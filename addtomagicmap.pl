use strict;
use warnings;
use Term::ProgressBar;

#init
my $datfile = "";
my $system = "";
my $substringh = "-h";
my @linesdat;

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "addmap (magicscan) v0.5 - Utility used for building the magicmap.map file used by magicscan. \n";
	print "\n";
	print "with addmap [dat file ...] [system]";
    print "\n";
	print "Example:\n";
	print '              addmap "D:/Atari - 2600.dat" "Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
}

#set paths and system variables
if (scalar(@ARGV) < 2 or scalar(@ARGV) > 2) {
  print "Invalid command line.. exit\n";
  print "use: addmap -h\n";
  print "\n";
  exit;
}
$datfile = $ARGV[-2];
$system = $ARGV[-1];

#debug
print "dat file: $datfile\n";
print "system: $system\n";

#exit no parameters
if ($datfile eq "" or $system eq "") {
  print "Invalid command line.. exit\n";
  print "use: datmap -h\n";
  print "\n";
  exit;
}

#read playlist file
open(FILE, "<", $datfile) or die "Could not open $datfile\n";
while (my $readline = <FILE>) {
  push(@linesdat, $readline);
  #print "$readline\n";
}
close (FILE);

my $gamename = "";
my $serialname = "";
my $serial = "";
my $resultgamestart = "";
my $resultgameend = "";
my $resultcrcstart = "";
my @seriallines;
my $serialline = "";

#parse the game name and redump disc serial
open (MAP, ">>", "magicmap.map") or die "Could not write magicmap.map\n";
foreach my $datline (@linesdat) {
  if ($datline =~ m/<game name="/) {
    #parse game name
	$resultgamestart = index($datline, '<game name="');
	$resultgameend = index($datline, '">');
	my $length = ($resultgameend)  - ($resultgamestart + 12) ;
    $gamename  = substr($datline, $resultgamestart + 12, $length);
    print "$gamename ";
  }
  if ($datline =~ m/<serial>/) {
    #parse serial
	$resultgamestart = index($datline, '<serial>"');
	$resultgameend = index($datline, '</serial>');
	my $length = ($resultgameend)  - ($resultgamestart + 11) ;
    $serialname  = substr($datline, $resultgamestart + 11, $length);
    print "$serialname ";
	
    #write system game and crc to thumbmap.map delimined by ,,
    print MAP "$system" . ",," , "$gamename" . ",," . "$serialname\n";
  }
}


