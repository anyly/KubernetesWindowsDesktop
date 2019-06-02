$LocalImages = "$PSScriptRoot/../images"
$CommandResult = docker images
if ($CommandResult.Length -lt 2) {
	Write-Host 'No Images To Save!'
	exit 0
}
for ($i = 1; $i -lt $CommandResult.Length; $i++) {
	$Line = $CommandResult[$i]
	$Data = $Line -Split ' +'
	$ImagesRepository = "$($Data[0]):$($Data[1])"
	$ImagesFileName = "$($ImagesRepository.Replace('/', '@').Replace(':', '~')).tar"
	docker save $ImagesRepository -o "$LocalImages\$ImagesFileName"
	Write-Host "Docker Save $ImagesRepository"
}
