#! /usr/bin/perl -T
#######################################################################
# $Id: dump_cookies.t,v 1.2 2010-11-17 21:35:16 dpchrist Exp $
#
# Test script for Dpchrist::CGI::dump_cookies().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests => 1;

use Dpchrist::CGI qw(:all);

$| = 1;

ok(print dump_cookies);						#  1

#######################################################################
