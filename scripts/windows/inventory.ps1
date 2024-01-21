$ErrorActionPreference = "SilentlyContinue"

$ipv6 = Read-Host "LETS GET READY TO RUMBLEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE`nAre you all using IPv6? (y/N)" 
if($ipv6 -inotlike "y*")
{
    $ipv6 = $false
    $blockipv6 = Read-Host "Do you want to go ahead and block all IPv6? (Y/n)"
    if($blockipv6 -ilike "n*")
    {
        Write-Host "Alright, suit yourself then"
    }
    else
    {
        Invoke-Expression reg add hklm\system\currentcontrolset\services\tcpip6\parameters /v DisabledComponents /t REG_DWORD /d 0xFF
        Invoke-Expression netsh interface teredo set state disabled
        Invoke-Expression netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
        Invoke-Expression netsh interface ipv6 isatap set state state=disabled
    }
}
else
{
    $ipv6 = $true
}

$path = Read-Host "Where do you want this file stored? (default is $pwd\, DO NOT append file name)"

try
{
    if(!(Test-Path $path))
    {
        Write-Host "Path not found, resorting to default"
        $path = $pwd
    }
}
catch
{
    $path = $pwd
}

Write-Host "Loading inventory..."

Invoke-Command -ScriptBlock {
    Write-Output "`n<!-- Inventory --!>"
    Write-Output "`n--Operating System Information--`n"
    Write-Output "`tOS: $((Get-WmiObject Win32_OperatingSystem).Caption)`n"
    Write-Output "`tOS Version: $((Get-WmiObject Win32_OperatingSystem).Version)`n"
    Write-Output "`tWMF Version: $($PSVersionTable.PSVersion)`n"

    $netframeworks = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name Version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, Version
    Write-Output "`t.NET Framework Verisons:"

    foreach($netframework in $netframeworks){
        Write-Output "`t`t$($netframework.PSChildName): $($netframework.Version)"
    }

    Write-Output "`n--Interface Information--"
    $interfaces = Get-NetAdapter

    foreach($interface in $interfaces){
        Write-Output "`n`tInterface $($interface.Name)"
        if($interface.Status -ne 'Disabled'){
            Write-Output "`t`tIP Address(es): $((Get-NetIPAddress -InterfaceAlias $interface.Name).IPAddress)"
        } else {
            Write-Output "`t`tThis interface is in a disabled state."
        }
        Write-Output "`t`tEthernet Address: $($interface.MacAddress)"
    }

    Write-Output "`n--Port Information--`n"
    
    if($ipv6)
    {
        $tcpconnections =  Get-NetTCPConnection | Where-Object { $_.State -eq 'Listen' } | Sort-Object LocalPort, LocalAddress
        $udpconnections = Get-NetUDPEndpoint | Where-Object { $_.LocalPort -lt '49152' } | Sort-Object LocalPort, LocalAddress
        $udpephermeral = Get-NetUDPEndpoint | Where-Object { $_.LocalPort -ge '49152' } | Sort-Object LocalPort, LocalAddress
    }
    else
    {
        $tcpconnections =  Get-NetTCPConnection | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.State -eq 'Listen' } | Sort-Object LocalPort, LocalAddress
        $udpconnections = Get-NetUDPEndpoint | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.LocalPort -lt '49152' } | Sort-Object LocalPort, LocalAddress
        $udpephermeral = Get-NetUDPEndpoint | Where-Object { $_.LocalAddress -notlike '*:*' -and $_.LocalPort -ge '49152' } | Sort-Object LocalPort, LocalAddress
    }

    foreach($tcpconnection in $tcpconnections) {
        $process = Get-Process -Id $tcpconnection.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            LocalAddress = $tcpconnection.LocalAddress
            LocalPort = $tcpconnection.LocalPort
            ProcessName = $process.Name
        }
    }
    
    Write-Output "^^^^^^^^^ TCP ^^^^^^^^^"

    foreach($udpconnection in $udpconnections) {
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
    Write-Output "`nEphermeral UDP ports open: $($udpephermeral.Count)`n"

    Write-Output "For a list of potential vulnerabilities, visit https://www.cvedetails.com."
    Write-Output "If searching via vendor, all Windows operating systems are under Microsoft."
    Write-Output "If searching via product, exclude the Windows edition (such as Standard or Home) when searching (i.e. search `"Windows Server 2012`").`n"
} | Out-File $path\inventory.txt -Encoding UTF8

Write-Host "Sucess, inventory saved in $path\inventory.txt"