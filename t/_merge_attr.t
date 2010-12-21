#! /usr/bin/perl -T
# $Id: _merge_attr.t,v 1.5 2010-12-20 06:05:19 dpchrist Exp $

use strict;
use warnings;

use Test::More tests => 11;

use Dpchrist::CGI	qw( _merge_attr );

use Carp;
use CGI			qw( :standard );
use Data::Dumper;

$| = 1;
$Data::Dumper::Sortkeys = 1;

my (@a, @a2, $t, $k, $k2, $v, $v2, %h, %h2, $s);

eval {
    _merge_attr();
};
ok (								#     1
    $@,
    'call with no arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    _merge_attr(1);
};
ok (								#     2
    $@,
    'call with one argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    _merge_attr(1, 2, 3);
};
ok (								#     3
    $@,
    'call with three arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    _merge_attr(1, 2);
};
ok (								#     4
    $@,
    'call with scalar first argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    _merge_attr([], 2);
};
ok (								#     5
    $@,
    'call with scalar second argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@], [qw(@)]),
);

eval {
    @a = ();
    _merge_attr(\@a, {});
};
ok (								#     6
    !$@
    && @a == 0,
    'call with empty arg list and empty attr hash ' .
    'should return empty argument list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a], [qw(@ *a)]),
);

eval {
    $k = __FILE__ . __LINE__;
    $v = __FILE__ . __LINE__;
    %h = ($k => $v);
    @a = (\%h);
    _merge_attr(\@a, {});
};
ok (								#     7
    !$@
    && @a == 1
    && $a[0]
    && ref($a[0]) eq 'HASH'
    && keys %{$a[0]} == 1
    && $a[0]->{$k} eq $v,
    'call with attr in arg list and empty attr hash ' .
    'should return arg list with attr'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, \@a], [qw(@ k v *h *a)]),
);

eval {
    $k = __FILE__ . __LINE__;
    $v = __FILE__ . __LINE__;
    %h = ($k => $v);
    @a = ();
    _merge_attr(\@a, \%h);
};
ok (								#     8
    !$@
    && @a == 0,
    'call with empty arg list and attr hash ' .
    'should return empty arg list'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, \@a], [qw(@ k v *h *a)]),
);

eval {
    $k = __FILE__ . __LINE__;
    $v = __FILE__ . __LINE__;
    %h = ($k => $v);
    @a2 = @a = (
	__FILE__ . __LINE__,
	__FILE__ . __LINE__,
    );
    _merge_attr(\@a2, \%h);
};
ok (								#     9
    !$@
    && @a2 == 3
    && $a2[0]
    && ref($a2[0]) eq 'HASH'
    && keys %{$a2[0]} == 1
    && $a2[0]->{$k} eq $v
    && $a2[1] eq $a[0]
    && $a2[2] eq $a[1],
    'call with arg list and attr hash ' .
    'should return arg list with attr'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, \@a, \@a2],
		     [qw(@   k   v   *h    a    a2)]),
);

eval {
    $k = __FILE__ . __LINE__;
    $v = __FILE__ . __LINE__;
    %h = ($k => $v);
    $k2 = __FILE__ . __LINE__;
    $v2 = __FILE__ . __LINE__;
    %h2 = ($k2 => $v2);
    @a2 = @a = (
	\%h,
	__FILE__ . __LINE__,
	__FILE__ . __LINE__,
    );
    _merge_attr(\@a2, \%h2);
};
ok (								#    10
    !$@
    && @a2 == 3
    && $a[0]
    && ref($a2[0]) eq 'HASH'
    && keys %{$a2[0]} == 2
    && $a2[0]->{$k} eq $v
    && $a2[0]->{$k2} eq $v2
    && $a2[1] eq $a[1]
    && $a2[2] eq $a[2],
    'call with arg list with attr and different attr hash ' .
    'should return arg list with both attr'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, $k2, $v2, \%h2, \@a, \@a2],
		     [qw(@   k   v   *h   k2   v2    h2    a    a2)]),
);

eval {
    $k = __FILE__ . __LINE__;
    $v = __FILE__ . __LINE__;
    %h = ($k => $v);
    $v2 = __FILE__ . __LINE__;
    %h2 = ($k => $v2);
    @a2 = @a = (
	\%h,
	__FILE__ . __LINE__,
	__FILE__ . __LINE__,
    );
    _merge_attr(\@a2, \%h2);
};
ok (								#    11
    !$@
    && @a2 == 3
    && $a2[0]
    && ref($a2[0]) eq 'HASH'
    && keys %{$a2[0]} == 1
    && $a2[0]->{$k} eq $v
    && $a2[1] eq $a[1]
    && $a2[2] eq $a[2],
    'call with arg list with attr and attr hash ' .
    'with same key but different value ' .
    'should return arg list with attr set to arg value'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $k, $v, \%h, $k2, $v2, \%h2, \@a, \@a2],
		     [qw(@   k   v   *h   k2   v2    h2    a    a2)]),
);
