#######################################################################
# $Id: validate_password_field.t,v 1.3 2010-12-02 19:17:02 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_password_field().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests		=> 10;

use strict;
use warnings;

use Dpchrist::CGI		qw( %PASSWORD_FIELD_ARGS
				    validate_password_field );

use Carp;
use CGI				qw( :standard );
use Data::Dumper;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my (@r, $s, $s2);

my $bad;
for (my $i = 0; $i < 32; $i++) {
    $bad .= chr($i);
}
$bad .= chr(127);

my $o = bless {}, 'Foo';

@r = eval {
    validate_password_field;
};
ok(								#     1
    $@ =~ 'ERROR: requires one argument',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_password_field undef;
};
ok(								#     2
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with undef first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_password_field '';
};
ok(								#     3
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with empty string as first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_password_field $o,
};
ok(								#     4
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with object first argument should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    validate_password_field $s;
};
ok(								#     5
    !$@
    && @r == 0,
    'call for with no CGI parameters should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    param(-name => $s, -value => '');
    $s2 = join ' ', __FILE__, __LINE__;
    validate_password_field $s2;
};
ok(								#     6
    !$@
    && @r == 0,
    'call for non-existent CGI parameter should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    validate_password_field $s;
};
ok(								#     7
    !$@
    && @r == 0,
    'call for CGI parameter containing empty string ' .
    'should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = '123456789 ' x (1 + $PASSWORD_FIELD_ARGS{-maxlength}/10);
    param(-name => $s, -value => $s2);
    validate_password_field $s;
};
ok(								#     8
    !$@
    && @r == 1
    && $r[0] =~ /ERROR: parameter '$s' is too long/,
    'call for CGI parameter with too long value ' .
    'should return error message'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, $s2, \@r], [qw(@ s s2 *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => $bad);
    validate_password_field $s;
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
    $s2 = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => $s2);
    validate_password_field $s;
};
ok(								#    10
    !$@
    && @r == 0,
    'call for CGI parameter with good value should return empty array'
) or confess join(' ',
    Data::Dumper->Dump([$@, $bad, $s, \@r], [qw(@ bad s *r)]),
);

