#!/usr/bin/perl

use strict;
use warnings;

my @kw = split " ", q(
  exit
  call
  execute
  >r
  r>
  ret
  [
  ]
  start
  here
  here!
  
  depth
  litb
  =
  assert
  drop
  not
  swap
  -
  +
  b@
  b!+
  b,
  !+
  ,
  d!+
  d,
  @
  dup
);

my %op = map { $kw[$_] => sprintf("%02X", $_) } 0..$#kw;
my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split " ", $prog;
my @bytes = map { chr hex($op{$_} || $_) } @tokens;

print @bytes;
