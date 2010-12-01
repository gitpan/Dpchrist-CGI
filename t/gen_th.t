#! /usr/bin/perl -T
#######################################################################
# $Id: gen_th.t,v 1.2 2010-11-24 22:12:24 dpchrist Exp $
#
# Test script for gen_th().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 7;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI		qw( gen_th );


local $|			= 1;
local $Data::Dumper::Sortkeys	= 1;


my ($r, @r, $s, $t, @a, %h, %h2);

$r = eval {
    %Dpchrist::CGI::TH_ATTR = ();
    $t = th();
    gen_th();
};
ok (								#     1
    !$@
    && $r
    && $r eq $t,
    'call with empty %TH_ATTR and no arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $t, $r], [qw(@ t r)]),
);

$r = eval {
    %Dpchrist::CGI::TH_ATTR = ();
    $s = join ' ',__FILE__, __LINE__;
    $t = th($s);
    gen_th($s);
};
ok (								#     2
    !$@
    && $r
    && $r eq $t,
    'call with empty %TH_ATTR and scalar argument'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $t, $r], [qw(@ s t r)]),
);

$r = eval {
    %Dpchrist::CGI::TH_ATTR = ();
    @a = (
	join(' ', __FILE__, __LINE__),
	join(' ', __FILE__, __LINE__),
    );
    $t = th(@a);
    gen_th(@a);
};
ok (								#     3
    !$@
    && $r
    && $r eq $t,
    'call with empty %TH_ATTR and list of arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a, $t, $r], [qw(@ *a t r)]),
);

$r = eval {
    %Dpchrist::CGI::TH_ATTR = ();
    @a = (
	join(' ', __FILE__, __LINE__),
	join(' ', __FILE__, __LINE__),
    );
    $t = th(\@a);
    gen_th(\@a);
};
ok (								#     4
    !$@
    && $r
    && $r eq $t,
    'call with empty %TH_ATTR and reference to array of arguments'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@a, $t, $r], [qw(@ *a t r)]),
);

$r = eval {
    %Dpchrist::CGI::TH_ATTR = ();
    $s = join ' ',__FILE__, __LINE__;
    %h = (-width => __LINE__);
    $t = th(\%h, $s);
    gen_th(\%h, $s);
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
    $t = th(\%h, $s);
    %Dpchrist::CGI::TH_ATTR = %h;
    gen_th($s);
};
ok (								#     6
    !$@
    && $r
    && $r eq $t,
    'call with attributes in %TH_ATTR'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \%h, $t, $r], [qw(@ s *h t r)]),
);

$r = eval {
    $s = join ' ',__FILE__, __LINE__;
    %h = (-width => __LINE__);
    %h2 = (-width => __LINE__);
    %Dpchrist::CGI::TH_ATTR = %h2;
    $t = th(\%h, $s);
    gen_th(\%h, $s);
};
ok (								#     7
    !$@
    && $r
    && $r eq $t,
    'call with attributes in %TH_ATTR and function call'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \%h, \%h2, $t, $r],
		     [qw(@   s   *h   *h2   t   r)]),
);

