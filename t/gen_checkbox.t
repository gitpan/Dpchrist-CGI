#! /usr/bin/perl -T
#######################################################################
# $Id: gen_checkbox.t,v 1.4 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for gen_checkbox().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 4;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( gen_checkbox );
use File::Basename;

$| = 1;
local $Data::Dumper::Sortkeys = 1;

my ($r, @r, @a, $t, %h, %h2, %h3);

### CGI::checkbox() generates warnings if -name argument not provided
### only seems to happen during 'make test' (?)

$r = eval {
    %Dpchrist::CGI::CHECKBOX_ARGS = ();
    %h = (-name => basename(__FILE__) . __LINE__);
    $t = checkbox(%h);
    gen_checkbox(%h);
};
ok (								#     1
    !$@
    && $r
    && $r eq $t,
    'call with empty %CHECKBOX_ARGS and argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-name => basename(__FILE__) . __LINE__);
    %Dpchrist::CGI::CHECKBOX_ARGS = (%h);
    $t = checkbox(%h);
    gen_checkbox();
};
ok (								#     2
    !$@
    && $r
    && $r eq $t,
    'call with %CHECKBOX_ARGS and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h2 = (-checked => __LINE__);
    $t = checkbox(%h, %h2);
    gen_checkbox(%h2);
};
ok (								#     3
    !$@
    && $r
    && $r eq $t,
    'call with %CHECKBOX_ARGS and different argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h3 = (-name => basename(__FILE__) . __LINE__);
    %Dpchrist::CGI::CHECKBOX_ARGS = (%h);
    $t = checkbox(%h3);
    gen_checkbox(%h3);
};
ok (								#     4
    !$@
    && $r
    && $r eq $t,
    'call with %CHECKBOX_ARGS and same named argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

