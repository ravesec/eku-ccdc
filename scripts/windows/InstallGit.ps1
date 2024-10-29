#Requires -Version 3.0

<#

.SYNOPSIS
This is a PowerShell script to install Git for Windows with installer-selected defaults and minimal user interaction
Git will install system-wide if:
    You are in a PowerShell instance that is running as Administrator
    You are running as a non-Administator but allow the installer access to the system via UAC
Git will install only for the current user if:
    You do not or cannot (due to permissions) allow the installer access to the system via UAC
RUN AT OWN RISK

.NOTES
Author: Logan Jackson
Date: 10/29/2024

.LINK
Github: https://github.com/c-u-r-s-e

#>

# Setting up the web client and TLS version
$webClient = (New-Object System.Net.WebClient)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# CHANGE ME TO NEWEST VERSION IF AVALIABLE (or don't, its up to you)
$installerHyperlink = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"

# Downloading the installer into the user's temp directory
try
{
    Write-Host "Downloading installer..."
    $webClient.DownloadFile($installerHyperlink, "$env:temp\Git-installer.exe")
}
catch
{
    Write-Error "Failed to download installer: $_"
    Exit 1
}

# Installing git with no user interaction and no restarts, then removing the installer
Write-Host "Installing git..."
try
{
    Start-Process -FilePath "$env:temp\Git-installer.exe" -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
}
catch
{
    Write-Error "Installation failed: $_"
    Remove-Item -ErrorAction SilentlyContinue "$env:temp\Git-installer.exe" -Force
    Exit 1
}

Remove-Item -ErrorAction SilentlyContinue "$env:temp\Git-installer.exe" -Force

# Initializing variables to check the git installation
$userSpecific = $false
$systemWide = $false
$systemWidex86 = $false
$noPathNoLocation = $false

# Check where the install has placed itself
if (Test-Path "$env:USERPROFILE\AppData\Local\Programs\Git")
{
    $userSpecific = $true
    Write-Host "Git has been installed as user-specific"
} 
elseif (Test-Path "$env:ProgramFiles\Git")
{
    $systemWide = $true
    Write-Host "Git has been installed system-wide"
}
elseif (Test-Path "$(${env:ProgramFiles(x86)})\Git")
{
    $systemWidex86 = $true
    Write-Host "Git has been installed system-wide (x86)"
}
else
{
    Write-Host "Could not locate where Git was installed"
}

# Test if git is in the path
$ErrorActionPreference = "SilentlyContinue"
git --version > $null

if ($?)
{
    Write-Host "Git is in the `$PATH"
}
else
{
    Write-Warning "Git is not in the `$PATH"
    if ($userSpecific)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:PATH + ";$env:USERPROFILE\AppData\Local\Programs\Git\cmd", [System.EnvironmentVariableTarget]::User)
    }
    elseif ($systemWide)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:PATH + ";$env:ProgramFiles\Git\cmd", [System.EnvironmentVariableTarget]::Machine)
    }
    elseif ($systemWidex86)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:PATH + ";$(${env:ProgramFiles(x86)})\Git\cmd", [System.EnvironmentVariableTarget]::Machine)
    }
    else
    {
        $noPathNoLocation = $true
    }
    if ($PATH -ilike "*git*")
    {
        Write-Host "Sucessfully added Git to path"
        Write-Warning "Note: must restart PowerShell instance due to manual add"
    }
    else
    {
        Write-Host "Git was not successfully added to path"
    }
}

# Achievement Get: "How Did We Get Here?"
if ($noPathNoLocation)
{
    Write-Warning "Either git installed in an unnatural location, or the installation failed and was not caught"
    Exit 1
}

# At this point, git has been fully installed
Write-Host "Successfully installed $(git --version)"

# Configure name and email
$configConfirm = Read-Host "Would you like to configure your global username and email? (Y/N)"
if ($configConfirm -ilike "Y*")
{
    $name = Read-Host "Enter your username"
    if ($null -ne $name)
    {
        git config --global user.name $name
        Write-Host "Git username configured to: $name"
    }
    $email = Read-Host "Enter your email"
    if ($null -ne $email)
    {
        git config --global user.email $email
        Write-Host "Git email configured to: $email"
    }
}