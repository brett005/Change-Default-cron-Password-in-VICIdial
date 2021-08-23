#!/usr/bin/perl

# ADMIN_update_cron_pass.pl - updates IP address in DB and conf file
#
# This script is designed to update all database tables and the local 
# astguiclient.conf, and manager.conf files and change cron password for DataBase and Asterisk manager. 
# As a base is used the original ADMIN_update_password.pl from Vicidial team- Copyright (C) 2009  Matt Florell <vicidial@gmail.com>    LICENSE: AGPLv2
# Characters $ & # (  ) = ` ' " \ | < >  [space] [tab] are not allowed as part of the new password
#
# default path to astguiclient configuration file:
$PATHconf =		'/etc/astguiclient.conf';
$PATHmanager='/etc/asterisk/manager.conf';

$CLIpassword=0;
$CLIrootDBpassword=0;

$secX = time();

# constants
$DB=0;  # Debug flag, set to 0 for no debug messages, lots of output


open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
@conf = <conf>;
close(conf);
$i=0;
foreach(@conf)
	{
	$line = $conf[$i];
	$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
	if ( ($line =~ /^VARserver_ip/) && ($CLIserver_ip < 1) )
		{$VARold_server_ip = $line;   $VARold_server_ip =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_server/) && ($CLIDB_server < 1) )
		{$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_database/) && ($CLIDB_database < 1) )
		{$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_user/) && ($CLIDB_user < 1) )
		{$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_pass/) && ($CLIDB_pass < 1) )
		{$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
	if ( ($line =~ /^VARDB_port/) && ($CLIDB_port < 1) )
		{$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
	$i++;
	}

############################################

### begin parsing run-time options ###
if (length($ARGV[0])>1)
{
	$i=0;
	while ($#ARGV >= $i)
	{
	$args = "$args $ARGV[$i]";
	$i++;
	}

	if ($args =~ /--help/i)
	{
	print "ADMIN_update_cron_pass.pl - updates cron passwords in the $VARDB_database\n";
	print "database and in the local /etc/astguiclient.conf, /etc/asterisk/manager.conf and dbconnect.php files.\n";
	print "Old files are kept with .bak extension\n";
	print "\n";
	print "command-line options:\n";
	print "  [--help] = this help screen\n";
	print "  [--debug] = verbose debug messages\n";
	print "configuration options:\n";
	print "  [--newcronpass=MyNew!Password1] = define new cron password at runtime\n";
	print "  [--rootDBpass=rootDBpassword] = define root MySQL password at runtime\n";
	print "\nCharacters NOT allowed in the password are: \$ \& \# \(  \) \= \` \' \" \\ \| \< \> [space] [tab]\n";
	print "\n";

	exit;
	}
	else
	{
		if ($args =~ /--debug/i) # Debug flag
		{
		$DB=1;
		}
		if ($args =~ /--rootDBpass/i) # root password for MySQL
		{
		@CLIpasswordARY = split(/--rootDBpass=/,$args);
		@CLIpasswordARX = split(/ /,$CLIpasswordARY[1]);
		if (length($CLIpasswordARX[0])>2)
			{
			$VARrootDBpassword = $CLIpasswordARX[0];
			$VARrootDBpassword =~ s/\/$| |\r|\n|\t//gi;
			$CLIrootDBpassword=1;
			print "\n  CLI defined root MySQL password:      $VARrootDBpassword\n";
			}
		}
		if ($args =~ /--newcronpass=/i) # CLI defined new cron password
		{
		@CLIpasswordARY = split(/--newcronpass=/,$args);
		@CLIpasswordARX = split(/ /,$CLIpasswordARY[1]);
		if (length($CLIpasswordARX[0])>1)
			{
			$VARpassword = $CLIpasswordARX[0];
			$VARpassword =~ s/\/$| |\r|\n|\t//gi;
			$CLIpassword=1;
			print "  CLI defined new cron password:        $VARpassword\n";
			}
		}
	}
}
else
{
#	print "no command line options set\n";
}
### end parsing run-time options ###

if (-e "$PATHconf") 
	{
	print "\nPrevious astGUIclient configuration file found at: $PATHconf\n";
	open(conf, "$PATHconf") || die "can't open $PATHconf: $!\n";
	@conf = <conf>;
	close(conf);
	$i=0;
	foreach(@conf)
		{
		$line = $conf[$i];
		$line =~ s/ |>|\n|\r|\t|\#.*|;.*//gi;
		if ( ($line =~ /^PATHhome/) && ($CLIhome < 1) )
			{$PATHhome = $line;   $PATHhome =~ s/.*=//gi;}
		if ( ($line =~ /^PATHlogs/) && ($CLIlogs < 1) )
			{$PATHlogs = $line;   $PATHlogs =~ s/.*=//gi;}
		if ( ($line =~ /^PATHagi/) && ($CLIagi < 1) )
			{$PATHagi = $line;   $PATHagi =~ s/.*=//gi;}
		if ( ($line =~ /^PATHweb/) && ($CLIweb < 1) )
			{$PATHweb = $line;   $PATHweb =~ s/.*=//gi;}
		if ( ($line =~ /^PATHsounds/) && ($CLIsounds < 1) )
			{$PATHsounds = $line;   $PATHsounds =~ s/.*=//gi;}
		if ( ($line =~ /^PATHmonitor/) && ($CLImonitor < 1) )
			{$PATHmonitor = $line;   $PATHmonitor =~ s/.*=//gi;}
		if ( ($line =~ /^PATHDONEmonitor/) && ($CLIDONEmonitor < 1) )
			{$PATHDONEmonitor = $line;   $PATHDONEmonitor =~ s/.*=//gi;}
		if ( ($line =~ /^VARserver_ip/) )
			{$VARserver_ip = $line;   $VARserver_ip =~ s/.*=//gi;}
		if ( ($line =~ /^VARDB_server/) && ($CLIDB_server < 1) )
			{$VARDB_server = $line;   $VARDB_server =~ s/.*=//gi;}
		if ( ($line =~ /^VARDB_database/) && ($CLIDB_database < 1) )
			{$VARDB_database = $line;   $VARDB_database =~ s/.*=//gi;}
		if ( ($line =~ /^VARDB_user/) && ($CLIDB_user < 1) )
			{$VARDB_user = $line;   $VARDB_user =~ s/.*=//gi;}
		if ( ($line =~ /^VARDB_pass/) && ($CLIDB_pass < 1) )
			{$VARDB_pass = $line;   $VARDB_pass =~ s/.*=//gi;}
		if ( ($line =~ /^VARDB_port/) && ($CLIDB_port < 1) )
			{$VARDB_port = $line;   $VARDB_port =~ s/.*=//gi;}
		if ( ($line =~ /^VARactive_keepalives/) && ($CLIactive_keepalives < 1) )
			{$VARactive_keepalives = $line;   $VARactive_keepalives =~ s/.*=//gi;}
		if ( ($line =~ /^VARasterisk_version/) && ($CLIasterisk_version < 1) )
			{$VARasterisk_version = $line;   $VARasterisk_version =~ s/.*=//gi;}
		if ( ($line =~ /^VARFTP_host/) && ($CLIFTP_host < 1) )
			{$VARFTP_host = $line;   $VARFTP_host =~ s/.*=//gi;}
		if ( ($line =~ /^VARFTP_user/) && ($CLIFTP_user < 1) )
			{$VARFTP_user = $line;   $VARFTP_user =~ s/.*=//gi;}
		if ( ($line =~ /^VARFTP_pass/) && ($CLIFTP_pass < 1) )
			{$VARFTP_pass = $line;   $VARFTP_pass =~ s/.*=//gi;}
		if ( ($line =~ /^VARFTP_port/) && ($CLIFTP_port < 1) )
			{$VARFTP_port = $line;   $VARFTP_port =~ s/.*=//gi;}
		if ( ($line =~ /^VARFTP_dir/) && ($CLIFTP_dir < 1) )
			{$VARFTP_dir = $line;   $VARFTP_dir =~ s/.*=//gi;}
		if ( ($line =~ /^VARHTTP_path/) && ($CLIHTTP_path < 1) )
			{$VARHTTP_path = $line;   $VARHTTP_path =~ s/.*=//gi;}
		if ( ($line =~ /^VARREPORT_host/) && ($CLIREPORT_host < 1) )
			{$VARREPORT_host = $line;   $VARREPORT_host =~ s/.*=//gi;}
		if ( ($line =~ /^VARREPORT_user/) && ($CLIREPORT_user < 1) )
			{$VARREPORT_user = $line;   $VARREPORT_user =~ s/.*=//gi;}
		if ( ($line =~ /^VARREPORT_pass/) && ($CLIREPORT_pass < 1) )
			{$VARREPORT_pass = $line;   $VARREPORT_pass =~ s/.*=//gi;}
		if ( ($line =~ /^VARREPORT_port/) && ($CLIREPORT_port < 1) )
			{$VARREPORT_port = $line;   $VARREPORT_port =~ s/.*=//gi;}
		if ( ($line =~ /^VARREPORT_dir/) && ($CLIREPORT_dir < 1) )
			{$VARREPORT_dir = $line;   $VARREPORT_dir =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_min_servers/) && ($CLIVARfastagi_log_min_servers < 1) )
			{$VARfastagi_log_min_servers = $line;   $VARfastagi_log_min_servers =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_max_servers/) && ($CLIVARfastagi_log_max_servers < 1) )
			{$VARfastagi_log_max_servers = $line;   $VARfastagi_log_max_servers =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_min_spare_servers/) && ($CLIVARfastagi_log_min_spare_servers < 1) )
			{$VARfastagi_log_min_spare_servers = $line;   $VARfastagi_log_min_spare_servers =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_max_spare_servers/) && ($CLIVARfastagi_log_max_spare_servers < 1) )
			{$VARfastagi_log_max_spare_servers = $line;   $VARfastagi_log_max_spare_servers =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_max_requests/) && ($CLIVARfastagi_log_max_requests < 1) )
			{$VARfastagi_log_max_requests = $line;   $VARfastagi_log_max_requests =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_checkfordead/) && ($CLIVARfastagi_log_checkfordead < 1) )
			{$VARfastagi_log_checkfordead = $line;   $VARfastagi_log_checkfordead =~ s/.*=//gi;}
		if ( ($line =~ /^VARfastagi_log_checkforwait/) && ($CLIVARfastagi_log_checkforwait < 1) )
			{$VARfastagi_log_checkforwait = $line;   $VARfastagi_log_checkforwait =~ s/.*=//gi;}
		$i++;
		}
	}

if ($VARpassword&&$VARrootDBpassword)
	{
	if ( $VARpassword =~ m/\$|\&|\#|\(|\)|\=|\`|\'|\"|\\|\||\<|\>| |\t/)
		{
		print "\nSupplied new cron password '$VARpassword' contains invalid character\(s\).\n";
		print "Characters NOT allowed in the password are: \$ \& \# \(  \) \= \` \' \" \\ \| \< \> [space] [tab] \n";
		$config_finished='NO';
		$bad_pass=1
		}
		else
		{
		$config_finished='YES';
		$bad_pass=0
		}
	}
else
	{
	$config_finished='NO';
	}

	while ($config_finished =~/NO/)
		{
			if (!$CLIpassword||$bad_pass) 
			 {
			##### BEGIN new password propmting and check #####
			$continue='NO';
			while ($continue =~/NO/)
				{
				print("\nPlease enter the new cron password : ");
				$PROMPT_password = <STDIN>;
				chomp($PROMPT_password);
				if (length($PROMPT_password)>0)
					{
					$PROMPT_password =~ s/\n|\r|\/$//gi;
					if ( $PROMPT_password =~ m/\$|\&|\#|\(|\)|\=|\`|\'|\"|\\|\||\<|\>| |\t/)
						{
						print "\nSupplied new cron password '$PROMPT_password' contains invalid character\(s\)\n";
						print "Characters NOT allowed in the password are: \$ \& \# \(  \) \= \` \' \" \\ \| \< \> [space] [tab] \n";
						$config_finished='NO';
						}
						else
						{
						$PROMPT_password =~ s/ |\n|\r|\t|\/$//gi;
						$VARpassword=$PROMPT_password;
						$continue='YES';
						}
					}
			    else
					{
					print("\nThis is not a valid password ");
					$continue='NO';
					}
				}
		##### END new password propmting and check  #####
			 }

		##### BEGIN DB root password propmting and check #####
		if (!$CLIrootDBpassword)
			{
#			print("\nWill need MySQL root password.");
			$continue='NO';
			while ($continue =~/NO/)
				{
				print("\nPlease enter root MySQL password : ");
				$PROMPTpassword = <STDIN>;
				chomp($PROMPTpassword);
				$VARrootDBpassword=$PROMPTpassword;
				$continue='YES';
				}
		##### END DB root password propmting and check  #####
			}



		print "\n";
		print "  new cron password:      $VARpassword\n";
		print "  root MySQL password:    $VARrootDBpassword\n";
		print "\n";

		print("Are these settings correct?(y/n): [y] ");
		$PROMPTconfig = <STDIN>;
		chomp($PROMPTconfig);
		if ( (length($PROMPTconfig)<1) or ($PROMPTconfig =~ /y/i) )
			{
			$config_finished='YES';
			}
		}

print "Writing changes to astguiclient.conf file: $PATHconf\n";

local $^I = ".bak"; # in place editing with backup file
@ARGV = $PATHconf;
	while( <> ){
      if( s/^\s*VARDB_pass\s*=.*/VARDB_pass => $VARpassword/ig ) {
        print;
      }
      else {
         print;
		}
   }
print "Writing changes to manager.conf file: $PATHconf\n";
@ARGV = $PATHmanager;
	while( <> ){
      if( s/^\s*secret\s*=.*/secret = $VARpassword/ig ) {
        print;
      }
      else {
         print;
		}
   }

	print "Writing changes to dbconnect.php file: $PATHweb/agc/dbconnect.php\n";
	@ARGV = "$PATHweb/agc/dbconnect.php";
	while( <> ){
		if( s/^\s*\$VARDB_pass\s*=.*/\$VARDB_pass = '$VARpassword';/ig ) {
        print;
			}
      else {
         print;
			}
	}
	print "Writing changes to dbconnect.php file: $PATHweb/vicidial/dbconnect.php\n";
   @ARGV = "$PATHweb/vicidial/dbconnect.php";
	while( <> ){
		if( s/^\s*\$VARDB_pass\s*=.*/\$VARDB_pass = '$VARpassword';/ig ) {
        print;
			}
      else {
         print;
			}
	}


print "\nSTARTING DATABASE TABLES UPDATES PHASE...\n";

if (!$VARDB_port) {$VARDB_port='3306';}

use DBI;
$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "root", "$VARrootDBpassword")
	or die "Couldn't connect to database: " . DBI->errstr;

print "  Updating servers table ASTmgrSECRET...\n";
$stmtA = "UPDATE servers SET ASTmgrSECRET='$VARpassword';";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table ASTmgrSECRET...\n";
$stmtA = "UPDATE phones SET ASTmgrSECRET='$VARpassword';";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table DBX_pass...\n";
$stmtA = "UPDATE phones SET DBX_pass='$VARpassword';";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table DBY_pass...\n";
$stmtA = "UPDATE phones SET DBY_pass='$VARpassword';";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

$dbhA->disconnect();

#update default values

$dbhA = DBI->connect("DBI:mysql:$VARDB_database:$VARDB_server:$VARDB_port", "root", "$VARrootDBpassword")
	or die "Couldn't connect to database: " . DBI->errstr;

print "  Updating servers table default ASTmgrSECRET...\n";
$stmtA = "ALTER TABLE `servers` CHANGE COLUMN `ASTmgrSECRET` `ASTmgrSECRET` VARCHAR(20) NOT NULL DEFAULT '$VARpassword' AFTER `ASTmgrUSERNAME`;";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table default ASTmgrSECRET...\n";
$stmtA = "ALTER TABLE `phones` CHANGE COLUMN `ASTmgrSECRET` `ASTmgrSECRET` VARCHAR(20) NULL DEFAULT '$VARpassword' AFTER `ASTmgrUSERNAME`;";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table default DBX_pass...\n";
$stmtA = "ALTER TABLE `phones` CHANGE COLUMN `DBX_pass` `DBX_pass` VARCHAR(15) NULL DEFAULT '$VARpassword' AFTER `DBX_user`;";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "  Updating phones table default DBY_pass...\n";
$stmtA = "ALTER TABLE `phones` CHANGE COLUMN `DBY_pass` `DBY_pass` VARCHAR(15) NULL DEFAULT '$VARpassword' AFTER `DBY_user`;";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}
$dbhA->disconnect();

$VARdb = 'mysql';
$dbhA = DBI->connect("DBI:mysql:$VARdb:$VARDB_server:$VARDB_port", "root", "$VARrootDBpassword")
	or die "Couldn't connect to database: " . DBI->errstr;
print "  Updating MySQL password for user 'cron'...\n";
$stmtA = "update user set password=PASSWORD('$VARpassword') where user='cron';";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

$stmtA = "FLUSH PRIVILEGES;";
$affected_rows = $dbhA->do($stmtA);
if ($DB) {print "     |$affected_rows|$stmtA|\n";}

print "\n";
print "CRON PASSWORD CHANGE FOR VICIDIAL FINISHED!\n";
print "\n";
$secy = time();		$secz = ($secy - $secX);		$minz = ($secz/60);		# calculate script runtime so far
print "\n     - process runtime      ($secz sec) ($minz minutes)\n";


exit;