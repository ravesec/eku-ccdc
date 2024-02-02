#Requires -RunAsAdministrator
# Author: Logan Jackson
# Resources: https://gist.github.com/mackwage

if((Get-WmiObject Win32_OperatingSystem).Caption -notlike "*Server*")
{
    Write-Host "Incorrect operating system, exiting."
    Exit 1
}
if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -lt "379893")
{
    Write-Host ".NET Framework is not 4.5.2 or above, exiting."
    Exit 1
}
if($PSVersionTable.PSVersion.Major -lt "5" -and $PSVersionTable.PSVersion.Minor -lt "1")
{
    Write-Host "Powershell is not 5.1 or above, exiting."
    Exit 1
}

$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n========Windows Server Hardening========"

DO
{
    Write-Host "`n---Main Menu---"
    Write-Host "1. First Run"
    Write-Host "2. Firewall"
    Write-Host "3. Active Directory"
    Write-Host "4. Updates"
    Write-Host "5. General Security"
    Write-Host "6. Exit"

    $userInput = Read-Host "`nYour selection"

    switch($userInput)
    {
        "1"
        {
            Write-Host "General Windows Hardening will now commence..."
            Read-Host "(ENTER to start or CTRL+C to cancel)"
            # Disable RDP
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
            
            # Disable DNS Multicast
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f

            # Disable parallel A and AAAA DNS queries
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v DisableParallelAandAAAA /t REG_DWORD /d 1 /f
            
            # Disable SMBv1
            reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f

            # Enables UAC and Virtualization
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableVirtualization /t REG_DWORD /d 1 /f
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f
            
            # Enable Safe DLL search mode and protection mode to prevent hijacking
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v SafeDLLSearchMode /t REG_DWORD /d 1 /f
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 1 /f

            # Enlarging Windows Event Security Log Size
            wevtutil sl Security /ms:1024000
            wevtutil sl Application /ms:1024000
            wevtutil sl System /ms:1024000
            wevtutil sl "Windows Powershell" /ms:1024000
            wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:1024000

            # Record command line data in process creation events eventid 4688
            reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
            
            # Enabled Advanced Settings
            reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f
            
            # Enable PowerShell Logging
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
            reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
            
            # Enable Windows Event Detailed Loggin
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
        }
        "2" 
            {
                DO
                {
                    Write-Host "`n---Firewall---"
                    Write-Host "1. Enable Firewall"
                    Write-Host "2. Disable Firewall"
                    Write-Host "3. Lockdown/Block all incoming traffic"
                    Write-Host "4. Disable Lockdown"
                    Write-Host "5. Main menu"
                    $firewallchoice = Read-Host "`nYour selection"
                    switch($firewallchoice)
                    {
                        "1"
                        {
                            $windows10ip = Read-Host "Enter the IP for Windows 10"
                            $docker2016ip = Read-Host "Enter the IP for Docker 2016"
                            $debian10ip = Read-Host "Enter the IP for Debian 10"
                            $ubuntu18ip = Read-Host "Enter the IP for Ubuntu 18"
                            $ubuntuwkstip = Read-Host "Enter the IP for Ubtuntu Wkst"
                            $splunk9ip = Read-Host "Enter the IP for Splunk"
                            $centos7ip = Read-Host "Enter the IP for CentOS 7"
                            $fedora21ip = Read-Host "Enter the IP for Fedora 21"
                        }
                        "2"
                        {

                        }
                        "3"
                        {
                            Write-Host "Locking down..."
                            if(Get-NetFirewallRule -DisplayName "Lockdown" -ErrorAction SilentlyContinue)
                            {
                                Set-NetFirewallRule -DisplayName "Lockdown" -Enabled True
                            }
                            else
                            {
                                New-NetFirewallRule -DisplayName "Lockdown" -LocalPort * -Direction Inbound -Action Block -Enabled True
                            }
                            [console]::beep(1000,500); [console]::beep(750,500); [console]::beep(1000,500); [console]::beep(750,500)
                        }
                        "4"
                        {
                            if(Get-NetFirewallRule -DisplayName "Lockdown" -ErrorAction SilentlyContinue)
                            {
                                Set-NetFirewallRule -DisplayName "Lockdown" -Enabled False
                                Write-Host "All done"
                            }
                            else
                            {
                                Write-Host "Could not find Lockdown firewall rule"
                            }
                        }
                        "5"
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
                    Write-Host "`n---Active Directory---"
                    Write-Host "1. Change default password for all users"
                    Write-Host "2. Deprivilege all users besides current administrator"
                    Write-Host "3. Main menu"
                    $adchoice = Read-Host "`nYour selection"
                    switch($adchoice)
                    {
                        "1"
                        {
                            Write-Host "`nChange default passwords"
                        }
                        "2"
                        {
                            
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
                    Write-Host "`n---Updates---"
                    Write-Host "1. Brute force updating"
                    Write-Host "2. Turn on automatic download of updates"
                    Write-Host "3. Main menu"
                    $updatechoice = Read-Host "`nYour selection"
                    switch($updatechoice)
                    {
                        "1"
                        {
                            Write-Host "`n---Manual updating through a CSV list---"
                            $webClient = New-Object System.Net.WebClient
                            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                            mkdir $env:temp\updates\ -ErrorAction SilentlyContinue | Out-Null
                            Write-Host "`nWarning: ensure CSV list has headers 'Hyperlinks' and 'UpdateName' and consists of updates for the correct OS"
                            $csvList = Read-Host "`nEnter the literal path for CSV list filled of hyperlinks. (C:\...\...)"
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
                            if($restart -ieq "y")
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

                        }
                        "3"
                        {
                            Break
                        }
                        default
                        {
                            Write-Host "Invalid choice."
                        }
                    }
                } while ($updatechoice -ne "3")
            }

        "5" 
            {
                DO
                {
                    Write-Host "`n---General Security---"
                    write-Host "1. Restart Services"
                    Write-Host "2. Sysinternals"
                    Write-Host "3. Logon Banner"
                    Write-Host "4. Main menu"
                    $gschoice = Read-Host "`nYour selection"
                    switch($gschoice)
                    {
                        "1"
                        {
                            Write-Host "Restarting services..."
                        }
                        "2"
                        {
                            Write-Host "Sysinternals"
                        }
                        "3"
                        {

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
                } while ($gschoice -ne "4")
            }

        "6"
            {
                Write-Host "`nGoodbye"
                Break
            }

        default
            {
                Write-Host "Invalid choice."
            }
    }
} while ($userInput -ne "6")