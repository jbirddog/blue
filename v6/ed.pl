#!/usr/bin/perl

use autodie;
use strict;
use warnings;

use constant {
	SRC_SIZE => 8192,

	BC_FIN => 0x00,
	BC_NUM_COMP => 0x08,
	BC_NUM_PUSH => 0x09,
};

my @bc_lens = (
	0,
	8, 0, 8, 8, 8, 8, 8,
	8, 8,
	0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0,
);

my @bc_fmts = (
	"\x1B[33;1;3mfin\x1B[0m ",
	
	"\x1B[31;1m%s ",
	"\x1B[33;1;3m;\x1B[0m ",
	"\x1B[33;1m%s ",
	"\x1B[32;1m%s ",
	"\x1B[36;1m%s ",
	"\x1B[35;1m%s ",
	"\x1B[37;1m%s ",
	
	"\x1B[32;1m%02X ",
	"\x1B[33;1m%02X ",
	
	"\x1B[33;1;3mdup\x1B[0m ",
	"\x1B[33;1;3m+\x1B[0m ",
	"\x1B[33;1;3m-\x1B[0m ",
	"\x1B[33;1;3mor\x1B[0m ",
	"\x1B[33;1;3mshl\x1B[0m ",

	"\x1B[33;1;3m\$\x1B[0m ",
	"\x1B[37;1;3m\$\x1B[0m ",
	"\x1B[33;1;3m!\x1B[0m ",
	"\x1B[33;1;3m@\x1B[0m ",
	"\x1B[33;1;3mb,\x1B[0m ",
	"\x1B[33;1;3mw,\x1B[0m ",
	"\x1B[33;1;3md,\x1B[0m ",
	"\x1B[33;1;3m,\x1B[0m ",
	
	"\n",
);

my $bc_file = $ARGV[0];
my $bc = "";

if (-e $bc_file) {
	open my $in, "<:raw", $bc_file;
	read $in, $bc, SRC_SIZE;
	close $in;
}

my $bc_len = length($bc);

sub render {
	my $display = "\x1B[2J";
	my $here = 0;
	
	while ($here < $bc_len) {
		my $b = ord(substr($bc, $here, 1));
		++$here;

		my $fmt = $bc_fmts[$b];
		my $len = $bc_lens[$b];

		my $data = substr($bc, $here, $len);
		$here += $len;

		$data = ord($data) if $len == 1;
		$data = unpack("Q", $data) if $b == BC_NUM_COMP || $b == BC_NUM_PUSH;

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
