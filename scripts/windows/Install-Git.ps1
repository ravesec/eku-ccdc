#Requires -Version 3.0

<#

.SYNOPSIS
This is a PowerShell script to install the latest 64-bit Git for Windows with installer-selected defaults and minimal user interaction.

.DESCRIPTION
Git will install system-wide if:
    You are in a PowerShell instance that is running as Administrator
    You are running as a non-Administator but allow the installer access to the system via UAC
Git will install only for the current user if:
    You cannot (due to permissions) allow the installer access to the system via UAC
    You run this script with the `-UserInstall` parameter (it will still prompt for UAC if you have permission to elevate, select Yes)
Git will cancel the installation if:
    You have permission to allow the installer access to the system via UAC yet choose not to

Multiple installations of git may conflict, not every edge case has been tried
RUN AT OWN RISK

.EXAMPLE
iex "(& {$(irm https://raw.githubusercontent.com/ravesec/eku-ccdc/main/scripts/windows/Install-Git.ps1)})"

.EXAMPLE
iex "(& {$(irm https://raw.githubusercontent.com/ravesec/eku-ccdc/main/scripts/windows/Install-Git.ps1)} arg -UserInstall)"

.PARAMETER UserInstall
This changes the directory of the installation to the AppData\Local\Programs of the current user.
This in turn forces git to install user-specifically instead of system wide when the user has permission to allow it to.

.NOTES
Author: Logan Jackson
Date: 10/29/2024

.LINK
Github: https://github.com/lj-sec

#>

param(
    [switch]$UserInstall
)

# Function to exit script without closing the entire PowerShell instance before user has a chance to read what went wrong
function Exit-Script
{
    Read-Host "`nScript has terminated. Press (Enter) to exit"
    Exit 1
}

# Ensure the user wants to continue
$installConfirm = Read-Host "`nThis is a script to install the latest version of Git. Please read the description before continuing.`nDo you wish to continue? (Y/N)"
if ($installConfirm -inotlike "Y*")
{
    Exit-Script
}

# Fetching the latest git for windows 64-bit installer
$installerHyperlink = Invoke-RestMethod "https://api.github.com/repos/git-for-windows/git/releases/latest" | ForEach-Object assets | Where-Object browser_download_url -like "*64-bit.exe" | Select-Object -ExpandProperty browser_download_url

# Setting up the web client and TLS version
$webClient = (New-Object System.Net.WebClient)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Downloading the installer into the user's temp directory
try
{
    Write-Host "Downloading installer..."
    $webClient.DownloadFile($installerHyperlink, "$env:TEMP\Git-installer.exe")
}
catch
{
    Start-Sleep 2
    Clear-Host
    Write-Error "Failed to download installer: $($_)"
    Exit-Script
}

# Installing git with no user interaction and no restarts, then removing the installer
Write-Host "Installing git..."
try
{
    $installArgs = "/VERYSILENT", "/NORESTART"
    # Checking for user install script to modify install directory
    if ($UserInstall.IsPresent)
    {
        $installArgs += "/DIR=$env:USERPROFILE\AppData\Local\Programs\Git"
    }
    Start-Process -FilePath "$env:TEMP\Git-installer.exe" -ArgumentList $installArgs -Wait
}
catch
{
    Start-Sleep 2
    Clear-Host
    Write-Error "Installation failed: $($_)"
    Remove-Item -ErrorAction SilentlyContinue "$env:TEMP\Git-installer.exe" -Force
    Exit-Script
}

# Cleaning up after successful install
Remove-Item -ErrorAction SilentlyContinue "$env:TEMP\Git-installer.exe" -Force

# Initializing variables to check the git installation
$gitPath = ""
$envVarTarget = ""
$noPathNoLocation = $false

# Check the default locations to find where the install has placed itself
if (Test-Path "$env:ProgramFiles\Git")
{
    $gitPath = "$env:ProgramFiles\Git"
    $envVarTarget = [System.EnvironmentVariableTarget]::User
    Write-Host "Git has been installed system-wide"
}
elseif (Test-Path "$(${env:ProgramFiles(x86)})\Git")
{
    $gitPath = "$(${env:ProgramFiles(x86)})\Git"
    $envVarTarget = [System.EnvironmentVariableTarget]::Machine
    Write-Host "Git has been installed system-wide (x86)"
}
elseif (Test-Path "$env:USERPROFILE\AppData\Local\Programs\Git")
{
    $gitPath = "$env:USERPROFILE\AppData\Local\Programs\Git"
    $envVarTarget = [System.EnvironmentVariableTarget]::Machine
    Write-Host "Git has been installed as user-specific"
} 
else
{
    Write-Warning "Could not locate where Git was installed"
}

# Test if git is in the path
if ($env:PATH -ilike "*\Git\cmd*")
{
    # No further action needed
    Write-Host "Git is in the `$PATH"
}
else
{
    # Attempt to add git to the system path if installed in Program Files or user path if in AppData
    Write-Warning "Git is not in the `$PATH"
    if ($gitPath -ne "")
    {
        $ErrorActionPreference = 'Stop'
        Write-Host "Attempting to add Git to `$PATH..."
        try
        {
            [System.Environment]::SetEnvironmentVariable("Path", $env:PATH + ";$gitPath\cmd", $envVarTarget)
            Write-Host "Sucessfully added Git to path"
            Write-Warning "Note: must restart PowerShell instance due to manual add"
        }
        catch
        {
            Write-Warning "Git could not be added to path"
        }
        $ErrorActionPreference = 'SilentlyContinue'
    }
    else
    {
        # Git did not install in a normal location and did not add itself to the path
        $noPathNoLocation = $true
    }
}

# Achievement Get: "How Did We Get Here?"
if ($noPathNoLocation)
{
    Start-Sleep 2
    Clear-Host
    Write-Warning "Either git installed in an unnatural location without adding itself to `$PATH or the installation failed due to lack of UAC access and was not caught prior to here"
    Exit-Script
}

# At this point, git has been installed regardless if in path or not
Write-Host "`nSuccessfully installed $(& $gitPath\cmd\git.exe --version)"

# Configure name and email
$configConfirm = Read-Host "`nWould you like to configure your global user.name and user.email? This backs up and replaces your current .gitconfig if present (Y/N)"
if ($configConfirm -ilike "Y*")
{
    $gitConfigPath = "$env:USERPROFILE\.gitconfig"
    if(Test-Path $gitConfigPath)
    {
        try
        {
            Copy-Item -Path $gitConfigPath -Destination "$gitConfigPath.bak" -Force
            Write-Host "Backup of .gitconfig saved at $gitConfigPath.bak"            
        }
        catch
        {
            Start-Sleep 2
            Clear-Host
            Write-Warning "Failed to backup .gitconfig, exiting instead"
            Exit-Script
        }
    }
    $name = Read-Host "Enter your user.name"
    $email = Read-Host "Enter your user.email"
    Set-Content -Path $gitConfigPath -Value "[user]`n    name = $name`n    email = $email" -Force
}