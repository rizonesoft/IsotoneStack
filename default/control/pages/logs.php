<?php
/**
 * Log Viewer Page
 * View and manage IsotoneStack logs
 */

// Get IsotoneStack paths
$isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
$logsPath = $isotonePath . DIRECTORY_SEPARATOR . 'logs';

// Get selected log
$selectedLog = $_GET['log'] ?? '';
$logContent = '';
$logFiles = [];

// Define log categories
$logCategories = [
    'Apache' => $logsPath . DIRECTORY_SEPARATOR . 'apache',
    'MariaDB' => $logsPath . DIRECTORY_SEPARATOR . 'mariadb',
    'IsotoneStack' => $logsPath . DIRECTORY_SEPARATOR . 'isotone',
    'PHP' => $logsPath . DIRECTORY_SEPARATOR . 'php'
];

// Get all log files
foreach ($logCategories as $category => $path) {
    if (is_dir($path)) {
        $files = glob($path . DIRECTORY_SEPARATOR . '*.{log,txt}', GLOB_BRACE);
        foreach ($files as $file) {
            $logFiles[$category][] = [
                'path' => $file,
                'name' => basename($file),
                'size' => filesize($file),
                'modified' => filemtime($file)
            ];
        }
    }
}

// Read selected log file
if (!empty($selectedLog) && file_exists($selectedLog)) {
    // Security check - ensure file is within logs directory
    $realPath = realpath($selectedLog);
    $realLogsPath = realpath($logsPath);
    
    if (strpos($realPath, $realLogsPath) === 0) {
        $lines = isset($_GET['lines']) ? intval($_GET['lines']) : 100;
        
        // Read last N lines
        $file = new SplFileObject($selectedLog, 'r');
        $file->seek(PHP_INT_MAX);
        $totalLines = $file->key();
        
        $startLine = max(0, $totalLines - $lines);
        $file->seek($startLine);
        
        $logContent = '';
        while (!$file->eof()) {
            $logContent .= $file->fgets();
        }
    }
}

// Handle log clearing
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['clear_log'])) {
    $logToClear = $_POST['log_path'];
    $realPath = realpath($logToClear);
    $realLogsPath = realpath($logsPath);
    
    if (strpos($realPath, $realLogsPath) === 0) {
        file_put_contents($logToClear, '');
        $message = 'Log file cleared successfully';
    }
}
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Log Viewer</h1>

<?php if (isset($message)): ?>
<div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Success!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($message); ?></span>
</div>
<?php endif; ?>

<div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
    <!-- Log Files List -->
    <div class="lg:col-span-1">
        <div class="bg-white rounded-lg shadow p-4">
            <h2 class="text-lg font-semibold mb-4">Log Files</h2>
            
            <?php foreach ($logCategories as $category => $path): ?>
                <?php if (isset($logFiles[$category]) && !empty($logFiles[$category])): ?>
                    <div class="mb-4">
                        <h3 class="text-sm font-medium text-gray-700 mb-2"><?php echo $category; ?></h3>
                        <div class="space-y-1">
                            <?php foreach ($logFiles[$category] as $file): ?>
                                <a href="?page=logs&log=<?php echo urlencode($file['path']); ?>" 
                                   class="block px-2 py-1 text-sm rounded hover:bg-gray-100 <?php echo $selectedLog === $file['path'] ? 'bg-blue-100 text-blue-700' : 'text-gray-600'; ?>">
                                    <div class="flex justify-between items-center">
                                        <span class="truncate"><?php echo htmlspecialchars($file['name']); ?></span>
                                        <span class="text-xs text-gray-500"><?php echo round($file['size'] / 1024, 1); ?>KB</span>
                                    </div>
                                    <div class="text-xs text-gray-500">
                                        <?php echo date('Y-m-d H:i', $file['modified']); ?>
                                    </div>
                                </a>
                            <?php endforeach; ?>
                        </div>
                    </div>
                <?php endif; ?>
            <?php endforeach; ?>
            
            <?php if (empty($logFiles)): ?>
                <p class="text-sm text-gray-600">No log files found</p>
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Log Content Viewer -->
    <div class="lg:col-span-3">
        <div class="bg-white rounded-lg shadow">
            <?php if (!empty($selectedLog)): ?>
                <div class="p-4 border-b border-gray-200">
                    <div class="flex justify-between items-center">
                        <div>
                            <h2 class="text-lg font-semibold"><?php echo basename($selectedLog); ?></h2>
                            <p class="text-sm text-gray-600">
                                <?php 
                                $fileSize = filesize($selectedLog);
                                echo round($fileSize / 1024, 2) . ' KB';
                                ?> | 
                                Last modified: <?php echo date('Y-m-d H:i:s', filemtime($selectedLog)); ?>
                            </p>
                        </div>
                        <div class="flex space-x-2">
                            <form method="GET" class="inline-flex items-center space-x-2">
                                <input type="hidden" name="page" value="logs">
                                <input type="hidden" name="log" value="<?php echo htmlspecialchars($selectedLog); ?>">
                                <label class="text-sm text-gray-600">Lines:</label>
                                <select name="lines" onchange="this.form.submit()" class="text-sm border border-gray-300 rounded px-2 py-1">
                                    <option value="50" <?php echo (isset($_GET['lines']) && $_GET['lines'] == 50) ? 'selected' : ''; ?>>50</option>
                                    <option value="100" <?php echo (!isset($_GET['lines']) || $_GET['lines'] == 100) ? 'selected' : ''; ?>>100</option>
                                    <option value="500" <?php echo (isset($_GET['lines']) && $_GET['lines'] == 500) ? 'selected' : ''; ?>>500</option>
                                    <option value="1000" <?php echo (isset($_GET['lines']) && $_GET['lines'] == 1000) ? 'selected' : ''; ?>>1000</option>
                                </select>
                            </form>
                            
                            <a href="?page=logs&log=<?php echo urlencode($selectedLog); ?>&lines=<?php echo isset($_GET['lines']) ? $_GET['lines'] : 100; ?>" 
                               class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm">
                                Refresh
                            </a>
                            
                            <form method="POST" class="inline" onsubmit="return confirm('Clear this log file?');">
                                <input type="hidden" name="log_path" value="<?php echo htmlspecialchars($selectedLog); ?>">
                                <button type="submit" name="clear_log" 
                                        class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm">
                                    Clear
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <div class="p-4">
                    <?php if (!empty($logContent)): ?>
                        <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto text-xs font-mono max-h-96 overflow-y-auto"><?php 
                            // Highlight log levels
                            $logContent = htmlspecialchars($logContent);
                            $logContent = preg_replace('/\[ERROR\]/', '<span class="text-red-400">[ERROR]</span>', $logContent);
                            $logContent = preg_replace('/\[WARNING\]/', '<span class="text-yellow-400">[WARNING]</span>', $logContent);
                            $logContent = preg_replace('/\[OK\]/', '<span class="text-green-400">[OK]</span>', $logContent);
                            $logContent = preg_replace('/\[INFO\]/', '<span class="text-blue-400">[INFO]</span>', $logContent);
                            echo $logContent;
                        ?></pre>
                    <?php else: ?>
                        <p class="text-gray-600">Log file is empty</p>
                    <?php endif; ?>
                </div>
            <?php else: ?>
                <div class="p-8 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    <p class="mt-2 text-gray-600">Select a log file to view its contents</p>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Log Information -->
<div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
    <div class="flex">
        <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <div class="text-sm text-blue-800">
            <p class="font-semibold mb-1">Log Viewer Notes:</p>
            <ul class="list-disc list-inside space-y-1">
                <li>Logs are organized by service category</li>
                <li>Only the last N lines are shown for large files</li>
                <li>Use the Refresh button to see latest entries</li>
                <li>Clear option removes all content from the log file</li>
                <li>Apache and MariaDB logs are rotated automatically</li>
                <li>IsotoneStack script logs include timestamps and severity levels</li>
            </ul>
        </div>
    </div>
</div>