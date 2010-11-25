#######################################################################
# $Id: 4_validate_textfield.t,v 1.2 2010-11-24 22:12:25 dpchrist Exp $
#
# Test script for Dpchrist::CGI::validate_textfield().
#
# Copyright (c) 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use strict;
use warnings;

use Test::More tests		=> 8;

use Dpchrist::CGI		qw( %TEXTFIELD_ARGS
				    validate_textfield );

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

@r = eval {
    validate_textfield();
};
ok(								#     1
    $@ =~ 'ERROR: requires one argument',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_textfield undef;
};
ok(								#     2
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with undef should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_textfield '';
};
ok(								#     3
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with empty string should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_textfield bless({}, 'Foo');
};
ok(								#     4
    $@ =~ 'ERROR: argument must be a CGI parameter name',
    'call with object should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    validate_textfield 'foo';
};
ok(								#     5
    !$@
    && @r == 0,
    'call for non-existant CGI parameter should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    param(-name => $s, -value => '');
    validate_textfield $s;
};
ok(								#     6
    !$@
    && @r == 0,
    'call for CGI parameter containing empty string ' .
    'should return empty list'
) or confess join(' ',
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s = join(' ', __FILE__, __LINE__);
    $s2 = '123456789 ' x (1 + $TEXTFIELD_ARGS{-maxlength}/10);
    param(-name => $s, -value => $s2);
    validate_textfield $s;
};
ok(								#     7
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
    validate_textfield $s;
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

