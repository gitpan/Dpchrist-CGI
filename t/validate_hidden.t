#! /usr/bin/perl -T
#######################################################################
# $Id: validate_hidden.t,v 1.6 2010-12-20 06:05:21 dpchrist Exp $
#
# Test script for validate_hidden().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 8;

use Dpchrist::CGI		qw(
    _calc_checksum
    dump_params
    validate_hidden
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use File::Basename;

$| 				= 1;
$Data::Dumper::Sortkeys 	= 1;

my ($r, @r);
my @e;
my $n   = basename(__FILE__) . __LINE__;
my $nx  = $n . '_ck';
my $v   = basename(__FILE__) . __LINE__;
my @a   = (-name => $n, -value => $v);
my $md5 = _calc_checksum(@a);

$r = eval {
    validate_hidden;
};
ok (								#     1
    $@ =~ /ERROR: requires exactly 2 arguments/,
    'call with no arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_hidden undef, $n;
};
ok (								#     2
    $@ =~ /ERROR: positional argument 0 must be array reference/,
    'call with undefined value should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_hidden \@e, undef;
};
ok (								#     3
    $@ =~ /ERROR: positional argument 1 must be parameter name/,
    'call with undefined value should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_hidden \@e, $n;
};
ok (								#     4
    !$@
    && @e == 0
    && !defined($r),
    'call when no parameters in scalar context should return undef'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

@r = eval {
    validate_hidden \@e, $n;
};
ok (								#     5
    !$@
    && @e == 0
    && @r == 0,
    'call when no parameters in list context should return emtpy array'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r, \@e, $n, $v, $nx, $md5],
		     [qw(@   r   *e   n   v   nx   md5)]),
    dump_params,
);

$r = eval {
    param($n, $v);
    validate_hidden \@e, $n;
};
ok (								#     6
    !$@
    && !defined($r)
    && @e == 2
    && $e[0] =~ /parameter '$nx' is required/
    && $e[1] =~ /parameter '$n' checksum missing/,
    'call with missing checksum should generate error message'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r, \@e, $n, $v],
		     [qw(@   r   *e   n   v)]),
    dump_params,
);

$r = eval {
    @e = ();
    param($nx, basename(__FILE__) . __LINE__);
    validate_hidden \@e, $n;
};
ok (								#     7
    !$@
    && !defined($r)
    && @e == 2
    && $e[0] =~ /parameter '$nx' must contain valid characters/
    && $e[1] =~ /parameter '$n' checksum bad/,
    'call with bad checksum should generate error message'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r, \@e, $n, $v, $nx, $md5],
		     [qw(@   r   *e   n   v   nx   md5)]),
    dump_params,
);

$r = eval {
    @e = ();
    param($nx, $md5);
    validate_hidden \@e, $n;
};
ok (								#     8
    !$@
    && @e == 0
    && defined($r)
    && $r eq $v,
    'call with valid parameter should return value'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r, \@e, $n, $v, $nx, $md5],
		     [qw(@   r   *e   n   v   nx   md5)]),
    dump_params,
);

