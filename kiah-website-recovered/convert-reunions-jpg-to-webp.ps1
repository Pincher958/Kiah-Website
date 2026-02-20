$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$jpgs = Get-ChildItem -Recurse -File -Include *.jpg,*.jpeg | Where-Object { $_.FullName -match '\\Reunions\\' }
$quality = 82
$results = @()

foreach ($jpg in $jpgs) {
    $src = $jpg.FullName
    $dir = $jpg.DirectoryName
    $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($jpg.Name)
    $final = Join-Path $dir ($nameNoExt + '.webp')

    $origDim = (& magick identify -format '%wx%h' "$src" | Out-String).Trim()
    & magick "$src" -strip -define webp:method=6 -define webp:auto-filter=true -quality $quality "$final"

    $newDim = (& magick identify -format '%wx%h' "$final" | Out-String).Trim()
    if ($newDim -ne $origDim) {
        if (Test-Path $final) {
            Remove-Item "$final" -Force
        }
        $results += [PSCustomObject]@{
            File = $jpg.Name
            Status = 'Failed'
            OriginalBytes = $jpg.Length
            WebPBytes = 0
            SavedBytes = 0
            ChosenQ = $quality
        }
        continue
    }

    $newLen = (Get-Item $final).Length
    $results += [PSCustomObject]@{
        File = $jpg.Name
        Status = 'Converted'
        OriginalBytes = $jpg.Length
        WebPBytes = $newLen
        SavedBytes = ($jpg.Length - $newLen)
        ChosenQ = $quality
    }
}

$logPath = Join-Path (Get-Location) ("reunions-webp-conversion-" + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.csv')
$results | Export-Csv -Path $logPath -NoTypeInformation

$originalSum = (($results | Measure-Object OriginalBytes -Sum).Sum)
$savedSum = (($results | Measure-Object SavedBytes -Sum).Sum)
$webpSum = (($results | Measure-Object WebPBytes -Sum).Sum)

$summary = [PSCustomObject]@{
    TotalJpg = $jpgs.Count
    Converted = ($results | Where-Object Status -eq 'Converted').Count
    Failed = ($results | Where-Object Status -eq 'Failed').Count
    OriginalMB = [math]::Round(($originalSum / 1MB), 2)
    WebPMB = [math]::Round(($webpSum / 1MB), 2)
    SavedMB = [math]::Round(($savedSum / 1MB), 2)
    SavedPercent = if ($originalSum -gt 0) { [math]::Round((($savedSum / $originalSum) * 100), 2) } else { 0 }
    Log = $logPath
}

$summary | Format-List
Write-Output 'TOP_10_BIGGEST_SAVINGS'
$results |
    Where-Object Status -eq 'Converted' |
    Sort-Object SavedBytes -Descending |
    Select-Object -First 10 File, ChosenQ,
        @{N = 'OrigKB'; E = { [math]::Round($_.OriginalBytes / 1KB, 1) }},
        @{N = 'WebPKB'; E = { [math]::Round($_.WebPBytes / 1KB, 1) }},
        @{N = 'SavedKB'; E = { [math]::Round($_.SavedBytes / 1KB, 1) }} |
    Format-Table -AutoSize
