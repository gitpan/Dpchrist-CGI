# $Id: _validate_checksum.t,v 1.5 2010-12-20 06:05:20 dpchrist Exp $

use strict;
use warnings;

use Test::More tests		=> 7;

use Dpchrist::CGI		qw(
    $_RX_UNTAINT_CHECKSUM
    _calc_checksum
    _validate_checksum
    dump_params
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use File::Basename;

use constant CHECKSUM_LENGTH	=> 32;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my @e;
my $n = basename(__FILE__) . __LINE__;
my $rx;
my $m;

my $r;
my $s;
my $t;

$r = eval {
    _validate_checksum;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 2 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_checksum undef, $n;
};
ok(								#     2
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with bad RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_checksum \@e, undef;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with bad NAME should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_checksum \@e, $n;
};
ok(								#     4
    !$@
    && @e == 0
    && !defined($r),
    'call when no parameters should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
);

$r = eval {
    $s = _calc_checksum(basename(__FILE__), __LINE__);
    param($n, $s);
    _validate_checksum \@e, $n;
};
ok(								#     5
    !$@
    && @e == 0
    && defined($r)
    && $r eq $s,
    'call with valid parameter should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
    dump_params,
);

$r = eval {
    $rx = $_RX_UNTAINT_CHECKSUM;
    $_RX_UNTAINT_CHECKSUM = qr/()/;
    _validate_checksum \@e, $n;
};
ok(								#     6
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must contain valid characters/,
    'call with broken untaint regexp should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
    dump_params,
);

$r = eval {
    @e = ();
    $_RX_UNTAINT_CHECKSUM = $rx;
    param($n, $s . '0');
    _validate_checksum \@e, $n;
};
ok(								#     7
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' length must be exactly 32 characters/,
    'call with short maxlength should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
    dump_params,
);

