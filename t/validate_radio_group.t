#######################################################################
# $Id: validate_radio_group.t,v 1.1 2010-12-02 19:17:02 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_radio_group().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests		=> 12;

use Dpchrist::CGI		qw( %CHECKBOX_ARGS
				    validate_radio_group );

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my (@r, $s, $s2);

my @values = (
    join('', __FILE__, __LINE__),
    join('', __FILE__, __LINE__),
    join('', __FILE__, __LINE__),
);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

@r = eval {
    validate_radio_group();
};
ok(								#     1
    $@ =~ 'ERROR: requires at least three arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_radio_group(1, 2);
};
ok(								#     2
    $@ =~ 'ERROR: requires at least three arguments',
    'call with two arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_radio_group(undef, 2, 3);
};
ok(								#     3
    $@ =~ 'ERROR: first argument must be a CGI parameter name',
    'call with undefined first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_radio_group('', 2, 3);
};
ok(								#     4
    $@ =~ 'ERROR: first argument must be a CGI parameter name',
    'call with empty string first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_radio_group(bless({}, 'Foo'), 2, 3);
};
ok(								#     5
    $@ =~ 'ERROR: first argument must be a CGI parameter name',
    'call with object first argument throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_radio_group('foo', 2, 3);
};
ok(								#     6
    !$@
    && @r == 0,
    'call when no CGI parameters should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    $s2 = join(' ', __FILE__, __LINE__);
    validate_radio_group($s2, 2, 3);
};
ok(								#     7
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s2' missing/,
    'call for missing radio group CGI parameter ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    validate_radio_group($s, 2, 3);
};
ok(								#     8
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' contains invalid value/,
    'call for CGI parameter containing empty string ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => $bad);
    validate_radio_group($s, 2, 3);
};
ok(								#     9
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' contains invalid characters/,
    'call for CGI parameter with bad characters ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $s, \@r], [qw(@ bad s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = join ' ', __FILE__, __LINE__;
    param(-name => $s, -value => $s2);
    validate_radio_group($s, 2, 3);
};
ok(								#    10
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' contains invalid value/,
    'call for CGI parameter with unlisted value ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = $values[0];
    param(-name => $s, -value => $s2);
    validate_radio_group $s, @values;
};
ok(								#    11
    !$@
    && @r == 0,
    'call for CGI parameter with good value using list form ' .
    'should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@values, \@r],
		     [qw(@   s   s2   *values  *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = $values[0];
    param(-name => $s, -value => $s2);
    validate_radio_group $s, [@values];
};
ok(								#    12
    !$@
    && @r == 0,
    'call for CGI parameter with good value using arrayref form ' .
    'should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@values, \@r],
		     [qw(@   s   s2   *values  *r)]),
);

