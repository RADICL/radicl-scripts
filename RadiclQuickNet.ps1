[CmdletBinding()]
Param(
	[string]$Server = "vcenter.radicl.uidaho.edu",

	[Parameter(Mandatory=$True)][string]$PgName,
	[Parameter(Mandatory=$True)][int]$PgCount,
	
	[string]$SwitchName = "Primary dvSwitch",
	[string]$PortBinding = "Static",

	[int]$StartingVlanID = 1000,
	[int]$WanPorts = 3,
	[int]$LanPorts = 64,

	[switch]$Confirm,
	[switch]$ConnectServer
)

# Map to vSphere Objects
$VDSwitch = Get-VDSwitch -Name $SwitchName

# Create base names and attach port counts to them
$Base = @(
	($($PgName + " WAN "),$WanPorts),
	($($PgName + " LAN "),$LanPorts)
)

ForEach ($B in $Base) {
	for ($i = 0; $i -lt $PgCount; $i++) {
		New-VDPortgroup `
			-VDSwitch $VDSwitch `
			-Name $($B[0] + $i.ToString("00")) `
			-NumPorts $B[1] `
			-VlanID $($StartingVlanId + $i) `
	}	
}
