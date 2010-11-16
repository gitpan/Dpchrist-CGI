#! /usr/bin/perl -T
#######################################################################
# $Id: 2_get_params_as_rha.t,v 1.1 2010-11-08 04:55:06 dpchrist Exp $
# test script for get_params_as_rha()
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 4;

use Carp;
use CGI			qw( :standard );
use Data::Dumper;
use Dpchrist::CGI	qw( :all );

local $Data::Dumper::Sortkeys = 1;

$| = 1;

my $r;

$r = eval {
    param();
};
ok (								#     1
    !$r,
    "CGI::param() with no parameters should return false value"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    get_params_as_rha();
};
ok (								#     2
    ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 0,
    "get_params_as_rha() with no parameters should return empty hash"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    param(-name => -foo, -value => "bar");
    param(-foo);
};
ok (								#     3
    $r
    && $r eq "bar",
    "set and read '-foo' via CGI::param() should work"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

$r = eval {
    get_params_as_rha();
};
ok (								#     4
    ref $r
    && ref $r eq "HASH"
    && scalar keys %$r == 1
    && ref $r->{-foo} eq "ARRAY"
    && scalar @{$r->{-foo}} == 1
    && $r->{-foo}[0] eq "bar",
    "get_params_as_rha() should return hashref with one arrayref " .
    "with one item 'bar'"
) or confess join(" ", __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)]),
);

#######################################################################
