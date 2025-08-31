<?php
/**
 * Script Management Page
 * Execute PowerShell scripts from the web interface
 */

// Handle script execution
$output = '';
$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['execute_script'])) {
    $scriptCategory = $_POST['category'] ?? '';
    $scriptName = $_POST['script'] ?? '';
    $parameters = $_POST['parameters'] ?? '';
    
    // Get IsotoneStack root path
    $isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
    $scriptsPath = $isotonePath . DIRECTORY_SEPARATOR . 'scripts';
    
    // Define available scripts by category
    $availableScripts = [
        'services' => [
            'Start-Services.ps1' => 'Start all IsotoneStack services',
            'Stop-Services.ps1' => 'Stop all IsotoneStack services',
            'Register-Services.ps1' => 'Register services with Windows',
            'Unregister-Services.ps1' => 'Unregister services from Windows',
            'Restart-Apache.ps1' => 'Restart Apache service'
        ],
        'mariadb' => [
            'Import-Database.ps1' => 'Import database from SQL file',
            'Import-DataFolder.ps1' => 'Import MariaDB data folder',
            'Repair-Database.ps1' => 'Repair corrupted database',
            'Drop-Database.ps1' => 'Drop database completely',
            'Backup-Database.ps1' => 'Backup database to SQL file'
        ],
        'phpmyadmin' => [
            'Setup-phpMyAdmin-Storage.ps1' => 'Setup phpMyAdmin storage',
            'Secure-phpMyAdmin-ControlUser.ps1' => 'Secure phpMyAdmin control user'
        ],
        'configuration' => [
            'Configure-IsotoneStack.ps1' => 'Configure IsotoneStack installation',
            'Complete-Install.ps1' => 'Complete installation setup',
            'Install-VCRedist.ps1' => 'Install Visual C++ Redistributables'
        ]
    ];
    
    // Validate script selection
    if (!isset($availableScripts[$scriptCategory][$scriptName])) {
        $error = "Invalid script selection";
    } else {
        // Build script path
        if ($scriptCategory === 'services' || $scriptCategory === 'configuration') {
            $scriptPath = "$scriptsPath\\$scriptName";
        } else {
            $scriptPath = "$scriptsPath\\$scriptCategory\\$scriptName";
        }
        
        // Check if script exists
        if (!file_exists($scriptPath)) {
            $error = "Script not found: $scriptPath";
        } else {
            // Build command
            $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptPath\"";
            
            // Add parameters if provided
            if (!empty($parameters)) {
                // Sanitize parameters
                $parameters = escapeshellarg($parameters);
                $command .= " $parameters";
            }
            
            $command .= " 2>&1";
            
            // Execute script
            $output = shell_exec($command);
            
            // Check for success indicators
            if (strpos($output, '[OK]') !== false || strpos($output, 'successfully') !== false) {
                $success = "Script executed successfully";
            } else if (strpos($output, '[ERROR]') !== false || strpos($output, 'failed') !== false) {
                $error = "Script execution failed - check output for details";
            } else {
                $success = "Script execution completed";
            }
        }
    }
}

// Get available scripts grouped by category
$scriptCategories = [
    'services' => 'Service Management',
    'mariadb' => 'Database Management',
    'phpmyadmin' => 'phpMyAdmin Management',
    'configuration' => 'Configuration & Setup'
];
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Script Management</h1>

<?php if (!empty($success)): ?>
<div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Success!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($success); ?></span>
</div>
<?php endif; ?>

<?php if (!empty($error)): ?>
<div class="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Error!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($error); ?></span>
</div>
<?php endif; ?>

<!-- Script Execution Form -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Execute Script</h2>
    
    <form method="POST" class="space-y-4">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Script Category</label>
            <select name="category" id="scriptCategory" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                <option value="">Select a category...</option>
                <?php foreach ($scriptCategories as $key => $label): ?>
                    <option value="<?php echo $key; ?>"><?php echo $label; ?></option>
                <?php endforeach; ?>
            </select>
        </div>
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Script</label>
            <select name="script" id="scriptName" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" required disabled>
                <option value="">Select a category first...</option>
            </select>
            <p id="scriptDescription" class="mt-1 text-sm text-gray-600"></p>
        </div>
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Parameters (optional)</label>
            <input type="text" name="parameters" id="scriptParameters" 
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                   placeholder="Enter script parameters if needed">
            <p class="mt-1 text-sm text-gray-600">Examples: database_name for Drop-Database, file.sql for Import-Database</p>
        </div>
        
        <div>
            <button type="submit" name="execute_script" 
                    class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
                Execute Script
            </button>
        </div>
    </form>
</div>

<!-- Script Output -->
<?php if (!empty($output)): ?>
<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Script Output</h2>
    <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto text-sm font-mono"><?php echo htmlspecialchars($output); ?></pre>
</div>
<?php endif; ?>

<!-- Available Scripts Reference -->
<div class="mt-8 bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Available Scripts</h2>
    
    <?php foreach ($scriptCategories as $category => $categoryLabel): ?>
    <div class="mb-6">
        <h3 class="text-lg font-medium text-gray-800 mb-2"><?php echo $categoryLabel; ?></h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-2">
            <?php 
            $scripts = $availableScripts[$category] ?? [];
            foreach ($scripts as $script => $description): 
            ?>
            <div class="flex items-start space-x-2 text-sm">
                <span class="text-gray-600 font-mono"><?php echo str_replace('.ps1', '', $script); ?></span>
                <span class="text-gray-500">-</span>
                <span class="text-gray-700"><?php echo $description; ?></span>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endforeach; ?>
</div>

<!-- Security Warning -->
<div class="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
    <div class="flex">
        <svg class="w-5 h-5 text-yellow-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
        </svg>
        <div class="text-sm text-yellow-800">
            <p class="font-semibold mb-1">Security Notice:</p>
            <ul class="list-disc list-inside space-y-1">
                <li>Scripts are executed with Administrator privileges</li>
                <li>Always verify parameters before execution</li>
                <li>Some scripts may restart services or modify system configuration</li>
                <li>Review script output carefully for any errors or warnings</li>
            </ul>
        </div>
    </div>
</div>

<script>
// Script data for dynamic population
const scriptData = <?php echo json_encode($availableScripts); ?>;

// Handle category selection
document.getElementById('scriptCategory').addEventListener('change', function() {
    const category = this.value;
    const scriptSelect = document.getElementById('scriptName');
    const scriptDescription = document.getElementById('scriptDescription');
    const parametersInput = document.getElementById('scriptParameters');
    
    // Clear script selection
    scriptSelect.innerHTML = '<option value="">Select a script...</option>';
    scriptDescription.textContent = '';
    parametersInput.value = '';
    
    if (category && scriptData[category]) {
        // Enable script selection
        scriptSelect.disabled = false;
        
        // Populate scripts for selected category
        Object.keys(scriptData[category]).forEach(script => {
            const option = document.createElement('option');
            option.value = script;
            option.textContent = script.replace('.ps1', '');
            scriptSelect.appendChild(option);
        });
    } else {
        scriptSelect.disabled = true;
    }
});

// Handle script selection
document.getElementById('scriptName').addEventListener('change', function() {
    const category = document.getElementById('scriptCategory').value;
    const script = this.value;
    const scriptDescription = document.getElementById('scriptDescription');
    const parametersInput = document.getElementById('scriptParameters');
    
    if (category && script && scriptData[category][script]) {
        scriptDescription.textContent = scriptData[category][script];
        
        // Set placeholder based on script
        if (script.includes('Drop-Database')) {
            parametersInput.placeholder = 'Enter database name (e.g., isotone_db)';
        } else if (script.includes('Import-Database')) {
            parametersInput.placeholder = 'Enter SQL file path';
        } else if (script.includes('Import-DataFolder')) {
            parametersInput.placeholder = 'Enter data folder path';
        } else if (script.includes('Backup-Database')) {
            parametersInput.placeholder = 'Enter database name to backup';
        } else if (script.includes('Repair-Database')) {
            parametersInput.placeholder = 'Enter database name to repair';
        } else {
            parametersInput.placeholder = 'Enter script parameters if needed';
        }
    } else {
        scriptDescription.textContent = '';
    }
});
</script>