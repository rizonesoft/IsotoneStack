# IsotoneStack Hash Generation and Verification Tool
# PowerShell version with advanced features

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('Create', 'Verify', 'Check', 'Update', 'Export')]
    [string]$Action = 'Create',
    
    [Parameter(Position=1)]
    [string]$FilePath,
    
    [ValidateSet('SHA256', 'SHA1', 'MD5', 'SHA384', 'SHA512')]
    [string]$Algorithm = 'SHA256',
    
    # Set path relative to parent directory (script is in tools folder)
    [string]$HashFile = (Join-Path (Split-Path $PSScriptRoot -Parent) "downloads\hashes.json"),
    
    [switch]$Force
)

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = 'White')
    Write-Host $Message -ForegroundColor $Color
}

# Known hashes for IsotoneStack components (from CDN)
$KnownHashes = @{
    'apache24.zip' = @{
        SHA256 = ''  # To be filled after first download
        Size = 12222464
        Component = 'Apache 2.4.65'
    }
    'php.zip' = @{
        SHA256 = ''  # To be filled after first download
        Size = 33985536
        Component = 'PHP 8.4.11'
    }
    'mariadb.zip' = @{
        SHA256 = ''  # To be filled after first download
        Size = 0  # Variable size for MariaDB 11.4.4
        Component = 'MariaDB 11.4.4'
    }
    'phpmyadmin.zip' = @{
        SHA256 = ''  # To be filled after first download
        Size = 0  # Variable size for phpMyAdmin 5.2.2 English
        Component = 'phpMyAdmin 5.2.2'
    }
}

function Get-FileHashInfo {
    param(
        [string]$Path,
        [string]$Algorithm = 'SHA256'
    )
    
    if (-not (Test-Path $Path)) {
        Write-ColorOutput "[ERROR] File not found: $Path" -Color Red
        return $null
    }
    
    $file = Get-Item $Path
    $hash = Get-FileHash -Path $Path -Algorithm $Algorithm
    
    return @{
        FileName = $file.Name
        FilePath = $file.FullName
        FileSize = $file.Length
        FileSizeMB = [Math]::Round($file.Length / 1MB, 2)
        Algorithm = $Algorithm
        Hash = $hash.Hash
        LastModified = $file.LastWriteTime
        Created = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    }
}

function Create-Hashes {
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    Write-ColorOutput "   Creating Hashes for IsotoneStack Files" -Color Cyan
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    
    # Get parent directory (script is in tools folder)
    $parentPath = Split-Path $PSScriptRoot -Parent
    $downloadsPath = Join-Path $parentPath "downloads"
    
    if (-not (Test-Path $downloadsPath)) {
        Write-ColorOutput "[ERROR] Downloads folder not found" -Color Red
        return
    }
    
    $hashData = @{
        Generated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Algorithm = $Algorithm
        Files = @{}
    }
    
    $files = Get-ChildItem -Path $downloadsPath -Include "*.zip", "*.exe", "*.7z" -Recurse
    
    foreach ($file in $files) {
        Write-ColorOutput "Processing: $($file.Name)" -Color Yellow
        
        $hashInfo = Get-FileHashInfo -Path $file.FullName -Algorithm $Algorithm
        if ($hashInfo) {
            $hashData.Files[$file.Name] = $hashInfo
            
            Write-ColorOutput "  Algorithm: $Algorithm" -Color Gray
            Write-ColorOutput "  Hash: $($hashInfo.Hash)" -Color Green
            Write-ColorOutput "  Size: $($hashInfo.FileSizeMB) MB" -Color Gray
            Write-ColorOutput ""
        }
    }
    
    # Save to JSON file
    $hashData | ConvertTo-Json -Depth 3 | Set-Content -Path $HashFile
    Write-ColorOutput "Hashes saved to: $HashFile" -Color Green
    
    # Also create a simple text file
    $textFile = Join-Path $downloadsPath "hashes.txt"
    $textContent = @()
    $textContent += "IsotoneStack Component Hashes"
    $textContent += "Generated: $($hashData.Generated)"
    $textContent += "Algorithm: $Algorithm"
    $textContent += "=" * 60
    $textContent += ""
    
    foreach ($fileName in $hashData.Files.Keys) {
        $fileInfo = $hashData.Files[$fileName]
        $textContent += "${fileName}:"
        $textContent += "  $Algorithm`: $($fileInfo.Hash)"
        $textContent += "  Size: $($fileInfo.FileSizeMB) MB"
        $textContent += ""
    }
    
    $textContent | Out-File -FilePath $textFile -Encoding UTF8
    Write-ColorOutput "Text hashes saved to: $textFile" -Color Green
}

function Verify-Hashes {
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    Write-ColorOutput "   Verifying IsotoneStack Downloads" -Color Cyan
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    
    # Get parent directory (script is in tools folder)
    $parentPath = Split-Path $PSScriptRoot -Parent
    $downloadsPath = Join-Path $parentPath "downloads"
    
    if (-not (Test-Path $HashFile)) {
        Write-ColorOutput "[WARNING] Hash file not found. Run with -Action Create first." -Color Yellow
        return
    }
    
    $hashData = Get-Content $HashFile | ConvertFrom-Json
    $verified = 0
    $failed = 0
    $missing = 0
    
    foreach ($fileName in $hashData.Files.PSObject.Properties.Name) {
        $filePath = Join-Path $downloadsPath $fileName
        $storedInfo = $hashData.Files.$fileName
        
        Write-ColorOutput "Verifying: $fileName" -Color Yellow
        
        if (-not (Test-Path $filePath)) {
            Write-ColorOutput "  [MISSING] File not found" -Color Red
            $missing++
            continue
        }
        
        $currentHash = (Get-FileHash -Path $filePath -Algorithm $hashData.Algorithm).Hash
        
        if ($currentHash -eq $storedInfo.Hash) {
            Write-ColorOutput "  [OK] Hash matches" -Color Green
            $verified++
        } else {
            Write-ColorOutput "  [FAIL] Hash mismatch!" -Color Red
            Write-ColorOutput "    Expected: $($storedInfo.Hash)" -Color Gray
            Write-ColorOutput "    Actual:   $currentHash" -Color Gray
            $failed++
        }
    }
    
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    Write-ColorOutput "Verification Results:" -Color White
    Write-ColorOutput "  Verified: $verified" -Color Green
    Write-ColorOutput "  Failed:   $failed" -Color Red
    Write-ColorOutput "  Missing:  $missing" -Color Yellow
    Write-ColorOutput "`n===========================================`n" -Color Cyan
}

function Check-SingleFile {
    param([string]$Path)
    
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Read-Host "Enter file path"
    }
    
    if (-not (Test-Path $Path)) {
        Write-ColorOutput "[ERROR] File not found: $Path" -Color Red
        return
    }
    
    Write-ColorOutput "`nFile: $Path" -Color Cyan
    Write-ColorOutput ("=" * 60) -Color Gray
    
    $file = Get-Item $Path
    Write-ColorOutput "Size: $([Math]::Round($file.Length / 1MB, 2)) MB ($($file.Length) bytes)" -Color White
    Write-ColorOutput "Modified: $($file.LastWriteTime)" -Color White
    Write-ColorOutput "" -Color White
    
    # Calculate multiple hashes
    $algorithms = @('SHA256', 'SHA1', 'MD5')
    
    foreach ($algo in $algorithms) {
        Write-ColorOutput "${algo}:" -Color Yellow
        $hash = (Get-FileHash -Path $Path -Algorithm $algo).Hash
        Write-ColorOutput "  $hash" -Color Green
    }
}

function Update-CDNHashes {
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    Write-ColorOutput "   Updating CDN Hash Database" -Color Cyan
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    
    # Get parent directory (script is in tools folder)
    $parentPath = Split-Path $PSScriptRoot -Parent
    $downloadsPath = Join-Path $parentPath "downloads"
    $cdnHashFile = Join-Path $parentPath "cdn-hashes.json"
    
    $cdnHashes = @{
        Generated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        CDN = "https://isotone.b-cdn.net/IsotoneStack/"
        Components = @{}
    }
    
    $files = @(
        'apache24.zip',
        'php.zip',
        'mariadb.zip',
        'phpmyadmin.zip'
    )
    
    foreach ($fileName in $files) {
        $filePath = Join-Path $downloadsPath $fileName
        
        if (Test-Path $filePath) {
            Write-ColorOutput "Processing: $fileName" -Color Yellow
            
            $hashInfo = Get-FileHashInfo -Path $filePath -Algorithm 'SHA256'
            $md5Info = Get-FileHashInfo -Path $filePath -Algorithm 'MD5'
            
            $cdnHashes.Components[$fileName] = @{
                Component = $KnownHashes[$fileName].Component
                SHA256 = $hashInfo.Hash
                MD5 = $md5Info.Hash
                Size = $hashInfo.FileSize
                SizeMB = $hashInfo.FileSizeMB
            }
            
            Write-ColorOutput "  SHA256: $($hashInfo.Hash)" -Color Green
            Write-ColorOutput "  MD5: $($md5Info.Hash)" -Color Green
            Write-ColorOutput "  Size: $($hashInfo.FileSizeMB) MB" -Color Gray
            Write-ColorOutput ""
        } else {
            Write-ColorOutput "  [SKIP] $fileName not found" -Color Yellow
        }
    }
    
    $cdnHashes | ConvertTo-Json -Depth 3 | Set-Content -Path $cdnHashFile
    Write-ColorOutput "CDN hashes saved to: $cdnHashFile" -Color Green
}

function Export-HashReport {
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    Write-ColorOutput "   Exporting Hash Report" -Color Cyan
    Write-ColorOutput "`n===========================================`n" -Color Cyan
    
    # Get parent directory (script is in tools folder)
    $parentPath = Split-Path $PSScriptRoot -Parent
    $reportPath = Join-Path $parentPath "HASH_REPORT.md"
    # Get parent directory (script is in tools folder)
    $parentPath = Split-Path $PSScriptRoot -Parent
    $downloadsPath = Join-Path $parentPath "downloads"
    
    $report = @()
    $report += "# IsotoneStack Component Hash Report"
    $report += ""
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += ""
    $report += "## Download Verification"
    $report += ""
    $report += "| Component | File | SHA256 | MD5 | Size |"
    $report += "|-----------|------|--------|-----|------|"
    
    $files = @{
        'apache24.zip' = 'Apache 2.4.65'
        'php.zip' = 'PHP 8.4.11'
        'mariadb.zip' = 'MariaDB 11.4.4'
        'phpmyadmin.zip' = 'phpMyAdmin 5.2.2'
    }
    
    foreach ($fileName in $files.Keys) {
        $filePath = Join-Path $downloadsPath $fileName
        
        if (Test-Path $filePath) {
            $sha256 = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
            $md5 = (Get-FileHash -Path $filePath -Algorithm MD5).Hash
            $size = [Math]::Round((Get-Item $filePath).Length / 1MB, 2)
            
            $report += "| $($files[$fileName]) | $fileName | ``$sha256`` | ``$md5`` | $size MB |"
        }
    }
    
    $report += ""
    $report += "## Verification Commands"
    $report += ""
    $report += "### Using CertUtil (Command Prompt):"
    $report += '```batch'
    $report += 'certutil -hashfile "C:\isotone\downloads\filename.zip" SHA256'
    $report += '```'
    $report += ""
    $report += "### Using PowerShell:"
    $report += '```powershell'
    $report += 'Get-FileHash -Path "C:\isotone\downloads\filename.zip" -Algorithm SHA256'
    $report += '```'
    $report += ""
    $report += "### Using this tool:"
    $report += '```batch'
    $report += 'Verify-Hashes.bat verify'
    $report += '```'
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    Write-ColorOutput "Report exported to: $reportPath" -Color Green
    
    # Display the report
    Write-ColorOutput "`nReport Contents:" -Color Yellow
    Get-Content $reportPath | ForEach-Object { Write-ColorOutput $_ -Color Gray }
}

# Main execution
switch ($Action) {
    'Create' {
        Create-Hashes
    }
    'Verify' {
        Verify-Hashes
    }
    'Check' {
        Check-SingleFile -Path $FilePath
    }
    'Update' {
        Update-CDNHashes
    }
    'Export' {
        Export-HashReport
    }
}