#######################################################################
# $Id: untaint_textfield.t,v 1.3 2010-11-24 22:12:24 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_textfield().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests			=> 4;

use Dpchrist::CGI			qw( untaint_textfield );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

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
    $s = join ' ', __FILE__, __LINE__;
    untaint_textfield $s;
};
ok(								#     3
    !$@
    && $r
    && $r eq $s,
    'call on string should return string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

$r = eval {
    $s = join ' ', __FILE__, __LINE__;
    untaint_textfield $bad . $s . $bad;
};
ok(								#     4
    !$@
    && $r
    && $r eq $s,
    'call on string with leading and trailing control characters ' .
    'should return string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

