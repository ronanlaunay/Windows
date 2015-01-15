Import-Module ActiveDirectory
Get-ADUser -searchbase "OU=Service Role Accounts,OU=WolseleyFrance,OU=WOS Operating Companies,DC=DS,DC=WOLSELEY,DC=COM" -Filter * | sort $_.name | FT name,samaccountname
