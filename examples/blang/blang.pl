#!/usr/bin/perl

use strict;
use warnings;

my @ops = qw(
  halt
  depth
  b>
  =
);

my %kw_to_op = map { $ops[$_] => sprintf("%X", $_) } 0..$#ops;

my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split /\s+/, $prog;
my @bytes = map { chr hex($kw_to_op{$_} || $_) } @tokens;

print @bytes;
