######################################## Time info ########################################
$date = Get-Date
$timestamp = Get-Date -format yyyyMMdd-HHmmss

######################################## Database info ####################################
$table_databases = @("db_test1","db_test2","db_test3","db_test4","db_test5","db_test6")
$database = 0

######################################## Connect info #####################################
$mysqlpath = "C:\Program Files\MySQL\MySQL Server 5.5\bin\"
$backuppath = "C:\mysql_backup\dump\"
$logpath = "C:\mysql_backup\logs\"
$username = "root"
$password = "password"
$hostname = "localhost"
$errorlog = $logpath + "error" + "_" + $database + "_" + "dump.log"

######################################## Backup file info #################################
$backupfile = $backuppath + $database + "_" + $timestamp +".sql"

######################################## Mail info ########################################
$Recipient = "launay.ronan@gmail.com"
$Subject = "MySQL Backup sur le serveur 1234"
$Body = "le backup de la base a bien ete effectue"
$Smtpserver = "smtprelay.domaine.tld"
$Sender = "backupmysql@provider.tld"

######################################## Script ###########################################
cd $mysqlpath 

foreach ($database in $table_databases)
{
$backupfile = $backuppath + $database + "_" + $timestamp +".sql"
.\mysqldump.exe --user=$username --password=$password --host=$hostname --log-error=$errorlog --databases $database --result-file=$backupfile
If (test-path ($backupfile))
{
$text = "la base de donnees $database a bien ete sauvegardee"
}
else 
{
$text = "la base de donnees $database n a pas pu etre sauvegardee"
}
$Body = "$Body `n$text"
$database = 0
}
Send-MailMessage -To $Recipient -Subject $Subject -Body $Body -SmtpServer $Smtpserver -From $Sender

cd $backuppath
$oldbackups = gci *.sql

for($i=0; $i -lt $oldbackups.count; $i++){
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-7)){
        $oldbackups[$i] | Remove-Item -Confirm:$false
    }
}

exit
