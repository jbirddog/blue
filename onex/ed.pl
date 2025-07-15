#!/usr/bin/perl

use autodie;
use strict;
use warnings;

use constant {
	BLK_SIZE => 1024,

	BC_FIN => 0x00,
	BC_WORD_DEFINE => 0x01,
	BC_WORD_END => 0x02,
	BC_WORD_EXEC => 0x03,
	BC_WORD_CADDR => 0x04,
	BC_WORD_RADDR => 0x05,
	BC_NUM_COMP => 0x06,
	BC_NUM_EXEC => 0x07,
	BC_ED_NL => 0x08,
};

my @bc_lens = (
	0,
	8,
	0,
	8,
	8,
	8,
	8,
	8,
	0,
);

my @bc_fmts = (
	"\x1B[33;1;3mfin\x1B[0m ",
	"\x1B[31;1m%s ",
	"\x1B[33;1;3m;\x1B[0m ",
	"\x1B[33;1m%s ",
	"\x1B[35;1m%s ",
	"\x1B[37;1m%s ",
	"\x1B[32;1m%02X ",
	"\x1B[33;1m%02X ",
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

		my $fmt = $bc_fmts[$b];
		my $len = $bc_lens[$b];

		my $data = substr($bc, $here, $len);
		$here += $len;

		$data = ord($data) if $len == 1;
		$data = unpack("Q", $data) if $b == BC_NUM_COMP || $b == BC_NUM_EXEC;

		$display .= sprintf($fmt, $data);
		
		last if $b == BC_FIN;
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
