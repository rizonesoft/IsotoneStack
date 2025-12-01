<?php
$isotoneRoot = realpath(__DIR__ . '/..');
$isoControlDir = $isotoneRoot . DIRECTORY_SEPARATOR . 'iso-control';
$executableCandidates = [
    $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'Release' . DIRECTORY_SEPARATOR . 'net10.0-windows' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe',
    $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . 'Debug' . DIRECTORY_SEPARATOR . 'net10.0-windows' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe',
    $isoControlDir . DIRECTORY_SEPARATOR . 'Isotone.exe'
];

$isoControlExecutable = null;
foreach ($executableCandidates as $candidate) {
    if (file_exists($candidate)) {
        $isoControlExecutable = realpath($candidate);
        break;
    }
}

if (!$isoControlExecutable) {
    $globPattern = $isoControlDir . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . '*' . DIRECTORY_SEPARATOR . 'win-x64' . DIRECTORY_SEPARATOR . 'Isotone.exe';
    $matches = glob($globPattern, GLOB_NOSORT);
    if (!empty($matches)) {
        $isoControlExecutable = realpath($matches[0]);
    }
}

$displayPath = $isoControlExecutable ?: $isoControlDir;
$relativePath = str_replace(['\\', '/'], DIRECTORY_SEPARATOR, $displayPath);

$systemInfo = [
    'os' => php_uname('s') . ' ' . php_uname('r'),
    'hostname' => gethostname(),
    'ip' => $_SERVER['SERVER_ADDR'] ?? 'localhost'
];
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IsotoneStack · Welcome</title>
    <style>
        :root {
            color-scheme: dark;
        }
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: "Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            background: radial-gradient(circle at 10% -10%, rgba(50, 150, 255, 0.25), rgba(9, 17, 31, 1)), #050910;
            color: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 48px 16px;
        }
        .shell {
            width: min(960px, 100%);
            background: rgba(8, 14, 24, 0.8);
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 25px 80px rgba(3, 7, 18, 0.65);
            padding: clamp(32px, 6vw, 56px);
            backdrop-filter: blur(40px);
        }
        .badge {
            display: inline-flex;
            align-items: center;
            padding: 8px 18px;
            border-radius: 999px;
            background: rgba(79, 209, 197, 0.12);
            color: #7af1df;
            font-size: 13px;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            margin-bottom: 18px;
        }
        h1 {
            font-size: clamp(32px, 6vw, 54px);
            margin: 0 0 12px 0;
            line-height: 1.1;
        }
        p.lead {
            font-size: clamp(16px, 2vw, 20px);
            color: #cbd5e1;
            margin: 0;
            line-height: 1.6;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 18px;
            margin: 32px 0;
        }
        .card {
            padding: 20px;
            border-radius: 16px;
            background: rgba(15, 23, 42, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.05);
            min-height: 140px;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .card h3 {
            margin: 0;
            font-size: 16px;
            color: #f8fafc;
            letter-spacing: 0.02em;
        }
        .card p {
            margin: 0;
            color: #94a3b8;
            font-size: 14px;
            line-height: 1.5;
        }
        .card a {
            margin-top: auto;
            color: #38e2b8;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
        }
        .path-box {
            margin-top: 32px;
            padding: 18px;
            border-radius: 12px;
            font-family: "Consolas", "JetBrains Mono", monospace;
            font-size: 14px;
            color: #8df5ff;
            background: rgba(2, 6, 23, 0.85);
            border: 1px solid rgba(56, 189, 248, 0.25);
            overflow-wrap: anywhere;
        }
        .actions {
            margin-top: 36px;
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
        }
        .button {
            padding: 14px 20px;
            border-radius: 12px;
            border: none;
            font-weight: 600;
            font-size: 15px;
            cursor: pointer;
            text-decoration: none;
            transition: filter 0.2s ease;
        }
        .button.primary {
            background: linear-gradient(120deg, #0ea5e9, #1dd1a1);
            color: #04121d;
        }
        .button.secondary {
            background: rgba(148, 163, 184, 0.15);
            color: #e2e8f0;
            border: 1px solid rgba(148, 163, 184, 0.35);
        }
        .button:hover {
            filter: brightness(1.05);
        }
        .system-info {
            margin-top: 24px;
            font-size: 14px;
            color: #94a3b8;
        }
        @media (max-width: 640px) {
            body {
                padding: 24px 12px;
            }
            .shell {
                padding: 28px;
            }
            .actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <main class="shell" role="main">
        <div class="badge">Localhost</div>
        <h1>Welcome to IsotoneStack</h1>
        <p class="lead">
            Iso-control is the single source of truth for managing your services. Launch the desktop app to start and stop
            Apache, MariaDB, Mailpit, and to reach every bundled developer tool.
        </p>

        <section class="grid" aria-label="Quick actions">
            <article class="card">
                <h3>Iso-control Desktop</h3>
                <p>Use the desktop dashboard to control all services, view logs, and open bundled tooling from one place.</p>
                <span>Launch locally from the path below.</span>
            </article>
            <article class="card">
                <h3>Databases</h3>
                <p>phpMyAdmin is still available for direct database access.</p>
                <a href="/phpmyadmin/">Open phpMyAdmin →</a>
            </article>
            <article class="card">
                <h3>Diagnostics</h3>
                <p>Need PHP runtime details?</p>
                <a href="/default/phpinfo.php">View phpinfo()</a>
            </article>
            <article class="card">
                <h3>Mailpit</h3>
                <p>Inspect captured emails in the bundled Mailpit instance.</p>
                <a href="http://localhost:8025" rel="noopener">Go to Mailpit</a>
            </article>
        </section>

        <div class="path-box" aria-label="Iso-control executable path">
            <?php echo htmlspecialchars($relativePath, ENT_QUOTES, 'UTF-8'); ?>
        </div>

        <div class="actions">
            <a class="button primary" href="/default/control/">Learn about Iso-control</a>
            <a class="button secondary" href="https://github.com/rizonesoft/IsotoneStack" target="_blank" rel="noopener">Project on GitHub</a>
        </div>

        <p class="system-info">
            <?php echo htmlspecialchars($systemInfo['hostname']); ?> · <?php echo htmlspecialchars($systemInfo['os']); ?> · <?php echo htmlspecialchars($systemInfo['ip']); ?>
        </p>
    </main>
</body>
</html>