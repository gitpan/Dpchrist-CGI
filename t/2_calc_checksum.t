#######################################################################
# $Id: 2_calc_checksum.t,v 1.2 2010-11-24 22:12:24 dpchrist Exp $
#
# Test script for Dpchrist::CGI::calc_checksum().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests		=> 4;

use strict;
use warnings;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Digest::MD5			qw( md5_hex );
use Dpchrist::CGI		qw( calc_checksum $CHECKSUM_SALT );

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, @a, $t);

$r = eval {
    calc_checksum();
};
ok(								#     1
    $@ =~ 'ERROR: requires at least one argument',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    calc_checksum undef;
};
ok(								#     2
    $@ =~ 'ERROR: arguments must be strings or array references',
    'call with undef should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    calc_checksum {};
};
ok(								#     3
    $@ =~ 'ERROR: arguments must be strings or array references',
    'call with hash reference should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    @a = ('foo', ['bar', 'baz'], 'bozo');
    $t = md5_hex($CHECKSUM_SALT, 'foo', 'bar', 'baz', 'bozo');
    calc_checksum @a;
};
ok(								#     4
    !$@
    && defined $r
    && $r eq $t,
    'call with strings and array ref of strings ' .
    'should return checksum'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@a, $t, $r], [qw(@ *a t r)]),
);

