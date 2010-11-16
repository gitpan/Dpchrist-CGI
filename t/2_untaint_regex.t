#######################################################################
# test script for untaint_regex
#
# Copyright 2006 by David Paul Christensen <dpchrist@holgerdanske.com>
#######################################################################

use Test::More tests => 3;

use Dpchrist::CGI qw(:all);

$| = 1;

eval {
    untaint_regex();
};
ok ($@ =~ /required parameter .* missing/);			#  1

ok(untaint_regex('[abc]*', 'abacab')
    eq 'abacab');						#  2

my @a = ('foo', 'bar', 'baz');
my @b = untaint_regex('[a-z]*', @a);

ok($a[0] eq $b[0] && $a[1] eq $b[1] && $a[2] eq $b[2]);		#  3

#######################################################################
