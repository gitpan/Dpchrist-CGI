#######################################################################
# $Id: _untaint_checksum.t,v 1.1 2010-12-14 05:56:13 dpchrist Exp $
#
# Test script for Dpchrist::CGI::_untaint_checksum().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( _untaint_checksum );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my $r;
my @r;
my $s;
my ($stdout, $stderr);

my $good = _calc_checksum(__FILE__, __LINE__);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}


$r = eval {
    _untaint_checksum;
};
ok(								#     1
    !$@
    && !defined $r,
    'call without arguments should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	_untaint_checksum undef;
    };
};
ok(								#     2
    !$@
    && !defined($r)
    && $stderr,
    'call on undef should return undef ' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $stderr], [qw(@ r stderr)]),
);

$r = eval {
    _untaint_checksum '';
};
ok(								#     3
    !$@
    && defined($r)
    && $r eq '',
    'call on empty string should return empty string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _untaint_checksum $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on control characters should return undefined value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

$r = eval {
    _untaint_checksum $good . $bad;
};
ok(								#     5
    !$@
    && !defined($r),
    'call on good value with trailing control characters ' .
    'should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _untaint_checksum $good;
};
ok(								#     6
    !$@
    && $r
    && $r eq $good,
    'call on good value should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

