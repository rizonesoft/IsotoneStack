<?php
/**
 * IsotoneStack Adminer Quick Access
 * Provides quick database access without manual login
 */

function adminer_object() {
    
    class IsotoneAdminer extends Adminer\Adminer {
        
        function name() {
            // Custom name in title and heading
            return 'IsotoneStack Database Manager';
        }
        
        function permanentLogin($create = false) {
            // Key used for permanent login
            return 'isotone_' . md5(__DIR__);
        }
        
        function credentials() {
            // Default credentials for MariaDB
            // These can be overridden by the login form
            return array('localhost', 'root', '');
        }
        
        function database() {
            // Default database - will be empty to show all databases
            return '';
        }
        
        function login($login, $password) {
            // Allow passwordless login for root user (local development)
            if ($login == 'root' && $password == '') {
                return true;
            }
            // Also allow any actual credentials
            return true;
        }
        
        function databases($flush = true) {
            // Get list of databases
            $databases = parent::databases($flush);
            
            // Add SQLite databases from sqlite folder if sqlite driver is selected
            if (isset($_GET['sqlite']) || (isset($_POST['auth']) && $_POST['auth']['driver'] == 'sqlite')) {
                $sqliteDir = dirname(__DIR__) . '/sqlite';
                if (is_dir($sqliteDir)) {
                    $files = glob($sqliteDir . '/*.db');
                    foreach ($files as $file) {
                        $databases[] = $file;
                    }
                }
            }
            
            return $databases;
        }
        
        function loginForm() {
            ?>
            <div style="background: #f0f0f0; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                <h2 style="margin-top: 0;">Quick Access</h2>
                <div style="display: flex; gap: 20px;">
                    <div style="flex: 1;">
                        <h3>MariaDB</h3>
                        <form action="" method="post">
                            <input type="hidden" name="auth[driver]" value="server">
                            <input type="hidden" name="auth[server]" value="localhost">
                            <input type="hidden" name="auth[username]" value="root">
                            <input type="hidden" name="auth[password]" value="">
                            <input type="hidden" name="auth[db]" value="">
                            <input type="submit" value="Connect to MariaDB (root)" style="padding: 10px 20px; background: #007cba; color: white; border: none; border-radius: 4px; cursor: pointer;">
                        </form>
                    </div>
                    
                    <div style="flex: 1;">
                        <h3>SQLite Databases</h3>
                        <?php
                        $sqliteDir = dirname(__DIR__) . '/sqlite';
                        if (is_dir($sqliteDir)) {
                            $files = glob($sqliteDir . '/*.db');
                            if ($files) {
                                foreach ($files as $file) {
                                    $dbName = basename($file);
                                    $dbPath = str_replace('\\', '/', $file);
                                    ?>
                                    <form action="" method="post" style="margin-bottom: 10px;">
                                        <input type="hidden" name="auth[driver]" value="sqlite">
                                        <input type="hidden" name="auth[server]" value="">
                                        <input type="hidden" name="auth[username]" value="">
                                        <input type="hidden" name="auth[password]" value="">
                                        <input type="hidden" name="auth[db]" value="<?php echo htmlspecialchars($dbPath); ?>">
                                        <input type="submit" value="Open <?php echo htmlspecialchars($dbName); ?>" style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;">
                                    </form>
                                    <?php
                                }
                            } else {
                                echo '<p>No SQLite databases found in /sqlite directory</p>';
                            }
                        } else {
                            echo '<p>SQLite directory not found</p>';
                        }
                        ?>
                    </div>
                </div>
            </div>
            
            <details>
                <summary style="cursor: pointer; padding: 10px; background: #e0e0e0; border-radius: 4px;">Advanced Login</summary>
                <div style="margin-top: 10px;">
                    <?php
                    // Show the original login form for advanced users
                    parent::loginForm();
                    ?>
                </div>
            </details>
            <?php
        }
        
        function head($dark = null) {
            parent::head($dark);
            ?>
            <style>
                /* Custom styles for IsotoneStack */
                #menu { background: #f8f9fa; }
                #menu a, #menu a:visited { 
                    color: #333333 !important; 
                    font-weight: 500;
                }
                #menu a:hover { 
                    background: #e9ecef; 
                    color: #000000 !important;
                }
                #menu .active {
                    font-weight: bold;
                    background: #dee2e6;
                }
                .rtl #menu { background: #f8f9fa; }
                .rtl #menu a { color: #333333 !important; }
                h1 { color: #2c3e50; }
                h2 { color: #34495e; }
                .message { background: #27ae60; }
                .error { background: #e74c3c; }
                input[type="submit"], button { 
                    transition: opacity 0.2s; 
                }
                input[type="submit"]:hover, button:hover { 
                    opacity: 0.8; 
                }
                /* Ensure all sidebar text is visible */
                #menu .links a { color: #333333 !important; }
                #menu h1 a { color: #333333 !important; }
            </style>
            <?php
        }
        
        function navigation($missing) {
            ?>
            <div style="background: #3498db; color: white; padding: 10px; margin-bottom: 20px; border-radius: 4px;">
                <strong>IsotoneStack Database Manager</strong> - 
                Quick access to MariaDB and SQLite databases
            </div>
            <?php
            parent::navigation($missing);
        }
    }
    
    return new IsotoneAdminer;
}

// Include the original Adminer
include './adminer.php';