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
my $substringr = "-redump";
my $directory = "";
my $cdimage = "";
my $redump = "FALSE";

foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "magicscan v0.8 - Generate disc code serials from a directory scan\n";
	print "\n";
	print "with magicscan [ options ] [directory ...]\n";
    print "\n";
	print "Options:\n";
	print "  -redump    attempts to process the serials into compatiblity with redump curation (otherwise raw)\n";
    print "\n";
	print "Notes:\n";
	print "  [directory] should be the path to the games folder\n";
	print "\n";
	print "Example:\n";
	print '   magicscan -redump "D:/ROMS/Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
  if ($argument =~ /\Q$substringr\E/) {
    $redump = "TRUE";
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

#debug
my $tempstr;
if ($redump eq "TRUE") {
  $tempstr = "redump";
} elsif ($redump eq "FALSE") {
  $tempstr = "raw";
} 
print "serials format: " . $tempstr . "\n";

my $max = scalar(@linesf);
my $progress = Term::ProgressBar->new({name => 'scanning', count => $max});

#Loop each iso and printout
open(LOG, ">", "serial_log.txt") or die "Could not open serial_log.txt\n";
	
my $offset;
my $read;
my $magic;
my $pos;
my $match;
my $count;

foreach my $element (@linesf) {
   $progress->update($_);
   
   my $systemname = "Unknown";
   my $game_id = "Unknown";
   my $region_id = "Unknown";
   
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

    #----- Detect systems ISO --------------------------------------------------------------------------------------------------------
	#---------------------------------------------------------------------------------------------------------------------------------
	
    #----- Sony - PlayStation Portable -----
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
    
	#----- Sony - Playstation -----
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
	
	#----- Nintendo - GameCube -----
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
	
	#----- Sega - Mega CD & Sega CD -----
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
	
	#----- Sega - Saturn -----
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
	
	#----- Sega - Dreamcast -----
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
	
    #----- Nintendo - Nintendo Wii -----
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
	
	#----- Panasonic - 3DO -----
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
		
	#----- Philips - CDi -----
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
	
	#----- NEC - PC Engine CD - TurboGrafx-CD ------
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
	
    #----- Get Serials ISO --------------------------------------------------------------------------------------------------
	#------------------------------------------------------------------------------------------------------------------------
	#----- Sony - PlayStation Portable -----
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

             or ($game_id eq "ULKS-")
             or ($game_id eq "ULAS-")
             or ($game_id eq "ULKS-")

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

	#----- Nintendo - GameCube -----	  
    } elsif ($redump eq "TRUE" and $systemname eq "Nintendo - GameCube") { # redump serial matching code (missing region offset)
      seek(FILE, 0, 0); 
      if (read(FILE, $game_id, 4) > 0) 
      {
        	
		$game_id =~ s/\s+$//; # rule right trim spaces till text
		$game_id = "DL-DOL-" . $game_id; # add prefix
		my $region_id = substr $game_id, -1;
		
		if ($element =~ m/\(Disc 1/i or $element =~ m/\(Disk 1/i) {
		  $game_id = $game_id . "-0";
		} elsif ($element =~ m/\(Disc 2/i or $element =~ m/\(Disk 2/i) {
		  $game_id = $game_id . "-1";
		}

		if ($region_id eq "E") {
		  $game_id = $game_id . "-USA";
		} elsif ($region_id eq "J") {
		  $game_id = $game_id . "-JPN";
		} elsif ($region_id eq "P") {
		  $game_id = $game_id . "-EUR";  # P can also be P-UKV, P-AUS
		} elsif ($region_id eq "X") {
		  $game_id = $game_id . "-EUR";  # X can also be X-UKV, X-EUU
		} elsif ($region_id eq "Y") {
		  $game_id = $game_id . "-FAH";
		} elsif ($region_id eq "D") {
		  $game_id = $game_id . "-NOE";
		} elsif ($region_id eq "S") {
		  $game_id = $game_id . "-ESP";
		} elsif ($region_id eq "F") {
		  $game_id = $game_id . "-FRA";
		} elsif ($region_id eq "I") {
		  $game_id = $game_id . "-ITA";
		} elsif ($region_id eq "H") {
		  $game_id = $game_id . "-HOL";
		}
      }  
    } elsif ($redump eq "FALSE" and $systemname eq "Nintendo - GameCube") {
      seek(FILE, 0, 0); # 0
      if (read(FILE, $game_id, 6) > 0)
      {

      } 
	  
	#----- Sega - Mega CD & Sega CD -----  
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Mega CD & Sega CD") {
      seek(FILE, 0x0183, 0);
      if (read(FILE, $game_id, 11) > 0) {

	      $game_id =~ s/\s+$//; # rule right trim spaces till text
		  $game_id =~ s/ //; # rule all spaces with no spacea 
		  #$count = () = $game_id =~ /-/g; # count total number of hyphens

          my $rhyphenpos;
          my $lgame_id;
          my $rgame_id;
  	      
          my $checkth =  substr $game_id, 0, 2;
          my $checkgh =  substr $game_id, 0, 2;
		  my $checkmkh =  substr $game_id, 0, 3;
		  my $check50 = substr $game_id, -2, 2;
          my $count = 0;
		  my $length = length $game_id;
		  
		  if ($checkth eq "T-") {
		     $rhyphenpos = rindex($game_id, "-");
	  		 $game_id = substr $game_id, 0, $rhyphenpos;
		  } elsif ($checkgh eq "G-") {
		     $rhyphenpos = rindex($game_id, "-");
	  		 $game_id = substr $game_id, 0, $rhyphenpos;
          } elsif ($checkmkh eq "MK-") {
		     if ($check50 eq "50") {
			   $lgame_id = substr $game_id, 3, 4;
			   $rgame_id = "-50";
			   $game_id = $lgame_id . $rgame_id
			 } else {
			   $game_id = substr $game_id, 3, 4;
			 }
		  }
	  }
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Mega CD & Sega CD") {
	  seek(FILE, 0x0183, 0);
      if (read(FILE, $game_id, 11) > 0)
      {

      }
	  
	#----- Sega - Saturn -----
	} elsif ($redump eq "TRUE" and $systemname eq "Sega - Saturn") {
      seek(FILE, 0x0020, 0);
      if (read(FILE, $game_id, 9) > 0) {
	  	 
		 $game_id =~ s/\s+$//; # rule right trim spaces till text
		 
	     my $rhyphenpos;
         my $lgame_id;
         my $rgame_id;
  	      
         my $checkth =  substr $game_id, 0, 2;
         my $checkmkh =  substr $game_id, 0, 3;
		 my $count = 0;
		 my $length = length $game_id;
		  
         seek(FILE, 0x0040, 0);
		 if (read(FILE, $region_id, 1) > 0) {
		    if ($region_id eq "U") {
		      if ($checkmkh eq "MK-") {
                 $game_id = substr $game_id, 3;
              }			  
			} elsif ($region_id eq "E") {
			  $lgame_id = substr $game_id, 0, 2;
              $rgame_id = substr $game_id, 3;
			  $game_id = $lgame_id .  $rgame_id;
			  $game_id = $game_id . "-50";
			}
		 }
      }
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Saturn") {
	   seek(FILE, 0x0020, 0);
       if (read(FILE, $game_id, 9) > 0)
       {
    
       }
	  
	#----- Sega - Dreamcast -----  
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Dreamcast") { #redump code
      seek(FILE, 0x0040, 0);
      if (read(FILE, $game_id, 10) > 0) {
	  
	      $game_id =~ s/\s+$//; # rule right trim spaces till text
		  $game_id =~ s/  / /; # rule replace 2 spaces with 1 space 
	      $game_id =~ s/ /-/g; # rule replace spaces with hyphens
		  #$game_id =~ s/--/-/g; # exception if we replaced two spaces in a row, make it single
		  $count = () = $game_id =~ /-/g; # count total number of hyphens
		 		
          my $rhyphenpos;
          my $lgame_id;
          my $rgame_id;
  	      
          my $checkth =  substr $game_id, 0, 2;
          my $checkt =  substr $game_id, 0, 1;
          my $checkhdrh =  substr $game_id, 0, 4;
		  my $checkhdr =  substr $game_id, 0, 3;
		  my $checkmkh =  substr $game_id, 0, 3;
		  my $checkmk =  substr $game_id, 0, 2;
          my $count = 0;
		  my $length = length $game_id;
		  
		  if ($checkth eq "T-") {
		      $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back T
		      } elsif ($count == 1 and $length <= 7) {
			    $game_id = substr $game_id, 0, 7;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 7;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
			  } else {
			  	 $lgame_id = substr $game_id, 0, 1;
 		  		 $rgame_id = substr $game_id, 1;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
		      }
		  } elsif ($checkt eq "T") {
			  $lgame_id = substr $game_id, 0, 1;
 			  $rgame_id = substr $game_id, 1, (length $game_id); # rule put a hyphen after T
			  $game_id = $lgame_id . "-" . $rgame_id;
		      $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back T
		      } elsif ($count == 1 and $length <= 7) {
			    $game_id = substr $game_id, 0, 8;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 7;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
			  } else {
			  	 $lgame_id = substr $game_id, 0, 1;
 		  		 $rgame_id = substr $game_id, 1;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
		      }
		  } elsif ($checkhdrh eq "HDR-") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
		  	  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -4, 4;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back HDR
		      }
		  } elsif ($checkhdr eq "HDR") {
		  	  $lgame_id = substr $game_id, 0, 3;
			  $rgame_id = substr $game_id, 4;
			  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after HDR
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
		  	  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -4, 4;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back HDR
		      }
		  } elsif ($checkmkh eq "MK-") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back MR
		      } elsif ($count == 1 and $length <= 8) {
			    $game_id = substr $game_id, 0, 8;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 8;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
			  } else {
			  	 $lgame_id = substr $game_id, 0, 2;
 		  		 $rgame_id = substr $game_id, 2;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
		      }
		  } elsif ($checkmk eq "MK") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back MR
		      } elsif ($count == 1) {
				 $lgame_id = substr $game_id, 0, 8;
 		  		 if (length($lgame_id) == 8) {
				   $rgame_id = "";
				   $game_id = $lgame_id;
				 } else {
				   $rgame_id = substr $game_id, -2, 2;
				   $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
				 }
			  } else {
			  	 $lgame_id = substr $game_id, 0, 2;
 		  		 $rgame_id = substr $game_id, 2;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
		      }
		  }
		}
      } elsif ($redump eq "FALSE" and $systemname eq "Sega - Dreamcast") {
      seek(FILE, 0x0040, 0);
      if (read(FILE, $game_id, 10) > 0)
      {

      } 
	  
	#----- Nintendo - Nintendo Wii -----
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
	
    #----- Detect systems BIN --------------------------------------------------------------------------------------------------------
	#---------------------------------------------------------------------------------------------------------------------------------
	#----- Nintendo - GameCube -----
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
	
    #----- Sega - Dreamcast -----
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

    #----- Nintendo - Nintendo Wii -----
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
	
	#----- Sega - Mega CD & Sega CD -----
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
	
	#----- Sega - Saturn -----
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
	
	#----- Sony - Playstation Portable -----
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
	
	#----- Panasonic - 3DO -----
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
	
	#----- Philips - CDi -----
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
	
	#----- Sony - Playstation -----
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
	
    #----- Get Serials BIN --------------------------------------------------------------------------------------------------
	#------------------------------------------------------------------------------------------------------------------------
    #----- Nintendo - GameCube -----
     if ($redump eq "TRUE" and $systemname eq "Nintendo - GameCube") { # redump serial matching code (missing region offset)
      seek(BIN, 0, 0); # 0 seems right, 2 to match redump serials
      if (read(BIN, $game_id, 4) > 0) # 6 seems right, 4 to match redump
      {
        	
		$game_id =~ s/\s+$//; # rule right trim spaces till text
		$game_id = "DL-DOL-" . $game_id; # add prefix
		my $region_id = substr $game_id, -1;
		
		if ($element =~ m/\(Disc 1/i or $element =~ m/\(Disk 1/i) {
		  $game_id = $game_id . "-0";
		} elsif ($element =~ m/\(Disc 2/i or $element =~ m/\(Disk 2/i) {
		  $game_id = $game_id . "-1";
		}
		
		if ($region_id eq "E") {
		  $game_id = $game_id . "-USA";
		} elsif ($region_id eq "J") {
		  $game_id = $game_id . "-JPN";
		} elsif ($region_id eq "P") {
		  $game_id = $game_id . "-EUR";  # P can also be P-UKV, P-AUS
		} elsif ($region_id eq "X") {
		  $game_id = $game_id . "-EUR";  # X can also be X-UKV, X-EUU
		} elsif ($region_id eq "Y") {
		  $game_id = $game_id . "-FAH";
		} elsif ($region_id eq "D") {
		  $game_id = $game_id . "-NOE";
		} elsif ($region_id eq "S") {
		  $game_id = $game_id . "-ESP";
		} elsif ($region_id eq "F") {
		  $game_id = $game_id . "-FRA";
		} elsif ($region_id eq "I") {
		  $game_id = $game_id . "-ITA";
		} elsif ($region_id eq "H") {
		  $game_id = $game_id . "-HOL";
		}
      }  
    } elsif ($redump eq "FALSE" and $systemname eq "Nintendo - GameCube") {
      seek(BIN, 0, 0); # 0
      if (read(BIN, $game_id, 6) > 0)
      {

      }

    #----- Nintendo - Nintendo Wii -----
    } elsif ($systemname eq "Nintendo - Nintendo Wii") {
      seek(BIN, 0x0000, 0);
      if (read(BIN, $game_id, 6) > 0)
      {

      } 

    #----- ega - Dreamcast -----
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Dreamcast") { #redump code
      seek(BIN, 0x0050, 0);
      if (read(BIN, $game_id, 10) > 0) {
	  
	      $game_id =~ s/\s+$//; # rule right trim spaces till text
		  $game_id =~ s/  / /; # rule replace 2 spaces with 1 space 
	      $game_id =~ s/ /-/g; # rule replace spaces with hyphens
		  #$game_id =~ s/--/-/g; # exception if we replaced two spaces in a row, make it single
		  $count = () = $game_id =~ /-/g; # count total number of hyphens
		 		
          my $rhyphenpos;
          my $lgame_id;
          my $rgame_id;
  	      
          my $checkth =  substr $game_id, 0, 2;
          my $checkt =  substr $game_id, 0, 1;
          my $checkhdrh =  substr $game_id, 0, 4;
		  my $checkhdr =  substr $game_id, 0, 3;
		  my $checkmkh =  substr $game_id, 0, 3;
		  my $checkmk =  substr $game_id, 0, 2;
          my $count = 0;
		  my $length = length $game_id;
		  
		  if ($checkth eq "T-") {
		      $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back T
		      } elsif ($count == 1 and $length <= 7) {
			    $game_id = substr $game_id, 0, 7;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 7;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
			  } else {
			  	 $lgame_id = substr $game_id, 0, 1;
 		  		 $rgame_id = substr $game_id, 1;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
		      }
		  } elsif ($checkt eq "T") {
			  $lgame_id = substr $game_id, 0, 1;
 			  $rgame_id = substr $game_id, 1, (length $game_id); # rule put a hyphen after T
			  $game_id = $lgame_id . "-" . $rgame_id;
		      $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back T
		      } elsif ($count == 1 and $length <= 7) {
			    $game_id = substr $game_id, 0, 8;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 7;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
			  } else {
			  	 $lgame_id = substr $game_id, 0, 1;
 		  		 $rgame_id = substr $game_id, 1;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after T
		      }
		  } elsif ($checkhdrh eq "HDR-") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
		  	  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -4, 4;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back HDR
		      }
		  } elsif ($checkhdr eq "HDR") {
		  	  $lgame_id = substr $game_id, 0, 3;
			  $rgame_id = substr $game_id, 4;
			  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after HDR
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
		  	  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -4, 4;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back HDR
		      }
		  } elsif ($checkmkh eq "MK-") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back MR
		      } elsif ($count == 1 and $length <= 8) {
			    $game_id = substr $game_id, 0, 8;
			  } elsif ($count == 1 and $length > 8) {
				  $lgame_id = substr $game_id, 0, 8;
				  $rgame_id = substr $game_id, -2, 2;
				  $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
			  } else {
			  	 $lgame_id = substr $game_id, 0, 2;
 		  		 $rgame_id = substr $game_id, 2;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
		      }
		  } elsif ($checkmk eq "MK") {
		  	  $count = () = $game_id =~ /-/g; # count total number of hyphens
			  if ($count >= 2) { #special case if 2 or more hypens exist from our previous replace
		         $rhyphenpos = rindex($game_id, "-");
		  		 $lgame_id = substr $game_id, 0, $rhyphenpos;
 		  		 $rgame_id = substr $game_id, -2, 2;
		  		 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen in back MR
		      } elsif ($count == 1) {
				 $lgame_id = substr $game_id, 0, 8;
 		  		 if (length($lgame_id) == 8) {
				   $rgame_id = "";
				   $game_id = $lgame_id;
				 } else {
				   $rgame_id = substr $game_id, -2, 2;
				   $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
				 }
			  } else {
			  	 $lgame_id = substr $game_id, 0, 2;
 		  		 $rgame_id = substr $game_id, 2;
				 $game_id = $lgame_id . "-" . $rgame_id; # rule put a hyphen after MR
		      }
		  }
		}
      } elsif ($redump eq "FALSE" and $systemname eq "Sega - Dreamcast") {
      seek(BIN, 0x0050, 0);
      if (read(BIN, $game_id, 10) > 0)
      {

      } 
	  
	#----- Sega - Mega CD & Sega CD -----
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Mega CD & Sega CD") {
      seek(BIN, 0x0193, 0);
      if (read(BIN, $game_id, 11) > 0) {

	      $game_id =~ s/\s+$//; # rule right trim spaces till text
		  $game_id =~ s/ //; # rule all spaces with no spacea 
		  #$count = () = $game_id =~ /-/g; # count total number of hyphens

          my $rhyphenpos;
          my $lgame_id;
          my $rgame_id;
  	      
          my $checkth =  substr $game_id, 0, 2;
          my $checkgh =  substr $game_id, 0, 2;
		  my $checkmkh =  substr $game_id, 0, 3;
		  my $check50 = substr $game_id, -2, 2;
          my $count = 0;
		  my $length = length $game_id;
		  
		  if ($checkth eq "T-") {
		     $rhyphenpos = rindex($game_id, "-");
	  		 $game_id = substr $game_id, 0, $rhyphenpos;
		  } elsif ($checkgh eq "G-") {
		     $rhyphenpos = rindex($game_id, "-");
	  		 $game_id = substr $game_id, 0, $rhyphenpos;
          } elsif ($checkmkh eq "MK-") {
		     if ($check50 eq "50") {
			   $lgame_id = substr $game_id, 3, 4;
			   $rgame_id = "-50";
			   $game_id = $lgame_id . $rgame_id
			 } else {
			   $game_id = substr $game_id, 3, 4;
			 }
		  }
	  }
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Mega CD & Sega CD") {
	  seek(BIN, 0x0193, 0);
      if (read(BIN, $game_id, 11) > 0)
      {

      }

    #----- Sega - Saturn -----
	} elsif ($redump eq "TRUE" and $systemname eq "Sega - Saturn") {
      seek(BIN, 0x0030, 0);
      if (read(BIN, $game_id, 9) > 0) {
	  	 
		 $game_id =~ s/\s+$//; # rule right trim spaces till text
		 
	     my $rhyphenpos;
         my $lgame_id;
         my $rgame_id;
  	      
         my $checkth =  substr $game_id, 0, 2;
         my $checkmkh =  substr $game_id, 0, 3;
		 my $count = 0;
		 my $length = length $game_id;
		  
         seek(BIN, 0x0050, 0);
		 if (read(BIN, $region_id, 1) > 0) {
		    if ($region_id eq "U") {
		      if ($checkmkh eq "MK-") {
                 $game_id = substr $game_id, 3;
              }			  
			} elsif ($region_id eq "E") {
			  $lgame_id = substr $game_id, 0, 2;
              $rgame_id = substr $game_id, 3;
			  $game_id = $lgame_id .  $rgame_id;
			  $game_id = $game_id . "-50";
			}
		 }
      }
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Saturn") {
	   seek(BIN, 0x0030, 0);
       if (read(BIN, $game_id, 9) > 0)
       {
    
       }
	   
	#----- Sony - Playstation Portable -----
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

             or ($game_id eq "ULKS-")
             or ($game_id eq "ULAS-")
             or ($game_id eq "ULKS-")
			 
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

  #----- Detect systems 3DS --------------------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------------------------------------------	
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