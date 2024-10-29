#Requires -Version 3.0

# Setting up the web client and TLS version
$webClient = (New-Object System.Net.WebClient)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# CHANGE ME TO NEWEST VERSION IF AVALIABLE (or don't, its up to you)
$installerHyperlink = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"

# Downloading the installer into the user's temp directory
$webClient.DownloadFile($installerHyperlink,"$env:temp\Git-2.47.0.2-64-bit.exe")

# Installing git with no user interaction and no restarts, then removing the installer
Start-Process -FilePath "$env:temp\Git-2.47.0.2-64-bit.exe" -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
Remove-Item "$env:temp\Git-2.47.0.2-64-bit.exe"

# Initializing variables to check the git installation
$userSpecific = $false
$systemWide = $false
$systemWidex86 = $false
$noPathNoLocation = $false

# Check where the install has placed itself
if(Test-Path "$env:USERPROFILE\AppData\Local\Programs\Git")
{
    $userSpecific = $true
    Write-Host "Git has been installed as user-specific"
}
elseif(Test-Path "C:\Program Files\Git")
{
    $systemWide = $true
    Write-Host "Git has been installed system-wide"
}
elseif(Test-Path "C:\Program Files (x86)\Git")
{
    $systemWidex86 = $true
    Write-Host "Git has been installed system-wide (x86)"
}
else
{
    Write-Host "Could not locate where Git was installed"
}

# Test if git is in the path
git --version

if($?)
{
    Write-Host "Git is in the `$PATH"
}
else
{
    if($userSpecific)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\AppData\Local\Programs\Git\cmd", [System.EnvironmentVariableTarget]::User)
    }
    elseif($systemWide)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\cmd", [System.EnvironmentVariableTarget]::Machine)
    }
    elseif($systemWidex86)
    {
        Write-Host "Adding Git to `$PATH..."
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\Git\cmd", [System.EnvironmentVariableTarget]::Machine)
    }
    else
    {
        $noPathNoLocation = $true
        Write-Warning "Git could not be located and is not in the `$PATH"
    }
}

if($noPathNoLocation)
{
    Write-Host "I have no idea what happened"
}
else
{
    $configConfirm = "Would you like to configure your global username and email? (Y/N)"
    if($configConfirm -ilike "Y*")
    {
        $name = Read-Host "Enter your username"
        if($null -ne $name)
        {
            git config --global user.name $name
        }
        $email = Read-Host "Enter your email"
        if($null -ne $email)
        {
            git config --global user.email $email
        }
    }
}