param(
[string]$Mode='Local'
)

$CacheDir = "$PSScriptRoot/cache"
if (!(Test-Path $CacheDir)) {
	mkdir $CacheDir | Out-Null
}

#region 强迫以管理员权限运行
$currentWi = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentWp = [Security.Principal.WindowsPrincipal]$currentWi
 
if( -not $currentWp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  $boundPara = ($MyInvocation.BoundParameters.Keys | foreach{
     '-{0} {1}' -f  $_ ,$MyInvocation.BoundParameters[$_]} ) -join ' '
  $currentFile = (Resolve-Path  $MyInvocation.InvocationName).Path
 
 $fullPara = $boundPara + ' ' + $args -join ' '
 Start-Process "$psHome\powershell.exe"   -ArgumentList "$currentFile $fullPara"   -verb runas
 return
}
#endregion


$KitematicHome = "${env:ProgramFiles}/Docker/Kitematic"
if (!(Test-Path $KitematicHome)) {

	$KitematicInstaller = "$CacheDir/Kitematic-Windows.zip"

	#Download Kitematic-Windows.zip
	if (!(Test-Path $KitematicInstaller)) {
		try {
			[System.Net.ServicePointManager]::SecurityProtocol=[System.Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -OutFile "$KitematicInstaller" -URI 'https://download.docker.com/kitematic/Kitematic-Windows.zip'
			Unblock-File "$KitematicInstaller"
		} catch {
			Write-Host "Kitematic-Windows.zip Download Error!" -f red
			Write-Host "$Error[0].Exception.Message" -f red
			exit 1
		}
	}
	Write-Host "Kitematic-Windows.zip Download completed!"
	
	#Expand-Archive Kitematic-Windows.zip
	Expand-Archive -Path $KitematicInstaller -DestinationPath $KitematicHome
	if ($Mode -eq 'Remote') {
		Remove-Item $KitematicInstaller -Force -ErrorAction "SilentlyContinue"
	}
	
}

. "$KitematicHome/Kitematic.exe"
