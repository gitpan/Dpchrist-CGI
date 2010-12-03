#######################################################################
# $Id: untaint_path.t,v 1.7 2010-12-02 19:17:02 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_path().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( untaint_path );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

my $good = '/tmp';
my $bad = "\x00";

$r = eval {
    untaint_path;
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
	untaint_path undef;
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
    untaint_path '';
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
    untaint_path $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on null should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

$r = eval {
    untaint_path $good . $bad;
};
ok(								#     5
    !$@
    && !defined($r),
    'call on good value with training null should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $good, $r], [qw(@ bad good r)]),
);

$r = eval {
    untaint_path $good;
};
ok(								#     6
    !$@
    && defined($r)
    && $r eq $good,
    'call on good value should return value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $r], [qw(@ good r)]),
);

