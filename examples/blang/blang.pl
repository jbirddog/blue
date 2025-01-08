#!/usr/bin/perl

use strict;
use warnings;

my %kw_to_op = qw(
  halt 0x00
);

my $prog = do { local $/; <STDIN> };
my @tokens = split /\s/, $prog;

print @tokens;
