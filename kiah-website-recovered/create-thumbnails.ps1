param(
    [string]$ImagesPath = "",
    [int]$ThumbnailWidth = 400,
    [int]$Quality = 80,
    [switch]$DryRun = $false
)

if (-not $ImagesPath) {
    $ImagesPath = Join-Path $PSScriptRoot "Images"
}

Write-Host ""
Write-Host "=== WebP Thumbnail Generator ===" -ForegroundColor Cyan
Write-Host "Images Path: $ImagesPath"
Write-Host "Thumbnail Width: ${ThumbnailWidth}px"
Write-Host "Quality: $Quality%"
Write-Host "Dry Run: $DryRun"
Write-Host ""

# Find ImageMagick
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

Write-Host ""
Write-Host "Scanning for WebP images..." -ForegroundColor Cyan
$webpFiles = Get-ChildItem -Path $ImagesPath -Filter "*.webp" -Recurse -File | Where-Object {
    $_.Name -notlike "*_thumb.webp"
}

$totalFiles = $webpFiles.Count
Write-Host "Found $totalFiles WebP images to create thumbnails for" -ForegroundColor Green
Write-Host ""

$created = 0
$skipped = 0
$errors = 0
$totalOriginalSize = 0
$totalThumbSize = 0
$startTime = Get-Date

foreach ($file in $webpFiles) {
    # Create thumbnail filename
    $thumbName = [System.IO.Path]::GetFileNameWithoutExtension($file.FullName) + "_thumb.webp"
    $thumbPath = Join-Path $file.DirectoryName $thumbName
    
    if (Test-Path $thumbPath) {
        Write-Host "SKIP: $($file.Name) (thumbnail exists)" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    
    try {
        $originalSize = $file.Length
        $totalOriginalSize += $originalSize
        
        if ($DryRun) {
            Write-Host "WOULD CREATE THUMB: $($file.Name)" -ForegroundColor Gray
            $created++
        } else {
            Write-Host "Creating thumbnail: $($file.Name) " -NoNewline
            
            # Create thumbnail with resize
            & $magickCmd convert "$($file.FullName)" -resize "${ThumbnailWidth}x>" -quality $Quality "$thumbPath" 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0 -and (Test-Path $thumbPath)) {
                $thumbSize = (Get-Item $thumbPath).Length
                $totalThumbSize += $thumbSize
                
                $savings = [math]::Round((($originalSize - $thumbSize) / $originalSize) * 100, 1)
                $originalKB = [math]::Round($originalSize / 1KB, 0)
                $thumbKB = [math]::Round($thumbSize / 1KB, 0)
                
                Write-Host "OK ${originalKB}KB to ${thumbKB}KB (${savings}% saved)" -ForegroundColor Green
                
                $created++
            } else {
                Write-Host "FAILED" -ForegroundColor Red
                $errors++
            }
        }
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
    
    # Progress indicator every 100 files
    if (($created + $skipped + $errors) % 100 -eq 0) {
        $progress = [math]::Round((($created + $skipped + $errors) / $totalFiles) * 100, 1)
        $elapsed = (Get-Date) - $startTime
        $rate = ($created + $skipped + $errors) / $elapsed.TotalSeconds
        $remaining = ($totalFiles - ($created + $skipped + $errors)) / $rate
        
        Write-Host ""
        Write-Host "Progress: $progress% | Created: $created | Skipped: $skipped | Errors: $errors" -ForegroundColor Yellow
        Write-Host "Estimated time remaining: $([math]::Round($remaining / 60, 1)) minutes" -ForegroundColor Yellow
        Write-Host ""
    }
}

$elapsed = (Get-Date) - $startTime

Write-Host ""
Write-Host "=== Thumbnail Creation Complete ===" -ForegroundColor Cyan
Write-Host "Total files: $totalFiles"
Write-Host "Created: $created"
Write-Host "Skipped: $skipped"
Write-Host "Errors: $errors"
Write-Host ""

if (-not $DryRun -and $created -gt 0) {
    $avgOriginalSize = [math]::Round($totalOriginalSize / $created / 1KB, 0)
    $avgThumbSize = [math]::Round($totalThumbSize / $created / 1KB, 0)
    $totalSavings = [math]::Round((($totalOriginalSize - $totalThumbSize) / $totalOriginalSize) * 100, 1)
    
    Write-Host "Size Comparison:"
    Write-Host "  Average Original: $avgOriginalSize KB"
    Write-Host "  Average Thumbnail: $avgThumbSize KB"
    Write-Host "  Average Savings: $totalSavings%"
    Write-Host ""
}

Write-Host "Total time: $([math]::Round($elapsed.TotalMinutes, 1)) minutes"
Write-Host ""
