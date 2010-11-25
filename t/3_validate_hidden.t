#! /usr/bin/perl -T
#######################################################################
# $Id: 3_validate_hidden.t,v 1.2 2010-11-25 01:46:07 dpchrist Exp $
#
# Test script for validate_hidden().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests => 7;

use strict;
use warnings;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI		qw( calc_checksum validate_hidden );

local $| 			= 1;
local $Data::Dumper::Sortkeys 	= 1;

my (@r, $s, $s2, @a, @a2, $md5, $t, $t2);

@r = eval {
    validate_hidden();
};
ok (								#     1
    $@ =~ /ERROR: requires exactly one argument/,
    'call with no arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_hidden undef;
};
ok (								#     2
    $@ =~ /ERROR: argument must be a CGI parameter name/,
    'call with undefined value should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_hidden 'foo';
};
ok (								#     3
    !$@
    && @r == 0,
    'call with no CGI parameters should return void'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    $s2 = join ' ', __FILE__, __LINE__;
    @a = (-name => $s, -value => $s2);
    param(@a);
    validate_hidden 'foo';
};
ok (								#     4
    !$@
    && @r == 1
    &&$r[0] =~ /ERROR: parameter 'foo' missing/,
    'call on unknown CGI parameter should return error message'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $s2, \@a, \@r], [qw(@ s s2 a *r)]),
);

@r = eval {
    validate_hidden $s;
};
ok (								#     5
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' checksum missing/,
    'call with missing checksum parameter should return error message'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $s2, \@a, \@r], [qw(@ s s2 a *r)]),
);

@r = eval {
    param(-name => $s . '_ck', -value => __FILE__ . __LINE__);
    validate_hidden $s;
};
ok (								#     6
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' checksum bad/,
    'call with bad checksum parameter should return error message'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $s2, \@a, \@r], [qw(@ s s2 a *r)]),
);

@r = eval {
    $md5 = calc_checksum(@a);
    param(-name => $s . '_ck', -value => $md5);
    validate_hidden $s;
};
ok (								#     7
    !$@
    && @r == 0,
    'call with argument and matching parameters ' .
    'should return void'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $s2, \@a, $md5, \@r],
		     [qw(@   s   s2    a   md5   *r)]),
);

