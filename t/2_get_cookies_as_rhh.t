#! /usr/bin/perl -T
#######################################################################
# $Id: 2_get_cookies_as_rhh.t,v 1.4 2010-11-17 21:35:16 dpchrist Exp $
#
# Test script for Dpchrist::CGI::get_cookies_as_rhh().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests => 1;

use Dpchrist::CGI		qw(:all);

use Carp;
use Data::Dumper;

$| = 1;

my $r = eval {
    get_cookies_as_rhh();
};
ok(								#     1
    !$@,
    'call with no arguments should not throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

#######################################################################
