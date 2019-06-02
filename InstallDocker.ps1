param(
[string]$Mode='Local'
)

$CacheDir = "$PSScriptRoot/cache"
if (!(Test-Path $CacheDir)) {
	mkdir $CacheDir | Out-Null
}

#Check Docker For windows Status
$DockerHome = "${env:ProgramFiles}/Docker/Docker"
if (!(Test-Path $DockerHome)) {
	
	$DockerInstaller = "$CacheDir/Docker for Windows Installer.exe"
	
	#Download Docker For windows-installer.exe
	if (!(Test-Path $DockerInstaller)) {
		try {
			[System.Net.ServicePointManager]::SecurityProtocol=[System.Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -OutFile "$DockerInstaller" -URI https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe
			Unblock-File "$DockerInstaller"
		} catch {
			Write-Host "Docker for Windows Installer.exe Download Error!" -f red
			Write-Host "$Error[0].Exception.Message" -f red
			exit 1
		}
	}
	Write-Host "Docker for Windows Installer.exe Download completed!"
	#Install Docker For windows-installer.exe
	Start-Process -Wait -FilePath $DockerInstaller
	
	if (!(Test-Path $DockerHome)) {
		Write-Host "Docker for Windows Installer.exe Installation cancelled!" -f red
		exit 1
	}
	
	#Remove DockerInstaller File
	if ($Mode -eq 'Remote') {
		Remove-Item $DockerInstaller -Force -ErrorAction "SilentlyContinue"
	}
	
	#Registry Mirrors Cinfigure
	$DotDocker = '~/.docker'
	if (!(Test-Path $DotDocker)) {
		mkdir -p $DotDocker | Out-Null
		Copy-Item "$PSScriptRoot/config/*" $DotDocker
	} else {
		try {
			$DaemonFile = "~/.docker/daemon.json"
			$DaemonJson = Get-Content -Path $DaemonFile -ErrorAction "SilentlyContinue" | ConvertFrom-Json
			$DaemonJson.'registry-mirrors' += "https://registry.docker-cn.com"
			$DaemonJson.'experimental' = $true
			$DaemonJson | ConvertTo-Json | Out-File $DaemonFile
			Unlock-File $DaemonFile
		} catch {
		}
	}
	
	#Env Setting
	try {
		docker version
	} catch {
		$PathVariable = "${env:ProgramData}\DockerDesktop\version-bin;$DockerHome\Resources\bin"
		${env:Path} = "${env:Path};$PathVariable"
	}
	
}

#Run Docker
if (!(Get-Process -Name 'Docker for Windows' -ErrorAction "SilentlyContinue")) {
	try {
		. "$DockerHome/Docker for Windows.exe"
	} finally {
		if (!(Get-Process -Name 'Docker for Windows' -ErrorAction "SilentlyContinue")) {
			Write-Host "Docker Startup Failed, Please Run Yourself!" -f red
			Write-Host "$Error[0].Exception.Message" -f red
			exit 1
		}
	}
}