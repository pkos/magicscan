use strict;
use warnings;
use String::Scanf;

my $cdimage = "H:/ROMS/3 Ninjas Kick Back (USA).chd";

my $SECTOR_SIZE = 2352;
my $SUBCODE_SIZE = 96;
my $TRACK_PAD = 4;


#typedef struct metadata {
#   char type[64];
#   char subtype[32];
#   char pgtype[32];
#   char pgsub[32];
#   uint32_t frame_offset;
#   uint32_t frames;
#   uint32_t pad;
#   uint32_t extra;
#   uint32_t pregap;
#   uint32_t postgap;
#   uint32_t track;
#} metadata_t;

my $track;
my $postgap;
my $pregap;
my $extra;
my $pad;
my $frames;
my $frame_offset;
my $pgsub;
my $pgtype;
my $subtype;
my $type;

my $offset;
my $read;

#load CHD metadata
#chdstream_get_meta(chd_CHD *chd, int idx, metadata_t *md)

   my $meta;
   my $meta_size = 0;
   #char meta[256];
   #chd_error err;

sub padding_frames {
   $frames = @_;
   return (($frames + $TRACK_PAD - 1) & ~($TRACK_PAD - 1)) - $frames;
}

sub chdstream_get_meta {
   
   open(CHD, $cdimage) or die "Could not open CHD '$cdimage' $!";
   binmode CHD;
   
   #format: CDROM_TRACK_METADATA2_FORMAT
   $offset = 0x0092;
   seek CHD, $offset, 0;
   $read = read CHD, $track, 1;
   
   $offset = 0x0099;
   seek CHD, $offset, 0;
   $read = read CHD, $type, 9;
   
   $offset = 0x00ab;
   seek CHD, $offset, 0;
   $read = read CHD, $subtype, 4;

   $offset = 0x00b7;
   seek CHD, $offset, 0;
   $read = read CHD, $frames, 5;
 
   $offset = 0x00c4;
   seek CHD, $offset, 0;
   $read = read CHD, $pregap, 1;

   $offset = 0x00cd;
   seek CHD, $offset, 0;
   $read = read CHD, $pgtype, 5;

   $offset = 0x00d9;
   seek CHD, $offset, 0;
   $read = read CHD, $pgsub, 4;

   $offset = 0x00e6;
   seek CHD, $offset, 0;
   $read = read CHD, $postgap, 1;

   $offset = 0x00d9;
   seek CHD, $offset, 0;
   $read = read CHD, $pgsub, 4;

   $offset = 0x00d9;
   seek CHD, $offset, 0;
   $read = read CHD, $pgsub, 4;
   
   
   close CHD;
   return ($track, $postgap, $pregap, $frames, $pgsub, $pgtype, $subtype, $type);
}

sub chdstream_find_track_number{

   my $trackin = @_;
   my $i;
   my $frame_offset = 0;
   my $true = "TRUE";
   for ($i = 0, $true eq "TRUE", ++$i)
   {
      ($track, $postgap, $pregap, $frames, $pgsub, $pgtype, $subtype, $type) = chdstream_get_meta;

      if ($trackin == $track) {
         $frame_offset = 0;
         return $track;
      }

      $frame_offset += $frames + $extra;
   }
}

sub chdstream_find_special_track {

   my $i;
   my $iter;
   my $largest_track = 0;
   my $largest_size = 0;

   #for ($i = 1; $true eq "TRUE"; ++i)
   #{
   
   #{
   #      if (track == CHDSTREAM_TRACK_LAST && i > 1)
   #      {
   #         *meta = iter;
   #         return true;
   #      }
   #      else if (track == CHDSTREAM_TRACK_PRIMARY && largest_track != 0)
   #         return chdstream_find_track_number(fd, largest_track, meta);
   #   }

   #   switch (track)
   #   {
   #      case CHDSTREAM_TRACK_FIRST_DATA:
   #         if (strcmp(iter.type, "AUDIO"))
   #         {
   #            *meta = iter;
   #            return true;
   #         }
   #         break;
   #      case CHDSTREAM_TRACK_PRIMARY:
   #         if (strcmp(iter.type, "AUDIO") && iter.frames > largest_size)
   #         {
   #            largest_size = iter.frames;
   #            largest_track = iter.track;
   #         }
   #         break;
   #      default:
   #         break;
   #   }
   #}
}





  ($track, $postgap, $pregap, $frames, $pgsub, $pgtype, $subtype, $type) = chdstream_get_meta;
  
  print "track: $track\n";
  print "postgap: $postgap\n";
  print "pregap: $pregap\n";
  print "frames: $frames\n";
  print "pgsub: $pgsub\n";
  print "pgtype: $pgtype\n";
  print "subtype: $subtype\n";
  print "type: $type\n";

