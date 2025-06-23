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

sub zero_pad {
	my $str = shift(@_);
	my $len = shift(@_);

	return $str . ("\x00" x ($len - length($str)));
}

my @bc_lens = (
	0,
	8,
	8,
	1,
);

my @bc_fmts = (
	"",
	"\x1B[31m%s ",
	"\x1B[33;1m%s ",
	"\x1B[32;1m%02X ",
);

my $bc_file = "test.blk";
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, BLK_SIZE;
	close $in;
}

=pod

$bc = "";
$bc .= chr(BC_DEFINE_WORD) . zero_pad("exit", 8);

# 31 c0			xor    eax,eax
$bc .= chr(BC_COMP_BYTE) . chr(0x31);
$bc .= chr(BC_COMP_BYTE) . chr(0xC0);

# b0 3c			mov    al,0x3c
$bc .= chr(BC_COMP_BYTE) . chr(0xB0);
$bc .= chr(BC_COMP_BYTE) . chr(0x3C);

# 40 b7 03		mov    dil,0x3
$bc .= chr(BC_COMP_BYTE) . chr(0x40);
$bc .= chr(BC_COMP_BYTE) . chr(0xB7);
$bc .= chr(BC_COMP_BYTE) . chr(0x03);

# 0f 05			syscall
$bc .= chr(BC_COMP_BYTE) . chr(0x0F);
$bc .= chr(BC_COMP_BYTE) . chr(0x05);

# call exit
$bc .= chr(BC_EXEC_WORD) . zero_pad("exit", 8);

$bc = zero_pad($bc, BLK_SIZE);

=cut

my $cursor = 0;
my $here = 0;
my $display = "\x1B[2J";

while ($here < length($bc)) {
	my $b = ord(substr($bc, $here, 1));
	++$here;
	last if $b == BC_FIN;

	my $fmt = @bc_fmts[$b];
	my $len = @bc_lens[$b];

	my $data = substr($bc, $here, $len);
	$here += $len;
	
	$data = ord($data) if $len == 1;
	
	$display .= sprintf($fmt, $data);
};

$display .= "\x1B[0m\n";

print $display;

open my $out, ">:raw", $bc_file;
print $out $bc;
close $out;
