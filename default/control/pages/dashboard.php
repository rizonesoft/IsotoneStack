<?php
/**
 * Dashboard Page - System Overview
 */

// Get system information
$systemInfo = [
    'hostname' => gethostname(),
    'os' => php_uname('s') . ' ' . php_uname('r'),
    'php_version' => PHP_VERSION,
    'server_software' => $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown',
    'server_time' => date('Y-m-d H:i:s'),
    'uptime' => @exec('wmic OS get LastBootUpTime')
];

// Get disk usage
$diskTotal = disk_total_space('C:');
$diskFree = disk_free_space('C:');
$diskUsed = $diskTotal - $diskFree;
$diskPercent = ($diskUsed / $diskTotal) * 100;

// Get memory usage (Windows)
$memInfo = @shell_exec('wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value');
preg_match('/TotalVisibleMemorySize=(\d+)/', $memInfo, $totalMem);
preg_match('/FreePhysicalMemory=(\d+)/', $memInfo, $freeMem);
$totalMemMB = isset($totalMem[1]) ? $totalMem[1] / 1024 : 0;
$freeMemMB = isset($freeMem[1]) ? $freeMem[1] / 1024 : 0;
$usedMemMB = $totalMemMB - $freeMemMB;
$memPercent = $totalMemMB > 0 ? ($usedMemMB / $totalMemMB) * 100 : 0;

// Check service status
$services = [
    'IsotoneApache' => checkServiceStatus('IsotoneApache'),
    'IsotoneMariaDB' => checkServiceStatus('IsotoneMariaDB'),
    'IsotoneMailpit' => checkServiceStatus('IsotoneMailpit')
];
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

<!-- System Stats Grid -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600">Apache</p>
                <p class="text-2xl font-bold <?php echo $services['IsotoneApache'] ? 'text-green-600' : 'text-red-600'; ?>">
                    <?php echo $services['IsotoneApache'] ? 'Running' : 'Stopped'; ?>
                </p>
            </div>
            <svg class="w-12 h-12 text-red-500 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2"></path>
            </svg>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600">MariaDB</p>
                <p class="text-2xl font-bold <?php echo $services['IsotoneMariaDB'] ? 'text-green-600' : 'text-red-600'; ?>">
                    <?php echo $services['IsotoneMariaDB'] ? 'Running' : 'Stopped'; ?>
                </p>
            </div>
            <svg class="w-12 h-12 text-blue-500 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4"></path>
            </svg>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600">PHP Version</p>
                <p class="text-2xl font-bold text-purple-600"><?php echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION; ?></p>
            </div>
            <svg class="w-12 h-12 text-purple-500 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path>
            </svg>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-sm text-gray-600">Mailpit</p>
                <p class="text-2xl font-bold <?php echo $services['IsotoneMailpit'] ? 'text-green-600' : 'text-red-600'; ?>">
                    <?php echo $services['IsotoneMailpit'] ? 'Running' : 'Stopped'; ?>
                </p>
            </div>
            <svg class="w-12 h-12 text-teal-500 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
            </svg>
        </div>
    </div>
</div>

<!-- System Resources -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold mb-4">Disk Usage</h2>
        <div class="mb-2">
            <div class="flex justify-between text-sm mb-1">
                <span>C: Drive</span>
                <span><?php echo number_format($diskPercent, 1); ?>%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-4">
                <div class="bg-blue-600 h-4 rounded-full" style="width: <?php echo $diskPercent; ?>%"></div>
            </div>
            <div class="flex justify-between text-xs text-gray-600 mt-1">
                <span>Used: <?php echo number_format($diskUsed / 1024 / 1024 / 1024, 1); ?> GB</span>
                <span>Free: <?php echo number_format($diskFree / 1024 / 1024 / 1024, 1); ?> GB</span>
            </div>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold mb-4">Memory Usage</h2>
        <div class="mb-2">
            <div class="flex justify-between text-sm mb-1">
                <span>RAM</span>
                <span><?php echo number_format($memPercent, 1); ?>%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-4">
                <div class="bg-green-600 h-4 rounded-full" style="width: <?php echo $memPercent; ?>%"></div>
            </div>
            <div class="flex justify-between text-xs text-gray-600 mt-1">
                <span>Used: <?php echo number_format($usedMemMB, 0); ?> MB</span>
                <span>Free: <?php echo number_format($freeMemMB, 0); ?> MB</span>
            </div>
        </div>
    </div>
</div>

<!-- System Information -->
<div class="bg-white rounded-lg shadow p-6 mb-8">
    <h2 class="text-lg font-semibold mb-4">System Information</h2>
    <div class="grid grid-cols-2 gap-4">
        <div>
            <p class="text-sm text-gray-600">Hostname</p>
            <p class="font-medium"><?php echo $systemInfo['hostname']; ?></p>
        </div>
        <div>
            <p class="text-sm text-gray-600">Operating System</p>
            <p class="font-medium"><?php echo $systemInfo['os']; ?></p>
        </div>
        <div>
            <p class="text-sm text-gray-600">PHP Version</p>
            <p class="font-medium"><?php echo $systemInfo['php_version']; ?></p>
        </div>
        <div>
            <p class="text-sm text-gray-600">Server Software</p>
            <p class="font-medium"><?php echo $systemInfo['server_software']; ?></p>
        </div>
        <div>
            <p class="text-sm text-gray-600">Server Time</p>
            <p class="font-medium"><?php echo $systemInfo['server_time']; ?></p>
        </div>
        <div>
            <p class="text-sm text-gray-600">Document Root</p>
            <p class="font-medium">C:/isotone/www</p>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold mb-4">Quick Actions</h2>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <a href="?page=services" class="bg-blue-100 hover:bg-blue-200 rounded-lg p-4 text-center transition-colors">
            <svg class="w-8 h-8 mx-auto mb-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            <span class="text-sm">Restart Services</span>
        </a>
        <a href="/phpmyadmin/" target="_blank" class="bg-orange-100 hover:bg-orange-200 rounded-lg p-4 text-center transition-colors">
            <svg class="w-8 h-8 mx-auto mb-2 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7"></path>
            </svg>
            <span class="text-sm">phpMyAdmin</span>
        </a>
        <a href="?page=logs" class="bg-yellow-100 hover:bg-yellow-200 rounded-lg p-4 text-center transition-colors">
            <svg class="w-8 h-8 mx-auto mb-2 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <span class="text-sm">View Logs</span>
        </a>
        <a href="?page=backup" class="bg-green-100 hover:bg-green-200 rounded-lg p-4 text-center transition-colors">
            <svg class="w-8 h-8 mx-auto mb-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
            </svg>
            <span class="text-sm">Backup</span>
        </a>
    </div>
</div>