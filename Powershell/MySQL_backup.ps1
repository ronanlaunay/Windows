######################################## Time info ########################################
$date = Get-Date
$timestamp = Get-Date -format yyyyMMdd-HHmmss

######################################## Database info ####################################
$tableDatabases = @("test0","test1","test2","test3","test4")
$database = 0
$textCheck = 0
$textDump = 0

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
$Recipient = "BAL@provider.tld"
$Subject = "MySQL Backup sur A01620"
$Body = "le backup de la base a bien ete effectue"
$Smtpserver = "serversmtp.domain.tld"
$Sender = "backupmysql@provider.tld"

######################################## Script ###########################################
cd $mysqlPath 

foreach ($database in $tableDatabases)
{
.\mysqlcheck.exe --user=$username --password=$password --host=$hostname -c $database | Out-File $checkLog

If (test-path ($checkLog))
{
$textCheck = "la base de donnees $database est bien coherente"
}
else 
{
$textCheck = "la base de donnees $database n est pas coherente"
}
$Body = "$Body `n`n$textCheck"

$checkLog = $checkPath + "check" + "_" + $database + "_" + "dump.log"
$errorLog = $errorPath + "error" + "_" + $database + "_" + "dump.log"
$backupfile = $backupPath + $database + "_" + $timestamp +".sql"

.\mysqldump.exe --user=$username --password=$password --host=$hostname --log-error=$errorLog --databases $database --result-file=$backupfile
If (test-path ($backupfile))
{
$textDump = "la base de donnees $database a bien ete sauvegardee"
}
else 
{
$textDump = "la base de donnees $database n a pas pu etre sauvegardee"
}
$Body = "$Body `n`n$textDump"
$database = 0
}

Send-MailMessage -To $Recipient -Subject $Subject -Body $Body -SmtpServer $Smtpserver -From $Sender

cd $backupPath
$oldbackups = gci *.sql

for($i=0; $i -lt $oldbackups.count; $i++){
    if ($oldbackups[$i].CreationTime -lt $date.AddDays(-7)){
        $oldbackups[$i] | Remove-Item -Confirm:$false
    }
}

exit
