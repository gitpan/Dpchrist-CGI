#! /usr/bin/perl -T
#######################################################################
# $Id: nbsp.t,v 1.3 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for nbsp().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 6;

use CGI				qw( nbsp );

use Carp;
use Data::Dumper;
use Dpchrist::CGI		qw( nbsp );

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my ($r, @r, $s, $t, @a, %h, %h2);
my $nbsp = '&nbsp;';

$r = eval {
    nbsp();
};
ok (								#     1
    !$@
    && $r
    && $r eq $nbsp,
    'call with no arguments should return non-breaking space'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    nbsp(undef);
};
ok (								#     2
    $@ =~ /ERROR: argument is not a whole number/,
    'call on undefined value should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    nbsp(bless({}, 'Foo'));
};
ok (								#     3
    $@ =~ /ERROR: argument is not a whole number/,
    'call on object should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    nbsp('');
};
ok (								#     4
    $@ =~ /ERROR: argument is not a whole number/,
    'call on empty string should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    nbsp(0);
};
ok (								#     5
    !$@
    && defined $r
    && $r eq '',
    'call on zero should return empty string'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $t = $nbsp x 3;
    nbsp(3);
};
ok (								#     6
    !$@
    && defined $r
    && $r eq $t,
    'call on valid argument should return correct HTML fragment'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

