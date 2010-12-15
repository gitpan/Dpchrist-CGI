# $Id: validate_required.t,v 1.7 2010-12-14 23:21:59 dpchrist Exp $

use strict;
use warnings;

use Test::More tests		=> 6;

use Dpchrist::CGI		qw(
    dump_params
    validate_required
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my $r;
my @e;
my @n = (
    __FILE__ . __LINE__,
    __FILE__ . __LINE__,
);

$r = eval {
    validate_required;
};
ok(								#     1
    $@ =~ 'ERROR: requires at least 2 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_required undef, @n;
};
ok(								#     2
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with undef RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_required \@e, undef;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with undef LIST should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_required \@e, @n, undef;
};
ok(								#     4
    $@ =~ 'ERROR: positional argument 3 must be parameter name',
    'call with undef name in LIST should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    @e = ();
    param($n[0], __FILE__ . __LINE__);
    validate_required \@e, @n;
};
ok(								#     5
    !$@
    && @e == 1
    && $e[0] =~ /ERROR: parameter '$n[1]' is required/,
    'call with missing parameter should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, \@n], [qw(@ r *e *n)]),
    dump_params,
);

$r = eval {
    @e = ();
    param($n[1], __FILE__ . __LINE__);
    validate_required \@e, @n;
};
ok(								#     6
    !$@
    && @e == 0
    && $r,
    'call with valid parameters should return true'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, \@n], [qw(@ r *e *n)]),
    dump_params,
);

