#######################################################################
# $Id: _validate_textual.t,v 1.7 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for Dpchrist::CGI::_validate_textual().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests		=> 9;

use strict;
use warnings;

use Dpchrist::CGI		qw( _validate_textual
				    dump_params
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use File::Basename;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my @e;
my $rc = sub { return shift };
my $n = basename(__FILE__) . __LINE__;
my $m = 80;

my $r;
my $s;

$r = eval {
    _validate_textual;
};
ok(								#     1
    $@ =~ 'ERROR: requires exactly 4 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_textual undef, $n, $rc, $m;
};
ok(								#     2
    $@ =~ 'ERROR: positional argument 0 must be array reference',
    'call with bad RA_ERRORS should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_textual \@e, undef, $rc, $m;
};
ok(								#     3
    $@ =~ 'ERROR: positional argument 1 must be parameter name',
    'call with bad NAME should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_textual \@e, $n, undef, $m;
};
ok(								#     4
    $@ =~ 'ERROR: positional argument 2 must be code reference',
    'call with bad RC_UNTAINT should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _validate_textual \@e, $n, $rc, undef;
};
ok(								#     5
    $@ =~ 'ERROR: positional argument 3 must be whole number',
    'call with bad MAXLENGTH should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    param($n,
	basename(__FILE__) . __LINE__,
	basename(__FILE__) . __LINE__,
    );
    _validate_textual \@e, $n, $rc, $m;
};
ok(								#     6
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must have single value/,
    'call with multivalued parameter should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $rc, $m],
		     [qw(@   r   *e   n   rc   m)]),
    dump_params,
);

$r = eval {
    @e = ();
    param($n, basename(__FILE__) . __LINE__);
    _validate_textual \@e, $n, sub { return }, $m;
};
ok(								#     7
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' must contain valid characters/,
    'call with undef untainted value should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $rc, $m],
		     [qw(@   r   *e   n   rc   m)]),
    dump_params,
);

$r = eval {
    @e = ();
    param($n, basename(__FILE__) . __LINE__);
    _validate_textual \@e, $n, $rc, 1;
};
ok(								#     8
    !$@
    && !defined($r)
    && @e == 1
    && $e[0] =~ /parameter '$n' length must be 1 characters or less/,
    'call with small maxlength should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $rc, $m],
		     [qw(@   r   *e   n   rc   m)]),
    dump_params,
);

$r = eval {
    @e = ();
    $s = basename(__FILE__) . __LINE__;
    param($n, $s);
    _validate_textual \@e, $n, $rc, $m;
};
ok(								#     9
    !$@
    && @e == 0
    && defined($r)
    && $r eq $s,
    'call with valid parameter should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, \@e, $n, $rc, $m],
		     [qw(@   r   *e   n   rc   m)]),
    dump_params,
);

