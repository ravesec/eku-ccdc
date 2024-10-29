$webClient = (New-Object System.Net.WebClient)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$webClient.DownloadFile("https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe","$env:USERPROFILE\Downloads")
Set-Location "$env:USERPROFILE\Downloads"
Start-Process Git-2.47.0.2-64-bit.exe /VERYSILENT /NORESTART -Wait
Remove-Item "Git-2.47.0.2-64-bit.exe"
$name = Read-Host "Enter your username:"
if($null -ne $name)
{
    git config --global user.name $name
}
$email = Read-Host "Enter your email:"
if($null -ne $email)
{
    git config --global user.email $email
}