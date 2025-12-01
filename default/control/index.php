<?php
$isotoneRoot = dirname(__DIR__, 2);
$isoControlDir = $isotoneRoot . DIRECTORY_SEPARATOR . 'iso-control';
$executableCandidates = [
    $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'Release' . DIRECTORY_SEPARATOR . 'net10.0-windows' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe',
    $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'Debug' . DIRECTORY_SEPARATOR . 'net10.0-windows' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe',
    $isoControlDir . DIRECTORY_SEPARATOR . 'Isotone.exe'
];

$isoControlExecutable = null;
foreach ($executableCandidates as $candidate) {
    if (file_exists($candidate)) {
        $isoControlExecutable = $candidate;
        break;
    }
}

if (!$isoControlExecutable) {
    $globPattern = $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . '*' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe';
    $matches = glob($globPattern, GLOB_NOSORT);
    if (!empty($matches)) {
        $isoControlExecutable = $matches[0];
    }
}

$isoControlExecutable = $isoControlExecutable ? realpath($isoControlExecutable) : null;
$displayPath = $isoControlExecutable ? str_replace('/', DIRECTORY_SEPARATOR, $isoControlExecutable) : $isoControlDir;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iso-control</title>
    <style>
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            background: radial-gradient(circle at top, #1F8F90, #0b1f2d 65%);
            color: #f4f7fb;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px;
        }
        .panel {
            width: 100%;
            max-width: 720px;
            background: rgba(5, 19, 31, 0.92);
            border-radius: 18px;
            padding: 48px;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.45);
        }
        .pill {
            display: inline-flex;
            align-items: center;
            padding: 6px 14px;
            border-radius: 999px;
            background: rgba(31, 143, 144, 0.16);
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            margin-bottom: 20px;
        }
        h1 {
            margin: 0 0 12px 0;
            font-size: clamp(32px, 4vw, 44px);
            line-height: 1.2;
        }
        p {
            margin: 0;
            color: #9fb3c8;
            line-height: 1.6;
        }
        .steps {
            margin-top: 32px;
            padding-left: 20px;
            color: #cdd8e5;
        }
        .steps li {
            margin-bottom: 12px;
        }
        .path-hint {
            margin-top: 24px;
            padding: 16px;
            background: rgba(10, 30, 48, 0.9);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            font-family: Consolas, "Liberation Mono", monospace;
            font-size: 13px;
            color: #8fe0ff;
            overflow-x: auto;
        }
        .actions {
            margin-top: 32px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }
        .actions a {
            text-decoration: none;
            padding: 12px 18px;
            border-radius: 10px;
            font-weight: 600;
            transition: opacity 0.2s ease;
        }
        .actions a.primary {
            background: #1F8F90;
            color: white;
        }
        .actions a.secondary {
            border: 1px solid rgba(255, 255, 255, 0.25);
            color: #f4f7fb;
        }
        .actions a:hover {
            opacity: 0.85;
        }
        @media (max-width: 640px) {
            body {
                padding: 20px;
            }
            .panel {
                padding: 32px;
            }
        }
    </style>
</head>
<body>
    <div class="panel">
        <div class="pill">Control Center</div>
        <h1>Iso-control is the only control panel</h1>
        <p>
            Manage services, databases, certificates, and the full IsotoneStack runtime from the Iso-control
            desktop application. Launch the app locally to start, stop, or inspect every component in one place.
        </p>

        <ol class="steps">
            <li>Open the Iso-control desktop app from your IsotoneStack installation.</li>
            <li>Use the dashboard to start or stop Apache, MariaDB, and Mailpit.</li>
            <li>Access phpMyAdmin, Mailpit, and other tools from the shortcuts inside Iso-control.</li>
        </ol>

        <div class="path-hint">
            <?php if ($isoControlExecutable): ?>
                <?php echo htmlspecialchars($displayPath, ENT_QUOTES, 'UTF-8'); ?>
            <?php else: ?>
                Iso-control folder: <?php echo htmlspecialchars($displayPath, ENT_QUOTES, 'UTF-8'); ?>
            <?php endif; ?>
        </div>

        <div class="actions">
            <a class="primary" href="/default/" title="Go back to the welcome page">Back to Localhost</a>
            <a class="secondary" href="https://github.com/rizonesoft/IsotoneStack" target="_blank" rel="noopener">View Project on GitHub</a>
        </div>
    </div>
</body>
</html>