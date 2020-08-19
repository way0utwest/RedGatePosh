###################################################################
#
# Set up Provision variables for machines and paths
# Set up default names
#
###################################################################
$ProvisionMachine = "dkrSpectre"
$ProvisionURL = "http://" + $ProvisionMachine + ":14145/"
$ProvisionInstance = "SQL2017"
$ImagePath = 'C:\SQLCloneImages'
$ImageDate = (get-date).ToString('yyyyMMdd')
$ImageBaseName = 'SimpleTalk_Base'
$ImageName = 'SimpleTalk_Base_New'
$SourceDatabase = 'SimpleTalk_5_Prod'
$ImageOldName = 'SimpleTalk_Dev_Base_Old'
$dir = Get-Location
$MaskingScript = $dir.tostring() + '\' + 'SimpleTalk_Prod_Mask.DMSMaskSet' 
$InjectScriptPath = $dir.tostring() + '\' + 'inject_st_contact.sql'
$Mask = New-SqlCloneMask -Path $MaskingScript
$InjectScript = New-SqlCloneSqlScript -Path $InjectScriptPath

###########################################################
# Provision Connection
###########################################################
Connect-SqlClone -ServerUrl $ProvisionURL

###########################################################
# Set proper Instance, path, and masking sets.
###########################################################
$SqlServerInstance = Get-SqlCloneSqlServerInstance -MachineName $ProvisionMachine -InstanceName $ProvisionInstance
$ImageDestination = Get-SqlCloneImageLocation -Path $ImagePath

###########################################################
#create masked image
###########################################################
$ImageOperation = New-SqlCloneImage -Name $ImageName -SqlServerInstance $SqlServerInstance -DatabaseName $SourceDatabase -Destination $ImageDestination -Modifications @($Mask, $InjectScript)

Wait-SqlCloneOperation -Operation $ImageOperation

###########################################################
# rename images
#
# Move old clones to current
# Remove old image
# Rename current to old
# Rename new image to current
###########################################################
$ImageToRemove = Get-SqlCloneImage | Where-Object {$_.Name -eq $ImageOldName}
If ($null -ne $ImageToRemove) {
  $NewImageHandle = Get-SqlCloneImage -Name $ImageName
  $oldClones = Get-SqlClone | Where-Object {$_.ParentImageId -eq $ImageToRemove.Id}
  foreach ($clone in $oldClones)
  {
    $thisDestination = Get-SqlCloneSqlServerInstance | Where-Object {$_.Id -eq $clone.LocationId}
    Remove-SqlClone $clone | Wait-SqlCloneOperation
    "Removed clone ""{0}"" from instance ""{1}"" " -f $clone.Name , $thisDestination.Server + '\' + $thisDestination.Instance;   
    New-SqlClone -Name $clone.Name -Location $thisDestination -Image $NewImageHandle | Wait-SqlCloneOperation
    "Added clone ""{0}"" to instance ""{1}"" " -f $clone.Name , $thisDestination.Server + '\' + $thisDestination.Instance;   
}
  Remove-SqlCloneImage -Image $ImageToRemove | Wait-SqlCloneOperation 
}

$ImageToRename = Get-SqlCloneImage | Where-Object {$_.Name -eq $ImageBaseName}
If ($null -ne $ImageToRename) {
  Rename-SqlCloneImage -Image $ImageToRename -NewName $ImageOldName | Wait-SqlCloneOperation 
}
$ImageToRename = Get-SqlCloneImage -Name $ImageName
Rename-SqlCloneImage -Image $ImageToRename -NewName $ImageBaseName