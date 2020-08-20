# Build script for SCA projects
param( $OverrideVersion="3.0")
# Instance variables
#    BuildInstance - SQL Server instance name for building 
$BuildInstance = "Aristotle"

# Database Variables
#    BuildDB - existing database used for build connection. Won't be altered
$BuildDB = "builddb"

# Package Variables
#    PackageID - Set the nuget package name to be used
#    PackageVersion - suffix on nuget package id.
$PackageID = "SimpleTalkDB"
$PackageVersion = $OverrideVersion

# Path variables
#   ProjectFile - full local path to the SCA project file (.sqlproj)
#   BuildArtifactPath - Path where the Nuget package is stored
$ProjectFile = "E:\Documents\git\SimpleTalkDemo\SimpleTalkDB\SimpleTalkDB.sqlproj"
$BuildArtifactPath = "E:\buildartifacts"

# Debug
# Use Continue to get more output
$DebugPreference = "SilentlyContinue"

# Setup database connections using variables from above to the build instance
$BuildConnection = New-DatabaseConnection -ServerInstance $BuildInstance -Database $BuildDB

# Build the database with a validate
$ValidProject = Invoke-DatabaseBuild $ProjectFile -TemporaryDatabaseServer $BuildConnection 

# Get the artifact and write to disk. Note the name comes from the package vars above.
$buildArtifact = New-DatabaseBuildArtifact $ValidProject -packageId $PackageID -PackageVersion $PackageVersion

Export-DatabaseBuildArtifact $buildArtifact -Path $BuildArtifactPath
