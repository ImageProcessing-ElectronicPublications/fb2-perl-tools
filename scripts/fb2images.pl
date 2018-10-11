#!/usr/bin/perl

use fb2::Images;
use Getopt::Long qw(HelpMessage VersionMessage);
use strict;

=head1 NAME

fb2images.pl - manipulate embedded images in the FictionBook file

=head1 SYNOPSIS

B<fb2images.pl> [B<--extract> I<image.id>] [B<--remove> I<image.id>] [B<--add> I<filename.png>] [B<--list>] I<filename.fb2>

=head1 DESCRIPTION

This utility allows to add new images into FB2 file, remove images, extract images and
list them.

Several operations can be performed during one operation.
First, utility extracts images, then removes ones to remove,
then adds all images to add and then lists images.

Input image names are used as E<lt>binaryE<gt> element ids.

=head1 BUGS

Utility doesn't check if image reference presents in the file, and is
unable to add references.

=head1 VERSION

0.02.2

=head1 COPYRIGHT AND LICENSE

Copyright 2006-2011 by Swami Dhyan Nataraj (Nikolay Shaplov)

This library is free software; you can redistribute it and/or modify
it under the terms of the General Public License (GPL).  For
more information, see http://www.fsf.org/licenses/gpl.txt

=cut

my $flags={};
my $opts={};
  GetOptions (help=>sub {HelpMessage(); },
                                  version=>sub {VersionMessage(); },
              "list|l" => \$opts->{'list'},
              "extract|x=s@" => \$opts->{'extract'},
              "add|a=s@"=> \$opts->{'add'},
              "remove|r=s@"=>\$opts->{'remove'}
             ) or exit(1);
  $opts->{'list'}=1 if @ARGV && ! %{$opts};
  my $FileName= $ARGV[0];

  my $parser = XML::LibXML->new();
  my $doc = $parser->parse_file($FileName);

  if ( $opts->{'extract'} )
  {
    fb2::Images::ExtractImages($doc,$opts,$flags);
  }
  if ( $opts->{'add'} )
  {
    fb2::Images::AddImages($doc,$opts,$flags);
  }
  if ( $opts->{'remove'} )
  {
    fb2::Images::RemoveImages($doc,$opts,$flags);
  }
  if ($opts->{'list'})
  {
    my $imagelist = fb2::Images::getImageList($doc);
    fb2::Images::printImageList($imagelist);
  }

  if ($flags->{'changed'})
  {
        my $backup = $FileName . "~";
        unlink $backup;
        rename $FileName, $backup or warn("Cannot make backup copy: $!");
        my $data = $doc->toString;
        open DST,">",$FileName;

        print DST $data;
        close DST;
  }
