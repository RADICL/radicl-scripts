[CmdletBinding()]
Param(
	[string]$Server = "vcenter.radicl.uidaho.edu",
	[string]$Cluster = "RADICL Red",
	
	[Parameter(Mandatory=$True)]
	[string]$Template,
	
	[string]$Datastore = "Working Storage",
	[string]$Parent,
	
	[Parameter(Mandatory=$True)]
	[string]$Location,
	
	[string]$NetName = "RADICL Main LAN",
	[string]$VmName = $("DNI-" + $Template + "-"),

	[Parameter(Mandatory=$True)]
	[int]$VmCount,

	[switch]$Confirm,
	[switch]$ConnectServer
)

if($ConnectServer) {
	Connect-VIServer -Server $Server
}

# Turn off confirmations?
if(-Not($Confirm)) {
	$ConfirmPreference = "none"
}

# Set Parameters to vSphere Objects
$VmCluster = Get-Cluster -Name $Cluster
$VmTemplate = Get-Template -Name $Template
$VmDatastore = Get-Datastore -Name $Datastore
$VmPort = $NetName
$VmDiskType = "Thin"

# Get Folder
if($Parent) {
	$ParentFolder = Get-Folder -Name $Parent
	$VmLoc = Get-Folder -Location $($ParentFolder) -Name $Location 
} else {
	$VmLoc = Get-Folder -Name $Location
}

for ($i = 0; $i -lt $VmCount; $i++) {
	#$VmLoc = Get-Folder -Location $($ParentFolder) -Name $($Location + $i.ToString("00"))
	$NewVm = New-VM -Name $($VmName + $i.ToString("00")) `
		-Template $VmTemplate `
		-ResourcePool $VmCluster `
		-Datastore $VmDatastore `
		-DiskStorageFormat $VmDiskType `
		-Location $VmLoc
	$NetAd = Get-NetworkAdapter -VM $NewVm
	$VmPortName = Get-VDPortgroup -Name $($VmPort + $i.ToString("00"))
	Set-NetworkAdapter -NetworkAdapter $NetAd[0] -Portgroup $VmPortName
}

if($ConnectServer) {
	Disconnect-VIServer -Server $Server
}