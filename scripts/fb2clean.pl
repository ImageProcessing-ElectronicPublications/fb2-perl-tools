#!/usr/bin/perl

use fb2::Clean;

if (! @ARGV) { print "
FB2 Clean
Usage: fb2clean.pl <inputfile.fb2>
";exit 0;}

fb2::Clean::CleanupFB2($ARGV[0]);
