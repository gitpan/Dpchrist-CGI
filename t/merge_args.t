#! /usr/bin/perl -T
#######################################################################
# $Id: merge_args.t,v 1.1 2010-11-21 06:47:54 dpchrist Exp $
#
# Test script for merge_args().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 10;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( merge_args );

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my (@a, @a2, $t, $k, $k2, $v, $v2, %h, %h2, $s);

eval {
    merge_args();
};
ok (								#     1
    $@,
    'call with no arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    merge_args(1);
};
ok (								#     2
    $@,
    'call with one argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    merge_args(1, 2, 3);
};
ok (								#     3
    $@,
    'call with three arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    merge_args(1, 2);
};
ok (								#     4
    $@,
    'call with scalar first argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    merge_args([], 2);
};
ok (								#     5
    $@,
    'call with scalar second argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    @a = ();
    merge_args(\@a, {});
};
ok (								#     6
    !$@
    && @a == 0,
    'call with empty arg list and empty arg hash ' .
    'should return empty argument list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a], [qw(@ *a)]),
);

eval {
    $k = join ' ', __FILE__, __LINE__;
    $v = join ' ', __FILE__, __LINE__;
    @a = ($k => $v);
    merge_args(\@a, {});
};
ok (								#     7
    !$@
    && @a == 2
    && $a[0] eq $k
    && $a[1] eq $v,
    'call with arg list and empty arg hash ' .
    'should return arg list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \@a], [qw(@ k v *a)]),
);

eval {
    $k = join ' ', __FILE__, __LINE__;
    $v = join ' ', __FILE__, __LINE__;
    %h = ($k => $v);
    @a2 = @a = ();
    merge_args(\@a2, \%h);
};
ok (								#     8
    !$@
    && @a2 == 2
    && $a2[0] eq $k
    && $a2[1] eq $v,
    'call with empty arg list and arg hash ' .
    'should put args from hash into list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, \@a, \@a2],
		     [qw(@   k   v   *h   *a   *a2)]),
);

eval {
    $k = join ' ', __FILE__, __LINE__;
    $v = join ' ', __FILE__, __LINE__;
    %h = ($k => $v);
    $k2 = join ' ', __FILE__, __LINE__;
    $v2 = join ' ', __FILE__, __LINE__;
    @a2 = @a = ($k2, $v2);
    merge_args(\@a2, \%h);
    %h2 = @a2;
};
ok (								#     9
    !$@
    && @a2 == 4
    && $h2{$k} eq $v
    && $h2{$k2} eq $v2,
    'call with arg list and different arg hash ' .
    'should return both args in list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, $k2, $v2, \@a, \@a2, \%h2],
		     [qw(@   k   v   *h   k2   v2    a    a2    h2)]),
);

eval {
    $k = join ' ', __FILE__, __LINE__;
    $v = join ' ', __FILE__, __LINE__;
    %h = ($k => $v);
    $v2 = join ' ', __FILE__, __LINE__;
    @a2 = @a = ($k, $v2);
    merge_args(\@a2, \%h);
    %h2 = @a2;
};
ok (								#    10
    !$@
    && @a2 == 2
    && $h2{$k} eq $v2,
    'call with arg list and arg hash with same key ' .
    'should return list with list arg'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, $k2, $v2, \@a, \@a2, \%h2],
		     [qw(@   k   v   *h   k2   v2    a    a2    h2)]),
);

