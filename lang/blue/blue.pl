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
my $prog = join " ", <STDIN>;

=pod
: syscall (( num eax -- res eax )) 0F b, 05 b, ;
: exit (( status edi -- noret )) 60 syscall ;
: bye (( -- noret )) 0 exit ;

bye
=cut


my @code_buffer;
my $compiling = 0;
my $here = 0;
my $latest_word = '';

my %dict = (
  ':' => {
    handler => \&colon,
  },
  '(('=> {
    handler => \&double_lparen,
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

sub next_token {
  (my $token, $prog) = split " ", $prog, 2;

  return $token;
};

sub compile_number {
  my $token = shift @_;
  my $number = chr(hex($token));
  
  push @code_buffer, ($op{'litb'}, $number);
}

sub interpret_word_ref {
  (my $word, my $where) = @_;

  push @code_buffer, (
    $op{'start'}, $op{'litb'}, chr($where), $op{'+'},
    $op{'mccall'}
  );
}

sub flow_in {
  my $word = shift @_;
  my $in = $dict{$word}{'in'};

  foreach (@$in) {
    if ($_ eq "edi") {
      compile_number 'BF';
      comma(1)->('b,');
      comma(4)->('d,');
    }
  }
}

sub compile_word_ref {
  (my $word, my $where) = @_;

  flow_in $word;
  
  compile_number 'E8';
  comma(1)->('b,');
  
  push @code_buffer, (
    $op{'litb'}, chr($where),
    $op{'litb'}, chr($here),
    $op{'-'},
    $op{'litb'}, chr(4),
    $op{'-'},
  );
  
  comma(4)->('d,');
}

sub word_ref {
  my $where = $here;
  
  return sub {
    my $word = shift @_;
    
    $compiling ? compile_word_ref($word, $where) : interpret_word_ref($word, $where);
  };
}

sub colon {
  my $word = next_token();

  $dict{$word} = {
    handler => word_ref(),
  };

  $compiling = 1;
  $latest_word = $word;
}

sub double_lparen {
  my @in;
  my @out;
  my $which = \@in;
  
  while (1) {
    my $token = next_token();
    last if $token eq "))";
    next if $token eq "noret";

    if ($token eq "--") {
      $which = \@out;
      next;
    }

    my $reg = next_token();
    push @$which, $reg;
  }

  $dict{$latest_word}{'in'} = \@in;
  $dict{$latest_word}{'out'} = \@out;
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

=pod
=cut

while (1) {
  my $token = next_token();
  last if not $token;
  
  my $handler = $dict{$token}{'handler'};
  $handler ? $handler->($token) : compile_number($token);
};

push @code_buffer, ($op{'depth'}, $op{'exit'});

print @code_buffer;
