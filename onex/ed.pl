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
	BC_COMP_QWORD => 0x04,
	BC_ED_NL => 0x05,
};

my @bc_lens = (
	0,
	8,
	8,
	1,
	8,
	0,
);

my @bc_fmts = (
	"",
	"\x1B[31;1m%s ",
	"\x1B[33;1m%s ",
	"\x1B[32;1m%02X ",
	"\x1B[32;1m%08X ",
	"\n",
);

my $bc_file = $ARGV[0];
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, BLK_SIZE;
	close $in;
}

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
