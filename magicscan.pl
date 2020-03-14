use strict;
use warnings;
use Term::ProgressBar;

#"SYSTEMS TO SUPPORT"                            "DETECT SYSYEM"  "GET SERIAL"    "OUTPUT"
# NEC - PC Engine CD - TurboGrafx-CD             iso
# Nintendo - GameCube                            iso, bin/cue     iso, bin/cue    lpl
# Nintendo - Nintendo 3DS                        3ds
# Nintendo - Nintendo Wii                        iso, bin/cue     iso, bin/cue
# Panasonic - 3DO                                iso, bin/cue
# Philips - CDi                                  iso, bin/cue
# Sega - Dreamcast                               iso, bin/cue     iso, bin/cue    lpl
# Sega - Mega-CD - Sega CD                       iso, bin/cue     iso, bin/cue    lpl
# Sega - Saturn                                  iso, bin/cue     iso, bin/cue    lpl
# SNK - Neo Geo CD                               
# Sony - Playstation                             iso, bin/cue         
# Sony - PlayStation Portable                    iso, bin/cue     iso, bin/cue    lpl

#----- check command line -----
my $relative = "FALSE";
my $substringh = "-h";
my $substringr = "-redump";
my $substringp = "-playlist";
my $substringpath = "-path";
my $directory;
my $cdimage = "";
my $redump = "FALSE";
my $playlist = "FALSE";
my $system;
my $path;
my $readline;
my $originalredumpserial = "";
my $foundingamemap;
my @linesmapsystem = "";
my @linesmapname = "";
my @linesmapserial = "";
my @linesfredump = "";

foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "magicscan v0.9 - Generate disc code serials from a directory scan\n";
	print "\n";
	print "with magicscan [ options ] [directory ...] [ system ]\n";
    print "\n";
	print "Options:\n";
	print "  -redump    attempts to process the serials into compatiblity with redump curation (otherwise raw)\n";
	print "  -path      write relative path instead of exact drive letter in playlist\n";
	print "  -playlist  creates a RetroArch playlist (.lpl) with names and serials curated from redump.org\n";
    print "\n";
	print "Notes:\n";
	print "  [directory] should be the path to the games folder\n";
    print "  [system]    should match a RetroArch database to properly configure system icons\n";
	print "\n";
	print "Example:\n";
	print '   magicscan -redump -path -playlist "D:/ROMS/Atari - 2600" "Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
  if ($argument =~ /\Q$substringr\E/) {
    $redump = "TRUE";
  }
  if ($argument =~ /\Q$substringp\E/) {
    $playlist = "TRUE";
  }
  if ($argument =~ /\Q$substringpath\E/) {
    $relative = "TRUE";
  }
}

#----- set directory and system -----
if (scalar(@ARGV) < 1 or scalar(@ARGV) > 5) {
  print "Invalid command line.. exit\n";
  print "use: magicscan -h\n";
  print "\n";
  exit;
}
$system = $ARGV[-1];
$directory = $ARGV[-2];
$directory =~ s/\\/\//g; 

#---- exit no parameters -----
if ($directory eq "" or $system eq "") {
  print "Invalid command line.. exit\n";
  print "use: magicscan -h\n";
  print "\n";
  exit;
}

#----- read games directory to @linesf -----
my @linesf;
my $discpath = $directory;
opendir(DIR, $directory) or die "Could not open $directory\n";
while (my $filename = readdir(DIR)) {
  if (-d $filename) {
    next;
  } else {
    push(@linesf, $filename) unless $filename eq '.' or $filename eq '..';    
  }
}
closedir(DIR);

#----- debug terminal output -----
my $tempstr;
if ($redump eq "TRUE") {
  $tempstr = "redump";
} elsif ($redump eq "FALSE") {
  $tempstr = "raw";
} 
print "serials format: " . $tempstr . "\n";
if ($playlist eq "TRUE") {
  print "relative path: $relative\n";
}

#---- create playlist header -----
if ($playlist eq "TRUE") {
  open(LPL, ">", $system . ".lpl") or die "Could not open $system" . ".lpl\n";

  #----- read redump curated map to @linesmap -----
  open(MAP, "<", "magicmap.map") or die "Couls not open magicmap,map\n";
  while (my $readline = <MAP>) {
    $readline =~ s/[\x0A\x0D]//g;
    my @templine = split /,,/ , $readline;
    if ($templine[0] = $system) {
    #print "$templine[0] " . "$templine[1] " . "$templine[2]\n";
	  push(@linesmapsystem, $templine[0]);
      push(@linesmapname, $templine[1]);
	  push(@linesmapserial, $templine[2]);
      next;  
    }  
  }
  close (MAP);
  print "map file: magicmap.map\n";
  
  #----- init varibles for playlist -----
  my $version = '  "version": "1.2",';
  my $default_core_path = '  "default_core_path": "",';
  my $default_core_name = '  "default_core_name": "",';
  my $label_display_mode = '  "label_display_mode": 0,';
  my $right_thumbnail_mode = '  "right_thumbnail_mode": 0,';
  my $left_thumbnail_mode = '  "left_thumbnail_mode": 0,';
  my $items = '  "items": [';
  my $romname = '';
  my $zipfile = '';

  #----- write playlist header -----
  print LPL "{\n";
  print LPL "$version\n";
  print LPL "$default_core_path\n";
  print LPL "$default_core_name\n";
  print LPL "$label_display_mode\n";
  print LPL "$right_thumbnail_mode\n";
  print LPL "$left_thumbnail_mode\n";
  print LPL "$items\n";
  
} elsif ($playlist eq "FALSE" and $redump eq "TRUE") {
  
  #----- read redump curated map to @linesmap -----
  open(MAP, "<", "magicmap.map") or die "Couls not open magicmap,map\n";
  while (my $readline = <MAP>) {
    $readline =~ s/[\x0A\x0D]//g;
    my @templine = split /,,/ , $readline;
    if ($templine[0] = $system) {
    #print "$templine[0] " . "$templine[1] " . "$templine[2]\n";
	  push(@linesmapsystem, $templine[0]);
      push(@linesmapname, $templine[1]);
	  push(@linesmapserial, $templine[2]);
      next;  
    }  
  }
  close (MAP);
}

#----- init progress bar -----
my $max = scalar(@linesf);
my $progress = Term::ProgressBar->new({name => 'scanning', count => $max});

#----- open log file -----
if ($redump eq "TRUE") {
  open(LOG, ">", "redump_serial_log.txt") or die "Could not open redump_serial_log.txt\n";
} elsif ($redump eq "FALSE") {
  open(LOG, ">", "raw_serial_log.txt") or die "Could not open raw_serial_log.txt\n";
}

#----- init detect and get serial variables -----
my $offset;
my $read;
my $magic;
my $pos;
my $match;
my $count;
my $extlen;

#----- MAIN LOOP OF EACH FILE SCANNED --------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
foreach my $element (@linesf) {
   $progress->update($_);
   
   my $rperiodpos = rindex($element, ".");
   my $systemname = "Unknown";
   my $game_id = "Unknown";
   my $region_id = "Unknown";
   my $rhyphenpos = rindex($element, ".");
   my $gamename = substr $element, 0, $rhyphenpos;
      
   #----- Detect systems ISO --------------------------------------------------------------------------------------------------------
   #---------------------------------------------------------------------------------------------------------------------------------
   if (lc substr($element, -4) eq '.iso') {

    #Detect system
	my $discfilename = "$discpath" . "/" . "$element";
    open(FILE, $discfilename) or die "Could not open file '$discfilename' $!";
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
	
	#----- Sega - Mega-CD - Sega CD -----
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
               $systemname = "Sega - Mega-CD - Sega CD";
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
      if ((read FILE, $magic, 7) > 0) {

        if (uc substr($magic, 0, 6) eq "CD-ROM" and $match = "TRUE") {
	      $systemname = "Panasonic - 3DO";
		  last;
		} elsif (uc substr($magic, 0, 7) eq "SAMPLER" and $match = "TRUE") {
		  $systemname = "Panasonic - 3DO";
		  last;
		} elsif (uc substr($magic, 0, 4) eq "TECD" and $match = "TRUE") {
		  $systemname = "Panasonic - 3DO";
		  last;
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
	#-------------------------------------------------------------------------------------------------------------------------
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
			 or ($game_id eq "UCKS-")

             or ($game_id eq "NPEH-")
             or ($game_id eq "NPUH-")
             or ($game_id eq "NPJH-")
             or ($game_id eq "NPHH-")
			 
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
	  
	#----- Sega - Mega-CD - Sega CD -----  
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Mega-CD - Sega CD") {
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
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Mega-CD - Sega CD") {
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
    	
    #----- Write playlist entry ISO --------------------------------------------------------------------------------------------------
	#----------------------------------------------------------------------------------------------------------------------------------
	
	#----- playlist TRUE and redump TRUE -----
	if ($playlist eq "TRUE" and $redump eq "TRUE") {	  
	  if ($relative eq "FALSE") {
        $path = '      "path": ' . '"' . "$discpath" . "/" . "$element" . '",';
      } else {
	    my $discpath = substr($discpath, 2, length($discpath));
		my $discname = substr($element,0,length($element));
        $path = '      "path": ' . '"..' . "$discpath" . "/" . "$discname" . '",';
      }
	  
	  my $i = 0;
	  my $redumpname;
	  
	  #----- main loop compare disc serial ($game_id) to magicmap.map and create playlist entry name and serial -----
	  PLAYLIST: foreach my $checkserial (@linesmapserial) {
	    if ($checkserial =~ /, /) {
          my @linesmapserialsplit = split($checkserial, ', ');
		  foreach my $checkserialmultiple (@linesmapserialsplit) {
		    if ($checkserialmultiple =~ / /) {
			  $originalredumpserial = $checkserialmultiple;
			  my $check1 = $checkserialmultiple;
			  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		      my $check2 = $game_id;
			  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			  $foundingamemap = "FALSE";
			  if ($check1 eq $check2) {
			    $foundingamemap = "TRUE";
				push(@linesfredump, $originalredumpserial);
		        $redumpname = $linesmapname[$i];
				$game_id = $originalredumpserial;
				last PLAYLIST;
			  }
			} elsif ($checkserialmultiple =~ /-/) {
			  my $check1 = $checkserialmultiple;
			  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		      my $check2 = $game_id;
			  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			  $foundingamemap = "FALSE";
			  if ($check1 eq $check2) {
			    $foundingamemap = "TRUE";
				push(@linesfredump, $checkserialmultiple);
		        $redumpname = $linesmapname[$i];
				$game_id = $checkserialmultiple;
				last PLAYLIST;
			   }
			}
          }
        } elsif ($checkserial =~ / /) {
	      $originalredumpserial = $checkserial;
		  my $check1 = $checkserial;
		  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
	      my $check2 = $game_id;
		  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
		  $foundingamemap = "FALSE";
		  if ($check1 eq $check2) {
     	    $foundingamemap = "TRUE";
			push(@linesfredump, $originalredumpserial);
		    $redumpname = $linesmapname[$i];
		    $game_id = $originalredumpserial;
			$i++;
			last PLAYLIST;
		  }
	    } elsif ($checkserial =~ /-/) {
		  my $check1 = $checkserial;
		  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		  my $check2 = $game_id;
		  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
		  $foundingamemap = "FALSE";
		  if ($check1 eq $check2) {
		    $foundingamemap = "TRUE";
			push(@linesfredump, $checkserial);
		    $redumpname = $linesmapname[$i];
			$game_id = $checkserial;
			$i++;
			last PLAYLIST;
		  }
		}
		$i++;
	  }
	  
	  if ($foundingamemap eq "TRUE") {
        #----- init playlist variables -----
	    my $label = '      "label": "' . "$redumpname" . '"' . ',';
	    my $core_path = '      "core_path": "DETECT",';
        my $core_name = '      "core_name": "DETECT",';
        my $serial = '      "crc32": "' . "$game_id" . '|serial"' . ',';
        my $db_name = '      "db_name": "' . "$system" . '.lpl"';
	    
		#----- write playlist variables to playlist file -----
	    print LPL "    {\n";
        print LPL "$path\n";
        print LPL "$label\n";
        print LPL "$core_path\n";
        print LPL "$core_name\n";
        print LPL "$serial\n";
        print LPL "$db_name\n";
        print LPL "    },\n";
	  }
	  if ($foundingamemap eq "FALSE") {
	    $game_id = $game_id . " (serial not in magicmap.map)";
	  }
	
	#----- playlist FALSE and redump TRUE -----
    } elsif ($playlist eq "FALSE" and $redump eq "TRUE") {
          #----- main loop compare disc serial ($game_id) to magicmap.map -----
		  OUTER: foreach my $checkserialredump (@linesmapserial) {
			 if ($checkserialredump =~ /, /) {
               my @linesmapsserialredumpsplit = split($checkserialredump, ', ');
		       foreach my $checkserialmultiple (@linesmapsserialredumpsplit) {
                 if ($checkserialmultiple =~ / /) {
				   $originalredumpserial = $checkserialredump;
				   my $check1 = $checkserialredump;
				   $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		           my $check2 = $game_id;
				   $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			       $foundingamemap = "FALSE";
				   if ($check1 eq $check2) {
				     $foundingamemap = "TRUE";
				     $game_id = $originalredumpserial;
				     last OUTER;
			       }
				 } elsif ($checkserialredump =~ /-/) {
			       my $check1 = $checkserialredump;
				   $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		           my $check2 = $game_id;
				   $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			       $foundingamemap = "FALSE";
				   if ($check1 eq $check2) {
				     $foundingamemap = "TRUE";
				     $game_id = $checkserialredump;
				     last OUTER;
			       }
			     }
		       }
			 } elsif ($checkserialredump =~ / /) {
				$originalredumpserial = $checkserialredump;
				my $check1 = $checkserialredump;
				$check1 =~ s/ /-/g; # rule replace spaces with hyphens
		        my $check2 = $game_id;
				$check2 =~ s/ /-/g; # rule replace spaces with hyphens
			    $foundingamemap = "FALSE";
				if ($check1 eq $check2) {
				  $foundingamemap = "TRUE";
				  $game_id = $originalredumpserial;
				  last OUTER;
			    }
	         } elsif ($checkserialredump =~ /-/) {
			    my $check1 = $checkserialredump;
				$check1 =~ s/ /-/g; # rule replace spaces with hyphens
		        my $check2 = $game_id;
				$check2 =~ s/ /-/g; # rule replace spaces with hyphens
			    $foundingamemap = "FALSE";
				if ($check1 eq $check2) {
				  $foundingamemap = "TRUE";
				  $game_id = $checkserialredump;
				  last OUTER;
			    }
			 }
		 }
		 if ($foundingamemap eq "FALSE") {
		   $game_id = $game_id . " (serial not in magicmap.map)";
		 }
    
	#----- playlist TRUE and redump FALSE -----
    } elsif ($playlist eq "TRUE" and $redump eq "FALSE") {
	    
		#----- init playlist variables ----
		if ($relative eq "FALSE") {
          $path = '      "path": ' . '"' . "$discpath" . "/" . "$element" . '",';
        } else {
	      my $discpath = substr($discpath, 2, length($discpath));
		  my $discname = substr($element,0,length($element));
          $path = '      "path": ' . '"..' . "$discpath" . "/" . "$discname" . '",';
        }
		my $label = '      "label": "' . "$gamename" . '"' . ',';
	    my $core_path = '      "core_path": "DETECT",';
        my $core_name = '      "core_name": "DETECT",';
		my $serial = '      "crc32": "' . "$game_id" . '|serial"' . ',';
        my $db_name = '      "db_name": "' . "$system" . '.lpl"';
	    
		#----- write playlist variables to playlist file -----
	    print LPL "    {\n";
        print LPL "$path\n";
        print LPL "$label\n";
        print LPL "$core_path\n";
        print LPL "$core_name\n";
        print LPL "$serial\n";
        print LPL "$db_name\n";
        print LPL "    },\n";
	}
	
	#----- Write entry to log file ISO --------------------------------------------------------------------------------------------------
	#----------------------------------------------------------------------------------------------------------------------------------	
	print LOG "File name: $element\n";
    print LOG "System: $systemname\n";
    print LOG "Game ID: $game_id\n";
	print LOG "\n";
	
  #----- Detect systems BIN --------------------------------------------------------------------------------------------------------
  #---------------------------------------------------------------------------------------------------------------------------------
  } elsif (lc substr($element, -4) eq '.cue') {
  
    #Detect system
    my $temp;
    my $cuefile;
	
    #read cue file
    open(FILE, $directory . "/" . $element) or die "Could not open file '$element' $!";
    binmode FILE;
  
    while ($temp = <FILE>) {
      if ($temp =~ /FILE/) {
	    my $resultgamestart = index($temp, 'FILE "');
	    my $resultgameend = rindex($temp, '" BINARY');
	    my $length = $resultgameend - $resultgamestart;
	    $cuefile = substr($temp, $resultgamestart + 6, $length - 6);
	    last;
	  }
	}
    
	#read bin file
	open(BIN, $directory . "/" . $cuefile) or die "Could not open file '$cuefile' $!";
    binmode BIN;
	
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
	
	#----- Sega - Mega-CD - Sega CD -----
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
               $systemname = "Sega - Mega-CD - Sega CD";
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
      if ((read BIN, $magic, 7) > 0) {

        if (uc substr($magic, 0, 6) eq "CD-ROM" and $match = "TRUE") {
	      $systemname = "Panasonic - 3DO";
		  last;
		} elsif (uc substr($magic, 0, 7) eq "SAMPLER" and $match = "TRUE") {
		  $systemname = "Panasonic - 3DO";
		  last;
		} elsif (uc substr($magic, 0, 4) eq "TECD" and $match = "TRUE") {
		  $systemname = "Panasonic - 3DO";
		  last;
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
      seek(BIN, 0, 0); 
      if (read(BIN, $game_id, 4) > 0)
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
	  
	#----- Sega - Mega-CD - Sega CD -----
    } elsif ($redump eq "TRUE" and $systemname eq "Sega - Mega-CD - Sega CD") {
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
	} elsif ($redump eq "FALSE" and $systemname eq "Sega - Mega-CD - Sega CD") {
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
             or ($game_id eq "NPHH-")
			 
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

    #----- Write playlist entry BIN --------------------------------------------------------------------------------------------------
	#----------------------------------------------------------------------------------------------------------------------------------
	
	#----- playlist TRUE and redump TRUE -----
	if ($playlist eq "TRUE" and $redump eq "TRUE") {	  
	  if ($relative eq "FALSE") {
        $path = '      "path": ' . '"' . "$discpath" . "/" . "$element" . '",';
      } else {
	    my $discpath = substr($discpath, 2, length($discpath));
		my $discname = substr($element,0,length($element));
        $path = '      "path": ' . '"..' . "$discpath" . "/" . "$discname" . '",';
      }
	  
	  my $i = 0;
	  my $redumpname;
	  
	  #----- main loop compare disc serial ($game_id) to magicmap.map and create playlist entry name and serial -----
	  PLAYLIST: foreach my $checkserial (@linesmapserial) {
	    if ($checkserial =~ /, /) {
          my @linesmapserialsplit = split($checkserial, ', ');
		  foreach my $checkserialmultiple (@linesmapserialsplit) {
		    if ($checkserialmultiple =~ / /) {
			  $originalredumpserial = $checkserialmultiple;
			  my $check1 = $checkserialmultiple;
			  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		      my $check2 = $game_id;
			  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			  $foundingamemap = "FALSE";
			  if ($check1 eq $check2) {
			    $foundingamemap = "TRUE";
				push(@linesfredump, $originalredumpserial);
		        $redumpname = $linesmapname[$i];
				$game_id = $originalredumpserial;
				last PLAYLIST;
			  }
			} elsif ($checkserialmultiple =~ /-/) {
			  my $check1 = $checkserialmultiple;
			  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		      my $check2 = $game_id;
			  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			  $foundingamemap = "FALSE";
			  if ($check1 eq $check2) {
			    $foundingamemap = "TRUE";
				push(@linesfredump, $checkserialmultiple);
		        $redumpname = $linesmapname[$i];
				$game_id = $checkserialmultiple;
				last PLAYLIST;
			   }
			}
          }
        } elsif ($checkserial =~ / /) {
	      $originalredumpserial = $checkserial;
		  my $check1 = $checkserial;
		  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
	      my $check2 = $game_id;
		  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
		  $foundingamemap = "FALSE";
		  if ($check1 eq $check2) {
     	    $foundingamemap = "TRUE";
			push(@linesfredump, $originalredumpserial);
		    $redumpname = $linesmapname[$i];
		    $game_id = $originalredumpserial;
			$i++;
			last PLAYLIST;
		  }
	    } elsif ($checkserial =~ /-/) {
		  my $check1 = $checkserial;
		  $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		  my $check2 = $game_id;
		  $check2 =~ s/ /-/g; # rule replace spaces with hyphens
		  $foundingamemap = "FALSE";
		  if ($check1 eq $check2) {
		    $foundingamemap = "TRUE";
			push(@linesfredump, $checkserial);
		    $redumpname = $linesmapname[$i];
			$game_id = $checkserial;
			$i++;
			last PLAYLIST;
		  }
		}
		$i++;
	  }
	  
	  if ($foundingamemap eq "TRUE") {
        #----- init playlist variables -----
	    my $label = '      "label": "' . "$redumpname" . '"' . ',';
	    my $core_path = '      "core_path": "DETECT",';
        my $core_name = '      "core_name": "DETECT",';
        my $serial = '      "crc32": "' . "$game_id" . '|serial"' . ',';
        my $db_name = '      "db_name": "' . "$system" . '.lpl"';
	    
		#----- write playlist variables to playlist file -----
	    print LPL "    {\n";
        print LPL "$path\n";
        print LPL "$label\n";
        print LPL "$core_path\n";
        print LPL "$core_name\n";
        print LPL "$serial\n";
        print LPL "$db_name\n";
        print LPL "    },\n";
	  }
	  if ($foundingamemap eq "FALSE") {
	    $game_id = $game_id . " (serial not in magicmap.map)";
	  }
	
	#----- playlist FALSE and redump TRUE -----
    } elsif ($playlist eq "FALSE" and $redump eq "TRUE") {
          #----- main loop compare disc serial ($game_id) to magicmap.map -----
		  OUTER: foreach my $checkserialredump (@linesmapserial) {
			 if ($checkserialredump =~ /, /) {
               my @linesmapsserialredumpsplit = split($checkserialredump, ', ');
		       foreach my $checkserialmultiple (@linesmapsserialredumpsplit) {
                 if ($checkserialmultiple =~ / /) {
				   $originalredumpserial = $checkserialredump;
				   my $check1 = $checkserialredump;
				   $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		           my $check2 = $game_id;
				   $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			       $foundingamemap = "FALSE";
				   if ($check1 eq $check2) {
				     $foundingamemap = "TRUE";
				     $game_id = $originalredumpserial;
				     last OUTER;
			       }
				 } elsif ($checkserialredump =~ /-/) {
			       my $check1 = $checkserialredump;
				   $check1 =~ s/ /-/g; # rule replace spaces with hyphens
		           my $check2 = $game_id;
				   $check2 =~ s/ /-/g; # rule replace spaces with hyphens
			       $foundingamemap = "FALSE";
				   if ($check1 eq $check2) {
				     $foundingamemap = "TRUE";
				     $game_id = $checkserialredump;
				     last OUTER;
			       }
			     }
		       }
			 } elsif ($checkserialredump =~ / /) {
				$originalredumpserial = $checkserialredump;
				my $check1 = $checkserialredump;
				$check1 =~ s/ /-/g; # rule replace spaces with hyphens
		        my $check2 = $game_id;
				$check2 =~ s/ /-/g; # rule replace spaces with hyphens
			    $foundingamemap = "FALSE";
				if ($check1 eq $check2) {
				  $foundingamemap = "TRUE";
				  $game_id = $originalredumpserial;
				  last OUTER;
			    }
	         } elsif ($checkserialredump =~ /-/) {
			    my $check1 = $checkserialredump;
				$check1 =~ s/ /-/g; # rule replace spaces with hyphens
		        my $check2 = $game_id;
				$check2 =~ s/ /-/g; # rule replace spaces with hyphens
			    $foundingamemap = "FALSE";
				if ($check1 eq $check2) {
				  $foundingamemap = "TRUE";
				  $game_id = $checkserialredump;
				  last OUTER;
			    }
			 }
		 }
		 if ($foundingamemap eq "FALSE") {
		   $game_id = $game_id . " (serial not in magicmap.map)";
		 }
    
	#----- playlist TRUE and redump FALSE -----
    } elsif ($playlist eq "TRUE" and $redump eq "FALSE") {
	    
		#----- init playlist variables ----
		if ($relative eq "FALSE") {
          $path = '      "path": ' . '"' . "$discpath" . "/" . "$element" . '",';
        } else {
	      my $discpath = substr($discpath, 2, length($discpath));
		  my $discname = substr($element,0,length($element));
          $path = '      "path": ' . '"..' . "$discpath" . "/" . "$discname" . '",';
        }
		my $label = '      "label": "' . "$gamename" . '"' . ',';
	    my $core_path = '      "core_path": "DETECT",';
        my $core_name = '      "core_name": "DETECT",';
		my $serial = '      "crc32": "' . "$game_id" . '|serial"' . ',';
        my $db_name = '      "db_name": "' . "$system" . '.lpl"';
	    
		#----- write playlist variables to playlist file -----
	    print LPL "    {\n";
        print LPL "$path\n";
        print LPL "$label\n";
        print LPL "$core_path\n";
        print LPL "$core_name\n";
        print LPL "$serial\n";
        print LPL "$db_name\n";
        print LPL "    },\n";
	}

	#----- Write entry to log file ISO --------------------------------------------------------------------------------------------------
	#----------------------------------------------------------------------------------------------------------------------------------	
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
	if ($originalredumpserial ne "") {
	  print LOG "Game ID: $originalredumpserial\n";
	} else {
	  print LOG "Game ID: $game_id\n";
	}
    print LOG "\n";  
  }
}
if ($redump eq "TRUE") {
  print "\nwriting:  redump_serial_log.txt\n";
} elsif ($redump eq "FALSE") {
  print "\nwriting:  raw_serial_log.txt\n";
}
close LOG;
#----- write the end of the playlist -----
if ($playlist eq "TRUE") {
  print LPL "  ]\n";
  print LPL "}\n";
  close LPL;
  #----- clean end comma from playlist -----
    my @lpllines;
	open(LPL, "<", $system . ".lpl") or die "Could not open $system" . ".lpl\n";
    while (my $readline = <LPL>) {
      push(@lpllines, $readline);
    }
    close (LPL);
	my $lengthlpl = scalar(@lpllines);
	$lpllines[$lengthlpl - 3] =~ s/    },/    }/;
    open(LPL, ">", $system . ".lpl") or die "Could not open $system" . ".lpl\n";
    foreach my $outline (@lpllines) {
	  print LPL "$outline";
	}
	close (LPL);
	print "writing:  $system" . ".lpl\n";
}