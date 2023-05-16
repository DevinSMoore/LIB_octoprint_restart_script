# Programmer: Devin Moore
# Description: This script is meant to restart the octopi server so that it automatically connects to the 3d-printer connected to the PC			    

Add-Type -AssemblyName PresentationFramework # Allows use of messageBox

# The following mess of variables are defining the paths to the necessary cura files in /<USER>/AppData/Roaming which contain the API key to cura, and information about the printer
$cura_executable_path = 'C:\Program Files (x86)\cura-lulzbot 3.6\cura-lulzbot.exe'

# $env:USERNAME will get us the username of the currently logged in PC
$settings_cura_path = 'C:\Users\' + $env:USERNAME + '\AppData\Roaming\cura'
$settings_cura_lulzbot_path = 'C:\Users\' + $env:USERNAME + '\AppData\Roaming\cura-lulzbot'

# This will grab the drive that the USB is on so we can copy files from it
# This is not dynamic, and will not function if multiple drives are inserted.
$usb_drive = gwmi win32_diskdrive | ?{$_.interfacetype -eq "USB"} | %{gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($_.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"} |  %{gwmi -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($_.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"} | %{$_.deviceid}
$usb_drive_path_cura = $usb_drive + '\support_files\roaming\cura'
$usb_drive_path_cura_lulzbot = $usb_drive + '\support_files\roaming\cura-lulzbot'

# Completely remove any old versions then copy in the desired files if the file already exists
$path_test = Test-Path $settings_cura_path

if ( $path_test )
{
    Remove-Item -Path $settings_cura_path -Recurse
    Remove-Item -Path $settings_cura_lulzbot_path -Recurse
}

Copy-Item -Path $usb_drive_path_cura -Destination $settings_cura_path -Recurse
Copy-Item -Path $usb_drive_path_cura_lulzbot -Destination $settings_cura_lulzbot_path -Recurse

# This will send an API request to the server to restart the server. we would do SSH but would have to expose information we don't want
$PrintServerURL = <URL WAS HERE>  # Octoprint IP or DNS

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("X-Api-Key", <API KEY WAS DROPPED PLEASE HELP>) # Octoprint API key

$Body= New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
Invoke-RestMethod -uri "$PrintServerURL/api/system/commands/core/restart" -Headers $headers -Method POST -Body $body

# Start alex's website here

# Starts up Cura after sending restart request
Start-Process $cura_executable_path
     								 