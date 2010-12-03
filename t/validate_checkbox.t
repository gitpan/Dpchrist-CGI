#######################################################################
# $Id: validate_checkbox.t,v 1.1 2010-12-02 19:17:02 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_checkbox().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests		=> 9;

use Dpchrist::CGI		qw( %CHECKBOX_ARGS
				    validate_checkbox );

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my (@r, $s, $s2);

my $good = $CHECKBOX_ARGS{-value} || 'on';

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

@r = eval {
    validate_checkbox;
};
ok(								#     1
    $@ =~ 'ERROR: requires one argument',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_checkbox undef;
};
ok(								#     2
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with undef should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_checkbox '';
};
ok(								#     3
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with empty string should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_checkbox bless({}, 'Foo');
};
ok(								#     4
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with object should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    my $s = join ' ', __FILE__, __LINE__;
    validate_checkbox $s;
};
ok (								#     5
    !$@
    && @r == 0,
    'call when no CGI parameters should return empty array'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    param(-name => $s, -value => ' ');
    $s2 = join ' ', __FILE__, __LINE__;
    validate_checkbox $s2;
};
ok(								#     6
    !$@
    && @r == 0,
    'call for non-existent CGI parameter should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    validate_checkbox $s;
};
ok(								#     7
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' contains invalid characters/,
    'call for CGI parameter containing empty string ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => $bad);
    validate_checkbox $s;
};
ok(								#     8
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
    param(-name => $s, -value => $good);
    validate_checkbox $s;
};
ok(								#     9
    !$@
    && @r == 0,
    'call for CGI parameter with good value ' .
    'should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $good, $s, \@r], [qw(@ good s *r)]),
);

