param(
    [string]$ImagesPath = "f:\Kiah Website Backup\kiah-website-recovered\Images",
    [int]$Quality = 85,
    [switch]$DeleteOriginals = $false,
    [switch]$DryRun = $false,
    [switch]$BackupFirst = $true
)

Write-Host ""
Write-Host "=== WebP Image Converter ===" -ForegroundColor Cyan
Write-Host "Images Path: $ImagesPath"
Write-Host "Quality: $Quality%"
Write-Host "Delete Originals: $DeleteOriginals"
Write-Host "Dry Run: $DryRun"
Write-Host "Backup First: $BackupFirst"
Write-Host ""

$magickCmd = Get-Command magick -ErrorAction SilentlyContinue

if (-not $magickCmd) {
    $magickPath = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"
    if (Test-Path $magickPath) {
        $magickCmd = $magickPath
        Write-Host "ImageMagick found: $magickPath" -ForegroundColor Green
    } else {
        Write-Host "ImageMagick not found. Please install it first." -ForegroundColor Red
        Write-Host "Run: winget install ImageMagick.ImageMagick" -ForegroundColor Yellow
        exit
    }
} else {
    Write-Host "ImageMagick found: $($magickCmd.Source)" -ForegroundColor Green
    $magickCmd = $magickCmd.Source
}

$imageExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.jfif', '.THM')

if ($BackupFirst -and -not $DryRun) {
    $backupPath = "f:\Kiah Website Backup\kiah-website-recovered\Images_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "Creating backup at: $backupPath" -ForegroundColor Yellow
    Write-Host "This may take a while..." -ForegroundColor Yellow
    Copy-Item -Path $ImagesPath -Destination $backupPath -Recurse -Force
    Write-Host "Backup complete!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Scanning for images..." -ForegroundColor Cyan
$imageFiles = Get-ChildItem -Path $ImagesPath -Recurse -File | Where-Object {
    $imageExtensions -contains $_.Extension
}

$totalFiles = $imageFiles.Count
Write-Host "Found $totalFiles images to convert" -ForegroundColor Green
Write-Host ""

$converted = 0
$skipped = 0
$errors = 0
$totalOriginalSize = 0
$totalWebPSize = 0
$startTime = Get-Date

$logFile = "f:\Kiah Website Backup\kiah-website-recovered\webp-conversion-log.txt"
"WebP Conversion Log - $(Get-Date)" | Out-File $logFile
"================================" | Out-File $logFile -Append
"" | Out-File $logFile -Append

foreach ($file in $imageFiles) {
    $webpPath = [System.IO.Path]::ChangeExtension($file.FullName, '.webp')
    
    if (Test-Path $webpPath) {
        Write-Host "SKIP: $($file.Name) (WebP exists)" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    
    try {
        $originalSize = $file.Length
        $totalOriginalSize += $originalSize
        
        if ($DryRun) {
            Write-Host "WOULD CONVERT: $($file.Name)" -ForegroundColor Gray
            $converted++
        } else {
            Write-Host "Converting: $($file.Name) " -NoNewline
            
            $result = & $magickCmd convert "$($file.FullName)" -quality $Quality "$webpPath" 2>&1
            
            if ($LASTEXITCODE -eq 0 -and (Test-Path $webpPath)) {
                $webpSize = (Get-Item $webpPath).Length
                $totalWebPSize += $webpSize
                
                $savings = [math]::Round((($originalSize - $webpSize) / $originalSize) * 100, 1)
                $originalKB = [math]::Round($originalSize / 1KB, 0)
                $webpKB = [math]::Round($webpSize / 1KB, 0)
                
                Write-Host "OK ${originalKB}KB to ${webpKB}KB (${savings}% saved)" -ForegroundColor Green
                
                "SUCCESS: $($file.FullName) -> Saved $savings%" | Out-File $logFile -Append
                
                if ($DeleteOriginals) {
                    Remove-Item $file.FullName -Force
                    Write-Host "  Deleted original" -ForegroundColor DarkGray
                }
                
                $converted++
            } else {
                Write-Host "Failed" -ForegroundColor Red
                "ERROR: Failed to convert $($file.FullName)" | Out-File $logFile -Append
                $errors++
            }
        }
    }
    catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        "ERROR: $($file.FullName) - $($_.Exception.Message)" | Out-File $logFile -Append
        $errors++
    }
    
    $processed = $converted + $skipped + $errors
    if ($processed % 100 -eq 0) {
        $progress = [math]::Round(($processed / $totalFiles) * 100, 1)
        $elapsed = (Get-Date) - $startTime
        $avgTime = $elapsed.TotalSeconds / $processed
        $remaining = ($totalFiles - $processed) * $avgTime
        Write-Host ""
        Write-Host "Progress: $progress% | Converted: $converted | Skipped: $skipped | Errors: $errors" -ForegroundColor Cyan
        Write-Host "Estimated time remaining: $([math]::Round($remaining / 60, 1)) minutes" -ForegroundColor Cyan
        Write-Host ""
    }
}

Write-Host ""
Write-Host "=== Conversion Complete ===" -ForegroundColor Cyan
Write-Host "Total files: $totalFiles"
Write-Host "Converted: $converted" -ForegroundColor Green
Write-Host "Skipped: $skipped" -ForegroundColor Yellow
if ($errors -gt 0) {
    Write-Host "Errors: $errors" -ForegroundColor Red
} else {
    Write-Host "Errors: $errors"
}

if (!$DryRun -and $converted -gt 0) {
    $originalSizeMB = [math]::Round($totalOriginalSize / 1MB, 2)
    $webpSizeMB = [math]::Round($totalWebPSize / 1MB, 2)
    $savedMB = [math]::Round(($totalOriginalSize - $totalWebPSize) / 1MB, 2)
    $savedPercent = [math]::Round((($totalOriginalSize - $totalWebPSize) / $totalOriginalSize) * 100, 1)
    
    Write-Host ""
    Write-Host "Size Comparison:" -ForegroundColor Cyan
    Write-Host "  Original: $originalSizeMB MB"
    Write-Host "  WebP: $webpSizeMB MB"
    Write-Host "  Saved: $savedMB MB ($savedPercent%)" -ForegroundColor Green
    
    "" | Out-File $logFile -Append
    "================================" | Out-File $logFile -Append
    "Total Savings: $savedMB MB ($savedPercent%)" | Out-File $logFile -Append
}

$totalTime = (Get-Date) - $startTime
Write-Host ""
Write-Host "Total time: $([math]::Round($totalTime.TotalMinutes, 1)) minutes" -ForegroundColor Cyan
Write-Host "Log file: $logFile" -ForegroundColor Yellow
Write-Host ""
