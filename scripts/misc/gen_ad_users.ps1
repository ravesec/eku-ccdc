$userpasswd = "!Password123"
$password = ConvertTo-SecureString $userpasswd -AsPlainText -Force
$num_accounts = 1767
$user_ou_path = "ou=_USERS,$(([ADSI]`"").distinguishedName)"
$ErrorActionPreference = "SilentlyContinue"


foreach ($person in $(Get-Content ../../../config_files/users-1800.txt)) {
    $splitstr = $person.Split(" ")

    $first = $splitstr[0].toLower()
    $last = $splitstr[1].toLower()
    $num = $splitstr[2]

    $username = "$($first)_$($last)$($num)"

    Write-Host "Creating domain user account $($username) in $($user_ou_path)"

    New-ADUser -AccountPassword $password `
               -GivenName $first `
               -Surname $last `
               -DisplayName $username `
               -Name $username `
               -EmployeeID $username `
               -Description "ALLSAFE employee $($splitstr[0]) $($splitstr[1])" `
               -PasswordNeverExpires $true `
               -Path $user_ou_path `
               -Enabled $true
}