use strict;
use warnings;
use Term::ProgressBar;

#"SYSTEMS TO SUPPORT"                            "DETECT SYSYEM"  "GET SERIAL"
# NEC - PC Engine CD - TurboGrafx-CD             X
# Nintendo - GameCube                            X                X
# Nintendo - Nintendo 3DS                        X
# Nintendo - Nintendo Wii                        X                X
# Panasonic - 3DO                                X
# Philips - CDi                                  X
# Sega - Dreamcast                               X                X
# Sega - Mega-CD - Sega CD                       X                X
# Sega - Saturn                                  X                X
# SNK - Neo Geo CD                               X
# Sony - Playstation                             X           
# Sony - PlayStation Portable                    X                X

# Random
#my $cdimage = "007 - The World Is Not Enough (USA).chd";
#my $cdimage = "Lumines (USA) (v1.01).cso";

# NEC - PC Engine CD - TurboGrafx-CD
#my $cdimage = "../magicnumber_data/Camp California (USA).iso";
#my $cdimage = "../magicnumber_data/Buster Bros. (USA).iso";
#my $cdimage = "../magicnumber_data/Dungeon Explorer II (USA).iso";

# Philips - CDi
#my $cdimage = "../magicnumber_data/1995 All The News and Views.iso";
#my $cdimage = "../magicnumber_data/Albero Azzurro (Italy).iso";
#my $cdimage = "../magicnumber_data/Burn Cycle (UE).iso";
#my $cdimage = "../magicnumber_data/Chaos Control.iso";
#my $cdimage = "../magicnumber_data/Space Ace.iso";

# Panasonic - 3DO
#my $cdimage = "../magicnumber_data/3D Atlas (USA).iso";
#my $cdimage = "../magicnumber_data/Ballz - The Director's Cut (USA).iso";
#my $cdimage = "../magicnumber_data/Belzerion (Japan).iso";

# Nintendo - Nintendo 3DS
#my $cdimage = "../magicnumber_data/4 Elements (Europe).3ds";
#my $cdimage = "../magicnumber_data/Angry Birds - Star Wars (Europe).3ds";
#my $cdimage = "../magicnumber_data/Angry Birds - Star Wars (USA).3ds";

# Sega - Dreamcast
#my $cdimage = "../magicnumber_data/4 Wheel Thunder v1.002 (2000)(Midway)(Europe)(en-fr)[!].iso";
#my $cdimage = "../magicnumber_data/Army Men - Sarge's Heroes v1.001 (2000)(Midway)(Europe)[!].iso";
#my $cdimage = "../magicnumber_data/Chicken Run v1.000 (2000)(EIDOS)(NTSC)(USA)[!].iso";

# SNK - Neo Geo CD
#my $cdimage = "../magicnumber_data/2020 Super Baseball (Japan) (En,Ja).iso";
#my $cdimage = "../magicnumber_data/King of Fighters '94, The (Japan) (En,Ja) (Rev A).iso";
#my $cdimage = "../magicnumber_data/Samurai Spirits - Amakusa Kourin ~ Samurai Shodown IV - Amakusa's Revenge (Japan) (En,Ja,Es,Pt).iso";

# Playstation - Works detect system
#y $cdimage = "../magicnumber_data/007 - The World Is Not Enough (USA).iso"; #ps1
#my $cdimage = "../magicnumber_data/3D Baseball (USA).iso"; #ps1
#my $cdimage = "../magicnumber_data/007 Racing (USA).iso"; #ps1
#my $cdimage = "../magicnumber_data/Hot Shots Golf (USA).iso"; #ps1

# Nintendo - Gamecube - Works detect system and get serial
#my $cdimage = "../magicnumber_data/All-Star Baseball 2002 (USA).iso"; #gc
#my $cdimage = "../magicnumber_data/007 - Nightfire (USA).iso"; #gc 
#my $cdimage = "../magicnumber_data/Amazing Island (USA).iso"; #gc

# Playstation Portable - Works detect system and get serial
#my $cdimage = "../magicnumber_data/0005 - Lumines (USA) (v1.01).iso";
#my $cdimage = "../magicnumber_data/12Riven - The Psi-Climinal of Integral (Japan) (v1.02).iso";
#my $cdimage = "../magicnumber_data/Air Conflicts - Aces of World War II (USA).iso";
#my $cdimage = "../magicnumber_data/Buzz! Brain of the UK (Europe) (v1.01).iso";

# Nintendo - Nintendo Wii
#my $cdimage = "../magicnumber_data/Angry Birds Trilogy (USA) (En,Fr).iso";
#my $cdimage = "../magicnumber_data/007 - Quantum of Solace (USA) (En,Fr).iso";
#my $cdimage = "../magicnumber_data/Biohazard (Japan).iso";

# Sega Saturn - Works detect system and get serial
#my $cdimage = "../magicnumber_data/Last Bronx (USA).iso"; #saturn
#my $cdimage = "../magicnumber_data/Alien Trilogy (Japan).iso";
#my $cdimage = "../magicnumber_data/Alien Trilogy (USA).iso";

# Sega CD - Works detect system and get serial
#my $cdimage = "../magicnumber_data/3 Ninjas Kick Back (1994)(Sony Imagesoft)(NTSC)(US)(Track 01 of 12)[!].iso";
#my $cdimage = "../magicnumber_data/Adventures of Batman & Robin, The (1995)(Sega)(PAL)(Track 1 of 7)[!].iso";

#check command line
my $substringh = "-h";
my $directory = "";
my $cdimage = "";

foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "magicscan v0.5 - Generate disc code serials from a directory scan\n";
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

foreach my $element (@linesf) {
   $progress->update($_);
  
   if (lc substr($element, -4) eq '.iso') {

    #Detect CSO
    if (lc substr($cdimage, -4) eq '.cso') {
  
      open(CSO, $cdimage) or die "Could not open file '$cdimage' $!";
      binmode CSO;
   
      seek CSO, 0, 0;
      $read = read CSO, $magic, 4;
  
      if ($magic eq "CISO") {
   
        #print "CSO:  TRUE\n";
   
      }  
  
      close CSO;
	  exit;
    }

    #Detect system
    my $systemname = "Unknown";
    my $temp;

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

    #----------------------- Detect systems
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
	
	#GAMECUBE
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
	
	#SNK - Neo Geo CD
	$offset = 0x8008;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 20;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "APPLE COMPUTER, INC.")
       {
          $systemname = "SNK - Neo Geo CD";
       }
    }
	
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
	$offset = 0x0000;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 7;
	if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\x01\x5a\x5a\x5a\x5a\x5a\x01")
       {
         $offset = 0x0028;
	     seek FILE, $offset, 0;
         $read = read FILE, $magic, 6;
         if ($read > 0)
         {
            if ($magic ne "" and (uc $magic eq "CD-ROM"))
            {
               $systemname = "Panasonic - 3DO";
            }
         }
	   }
	}
	
	#Philips - CDi
	$offset = 0x8001;
	seek FILE, $offset, 0;
    $read = read FILE, $magic, 14;
    if ($read > 0)
    {
       if ($magic ne "" and $magic eq "\x43\x44\x2d\x49\x20\x01\x00\x43\x44\x2d\x52\x54\x4f\x53")
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
	
    #--------------------------------- Get Serials

    my $pos;
    my $game_id = "Unknown";

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

      seek(FILE, 0, 0);
      if (read(FILE, $game_id, 6) > 0)
      {

      } 
    } elsif ($systemname eq "Sega - Mega CD & Sega CD") {

      seek(FILE, 0x0183, 0);
      if (read(FILE, $game_id, 7) > 0)
      {

      }
    } elsif ($systemname eq "Sega - Saturn") {

      seek(FILE, 0x0020, 0);
      if (read(FILE, $game_id, 7) > 0)
      {

      }
    } elsif ($systemname eq "Sega - Dreamcast") {

      seek(FILE, 0x0040, 0);
      if (read(FILE, $game_id, 7) > 0)
      {

      }  
    } elsif ($systemname eq "Nintendo - Nintendo Wii") {

      seek(FILE, 0x0000, 0);
      if (read(FILE, $game_id, 6) > 0)
      {

      } 
    }

    print LOG "File name: $element\n";
    print LOG "System: $systemname\n";
    print LOG "Game ID: $game_id\n";
	print LOG "\n";

    close FILE;
  }
}
print "\nwriting:  serial_log.txt\n";
close LOG;