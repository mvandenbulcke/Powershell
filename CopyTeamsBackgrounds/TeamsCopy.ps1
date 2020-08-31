# Name: TeamsCopy.ps1
# Usage: TeamsCopy.ps1
# Description: 
#	Makes a folder and copies the file from a network location to the Teams background folder to push corporate backgrounds to Microsoft Teams clients.
#

# Make the directory
mkdir -p C:\Users\$env:UserName\AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads

# Copy the files from source location to destination location
robocopy "\\SERVER\Backgrounds$\Backgrounds" "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Teams\Backgrounds\Uploads\"