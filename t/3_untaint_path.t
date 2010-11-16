#######################################################################
# test script for untaint_path
#
# Copyright 2006 by David Paul Christensen <dpchrist@holgerdanske.com>
#######################################################################

use Test::More tests => 5;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use Dpchrist::CGI qw(:all);

$| = 1;

ok(!defined untaint_path(undef));				#  1

my @a = (undef, undef, undef);
my @b = untaint_path(@a);
if (!defined $b[0] && !defined $b[1] && !defined $b[2]) {
    ok(1);							#  2
}
else {
    warn join ' ', __FILE__, __LINE__,
	Data::Dumper->Dump([\@a, \@b], [qw(*a *b)]);
}

ok(untaint_path('foo/bar.baz') eq 'foo/bar.baz');		#  3

@a = ('foo', 'bar', 'baz');
@b = untaint_path(@a);
if ($a[0] eq $b[0] && $a[1] eq $b[1] && $a[2] eq $b[2]) {
    ok(1);							#  4
}
else {
    warn join ' ', __FILE__, __LINE__,
	Data::Dumper->Dump([\@a, \@b], [qw(*a *b)]);
}

ok(!untaint_path("\x00"));					#  5

#######################################################################
