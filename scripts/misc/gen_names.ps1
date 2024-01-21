$num_accounts = 250

Invoke-Generate '[person] [numeric]' -Count $num_accounts | Out-File "users-$($num_accounts).txt"