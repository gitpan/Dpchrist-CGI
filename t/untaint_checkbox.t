#######################################################################
# $Id: untaint_checkbox.t,v 1.1 2010-12-02 19:17:01 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_checkbox().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( untaint_checkbox );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

my $good = 'on';

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);


$r = eval {
    untaint_checkbox;
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
	untaint_checkbox undef;
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
    untaint_checkbox '';
};
ok(								#     3
    !$@
    && !defined($r),
    'call on empty string should return undef ' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    untaint_checkbox $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on control characters should return undefined value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

$r = eval {
    untaint_checkbox $good . $bad;
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
    untaint_checkbox $good;
};
ok(								#     6
    !$@
    && $r
    && $r eq $good,
    'call on good value should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

