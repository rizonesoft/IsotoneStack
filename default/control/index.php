<?php
/**
 * IsotoneStack Control Panel
 * Web-based management interface
 */

session_start();

// Simple authentication check (enhance this in production)
$authenticated = isset($_SESSION['authenticated']) && $_SESSION['authenticated'] === true;

// Handle login
if (isset($_POST['login'])) {
    $password = $_POST['password'] ?? '';
    // Default password - CHANGE THIS!
    if ($password === 'isotone') {
        $_SESSION['authenticated'] = true;
        $authenticated = true;
    } else {
        $error = 'Invalid password';
    }
}

// Handle logout
if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: /default/control/');
    exit;
}

// Check service status
function checkServiceStatus($serviceName) {
    $output = shell_exec("sc query $serviceName 2>&1");
    return strpos($output, 'RUNNING') !== false;
}

// Get current page
$page = $_GET['page'] ?? 'dashboard';

// If not authenticated, show login
if (!$authenticated) {
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack Control Panel - Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">
    <div class="min-h-screen flex items-center justify-center">
        <div class="bg-white p-8 rounded-lg shadow-md w-96">
            <h2 class="text-2xl font-bold mb-6 text-center">IsotoneStack Control Panel</h2>
            <?php if (isset($error)): ?>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                <?php echo $error; ?>
            </div>
            <?php endif; ?>
            <form method="POST">
                <div class="mb-4">
                    <label class="block text-gray-700 text-sm font-bold mb-2" for="password">
                        Password
                    </label>
                    <input class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" 
                           id="password" name="password" type="password" placeholder="Enter password" required>
                </div>
                <button class="w-full bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" 
                        type="submit" name="login">
                    Sign In
                </button>
            </form>
            <p class="text-xs text-gray-600 mt-4 text-center">Default password: isotone</p>
        </div>
    </div>
</body>
</html>
<?php
    exit;
}

// Main control panel interface
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack Control Panel</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .sidebar-item.active {
            background-color: #4F46E5;
            color: white;
        }
        .sidebar-item:hover {
            background-color: #E5E7EB;
        }
        .sidebar-item.active:hover {
            background-color: #4338CA;
        }
    </style>
</head>
<body class="bg-gray-100">
    <div class="flex h-screen">
        <!-- Sidebar -->
        <div class="w-64 bg-white shadow-md">
            <div class="p-4 bg-indigo-600 text-white">
                <h1 class="text-xl font-bold">IsotoneStack</h1>
                <p class="text-sm opacity-90">Control Panel</p>
            </div>
            
            <nav class="mt-4">
                <a href="?page=dashboard" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'dashboard' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                    </svg>
                    Dashboard
                </a>
                
                <a href="?page=services" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'services' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2"></path>
                    </svg>
                    Services
                </a>
                
                <a href="?page=databases" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'databases' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"></path>
                    </svg>
                    Databases
                </a>
                
                <a href="?page=vhosts" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'vhosts' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path>
                    </svg>
                    Virtual Hosts
                </a>
                
                <a href="?page=php" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'php' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
                    </svg>
                    PHP Settings
                </a>
                
                <a href="?page=logs" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'logs' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    Logs
                </a>
                
                <a href="?page=mailtest" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'mailtest' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                    Mail Test
                </a>
                
                <a href="?page=files" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'files' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
                    </svg>
                    File Manager
                </a>
                
                <a href="?page=security" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'security' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                    </svg>
                    Security
                </a>
                
                <a href="?page=backup" class="sidebar-item block px-4 py-3 text-gray-700 <?php echo $page === 'backup' ? 'active' : ''; ?>">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                    </svg>
                    Backup
                </a>
                
                <hr class="my-4">
                
                <a href="?logout" class="sidebar-item block px-4 py-3 text-red-600">
                    <svg class="inline w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                    Logout
                </a>
            </nav>
        </div>
        
        <!-- Main Content -->
        <div class="flex-1 overflow-y-auto">
            <div class="p-8">
                <?php
                // Include page content based on selection
                switch ($page) {
                    case 'dashboard':
                        include 'pages/dashboard.php';
                        break;
                    case 'services':
                        include 'pages/services.php';
                        break;
                    case 'databases':
                        include 'pages/databases.php';
                        break;
                    case 'vhosts':
                        include 'pages/vhosts.php';
                        break;
                    case 'php':
                        include 'pages/php.php';
                        break;
                    case 'logs':
                        include 'pages/logs.php';
                        break;
                    case 'mailtest':
                        include 'pages/mailtest.php';
                        break;
                    case 'files':
                        include 'pages/files.php';
                        break;
                    case 'security':
                        include 'pages/security.php';
                        break;
                    case 'backup':
                        include 'pages/backup.php';
                        break;
                    default:
                        include 'pages/dashboard.php';
                }
                ?>
            </div>
        </div>
    </div>
    
    <script>
        // Auto-refresh for service status
        if (window.location.search.includes('page=services') || window.location.search === '') {
            setInterval(function() {
                fetch('api/service-status.php')
                    .then(response => response.json())
                    .then(data => {
                        // Update service statuses
                        Object.keys(data).forEach(service => {
                            const element = document.getElementById('status-' + service);
                            if (element) {
                                element.textContent = data[service] ? 'Running' : 'Stopped';
                                element.className = data[service] ? 'text-green-600' : 'text-red-600';
                            }
                        });
                    });
            }, 5000);
        }
    </script>
</body>
</html>