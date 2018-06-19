#!/usr/bin/perl -w
#use strict;

my ($mphones, $mphones0);

# check usage
if (@ARGV != 2) {
  print "usage: $0 sourcemonophones xw_monophones\n\n"; 
  exit (0);
}

# read in command line arguments
($mphones,$mphones0) = @ARGV;

open (MPHONES,"$mphones") || die ("Unable to open $monophones file for reading");
open (MPHONES0,">$mphones0") || die ("Unable to open $monophones0 file for writing");


#write to the file

my $line;

while( $line = <MPHONES> ){

  chomp($line);
  
  if($line ne "sp" && $line ne "sil"){
	  print MPHONES0 "$line\n";
  }
}

close(MPHONES0);
close(MPHONES);
