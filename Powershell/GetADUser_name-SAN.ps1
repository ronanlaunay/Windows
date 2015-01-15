Import-Module ActiveDirectory
Get-ADUser -searchbase "OU=Service Role Accounts,OU=Company,OU=All Company,DC=DS,DC=COMPANY,DC=COM" -Filter * | sort $_.name | FT name,samaccountname
