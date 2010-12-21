#######################################################################
# $Id: untaint_radio_group.t,v 1.3 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_radio_group().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( untaint_radio_group );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;
use File::Basename;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, $s);
my ($stdout, $stderr);

my $good = join ' ', basename(__FILE__), __LINE__;

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

$r = eval {
    untaint_radio_group;
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
	untaint_radio_group undef;
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
    untaint_radio_group '';
};
ok(								#     3
    !$@
    && defined($r)
    && $r eq '',
    'call on empty string should return empty string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

$r = eval {
    untaint_radio_group $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on bad value should return undefined value'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

$r = eval {
    untaint_radio_group $good . $bad;
};
ok(								#     5
    !$@
    && !defined($r),
    'call on good value with trailing control characters ' .
    'should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $bad, $r], [qw(@ good bad r)]),
);

$r = eval {
    untaint_radio_group $good;
};
ok(								#     6
    !$@
    && defined($r)
    && $r eq $good,
    'call on empty string should return empty string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $r], [qw(@ good r)]),
);

