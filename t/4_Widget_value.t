#! /usr/bin/perl -T
#######################################################################
# $Id: 4_Widget_value.t,v 1.1 2010-11-16 01:16:30 dpchrist Exp $
#
# Test script for Dpchrist::CGI::Widget::value().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use constant CLASS		=> 'Dpchrist::CGI::Widget';
use constant DERIVED_CLASS	=> 'Dpchrist::CGI::Widget::Checkbox';

use Test::More tests => 6;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
#use Dpchrist::CGI::Widget;
use Dpchrist::CGI::Widget::Checkbox;
use Dpchrist::LangUtil		qw( :all );

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my (@a, $r, $s);

my $obj = eval {
    no strict 'refs';
    CLASS->new();
};

$r = eval {
    Dpchrist::CGI::Widget::value();
};
ok (								#     1
    $@,
    'call as function should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    no strict 'refs';
    CLASS->value();
};
ok (								#     2
    $@,
    'call as class method should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    my $obj = bless {}, CLASS;
    $obj->value(1, 2);
};
ok (								#     3
    $@,
    'call with more than one argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = join ' ',  __PACKAGE__, __FILE__, __LINE__;
    no strict 'refs';
    my $obj = DERIVED_CLASS->new();
    $obj->value();
};
ok (								#     4
    !$@
    && !defined $r,
    'call with non-existant parameter in scalar context ' .
    'should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

@a = eval {
    $s = join ' ',  __PACKAGE__, __FILE__, __LINE__;
    my $obj = bless({-name => $s}, CLASS);
    $obj->value();
};
ok (								#     5
    !$@
    && @a == 0,
    'call with non-existant parameter in list context ' .
    'should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@a], [qw(@ s *a)]),
);

$r = eval {
    $s = join ' ',  __PACKAGE__, __FILE__, __LINE__;
    no strict 'refs';
    my $obj = DERIVED_CLASS->new(-value => $s);
    $obj->value();
};
ok (								#     6
    !$@
    && $r eq $s,
    'call with scalar value set in constructor should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $s], [qw(@ r s)]),
);
