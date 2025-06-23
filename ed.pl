#!/usr/bin/perl

use strict;

use constant {
	BC_FIN => 0x00,
	BC_DEFINE_WORD => 0x01,
	BC_EXEC_WORD => 0x02,
	BC_COMP_BYTE => 0x03,
};

my $bc = "\x00" x 1024;
my $here = 0;

while ($here < length($bc)) {
	my $b = substr($bc, $here, 1);

	last if $b == BC_FIN;
	
	++$here;
};

print $here;

my $out;
open $out, ">test.blk" or die $!;
print $out $bc;
