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

my @bc_lens = qw(
	0,
	8,
	8,
	1,
);

my @bc_fmts = (
	"",
	"\x1B[31m%s ",
	"\x1B[31m%s ",
	"\x1B[31m%s ",
);

my $bc_file = "test.blk";
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, BLK_SIZE;
	close $in;
}

$bc = chr(BC_DEFINE_WORD) . "exit\x00\x00\x00\x00";

$bc .= "\x00" x (BLK_SIZE - length($bc));

my $here = 0;
my $display = "\x1B[2J";

while ($here < length($bc)) {
	my $b = ord(substr($bc, $here, 1));
	++$here;
	last if $b == BC_FIN;

	my $fmt = @bc_fmts[1];
	my $len = @bc_lens[$b];

	my $data = substr($bc, $here, $len);
	$here += $len;
	
	$display .= sprintf($fmt, $data);

	last;
};

$display .= "\x1B[0m\n";

print $display;

open my $out, ">:raw", $bc_file;
print $out $bc;
close $out;
