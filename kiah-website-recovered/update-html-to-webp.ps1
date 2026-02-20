param(
    [string]$WebsitePath = "",
    [switch]$DryRun = $false,
    [switch]$BackupFirst = $true
)

if (-not $WebsitePath) {
    $WebsitePath = $PSScriptRoot
}

Write-Host ""
Write-Host "=== HTML Image Reference Updater ===" -ForegroundColor Cyan
Write-Host "Website Path: $WebsitePath"
Write-Host "Dry Run: $DryRun"
Write-Host "Backup First: $BackupFirst"
Write-Host ""

$imageExtensions = @('jpg', 'jpeg', 'png', 'gif', 'bmp', 'tif', 'jfif', 'JPG', 'JPEG', 'PNG', 'GIF', 'BMP', 'TIF', 'JFIF')

if ($BackupFirst -and -not $DryRun) {
    $backupPath = "$WebsitePath\HTML_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Creating backup of HTML and CSS files..." -ForegroundColor Yellow
    New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
    
    $searchPath = Join-Path $WebsitePath "*"
    Get-ChildItem -Path $searchPath -Recurse -File -Include *.html,*.css | ForEach-Object {
        $relativePath = $_.FullName.Substring($WebsitePath.Length + 1)
        $backupFile = Join-Path $backupPath $relativePath
        $backupDir = Split-Path $backupFile -Parent
        
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        }
        
        Copy-Item $_.FullName -Destination $backupFile -Force
    }
    Write-Host "Backup created at: $backupPath" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Scanning for HTML and CSS files..." -ForegroundColor Cyan
$searchPath = Join-Path $WebsitePath "*"
$files = Get-ChildItem -Path $searchPath -Recurse -File -Include *.html,*.css | Where-Object {
    $_.FullName -notmatch "[\\/]HTML_Backup_|[\\/]Images_Backup_"
}

$totalFiles = $files.Count
Write-Host "Found $totalFiles files to process" -ForegroundColor Green
Write-Host ""

$updatedFiles = 0
$skippedFiles = 0
$totalChanges = 0

$logFile = "$WebsitePath\html-update-log.txt"
"HTML Update Log - $(Get-Date)" | Out-File $logFile
"================================" | Out-File $logFile -Append
"" | Out-File $logFile -Append

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileChanges = 0
    
    foreach ($ext in $imageExtensions) {
        $patterns = @(
            @{
                Name = "img src"
                Regex = "(<img[^>]+src\s*=\s*[`"'])([^`"']+\.$ext)([`"'])"
                Replacement = "`$1`$2.webp`$3"
            },
            @{
                Name = "background-image url"
                Regex = "(background-image:\s*url\s*\(\s*[`"']?)([^`"'\)]+\.$ext)([`"']?\s*\))"
                Replacement = "`$1`$2.webp`$3"
            },
            @{
                Name = "background url"
                Regex = "(background:\s*[^;]*url\s*\(\s*[`"']?)([^`"'\)]+\.$ext)([`"']?\s*\))"
                Replacement = "`$1`$2.webp`$3"
            },
            @{
                Name = "a href to image"
                Regex = "(<a[^>]+href\s*=\s*[`"'])([^`"']+\.$ext)([`"'])"
                Replacement = "`$1`$2.webp`$3"
            }
        )
        
        foreach ($pattern in $patterns) {
            $matches = [regex]::Matches($content, $pattern.Regex, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            
            if ($matches.Count -gt 0) {
                $newContent = [regex]::Replace($content, $pattern.Regex, $pattern.Replacement, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                
                if ($newContent -ne $content) {
                    $content = $newContent
                    $changeCount = $matches.Count
                    $fileChanges += $changeCount
                    
                    if ($DryRun) {
                        Write-Host "  WOULD UPDATE: $($pattern.Name) - $changeCount change(s) for .$ext" -ForegroundColor Gray
                    }
                    
                    "  $($pattern.Name): Changed $changeCount reference(s) from .$ext to .webp" | Out-File $logFile -Append
                }
            }
        }
    }
    
    if ($fileChanges -gt 0) {
        if ($DryRun) {
            Write-Host "WOULD UPDATE: $($file.Name) - $fileChanges change(s)" -ForegroundColor Yellow
        } else {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            Write-Host "UPDATED: $($file.Name) - $fileChanges change(s)" -ForegroundColor Green
        }
        
        "FILE: $($file.FullName) - $fileChanges changes" | Out-File $logFile -Append
        $updatedFiles++
        $totalChanges += $fileChanges
    } else {
        Write-Host "SKIP: $($file.Name) - No changes needed" -ForegroundColor DarkGray
        $skippedFiles++
    }
}

Write-Host ""
Write-Host "=== Update Complete ===" -ForegroundColor Cyan
Write-Host "Total files processed: $totalFiles"
Write-Host "Files updated: $updatedFiles" -ForegroundColor Green
Write-Host "Files skipped: $skippedFiles" -ForegroundColor Yellow
Write-Host "Total changes made: $totalChanges" -ForegroundColor Green

"" | Out-File $logFile -Append
"================================" | Out-File $logFile -Append
"Summary: $updatedFiles files updated with $totalChanges total changes" | Out-File $logFile -Append

Write-Host ""
Write-Host "Log file: $logFile" -ForegroundColor Yellow
Write-Host ""

if ($DryRun) {
    Write-Host "This was a DRY RUN - no files were modified." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to apply the changes." -ForegroundColor Yellow
    Write-Host ""
}
