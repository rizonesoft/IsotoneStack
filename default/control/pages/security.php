<?php
/**
 * Security Management Page
 * Manage authentication and security settings
 */

$message = '';
$error = '';

// Handle password change
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    $currentPassword = $_POST['current_password'] ?? '';
    $newPassword = $_POST['new_password'] ?? '';
    $confirmPassword = $_POST['confirm_password'] ?? '';
    
    // Get config file path
    $isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
    $configFile = $isotonePath . DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'control-panel.json';
    
    // Load or create config
    if (file_exists($configFile)) {
        $config = json_decode(file_get_contents($configFile), true);
    } else {
        $config = ['password' => 'isotone']; // Default password
    }
    
    // Verify current password
    $currentHash = isset($config['password_hash']) ? $config['password_hash'] : null;
    $currentPlain = isset($config['password']) ? $config['password'] : 'isotone';
    
    $validPassword = false;
    if ($currentHash && password_verify($currentPassword, $currentHash)) {
        $validPassword = true;
    } elseif (!$currentHash && $currentPassword === $currentPlain) {
        $validPassword = true;
    }
    
    if (!$validPassword) {
        $error = 'Current password is incorrect';
    } elseif ($newPassword !== $confirmPassword) {
        $error = 'New passwords do not match';
    } elseif (strlen($newPassword) < 8) {
        $error = 'Password must be at least 8 characters long';
    } else {
        // Update password
        $config['password_hash'] = password_hash($newPassword, PASSWORD_DEFAULT);
        unset($config['password']); // Remove plain text password
        
        // Save config
        if (file_put_contents($configFile, json_encode($config, JSON_PRETTY_PRINT))) {
            $message = 'Password updated successfully';
        } else {
            $error = 'Failed to save configuration';
        }
    }
}

// Handle session timeout setting
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_timeout'])) {
    $timeout = intval($_POST['session_timeout']);
    
    if ($timeout < 5 || $timeout > 1440) {
        $error = 'Session timeout must be between 5 and 1440 minutes';
    } else {
        $isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
        $configFile = $isotonePath . DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'control-panel.json';
        
        if (file_exists($configFile)) {
            $config = json_decode(file_get_contents($configFile), true);
        } else {
            $config = [];
        }
        
        $config['session_timeout'] = $timeout;
        
        if (file_put_contents($configFile, json_encode($config, JSON_PRETTY_PRINT))) {
            $message = 'Session timeout updated successfully';
        } else {
            $error = 'Failed to save configuration';
        }
    }
}

// Load current settings
$isotonePath = dirname(dirname(dirname(dirname(__FILE__))));
$configFile = $isotonePath . DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'control-panel.json';
$currentTimeout = 30; // Default 30 minutes

if (file_exists($configFile)) {
    $config = json_decode(file_get_contents($configFile), true);
    $currentTimeout = $config['session_timeout'] ?? 30;
}

// Get security status
$securityChecks = [
    'password_strength' => [
        'label' => 'Password Strength',
        'status' => isset($config['password_hash']) ? 'secure' : 'weak',
        'message' => isset($config['password_hash']) ? 'Using hashed password' : 'Using default password'
    ],
    'ssl_enabled' => [
        'label' => 'SSL/HTTPS',
        'status' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'enabled' : 'disabled',
        'message' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'Connection is secure' : 'Not using HTTPS'
    ],
    'session_security' => [
        'label' => 'Session Security',
        'status' => ini_get('session.cookie_httponly') ? 'enabled' : 'partial',
        'message' => ini_get('session.cookie_httponly') ? 'HttpOnly cookies enabled' : 'HttpOnly cookies disabled'
    ],
    'file_permissions' => [
        'label' => 'File Permissions',
        'status' => 'check',
        'message' => 'Manual review recommended'
    ]
];
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Security Settings</h1>

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

<!-- Security Status -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Security Status</h2>
    
    <div class="space-y-3">
        <?php foreach ($securityChecks as $check): ?>
        <div class="flex items-center justify-between p-3 bg-gray-50 rounded">
            <div>
                <span class="font-medium"><?php echo $check['label']; ?></span>
                <p class="text-sm text-gray-600"><?php echo $check['message']; ?></p>
            </div>
            <div>
                <?php if ($check['status'] === 'secure' || $check['status'] === 'enabled'): ?>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                        <span class="w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                        Secure
                    </span>
                <?php elseif ($check['status'] === 'weak' || $check['status'] === 'disabled'): ?>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                        <span class="w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                        Needs Attention
                    </span>
                <?php else: ?>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-yellow-100 text-yellow-800">
                        <span class="w-2 h-2 bg-yellow-500 rounded-full mr-2"></span>
                        Review
                    </span>
                <?php endif; ?>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Change Password -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Change Password</h2>
    
    <form method="POST" class="space-y-4">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Current Password</label>
            <input type="password" name="current_password" required
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">New Password</label>
            <input type="password" name="new_password" required minlength="8"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <p class="mt-1 text-sm text-gray-600">Minimum 8 characters</p>
        </div>
        
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Confirm New Password</label>
            <input type="password" name="confirm_password" required
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
        </div>
        
        <div>
            <button type="submit" name="change_password"
                    class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
                Update Password
            </button>
        </div>
    </form>
</div>

<!-- Session Settings -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <h2 class="text-xl font-semibold mb-4">Session Settings</h2>
    
    <form method="POST" class="space-y-4">
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Session Timeout (minutes)</label>
            <input type="number" name="session_timeout" min="5" max="1440" value="<?php echo $currentTimeout; ?>"
                   class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
            <p class="mt-1 text-sm text-gray-600">Automatically logout after this period of inactivity</p>
        </div>
        
        <div>
            <button type="submit" name="update_timeout"
                    class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
                Update Timeout
            </button>
        </div>
    </form>
</div>

<!-- Security Recommendations -->
<div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
    <div class="flex">
        <svg class="w-5 h-5 text-blue-600 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
        </svg>
        <div class="text-sm text-blue-800">
            <p class="font-semibold mb-1">Security Recommendations:</p>
            <ul class="list-disc list-inside space-y-1">
                <li>Change the default password immediately after installation</li>
                <li>Use a strong password with mixed case, numbers, and symbols</li>
                <li>Enable HTTPS/SSL for secure connections</li>
                <li>Regularly review and update file permissions</li>
                <li>Keep IsotoneStack and all components updated</li>
                <li>Restrict control panel access to trusted IP addresses</li>
                <li>Regularly backup your configuration and databases</li>
            </ul>
        </div>
    </div>
</div>