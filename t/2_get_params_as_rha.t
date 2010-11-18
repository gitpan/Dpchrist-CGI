#! /usr/bin/perl -T
#######################################################################
# $Id: 2_get_params_as_rha.t,v 1.3 2010-11-17 21:23:08 dpchrist Exp $
#
# Test script for get_params_as_rha() with functional interface.
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 14;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( :all );

local $Data::Dumper::Sortkeys = 1;

$| = 1;

{
my ($r, @r, $s, $s2, $q);

$r = eval {
    get_params_as_rha();
};
ok (								#     1
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 0,
    "get_params_as_rha() with no CGI parameters " .
    "should return empty hash"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = join ' ', __FILE__, __LINE__;
    $s2 = join ' ', __FILE__, __LINE__;
    param(-name => $s, -value => $s2);
    param($s);
};
ok (								#     2
    !$@
    && $r
    && $r eq $s2,
    "use CGI::param() to set test parameter"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    get_params_as_rha();
};
ok (								#     3
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 1
    && ref $r->{$s} eq "ARRAY"
    && scalar @{$r->{$s}} == 1
    && $r->{$s}[0] eq $s2,
    "get_params_as_rha() should return corresponding hashref"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);
}

{
my ($r, @r, $s, $s2, $s3, $s4, $q, $q2);

$r = eval {
    $q = CGI->new();
};
ok (								#     4
    !$@
    && $q->isa('CGI')
    && $r->isa('CGI'),
    'create a CGI test object'
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, $r], [qw(@ q r)]),
);

@r = eval {
    $q->param();
};
ok (								#     5
    !$@
    && @r == 0,
    "there should be no initial CGI parameters"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, \@r], [qw(@ q *r)]),
);

$r = eval {
    get_params_as_rha($q);
};
ok (								#     6
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 0,
    "call should return empty hash"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, $r], [qw(@ q r)]),
);

$r = eval {
    $s = join ' ', __FILE__, __LINE__;
    $s2 = join ' ', __FILE__, __LINE__;
    $q->param(-name => $s, -value => $s2);
    $q->param($s);
};
ok (								#     7
    !$@
    && $r
    && $r eq $s2,
    "set test parameter in test object"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, $r], [qw(@ q r)]),
);

$r = eval {
    get_params_as_rha($q);
};
ok (								#     8
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 1
    && ref $r->{$s} eq "ARRAY"
    && scalar @{$r->{$s}} == 1
    && $r->{$s}[0] eq $s2,
    "call should return corresponding hashref"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, $r], [qw(@ q r)]),
);

$r = eval {
    $q2 = CGI->new();
};
ok (								#     9
    !$@
    && $q2->isa('CGI')
    && $r->isa('CGI'),
    'create another CGI test object'
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q2, $r], [qw(@ q2 r)]),
);

@r = eval {
    $q2->param();
};
ok (								#    10
    !$@
    && @r == 0,
    "there should be no initial CGI parameters"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q2, \@r], [qw(@ q2 *r)]),
);

$r = eval {
    get_params_as_rha($q2);
};
ok (								#    11
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 0,
    "call should return empty hash"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q2, $r], [qw(@ q2 r)]),
);

$r = eval {
    $s3 = join ' ', __FILE__, __LINE__;
    $s4 = join ' ', __FILE__, __LINE__;
    $q2->param(-name => $s3, -value => $s4);
    $q2->param($s3);
};
ok (								#    12
    !$@
    && $r
    && $r eq $s4,
    "set different test parameter in second test object"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q2, $r], [qw(@ q2 r)]),
);

$r = eval {
    get_params_as_rha($q2);
};
ok (								#    13
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 1
    && ref $r->{$s3} eq "ARRAY"
    && scalar @{$r->{$s3}} == 1
    && $r->{$s3}[0] eq $s4,
    "call should return corresponding hashref"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q2, $r], [qw(@ q2 r)]),
);

$r = eval {
    get_params_as_rha($q);
};
ok (								#    14
    !$@
    && ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 1
    && ref $r->{$s} eq "ARRAY"
    && scalar @{$r->{$s}} == 1
    && $r->{$s}[0] eq $s2,
    "first object should be unchanged"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $q, $r], [qw(@ q r)]),
);
}
