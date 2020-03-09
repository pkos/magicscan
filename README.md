magicscan v0.9 - Generate disc code serials from a directory scan

with `magicscan [ options ] [directory ...] [ system ]`

Options:

  `-redump    attempts to process the serials into compatiblity with redump curation (otherwise raw)`
  `-path      write relative path instead of exact drive letter in playlist`
  `-playlist  creates a RetroArch playlist (.lpl) with names and serials curated from redump.org`
  
  

Notes:

  `[directory] should be the path to the games folder`
  `[system]    should match a RetroArch database to properly configure system icons`
  

Example:

   `magicscan -redump -path -playlist "D:/ROMS/Atari - 2600"`
   

Author:
   Discord - Romeo#3620


 SYSTEMS TO SUPPORT | DETECTS SYSYEM | GETS SERIAL | OUTPUTS
 ------------------ | -------------- | ----------- | -------
 NEC - PC Engine CD - TurboGrafx-CD | iso | 
 Nintendo - GameCube | iso, bin/cue | iso, bin/cue | lpl
 Nintendo - Nintendo 3DS | 3ds | | 
 Nintendo - Nintendo Wii | iso, bin/cue | iso, bin/cue | 
 Panasonic - 3DO | iso, bin/cue |  | 
 Philips - CDi | iso, bin/cue | | |
 Sega - Dreamcast | iso, bin/cue | iso, bin/cue | lpl
 Sega - Mega-CD - Sega CD | iso, bin/cue | iso, bin/cue | lpl
 Sega - Saturn | iso, bin/cue | iso, bin/cue | lpl
 SNK - Neo Geo CD |  | | 
 Sony - Playstation | iso, bin/cue | |            
 Sony - PlayStation Portable | iso, bin/cue | iso, bin/cue | lpl
 
 
 ----------------------------------------------------------------------------------------------------
 
addtomagicmap (magicscan) v0.5 - Utility used for building the magicmap.map file used by magicscan.

with `addtomagicmap [dat file ...] [system]`
Notes:
  `[system]    should match a RetroArch database to properly configure system icons`

Example:
              `addtomagicmap "D:/Atari - 2600.dat" "Atari - 2600"`

Author:
   Discord - Romeo#3620
