#! /usr/bin/perl -T
#######################################################################
# $Id: gen_td.t,v 1.1 2010-11-21 04:02:28 dpchrist Exp $
#
# Test script for gen_td().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 7;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( gen_td );

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my ($r, @r, $s, $t, @a, %h, %h2);

$r = eval {
    %Dpchrist::CGI::TD_ATTR = ();
    $t = td();
    gen_td();
};
ok (								#     1
    !$@
    && $r
    && $r eq $t,
    'call with empty %TD_ATTR and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $t, $r], [qw(@ t r)]),
);

$r = eval {
    %Dpchrist::CGI::TD_ATTR = ();
    $s = join ' ',__FILE__, __LINE__;
    $t = td($s);
    gen_td($s);
};
ok (								#     2
    !$@
    && $r
    && $r eq $t,
    'call with empty %TD_ATTR and scalar argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $t, $r], [qw(@ s t r)]),
);

$r = eval {
    %Dpchrist::CGI::TD_ATTR = ();
    @a = (
	join(' ', __FILE__, __LINE__),
	join(' ', __FILE__, __LINE__),
    );
    $t = td(@a);
    gen_td(@a);
};
ok (								#     3
    !$@
    && $r
    && $r eq $t,
    'call with empty %TD_ATTR and list of arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a, $t, $r], [qw(@ *a t r)]),
);

$r = eval {
    %Dpchrist::CGI::TD_ATTR = ();
    @a = (
	join(' ', __FILE__, __LINE__),
	join(' ', __FILE__, __LINE__),
    );
    $t = td(\@a);
    gen_td(\@a);
};
ok (								#     4
    !$@
    && $r
    && $r eq $t,
    'call with empty %TD_ATTR and reference to array of arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a, $t, $r], [qw(@ *a t r)]),
);

$r = eval {
    %Dpchrist::CGI::TD_ATTR = ();
    $s = join ' ',__FILE__, __LINE__;
    %h = (-width => __LINE__);
    $t = td(\%h, $s);
    gen_td(\%h, $s);
};
ok (								#     5
    !$@
    && $r
    && $r eq $t,
    'call with attributes in function call'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, %h, $t, $r], [qw(@ s *h t r)]),
);

$r = eval {
    $s = join ' ',__FILE__, __LINE__;
    %h = (-width => __LINE__);
    $t = td(\%h, $s);
    %Dpchrist::CGI::TD_ATTR = %h;
    gen_td($s);
};
ok (								#     6
    !$@
    && $r
    && $r eq $t,
    'call with attributes in %TD_ATTR'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \%h, $t, $r], [qw(@ s *h t r)]),
);

$r = eval {
    $s = join ' ',__FILE__, __LINE__;
    %h = (-width => __LINE__);
    %h2 = (-width => __LINE__);
    %Dpchrist::CGI::TD_ATTR = %h2;
    $t = td(\%h, $s);
    gen_td(\%h, $s);
};
ok (								#     7
    !$@
    && $r
    && $r eq $t,
    'call with attributes in %TD_ATTR and function call'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \%h, \%h2, $t, $r],
		     [qw(@   s   *h   *h2   t   r)]),
);

