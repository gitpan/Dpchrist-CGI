#######################################################################
# $Id: 3_untaint_textarea.t,v 1.2 2010-11-18 22:52:58 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_textarea().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use Test::More tests			=> 4;

use Dpchrist::CGI			qw( untaint_textarea );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

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
    $s = join ' ', __FILE__, __LINE__;
    untaint_textarea $s;
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
    $s = join ' ', __FILE__, __LINE__, "\r\n";
    untaint_textarea $bad . $s . $bad;
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

