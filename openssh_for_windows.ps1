# ssh_for_windows PLEASE READ THE BELOW INFO !!
# Updated for 2021/2022. DO NOT USE THE ORIGINAL SCRIPT BELOW.
# Instead, recommended steps are as follows, per https://github.com/illudium/ssh_install_and_secure_config_for_windows
##### USE BELOW STEPS INSTEAD OF THE ORIGINAL SCRIPT FURTHER BELOW THIS SECTION #####
## Step 1 Required for some of the below to work. 
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2
#
## Step 2 
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
#
## Step 3 
# Install-Module WinSSH
#
## Step4 
# Import-Module WinSSH
#4 (allow the above to complete...) 
# Start-Sleep -s 10
#
## Step 5
# Install-WinSSH -GiveWinSSHBinariesPathPriority -ConfigureSSHDOnLocalHost $InstallWinSSHResult = Install-WinSSH -GiveWinSSHBinariesPathPriority -ConfigureSSHDOnLocalHost
#
## END. 
#
#
# ITEM BELOW IS OLD AND NOW OUTDATED, DO NOT USE :-)
#
# Please note that this is something of a quick-and-dirty script in terms of the basic powershell used.
# It is not meant to be exemplary coding, the focus on this was the resulting configuration and its security,
# the provided powershell script does **_NO_ERROR_CHECKING_** and is in fact quite rudimentary.
#
# REQUIREMENTS:
# You will need to have SSH already configured and operational client-side (on your workstation),
# and the content of your chosen & working ssh .pub keypair.
#
# For more info, please see https://www.ssh.com/ssh/public-key-authentication
# For the key type, ed25519 is recommended and supported with the version of OpenSSH server that will be installed.
#
# IMPORTANT: YOU MUST adjust (and or add to) the desired external IPs below in the # Adjust the built-in Windows firewall
# section, AND you must already have ssh installed and working, client-side (per above).
#
# CRITICAL: You must have an existing, available, local admin account on each Windows endpoint you want to connect to.
# It is fine and recommended in an AD environment that you manage any such accounts via LAPS,
# see https://www.microsoft.com/en-us/download/details.aspx?id=46899
# NOTE: The resulting setup will allow you to connect to the designated account WITHOUT needing to authenticate.
# It is incumbent on you - in fact URGENT that you use a properly maintained & secured workstation from which to connect.
# 
# Implementation per endpoint:
# How you implement this on existing Windows end-points is a matter of your own choosing, based on existing
# management tools and options :-)

Add-WindowsCapability –online –Name "OpenSSH.Server~~~~0.0.1.0"

Set-Service sshd -StartupType Automatic

Start-Service sshd

## Adjust the built-in Windows firewall rules
# MAKE SURE TO ADJUST THE "ips" section below, to allow you to connect from your predetermined,
# and appropriately configured, remote IP address(es).

Set-NetFirewallrule -Name "OpenSSH-Server-In-TCP" -Action Allow

$fwRule = Get-NetFirewallrule -Name "OpenSSH-Server-In-TCP"

# !!! ADJUST THESE !!! Modify accordingly for the desired remote IPs you want to permit to access the host in question.
$ips = @("192.168.123.7", "192.168.17.118", "192.168.0.117-192.168.0.118")

foreach($r in $fwRule) { Set-NetFirewallRule -Name $r.Name -RemoteAddress $ips }

## Setup ssh key-based authentication. 
# ADJUST AS NEEDED based on the account-name in question on your endpoints, "localadmin" here is a suggestion.
# You ALSO MUST of course, replace the item below 'Place the... (etc) with the content of your desired pub key portion of your ssh key.
# Ed25519 is recommended and works from macOS (Mojave, Catalina) to Windows. See https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54

mkdir 'C:\Users\localadmin\.ssh'
New-Item 'C:\Users\localadmin\.ssh\authorized_keys'
Set-Content C:\Users\localadmin\.ssh\authorized_keys 'Place the pre-retrieved content of your ssh PUBLIC keypair here'

### IMPORTANT, aka last but not least !
# To enable and restrict ssh connections to key-based authentication only, 
# we need to comment out the files in C:\ProgramData\ssh\sshd_config
# namely as follows:

# Match Group administrators                                                    
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
#
#and probably want to change to the following:
#PasswordAuthentication no
#
# SO, accomplishing this VIA powershell:

(gc C:\ProgramData\ssh\sshd_config) -replace "Match Group administrators", "# Match Group administrators" | sc C:\ProgramData\ssh\sshd_config

(gc C:\ProgramData\ssh\sshd_config) -replace "       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys", "#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys " | sc C:\ProgramData\ssh\sshd_config

(gc C:\ProgramData\ssh\sshd_config) -replace "PasswordAuthentication yes", "PasswordAuthentication no" | sc C:\ProgramData\ssh\sshd_config

# Covering both possibilities for thoroughness
(gc C:\ProgramData\ssh\sshd_config) -replace "#PasswordAuthentication no", "PasswordAuthentication no" | sc C:\ProgramData\ssh\sshd_config

## Restart sshd to implement the changes made
# 

Restart-Service sshd


