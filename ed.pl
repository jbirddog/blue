#!/usr/bin/perl

use autodie;
use strict;
use warnings;

use constant {
	BLK_SIZE => 1024,

	BC_FIN => 0x00,
	BC_DEFINE_WORD => 0x01,
	BC_EXEC_WORD => 0x02,
	BC_COMP_BYTE => 0x03,
	BC_ED_NL => 0x04,
};

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
	"\n",
);

my $bc_file = $ARGV[0];
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, BLK_SIZE;
	close $in;
}

#=pod

sub zero_pad {
	my ($str, $len) = @_;

	return $str . ("\x00" x ($len - length($str)));
}

$bc = "";
$bc .= chr(BC_DEFINE_WORD) . zero_pad("xor", 8);
$bc .= chr(BC_ED_NL);

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

# editor formatting
$bc .= chr(BC_ED_NL);
$bc .= chr(BC_ED_NL);

# call exit
$bc .= chr(BC_EXEC_WORD) . zero_pad("exit", 8);

$bc = zero_pad($bc, BLK_SIZE);

#=cut

my $cursor = 0;
my $cursor_display = "\x1B[37;1m>\x1B[0m";

sub render {
	my $display = "\x1B[2J";
	my $here = 0;
	
	while (1) {
		$display .= $cursor_display if $cursor == $here;
	
		my $b = ord(substr($bc, $here, 1));
		++$here;
		last if $b == BC_FIN;

		my $fmt = $bc_fmts[$b];
		my $len = $bc_lens[$b];

		my $data = substr($bc, $here, $len);
		$here += $len;

		$data = ord($data) if $len == 1;

		$display .= sprintf($fmt, $data);
	};

	$display .= "\x1B[0m\n\n";

	print $display;
}

while (1) {
	render();
	last;

	print "> ";
	my $input = <STDIN>;
	chomp $input;

	last if $input eq "q";
}

#open my $out, ">:raw", $bc_file;
#print $out $bc;
#close $out;
