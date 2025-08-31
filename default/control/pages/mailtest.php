<?php
/**
 * Mail Testing Page - Test PHP mail() function with Mailpit
 */

$message = '';
$messageType = '';

// Handle mail test submission
if (isset($_POST['send_test'])) {
    $to = $_POST['to'] ?? 'test@example.com';
    $subject = $_POST['subject'] ?? 'Test Email from IsotoneStack';
    $body = $_POST['body'] ?? 'This is a test email sent from IsotoneStack Control Panel.';
    $from = $_POST['from'] ?? 'isotone@localhost';
    $cc = $_POST['cc'] ?? '';
    $bcc = $_POST['bcc'] ?? '';
    
    // Build headers
    $headers = "From: $from\r\n";
    $headers .= "Reply-To: $from\r\n";
    $headers .= "X-Mailer: IsotoneStack/1.0\r\n";
    
    if (!empty($cc)) {
        $headers .= "Cc: $cc\r\n";
    }
    if (!empty($bcc)) {
        $headers .= "Bcc: $bcc\r\n";
    }
    
    // Check if HTML format is selected
    if (isset($_POST['html_format']) && $_POST['html_format'] == '1') {
        $headers .= "MIME-Version: 1.0\r\n";
        $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
        
        // Convert plain text to HTML if needed
        if (strpos($body, '<') === false) {
            $body = nl2br(htmlspecialchars($body));
            $body = "<html><body>$body</body></html>";
        }
    } else {
        $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
    }
    
    // Send the email
    if (mail($to, $subject, $body, $headers)) {
        $message = "Email sent successfully! Check Mailpit at <a href='http://localhost:8025' target='_blank' class='text-blue-600 hover:underline'>http://localhost:8025</a> to view it.";
        $messageType = 'success';
    } else {
        $message = "Failed to send email. Please check your PHP mail configuration.";
        $messageType = 'error';
    }
}

// Check Mailpit status
$mailpitRunning = false;
$socket = @fsockopen('localhost', 1025, $errno, $errstr, 1);
if ($socket) {
    fclose($socket);
    $mailpitRunning = true;
}

// Get PHP mail configuration
$mailConfig = [
    'SMTP' => ini_get('SMTP'),
    'smtp_port' => ini_get('smtp_port'),
    'sendmail_from' => ini_get('sendmail_from'),
    'mail.add_x_header' => ini_get('mail.add_x_header') ? 'On' : 'Off'
];

// Sample email templates
$templates = [
    'simple' => [
        'subject' => 'Test Email from IsotoneStack',
        'body' => "Hello,\n\nThis is a test email sent from IsotoneStack Control Panel.\n\nIf you receive this message, your email configuration is working correctly!\n\nBest regards,\nIsotoneStack"
    ],
    'html' => [
        'subject' => 'HTML Test Email from IsotoneStack',
        'body' => '<h2>Hello from IsotoneStack!</h2>
<p>This is a <strong>HTML test email</strong> sent from the IsotoneStack Control Panel.</p>
<ul>
    <li>Your mail configuration is working</li>
    <li>Mailpit is capturing emails</li>
    <li>HTML formatting is enabled</li>
</ul>
<p>Visit <a href="http://localhost">http://localhost</a> to access your local development environment.</p>
<hr>
<p><em>IsotoneStack - Professional Development Environment</em></p>'
    ],
    'notification' => [
        'subject' => 'System Notification - IsotoneStack',
        'body' => "SYSTEM NOTIFICATION\n==================\n\nService: All Systems Operational\nStatus: OK\nTime: " . date('Y-m-d H:i:s') . "\n\nAll IsotoneStack services are running normally.\n\nThis is an automated test message."
    ]
];
?>

<h1 class="text-3xl font-bold text-gray-900 mb-8">Mail Testing</h1>

<!-- Status Alert -->
<?php if ($message): ?>
<div class="mb-6 <?php echo $messageType === 'success' ? 'bg-green-100 border-green-400 text-green-700' : 'bg-red-100 border-red-400 text-red-700'; ?> px-4 py-3 rounded border">
    <?php echo $message; ?>
</div>
<?php endif; ?>

<!-- Mailpit Status -->
<div class="mb-6 bg-white rounded-lg shadow p-6">
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-lg font-semibold mb-2">Mailpit Status</h2>
            <div class="flex items-center">
                <?php if ($mailpitRunning): ?>
                    <span class="w-3 h-3 bg-green-500 rounded-full mr-2"></span>
                    <span class="text-green-600 font-medium">Running on port 1025</span>
                <?php else: ?>
                    <span class="w-3 h-3 bg-red-500 rounded-full mr-2"></span>
                    <span class="text-red-600 font-medium">Not Running</span>
                <?php endif; ?>
            </div>
            <p class="text-sm text-gray-600 mt-2">
                Mailpit captures all outgoing emails for testing. No emails are actually sent externally.
            </p>
        </div>
        <div>
            <a href="http://localhost:8025" target="_blank" class="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-lg inline-block">
                Open Mailpit UI
            </a>
        </div>
    </div>
</div>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <!-- Email Form -->
    <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-semibold mb-4">Send Test Email</h2>
            
            <form method="POST">
                <div class="space-y-4">
                    <!-- From -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">From</label>
                        <input type="email" name="from" value="<?php echo $_POST['from'] ?? 'isotone@localhost'; ?>" 
                               class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border">
                    </div>
                    
                    <!-- To -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">To *</label>
                        <input type="email" name="to" value="<?php echo $_POST['to'] ?? 'test@example.com'; ?>" required
                               class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border">
                    </div>
                    
                    <!-- CC/BCC -->
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">CC</label>
                            <input type="email" name="cc" value="<?php echo $_POST['cc'] ?? ''; ?>" 
                                   placeholder="Optional"
                                   class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">BCC</label>
                            <input type="email" name="bcc" value="<?php echo $_POST['bcc'] ?? ''; ?>" 
                                   placeholder="Optional"
                                   class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border">
                        </div>
                    </div>
                    
                    <!-- Subject -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Subject *</label>
                        <input type="text" name="subject" value="<?php echo $_POST['subject'] ?? 'Test Email from IsotoneStack'; ?>" required
                               class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border">
                    </div>
                    
                    <!-- Message Body -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Message *</label>
                        <textarea name="body" rows="8" required
                                  class="w-full border-gray-300 rounded-lg shadow-sm focus:border-blue-500 focus:ring-blue-500 px-3 py-2 border"><?php echo $_POST['body'] ?? "Hello,\n\nThis is a test email sent from IsotoneStack Control Panel.\n\nIf you receive this message, your email configuration is working correctly!\n\nBest regards,\nIsotoneStack"; ?></textarea>
                    </div>
                    
                    <!-- HTML Format -->
                    <div>
                        <label class="flex items-center">
                            <input type="checkbox" name="html_format" value="1" <?php echo (isset($_POST['html_format']) && $_POST['html_format'] == '1') ? 'checked' : ''; ?>
                                   class="rounded border-gray-300 text-blue-600 shadow-sm focus:border-blue-500 focus:ring-blue-500 mr-2">
                            <span class="text-sm text-gray-700">Send as HTML email</span>
                        </label>
                    </div>
                    
                    <!-- Submit Button -->
                    <div class="flex items-center justify-between">
                        <button type="submit" name="send_test" 
                                class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg font-medium transition-colors">
                            Send Test Email
                        </button>
                        
                        <!-- Template Buttons -->
                        <div class="space-x-2">
                            <button type="button" onclick="loadTemplate('simple')" 
                                    class="text-sm text-blue-600 hover:text-blue-800">Load Simple</button>
                            <button type="button" onclick="loadTemplate('html')" 
                                    class="text-sm text-blue-600 hover:text-blue-800">Load HTML</button>
                            <button type="button" onclick="loadTemplate('notification')" 
                                    class="text-sm text-blue-600 hover:text-blue-800">Load Notification</button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Configuration Info -->
    <div>
        <div class="bg-white rounded-lg shadow p-6 mb-6">
            <h2 class="text-lg font-semibold mb-4">PHP Mail Configuration</h2>
            <dl class="space-y-2">
                <div>
                    <dt class="text-sm font-medium text-gray-600">SMTP Server</dt>
                    <dd class="text-sm text-gray-900"><?php echo $mailConfig['SMTP']; ?></dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-600">SMTP Port</dt>
                    <dd class="text-sm text-gray-900"><?php echo $mailConfig['smtp_port']; ?></dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-600">Default From</dt>
                    <dd class="text-sm text-gray-900"><?php echo $mailConfig['sendmail_from'] ?: 'Not set'; ?></dd>
                </div>
                <div>
                    <dt class="text-sm font-medium text-gray-600">X-Header</dt>
                    <dd class="text-sm text-gray-900"><?php echo $mailConfig['mail.add_x_header']; ?></dd>
                </div>
            </dl>
        </div>
        
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h3 class="text-sm font-semibold text-blue-900 mb-2">How it works</h3>
            <ul class="text-sm text-blue-800 space-y-1">
                <li>• PHP mail() sends to localhost:1025</li>
                <li>• Mailpit captures all emails</li>
                <li>• No emails leave your system</li>
                <li>• View emails at port 8025</li>
                <li>• Perfect for development testing</li>
            </ul>
        </div>
    </div>
</div>

<!-- Recent Tests (if we implement logging) -->
<div class="mt-8 bg-white rounded-lg shadow p-6">
    <h2 class="text-lg font-semibold mb-4">Testing Tips</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
            <h3 class="font-medium text-gray-900 mb-2">Common Test Scenarios</h3>
            <ul class="text-sm text-gray-600 space-y-1">
                <li>• Test contact form submissions</li>
                <li>• Verify password reset emails</li>
                <li>• Check newsletter formatting</li>
                <li>• Validate notification systems</li>
                <li>• Debug email headers and content</li>
            </ul>
        </div>
        <div>
            <h3 class="font-medium text-gray-900 mb-2">PHP Code Example</h3>
            <pre class="bg-gray-100 p-3 rounded text-xs overflow-x-auto">
<code>&lt;?php
// Simple mail example
mail('user@example.com', 
     'Subject', 
     'Message body',
     'From: sender@example.com');

// With headers
$headers = "From: sender@example.com\r\n";
$headers .= "Reply-To: reply@example.com\r\n";
$headers .= "X-Mailer: PHP/" . phpversion();

mail($to, $subject, $message, $headers);
?&gt;</code>
            </pre>
        </div>
    </div>
</div>

<script>
// Email templates
const templates = <?php echo json_encode($templates); ?>;

function loadTemplate(type) {
    if (templates[type]) {
        document.querySelector('input[name="subject"]').value = templates[type].subject;
        document.querySelector('textarea[name="body"]').value = templates[type].body;
        
        // Check HTML format for HTML template
        document.querySelector('input[name="html_format"]').checked = (type === 'html');
    }
}
</script>