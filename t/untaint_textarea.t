#######################################################################
# $Id: untaint_textarea.t,v 1.6 2010-12-20 06:05:20 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_textarea().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 6;

use Dpchrist::CGI			qw( untaint_textarea );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;
use File::Basename;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

my $good = join("\n",
    basename(__FILE__) . __LINE__,
    basename(__FILE__) . __LINE__,
    basename(__FILE__) . __LINE__,
);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    next if $i == 10 || $i == 13;
    $bad .= chr($i);
}
$bad .= chr(127);

$r = eval {
    untaint_textarea;
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
	untaint_textarea undef;
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
    untaint_textarea '';
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
    untaint_textarea $bad;
};
ok(								#     4
    !$@
    && !defined($r),
    'call on invalid characters should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $r], [qw(@ bad r)]),
);

$r = eval {
    untaint_textarea $good . $bad;
};
ok(								#     5
    !$@
    && !defined($r),
    'call on good string with trailing invalid characters ' .
    'should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $bad, $r], [qw(@ good bad r)]),
);

$r = eval {
    untaint_textarea $good;
};
ok(								#     6
    !$@
    && defined($r)
    && $r eq $good,
    'call on good string should return string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $r], [qw(@ good r)]),
);

