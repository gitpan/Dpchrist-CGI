#######################################################################
# $Id: 3_untaint_path.t,v 1.5 2010-11-18 22:52:58 dpchrist Exp $
#
# Test script for Dpchrist::CGI::untaint_path().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use 5.010;
use strict;
use warnings;

use Test::More tests			=> 4;

use Dpchrist::CGI			qw( untaint_path );

use Capture::Tiny			qw ( capture );
use Carp;
use Data::Dumper;

$|					= 1;
$Data::Dumper::Sortkeys			= 1;

my ($r, @r, $s);
my ($stdout, $stderr);

$r = eval {
    untaint_path;
};
ok(								#     1
    !$@
    && !defined $r,
    'call without arguments in scalar context should return'
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
    $s = join ' ', __FILE__, __LINE__;
    untaint_path $s;
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
    untaint_path "\x00" . $s . "\x00";
};
ok(								#     4
    !$@
    && $r
    && $r eq $s,
    'call on string with leading and training nulls ' .
    'should return string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $r], [qw(@ s r)]),
);

