# Copyright 2006-2011 by Swami Dhyan Nataraj (Nikolay Shaplov)
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
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
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package fb2::Normalize;
#normalize FictionBook file

use XML::LibXML;
our $VERSION=0.02.2;

my @inline_elsments=('a', 'book-name', 'book-title', 'city', 'code', 'custom-info', 'date', 
'email', 'emphasis', 'first-name', 'genre', 'home-page', 'id', 'isbn', 'image', 'keywords', 'lang', 'last-name', 
'middle-name', 'nickname', 'p', 'part', 'program-used', 'publish-info', 'publisher', 'sequence', 'src-lang', 'src-ocr', 
'src-url', 'strikethrough', 'strong', 'sub', 'subtitle', 'sup', 'text-author', 'v', 'version', 'year');
my %inline_elements_hash=();

foreach (@inline_elsments)
{
  $inline_elements_hash{$_}=1;
}

sub normalize_branch
{
  my $branch = shift;
  my $level = shift;
  foreach ($branch->getChildNodes())
  {
    normalize_text_node($_) if ($_->nodeType() == XML_TEXT_NODE);
  }
  my @children=$branch->getChildNodes();
  if (! $inline_elements_hash{$branch->nodeName()} )
  {
    my $count=1;
    foreach my $node (@children)
    {
      my $new_node=$branch->getOwnerDocument()->createTextNode("\n  ".$level);
      $branch->insertBefore ($new_node,$node);
      $count++;
    }
    my $new_node=$branch->getOwnerDocument()->createTextNode("\n".$level);
    $branch->insertBefore ($new_node,undef); # adding as last node
  }
  foreach (@children)
  {
    normalize_branch($_,$level."  ") if ($_->nodeType() == XML_ELEMENT_NODE);
  }
}

sub normalize_text_node
{
  my $text_node=shift;
  return 0 if ( $text_node->nodeType() != XML_TEXT_NODE );
  my $text=$text_node->getData();
  $text=~s/\s+/ /g;
  $text=~s/^ //g;
  $text=~s/ $//g;
  if ($text eq '')
  {
    $text_node->getParentNode()->removeChild($text_node);
  } else
  {
    $text_node->setData($text);
  }
}

1;
