#!/usr/bin/perl

use fb2::Normalize;
use strict;

if (! @ARGV) { print "
FB2 Normalize
Usage: fb2normalize.pl <inputfile.fb2>
";exit 0;}

  my $FileName = $ARGV[0];
  my $parser = XML::LibXML->new();
  my $root = $parser->parse_file($FileName)->getDocumentElement();

  fb2::Normalize::normalize_branch($root);

  my $data = $root->toString();
  my $backup = $FileName . "~";
  unlink $backup;
  rename $FileName, $backup or warn("Cannot make backup copy: $!");
  open DST,">",$FileName;
  print DST $data;
  close DST;
