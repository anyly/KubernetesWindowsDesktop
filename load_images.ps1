$ImagesProperties = "$PSScriptRoot/cache/k8s-for-docker-desktop/images.properties"
$LocalImages = "$PSScriptRoot/images"
$AllImages = @()

#Installation From Local Images
if (Test-Path $LocalImages) {
	Get-ChildItem $LocalImages | ForEach-Object -Process{
		if(($_ -is [System.IO.FileInfo]) -and ($_.Extension.ToLower() -eq '.tar')) {
			$ImagesRepository = $_.BaseName.Replace('@', '/').Replace('~', ':');
			if ($AllImages -contains $ImagesRepository) {
				continue
			}
			docker load -i $_.FullName
			$AllImages += $ImagesRepository
			Write-Output "$ImagesRepository Local Loaded"
		}
	}
}

#Installation From Images Properties
foreach($line in Get-Content $ImagesProperties) {
    $data = $line.Split('=')
    $key = $data[0];
    $value = $data[1];
	$ImagesRepository = $key
	if ($AllImages -contains $ImagesRepository) {
		continue
	}
    docker pull ${value}
    docker tag ${value} ${key}
    docker rmi ${value}
	$AllImages += $ImagesRepository
    Write-Output "$key=$value"
}