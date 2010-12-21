#! /usr/bin/perl -T
#######################################################################
# $Id: gen_textarea.t,v 1.3 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for gen_textarea().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 5;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( gen_textarea );
use File::Basename;

$| = 1;
$Data::Dumper::Sortkeys = 1;

my ($r, @r, $t, %h, %h2);

$r = eval {
    %Dpchrist::CGI::TEXTAREA_ARGS = ();
    $t = textarea();
    gen_textarea();
};
ok (								#     1
    !$@
    && $r
    && $r eq $t,
    'call with empty %TEXTAREA_ARGS and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $t, $r], [qw(@ t r)]),
);

$r = eval {
    %Dpchrist::CGI::TEXTAREA_ARGS = ();
    %h = (-name => basename(__FILE__) . __LINE__);
    $t = textarea(%h);
    gen_textarea(%h);
};
ok (								#     2
    !$@
    && $r
    && $r eq $t,
    'call with empty %TEXTAREA_ARGS and argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTAREA_ARGS = (%h);
    $t = textarea(%h);
    gen_textarea();
};
ok (								#     3
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTAREA_ARGS and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTAREA_ARGS = (%h);
    %h2 = (-name => basename(__FILE__) . __LINE__);
    $t = textarea(%h, %h2);
    gen_textarea(%h2);
};
ok (								#     4
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTAREA_ARGS and different argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

$r = eval {
    %h = (-size => __LINE__);
    %Dpchrist::CGI::TEXTAREA_ARGS = (%h);
    %h2 = (-size =>  __LINE__);
    $t = textarea(%h2);
    gen_textarea(%h2);
};
ok (								#     5
    !$@
    && $r
    && $r eq $t,
    'call with %TEXTAREA_ARGS and same named argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, %h, $t, $r], [qw(@ h t r)]),
);

