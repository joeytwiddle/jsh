#!/usr/bin/perl -w

# Copyright 2001, Felix Ritter (Felix.Ritter@gmx.de)
#
# Original script (color mode) Copyright 2000,
# Andreas Widmann (widmann@rz.uni-leipzig.de)
#
# This script is free software; permission to use, copy, modify, and
# distribute this software and its documentation for any purpose without
# fee is hereby granted, provided that both the above copyright notice
# and this permission notice appear in all copies and in supporting
# documentation.
#
# This software is provided "as is" without express or implied warranty
# of any kind.

#introstuff
sub usage_info() {
  print "gnuplot-boxfill.pl\n";
  print "  fills (and outlines) boxes in gnuplot 3.7.1 postscript files\n";
  print "usage:\n";
  print "  gnuplot-boxfill.pl [-c | -g | -p] [-o] [-r] [-z] <ps_in> <ps_out>\n";
  print "options:\n";
  print "  -c         color fill (default)\n";
  print "  -g         gray fill\n";
  print "  -p         pattern fill\n";
  print "  -o         draw outline\n";
  print "  -r         remove \"currentpoint stroke M\" (experimental!)\n";
  print "  -z         outline zero height boxes (experimental!)\n";
  print "arguments:\n";
  print "  <ps_in>    postscript input file\n";
  print "  <ps_out>   postscript output file\n";
}
if ($#ARGV < 1) {
  &usage_info();
  exit(0);
}

$prolog = '/graymode true def

/BfDict 400 dict def 

/dpiranges   [  2540    2400    1693     1270    1200     635      600      0      ] def
/PatFreq     [	10.5833 10.0     9.4055  10.5833 10.0	  10.5833  10.0	   9.375   ] def

/dpi 72 0 matrix defaultmatrix dtransform dup mul exch dup mul add sqrt def

/screenIndex {
	0 1 dpiranges length 1 sub { dup dpiranges exch get 1 sub dpi le {exit} {pop} ifelse } for
} bind def

/CurColors [ 0 0 0 1 0 0 0 1] def

/RealSetgray /setgray load def
/RealSetrgbcolor /setrgbcolor load def
/RealSetcmykcolor {
	4 1 roll
	3 { 3 index add 0 max 1 min 1 exch sub 3 1 roll} repeat 
	RealSetrgbcolor pop
} bind def

/tintCMYK {
	1 tintGray sub CurColors 0 4 getinterval aload pop 	
	4 index mul 5 1 roll										
	3 index mul 5 1 roll										
	2 index mul 5 1 roll										
	mul 4 1 roll												
}bind def
/tintRGB {
	1 tintGray sub CurColors 4 3 getinterval aload pop 	
	1 exch sub 3 index mul 1 exch sub 4 1 roll					
	1 exch sub 2 index mul 1 exch sub 4 1 roll					
	1 exch sub mul 1 exch sub 3 1 roll							
}bind def
/combineColor {
	/tintGray 1 1 CurGray sub CurColors 7 get mul sub def
	graymode not {
		[/Pattern [/DeviceCMYK]] setcolorspace
		tintCMYK CurPat setcolor
	} {
		CurColors 3 get 1.0 ge {
			tintGray RealSetgray
		} {
			graymode {
				tintCMYK
				RealSetcmykcolor
			} {
				tintRGB
				RealSetrgbcolor
			} ifelse
		} ifelse
	} ifelse
} bind def

/patProcDict 5 dict dup begin
	<0f1e3c78f0e1c387> { 3 setlinewidth -1 -1 moveto 9 9 lineto stroke
				4 -4 moveto 12 4 lineto stroke
				-4 4 moveto 4 12 lineto stroke} bind def
	<0f87c3e1f0783c1e> { 3 setlinewidth -1 9 moveto 9 -1 lineto stroke
				-4 4 moveto 4 -4 lineto stroke
				4 12 moveto 12 4 lineto stroke} bind def
	<8142241818244281> { 1 setlinewidth -1 9 moveto 9 -1 lineto stroke
				-1 -1 moveto 9 9 lineto stroke } bind def
	<03060c183060c081> { 1 setlinewidth -1 -1 moveto 9 9 lineto stroke
				4 -4 moveto 12 4 lineto stroke
				-4 4 moveto 4 12 lineto stroke} bind def
	<8040201008040201> { 1 setlinewidth -1 9 moveto 9 -1 lineto stroke
				-4 4 moveto 4 -4 lineto stroke
				4 12 moveto 12 4 lineto stroke} bind def
end def
/patDict 15 dict dup begin
	/PatternType 1 def		
	/PaintType 2 def		
	/TilingType 3 def		
	/BBox [ 0 0 8 8 ] def 	
	/XStep 8 def			
	/YStep 8 def			
	/PaintProc {
		begin
		patProcDict bstring known {
			patProcDict bstring get exec
		} {
			8 8 true [1 0 0 -1 0 8] bstring imagemask
		} ifelse
		end
	} bind def
end def

/setPatternMode {
	pop pop
	dup patCache exch known {
		patCache exch get
	} { 
		dup
		patDict /bstring 3 -1 roll put
		patDict 
		65 PatFreq screenIndex get div dup matrix scale
		makepattern
		dup 
		patCache 4 -1 roll 3 -1 roll put
	} ifelse
	/CurGray 0 def
	/CurPat exch def
	/graymode false def
	combineColor
} bind def
/setGrayScaleMode {
	graymode not {
		/graymode true def
	} if
	/CurGray exch def
	combineColor
} bind def

BfDict begin [
	/fillvals
] { 0 def } forall

/SetPattern { 
	fillvals exch get
	dup type /stringtype eq
	{8 1 setPatternMode} 
	{setGrayScaleMode}
	ifelse
	} bind def

/InitPattern {
	BfDict begin dup
	array /fillvals exch def
	dict /patCache exch def
	end
	} def
/DefPattern {
	BfDict begin
	fillvals 3 1 roll put
	end
	} def

7 InitPattern
0 <03060c183060c081> DefPattern
1 <8040201008040201> DefPattern
2 <0f1e3c78f0e1c387> DefPattern
3 <0f87c3e1f0783c1e> DefPattern
4 <8142241818244281> DefPattern
5 <111111ff111111ff> DefPattern
6 0 DefPattern';

$outlinestyle = 'LTb';
if(grep(/^-o$/, @ARGV) == 1) { $outline = "\ngsave\ncurrentpoint $outlinestyle M redo stroke\ngrestore" }
else { $outline = '' }

#read input file
open(IN, $ARGV[$#ARGV - 1]) || die "Cannot open $ARGV[$#ARGV - 1]\n";
$content = join('', <IN>);
close(IN);

#search patterns
$key = '(-*\d+ -*\d+ M\n)(-*\d+)( -*\d+ V\n)(-*\d+ -*\d+ [RM]\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n)';
#$key = '(-*\d+ -*\d+ M\n)(-*\d+)( -*\d+ V\n)(-*\d+ -*\d+ [RM]\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n)'; #experimental
$box = '(?<!LTb)(\n-*\d+ -*\d+ [RM]\n)(-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n-*\d+ -*\d+ V)';
#$box = '(?<!LTb)(\n-*\d+ -*\d+ [RM]\n)(-*\d+ -*\d+ V\n-*\d+ -*\d+ V\n-*\d+ -*\d+ [LV]\n-*\d+ -*\d+ V)'; #experimental
$endComments = '(%%EndComments[ \t]*\n)';
$sftextcmd = '(/[LRC]show *{)(.*\n.*)(}.*def)';
$mftextcmd = '(/MFshow *{.*\n.*\n.*{)(show)(}.*\n.*} *bind *def)';
$ltTable = '(/LT)([0-8])( { PL \[.*\] ).* DL( } def)';
$bfDLPlace = '(/DL { Color)';

#substitute comments
$content =~ s/(%%Title: ).*$/$1$ARGV[$#ARGV]/m;
$content =~ s/(%%Creator: ).*$/$1gnuplot-boxfill.pl/m;
$content =~ s/(%%CreationDate: ).*$/$1.localtime()/em;

#remove "currentpoint stroke M"
if(grep(/^-r$/, @ARGV) == 1) { $content =~ s/\ncurrentpoint stroke M\n/\n/g }

if(grep(/^-g$/, @ARGV) == 1) {
  #modify colors
  $content =~ s/$bfDLPlace/\/BfDL { Color {8 exch sub 4 div 1 sub 0.15 sub setgray Solid {pop []} if 0 setdash }\n {pop Solid {pop []} if 0 setdash} ifelse } def\n$1/;
  $content =~ s/$ltTable/$1$2$3$2 BfDL$4/g;

  #substitute boxplot commands
  $content =~ s/$key/$1gsave\n\/redo \{0 vpt 1.25 div V $2 0 V 0 vpt 1.75 mul neg V $2 neg 0 V closepath\} bind def\ncurrentpoint M redo fill\ngrestore$outline\n$2 0 R\n$4/g;
  $content =~ s/$box/$1gsave\n\/redo\{$2\} bind def\ncurrentpoint M redo fill\ngrestore$outline/g;

  #modify text output commands
  $content =~ s/$sftextcmd/$1gsave 0 setgray\n$2grestore\n$3/g;
  $content =~ s/$mftextcmd/$1gsave 0 setgray $2 grestore$3/g;
}
elsif(grep(/^-p$/, @ARGV) == 1) {
  #add postscript macros
  $content =~ s/$endComments/$1$prolog\n/;

  #modify colors
  $content =~ s/$ltTable/$1$2$3$2 SetPattern$4/g;

  #substitute boxplot commands
  $content =~ s/$key/$1gsave\n\/redo \{0 vpt 1.25 div V $2 0 V 0 vpt 1.75 mul neg V $2 neg 0 V closepath\} bind def\ncurrentpoint currentpoint M redo gsave 1 setgray fill grestore M redo fill\ngrestore$outline\n$2 0 R\n$4/g;
  $content =~ s/$box/$1gsave\n\/redo\{$2\} bind def\ncurrentpoint currentpoint M redo gsave 1 setgray fill grestore M redo fill\ngrestore$outline/g;

  #modify text output commands
  $content =~ s/$sftextcmd/$1gsave 0 setgray\n$2grestore\n$3/g;
  $content =~ s/$mftextcmd/$1gsave 0 setgray $2 grestore$3/g;
}
else {
  #substitute boxplot commands
  $content =~ s/$key/$1gsave\n\/redo \{0 vpt 1.25 div V $2 0 V 0 vpt 1.75 mul neg V $2 neg 0 V closepath\} bind def\ncurrentpoint M redo fill\ngrestore$outline\n$2 0 R\n$4/g;
  $content =~ s/$box/$1gsave\n\/redo\{$2\} bind def\ncurrentpoint M redo fill\ngrestore$outline/g;
}

#outline zero height boxes
if(grep(/^-z$/, @ARGV) == 1) {
  $boxshort = '(?<!LTb)(\n-*\d+ -*\d+ [RM]\n)(-*\d+ -*\d+ V\n-*\d+ -*\d+ V)(?!\n.*V\n)';
  $content =~ s/$boxshort/$1gsave\n\/redo\{$2\} bind def\ncurrentpoint stroke M redo fill\ngrestore$outline/g;
}

#write to output file
open(OUT, ">$ARGV[$#ARGV]") || die "Cannot open $ARGV[$#ARGV]\n";
print OUT "$content";
close(OUT);
