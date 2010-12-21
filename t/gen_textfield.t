#! /usr/bin/perl -T
#######################################################################
# $Id: gen_textfield.t,v 1.3 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for gen_textfield().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 5;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( gen_textfield );
use File::Basename;

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my ($r, @r, $t, %h, %h2);

$r = eval {
    %Dpchrist::CGI::TEXTFIELD_ARGS = ();
    $t = textfield();
    gen_textfield();
};
ok (								#     1
    !$@
    && $r
    && $r eq $t,
    'call with empty %TEXTFIELD_ARGS and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $t, $r], [qw(@ t r)]),
);

$r = eval {
    %Dpchrist::CGI::TEXTFIELD_ARGS = ();
    %h = (-name => basename(__FILE__) . __LINE__);
    $t = textfield(%h);
    gen_textfield(%h);
};
ok (								#     2
    !$@
    && $r
    && $r eq $t,
    'call with empty %TEXTFIELD_ARGS and argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTFIELD_ARGS = (%h);
    $t = textfield(%h);
    gen_textfield();
};
ok (								#     3
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTFIELD_ARGS and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTFIELD_ARGS = (%h);
    %h2 = (-name => basename(__FILE__) . __LINE__);
    $t = textfield(%h, %h2);
    gen_textfield(%h2);
};
ok (								#     4
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTFIELD_ARGS and different argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTFIELD_ARGS = (%h);
    %h2 = (-size =>  __LINE__);
    $t = textfield(%h2);
    gen_textfield(%h2);
};
ok (								#     5
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTFIELD_ARGS and same named argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

