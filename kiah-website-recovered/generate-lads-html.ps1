# Script to generate Eaglelads HTML sections with images
# This will scan the folders and create properly sorted HTML

$basePath = "Images/Eagle/The Lads"
$crewData = @()

# Define crew members with their folder mappings (alphabetically by surname)
$crewMembers = @(
    @{Name="Peter (Ali) Barber"; Folder="Ali Barber"; Rank="Unknown"; Surname="Barber"},
    @{Name="Keith (Barney) Barnes"; Folder="Keith Barnes"; Rank="Unknown"; Surname="Barnes"},
    @{Name="Peter (Bazzers) Bastock"; Folder="Pete Bastock"; Rank="RO2(T)"; Surname="Bastock"},
    @{Name="Colin Baxter"; Folder="Colin Baxter"; Rank="RS"; Surname="Baxter"},
    @{Name="John (Blacky) Blackwell"; Folder="Blacky Blackwell"; Rank="CY"; Surname="Blackwell"},
    @{Name="Glen (Sam) Blyth"; Folder="Sam Blyth"; Rank="RO2(?)"; Surname="Blyth"},
    @{Name="Ian Body"; Folder="Ian Body"; Rank="RO3(T)"; Surname="Body"},
    @{Name="David (Tiny) Brighton"; Folder="Dave Brighton"; Rank="RO2(G)"; Surname="Brighton"},
    @{Name="Reginald (Buster) Brown"; Folder="Reggie Brown"; Rank="RO2(G)"; Surname="Brown"},
    @{Name="Rodney (Chippy) Carpenter"; Folder="Chippy Carpenter"; Rank="RO2(T)"; Surname="Carpenter"},
    @{Name="Frank (Woggers) Chadwick"; Folder="Frank Chadwick"; Rank="RO2(G)"; Surname="Chadwick"},
    @{Name="Chris Childs"; Folder="Chris Childs"; Rank="RO2(?)"; Surname="Childs"},
    @{Name="Peter (Nobby) Clarke"; Folder="Nobby Clarke"; Rank="RO2(T)"; Surname="Clarke"},
    @{Name="Lindsay John (Charlie) Cosker"; Folder="Lyndsey John Cosker"; Rank="LRO(T)"; Surname="Cosker"},
    @{Name="Roger Dunt"; Folder="Roger Dunt"; Rank="Unknown"; Surname="Dunt"},
    @{Name="Colin Ellis"; Folder="Colin Ellis"; Rank="Unknown"; Surname="Ellis"},
    @{Name="Dick Fish"; Folder="Dick Fish"; Rank="Unknown"; Surname="Fish"},
    @{Name="Florrie Ford"; Folder="Florrie Ford"; Rank="Unknown"; Surname="Ford"},
    @{Name="Pete Fox"; Folder="Pete Fox"; Rank="Unknown"; Surname="Fox"},
    @{Name="Barry Frere"; Folder="Barry Frere"; Rank="Unknown"; Surname="Frere"},
    @{Name="Pete Gamble"; Folder="Pete Gamble"; Rank="Unknown"; Surname="Gamble"},
    @{Name="Dave Goldfinch"; Folder="Dave Goldfinch"; Rank="Unknown"; Surname="Goldfinch"},
    @{Name="Geoff Gordon"; Folder="Geoff Gordon"; Rank="Unknown"; Surname="Gordon"},
    @{Name="Ian Grant"; Folder="Ian Grant"; Rank="Unknown"; Surname="Grant"},
    @{Name="Bob Gregory"; Folder="Bob Gregory"; Rank="Unknown"; Surname="Gregory"},
    @{Name="Barry Haines"; Folder="Barry Haines"; Rank="Unknown"; Surname="Haines"},
    @{Name="Harry Harrison"; Folder="Harry Harrison"; Rank="Unknown"; Surname="Harrison"},
    @{Name="Charlie Herridge"; Folder="Charlie Herridge"; Rank="Unknown"; Surname="Herridge"},
    @{Name="Eddie Herron"; Folder="Eddie Herron"; Rank="Unknown"; Surname="Herron"},
    @{Name="Roger Hopkins"; Folder="Roger Hopkins"; Rank="Unknown"; Surname="Hopkins"},
    @{Name="Chris Howard"; Folder="Chris Howard"; Rank="Unknown"; Surname="Howard"},
    @{Name="Father Jones"; Folder="Father Jones"; Rank="Padre"; Surname="Jones"},
    @{Name="Alan Keenes"; Folder="Alan Keenes"; Rank="Unknown"; Surname="Keenes"},
    @{Name="Noddy Knot"; Folder="Noddy Knot"; Rank="Unknown"; Surname="Knot"},
    @{Name="Alan Langler"; Folder="Alan Langler"; Rank="Unknown"; Surname="Langler"},
    @{Name="Roger Lawrence"; Folder="Roger Lawrence"; Rank="Unknown"; Surname="Lawrence"},
    @{Name="Pete Legg"; Folder="Pete Legg"; Rank="Unknown"; Surname="Legg"},
    @{Name="Johnny Mackin"; Folder="Johnny Mackin"; Rank="Unknown"; Surname="Mackin"},
    @{Name="Alan Martin"; Folder="Alan Martin"; Rank="Unknown"; Surname="Martin"},
    @{Name="Neil McCloghlan"; Folder="Neil McCloghlan"; Rank="Unknown"; Surname="McCloghlan"},
    @{Name="Bob McGlennan"; Folder="Bob McGlennan"; Rank="Unknown"; Surname="McGlennan"},
    @{Name="Colin Mowles"; Folder="Colin Mowles"; Rank="Unknown"; Surname="Mowles"},
    @{Name="Muzz Murray"; Folder="Muzz Murray"; Rank="Unknown"; Surname="Murray"},
    @{Name="Sandy Nabbs"; Folder="Sandy Nabbs"; Rank="Unknown"; Surname="Nabbs"},
    @{Name="Bruce Pavier"; Folder="Bruce Pavier"; Rank="Unknown"; Surname="Pavier"},
    @{Name="Pete Phillips"; Folder="Pete Phillips"; Rank="Unknown"; Surname="Phillips"},
    @{Name="Priggey Price"; Folder="Priggey Price"; Rank="Unknown"; Surname="Price"},
    @{Name="Dick Richards"; Folder="Dick Richards"; Rank="Unknown"; Surname="Richards"},
    @{Name="Lou Rowson"; Folder="Lou Rowson"; Rank="Unknown"; Surname="Rowson"},
    @{Name="Tex Scott"; Folder="Tex Scott"; Rank="Unknown"; Surname="Scott"},
    @{Name="Gerry Sharp"; Folder="Gerry Sharp"; Rank="Unknown"; Surname="Sharp"},
    @{Name="Jan Sheere"; Folder="Jan Sheere"; Rank="Unknown"; Surname="Sheere"},
    @{Name="Martin Slater"; Folder="Martin Slater"; Rank="Unknown"; Surname="Slater"},
    @{Name="Denis Smith"; Folder="Denis Smith"; Rank="Unknown"; Surname="Smith"},
    @{Name="Pete Statton"; Folder="Pete Statton"; Rank="Unknown"; Surname="Statton"},
    @{Name="Dave Strickland"; Folder="Dave Strickland"; Rank="Unknown"; Surname="Strickland"},
    @{Name="Paul Strickland"; Folder="Paul Strickland"; Rank="Unknown"; Surname="Strickland"},
    @{Name="George Temperley"; Folder="George Temperley"; Rank="Unknown"; Surname="Temperley"},
    @{Name="Bill Todd"; Folder="Bill Todd"; Rank="Unknown"; Surname="Todd"},
    @{Name="Topsy Turner"; Folder="Topsy Turner"; Rank="Unknown"; Surname="Turner"},
    @{Name="Cliff Wade"; Folder="Cliff Wade"; Rank="Unknown"; Surname="Wade"},
    @{Name="Jeffery Williams"; Folder="Jeffery Williams"; Rank="Unknown"; Surname="Williams"},
    @{Name="Slinger Woods"; Folder="Slinger Woods"; Rank="Unknown"; Surname="Woods"}
)

# Sort by surname
$crewMembers = $crewMembers | Sort-Object {$_.Surname}

# Generate HTML for each crew member
$htmlOutput = ""

foreach ($crew in $crewMembers) {
    $folderPath = "../$basePath/$($crew.Folder)"
    $fullPath = "Images/Eagle/The Lads/$($crew.Folder)"
    
    # Get images from folder (if exists)
    $images = @()
    if (Test-Path $fullPath) {
        $images = Get-ChildItem -Path $fullPath -Filter "*.webp" | 
                  Where-Object { $_.Name -notlike "*_thumb.webp" } |
                  Select-Object -First 6
    }
    
    $htmlOutput += @"
					<div class="lads-row">
						<div class="lads-info">
							<h3 class="lads-name">$($crew.Name)</h3>
							<p class="lads-rank">$($crew.Rank)</p>
						</div>
						<div class="lads-gallery-container">
							<div class="lads-gallery-headings">
								<div
									class="lads-heading"
									style="color: darkgoldenrod; text-decoration: underline"
								>
									As A Kid
								</div>
								<div
									class="lads-heading lads-heading-span-4"
									style="color: darkgoldenrod; text-decoration: underline"
								>
									In The Mob
								</div>
								<div
									class="lads-heading"
									style="color: darkgoldenrod; text-decoration: underline"
								>
									As An Old Git
								</div>
							</div>
							<div class="lads-gallery">
"@
    
    # Add up to 6 images
    for ($i = 0; $i -lt 6; $i++) {
        if ($i -lt $images.Count) {
            $img = $images[$i]
            $imgPath = "$folderPath/$($img.Name)"
            $htmlOutput += @"

								<div class="lads-image-box">
									<img
										src="$imgPath"
										alt="$($crew.Name)"
										data-gallery="eaglelads"
									/>
								</div>
"@
        } else {
            $htmlOutput += @"

								<div class="lads-image-box">
									<img src="" alt="" data-gallery="eaglelads" />
								</div>
"@
        }
    }
    
    $htmlOutput += @"

							</div>
						</div>
					</div>

"@
}

# Output to file
$htmlOutput | Out-File -FilePath "lads-generated-html.txt" -Encoding UTF8
Write-Host "HTML generated successfully! Check lads-generated-html.txt"
Write-Host "Total crew members: $($crewMembers.Count)"
