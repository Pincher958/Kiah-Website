# Script to transform lads-gallery structure in toddington-members.html
# From: separate headings and gallery sections
# To: paired columns with heading + image box

$filePath = "e:\Kiah Website Backup\kiah-website-recovered\toddington-members.html"
$content = Get-Content -Path $filePath -Raw

# Use regex to find and replace each gallery container structure
# Pattern matches from lads-gallery-container opening to its closing
$pattern = [regex]::new(@'
(?s)(<div class="lads-gallery-container">\s*)<div class="lads-gallery-headings">\s*<div\s+class="lads-heading"\s+style="color: darkgoldenrod; text-decoration: underline"\s*>\s*(.*?)\s*</div>\s*<div\s+class="lads-heading"\s+style="color: darkgoldenrod; text-decoration: underline"\s*>\s*(.*?)\s*</div>\s*</div>\s*<div class="lads-gallery">\s*<div class="lads-image-box">\s*(<img[^>]*>)\s*</div>\s*<div class="lads-image-box">\s*(<img[^>]*>)\s*</div>\s*</div>(\s*</div>)
'@)

$replacement = {
    param($match)
    
    $indent = $match.Groups[1].Value
    $heading1 = $match.Groups[2].Value
    $heading2 = $match.Groups[3].Value
    $img1 = $match.Groups[4].Value
    $img2 = $match.Groups[5].Value
    $closingDiv = $match.Groups[6].Value
    
    # Build the new structure
    $newStructure = @"
$indent<div class="lads-image-column">
						<div
							class="lads-heading"
							style="color: darkgoldenrod; text-decoration: underline"
						>
							$heading1
						</div>
						<div class="lads-image-box">
							$img1
						</div>
					</div>
					<div class="lads-image-column">
						<div
							class="lads-heading"
							style="color: darkgoldenrod; text-decoration: underline"
						>
							$heading2
						</div>
						<div class="lads-image-box">
							$img2
						</div>
					</div>$closingDiv
"@
    
    return $newStructure
}

# Count matches before replacement
$matches = $pattern.Matches($content)
Write-Host "Found $($matches.Count) instances to replace"

# Perform the replacement
$newContent = $pattern.Replace($content, $replacement)

# Check if any replacements were made
if ($newContent -ne $content) {
    # Backup the original file
    $backupPath = $filePath + ".backup-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Copy-Item -Path $filePath -Destination $backupPath
    Write-Host "Backup created at: $backupPath"
    
    # Write the new content
    Set-Content -Path $filePath -Value $newContent -NoNewline
    Write-Host "Successfully transformed all instances in the file"
} else {
    Write-Host "No changes were made to the file"
}
