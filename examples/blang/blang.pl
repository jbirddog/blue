#!/usr/bin/perl

use strict;
use warnings;

my @kw = qw(
  halt
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
);

my %op = map { $kw[$_] => sprintf("%02X", $_) } 0..$#kw;
my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split " ", $prog;
my @bytes = map { chr hex($op{$_} || $_) } @tokens;

print @bytes;
