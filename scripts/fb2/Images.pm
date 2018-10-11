# Copyright 2006-2011 by Swami Dhyan Nataraj (Nikolay Shaplov)
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package fb2::Images;
#manipulate embedded images in the FictionBook file

use XML::LibXML;
use File::MMagic;
use MIME::Base64 qw(encode_base64);
use Encode;
our $VERSION=0.02.2;

sub printImageList
{
  my $List=shift;
  foreach (@{$List})
  {
    print "$_\n";
  }
}

sub getImageList
{
  my $doc=shift;
  my @list=();

  foreach ($doc->getDocumentElement()->getElementsByTagName('binary' ,0) )
  {
    my $id=$_->getAttribute('id');
    push @list,$id  if ($id)
  }
  return \@list
}

sub getUsedIdList
{
  my $doc=shift;
  my @list=();

  foreach ($doc->getDocumentElement()->getElementsByTagName('*' ,1) )
  {
    my $id=$_->getAttribute('id');
    push @list,$id if $id
  }
  return \@list
}

sub AddImages
{
  my $doc = shift;
  my $opts = shift;
  my $flags = shift;

  foreach (@{$opts->{'add'}})
  {
    my $flag=1;
    my $ImageName=$_;
    print "Adding image $_ ...\n";
    foreach (@{getImageList($doc)})
    {
      if ($_ eq $ImageName)
      {
        print STDERR "Image $ImageName already exist\n";
        $flag=0;
        last;
      }
    }
    if ($flag)
    {
      foreach (@{getUsedIdList($doc)})
      {
        if ($_ eq $ImageName)
        {
          print STDERR "Object $ImageName already exist\n";
          $flag=0;
          last;
        }
      }
    }
    if ($flag)
    {
      my $mm= new File::MMagic;
      my $MimeType=  $mm->checktype_filename($ImageName);
      open(FILE, $ImageName) or die "$!";
      local($/) = undef;
      my $Encoded= encode_base64(<FILE>);
      close (FILE);
      my $NewNode = $doc->createElement('binary');
      $NewNode->setAttribute ('id', $ImageName);
      $NewNode->setAttribute ('content-type',$MimeType);
      $NewNode->appendChild($doc->createTextNode("\n".$Encoded));
      $doc->getDocumentElement()->appendChild($NewNode);
      $doc->getDocumentElement()->appendChild($doc->createTextNode("\n"));
      $flags->{'changed'}=1;
    }
  }
}

sub RemoveImages
{
  my $doc = shift;
  my $opts = shift;
  my $flags = shift;

  my $root=$doc->getDocumentElement();
  foreach (@{$opts->{'remove'}})
  {
    my $ImageName=$_;
    print "Removing image '$_'... ";
    my $flag=1;
    foreach my $binary ($root->getElementsByTagName('binary' ,0))
    {
      if ($binary->getAttribute('id') eq $ImageName)
      {
        while (1)
        {
          my $prev = $binary->getPreviousSibling();
          last until defined($prev);
          last until ($prev->nodeType() == XML_TEXT_NODE && $prev->getData() =~ /^\s*$/ );
          $root->removeChild($prev);
        }
        $root->removeChild($binary);
        print "Done\n";
        $flag=0;
        $flags->{'changed'}=1;
      }
    }
    print "Not Found!\n" if $flag;
  }
}

sub getText
{
  my ($elem) = @_;
  my $text = '';
  for my $node ($elem->getChildNodes())
  {
    if ($node->nodeType() == XML_ELEMENT_NODE)
    {
      $text .= getText($node);
    }
    elsif ($node->nodeType() == XML_TEXT_NODE)
    {
      $text .= $node->getData();
    }
  }
  return $text;
}

sub ExtractImages
{
  my ($doc,$opts,$flags) = @_;

  my $root=$doc->getDocumentElement();
  foreach my $ImageName (@{$opts->{'extract'}})
  {
    print "Extracting image '$ImageName'... ";
    my $flag=1;
    foreach my $binary ($root->getElementsByTagName('binary' ,0))
    {
      if ($binary->getAttribute('id') eq $ImageName)
      {
        my $data = MIME::Base64::decode_base64( getText( $binary ) );
        open(FILE, '>', $ImageName) or die "$!";
        print FILE $data;
        close (FILE);
        print "Done\n";
        $flag=0;
        last;
      }
    }
    print "Not Found!\n" if $flag;
  }
}
