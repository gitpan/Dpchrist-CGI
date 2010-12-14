#######################################################################
# $Id: _untaint_regexp.t,v 1.9 2010-12-14 05:53:12 dpchrist Exp $
#
# Test script for Dpchrist::CGI::_untaint_regexp().
#
# Copyright (c) 2010 by David Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests => 12;

use Dpchrist::CGI		qw( _untaint_regexp $RX_PASSTHROUGH );

use Capture::Tiny		qw( capture );
use Carp;
use Dpchrist::LangUtil		qw( :all );

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my ($r, @r);
my ($stdout, $stderr);

my @a = (
    join(' ', __FILE__, __LINE__),
    join(' ', __FILE__, __LINE__),
);

my $o  = bless {}, __FILE__ . __LINE__;
my $o2 = bless {}, __FILE__ . __LINE__;

$r = eval {
    _untaint_regexp;
};
ok(								#     1
    $@,
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _untaint_regexp 1;
};
ok(								#     2
    $@,
    'call with non-regex first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _untaint_regexp $RX_PASSTHROUGH;
};
ok(								#     3
    !$@
    && !defined $r,
    'call with pass-through RX and no list ' .
    'in scalar context should return undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

@r = eval {
    _untaint_regexp $RX_PASSTHROUGH;
};
ok(								#     4
    !$@
    && @r == 0,
    'call with pass-through RX and no list ' .
    'in list context should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	_untaint_regexp $RX_PASSTHROUGH, undef, undef;
    };
};
ok(								#     5
    !$@
    && !defined $r
    && $stderr =~ /attempt to apply regular expression to undefined/,
    'call with pass-through RX and no LIST ' .
    'in scalar context should return undef ' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $stderr], [qw(@ r stderr)]),
);

($stdout, $stderr) = capture {
    @r = eval {
	_untaint_regexp $RX_PASSTHROUGH, undef, undef;
    };
};
ok(								#     6
    !$@
    && @r == 2
    && !defined($r[0])
    && !defined($r[1])
    && $stderr =~ /attempt to apply regular expression to undefined/,
    'call with pass-through RX and no LIST ' .
    'in list context should return empty list ' .
    'and generate warning'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $stderr], [qw(@ r stderr)]),
);

$r = eval {
    _untaint_regexp $RX_PASSTHROUGH, '', '';
};
ok(								#     7
    !$@
    && $r eq '',
    'call with pass-through RX on list of empty strings ' .
    'in scalar context should return empty string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

@r = eval {
    _untaint_regexp $RX_PASSTHROUGH, '', '';
};
ok(								#     8
    !$@
    && @r == 2
    && $r[0] eq ''
    && $r[1] eq '',
    'call with pass-through RX on list of empty strings ' .
    'in list context should return list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _untaint_regexp $RX_PASSTHROUGH, @a;
};
ok(								#     9
    !$@
    && $r
    && $r eq $a[0],
    'call with pass-through RX on list of strings ' .
    'in scalar context should return first string'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@a, $r], [qw(@ *a r)]),
);

@r = eval {
    _untaint_regexp $RX_PASSTHROUGH, @a;
};
ok(								#    10
    !$@
    && @r == @a
    && arrayref_cmp(\@r, \@a) == 0,
    'call with pass-through RX on list of strings ' .
    'in list context should return list'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@a, \@r], [qw(@ *a *r)]),
);

($stdout, $stderr) = capture {
    $r = eval {
	_untaint_regexp $RX_PASSTHROUGH, $o, $o2;
    };
};
ok(								#    11
    !$@
    && !defined($r)
    && $stderr =~ /attempt to apply regular expression to reference/,
    'call with pass-through RX on list of objects ' .
    'in scalar context should return stringified representation ' .
    'of first object'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

($stdout, $stderr) = capture {
    @r = eval {
	_untaint_regexp $RX_PASSTHROUGH, $o, $o2;
    };
};
ok(								#    12
    !$@
    && @r == 2
    && !defined($r[0])
    && !defined($r[1])
    && $stderr =~ /attempt to apply regular expression to reference/,
    'call with pass-through RX on list of objects ' .
    'in list context should return list of undef'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

