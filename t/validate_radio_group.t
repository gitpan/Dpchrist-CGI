# $Id: validate_radio_group.t,v 1.2 2010-12-13 06:10:53 dpchrist Exp $

use strict;
use warnings;

use Test::More tests		=> 10;

use Dpchrist::CGI		qw(
    dump_params
    validate_radio_group
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my $r;

my @e,
my $n = __FILE__ . __LINE__;
my @v = (
    __LINE__,
    __LINE__,
    __LINE__,
);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

$r = eval {
    validate_radio_group;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 3 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_radio_group undef, $n, \@v;
};
ok(								#     2
    $@ =~ /positional argument 0 must be array reference/,
    'call with undef RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    validate_radio_group \@e, undef, \@v;
};
ok(								#     3
    $@ =~ /positional argument 1 must be parameter name/,
    'call with undef NAME should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    validate_radio_group \@e, $n, undef;
};
ok(								#     4
    $@ =~ /positional argument 2 must be array reference/,
    'call with undef RA_VALUES should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    validate_radio_group \@e, $n, \@v;
};
ok(								#     5
    !$@
    && @e == 0
    && !defined($r),
    'call with no parameters should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    @e = ();
    param(__FILE__, __LINE__);
    validate_radio_group \@e, $n, \@v;
};
ok(								#     6
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' is required/,
    'call on empty parameter when others exist ' .
    'should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    @e = ();
    param($n,
	__FILE__ . __LINE__,
	__FILE__ . __LINE__,
    );
    validate_radio_group \@e, $n, \@v;
};
ok(								#     7
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must have single value/,
    'call with multivalued parameter should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    @e = ();
    param($n, $bad);
    validate_radio_group \@e, $n, \@v;
};
ok(								#     8
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must contain valid characters/,
    'call with parameter containing control characters ' . 
    'should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    @e = ();
    param($n, __FILE__ . __LINE__);
    validate_radio_group \@e, $n, \@v;
};
ok(								#     9
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must contain valid value/,
    'call with unknown value should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

$r = eval {
    @e = ();
    param($n, $v[-1]);
    validate_radio_group \@e, $n, \@v;
};
ok(								#    10
    !$@
    && @e == 0
    && defined($r)
    && $r eq $v[-1],
    'call with known value should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, \@v], [qw(@ r *e n *v)]),
    dump_params
);

