#!/usr/bin/perl

use strict;
use warnings;

my %kw_to_op = qw(
  halt 00
);

my $prog = join " ", grep { /^[^#]/ } <STDIN>;
my @tokens = split /\s+/, $prog;
my @bytes = map { chr hex($kw_to_op{$_} || $_) } @tokens;

print @bytes;
