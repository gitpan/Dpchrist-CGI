# $Id: validate_textfield.t,v 1.7 2010-12-20 06:05:21 dpchrist Exp $

use strict;
use warnings;

use Test::More tests		=> 6;

use Dpchrist::CGI		qw(
    %TEXTFIELD_ARGS
    $RX_UNTAINT_TEXTFIELD
    validate_textfield
    dump_params
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use File::Basename;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my @e;
my $n = basename(__FILE__) . __LINE__;
my $rx;
my $m;

my $r;
my $s;

$r = eval {
    validate_textfield;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 2 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_textfield undef, $n;
};
ok(								#     2
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with bad RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_textfield \@e, undef;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with bad NAME should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = basename(__FILE__) . __LINE__;
    param($n, $s);
    validate_textfield \@e, $n;
};
ok(								#     4
    !$@
    && @e == 0
    && defined($r)
    && $r eq $s,
    'call with valid parameter should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
);

$r = eval {
    $rx = $RX_UNTAINT_TEXTFIELD;
    $RX_UNTAINT_TEXTFIELD = qr/()/;
    $s = basename(__FILE__) . __LINE__;
    param($n, $s);
    validate_textfield \@e, $n;
};
ok(								#     5
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must contain valid characters/,
    'call with broken untaint regexp should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
);

$r = eval {
    @e = ();
    $RX_UNTAINT_TEXTFIELD = $rx;
    $TEXTFIELD_ARGS{-maxlength} = 1;
    $s = __LINE__;
    param($n, $s);
    validate_textfield \@e, $n;
};
ok(								#     6
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' length must be 1 characters or less/,
    'call with short maxlength should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $s], [qw(@ r *e n s)]),
);

