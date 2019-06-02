#Wait For Kubernetes Startup
$CacheDir = "$PSScriptRoot/cache"
$KubernetesSetupDir = "$CacheDir/k8s-for-docker-desktop"
try {
	for (;;) {
		$KubectlGetNodes = kubectl get nodes
		if ($KubectlGetNodes.length -ge 2) {
			Clear-Host
			Write-Host "=====================Kubernetes Nodes===================="
			$KubectlGetNodes
			Write-Host "==========================================================="
			Write-Host ""
			break
		}
		Write-Host ""
		if (!(Get-Process -Name 'Docker for Windows')) {
			Write-Host "Kubernetes Startup Failed, Please Run Yourself!" -f red
			Write-Host "$Error[0].Exception.Message" -f red
			exit 1
		}
		sleep -s 2
	}
} catch {
	Write-Host "Kubernetes Startup Failed, Please Run Yourself!" -f red
	Write-Host "$Error[0].Exception.Message" -f red
	exit 1
}

#Startup Kubernetes Dashboard
if (!(netstat -ano | findstr ' 127.0.0.1:8001 ')) {
	#Start Kubectl Proxy As Backgound Daemon
	Start-Job -Name KubectlProxy -Scriptblock {
		Start-process kubectl -ArgumentList "proxy --address=127.0.0.1 --port=8001" -NoNewWindow
	}
	
	#Set Credentials For Kubernetes Client
	$TOKEN=((kubectl -n kube-system describe secret default | Select-String "token:") -split " +")[1]
	kubectl config set-credentials docker-for-desktop --token="${TOKEN}"
}


kubectl create -f ${KubernetesSetupDir}/kubernetes-dashboard.yaml

Start-Process -FilePath 'http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default'
