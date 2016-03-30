#!/usr/bin/perl -w

# Set up environment
use lib "/usr/lib/smoothwall";
use SmoothInstall qw( :standard );
use header  qw( :standard );
use Shell qw(rm touch);

Init("backupssh");

# Start Installation
# ClearScreen;

PRINT $GREEN . "Installing $CYAN $ModDetails{'MOD_NAME'} $ModDetails{'MOD_VERSION'} $NORMAL";

# Insert Additional Code Here as required
PRINT $GREEN . "Backing up original script...\n$NORMAL";
system("/bin/mv","/httpd/cgi-bin/backup.img","$MODDIR/backup/backup.img");
print $YELLOW . "\t\t\t\t\tDone!\n\n$NORMAL";

PRINT $GREEN . "Creating keyfile in /root/.ssh...\n$NORMAL";
system("/usr/bin/ssh-keygen -t rsa");
print $YELLOW . "\t\t\t\t\tDone!\n\n$NORMAL";

PRINT $GREEN . "Applying necessary permissions on keyfile...\n$NORMAL";
system("chmod 600 /root/.ssh/id_*");
print $YELLOW . "\t\t\t\t\tDone!\n\n$NORMAL";

PRINT $GREEN . "Applying necessary permissions on mod dir...\n$NORMAL";
system("chown -R nobody.root $MODDIR/etc");
print $YELLOW . "\t\t\t\t\tDone!\n\n$NORMAL";

PRINT $GREEN . "Preparing for the future non-interactive SCP transfer with remote host...";
print "\nPlease enter remote hostname or IP:\n$NORMAL";
$host = "";
$host = <STDIN>;
chomp $host;
print $GREEN . "\nPlease enter remote host SSH port:\n$NORMAL";
$port = "";
$port = <STDIN>;
chomp $port;
print $GREEN . "\nPlease enter remote host user: [root]\n$NORMAL";
$user = "";
$user = <STDIN>;
chomp $user;
if ($user eq '') { $user = 'root'; }
print $GREEN . "\nAdding key to remote host's authorized_keys file...\n$NORMAL";
system("scp -P $port /root/.ssh/id_rsa.pub $user\@$host:.; ssh -p $port $user\@$host \"mkdir -p /$user/.ssh; cd /$user/.ssh; /bin/touch authorized_keys; cat /$user/id_rsa.pub >> authorized_keys\"");
print $YELLOW . "\t\t\t\t\tDone!\n\n$NORMAL";

$cgiparams{'HOST'} = $host;
$cgiparams{'PORT'} = $port;
$cgiparams{'USER'} = $user;
$cgiparams{'KEY'} = 'id_rsa';
&writehash("$MODDIR/etc/settings", \%cgiparams);

# Remove Installation Symbolic Link
# unlink("/tmp/install-$ModDetails{'MOD_NAME'}"); # No longer needed with makeself?

PRINT $GREEN . "Finished Installation. $NORMAL";
# Restart Smoothd to install new module
StopMod("/usr/sbin/smoothd", "Smoothd");
StartMod("/usr/sbin/smoothd", "Smoothd");