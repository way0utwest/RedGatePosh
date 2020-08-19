# SQL Change Automation Demo Scripts
These are the demo scripts available in this folder. Here are the demos, each of which has a section below:

- Build an SCA Project
- Build and Release an SCA Project

## Build an SCA Project - buildscadb.ps1
This script is designed to build database from an SQL Change Automation project. There is one parameter to pass in, which is the version of the nuget package. This overrides the default in the script.

This script needs to have a variables changed for your build instance, for the folder for the build artifact, the project file and path, the nuget package name, and a database for the connection. The database isn't used.

## Build and Release an SCA Project
This script is designed to take an SCA project and do the following:
- build it
- output a nuget package in a folder
- take the nuget package and product a release artifact
- write the release artifact into a separate folder
- deploy changes from the release artifact to an instance