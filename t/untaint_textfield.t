#######################################################################
# $Id: untaint_textfield.t,v 1.6 2010-12-20 06:05:21 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_textfield().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( untaint_textfield );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

my $good = join(' ', __FILE__, __LINE__);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

$r = eval {
    untaint_textfield;
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
	untaint_textfield undef;
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
    untaint_textfield '';
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
    untaint_textfield $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on invalid characters should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

$r = eval {
    untaint_textfield $good . $bad;
};
ok(								#     5
    !$@
    && !defined($r),
    'call on good string with trailing invalid characters ' .
    'should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

$r = eval {
    untaint_textfield $good;
};
ok(								#     6
    !$@
    && defined($r)
    && $r eq $good,
    'call on good string should return string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

