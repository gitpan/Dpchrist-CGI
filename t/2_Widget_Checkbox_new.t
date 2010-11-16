#! /usr/bin/perl -T
#######################################################################
# $Id: 2_Widget_Checkbox_new.t,v 1.3 2010-11-16 05:28:52 dpchrist Exp $
#
# Test script for Dpchrist::CGI::Widget::Textbox::new().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use constant CLASS		=> 'Dpchrist::CGI::Widget::Checkbox';

use Test::More tests => 14;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI::Widget::Checkbox;

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my ($r, @r, $s, $s2, @a, %h);

$r = eval {
    Dpchrist::CGI::Widget::Checkbox::new();
};
ok (								#     1
    $@,
    'call as function should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    my $obj = bless({}, CLASS);
    $obj->new();
};
ok (								#     2
    $@,
    'call as object method should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    no strict 'refs';
    CLASS->new(-foo => 'bar');
};
ok (								#     3
    $@,
    'call with unknown arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    no strict 'refs';
    CLASS->new();
};
ok (								#     4
    !$@
    && $r
    && $r->isa(CLASS)
    && $r->{-name} eq 'checkbox0',
    'call with no arguments should return object ' .
    'with automatically generated name'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    no strict 'refs';
    CLASS->new();
};
ok (								#     5
    !$@
    && $r
    && $r->isa(CLASS)
    && $r->{-name} eq 'checkbox1',
    'another call with no arguments should return object ' .
    'with next automatically generated name'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = join ' ', __PACKAGE__, __FILE__, __LINE__;
    no strict 'refs';
    CLASS->new(-name => $s);
};
ok (								#     6
    $r
    && $r->isa(CLASS)
    && $r->{-name} eq $s,
    'call with -name argument should return corresponding object'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = join ' ', __PACKAGE__, __FILE__, __LINE__;
    $s2 = join ' ', __PACKAGE__, __FILE__, __LINE__;
    no strict 'refs';
    CLASS->new(-name => $s, -value => $s2);
};
ok (								#     7
    $r
    && $r->isa(CLASS)
    && $r->{-name} eq $s
    && CGI::param($s) eq $s2,
    'call with -value argument should return corresponding object ' .
    'and set CGI parameter'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $s, $s2], [qw(@ r s s2)]),
);

foreach (qw(
    -checked -selected -on -label -onClick -override -force )) {
    $r = eval {
	$s = join ' ', __PACKAGE__, __FILE__, __LINE__, $_;
	$s2 = join ' ', __PACKAGE__, __FILE__, __LINE__, $_;
	no strict 'refs';
	CLASS->new(-name => $s, $_ => $s2);
    };
    ok (							#  8-14
	$r
	&& $r->isa(CLASS)
	&& $r->{-name} eq $s
	&& $r->{$_} eq $s2,
	"call with $_ argument should return corresponding object"
    ) or confess join(' ',
	Data::Dumper->Dump([$@, $r, $s, $s2], [qw(@ r s s2)]),
    );
}

