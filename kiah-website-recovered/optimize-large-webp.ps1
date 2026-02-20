param(
    [int]$MinSize = 500,  # Minimum size in KB to optimize
    [int]$Quality = 80,    # WebP quality (lower = smaller file, but still good quality)
    [int]$MaxWidth = 1920, # Maximum width in pixels
    [switch]$DryRun = $false
)

# ImageMagick path
$magickPath = "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe"

if (-not (Test-Path $magickPath)) {
    Write-Host "ERROR: ImageMagick not found at $magickPath" -ForegroundColor Red
    Write-Host "Checking if magick is in PATH..." -ForegroundColor Yellow
    $magickCmd = Get-Command magick -ErrorAction SilentlyContinue
    if ($magickCmd) {
        $magickPath = $magickCmd.Source
        Write-Host "Found ImageMagick in PATH: $magickPath" -ForegroundColor Green
    } else {
        Write-Host "Please install ImageMagick first" -ForegroundColor Red
        exit 1
    }
}

Write-Host "=== Optimizing Large WebP Images ===" -ForegroundColor Cyan
Write-Host "Target: Images over ${MinSize}KB"
Write-Host "Maximum width: ${MaxWidth}px"
Write-Host "WebP Quality: $Quality"
Write-Host "Dry Run: $DryRun" -ForegroundColor $(if ($DryRun) { "Yellow" } else { "Green" })
Write-Host ""

# Find all large WebP images (excluding thumbnails)
$minSizeBytes = $MinSize * 1KB
$largeImages = Get-ChildItem -Path "Images" -Recurse -File -Include "*.webp" | 
    Where-Object { $_.Name -notmatch "_thumb" -and $_.Length -gt $minSizeBytes }

$totalCount = $largeImages.Count
Write-Host "Found $totalCount images over ${MinSize}KB to optimize"
Write-Host ""

if ($totalCount -eq 0) {
    Write-Host "No images found to optimize!" -ForegroundColor Yellow
    exit 0
}

if ($DryRun) {
    Write-Host "DRY RUN - No files will be modified" -ForegroundColor Yellow
    Write-Host ""
    $largeImages | Select-Object -First 20 | ForEach-Object {
        $sizeKB = [math]::Round($_.Length / 1KB, 2)
        Write-Host "Would optimize: $($_.Name) (${sizeKB} KB) - $($_.DirectoryName.Replace((Get-Location), '.'))"
    }
    if ($totalCount -gt 20) {
        Write-Host "... and $($totalCount - 20) more files"
    }
    
    # Show size breakdown
    $totalSize = ($largeImages | Measure-Object -Property Length -Sum).Sum
    Write-Host "`nTotal size of images to optimize: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host "Estimated space savings: 30-50% (approximately $([math]::Round($totalSize * 0.4 / 1MB, 2)) MB)" -ForegroundColor Cyan
    exit 0
}

# Confirm action
Write-Host "This will optimize $totalCount images" -ForegroundColor Yellow
Write-Host "Each image will be:" -ForegroundColor Yellow
Write-Host "  1. Resized to max ${MaxWidth}px wide (if larger)" -ForegroundColor Yellow
Write-Host "  2. Recompressed with quality $Quality" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Continue? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit 0
}

# Create a temporary backup directory
$backupDir = "Images_Optimization_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Write-Host "`nCreating backup directory: $backupDir" -ForegroundColor Yellow
New-Item -Path $backupDir -ItemType Directory -Force | Out-Null

$optimized = 0
$errors = 0
$noChange = 0
$totalSizeBefore = 0
$totalSizeAfter = 0
$startTime = Get-Date

$logFile = "optimization-log-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
"Large WebP Optimization Log - $(Get-Date)" | Out-File $logFile
"==========================================" | Out-File $logFile -Append
"Settings: MinSize=${MinSize}KB, Quality=$Quality, MaxWidth=${MaxWidth}px" | Out-File $logFile -Append
"" | Out-File $logFile -Append

foreach ($image in $largeImages) {
    $sizeBefore = $image.Length
    $totalSizeBefore += $sizeBefore
    
    try {
        # Backup the original
        $backupPath = Join-Path $backupDir $image.Name
        Copy-Item $image.FullName $backupPath -Force
        
        # Create a temporary file for the optimized version
        $tempFile = [System.IO.Path]::GetTempFileName()
        $tempWebp = [System.IO.Path]::ChangeExtension($tempFile, '.webp')
        
        # Optimize: resize if needed and recompress with quality setting
        & $magickPath $image.FullName -resize "${MaxWidth}x>" -quality $Quality $tempWebp 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0 -and (Test-Path $tempWebp)) {
            $sizeAfter = (Get-Item $tempWebp).Length
            
            # Only replace if we actually saved space
            if ($sizeAfter -lt $sizeBefore) {
                Copy-Item $tempWebp $image.FullName -Force
                Remove-Item $tempWebp -Force
                
                $totalSizeAfter += $sizeAfter
                $reduction = [math]::Round((($sizeBefore - $sizeAfter) / $sizeBefore) * 100, 1)
                $savedKB = [math]::Round(($sizeBefore - $sizeAfter) / 1KB, 1)
                
                Write-Host "OPTIMIZED: $($image.Name) - $([math]::Round($sizeBefore / 1KB, 1)) KB -> $([math]::Round($sizeAfter / 1KB, 1)) KB (-${savedKB} KB, $reduction%)" -ForegroundColor Green
                "OPTIMIZED: $($image.FullName) - $([math]::Round($sizeBefore / 1KB, 1)) KB -> $([math]::Round($sizeAfter / 1KB, 1)) KB ($reduction% reduction)" | Out-File $logFile -Append
                
                $optimized++
            } else {
                # New file is not smaller, keep original
                Remove-Item $tempWebp -Force -ErrorAction SilentlyContinue
                $totalSizeAfter += $sizeBefore
                Write-Host "NO CHANGE: $($image.Name) - already optimized" -ForegroundColor DarkGray
                $noChange++
            }
        } else {
            throw "ImageMagick failed to process the image"
        }
        
        # Clean up temp file
        if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
        
        # Progress indicator
        $processed = $optimized + $errors + $noChange
        if ($processed % 50 -eq 0) {
            $percentComplete = [math]::Round(($processed / $totalCount) * 100, 1)
            Write-Host "`nProgress: $percentComplete% | Optimized: $optimized | No Change: $noChange | Errors: $errors`n" -ForegroundColor Cyan
        }
    }
    catch {
        $errors++
        $totalSizeAfter += $sizeBefore
        Write-Host "ERROR: Failed to optimize $($image.Name) - $_" -ForegroundColor Red
        "ERROR: $($image.FullName) - $_" | Out-File $logFile -Append
    }
}

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMinutes

Write-Host "`n=== Optimization Complete ===" -ForegroundColor Green
Write-Host "Total images processed: $totalCount"
Write-Host "Successfully optimized: $optimized"
Write-Host "No change needed: $noChange"
Write-Host "Errors: $errors"
Write-Host "Size before: $([math]::Round($totalSizeBefore / 1MB, 2)) MB"
Write-Host "Size after: $([math]::Round($totalSizeAfter / 1MB, 2)) MB"
Write-Host "Space saved: $([math]::Round(($totalSizeBefore - $totalSizeAfter) / 1MB, 2)) MB"
Write-Host "Reduction: $([math]::Round((($totalSizeBefore - $totalSizeAfter) / $totalSizeBefore) * 100, 1))%"
Write-Host "Time taken: $([math]::Round($duration, 1)) minutes"
Write-Host ""
Write-Host "Backup location: $backupDir" -ForegroundColor Cyan
Write-Host "Log file: $logFile" -ForegroundColor Cyan

"" | Out-File $logFile -Append
"=== Summary ===" | Out-File $logFile -Append
"Total images: $totalCount" | Out-File $logFile -Append
"Optimized: $optimized" | Out-File $logFile -Append
"No change: $noChange" | Out-File $logFile -Append
"Errors: $errors" | Out-File $logFile -Append
"Space saved: $([math]::Round(($totalSizeBefore - $totalSizeAfter) / 1MB, 2)) MB" | Out-File $logFile -Append
"Time: $([math]::Round($duration, 1)) minutes" | Out-File $logFile -Append
