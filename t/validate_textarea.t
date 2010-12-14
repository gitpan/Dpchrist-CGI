# $Id: validate_textarea.t,v 1.5 2010-12-13 06:10:53 dpchrist Exp $

use Test::More tests		=> 6;

use strict;
use warnings;

use Dpchrist::CGI		qw(
    %TEXTAREA_ARGS
    $RX_UNTAINT_TEXTAREA
    validate_textarea
    dump_params
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my @e;
my $n = __FILE__ . __LINE__;
my $rx;
my $m;

my $r;
my $s;

$r = eval {
    validate_textarea;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 2 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_textarea undef, $n;
};
ok(								#     2
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with bad RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_textarea \@e, undef;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with bad NAME should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = __FILE__ . __LINE__;
    param($n, $s);
    validate_textarea \@e, $n;
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
    $rx = $RX_UNTAINT_TEXTAREA;
    $RX_UNTAINT_TEXTAREA = qr/()/;
    $s = __FILE__ . __LINE__;
    param($n, $s);
    validate_textarea \@e, $n;
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
    $RX_UNTAINT_TEXTAREA = $rx;
    $TEXTAREA_ARGS{-maxlength} = 1;
    $s = __LINE__;
    param($n, $s);
    validate_textarea \@e, $n;
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

