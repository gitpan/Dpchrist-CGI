#######################################################################
# $Id: validate_parameter_present.t,v 1.5 2010-12-02 19:17:02 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_parameter_present().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests		=> 8;

use Dpchrist::CGI		qw( validate_parameter_present );

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my (@r, $s, $s2);

@r = eval {
    validate_parameter_present();
};
ok(								#     1
    $@ =~ 'ERROR: requires at least one argument',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_parameter_present undef;
};
ok(								#     2
    $@ =~ 'ERROR: arguments must be CGI parameter names',
    'call with undef should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_parameter_present '';
};
ok(								#     3
    $@ =~ 'ERROR: arguments must be CGI parameter names',
    'call with empty string should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_parameter_present bless({}, 'Foo');
};
ok(								#     4
    $@ =~ 'ERROR: arguments must be CGI parameter names',
    'call with object should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    validate_parameter_present $s;
};
ok(								#     5
    !$@
    && @r == 0,
    'call with no CGI parameters should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    validate_parameter_present $s;
};
ok(								#     6
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' missing/,
    'call on CGI parameter with empty string ' .
    'should generate error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s2 = join(' ', __FILE__, __LINE__);
    validate_parameter_present $s2;
};
ok(								#     7
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s2' missing/,
    'call on non-existent CGI parameter ' .
    'should return error string'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => $s2);
    validate_parameter_present $s;
};
ok(								#     8
    !$@
    && @r == 0,
    'call on CGI parameter with value should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);
