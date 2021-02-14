$languages = "CSharp","Java","PHP","TypeScript","ObjC"
$sourceDirectories = @{
    "linux" = "/home/muzengin";
    "macos" = "/home/muzengin";
    "windows" = "C:/github";
}
$platforms = $sourceDirectories | Select-Object -ExpandProperty Keys

$cleanMetadataPaths = @{
    "v1.0" = "clean_v10_metadata/cleanMetadataWithDescriptionsv1.0.xml";
    "beta" = "clean_beta_metadata/cleanMetadataWithDescriptionsbeta.xml"
}

$endpointVersions = $cleanMetadataPaths | Select-Object -ExpandProperty Keys

foreach ($platform in $platforms)
{
    $fileName = "launchSettings.MSGraph-SDK-Code-Generator.$platform.json"
    $launchSettings = @{
        "profiles" = @{}
    }

    Write-Host "Generating $fileName" -ForegroundColor Green
    
    $sourceDirectory = $sourceDirectories[$platform]
    $metadataDirectory = "$sourceDirectory/msgraph-metadata"
    $workingDirectory = "$sourceDirectory/MSGraph-SDK-Code-Generator/src/Typewriter/bin/Debug/net5.0"
    foreach ($language in $languages)
    {
        foreach ($endpointVersion in $endpointVersions)
        {
            $metadataPath = $cleanMetadataPaths[$endpointVersion]
            $metadataFullPath = "$metadataDirectory/$metadataPath"
            $outputDirectory = "$language`_$endpointVersion"
            
            $commandLineArgs = "-v Info -m $metadataFullPath -g Files -l $language -o $outputDirectory -e $endpointVersion"
            
            if ($platform -eq "windows")
            {
                $commandLineArgs = $commandLineArgs.Replace("/", "\")
                $workingDirectory = $workingDirectory.Replace("/", "\")
            }

            $profileName = "Generate_$language`_$endpointVersion"
            $launchSettings.profiles[$profileName] = @{
                "commandName" = "Project";
                "commandLineArgs" = $commandLineArgs;
                "workingDirectory" = $workingDirectory;
            }
        }
    }

    ($launchSettings | ConvertTo-Json) > $fileName
}