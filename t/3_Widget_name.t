#! /usr/bin/perl -T
#######################################################################
# $Id: 3_Widget_name.t,v 1.1 2010-11-16 01:16:30 dpchrist Exp $
#
# Test script for Dpchrist::CGI::Widget::name().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use constant CLASS		=> 'Dpchrist::CGI::Widget';
use constant DERIVED_CLASS	=> 'Dpchrist::CGI::Widget::Checkbox';

use Test::More tests => 4;

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
    Dpchrist::CGI::Widget::name();
};
ok (								#     1
    $@,
    'call as function should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    no strict 'refs';
    CLASS->name();
};
ok (								#     2
    $@,
    'call as class method should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    my $obj = bless {}, CLASS;
    $obj->name('foo');
};
ok (								#     3
    $@,
    'call with argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = join ' ',  __PACKAGE__, __FILE__, __LINE__;
    no strict 'refs';
    my $obj = DERIVED_CLASS->new(-name => $s);
    $obj->name();
};
ok (								#     4
    !$@
    && $r eq $s,
    'call with name set in constructor ' .
    'should return corresponding object'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $s], [qw(@ r s)]),
);
