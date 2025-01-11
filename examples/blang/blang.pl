#!/usr/bin/perl

use strict;
use warnings;

my @kws = qw(
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
);

my %op = map { $kws[$_] => sprintf("%02X", $_) } 0..$#kws;
my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split " ", $prog;
my @bytes = map { chr hex($op{$_} || $_) } @tokens;

print @bytes;
