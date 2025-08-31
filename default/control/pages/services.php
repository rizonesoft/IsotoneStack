<?php
/**
 * Services Management Page
 * Uses PowerShell scripts for service management
 */

// Handle service actions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && isset($_POST['service'])) {
    $action = $_POST['action'];
    $service = $_POST['service'];
    
    // Get IsotoneStack root path
    $isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
    $scriptsPath = $isotonePath . DIRECTORY_SEPARATOR . 'scripts';
    
    // Security: Validate service name
    $validServices = ['IsotoneApache', 'IsotoneMariaDB', 'IsotoneMailpit', 'all'];
    if (!in_array($service, $validServices)) {
        $error = "Invalid service name";
    } else {
        // Execute appropriate PowerShell script
        switch ($action) {
            case 'start':
                if ($service === 'all') {
                    $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Start-Services.ps1\" 2>&1";
                } else {
                    $command = "net start $service 2>&1";
                }
                break;
                
            case 'stop':
                if ($service === 'all') {
                    $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Stop-Services.ps1\" 2>&1";
                } else {
                    $command = "net stop $service 2>&1";
                }
                break;
                
            case 'restart':
                if ($service === 'all') {
                    // Stop then start all services
                    $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Stop-Services.ps1\" && powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Start-Services.ps1\" 2>&1";
                } else if ($service === 'IsotoneApache') {
                    // Use the Restart-Apache script if it exists
                    if (file_exists("$scriptsPath\\Restart-Apache.ps1")) {
                        $command = "powershell.exe -ExecutionPolicy Bypass -File \"$scriptsPath\\Restart-Apache.ps1\" 2>&1";
                    } else {
                        $command = "net stop $service && net start $service 2>&1";
                    }
                } else {
                    $command = "net stop $service && net start $service 2>&1";
                }
                break;
                
            default:
                $error = "Invalid action";
        }
        
        if (!isset($error)) {
            // Execute command
            $output = shell_exec($command);
            
            // Check if successful
            if (strpos($output, 'successfully') !== false || strpos($output, 'started') !== false) {
                $success = ucfirst($action) . " operation completed for " . ($service === 'all' ? 'all services' : $service);
            } else {
                $error = "Operation failed. Output: " . substr($output, 0, 200);
            }
            
            // Wait a moment for service status to update
            sleep(2);
        }
    }
}

// Service definitions
$services = [
    [
        'name' => 'IsotoneApache',
        'display' => 'Apache HTTP Server',
        'description' => 'Serves web pages and handles HTTP requests',
        'port' => '80, 443',
        'status' => checkServiceStatus('IsotoneApache'),
        'icon' => 'server',
        'color' => 'red'
    ],
    [
        'name' => 'IsotoneMariaDB',
        'display' => 'MariaDB Database',
        'description' => 'MySQL-compatible database server',
        'port' => '3306',
        'status' => checkServiceStatus('IsotoneMariaDB'),
        'icon' => 'database',
        'color' => 'blue'
    ],
    [
        'name' => 'IsotoneMailpit',
        'display' => 'Mailpit Email Testing',
        'description' => 'Captures and displays test emails',
        'port' => '1025, 8025',
        'status' => checkServiceStatus('IsotoneMailpit'),
        'icon' => 'mail',
        'color' => 'teal'
    ]
];
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Service Management</h1>

<?php if (isset($success)): ?>
<div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Success!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($success); ?></span>
</div>
<?php endif; ?>

<?php if (isset($error)): ?>
<div class="mb-6 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
    <strong class="font-bold">Error!</strong>
    <span class="block sm:inline"><?php echo htmlspecialchars($error); ?></span>
</div>
<?php endif; ?>

<!-- Service Controls -->
<div class="mb-6 bg-white rounded-lg shadow p-4">
    <div class="flex items-center justify-between">
        <h2 class="text-lg font-semibold">Quick Actions</h2>
        <div class="space-x-2">
            <form method="POST" class="inline">
                <input type="hidden" name="action" value="start">
                <input type="hidden" name="service" value="all">
                <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                    Start All Services
                </button>
            </form>
            <form method="POST" class="inline">
                <input type="hidden" name="action" value="stop">
                <input type="hidden" name="service" value="all">
                <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                    Stop All Services
                </button>
            </form>
            <form method="POST" class="inline">
                <input type="hidden" name="action" value="restart">
                <input type="hidden" name="service" value="all">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors">
                    Restart All Services
                </button>
            </form>
        </div>
    </div>
</div>

<!-- Individual Services -->
<div class="space-y-4">
    <?php foreach ($services as $service): ?>
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
                <!-- Service Icon -->
                <div class="p-3 bg-<?php echo $service['color']; ?>-100 rounded-lg">
                    <?php if ($service['icon'] === 'server'): ?>
                    <svg class="w-8 h-8 text-<?php echo $service['color']; ?>-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2"></path>
                    </svg>
                    <?php elseif ($service['icon'] === 'database'): ?>
                    <svg class="w-8 h-8 text-<?php echo $service['color']; ?>-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"></path>
                    </svg>
                    <?php elseif ($service['icon'] === 'mail'): ?>
                    <svg class="w-8 h-8 text-<?php echo $service['color']; ?>-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                    <?php endif; ?>
                </div>
                
                <!-- Service Info -->
                <div>
                    <h3 class="text-lg font-semibold text-gray-900"><?php echo $service['display']; ?></h3>
                    <p class="text-sm text-gray-600"><?php echo $service['description']; ?></p>
                    <div class="mt-1 flex items-center space-x-4">
                        <span class="text-xs text-gray-500">Port: <?php echo $service['port']; ?></span>
                        <span class="text-xs text-gray-500">Service: <?php echo $service['name']; ?></span>
                    </div>
                </div>
            </div>
            
            <!-- Status and Controls -->
            <div class="flex items-center space-x-4">
                <!-- Status -->
                <div class="text-right">
                    <?php if ($service['status']): ?>
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                            Running
                        </span>
                    <?php else: ?>
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                            <span class="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                            Stopped
                        </span>
                    <?php endif; ?>
                </div>
                
                <!-- Control Buttons -->
                <div class="flex space-x-2">
                    <?php if (!$service['status']): ?>
                    <form method="POST" class="inline">
                        <input type="hidden" name="action" value="start">
                        <input type="hidden" name="service" value="<?php echo $service['name']; ?>">
                        <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm font-medium transition-colors">
                            Start
                        </button>
                    </form>
                    <?php else: ?>
                    <form method="POST" class="inline">
                        <input type="hidden" name="action" value="stop">
                        <input type="hidden" name="service" value="<?php echo $service['name']; ?>">
                        <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm font-medium transition-colors">
                            Stop
                        </button>
                    </form>
                    <form method="POST" class="inline">
                        <input type="hidden" name="action" value="restart">
                        <input type="hidden" name="service" value="<?php echo $service['name']; ?>">
                        <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm font-medium transition-colors">
                            Restart
                        </button>
                    </form>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
    <?php endforeach; ?>
</div>

<!-- Service Information -->
<div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
    <div class="flex">
        <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
        </svg>
        <div class="text-sm text-blue-800">
            <p class="font-semibold mb-1">Service Management Notes:</p>
            <ul class="list-disc list-inside space-y-1">
                <li>Services are managed through Windows Service Control Manager</li>
                <li>Stopping Apache will make web interfaces unavailable</li>
                <li>Stopping MariaDB will disconnect database connections</li>
                <li>Mailpit can be safely stopped without affecting other services</li>
                <li>Always ensure proper shutdown of services before system restart</li>
            </ul>
        </div>
    </div>
</div>