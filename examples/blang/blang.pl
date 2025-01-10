#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my @ops = qw(
  halt
  depth
  litb
  =
  assert
  drop
  not
  swap
);

my %kw_to_op = map { $ops[$_] => sprintf("%02X", $_) } 0..$#ops;

my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split " ", $prog;
my @bytes = map { chr hex($kw_to_op{$_} || $_) } @tokens;

print @bytes;
