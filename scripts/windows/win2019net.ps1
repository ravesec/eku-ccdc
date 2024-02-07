# This script will update compatible Windows machines to .NET 8.0 and Powershell 7.4
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

Read-Host "`nNote: this script will check for .NET 8.0 and Powershell 7.4 or higher and update if not up to date. (ENTER)"

$update = $false
mkdir $env:temp\updater\ -ErrorAction SilentlyContinue | Out-Null
$webClient = New-Object System.Net.WebClient
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

if((Invoke-Expression "dotnet.exe --list-runtimes" 2>$null) -like "*8.0*")
{
    Write-Host ".NET Framework is up-to-date"
}
else 
{
    $update = $true
    Write-Host "Updating .NET to 8.0...`n"
    Write-Host "`tDownloading .NET updater..."
    $webClient.DownloadFile("https://go.microsoft.com/fwlink/?LinkId=2203304", "$env:temp\updater\net-updater.exe")
    Write-Host "`tRunning .NET updater..."
    Start-Process -FilePath "$env:temp\updater\net-updater.exe" -ArgumentList "/quiet","/norestart" -Wait
    Write-Host "`tDone!"
    $env:updatedThisSession = $true
    Invoke-Expression "Setx updatedWithoutRestart $true | Out-Null"
}


if($PSVersionTable.PSVersion.Major -ge "7" -and $PSVersionTable.PSVersion.Minor -ge "4")
{
    Write-Host "`nWMF is up-to-date"
}
elseif(Test-Path "$env:ProgramFiles\Powershell\7")
{
    Write-Host "`nWMF is up-to-date, run pwsh.exe"
}
else
{
    $update = $true
    Write-Host "`nUpdating Powershell to 7.4...`n"
    Write-Host "`tBacking up PSModulePath to $env:temp\updater\..."
    $env:PSModulePath | Out-File -FilePath "$env:temp\updater\PSModulePath.txt"
    Write-Host "`tDownloading  updater..."
    $webClient.DownloadFile("https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.msi","$env:temp\updater\pwsh-updater.msi")
    Write-Host "`tRunning Powershell updater..."
    Start-Process "msiexec.exe" -ArgumentList "/package $env:temp\updater\pwsh-updater.msi","/quiet","/norestart","ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1","ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1","ENABLE_PSREMOTING=1","REGISTER_MANIFEST=1","USE_MU=1","ENABLE_MU=1 ADD_PATH=1" -Wait
    Write-Host "`tDone!"
    $env:updatedThisSession = $true
    Invoke-Expression "Setx updatedWithoutRestart $true | Out-Null"
}

$webClient.Dispose | Out-Null

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