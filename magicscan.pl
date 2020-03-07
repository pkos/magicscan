use strict;
use warnings;
use Term::ProgressBar;

#"SYSTEMS TO SUPPORT"                            "DETECT SYSYEM"  "GET SERIAL"
# NEC - PC Engine CD - TurboGrafx-CD             iso
# Nintendo - GameCube                            iso, bin/cue     iso, bin/cue
# Nintendo - Nintendo 3DS                        3ds
# Nintendo - Nintendo Wii                        iso, bin/cue     iso, bin/cue
# Panasonic - 3DO                                iso, bin/cue
# Philips - CDi                                  iso, bin/cue
# Sega - Dreamcast                               iso, bin/cue     iso, bin/cue
# Sega - Mega-CD - Sega CD                       iso, bin/cue     iso, bin/cue
# Sega - Saturn                                  iso, bin/cue     iso, bin/cue
# SNK - Neo Geo CD                               
# Sony - Playstation                             iso, bin/cue         
# Sony - PlayStation Portable                    iso, bin/cue     iso, bin/cue

#check command line
my $substringh = "-h";
my $directory = "";
my $cdimage = "";

foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "magicscan v0.6 - Generate disc code serials from a directory scan\n";
	print "\n";
	print "with magicscan [directory ...]";
    print "\n";
	print "Notes:\n";
	print "  [directory] should be the path to the games folder\n";
	print "\n";
	print "Example:\n";
	print '   magicscan "D:/ROMS/Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
}

#set directory, system, and extension variables
if (scalar(@ARGV) < 1 or scalar(@ARGV) > 2) {
  print "Invalid command line.. exit\n";
  print "use: magicscan -h\n";
  print "\n";
  exit;
}
$directory = $ARGV[-1];
$directory =~ s/\\/\//g; 

#exit no parameters
if ($directory eq "") {
  print "Invalid command line.. exit\n";
  print "use: magicscan -h\n";
  print "\n";
  exit;
}

#read games directory to @linesf
my @linesf;
opendir(DIR, $directory) or die "Could not open $directory\n";
while (my $filename = readdir(DIR)) {
  if (-d $filename) {
    next;
  } else {
    push(@linesf, $filename) unless $filename eq '.' or $filename eq '..';
    #print "$filename\n";    
  }
}
closedir(DIR);
my $max = scalar(@linesf);
my $progress = Term::ProgressBar->new({name => 'progress', count => $max});

#Loop each iso and printout

open(LOG, ">", "serial_log.txt") or die "Could not open serial_log.txt\n";
	
my $offset;
my $read;
my $magic;
my $pos;
my $match;
	
foreach my $element (@linesf) {
   $progress->update($_);
   
   my $systemname = "Unknown";
   my $game_id = "Unknown";
   
   if (lc substr($element, -4) eq '.iso') {

    #Detect system
    open(FILE, $directory . "/" . $element) or die "Could not open file '$element' $!";
    binmode FILE;
   
    #just a couple magic numbers
    #seek FILE, 0x8001, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0x8001: $magic\n";
    #seek FILE, 0x8028, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0x8028: $magic\n";
    #seek FILE, 0x8801, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0x8801: $magic\n";
    #seek FILE, 0x9001, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0x9001: $magic\n";
    #seek FILE, 0xb135, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0xb135: $magic\n";
    #seek FILE, 0xb221, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0xb221: $magic\n";
    #seek FILE, 0xb381, 0;
    #$read = read FILE, $magic, $MAGIC_LEN;
    #print "0xb381: $magic\n";

    #----------------------- Detect systems ISO
    #PSP
	$offset = 0x8008;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 8;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "PSP GAME")
       {
          $systemname = "Sony - Playstation Portable";
       }
    }
    
	#PS1
	$offset = 0x8008;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 11;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "PLAYSTATION")
       {
          $systemname = "Sony - Playstation";
       }
    }
	
	#Nintendo - GameCube
	$offset = 0x001c;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 4;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\xc2\x33\x9f\x3d")
       {
          $systemname = "Nintendo - GameCube";
       }
    }
	
	#Sega CD
	$offset = 0x0000;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 14;
	if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGADISCSYSTEM")
       {
         $offset = 0x0100;
	     seek FILE, $offset, 0;
         $read = read FILE, $magic, 12;
         if ($read > 0)
         {
            if ($magic ne "" and ($magic eq "SEGA MEGADRI" or $magic = "SEGA GENESIS"))
            {
               $systemname = "Sega - Mega CD & Sega CD";
            }
         }
	   }
	}
	
	#Sega - Saturn
	$offset = 0x0000;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 15;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGA SEGASATURN")
       {
          $systemname = "Sega - Saturn";
       }
    }
	
	#Sega - Dreamcast
	$offset = 0x0000;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 15;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGA SEGAKATANA")
       {
          $systemname = "Sega - Dreamcast";
       }
    }
	
    #Nintendo - Nintendo Wii
	$offset = 0x0018;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 4;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\x5d\x1c\x9e\xa3")
       {
          $systemname = "Nintendo - Nintendo Wii";
       }
    }
	
	#Panasonic - 3DO
	for ($pos = 0; $pos < 10000; $pos++) {
    
	  seek FILE, $pos, 0;
      if ((read FILE, $magic, 7) > 0) {

        if ($magic eq "\x01\x5a\x5a\x5a\x5a\x5a\x01") {
          $match = "TRUE";
		  last;
	    }
	  }
	}
	for ($pos = 0; $pos < 10000; $pos++) {
    
	  seek FILE, $pos, 0;
      if ((read FILE, $magic, 6) > 0) {

        if (uc $magic eq "CD-ROM" and $match = "TRUE") {
	      $systemname = "Panasonic - 3DO";
		}
	  }
	}
		
	#Philips - CDi
	$offset = 0x8008;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 7;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "CD-RTOS")
       {
          $systemname = "Philips - CDi";
       }
    }
	
	#NEC - PC Engine CD - TurboGrafx-CD
	$offset = 0x0820;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 16;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "PC Engine CD-ROM")
       {
          $systemname = "NEC - PC Engine CD - TurboGrafx-CD";
       }
    }
	
    #--------------------------------- Get Serials ISO

    #Get Serial
    if ($systemname eq "Sony - Playstation Portable") {
  
      for ($pos = 0; $pos < 100000; $pos++) {
    
	    seek FILE, $pos, 0;
        if ((read FILE, $game_id, 5) > 0) {

          if (
             ($game_id eq "ULES-")
             or ($game_id eq "ULUS-")
             or ($game_id eq "ULJS-")
             or ($game_id eq "ULEM-")
             or ($game_id eq "ULUM-")
             or ($game_id eq "ULJM-")
             or ($game_id eq "UCES-")
             or ($game_id eq "UCUS-")
             or ($game_id eq "UCJS-")
             or ($game_id eq "UCAS-")

             or ($game_id eq "NPEH-")
             or ($game_id eq "NPUH-")
             or ($game_id eq "NPJH-")

             or ($game_id eq "NPEG-")
             or ($game_id eq "NPUG-")
             or ($game_id eq "NPJG-")
             or ($game_id eq "NPHG-")

             or ($game_id eq "NPEZ-")
             or ($game_id eq "NPUZ-")
             or ($game_id eq "NPJZ-")
          ) {
            seek(FILE, $pos, 0);
            if (read(FILE, $game_id, 10) > 0) {

            }
            last;
          }
        } else {
          last;
        }
      }
    } elsif ($systemname eq "Sony - Playstation") {

    } elsif ($systemname eq "Nintendo - GameCube") {

      seek(FILE, 0, 0); # 0 seems right, 2 to match redump serials
      if (read(FILE, $game_id, 6) > 0) # 6 seems right, 4 to match redump
      {

      } 
    #} elsif ($systemname eq "Nintendo - GameCube") { # redump serial matching code (missing region offset)
    #
    #  seek(FILE, 2, 0); # 0 seems right, 2 to match redump serials
    #  if (read(FILE, $game_id, 4) > 0) # 6 seems right, 4 to match redump
    #  {
    #    $game_id = "DL-DOL-" . $game_id . "";
    #  } 
    } elsif ($systemname eq "Sega - Mega CD & Sega CD") {

      seek(FILE, 0x0183, 0);
      if (read(FILE, $game_id, 11) > 0)
      {

      }
    } elsif ($systemname eq "Sega - Saturn") {

      seek(FILE, 0x0020, 0);
      if (read(FILE, $game_id, 9) > 0)
      {

      }
    } elsif ($systemname eq "Sega - Dreamcast") {

      seek(FILE, 0x0040, 0);
      if (read(FILE, $game_id, 10) > 0)
      {

      }  
    } elsif ($systemname eq "Nintendo - Nintendo Wii") {

      seek(FILE, 0x0000, 0);
      if (read(FILE, $game_id, 6) > 0)
      {

      } 
    }
    close FILE;
  
    print LOG "File name: $element\n";
    print LOG "System: $systemname\n";
    print LOG "Game ID: $game_id\n";
    print LOG "\n";  

  } elsif (lc substr($element, -4) eq '.cue') {
  
    #Detect system
    my $temp;
    my $cuefile;
	
    #read cue file
    open(FILE, $directory . "/" . $element) or die "Could not open file '$element' $!";
    binmode FILE;
  
    $temp = <FILE>;
    my $resultgamestart = index($temp, 'FILE "');
	my $resultgameend = rindex($temp, '" BINARY');
	my $length = $resultgameend - $resultgamestart;
	$cuefile = substr($temp, $resultgamestart + 6, $length - 6);
    
	#read bin file
	open(BIN, $directory . "/" . $cuefile) or die "Could not open file '$cuefile' $!";
    binmode BIN;
	
	#----------------------- Detect systems BIN
	#Nintendo - GameCube
	$offset = 0x001c;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 4;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\xc2\x33\x9f\x3d")
       {
          $systemname = "Nintendo - GameCube";
       }
    }
	
    #Sega - Dreamcast
	$offset = 0x0010;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 15;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGA SEGAKATANA")
       {
          $systemname = "Sega - Dreamcast";
       }
    }

    #Nintendo - Nintendo Wii
	$offset = 0x0018;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 4;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\x5d\x1c\x9e\xa3")
       {
          $systemname = "Nintendo - Nintendo Wii";
       }
    }
	
	#Sega CD
	$offset = 0x0010;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 14;
	if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGADISCSYSTEM")
       {
         $offset = 0x0110;
	     seek BIN, $offset, 0;
         $read = read BIN, $magic, 12;
         if ($read > 0)
         {
            if ($magic ne "" and ($magic eq "SEGA MEGADRI" or $magic = "SEGA GENESIS"))
            {
               $systemname = "Sega - Mega CD & Sega CD";
            }
         }
	   }
	}
	
	#Sega - Saturn
	$offset = 0x0010;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 15;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "SEGA SEGASATURN")
       {
          $systemname = "Sega - Saturn";
       }
    }
	
	#PSP
	$offset = 0x8008;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 8;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "PSP GAME")
       {
          $systemname = "Sony - Playstation Portable";
       }
    }
	
	#Panasonic - 3DO
	for ($pos = 0; $pos < 10000; $pos++) {
    
	  seek BIN, $pos, 0;
      if ((read BIN, $magic, 7) > 0) {

        if ($magic eq "\x01\x5a\x5a\x5a\x5a\x5a\x01") {
          $match = "TRUE";
		  last;
	    }
	  }
	}
	for ($pos = 0; $pos < 10000; $pos++) {
    
	  seek BIN, $pos, 0;
      if ((read BIN, $magic, 6) > 0) {

        if (uc $magic eq "CD-ROM" and $match = "TRUE") {
	      $systemname = "Panasonic - 3DO";
		}
	  }
	}
	
	#Philips - CDi
	$offset = 0x9320;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 7;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "CD-RTOS")
       {
          $systemname = "Philips - CDi";
       }
    }
	
	#PS1
	$offset = 0x9320;
	seek BIN, $offset, 0;
    $read = read BIN, $magic, 11;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "PLAYSTATION")
       {
          $systemname = "Sony - Playstation";
       }
    }
	
    #--------------------------------- Get Serials BIN
    if ($systemname eq "Nintendo - GameCube") {

      seek(BIN, 0, 0); # 0 seems right, 2 to match redump serials
      if (read(BIN, $game_id, 6) > 0) # 6 seems right, 4 to match redump
      {

      } 
    } elsif ($systemname eq "Nintendo - Nintendo Wii") {

      seek(BIN, 0x0000, 0);
      if (read(BIN, $game_id, 6) > 0)
      {

      } 
    } elsif ($systemname eq "Sega - Dreamcast") {

      seek(BIN, 0x0050, 0);
      if (read(BIN, $game_id, 10) > 0)
      {

      }  
    } elsif ($systemname eq "Sega - Mega CD & Sega CD") {

      seek(BIN, 0x0193, 0);
      if (read(BIN, $game_id, 11) > 0)
      {

      }
	} elsif ($systemname eq "Sega - Saturn") {

      seek(BIN, 0x0030, 0);
      if (read(BIN, $game_id, 9) > 0)
      {

      }
    } elsif ($systemname eq "Sony - Playstation Portable") {
  
      for ($pos = 0; $pos < 100000; $pos++) {
    
	    seek BIN, $pos, 0;
        if ((read BIN, $game_id, 5) > 0) {

          if (
             ($game_id eq "ULES-")
             or ($game_id eq "ULUS-")
             or ($game_id eq "ULJS-")
             or ($game_id eq "ULEM-")
             or ($game_id eq "ULUM-")
             or ($game_id eq "ULJM-")
             or ($game_id eq "UCES-")
             or ($game_id eq "UCUS-")
             or ($game_id eq "UCJS-")
             or ($game_id eq "UCAS-")

             or ($game_id eq "NPEH-")
             or ($game_id eq "NPUH-")
             or ($game_id eq "NPJH-")

             or ($game_id eq "NPEG-")
             or ($game_id eq "NPUG-")
             or ($game_id eq "NPJG-")
             or ($game_id eq "NPHG-")

             or ($game_id eq "NPEZ-")
             or ($game_id eq "NPUZ-")
             or ($game_id eq "NPJZ-")
          ) {
            seek(BIN, $pos, 0);
            if (read(BIN, $game_id, 10) > 0) {

            }
            last;
          }
        } else {
          last;
        }
      }
	}
	close BIN;
	
	print LOG "File name: $element\n";
    print LOG "System: $systemname\n";
    print LOG "Game ID: $game_id\n";
    print LOG "\n";  
	
  } elsif (lc substr($element, -4) eq '.3ds') {

    #Detect system
    open(FILE, $directory . "/" . $element) or die "Could not open file '$element' $!";
    binmode FILE;
	
	#Nintendo - Nintendo 3DS
	$offset = 0x0100;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 4;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "NCSD")
       {
          $systemname = "Nintendo - Nintendo 3DS";
       }
    }
	
	print LOG "File name: $element\n";
    print LOG "System: $systemname\n";
    print LOG "Game ID: $game_id\n";
    print LOG "\n";  
  }
}
print "\nwriting:  serial_log.txt\n";
close LOG;