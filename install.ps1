param(
[string]$Mode='Local'
)
"Installation From $Mode."
. "$PSScriptRoot/InstallDocker.ps1" -Mode $Mode
. "$PSScriptRoot/InstallKubernetes.ps1" -Mode $Mode

