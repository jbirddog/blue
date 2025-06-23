#!/usr/bin/perl

use autodie;
use strict;

use constant {
	BLK_SIZE => 1024,

	BC_FIN => 0x00,
	BC_DEFINE_WORD => 0x01,
	BC_EXEC_WORD => 0x02,
	BC_COMP_BYTE => 0x03,
};

my $bc_file = "test.blk";
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, BLK_SIZE;
	close $in;
}

$bc .= "\x00" x (BLK_SIZE - length($bc));

my $here = 0;
my $display = "\x1B[2J";

while ($here < length($bc)) {
	my $b = substr($bc, $here, 1);

	last if $b == BC_FIN;

	++$here;
};

print $display;

open my $out, ">:raw", $bc_file;
print $out $bc;
close $out;

