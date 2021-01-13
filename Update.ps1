$things = @("VFE_PortableWoodFiredGenerator",
    "VFE_PortableChemfuelPoweredGenerator",
    "VFE_IndustrialWoodFiredGenerator",
    "VFE_IndustrialChemfuelPoweredGenerator",
    "VFE_SmallVanometricPowerCell",
    "VFE_LargeVanometricPowerCell",
    "VFE_LargeBattery",
    # "VFE_SmallBattery", # Removed because it has a custom thingClass
    "VFE_AdvancedBattery",
    "VFE_LargeAdvancedBattery")

$outputpath = $pwd
$inputpath = "D:\Steam\steamapps\workshop\content\294100\2062943477"

$research = @()

Push-Location $inputpath
Get-ChildItem -Recurse -File -Filter "*.xml" -Path $inputpath | ForEach-Object {

    $xml = [xml]'<?xml version="1.0" encoding="utf-8" ?><Defs />'
    $defs = $xml.SelectSingleNode('/Defs')

    $file = [xml](Get-Content $_.FullName)
    $path = Resolve-Path -Relative $_.FullName

    $things | Foreach-Object {
        if ($item = $file.SelectSingleNode("/Defs/ThingDef[defName='$_']")) {
            Write-Host "Thing $_ : $path" -ForegroundColor Green
            $defs.AppendChild($xml.ImportNode($item, $true)) | Out-Null
        }
    }

    if ($defs.ThingDef) {
        $savepath = Join-Path $outputpath $path
        New-Item (Split-Path -Parent $savepath) -ItemType Directory -Force | Out-Null
        $xml.Save($savepath)

        $texpath = Join-Path $outputpath "Textures"

        $xml.Defs.ThingDef.graphicData.texPath | ForEach-Object {
            if ($_) {
                $dest = Split-Path -Parent (Join-Path $texpath $_)
                New-Item $dest -ItemType Directory -Force | Out-Null
                Get-Item "$(Join-Path "Textures" $_)*" | Copy-Item -Destination $dest
            }
        }

        $xml.Defs.ThingDef.uiIconPath | ForEach-Object {
            if ($_) {
                $dest = Split-Path -Parent (Join-Path $texpath $_)
                New-Item $dest -ItemType Directory -Force | Out-Null
                Get-Item "$(Join-Path "Textures" $_)*" | Copy-Item -Destination $dest
            }
        }

        $xml.Defs.ThingDef.researchPrerequisites.li | ForEach-Object {
            $research += $_
        }
    }
}

Get-ChildItem -Recurse -File -Filter "*.xml" -Path $inputpath | ForEach-Object {

    $xml = [xml]'<?xml version="1.0" encoding="utf-8" ?>
                <Defs>
                    <ResearchTabDef>
                        <defName>VanillaExpanded</defName>
                        <label>Vanilla Expanded</label>
                    </ResearchTabDef>
                </Defs>'
    $defs = $xml.SelectSingleNode('/Defs')

    $file = [xml](Get-Content $_.FullName)
    $path = Resolve-Path -Relative $_.FullName

    $research | Select-Object -Unique | Foreach-Object {
        if ($item = $file.SelectSingleNode("/Defs/ResearchProjectDef[defName='$_']")) {
            Write-Host "Research $_ : $path" -ForegroundColor Blue
            $defs.AppendChild($xml.ImportNode($item, $true)) | Out-Null
        }
    }

    if ($defs.ResearchProjectDef) {
        $savepath = Join-Path $outputpath $path
        New-Item (Split-Path -Parent $savepath) -ItemType Directory -Force | Out-Null
        $xml.Save($savepath)
    } 
}     

Pop-Location
