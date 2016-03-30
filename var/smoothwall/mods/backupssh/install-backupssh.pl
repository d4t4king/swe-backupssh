#!/usr/bin/perl -w

# Set up environment
use lib "/usr/lib/smoothwall";
use SmoothInstall qw( :standard );
use header  qw( :standard );
use Shell qw(rm touch);
use Term::ANSIColor;

Init("backupssh");

# Start Installation
# ClearScreen;

print colored("Installing ", "green");
print colored("$ModDetails{'MOD_NAME'} $ModDetails{'MOD_VERSION'} \n", "cyan");

# Insert Additional Code Here as required
print colored("Backing up original script...\n", "cyan");
system("/bin/mv","/httpd/cgi-bin/backup.img","$MODDIR/backup/backup.img");
print colored("\t\t\t\t\tDone!\n\n", "yellow");

print colored("Creating keyfile in /root/.ssh...\n", "green");
system("/usr/bin/ssh-keygen -t rsa");
print colored("\t\t\t\t\tDone!\n\n", "yellow");

print colored("Applying necessary permissions on keyfile...\n", "green");
system("chmod 600 /root/.ssh/id_*");
print colored("\t\t\t\t\tDone!\n\n", "yellow");

print colored("Applying necessary permissions on mod dir...\n", "green");
system("chown -R nobody.root $MODDIR/etc");
print colored("\t\t\t\t\tDone!\n\n", "yellow");

print colored("Preparing for the future non-interactive SCP transfer with remote host...\n", "green");
print colored("Please enter remote hostname or IP:\n", "green");
$host = "";
$host = <STDIN>;
chomp $host;
print colored("\nPlease enter remote host SSH port:\n", "green");
$port = "";
$port = <STDIN>;
chomp($port);
print colored("\nPlease enter remote host user: [root]\n", "green");
$user = "";
$user = <STDIN>;
chomp($user);
if ($user eq '') { $user = 'root'; }
print colored("\nAdding key to remote host's authorized_keys file...\n", "green");
system("scp -P $port /root/.ssh/id_rsa.pub $user\@$host:.; ssh -p $port $user\@$host \"mkdir -p /$user/.ssh; cd /$user/.ssh; /bin/touch authorized_keys; cat /$user/id_rsa.pub >> authorized_keys\"");
print colored("\t\t\t\t\tDone!\n\n", "yellow");

$cgiparams{'HOST'} = $host;
$cgiparams{'PORT'} = $port;
$cgiparams{'USER'} = $user;
$cgiparams{'KEY'} = 'id_rsa';
&writehash("$MODDIR/etc/settings", \%cgiparams);

# Remove Installation Symbolic Link
# unlink("/tmp/install-$ModDetails{'MOD_NAME'}"); # No longer needed with makeself?

print colored("Finished Installation.\n", "yellow");
# Restart Smoothd to install new module
StopMod("/usr/sbin/smoothd", "Smoothd");
StartMod("/usr/sbin/smoothd", "Smoothd");

