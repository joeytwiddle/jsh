#!/usr/bin/perl
# (That's a guess!)

eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && 
eval 'exec perl -S $0 $argv:q'
if 0;

######################################################################
#
# pdfrotate - rotates each page in a pdf file by a given angle
#  
# NB! This script modifies files in place. 
#     Backup is saved to 'filename.bak'.
#     
# I use the script to rotate pdf files produced by the following commands: 
# LaTeX2e (containing landscape specials) -> dvips -> ps2pdf
#  
# It will probably fail on landscape-files produced in other ways.
# If you make improvements to, or fix bugs in, this command,
# please mail a copy of the new version to me.
#  
# Robert Dick (dickrp@wckn.dorm.clarkson.edu)
#  - bug fixes and small improvements by 
#      Hans Fredrik Nordhaug  (hansfn@mi.uib.no)
#
#########################################################################

BEGIN{$^I='.bak'}

use strict;
  
sub usage();
 
my ($rotation,$bytepos,$in_xref,@table,$rot_com);
 
$rotation = 270;
$bytepos = 0;
$in_xref = 0;
@table = ();

# Parse flags.
if ( $#ARGV < 0) { usage (); 
} elsif ($ARGV[0] =~ m/^-r([0-9]+)$/) {
    shift(@ARGV);
    $rotation = $1;
} elsif ($ARGV[0] =~ m/^-r$/) {
    shift(@ARGV);
    $rotation = shift(@ARGV); }
usage() if ($rotation < 0 or $rotation > 360);  
usage() if (not scalar(@ARGV));

# Process the input files.

while (<>) {
    if (not $in_xref) { 
        print $_;
        
        if (m/^([0-9]+) [0-9]+ obj$/) {
            # Prepare the index.
            $table[$1 - 1] = $bytepos;
        } elsif (m/\/MediaBox \[[0-9]+ [0-9]+ [0-9]+ [0-9]+\]$/) {
            # Rotate each page.
            $rot_com = "/Rotate $rotation\n";
            print $rot_com;
            $bytepos += length($rot_com);
        } elsif (m/^xref$/) {
            # Prepare the index.
            $in_xref = 1;
            push @table, $bytepos;
        }
    } else {
        # Rebuild the xrefs.
        if (m/^[0-9]+ [0-9]+ n\s*$/) {
            printf "%0.10d 00000 n \n", shift(@table);
        } elsif (m/^[0-9]+$/) {
            print shift(@table), "\n";
        } else {
            print $_;
        }
    }
    
    $bytepos += length($_);
}

#-----------------------------------------------------------------------------
sub usage () {
    print "Usage: pdfrotate [-r ...] [file] \n".
        " \t-r  sets angle of rotation (default: 270)\n\n";
        exit -1;
}
