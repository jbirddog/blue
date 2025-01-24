#!/usr/bin/perl

use strict;
use warnings;

$SIG{__WARN__} = sub { die @_ };

=pod
=cut

my @kw = split " ", q(
  exit
  true false
  if-else
  mccall call
  >r r>
  ret
  [ ]
  ip ip!
  entry
  start
  here here!
  b@ @
  b!+ w!+ d!+ !+
  b, w, d, ,
  litb litw litd lit

  depth dup drop swap
  not = + -
);

=pod
=cut

my %op = map { $kw[$_] => chr $_ } 0..$#kw;

my $prog = <STDIN>;

$prog = q/
: bye
  BF b, 03 d,
  B8 b, 3C d,
  0F b, 05 b,
;

: bye2
  BF b, 05 d,
  B8 b, 3C d,
  0F b, 05 b,
;

bye2
/;

my @code_buffer;
my $compiling = 0;
my $here = 0;
my $latest = 0;

sub next_token {
  (my $token, $prog) = split " ", $prog, 2;

  return $token;
};

sub compile_number {
  my $token = shift @_;
  my $number = chr(hex($token));
  
  push @code_buffer, ($op{'litb'}, $number);
}

sub interpret_word {
  my $where = shift @_;

  push @code_buffer, (
    $op{'start'}, $op{'litb'}, chr($where), $op{'+'},
    $op{'mccall'}
  );
}

sub compile_word {
  #litb E8 b,
  compile_number 'E8';
  comma(1)->('b,');
      
  #start here - litb 04 + d,
  push @code_buffer, ($op{'start'}, $op{'here'}, $op{'-'});
  compile_number '04';
  push @code_buffer, $op{'+'};
  comma(4)->('d,');
}

sub call_word {
  my $where = $here;
  
  return sub {
    $compiling ? compile_word() : interpret_word($where);
  };
}

sub todo { }

my %dict = (
  ':' => {
    handler => \&colon,
  },
  '(('=> {
    handler => \&todo,
  },
  '--' => {
    handler => \&todo,
  },
  '))' => {
    handler => \&todo,
  },
  ';' => {
    handler => \&semi,
  },
  'b,'=> {
    handler => comma(1),
  },
  'd,'=> {
    handler => comma(4),
  },
);

sub colon {
  my $word = next_token();

  $dict{$word} = {
    handler => call_word(),
  };

  $compiling = 1;
  $latest = $here;
}

sub semi {
  compile_number 'C3';
  comma(1)->('b,');
  
  $compiling = 0;
}

sub comma {
  my $size = shift @_;

  return sub {
    $here += $size;
    push @code_buffer, $op{$_[0]};
  };
}

while (1) {
  my $token = next_token();
  last if not $token;
  
  my $handler = $dict{$token}{'handler'};
  $handler ? $handler->($token) : compile_number($token);
};

push @code_buffer, ($op{'depth'}, $op{'exit'});

print @code_buffer;






=pod
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 60 syscall ;
: bye (( -- )) 0 exit ;

bye
=cut

=pod
  litb E8 b,
  start here - litb 04 + d,

my @tokens = split " ", q(
  litb BF b, litb 05 d,
  litb B8 b, litb 3C d,
  litb 0F b, litb 05 b,
  litb C3 b,
  
  here litb 0D - mccall

  depth depth exit
);

{ chr hex($op{$_} || $_) }
=cut
