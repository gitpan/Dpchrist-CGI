#######################################################################
# $Id: validate_checkbox.t,v 1.4 2010-12-20 03:51:14 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_checkbox().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests		=> 9;

use Dpchrist::CGI		qw(
    %CHECKBOX_ARGS
    dump_params
    validate_checkbox
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use File::Basename;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, @e, $s, $s2);

my $good = $CHECKBOX_ARGS{-value} || 'on';

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

$r = eval {
    validate_checkbox;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 2 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_checkbox undef;
};
ok(								#     2
    $@ =~ 'ERROR: requires exactly 2 arguments',
    'call with one argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_checkbox undef, undef;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with undef RA_ERRORS argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    validate_checkbox \@e, undef;
};
ok(								#     4
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with undef NAME argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = basename(__FILE__) . __LINE__;
    validate_checkbox \@e, $s;
};
ok(								#     5
    !$@
    && @e == 0
    && !defined($r),
    'call on undefined parameter should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@e, $r], [qw(@ *e r)]),
);

$r = eval {
    @e = ();
    $s = basename(__FILE__) . __LINE__;
    param($s,
	basename(__FILE__) . __LINE__,
	basename(__FILE__) . __LINE__,
    );
    validate_checkbox \@e, $s;
};
ok(								#     6
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$s' must have single value/,
    'call with multivalued parameter should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@e, $r], [qw(@ s *e r)]),
);

$r = eval {
    @e = ();
    $s = basename(__FILE__) . __LINE__;
    param($s, "BEL\x07");
    validate_checkbox \@e, $s;
};
ok(								#     7
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$s' must contain valid characters/,
    'call with parameter value containing control characters ' .
    'should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@e, $r], [qw(@ s *e r)]),
);

$r = eval {
    @e = ();
    $s = basename(__FILE__) . __LINE__;
    param($s, basename(__FILE__) . __LINE__);
    validate_checkbox \@e, $s;
};
ok(								#     8
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$s' must contain valid value/,
    'call with invalid parameter value ' .
    'should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@e, $r], [qw(@ s *e r)]),
);

$r = eval {
    @e = ();
    $s = basename(__FILE__) . __LINE__;
    $CHECKBOX_ARGS{-value} = basename(__FILE__) . __LINE__;
    param($s, $CHECKBOX_ARGS{-value});
    validate_checkbox \@e, $s;
};
ok(								#     9
    !$@
    && @e == 0
    && defined($r)
    && $r eq $CHECKBOX_ARGS{-value},
    'call with parameter value of $CHECKBOX_ARGS{-VALUE} ' .
    'should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@e, \%CHECKBOX_ARGS, $r],
		     [qw(@   s   *e    CHECKBOX_ARGS   r)]),
);

