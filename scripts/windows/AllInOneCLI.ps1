#Requires -Version 3.0

<#
.SYNOPSIS
This is a general Windows Hardening tool created for EKUCCDC purposes.
Requires PS 3.0 and Administrator rights.

.DESCRIPTION
The features of this tool include:
    -.NET version checking / updating
        -Checks for 4.8.x+
    -WMF/Powershell version checking / updating
        -Checks for 5.1+, optionally can install 7
    -OS hardening
    -Firewall management
        -Firewall toggle
        -MWCCDC firewall setup
    -Active Directory management
        -Generate random users
        -Generate random passwords for all users
        -Remove all groups from users besides current administrator
    -Windows update management
        -Ability to install updates from .csv list
        -Turn on automatic updating
    -General security management
        -Installation of sysinternals
        -Installation of Bluespawn
        -Setting logon banner
        -Setting logoff timer
    -Taking inventory of current services / versions

.PARAMETER Force
Disables .NET and WMF version checking.

.INPUTS
None.

.OUTPUTS
None directly, however a directory is created inside of the root directory of the homedrive.
Within this, temporary files will be stored (such as updates), and logs will be created to track the changes made to the system.

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
https://gist.github.com/mackwage

.LINK
Github: https://github.com/c-u-r-s-e
#>

param (
    [switch]$Force
)

# Powershell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "You must run this script as an administrator."
    Exit 1
}

if($Force.IsPresent)
{
    $env:updatedThisSession = $false
    reg delete HKCU\Environment /v updatedWithoutRestart /f | Out-Null
} 
elseif($env:updatedWithoutRestart -or $env:updatedThisSession)
{
    Write-Warning "You have updated without restart! Updates must take effect before rerunning script."
    Write-Host "If you have restarted and this is a false positive, rerun this script with -Force."
    Exit 1
}

# Creating a log file to note changes made to the system
mkdir -ErrorAction SilentlyContinue $env:HOMEDRIVE\WindowsHardeningCLI | Out-Null
mkdir -ErrorAction SilentlyContinue $env:HOMEDRIVE\WindowsHardeningCLI\Logs | Out-Null
$i = 1
while(Test-Path $env:HOMEDRIVE\WindowsHardeningCLI\Logs\log.$i.txt)
{
    $i++
}
Write-Host "`nEstablishing a log file at $env:HOMEDRIVE\WindowsHardeningCLI\Logs\log.$i.txt"
Out-File $env:HOMEDRIVE\WindowsHardeningCLI\Logs\log.$i.txt
$logFile = "$env:HOMEDRIVE\WindowsHardeningCLI\Logs\log.$i.txt"

# Write-Log Function to write logs to $logFile
function Write-Log {
    param (
        [string]$message
    )

    $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss K"

    Write-Output "$currentTime - $message" | Out-File $logFile -Append
}

# For downloads and such
$webClient = New-Object System.Net.WebClient
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Write-Log "Script started!"

if(!$Force.IsPresent)
{
    # Checking for .NET Frameworks older than 4.8, latest .NET compatible for Windows 2012 and up
    $outdatedNet = $false
    switch -Wildcard ((Get-WmiObject Win32_OperatingSystem).Caption)
    {
        "*2012 R2*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "528049")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2085155"
                }
            }
        "*2012*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "528049")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2085155"
                }
            }
        "*2016*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "528049")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2085155"
                }
            }
        "*2019*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "528049")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2085155"
                }
            }
        "*2022*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "533325")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2203304"
                }
            }
        "*10*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "533325")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2203304"
                }
            }
        "*11*"
            {
                if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "533320")
                {
                    $outdatedNet = $true
                    $netUpdateLink = "https://go.microsoft.com/fwlink/?LinkId=2203304"
                }
            }
        default
            {
                Write-Warning "Could not detect compatible Windows Version, and therefore .NET version.`nThis script has only been tested on Windows Server 2012/Windows 10 and later, and .NET 4.8 and later."
                Write-Host "If you would like to run this script anyway (not recommended), rerun with -Force."
                Exit 1
            }
    }

    if($outdatedNet)
    {
        Write-Log "Outdated .NET Framework detected"
        Write-Warning ".NET Framework is not 4.8 or above!"
        $updateNet = Read-Host "Would you like to update now? (Y/n)"

        if($updateNet -ilike "n*")
        {
            Write-Warning "Script requires .NET 4.8+, exiting..."
            Write-Host "If you would like to run this script anyway (not recommended), rerun with -Force."
            Write-Log "Script requires .NET 4.8+, exiting..."
            Exit 1
        }

        $update = $true
        Write-Host "Updating .NET to 4.8...`n"
        Write-Host "Downloading .NET updater..."
        $webClient.DownloadFile("$netUpdateLink", "$env:HOMEDRIVE\WindowsHardeningCLI\net-updater.exe")
        Write-Host "Running .NET updater..."
        Start-Process -FilePath "$env:HOMEDRIVE\WindowsHardeningCLI\net-updater.exe" -ArgumentList "/quiet","/norestart" -Wait
        Write-Host "Done!"
        $env:updatedThisSession = $true
        Invoke-Expression "Setx updatedWithoutRestart $true | Out-Null"
        Write-Log ".NET was updated"
    }
    else
    {
        Write-Host ".NET is up-to-date, 4.8+"
    }

    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL

    if($PSVersionTable.PSVersion.Major -ge "7" -and $PSVersionTable.PSVersion.Minor -ge "4")
    {
        Write-Host "WMF is up-to-date, 7.4.x"
    }
    elseif($PSVersionTable.PSVersion.Major -ge "5" -and $PSVersionTable.PSVersion.Minor -ge "1")
    {
        Write-Host "WMF is up-to-date, 5.1.x"
        if(!(Test-Path "$env:ProgramFiles\Powershell\7"))
        {
            $updateWmf = Read-Host "Would you like to optionally install 7.4.1? (Y/n)"
            if($updateWmf -ilike "n*")
            {
                Write-Host "No problemo"
                $updateWmf = $false
            }
            else
            {
                $updateWmf = $true
                $wmfLink = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi"
            }
        }
    }
    else
    {
        Write-Warning "Powershell is not up-to-date!"
        $updateWmf = Read-Host "Would you like to update now to 5.1? (Y/n)"
        if($updateWmf -ilike "n*")
        {
            Write-Warning "Powershell 5.1 and later is required for this script!"
            Write-Host "If you would like to run this script anyway (not recommended), rerun with -Force."
            Exit 1
        }
        else
        {
            $updateWmf = $true
            $wmfLink = ""
        }
    }

    if($updateWmf)
    {

    }
    
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL
    ## UNFINISHED SCRIPT TO UPDATE POWERSHELL

    if($update)
    {
        $restart = Read-Host "`nNecessary updates complete. Restart now? (y/N)"
        if($restart -ilike "y*")
        {
            reg delete HKCU\Environment /v updatedWithoutRestart /f
            $env:updatedThisSession = $null
            Restart-Computer
        }
        else
        {
            Write-Warning "Restart is required for updates to take effect."
            Exit 1
        }
    }
}

# Initializing $try and $catch so that later can determine how program is exited
$try=$false
$catch=$false

# Checking if machine is server, and if so what services running on it
$serverOS = ((Get-WmiObject Win32_OperatingSystem).Caption -ilike "*Server*")
$activeDirectoryRunning = ((Get-Service -ErrorAction SilentlyContinue -Name NTDS).Status -eq "Running")
$dnsRunning = ((Get-Service -ErrorAction SilentlyContinue -Name DNS).Status -eq "Running")
$dhcpRunning = ((Get-Service -ErrorAction SilentlyContinue -Name DHCP).Status -eq "Running")

if($serverOS)
{
    Write-Host "Server Operating System was found"
}
if($activeDirectoryRunning)
{
    Write-Host "Active Directory Service is running"
}
if($dnsRunning)
{
    Write-Host "DNS is running"
}
if($dhcpRunning)
{
    Write-Host "DHCP is running"
}

try {
    $ErrorActionPreference = "SilentlyContinue"

    Write-Host "`n========Windows Hardening========"

    DO
    {
        Write-Host "`n---Main Menu---"
        Write-Host "1. Scripted Changes"
        Write-Host "2. Firewall"
        if($activeDirectoryRunning)
        {
            Write-Host "3. Active Directory"
        }
        else
        {
            Write-Host -ForegroundColor Red "3. Active Directory (X)"  
        }
        Write-Host "4. Updates"
        Write-Host "5. General Security"
        Write-Host "6. Inventory"
        Write-Host "7. Exit"

        $userInput = Read-Host "`nYour selection"

        switch($userInput)
        {
            "1"
                {
                    Write-Host "General Windows Hardening will now commence..."
                    Write-Warning "This will make several modifications to your HKLM registry hive and default Windows settings`nIt is strongly recommended you review these before proceeding, and comment out those unnecessary or potentially harmful."
                    Write-Host "A backup of your HKLM will be stored in $env:HOMEDRIVE\WindowsHardeningCLI\RegistryBackups."
                    Read-Host "(ENTER to start or CTRL+C to cancel)"

                    Write-Log "General Windows hardening begins!"
                    
                    Write-Log "Attempting to establish a registry backup..."
                    mkdir -ErrorAction SilentlyContinue $env:HOMEDRIVE\WindowsHardeningCLI\RegistryBackups | Out-Null
                    $curTime = Get-Date -Format "yyyyMMdd_HHmmss"
                    $regFile = "$env:HOMEDRIVE\WindowsHardeningCLI\RegistryBackups\backup_$curTime.reg"
                    $continueHardening = $false

                    reg export HKLM $regFile /y | Out-Null
                    
                    if($LASTEXITCODE -eq "0")
                    {
                        Write-Host "HKLM registry sucessfully backed up at $regFile"
                        Write-Log "HKLM registry successfully backed up at $regFile"
                        $continueHardening = $true
                    }
                    else
                    {
                        Write-Warning "HKLM backup failed!"
                        $confirmHardening = Read-Host "Continue without a backup? (Not recommended) (y/N):"
                        if($confirmHardening -ilike "y*")
                        {
                            $continueHardening = $true
                        }
                    }

                    if(!$continueHardening)
                    {
                        Break
                    }

                    #### MAKE CHANGES BELOW IF NECESSARY ####
                    #### MAKE CHANGES BELOW IF NECESSARY ####
                    #### MAKE CHANGES BELOW IF NECESSARY ####

                    # Disable RDP
                    Write-Log "Disabling RDP..." 
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f

                    # Disable DNS Multicast
                    Write-Log "Disabling DNS Multicast..."
                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f

                    # Disable parallel A and AAAA DNS queries
                    Write-Log "Disabling parallel A and AAAA DNS queries..."
                    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v DisableParallelAandAAAA /t REG_DWORD /d 1 /f

                    # Disable SMBv1
                    Write-Log "Disabling SMBv1..."
                    reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f

                    # Enables UAC and Virtualization
                    Write-Log "Enabling UAC and Virtualization..."
                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableVirtualization /t REG_DWORD /d 1 /f
                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f

                    # Enable Safe DLL search mode and protection mode to prevent hijacking
                    Write-Log "Enabling Safe DLL search mode and protection mode..."
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v SafeDLLSearchMode /t REG_DWORD /d 1 /f
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 1 /f

                    # Enlarging Windows Event Security Log Size
                    Write-Log "Increaing the size of Windows Event Security Log..."
                    wevtutil sl Security /ms:1024000
                    wevtutil sl Application /ms:1024000
                    wevtutil sl System /ms:1024000
                    wevtutil sl "Windows Powershell" /ms:1024000
                    wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:1024000

                    # Record command line data in process creation events eventid 4688
                    Write-Log "Enabling auditing of command line data in process creations events (ID 4688)..."
                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

                    # Prevents the application of category-level audit policy from Group Policy and from the Local Security Policy administrative tool
                    Write-Log "Preventing the application of category-level audit policy from Group Policy and from the Local Security Policy administrative tool"
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f

                    # Enable PowerShell Logging
                    Write-Log "Enabling Powershell logging..."
                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f

                    # Enable Windows Event Detailed Login
                    Write-Log "Enabling Windows Event Detailed Logins..."
                    AuditPol /set /subcategory:"Security Group Management" /success:enable /failure:enable
                    AuditPol /set /subcategory:"Process Creation" /success:enable /failure:enable
                    AuditPol /set /subcategory:"Logoff" /success:enable /failure:disable
                    AuditPol /set /subcategory:"Logon" /success:enable /failure:enable 
                    AuditPol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:disable
                    AuditPol /set /subcategory:"Removable Storage" /success:enable /failure:enable
                    AuditPol /set /subcategory:"SAM" /success:disable /failure:disable
                    AuditPol /set /subcategory:"Filtering Platform Policy Change" /success:disable /failure:disable
                    AuditPol /set /subcategory:"IPsec Driver" /success:enable /failure:enable
                    AuditPol /set /subcategory:"Security State Change" /success:enable /failure:enable
                    AuditPol /set /subcategory:"Security System Extension" /success:enable /failure:enable
                    AuditPol /set /subcategory:"System Integrity" /success:enable /failure:enable

                    # Stop Remote Registry
                    Write-Log "Attempting to stop remote registry..."
                    net stop RemoteRegistry -Force

                    # Flush dns
                    Write-Log "Flushing DNS..."
                    ipconfig /flushdns

                    # Harden Lsass
                    Write-Log "Hardening LSASS..."
                    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
                    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" /v AllowProtectedCreds /t REG_DWORD /d 1 /f
                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" /v AllowDigest /t REG_DWORD /d 0 /f

                    # Stop WinRM
                    Write-Log "Attempting to stop Remote Management..."
                    net stop WinRM -Force

                    # Disable Guest user
                    Write-Log "Disabling the Guest user account..."
                    net user Guest /active:NO 2>$null

                    # Set some common ransomware filetypes to default to notepad
                    Write-Log "Setting .hta, .wsh, .wsf, .bat, .js, .jse, .vbe, .vbs files to default to notepad.exe..."
                    ftype htafile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype wshfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype wsffile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype batfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype jsfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype jsefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype vbefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
                    ftype vbsfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"

                    # Encrypt/Sign outgoing secure channel traffic when possible
                    Write-Log "Signing outgoing secure channel traffic when possible..."
                    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SealSecureChannel /t REG_DWORD /d 1 /f
                    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SignSecureChannel /t REG_DWORD /d 1 /f

                    #### MAKE CHANGES ABOVE IF NECESSARY ####
                    #### MAKE CHANGES ABOVE IF NECESSARY ####
                    #### MAKE CHANGES ABOVE IF NECESSARY ####

                    Write-Log "General Windows Hardening ends!"
                }
            "2" 
                {
                    DO
                    {
                        Write-Host -ForegroundColor Red "`n---Firewall---"
                        Write-Host "1. Enable Firewall"
                        Write-Host "2. Disable Firewall"
                        Write-Host "3. MWCCDC Firewall Setup"
                        Write-Host "4. Main menu"
                        $firewallchoice = Read-Host "`nYour selection"
                        switch($firewallchoice)
                        {
                            "1"
                                {
                                    Write-Warning "This will enable the firewall on all profiles with default/already established rules."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    Write-Log "Firewall enabled on all profiles with default/already established rules"
                                    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
                                }
                            "2"
                                {
                                    Write-Warning "This will disable the firewall on all profiles."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    Write-Log "Firewall disabled on all profiles"
                                    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
                                }
                            "3"
                                {
                                    Write-Warning "This will setup firewall rules allowing necessary traffic in accordance with the 2024 MWCCDC Topology."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    ## UNFINISHED FIREWALL SETUP
                                    ## UNFINISHED FIREWALL SETUP
                                    ## UNFINISHED FIREWALL SETUP
                                    Write-Log "Firewall setup for 2024 MWCCDC begins!"

                                    Write-Log "Firewall setup for 2024 MWCCDC ends!"
                                    ## UNFINISHED FIREWALL SETUP
                                    ## UNFINISHED FIREWALL SETUP
                                    ## UNFINISHED FIREWALL SETUP
                                }
                            "4"
                                {
                                    Break
                                }
                            default
                                {
                                    Write-Host "`nInvalid choice."
                                }
                        }
                    } while ($firewallchoice -ne "4")
                }
            "3" 
                {
                    DO
                    {
                        if(!$activeDirectoryRunning)
                        {
                            Write-Host -ForegroundColor Red "Active Directory service was not found!"
                            Break
                        }

                        Write-Host -ForegroundColor Blue "`n---Active Directory---"
                        Write-Host "1. Scramble default password for all users"
                        Write-Host "2. Deprivilege all users besides current administrator"
                        Write-Host "3. Main menu"
                        $adchoice = Read-Host "`nYour selection"
                        switch($adchoice)
                        {
                            "1"
                                {
                                    Write-Host "`n---Change All Default Passwords---"
                                    Write-Warning "This generates new passwords for all users in this Active Directory and outputs them into a .csv"
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }
                                }
                            "2"
                                {
                                    Write-Warning "This will remove *ALL* groups and privileges that *ALL* users (besides this current Admin!) on the AD Domain belong to, reducing them all to `"Domain Users`""
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    $currentAdmin = $env:USERNAME
                                    $users = Get-ADUser -Filter {SamAccountName -ne $currentAdmin}

                                    # Iterate through each user and remove all privileges
                                    foreach ($user in $users)
                                    {
                                        # Check if the user is a member of any groups and remove them
                                        $userGroups = Get-ADUser $user.SamAccountName | Get-ADPrincipalGroupMembership | Where-Object { $_.SamAccountName -ne "Domain Users" }
                                        foreach ($group in $userGroups)
                                        {
                                            Remove-ADGroupMember -Identity $group.SamAccountName -Members $user.SamAccountName -Confirm:$false
                                        } 
                                        # Remove any direct user privileges
                                        $user | Remove-ADUser -RemoveOtherAttributes -Confirm:$false
                                    }

                                    Write-Host "`nPrivileges have been removed for all users except $currentAdmin."

                                }
                            "3"
                                {
                                    Break
                                }
                            default
                                {
                                    Write-Host "`nInvalid choice"
                                }
                        }
                    } while ($adchoice -ne "3")
                }

            "4" 
                {
                    DO
                    {
                        Write-Host -ForegroundColor Green "`n---Updates---"
                        Write-Host "1. Update via .csv"
                        Write-Host "2. Turn on automatic download of updates"
                        Write-Host "3. Attempt to fix Windows Updater if not finding updates"
                        Write-Host "4. Main menu"
                        $updatechoice = Read-Host "`nYour selection"
                        switch($updatechoice)
                        {
                            "1"
                                {
                                    Write-Host "`n---Manual updating through a CSV list---"
                                    Write-Warning "This will attempt to update via a CSV file consisting of hyperlinks to the Microsoft Update Catalog"
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    mkdir $env:temp\updates\ -ErrorAction SilentlyContinue | Out-Null
                                    Write-Host "`nEnsure CSV list has headers 'Hyperlinks' and 'UpdateName' and consists of updates for the correct OS"
                                    $csvList = Read-Host "`nEnter the literal path for CSV list filled of hyperlinks. (I.E. $env:HOMEDRIVE\...\...)"
                                    if(![System.IO.File]::Exists($csvList))
                                    {
                                        Write-Host "`nIncorrect format or path does not exist"
                                        Break
                                    }
                                    if([System.IO.Path]::GetExtension($csvList) -ne ".csv")
                                    {
                                        Write-Host "`nIncorrect file type"
                                        Break
                                    }
                                    $priorityChoice = Read-Host "`nEnter (1) for only security updates, (2) for only quality updates, or (3) for both"
                                    switch($priorityChoice)
                                    {
                                        "1"
                                            {
                                                $updateHyperlinks = Import-Csv -LiteralPath "$csvList" | Where-Object {$_.Hyperlinks -like "*/secu/*"}
                                            }
                                        "2"
                                            {
                                                $updateHyperlinks = Import-Csv -LiteralPath "$csvList" | Where-Object {$_.Hyperlinks -like "*/updt/*"}
                                            }
                                        "3"
                                            {
                                                $updateHyperlinks = Import-Csv -LiteralPath "$csvList"
                                            }
                                        default
                                            {
                                                Write-Host "Invalid choice"
                                                Break
                                            }
                                    }
                                    foreach($link in $updateHyperlinks)
                                    {
                                        Write-Host "`nDownloading $($link.UpdateName)..."
                                        $webClient.DownloadFile($link.Hyperlinks,"$env:temp\updates\$($link.UpdateName).msu")
                                        Write-Host "Installing $($link.UpdateName)..."
                                        Start-Process -FilePath "$env:temp\updates\$($link.UpdateName).msu" -ArgumentList "/quiet","/norestart" -Wait
                                    }
                                    $webClient.Dispose()
                                    [System.Console]::Clear()
                                    $restart = Read-Host "`nUpdates from CSV complete. Restart now? (y/N)"
                                    if($restart -ilike "y*")
                                    {
                                        Restart-Computer
                                    }
                                    else
                                    {
                                        Write-Host "Note: restart is required for updates to take effect."
                                    }
                                }
                            "2"
                                {
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }
                                    Write-Host "Setting Windows Automatic Updates"
                                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 3 /f
                                }
                            "3"
                                {
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }
                                    Write-Host "Attempting to fix Windows Updater Service..."
                                    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 1 /f
                                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\" /v DODownloadMode /t REG_DWORD /d 1 /f
                                    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
                                    reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
                                    reg add "HKLM\SYSTEM\Internet Communication Management\Internet Communication" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
                                    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWindowsUpdate /t REG_DWORD /d 0 /f
                                }
                            "4"
                                {
                                    Break
                                }
                            default
                                {
                                    Write-Host "Invalid choice."
                                }
                        }
                    } while ($updatechoice -ne "4")
                }

            "5" 
                {
                    DO
                    {
                        Write-Host -ForegroundColor Magenta "`n---General Security---"
                        write-Host "1. Restart Services"
                        Write-Host "2. Sysinternals"
                        Write-Host "3. Logon Banner"
                        Write-Host "4. Bluespawn"
                        Write-Host "5. Set Logout Timer"
                        Write-Host "6. Main Menu"
                        $gschoice = Read-Host "`nYour selection"
                        switch($gschoice)
                        {
                            "1"
                            {
                                Write-Warning "This will attempt to restart the DNS, DHCP, and NTFS services found on this computer."
                                $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                if ($warning -inotlike "y*")
                                {
                                    Break
                                }
                                
                                Write-Host "Restarting services..."
                                if(Get-Service | Where-Object {$_.Name -eq "DNS"})
                                {
                                    Restart-Service DNS -Force
                                }
                                else
                                {
                                    Write-Host "DNS service could not be found!"
                                }
                                if(Get-Service | Where-Object {$_.Name -eq "NTFS"})
                                {
                                    Restart-Service NTFS -Force
                                }
                                else
                                {
                                    Write-Host "NTFS service could not be found!"
                                }
                                if(Get-Service | Where-Object {$_.Name -eq "DHCPServer"})
                                {
                                    Restart-Service DHCPServer -Force
                                }
                                else
                                {
                                    Write-Host "DHCPServer service could not be found!"
                                }
                            }
                            "2"
                                {
                                    Write-Warning "This will attempt to install the Sysinternals Suite to $env:HOMEDRIVE\Sysinternals."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    Write-Host "Sysinternals"
                                    if(Test-Path $env:HOMEDRIVE\Windows\SysInternalsSuite)
                                    {
                                        $switchdirSysinternals = Read-Host "Sysinternals installed at $env:HOMEDRIVE\Windows\Sysinternals. Switch directories now? (y/N)"
                                        if($switchdirSysinternals -like "y*")
                                        {
                                            Set-Location "$env:HOMEDRIVE\Windows\Sysinternals"
                                            Break
                                        }
                                    }
                                    elseif(Test-Path $env:HOMEDRIVE\Windows\SysInternalsSuite.zip)
                                    {
                                        $confirmSysUnzip = Read-Host "Unzip Sysinterals?"
                                        if($confirmSysUnzip -ilike "y*")
                                        {
                                            Expand-Archive -Path $env:HOMEDRIVE\Windows\SysInternalsSuite -DestinationPath $env:HOMEDRIVE\Windows\SysInternalsSuite -Force
                                        }
                                    }
                                    else
                                    {
                                        $confirmSysinternals = Read-Host "Sysinternals Suite is not detected, install now?"
                                        if($confirmSysinternals -ilike "y*")
                                        {
                                            Write-Host "Installing sysinternals..."
                                            $webClient.DownloadFile("https://download.sysinternals.com/files/SysinternalsSuite.zip","$env:HOMEDRIVE\Windows\SysInternalsSuite.zip") | Wait-Event
                                        }
                                    }
                                }
                            "3"
                                {
                                    Write-Warning "This will set up a notice of the terms of use of using this resource at logon."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    Write-Host "Would you like to..."
                                    Write-Host "1. Write your own policy"
                                    Write-Host "2. Use our generic terms of use"
                                    $termsChoice = Read-Host "Your selection"
                                    switch($termsChoice)
                                    {
                                        "1"
                                        {
                                            $legalNoticeCaption = Read-Host "What would you like the heading to state?"
                                            $legalNoticeText = Read-Host "What would you like the text to state?"
                                            Write-Host "Setting logon banner..."
                                            reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /t REG_SZ /d "$legalNoticeCaption"
                                            reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /t REG_SZ /d "$legalNoticeText"
                                        }
                                        "2"
                                        {
                                            $domainName = Read-Host "What is the name of the domain that you would like to use?"
                                            Write-Host "Setting logon banner..."
                                            reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /t REG_SZ /d "IMPORANT NOTICE:"
                                            reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /t REG_SZ /d "By accessing this network resource, you consent to monitoring of your activities and understand $domainName may exercise its rights under the law to access, use, and disclose any information obtained from your use of this resource."
                                        }
                                        default
                                        {
                                            Write-Host "Invalid selection"
                                            Break
                                        }
                                    }
                                }
                            "4"
                                {
                                    Write-Warning "This will attempt to download Bluespawn client to current user's Downloads folder."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    if(Test-Path $env:HOMEPATH\Downloads\BLUESPAWN-client-x64.exe)
                                    {
                                        Write-Host "BLUESPAWN already installed at $env:HOMEPATH\Downloads\BLUESPAWN-client-x64.exe"
                                        Write-Host "Launch this tool from the CLI"
                                    }
                                    else
                                    {
                                        Write-Host "Downloading Bluespawn..."
                                        $webClient.DownloadFile("https://github.com/ION28/BLUESPAWN/releases/download/v0.5.1-alpha/BLUESPAWN-client-x64.exe","$env:HOMEPATH\Downloads\BLUESPAWN-client-x64.exe") | Wait-Event
                                    }
                                }
                            "5"
                                {
                                    Write-Warning "This will set an inactivity timeout to the amount of seconds specified by you."
                                    $warning = Read-Host "Are you sure you want to continue? (y/N)"
                                    if ($warning -inotlike "y*")
                                    {
                                        Break
                                    }

                                    $secondsLogout = Read-Host "How many seconds of inactivity before session logout?"
                                    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d $secondsLogout /f
                                }
                            "6"
                                {
                                    Break
                                }
                            default
                                {
                                    Write-Host "Invalid choice."
                                }
                        }
                    } while ($gschoice -ne "6")
                }
            "6"
                {
                    Write-Log "Inventory script started..." 

                    mkdir -ErrorAction SilentlyContinue $env:HOMEDRIVE\WindowsHardeningCLI\Inventory | Out-Null

                    $ipv6 = Read-Host "Are you all using IPv6? (y/N)" 
                    $ipv6 = $ipv6 -ilike "y*"

                    Write-Log "Inventory being stored in $env:HOMEDRIVE\WindowsHardeningCLI\Inventory\inventory.$i.txt" 

                    Write-Host "Loading inventory..."

                    Invoke-Command -ScriptBlock {
                        Write-Output "`n<!-- Inventory --!>"
                        Write-Output "`n--Operating System Information--`n"
                        $osInfo = Get-CimInstance Win32_OperatingSystem
                        Write-Output "`tOS: $($osInfo.Caption)`n"
                        Write-Output "`tOS Version: $($osInfo.Version)`n"
                        Write-Output "`tWMF Version: $($PSVersionTable.PSVersion)`n"
                    
                        $netframeworks = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, Version
                        Write-Output "`t.NET Framework Verisons:"
                    
                        foreach($netframework in $netframeworks)
                        {
                            Write-Output "`t`t$($netframework.PSChildName): $($netframework.Version)"
                        }
                    
                        Write-Output "`n--Interface Information--"
                        $interfaces = Get-NetAdapter
                    
                        foreach($interface in $interfaces)
                        {
                            Write-Output "`n`tInterface $($interface.Name)"
                            if($interface.Status -ne 'Disabled')
                            {
                                Write-Output "`t`tIP Address(es): $((Get-NetIPAddress -InterfaceAlias $interface.Name).IPAddress)"
                            } else
                            {
                                Write-Output "`t`tThis interface is in a disabled state."
                            }
                            Write-Output "`t`tEthernet Address: $($interface.MacAddress)"
                        }
                    
                        Write-Output "`n--Port Information--`n"

                        if($ipv6)
                        {
                            $tcpconnections =  Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' } | Sort-Object LocalPort, LocalAddress
                            $udpconnections = Get-NetUDPEndpoint | Where-Object { $_.LocalPort -lt '49152' } | Sort-Object LocalPort, LocalAddress
                            $udpephemeral  = Get-NetUDPEndpoint | Where-Object { $_.LocalPort -ge '49152' } | Sort-Object LocalPort, LocalAddress
                        }
                        else
                        {
                            $tcpconnections =  Get-NetTCPConnection | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.State -eq 'Listen' } | Sort-Object LocalPort, LocalAddress
                            $udpconnections = Get-NetUDPEndpoint | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.LocalPort -lt '49152' } | Sort-Object LocalPort, LocalAddress
                            $udpephemeral  = Get-NetUDPEndpoint | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.LocalPort -ge '49152' } | Sort-Object LocalPort, LocalAddress
                        }
                    
                        foreach($tcpconnection in $tcpconnections)
                        {
                            $process = Get-Process -Id $tcpconnection.OwningProcess -ErrorAction SilentlyContinue
                            [PSCustomObject]@{
                                LocalAddress = $tcpconnection.LocalAddress
                                LocalPort = $tcpconnection.LocalPort
                                ProcessName = $process.Name
                            }
                        }

                        Write-Output "^^^^^^^^^ TCP ^^^^^^^^^"
                    
                        foreach($udpconnection in $udpconnections)
                        {
                            $process = Get-Process -Id $udpconnection.OwningProcess -ErrorAction SilentlyContinue
                            [PSCustomObject]@{
                                LocalAddress = $udpconnection.LocalAddress
                                LocalPort = $udpconnection.LocalPort
                                ProcessName = $process.Name
                            }
                        }
                    
                        Write-Output "^^^^^^^^^ UDP ^^^^^^^^^"
                    
                        $connections = $tcpconnections + $udpconnections
                        $portsopen = ($connections | Select-Object -Unique LocalPort).Count
                    
                        Write-Output "`nTotal unique open ports: $($portsopen)"
                        Write-Output "`nEphemeral  UDP ports open: $($udpephemeral.Count)`n"
                    
                        Write-Output "For a list of potential vulnerabilities, visit https://www.cvedetails.com."
                        Write-Output "If searching via vendor, all Windows operating systems are under Microsoft."
                        Write-Output "If searching via product, exclude the Windows edition (such as Standard or Home) when searching (i.e. search `"Windows Server 2012`").`n"
                    } | Out-File $env:HOMEDRIVE\WindowsHardeningCLI\Inventory\inventory.$i.txt -Encoding UTF8

                    Write-Host "Sucess, inventory saved in $env:HOMEDRIVE\WindowsHardeningCLI\Inventory\inventory.$i.txt"
                    Write-Log "Sucess, inventory saved in $env:HOMEDRIVE\WindowsHardeningCLI\Inventory\inventory.$i.txt" 
                }
            "7"
                {
                    Write-Host "`nGoodbye`n"
                    $try = $true
                    Break
                }

            default
                {
                    Write-Host "Invalid choice."
                }
        }
    } while ($userInput -ne "7")
}
catch
{
    $catch = $true
}
finally
{
    if($try)
    {
        Write-Log "The script was exited via main menu!"
    }
    elseif ($catch)
    {
        Write-Log "The script was closed via terminating error (potentially weird user input?)"
    }
    else
    {
        Write-Log "The script was forcibly exited (potentially Control+C)"    
    }
}