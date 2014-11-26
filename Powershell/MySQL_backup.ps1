
######################################## Time info ########################################
$date = Get-Date
$timestamp = Get-Date -format yyyyMMdd-HHmmss

######################################## Database info ####################################
$tableDatabases = @("test1","test2","test3","test4","test5")
$database = 0

######################################## Connect info #####################################
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 5.5\bin\"
$backupPath = "C:\mysql_backup\dump\"
$errorPath = "C:\mysql_backup\error\"
$checkPath = "C:\mysql_backup\check\"
$username = "root"
$password = "password"
$hostname = "localhost"

######################################## Backup file info #################################
$checkLog = $checkPath + "check" + "_" + $database + "_" + "dump.log"
$errorLog = $errorPath + "error" + "_" + $database + "_" + "dump.log"
$backupfile = $backupPath + $database + "_" + $timestamp +".sql"

######################################## Mail info ########################################
$Recipient = "serviceaccount@provider.tld"
$Subject = "MySQL Backup"
$Smtpserver = "smtpserver.company.com"
$Sender = "backupaccount@provider.tld"

$strBody = @"
<html>
<body>
$(date) : 
Le backup des bases de donnes sur le serveur commence. <br>
</body>
</html>
<br>
"@

######################################## Script ###########################################
cd $mysqlPath
foreach ($database in $tableDatabases)
{
.\mysqlcheck.exe --user=$username --password=$password --host=$hostname -c $database | Out-File $checkLog

If (test-path ($checkLog))
{
$strBody += "$(date) : la base de donnees <font color=red>$database</font> est bien coherente<br>"
}
else
{
$strBody += "$(date) : la base de donnees <font color=red>$database</font> n est pas coherente<br>"
}

$checkLog = $checkPath + "check" + "_" + $database + "_" + "dump.log"
$errorLog = $errorPath + "error" + "_" + $database + "_" + "dump.log"
$backupfile = $backupPath + $database + "_" + $timestamp +".sql"

.\mysqldump.exe --user=$username --password=$password --host=$hostname --log-error=$errorLog --databases $database --result-file=$backupfile

If (test-path ($backupfile))
{
$strBody += "$(date) : la base de donnees <font color=red>$database</font> a bien ete sauvegardee<br><br>"
}
else
{
$strBody += "$(date) : la base de donnees <font color=red>$database</font> n a pas pu etre sauvegardee<br><br>"
}
$database = 0
}
$strBody += "$(date) : Le  backup des bases sur le serveur est termine<br>"

Send-MailMessage -To $Recipient -Subject $Subject -Body $strBody -BodyAsHtml $Smtpserver -From $Sender

cd $backupPath
$oldbackups = gci *.sql

for($i=0; $i -lt $oldbackups.count; $i++){
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-7)){
        $oldbackups[$i] | Remove-Item -Confirm:$false
    }
}
exit
