# SQL Change Automation Build Script
#
# Be sure to change variables as needed for instances, paths, project files, etc.
#
#
# Parameters
#      0 - Version number
param( $OverrideVersion="3.2")

#  Instance variables
#    DevInstance - SQL Server instance for development
#    BuildInstance - SQL Server instance name for building 
#    TargetInstance - SQL Server instance for deployment/update
$DevInstance = "Aristotle"
$BuildInstance = "Aristotle"
$TargetInstance = "Aristotle"

# Database Variables
#    DevDB - database used for developing changes (mostly a placeholder for now)
#    BuildDB - existing database used for build connection. Won't be altered
#    TargetDB - deployment target for this script.
$DevDB = "SimpleTalk_1_Dev"
$BuildDB = "builddb"
$TargetDB = "test5"

# Package Variables
#    PackageID - Set the nuget package name to be used
$PackageID = "SimpleTalkDB"
$PackageVersion = $OverrideVersion

# Path variables
$ProjectFile = "E:\Documents\git\SimpleTalkDemo\SimpleTalkDB\SimpleTalkDB.sqlproj"
$BuildArtifactPath = "E:\buildartifacts"
$ReleaseArtifactPath = "E:\releaseartifacts"

# Debug
# Use Continue to get more output
$DebugPreference = "SilentlyContinue"

# Setup database connections
$DevConnection = New-DatabaseConnection -ServerInstance $DevInstance -Database $DevDB
$BuildConnection = New-DatabaseConnection -ServerInstance $BuildInstance -Database $BuildDB

# Build the database with a validate
$ValidProject = Invoke-DatabaseBuild $ProjectFile -TemporaryDatabaseServer $BuildConnection 

# Get the artifact and write to disk. Note the name comes from the package vars above.
$buildArtifact = New-DatabaseBuildArtifact $ValidProject -packageId $PackageID -PackageVersion $Version

Export-DatabaseBuildArtifact $buildArtifact -Path $BuildArtifactPath


# Setup prod connection for deployment
$ProdConnection = New-DatabaseConnection -ServerInstance $TargetInstance -Database $TargetDB

$NugetArtifact = $BuildArtifactPath + "\" +$PackageID + "." +$Version +".nupkg"

$dbRelease = New-DatabaseReleaseArtifact -Source $NugetArtifact -Target $ProdConnection

# save the release artifact
$ReleasePath = $ReleaseArtifactPath + "\" + $PackageID + "." + $Version + ".zip"

Export-DatabaseReleaseArtifact $dbRelease -Path $ReleasePath -Format Zip

Use-DatabaseReleaseArtifact $dbRelease -DeployTo $ProdConnection 
