#!/usr/bin/perl -w
# or #!c:/perl/bin/perl.exe -w
# utdep.pl - Check the dependencies of an Unreal Tournament (UT99) file.
# Version: 0.2.0

use strict;
use warnings;

my $debug = 0;

my $map = shift;

unless ($map) {
  print "Usage: perl -w $0 <FileName> [ -h | -n | -i | -d ]\n";
  print "  to print headers, name, imports, or dependencies (default).\n";
  exit;
}

my %headers;
my (@names, @imports, @exports);

open(MAP, "<", $map) or die "Can't open $map: $!";

# get the headers to find the tables.
getHeaders();

# check the file's signature to make sure it's an Unreal Tournament file;
if ($headers{"Signature"} ne "9e2a83c1") {
  # die "Invallid file";   ## Disabled because it fails on 64-bit arch.
}

# get the tables I need to get the dependancies
getNames();
getImports();
getImportNames();

# parseAndRunArgs();

my $arg;

$arg = shift;

unless ($arg) {
  $arg = "-d";
}

while ($arg) {
  if ($arg eq "-h") {
    printHeaders();
  }
  if ($arg eq "-n") {
    printNames();
  }
  if ($arg eq "-i") {
    printImports();
  }
  if ($arg eq "-d") {
    printDependencies();
  }
  # $arg = shift || exit;
  $arg = shift;
}

close(MAP);

#----------------------------------------#
# subroutines used above and for testing #
#----------------------------------------#

sub getHeaders {
  # this shouldn't be an issue, paranoia.
  seek(MAP, 0, 0);
  $headers{"Signature"} = sprintf("%x", ReadLong());
  $headers{"Version"} = ReadShort();
  $headers{"License"} = ReadShort();
  $headers{"Flag"} = ReadLong();
  $headers{"NameCount"} = ReadLong();
  $headers{"NameOffset"} = ReadLong();
  $headers{"ExportCount"} = ReadLong();
  $headers{"ExportOffset"} = ReadLong();
  $headers{"ImportCount"} = ReadLong();
  $headers{"ImportOffset"} = ReadLong();

  # only get the GUID if the version >= 68
  if ($headers{"Version"} >= 68) {
    $headers{"GUID"} = sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong());
  }
}

sub getImports {
  # skip to the imports table
  seek(MAP, $headers{"ImportOffset"}, 0);
  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    my $offset = tell(MAP);
    my $class_package = ReadIndex();
    my $class_name = ReadIndex();
    my $package = ReadLong();
    my $name = ReadIndex();
    $imports[$i] = {"offset" => $offset, "uPackage" => $class_package, "uName" => $class_name, "Package" => $package, "Name" => $name};
  }
}

sub getImportNames {
  for(my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    $imports[$i]->{"_uPackage"} = getName($imports[$i]->{"uPackage"});
    $imports[$i]->{"_uName"} = getName($imports[$i]->{"uName"});
    ## Catch the bug where we fail to parse the file properly, and abort the process instead of looping and spewing errors.
    # if ($imports[$i]->{"Package"} < 0 || $imports[$i]->{"Package"} >= 0) {
    # } else {
      # die "getImportNames(): Package is not a number!"
    # }
    # if (!$imports[$i]->{"Package"}) {
    if ($imports[$i]->{"Package"} eq "") {
      die "getImportNames(): \$import[".$i."]->{\"Package\"} has no value; aborting";
      # die "getImportNames(): Package \"" . ($imports[$i]->{"Package"}) . "\" (".$i.") is not a number; aborting";
    }
    if ($imports[$i]->{"Package"} < 0) {
      my $tmp = $imports[$i]->{"Package"};
      $tmp *= -1;
      $tmp -= 1;
      $imports[$i]->{"_Package"} = getName($imports[$tmp]->{"Name"});
    }
    else {
      $imports[$i]->{"_Package"} = getName($imports[$i]->{"Package"});
    }
    $imports[$i]->{"_Name"} = getName($imports[$i]->{"Name"});
  }
}

sub getName {
  my $i = shift;
  if ($i < 0) {
      return "Engine";
  }
  elsif ($i > $#names) {
    return "Error";
  }
  else {
    return $names[$i]->{"Name"};
  }
}

sub getNames {
  # skip to the name table.
  seek(MAP, $headers{"NameOffset"}, 0);

  my $object;
  my $length;

  for (my $i = 0; $i < $headers{"NameCount"}; $i++) {
    my ($length, $object);
    read(MAP, $length, 1);
      $length = unpack("C", $length);
    read(MAP, $object, $length);
    # $object =~ s/ $//g;

    chop($object);
    my $flag = ReadLong();
    $names[$i] = { "Name" => $object, "Flag" => $flag }; 
    # $debug && print "getNames: name=" . $object . " flag=" . $object . "\n";
  }
}

sub printDependencies {
  # this subroutine can probably be written a lot better but this will do for now.
  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    if ($imports[$i]->{"Package"} == 0) {
      # now we have a package;
      for(my $x = 0; $x < $headers{"ImportCount"}; $x++) {
        if ($imports[$i]->{"_Name"} eq $imports[$x]->{"_Package"}) {
          # there must be some hidden character for I can only use a regexp and not an exact match;
          if ($imports[$x]->{"_uName"} =~ m/Class/) {
            $imports[$i]->{"Type"} = ".u";
            last;
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Texture/) {
            $imports[$i]->{"Type"} = ".utx";
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Sound/) {
            $imports[$i]->{"Type"} = ".uax";
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Music/) {
            $imports[$i]->{"Type"} = ".umx";
          }
	  else {
            # another deeper search for the origin of a package;
            foreach (my $y = 0; $y < $headers{"ImportCount"}; $y++) {
              if ($imports[$x]->{"_Name"} eq $imports[$y]->{"_Package"}) {
                if ($imports[$y]->{"_uName"} =~ m/Class/) {
                  $imports[$i]->{"Type"} = ".u";
                  last;
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Texture/) {
                  $imports[$i]->{"Type"} = ".utx";
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Sound/) {
                  $imports[$i]->{"Type"} = ".uax";
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Music/) {
                  $imports[$i]->{"Type"} = ".umx";
                }
              }
             }
          }
          # if a package is marked as a non .u file it can also be .u package with some imported stuff
          # if it's an .u there's no need to look further though.
          last if ($imports[$i]->{"Type"} and $imports[$i]->{"Type"} eq ".u");
        }
        # same here.
          last if ($imports[$i]->{"Type"} and $imports[$i]->{"Type"} eq ".u");
        }
        print $imports[$i]->{"_Name"};
        if ($imports[$i]->{"Type"}) {
          print $imports[$i]->{"Type"} . "\n";
        }
        else {
        print ".???\n";
      }
    }
  }
}

sub printHeaders {
  print "Headers:";
  print "\n  Signature: " . $headers{"Signature"};
  print "\n  Version: " . $headers{"Version"};
  print "\n  License: " . $headers{"License"};
  print "\n  Flag: " . $headers{"Flag"};
  print "\n  Name Count: " . $headers{"NameCount"};
  print "\n  Name Offset: " . $headers{"NameOffset"};
  print "\n  Export Count: " . $headers{"ExportCount"};
  print "\n  Export Offset: " . $headers{"ExportOffset"};
  print "\n  Import Count: " . $headers{"ImportCount"};
  print "\n  Import Offset: " . $headers{"ImportOffset"};

  # only print the GUID if the version >= 68
  if ($headers{"Version"} >= 68) {
    print "\n  GUID: " . $headers{"GUID"} 
  }

  print "\n\n";
}

sub printImports {
  print "Imports:";

  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    print "\n  Import $i: ";
    print join(".", $imports[$i]->{"_uPackage"}, $imports[$i]->{"_uName"}, $imports[$i]->{"_Package"}, $imports[$i]->{"_Name"});
  }
  print "\n\n";
}

sub printNames {
  print "Names";
  for (my $i = 0; $i < $headers{"NameCount"}; $i++) {
    print "\n  Name $i: " . $names[$i]->{"Name"};
  }
  print "\n\n";
}

sub ReadIndex {
  # read an index coded section from MAP, I really have no idea what I'm doing
  # here, just copied the code from the original script but it seems to work ok

  my $buffer;
  my $neg;

  for(my $i = 0; $i < 5; $i++) {
    my $more = 0;
    my $char;
    read(MAP, $char, 1);
    $char = vec($char, 0, 8);
    my $length = 6;

    if ($i == 0) {
      $neg = ($char & 0x80);
      $more = ($char & 0x40);
      $buffer = ($char & 0x3F);
    }
    elsif ($i == 4) {
      $buffer |= ($char & 0x80) << $length;
      $more = 0;
    }
    else {
     $more = ($char & 0x80);
     $buffer |= ($char & 0x7F) << $length;
     $length += 7;
    }
    last unless ($more);
  }

  if ($neg) {
    $buffer *= -1;
  }

  # $debug && print "ReadIndex returning buffer: " . $buffer . "\n";
  return $buffer;

}

sub ReadLong {
  my $string;
  my $char = read(MAP, $string, 4);
  return unpack("l", $string);
}

sub ReadShort {
  my $string;
  read(MAP, $string, 2);
  return unpack("S", $string);
}

=head1 NAME

  utdep.pl - retrieve the dependencies of a unreal tournament package.
  Version: 0.2.0

=head1 DESCRIPTION

  This script will extract the headers, index and import table from an unreal
  tournament package (usually a map package) and return a list of packages on
  which the package depends.

=head1 USAGE

  perl -w utdep.pl <package> ?-h? ?-n? ?-i? ?-d? [windows/linux/mac]
  utdep.pl <package> ?-h? ?-n? ?-i? ?-d? [linux]

  There are several commandline arguments but their use is intended
  for debugging and when there is something wrong with the dependancies list.

  -h print the headers
  -n print the name table
  -i print the import table
  -d print the dependencies list (default)

=head1 CHANGELOG

  version 0.2.0
    added some POD documentation

  version 0.1.1
    removed last character of the names
    added commandline options to print tables (nogginBasher)

  version 0.1.0
    Basic script

=head1 BUGS

   The script was tested on UT99/GOTY maps, it might work for other packages
   and/or UT versions as well. Testing revealed some bugs, most of them are
   impossible to overcome because of the way unreal packages are constructed.

   The dependencies don't have to be in the same case as the files.

   It's not possible to determine the type of all packages, in this case the
   .??? extention is used.
     Typical packages that go wrong: unrealshare.u

   Not all the packages are printed with the correct extention, the standard
   .u packages export music, sounds or textures too which will confuse the
   script. I haven't found anything to solve this so the best solution is to
   ignore them.
     In theory it's possible to check that package whether it exports the
   required data but this is beyond the intentions of this script.
     Typical packages that go wrong: editor.u, unreali.u, unrealshare.u,
   umenu.u, utmenu.u, uwindow.u

   Sometimes when using this script for an automated check in some maps errors
   occur, however they cannot be repeated when running the script on that map
   alone.

=head1 ACKNOWLEDGEMENTS

  With writing this script I had a lot of help at the Beyond Unreal forums, 
  especially from from Just**Me who gave me an example script to work from.
  You can find the topic with the example script here:
  http://forums.beyondunreal.com/showthread.php?p=2285785

  Other helpfull pages at UnrealWiki:
  http://wiki.beyondunreal.com/wiki/Package_File_Format
  http://wiki.beyondunreal.com/wiki/Package_File_Format/Data_Details

  Thanks to NogginBasher for testing the script.

=head1 COPYRIGHTS & DISCLAMER

  There's no copyright on the script, you may redistribute, adapt and rewrite
  it if you want. I can't be held responsible for any damage of this script did
  to your system, especially not when they are redistributed or addapted by
  other persons. Use the script at your own risk.

=head1 AUTHOR

  Christiaan ter Veen [mail at rork dot nl]
  http://www.rork.nl/
