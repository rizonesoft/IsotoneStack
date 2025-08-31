<?php
/**
 * IsotoneStack - Dashboard
 * Dynamic component information and control panel
 */

// Component version detection functions
function getApacheVersion() {
    if (function_exists('apache_get_version')) {
        $version = apache_get_version();
        if (preg_match('/Apache\/(\d+\.\d+\.\d+)/', $version, $matches)) {
            return $matches[1];
        }
    }
    return 'Unknown';
}

function getPHPVersion() {
    return PHP_VERSION;
}

function getMariaDBVersion() {
    $mysqli = @new mysqli('localhost', 'root', '');
    if (!$mysqli->connect_error) {
        $result = $mysqli->query("SELECT VERSION()");
        if ($result) {
            $row = $result->fetch_row();
            $mysqli->close();
            return $row[0];
        }
        $mysqli->close();
    }
    return 'Not Connected';
}

function getPhpMyAdminVersion() {
    $configFile = 'C:/isotone/phpmyadmin/RELEASE-DATE-5.2.2';
    if (file_exists($configFile)) {
        return '5.2.2';
    }
    return 'Unknown';
}

function getMailpitStatus() {
    $socket = @fsockopen('localhost', 1025, $errno, $errstr, 1);
    if ($socket) {
        fclose($socket);
        return 'Running';
    }
    return 'Stopped';
}

// Component definitions
$components = [
    [
        'name' => 'Apache',
        'description' => 'High-performance HTTP Server',
        'version' => getApacheVersion(),
        'status' => 'Running',
        'icon' => 'server',
        'color' => 'red',
        'url' => null,
        'port' => '80, 443'
    ],
    [
        'name' => 'PHP',
        'description' => 'Server-side scripting language',
        'version' => getPHPVersion(),
        'status' => 'Active',
        'icon' => 'code',
        'color' => 'purple',
        'url' => '/default/phpinfo.php',
        'port' => null
    ],
    [
        'name' => 'MariaDB',
        'description' => 'MySQL-compatible database server',
        'version' => getMariaDBVersion(),
        'status' => strpos(getMariaDBVersion(), 'Not Connected') === false ? 'Running' : 'Stopped',
        'icon' => 'database',
        'color' => 'blue',
        'url' => null,
        'port' => '3306'
    ],
    [
        'name' => 'phpMyAdmin',
        'description' => 'Web-based MySQL administration',
        'version' => getPhpMyAdminVersion(),
        'status' => 'Available',
        'icon' => 'table',
        'color' => 'orange',
        'url' => '/phpmyadmin/',
        'port' => null
    ],
    [
        'name' => 'phpLiteAdmin',
        'description' => 'SQLite database management',
        'version' => '1.9.8.2',
        'status' => 'Available',
        'icon' => 'collection',
        'color' => 'green',
        'url' => '/phpliteadmin/',
        'port' => null
    ],
    [
        'name' => 'Adminer',
        'description' => 'Universal database management',
        'version' => '5.3.0',
        'status' => 'Available',
        'icon' => 'view-grid',
        'color' => 'indigo',
        'url' => '/adminer/',
        'port' => null
    ],
    [
        'name' => 'Mailpit',
        'description' => 'Email testing and capture tool',
        'version' => '1.27.7',
        'status' => getMailpitStatus(),
        'icon' => 'mail',
        'color' => 'teal',
        'url' => 'http://localhost:8025',
        'port' => '1025, 8025'
    ],
    [
        'name' => 'Control Panel',
        'description' => 'IsotoneStack Management Interface',
        'version' => '1.0',
        'status' => 'Available',
        'icon' => 'cog',
        'color' => 'gray',
        'url' => '/default/control/',
        'port' => null
    ],
    [
        'name' => 'Chromium',
        'description' => 'Portable development browser',
        'version' => file_exists('C:/isotone/browser/chromium/chrome.exe') ? 'Installed' : 'Not Installed',
        'status' => file_exists('C:/isotone/browser/chromium/chrome.exe') ? 'Available' : 'Download Required',
        'icon' => 'globe',
        'color' => 'blue',
        'url' => file_exists('C:/isotone/browser/chromium/chrome.exe') ? '#' : 'https://github.com/portapps/ungoogled-chromium-portable',
        'port' => null
    ]
];

// Get system information
$systemInfo = [
    'os' => php_uname('s') . ' ' . php_uname('r'),
    'hostname' => gethostname(),
    'ip' => $_SERVER['SERVER_ADDR'] ?? 'localhost',
    'php_sapi' => php_sapi_name(),
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack - Professional Development Environment</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/heroicons@2.0.18/24/outline/style.css">
    <style>
        .hero-gradient {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .card-hover {
            transition: all 0.3s ease;
        }
        .card-hover:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
        .status-indicator {
            animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }
        @keyframes pulse {
            0%, 100% {
                opacity: 1;
            }
            50% {
                opacity: .5;
            }
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <div class="hero-gradient text-white">
        <div class="container mx-auto px-6 py-16">
            <div class="flex items-center justify-between">
                <div>
                    <h1 class="text-4xl font-bold mb-2">IsotoneStack</h1>
                    <p class="text-xl opacity-90">Professional Windows Development Environment</p>
                </div>
                <div class="text-right">
                    <p class="text-sm opacity-75">System: <?php echo $systemInfo['os']; ?></p>
                    <p class="text-sm opacity-75">Host: <?php echo $systemInfo['hostname']; ?></p>
                    <p class="text-sm opacity-75">IP: <?php echo $systemInfo['ip']; ?></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Stats -->
    <div class="container mx-auto px-6 -mt-8">
        <div class="bg-white rounded-lg shadow-lg p-6">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div class="text-center">
                    <div class="text-2xl font-bold text-gray-900"><?php echo count(array_filter($components, fn($c) => in_array($c['status'], ['Running', 'Active']))); ?></div>
                    <div class="text-sm text-gray-600">Active Services</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold text-gray-900"><?php echo count($components); ?></div>
                    <div class="text-sm text-gray-600">Total Components</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold text-gray-900">PHP <?php echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION; ?></div>
                    <div class="text-sm text-gray-600">Runtime Version</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold text-gray-900"><?php echo round(memory_get_usage() / 1024 / 1024, 1); ?> MB</div>
                    <div class="text-sm text-gray-600">Memory Usage</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Component Cards -->
    <div class="container mx-auto px-6 py-12">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Components & Services</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            <?php foreach ($components as $component): ?>
            <div class="bg-white rounded-lg shadow-md card-hover">
                <div class="p-6">
                    <!-- Icon and Status -->
                    <div class="flex items-center justify-between mb-4">
                        <div class="p-3 bg-<?php echo $component['color']; ?>-100 rounded-lg">
                            <?php 
                            // SVG icons for each component
                            $icons = [
                                'server' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01"></path></svg>',
                                'code' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>',
                                'database' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path></svg>',
                                'table' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path></svg>',
                                'collection' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path></svg>',
                                'view-grid' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path></svg>',
                                'mail' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>',
                                'cog' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>',
                                'globe' => '<svg class="w-6 h-6 text-' . $component['color'] . '-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path></svg>'
                            ];
                            echo $icons[$component['icon']] ?? $icons['cog'];
                            ?>
                        </div>
                        <div class="flex items-center">
                            <?php if ($component['status'] === 'Running' || $component['status'] === 'Active'): ?>
                                <span class="status-indicator w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                                <span class="text-xs text-green-600 font-semibold"><?php echo $component['status']; ?></span>
                            <?php elseif ($component['status'] === 'Stopped'): ?>
                                <span class="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                                <span class="text-xs text-red-600 font-semibold"><?php echo $component['status']; ?></span>
                            <?php else: ?>
                                <span class="w-2 h-2 bg-gray-400 rounded-full mr-2"></span>
                                <span class="text-xs text-gray-600 font-semibold"><?php echo $component['status']; ?></span>
                            <?php endif; ?>
                        </div>
                    </div>

                    <!-- Component Info -->
                    <h3 class="text-lg font-semibold text-gray-900 mb-1"><?php echo $component['name']; ?></h3>
                    <p class="text-sm text-gray-600 mb-3"><?php echo $component['description']; ?></p>
                    
                    <!-- Version and Port -->
                    <div class="space-y-1 mb-4">
                        <div class="flex justify-between text-xs">
                            <span class="text-gray-500">Version:</span>
                            <span class="text-gray-900 font-medium"><?php echo $component['version']; ?></span>
                        </div>
                        <?php if ($component['port']): ?>
                        <div class="flex justify-between text-xs">
                            <span class="text-gray-500">Port:</span>
                            <span class="text-gray-900 font-medium"><?php echo $component['port']; ?></span>
                        </div>
                        <?php endif; ?>
                    </div>

                    <!-- Action Button -->
                    <?php if ($component['url']): ?>
                    <a href="<?php echo $component['url']; ?>" 
                       class="block w-full text-center bg-<?php echo $component['color']; ?>-600 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-<?php echo $component['color']; ?>-700 transition-colors">
                        Open Interface
                    </a>
                    <?php else: ?>
                    <div class="block w-full text-center bg-gray-200 text-gray-500 rounded-lg px-4 py-2 text-sm font-medium cursor-not-allowed">
                        Service Only
                    </div>
                    <?php endif; ?>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Quick Links -->
    <div class="container mx-auto px-6 py-12">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Quick Actions</h2>
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                <a href="/default/control/" class="flex items-center justify-center p-4 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors">
                    <svg class="w-5 h-5 mr-2 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
                    </svg>
                    <span class="text-sm font-medium">Control Panel</span>
                </a>
                <a href="/phpmyadmin/" class="flex items-center justify-center p-4 bg-orange-100 rounded-lg hover:bg-orange-200 transition-colors">
                    <svg class="w-5 h-5 mr-2 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4"></path>
                    </svg>
                    <span class="text-sm font-medium">Databases</span>
                </a>
                <a href="http://localhost:8025" class="flex items-center justify-center p-4 bg-teal-100 rounded-lg hover:bg-teal-200 transition-colors">
                    <svg class="w-5 h-5 mr-2 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                    <span class="text-sm font-medium">Email Testing</span>
                </a>
                <a href="/default/phpinfo.php" class="flex items-center justify-center p-4 bg-purple-100 rounded-lg hover:bg-purple-200 transition-colors">
                    <svg class="w-5 h-5 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <span class="text-sm font-medium">PHP Info</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-12">
        <div class="container mx-auto px-6 py-8">
            <div class="flex flex-col md:flex-row justify-between items-center">
                <div class="mb-4 md:mb-0">
                    <p class="text-sm">IsotoneStack v1.0 - Professional Development Environment</p>
                    <p class="text-xs text-gray-400 mt-1">All components are open source and free for commercial use</p>
                </div>
                <div class="flex space-x-6">
                    <a href="/default/control/" class="text-sm hover:text-gray-300">Control Panel</a>
                    <a href="/default/docs/" class="text-sm hover:text-gray-300">Documentation</a>
                    <a href="https://github.com/isotonestack" class="text-sm hover:text-gray-300">GitHub</a>
                </div>
            </div>
        </div>
    </footer>
</body>
</html>