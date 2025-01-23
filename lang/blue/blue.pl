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

=pod
=cut

use constant COMPILE => 0;
use constant INTERPRET => 1;

my $mode = INTERPRET;
my %dict = (
  ":" => {
    handler => sub { die "ok?" },
  },
);

my $prog = <STDIN>;

$prog = q/
: bye (( -- ))
  BF b, 05 d,
  B8 b, 3C d,
  0F b, 05 b,
  C3 b,
;

bye
/;

my @tokens = split " ", $prog;
my @bytes = map { $dict{$_}{'handler'}(); } @tokens;

print @bytes;






=pod
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 60 syscall ;
: bye (( -- )) 0 exit ;

bye
=cut

=pod
  litb E8 b,
  start here - litb 04 + d,

my @tokens = split " ", q(
  litb BF b, litb 05 d,
  litb B8 b, litb 3C d,
  litb 0F b, litb 05 b,
  litb C3 b,
  
  here litb 0D - mccall

  depth depth exit
);

{ chr hex($op{$_} || $_) }
=cut
