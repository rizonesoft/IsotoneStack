<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack Demo</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
            max-width: 800px;
            margin: 2rem;
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        .status {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        .component {
            background: rgba(255, 255, 255, 0.2);
            padding: 1.5rem;
            border-radius: 10px;
            transition: transform 0.3s;
        }
        .component:hover {
            transform: translateY(-5px);
        }
        .component h3 {
            font-size: 1.2rem;
            margin-bottom: 0.5rem;
        }
        .version {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        .links {
            margin-top: 2rem;
        }
        .links a {
            display: inline-block;
            margin: 0.5rem;
            padding: 0.75rem 1.5rem;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: all 0.3s;
        }
        .links a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
        }
        .info {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }
        .back-link {
            position: absolute;
            top: 2rem;
            left: 2rem;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .back-link:hover {
            background: rgba(255, 255, 255, 0.3);
        }
    </style>
</head>
<body>
    <a href="/" class="back-link">← Back to Home</a>
    <div class="container">
        <h1>🔧 IsotoneStack Demo</h1>
        <p style="font-size: 1.2rem; margin-bottom: 2rem;">System Information & Component Versions</p>
        
        <div class="status">
            <div class="component">
                <h3>🐘 PHP</h3>
                <p class="version"><?php echo phpversion(); ?></p>
            </div>
            
            <div class="component">
                <h3>🌐 Web Server</h3>
                <p class="version"><?php echo $_SERVER['SERVER_SOFTWARE']; ?></p>
            </div>
            
            <div class="component">
                <h3>🗄️ Database</h3>
                <p class="version">
                <?php
                    try {
                        $pdo = new PDO('mysql:host=localhost;port=3306', 'root', '');
                        echo $pdo->getAttribute(PDO::ATTR_SERVER_VERSION);
                    } catch (PDOException $e) {
                        echo 'Not connected';
                    }
                ?>
                </p>
            </div>
            
            <div class="component">
                <h3>💻 OS</h3>
                <p class="version"><?php echo php_uname('s') . ' ' . php_uname('r'); ?></p>
            </div>
        </div>
        
        <div class="info">
            <h3>Loaded PHP Extensions</h3>
            <p style="margin-top: 1rem; word-wrap: break-word;">
                <?php echo implode(', ', get_loaded_extensions()); ?>
            </p>
        </div>
        
        <div class="info">
            <h3>PHP Settings</h3>
            <p style="margin-top: 1rem;">
                Memory Limit: <?php echo ini_get('memory_limit'); ?> |
                Max Execution Time: <?php echo ini_get('max_execution_time'); ?>s |
                Upload Max Size: <?php echo ini_get('upload_max_filesize'); ?>
            </p>
        </div>
        
        <div class="links">
            <a href="/phpmyadmin">phpMyAdmin</a>
            <a href="/phpinfo.php">Full PHP Info</a>
        </div>
        
        <p style="margin-top: 2rem; opacity: 0.7;">
            <?php echo date('Y-m-d H:i:s'); ?> | 
            Server Time: <?php echo date_default_timezone_get(); ?>
        </p>
    </div>
</body>
</html>