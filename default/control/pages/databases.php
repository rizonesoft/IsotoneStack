<?php
/**
 * Database Management Page
 * Manage MariaDB databases and operations
 */

$message = '';
$error = '';
$output = '';

// Get IsotoneStack paths
$isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
$mariadbPath = $isotonePath . DIRECTORY_SEPARATOR . 'mariadb' . DIRECTORY_SEPARATOR . 'bin';
$dataPath = $isotonePath . DIRECTORY_SEPARATOR . 'mariadb' . DIRECTORY_SEPARATOR . 'data';

// Handle database operations
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['create_database'])) {
        $dbName = preg_replace('/[^a-zA-Z0-9_]/', '', $_POST['database_name']);
        if (empty($dbName)) {
            $error = "Invalid database name";
        } else {
            $command = "\"$mariadbPath\\mysql.exe\" -u root -e \"CREATE DATABASE IF NOT EXISTS `$dbName` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\" 2>&1";
            $output = shell_exec($command);
            if (strpos($output, 'ERROR') === false) {
                $message = "Database '$dbName' created successfully";
            } else {
                $error = "Failed to create database: " . substr($output, 0, 200);
            }
        }
    } elseif (isset($_POST['drop_database'])) {
        $dbName = $_POST['database_name'];
        if ($dbName === 'mysql' || $dbName === 'information_schema' || $dbName === 'performance_schema' || $dbName === 'sys') {
            $error = "Cannot drop system database";
        } else {
            $scriptsPath = $isotonePath . DIRECTORY_SEPARATOR . 'scripts' . DIRECTORY_SEPARATOR . 'mariadb';
            $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Drop-Database.ps1\" -DatabaseName \"$dbName\" 2>&1";
            $output = shell_exec($command);
            if (strpos($output, '[OK]') !== false) {
                $message = "Database '$dbName' dropped successfully";
            } else {
                $error = "Failed to drop database - check output for details";
            }
        }
    } elseif (isset($_POST['backup_database'])) {
        $dbName = $_POST['database_name'];
        $backupPath = $isotonePath . DIRECTORY_SEPARATOR . 'backups';
        if (!file_exists($backupPath)) {
            mkdir($backupPath, 0755, true);
        }
        $backupFile = $backupPath . DIRECTORY_SEPARATOR . $dbName . '_' . date('Y-m-d_His') . '.sql';
        
        $command = "\"$mariadbPath\\mysqldump.exe\" -u root --single-transaction --routines --triggers --events \"$dbName\" > \"$backupFile\" 2>&1";
        exec($command, $outputArr, $returnVar);
        
        if ($returnVar === 0 && file_exists($backupFile) && filesize($backupFile) > 0) {
            $message = "Database '$dbName' backed up to: " . basename($backupFile);
        } else {
            $error = "Failed to backup database";
            if (file_exists($backupFile) && filesize($backupFile) === 0) {
                unlink($backupFile);
            }
        }
    } elseif (isset($_POST['repair_database'])) {
        $dbName = $_POST['database_name'];
        $scriptsPath = $isotonePath . DIRECTORY_SEPARATOR . 'scripts' . DIRECTORY_SEPARATOR . 'mariadb';
        $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Repair-Database.ps1\" -DatabaseName \"$dbName\" 2>&1";
        $output = shell_exec($command);
        if (strpos($output, '[OK]') !== false) {
            $message = "Database '$dbName' repair completed";
        } else {
            $error = "Repair encountered issues - check output for details";
        }
    }
}

// Get list of databases
$databases = [];
$command = "\"$mariadbPath\\mysql.exe\" -u root -e \"SHOW DATABASES;\" 2>&1";
$result = shell_exec($command);
if ($result && strpos($result, 'ERROR') === false) {
    $lines = explode("\n", trim($result));
    foreach ($lines as $line) {
        $line = trim($line);
        if (!empty($line) && $line !== 'Database' && !strpos($line, 'WARNING')) {
            $databases[] = $line;
        }
    }
}

// Get database sizes
$dbSizes = [];
foreach ($databases as $db) {
    $command = "\"$mariadbPath\\mysql.exe\" -u root -e \"SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size FROM information_schema.TABLES WHERE table_schema = '$db';\" 2>&1";
    $result = shell_exec($command);
    if ($result && strpos($result, 'ERROR') === false) {
        $lines = explode("\n", trim($result));
        foreach ($lines as $line) {
            if (is_numeric(trim($line))) {
                $dbSizes[$db] = trim($line) . ' MB';
                break;
            }
        }
    }
    if (!isset($dbSizes[$db])) {
        $dbSizes[$db] = '0 MB';
    }
}
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Database Management</h1>

<?php if (!empty($message)): ?>
<div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Success!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($message); ?></span>
</div>
<?php endif; ?>

<?php if (!empty($error)): ?>
<div class="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Error!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($error); ?></span>
</div>
<?php endif; ?>

<!-- Quick Access Tools -->
<div class="mb-6 bg-white rounded-lg shadow p-4">
    <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold">Database Tools</h2>
        <div class="space-x-2">
            <a href="/phpmyadmin/" target="_blank" class="bg-orange-600 hover:bg-orange-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors inline-block">
                phpMyAdmin
            </a>
            <a href="/adminer/" target="_blank" class="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors inline-block">
                Adminer
            </a>
            <a href="/phpliteadmin/" target="_blank" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors inline-block">
                phpLiteAdmin
            </a>
        </div>
    </div>
</div>

<!-- Create New Database -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Create New Database</h2>
    
    <form method="POST" class="flex space-x-4">
        <input type="text" name="database_name" placeholder="Enter database name" required
               pattern="[a-zA-Z0-9_]+" title="Only letters, numbers, and underscores allowed"
               class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
        <button type="submit" name="create_database"
                class="bg-green-600 hover:bg-green-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
            Create Database
        </button>
    </form>
</div>

<!-- Existing Databases -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Existing Databases</h2>
    
    <?php if (empty($databases)): ?>
        <p class="text-gray-600">No databases found or MariaDB service is not running.</p>
    <?php else: ?>
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Database</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Size</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                        <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <?php foreach ($databases as $db): 
                        $isSystem = in_array($db, ['mysql', 'information_schema', 'performance_schema', 'sys']);
                    ?>
                    <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            <?php echo htmlspecialchars($db); ?>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <?php echo $dbSizes[$db] ?? 'Unknown'; ?>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <?php if ($isSystem): ?>
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                                    System
                                </span>
                            <?php else: ?>
                                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                                    User
                                </span>
                            <?php endif; ?>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <div class="flex justify-end space-x-2">
                                <?php if (!$isSystem): ?>
                                    <form method="POST" class="inline" onsubmit="return confirm('Backup database <?php echo $db; ?>?');">
                                        <input type="hidden" name="database_name" value="<?php echo htmlspecialchars($db); ?>">
                                        <button type="submit" name="backup_database" 
                                                class="text-blue-600 hover:text-blue-900">Backup</button>
                                    </form>
                                    <form method="POST" class="inline" onsubmit="return confirm('Repair database <?php echo $db; ?>?');">
                                        <input type="hidden" name="database_name" value="<?php echo htmlspecialchars($db); ?>">
                                        <button type="submit" name="repair_database" 
                                                class="text-yellow-600 hover:text-yellow-900">Repair</button>
                                    </form>
                                    <form method="POST" class="inline" onsubmit="return confirm('Are you sure you want to drop database <?php echo $db; ?>? This cannot be undone!');">
                                        <input type="hidden" name="database_name" value="<?php echo htmlspecialchars($db); ?>">
                                        <button type="submit" name="drop_database" 
                                                class="text-red-600 hover:text-red-900">Drop</button>
                                    </form>
                                <?php else: ?>
                                    <span class="text-gray-400">Protected</span>
                                <?php endif; ?>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</div>

<!-- Operation Output -->
<?php if (!empty($output)): ?>
<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Operation Output</h2>
    <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto text-sm font-mono"><?php echo htmlspecialchars($output); ?></pre>
</div>
<?php endif; ?>

<!-- Database Information -->
<div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
    <div class="flex">
        <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <div class="text-sm text-blue-800">
            <p class="font-semibold mb-1">Database Management Notes:</p>
            <ul class="list-disc list-inside space-y-1">
                <li>System databases are protected and cannot be dropped</li>
                <li>Backups are stored in the C:\isotone\backups directory</li>
                <li>Database repair attempts to fix corrupted tables</li>
                <li>Always backup databases before performing destructive operations</li>
                <li>MariaDB service must be running for database operations</li>
            </ul>
        </div>
    </div>
</div>