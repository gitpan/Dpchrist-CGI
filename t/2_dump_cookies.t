#######################################################################
# test script for dump_cookies
#
# Copyright 2006 by David Paul Christensen <dpchrist@holgerdanske.com>
#######################################################################

use Test::More tests => 1;

use Dpchrist::CGI qw(:all);

$| = 1;

ok(print dump_cookies);						#  1

#######################################################################
