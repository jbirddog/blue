#!/usr/bin/perl

use strict;
use warnings;

my @kw = split " ", q(
  exit
  true false
  if-else
  mccall call
  >r r>
  ret
  [ ]
  ip ip!
  entry
  start
  here here!
  b@ @
  b!+ w!+ d!+ !+
  b, w, d, ,
  litb litw litd lit

  depth dup drop swap
  not = + -
);

my %op = map { $kw[$_] => sprintf("%02X", $_) } 0..$#kw;
my $prog = join " ", grep { /^[^#]/ } <STDIN>;

=pod
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 60 syscall ;
: bye (( -- )) 0 exit ;

bye
=cut

=pod
  litb E8 b,
  here start - litb 04 - d,
=cut

my @tokens = split " ", q(
  litb B8 b, litd 3C 00 00 00 d,
  litb 0F b, litb 05 b,
  litb C3 b,
  
  litb BF b, litd 07 00 00 00 d,
  litb E8 b,
  start here - litb 04 + d,
  litb C3 b,
  
  here litb 0B - mccall

  depth depth exit
);

my @bytes = map { chr hex($op{$_} || $_) } @tokens;

print @bytes;
