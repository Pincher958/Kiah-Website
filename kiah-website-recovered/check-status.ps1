Write-Host ""
Write-Host "=== WebP Migration Status ===" -ForegroundColor Cyan
Write-Host ""

# Check if backup exists
$backupFolders = Get-ChildItem -Path "." -Filter "Images_Backup_*" -Directory
if ($backupFolders) {
    $latestBackup = $backupFolders | Sort-Object Name -Descending | Select-Object -First 1
    $backupSize = (Get-ChildItem $latestBackup.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $backupGB = [math]::Round($backupSize / 1GB, 2)
    Write-Host "Backup: $($latestBackup.Name)" -ForegroundColor Green
    Write-Host "  Size: $backupGB GB of ~3.8 GB" -ForegroundColor White
    
    if ($backupGB -ge 3.7) {
        Write-Host "  Status: Complete!" -ForegroundColor Green
    } else {
        Write-Host "  Status: In progress..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Backup: Not started" -ForegroundColor Yellow
}

Write-Host ""

# Check WebP files
$webpCount = (Get-ChildItem ".\Images" -Recurse -Filter *.webp -ErrorAction SilentlyContinue).Count
$originalCount = (Get-ChildItem ".\Images" -Recurse -Include *.jpg,*.jpeg,*.png,*.gif,*.bmp,*.tif -ErrorAction SilentlyContinue).Count

Write-Host "WebP Conversion:" -ForegroundColor Cyan
Write-Host "  WebP files: $webpCount"
Write-Host "  Original files remaining: $originalCount"

if ($webpCount -gt 0 -and $originalCount -gt 0) {
    $progress = [math]::Round(($webpCount / ($webpCount + $originalCount)) * 100, 1)
    Write-Host "  Progress: $progress%" -ForegroundColor Yellow
}

if ($webpCount -gt 0) {
    $webpSize = (Get-ChildItem ".\Images" -Recurse -Filter *.webp -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $webpMB = [math]::Round($webpSize / 1MB, 2)
    Write-Host "  WebP size: $webpMB MB" -ForegroundColor White
}

Write-Host ""

# Check conversion log
if (Test-Path ".\webp-conversion-log.txt") {
    $logContent = Get-Content ".\webp-conversion-log.txt" -Tail 5
    Write-Host "Latest conversion log entries:" -ForegroundColor Cyan
    $logContent | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "Conversion log: Not created yet" -ForegroundColor Yellow
}

Write-Host ""

# Check HTML update status
$htmlBackup = Get-ChildItem -Path "." -Filter "HTML_Backup_*" -Directory
if ($htmlBackup) {
    Write-Host "HTML Update: Completed" -ForegroundColor Green
    if (Test-Path ".\html-update-log.txt") {
        $htmlLog = Get-Content ".\html-update-log.txt" -Tail 3
        $htmlLog | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
} else {
    Write-Host "HTML Update: Not started" -ForegroundColor Yellow
    Write-Host "  Run: .\update-html-to-webp.ps1 -DryRun" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Cyan

if ($backupGB -lt 3.7 -or -not $backupFolders) {
    Write-Host "1. Wait for backup and conversion to complete" -ForegroundColor Yellow
} elseif ($webpCount -eq 0) {
    Write-Host "1. Wait for image conversion to complete" -ForegroundColor Yellow
} elseif (-not $htmlBackup) {
    Write-Host "1. Run: .\update-html-to-webp.ps1 -DryRun" -ForegroundColor Yellow
    Write-Host "2. Then run: .\update-html-to-webp.ps1" -ForegroundColor Yellow
} else {
    Write-Host "1. Test your website: start index.html" -ForegroundColor Green
    Write-Host "2. Clean up originals: .\convert-images-webp.ps1 -DeleteOriginals" -ForegroundColor Yellow
    Write-Host "3. Clean Git history to reduce from 8.18 GB to <5 GB" -ForegroundColor Yellow
}

Write-Host ""
