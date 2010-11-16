#! /usr/bin/perl -T
#######################################################################
# $Id: 5_Widget_Checkbox_genhtml_widget.t,v 1.2 2010-11-16 02:14:03 dpchrist Exp $
#
# Test script for Dpchrist::CGI::Widget::Textbox::genhtml_widget().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use constant CLASS		=> 'Dpchrist::CGI::Widget::Checkbox';

use Test::More tests => 6;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI::Widget::Checkbox;

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my $r;

my $obj = eval {
    no strict 'refs';
    CLASS->new();
};

$r = eval {
    Dpchrist::CGI::Widget::Checkbox::genhtml_widget();
};
ok (								#     1
    $@,
    'call as function should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    no strict 'refs';
    CLASS->genhtml_widget();
};
ok (								#     2
    $@,
    'call as class method should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    $obj->genhtml_widget(-foo => 'bar');
};
ok (								#     3
    $@,
    'call with unknown argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    $obj->genhtml_widget(-name => 'prohibited');
};
ok (								#     4
    $@,
    'call with prohibited argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    no strict 'refs';
    join ' ', $obj->genhtml_widget();
};
ok (								#     5
    !$@
    && $r =~ /checkbox.*name=/,
    'call on default object should return corrsponding HTML'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    join ' ', $obj->genhtml_widget(-checked => 1);
};
ok (								#     6
    !$@
    && $r =~ /checkbox.*value="on"/,
    'call with argument -checked should return corresponding HTML'
) or confess join(' ',
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

