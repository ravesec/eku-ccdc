# This script is made specfically for Windows Server 2012 due to version-specfic packages of .NET and WMF
# Author: Logan Jackson

$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "You must run this script as an administrator."
    Exit 1
}

Write-Host "`n--Updating .NET Framework and Windows Management Framework--"

if($env:updatedWithoutRestart -or $env:updatedThisSession)
{
    $runAgain = Read-Host "`nYou have already updated without restart, are you sure you want to run again? (y/N)"
    if($runAgain -ine "y")
    {
        Exit 1
    }
}

Read-Host "`nNote: this script is built for Windows Server 2012 only. (ENTER)"

if((Get-WmiObject Win32_OperatingSystem).Caption -notlike "*2012*")
{
    Write-Host "Incorrect operating system."
    Exit 1
}

$update = $false
mkdir $env:temp\updater\ -ErrorAction SilentlyContinue | Out-Null
$webClient = New-Object System.Net.WebClient
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

if((Get-ItemProperty -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release -ge "379893")
{
    Write-Host ".NET Framework is up-to-date"
}
else 
{
    $update = $true
    Write-Host "Updating .NET to 4.5.2...`n"
    Write-Host "`tDownloading .NET updater..."
    $webClient.DownloadFile("https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe", "$env:temp\updater\net-updater.exe")
    Write-Host "`tRunning .NET updater..."
    Start-Process -FilePath "$env:temp\updater\net-updater.exe" -ArgumentList "/quiet","/norestart" -Wait
    Write-Host "`tDone!"
    $webClient.Dispose()
    $env:updatedThisSession = $true
    Invoke-Expression "Setx updatedWithoutRestart $true | Out-Null"
}

if($PSVersionTable.PSVersion.Major -ge "5" -and $PSVersionTable.PSVersion.Minor -ge "1")
{
    Write-Host "`nWMF is up-to-date"
}
else
{
    $update = $true
    $env:PSModulePath | Out-File -FilePath "$env:temp\updater\PSModulePath.txt"
    Write-Host "`nUpdating WMF to 5.1...`n"
    Write-Host "`tDownloading WMF updater..."
    $webClient.DownloadFile("https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/updt/2017/03/windows8-rt-kb3191565-x64_b346e79d308af9105de0f5842d462d4f9dbc7f5a.msu", "$env:temp\updater\wmf-updater.msu")
    Write-Host "`tRunning WMF updater..."
    Start-Process -FilePath "$env:temp\updater\wmf-updater.msu" -ArgumentList "/quiet","/norestart" -Wait
    $env:PSModulePath = Get-Content -Path "C:\PSModulePath.txt"
    Write-Host "`tDone!"
    $webClient.Dispose()
    $env:updatedThisSession = $true
    Invoke-Expression "Setx updatedWithoutRestart $true | Out-Null"
}

$webClient = $null

if($update)
{
    [System.Console]::Clear()
    $restart = Read-Host "`nNecessary updates complete. Restart now? (y/N)"
    if($restart -ieq "y")
    {
        Invoke-Expression "reg delete HKCU\Environment /v updatedWithoutRestart /f | Out-Null"
        $env:updatedThisSession = $null
        Restart-Computer
    }
    else
    {
        Write-Host "Note: restart is required for updates to take effect."
    }
}

Write-Host ""