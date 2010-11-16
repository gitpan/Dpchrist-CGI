#######################################################################
# test script for untaint_textarea
#
# Copyright 2006 by David Paul Christensen <dpchrist@holgerdanske.com>
#######################################################################

use Test::More tests => 4;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use Dpchrist::CGI qw(:all);

$| = 1;

ok(!defined untaint_textarea(undef));				#  1

my @a = (undef, undef, undef);
my @b = untaint_textarea(@a);
if (!defined $b[0] && !defined $b[1] && !defined $b[2]) {
    ok(1);							#  2
}
else {
    warn join ' ', __FILE__, __LINE__,
	Data::Dumper->Dump([\@a, \@b], [qw(*a *b)]);
}

ok(untaint_textarea('foo') eq 'foo');				#  3

@a = ('foo\n', 'bar', 'baz');
@b = untaint_textarea(@a);
if ($a[0] eq $b[0] && $a[1] eq $b[1] && $a[2] eq $b[2]) {
    ok(1);							#  4
}
else {
    warn join ' ', __FILE__, __LINE__,
	Data::Dumper->Dump([\@a, \@b], [qw(*a *b)]);
}

#######################################################################
