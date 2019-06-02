param(
[string]$Mode='Local'
)

$CacheDir = "$PSScriptRoot/cache"
if (!(Test-Path $CacheDir)) {
	mkdir $CacheDir | Out-Null
}

#Wait For Docker Deamon Ready
try {
	for (;;) {
		$DockerInfo=docker info
		if ($DockerInfo) {
			Clear-Host
			Write-Host "=====================Docker Information===================="
			$DockerInfo
			break
		}
		Write-Host ""
		if (!(Get-Process -Name 'Docker for Windows')) {
			Write-Host "Docker Startup Failed, Please Run Yourself!" -f red
			Write-Host "$Error[0].Exception.Message" -f red
			exit 1
		}
		sleep -s 2
	}
} catch {
	Write-Host "Docker Startup Failed, Please Run Yourself!" -f red
	Write-Host "$Error[0].Exception.Message" -f red
	exit 1
}

$KubernetesSetupDir = "$CacheDir/k8s-for-docker-desktop"
$VERSION = "$PSScriptRoot/VERSION"
#Download Kubernetes For Docker Desktop
Write-Host "=====================Kubernetes For Docker Desktop===================="
if (!(Test-Path $KubernetesSetupDir)) {
	
	$DockerVersion = docker --version
	$DockerVersion = $DockerVersion.Split(',')[0].Split(' ')[-1]
	$DockerBigVersion = [int]($DockerVersion.Split('.')[0]);
	$KubernetesBranch = 'master'
	if ($DockerBigVersion -lt 19) {
		$KubernetesBranch = 'v2.0.0.2'
	}
	
	try {
		git clone https://github.com/AliyunContainerService/k8s-for-docker-desktop $KubernetesSetupDir -b $KubernetesBranch
		
	} catch {
		Write-Host "Kubernetes For Docker Desktop Download Error!" -f red
		Write-Host "$Error[0].Exception.Message" -f red
		exit 1
	}
	Write-Host "Kubernetes For Docker Desktop Download completed!"
	#Write Version
	try {
		$VersionObject = Get-Content -Path "$VERSION" | ConvertFrom-Json
	} catch {
		$VersionObject = @{}
	}
	$VersionObject.'Docker' = $DockerVersion
	$VersionObject.'Kubernetes Desktop' = $KubernetesBranch
	$VersionObject | ConvertTo-Json | Out-File "$VERSION"
	Unlock-File $VERSION
}

#Load Kubernetes Images
. "$PSScriptRoot/load_images.ps1"

if ($Mode -eq 'Remote') {
	Remove-Item $KubernetesSetupDir -Recurse -Force -ErrorAction "SilentlyContinue"
}
