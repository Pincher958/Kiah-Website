param(
    [string]$ImagesPath = "f:\Kiah Website Backup\kiah-website-recovered\Images",
    [switch]$DryRun = $false
)

Write-Host ""
Write-Host "=== Original Image Deletion Tool ===" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be deleted" -ForegroundColor Yellow
} else {
    Write-Host "⚠ WARNING: This will PERMANENTLY DELETE original image files!" -ForegroundColor Red
    Write-Host "WebP and thumbnail versions will be kept." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press CTRL+C to cancel or any other key to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host ""

# Get all original images
$originalExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.jfif', '.THM')
$originalImages = Get-ChildItem -Path $ImagesPath -Recurse -File | Where-Object {
    $originalExtensions -contains $_.Extension
}

Write-Host "Found $($originalImages.Count) original images to check..." -ForegroundColor Cyan
Write-Host ""

$deleted = 0
$skipped = 0
$totalSize = 0
$deletedFiles = @()
$startTime = Get-Date

$logFile = "f:\Kiah Website Backup\kiah-website-recovered\deleted-images-log.txt"
if (-not $DryRun) {
    "Original Image Deletion Log - $(Get-Date)" | Out-File $logFile
    "================================" | Out-File $logFile -Append
    "" | Out-File $logFile -Append
}

foreach ($original in $originalImages) {
    # Check for WebP version and thumbnail
    $webpPath = [System.IO.Path]::ChangeExtension($original.FullName, '.webp')
    $thumbPath = $webpPath -replace '\.webp$', '_thumb.webp'
    
    $hasWebP = Test-Path $webpPath
    $hasThumb = Test-Path $thumbPath
    
    if ($hasWebP -and $hasThumb) {
        $size = $original.Length
        $totalSize += $size
        $sizeKB = [math]::Round($size / 1KB, 0)
        
        if ($DryRun) {
            Write-Host "WOULD DELETE: $($original.Name) ($sizeKB KB)" -ForegroundColor Gray
        } else {
            try {
                Remove-Item $original.FullName -Force
                Write-Host "DELETED: $($original.Name) ($sizeKB KB)" -ForegroundColor Green
                "DELETED: $($original.FullName) ($sizeKB KB)" | Out-File $logFile -Append
                $deletedFiles += $original.FullName
            } catch {
                Write-Host "ERROR deleting $($original.Name): $($_.Exception.Message)" -ForegroundColor Red
                "ERROR: $($original.FullName) - $($_.Exception.Message)" | Out-File $logFile -Append
                $skipped++
                continue
            }
        }
        $deleted++
    } else {
        Write-Host "SKIPPED (missing WebP or thumbnail): $($original.Name)" -ForegroundColor Yellow
        $skipped++
    }
    
    # Progress indicator every 100 files
    if (($deleted + $skipped) % 100 -eq 0) {
        $progress = [math]::Round((($deleted + $skipped) / $originalImages.Count) * 100, 1)
        Write-Host ""
        Write-Host "Progress: $progress% | Deleted: $deleted | Skipped: $skipped" -ForegroundColor Cyan
        Write-Host ""
    }
}

$elapsed = (Get-Date) - $startTime
$totalMB = [math]::Round($totalSize / 1MB, 2)
$totalGB = [math]::Round($totalSize / 1GB, 2)

Write-Host ""
Write-Host "=== Deletion Complete ===" -ForegroundColor Cyan
Write-Host "Total files processed: $($originalImages.Count)"
Write-Host "Files deleted: $deleted" -ForegroundColor Green
Write-Host "Files skipped: $skipped" -ForegroundColor Yellow
Write-Host "Space freed: $totalMB MB ($totalGB GB)" -ForegroundColor Cyan
Write-Host "Time taken: $([math]::Round($elapsed.TotalMinutes, 1)) minutes"
Write-Host ""

if (-not $DryRun -and $deleted -gt 0) {
    Write-Host "Log file created: $logFile" -ForegroundColor Cyan
    "" | Out-File $logFile -Append
    "================================" | Out-File $logFile -Append
    "Total deleted: $deleted files" | Out-File $logFile -Append
    "Space freed: $totalMB MB ($totalGB GB)" | Out-File $logFile -Append
}

if ($DryRun) {
    Write-Host "This was a DRY RUN. To actually delete files, run without -DryRun" -ForegroundColor Yellow
} else {
    Write-Host "Original images have been deleted successfully!" -ForegroundColor Green
    Write-Host "Your WebP images and thumbnails are still intact." -ForegroundColor Green
}

Write-Host ""
