#!/usr/bin/perl

use strict;
use warnings;

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

my %op = map { $kw[$_] => sprintf("%02X", $_) } 0..$#kw;

=pod
=cut

my $prog = <STDIN>;

$prog = q/
: bye (( -- ))
  BF b, 05 d,
  B8 b, 3C d,
  0F b, 05 b,
  C3 b,
;

bye
/;

$prog = 'BF';

$SIG{__WARN__} = sub { die @_ };

my $compiling = 0;
my $here = 0;
my $latest = 0;

sub next_token {
  (my $token, $prog) = split " ", $prog, 2;

  return $token;
};

sub compile_number {
  my $token = shift @_;
  my $number = hex($token);
  my @bytes = ($op{'litb'}, chr($number));

  return \@bytes;
}

sub call_word {
  my $where = $here;
  
  return sub {
    die if $compiling;

    my @bytes = (
      $op{'start'}, $op{'litb'}, chr($where), $op{'+'},
      $op{'mccall'}
    );
    
    return \@bytes;
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
  $compiling = 0;
}

sub comma {
  my $size = shift @_;

  return sub {
    my @bytes = ($op{$_[0]});
    
    $here += $size;

    return \@bytes;
  };
}

my @code_buffer;

do {
  my $token = next_token();
  my $handler = $dict{$token}{'handler'};
  my @compiled = $handler ? $handler->($token) : compile_number($token);

} while $prog;

push @code_buffer, $op{'depth'};
push @code_buffer, $op{'exit'};

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
