#!/usr/bin/perl

use strict;
use warnings;

my @kw = split " ", q(
  exit
  call
  depth
  litb
  =
  assert
  drop
  not
  swap
  [
  ]
  start
  -
  +
  b@
  here
  execute
  ret
  b!+
  here!
  b,
  !+
  ,
  d!+
  d,
  @
  dup
  >r
  r>
);

my %op = map { $kw[$_] => sprintf("%02X", $_) } 0..$#kw;
my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split " ", $prog;
my @bytes = map { chr hex($op{$_} || $_) } @tokens;

print @bytes;
