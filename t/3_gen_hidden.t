#! /usr/bin/perl -T
#######################################################################
# $Id: 3_gen_hidden.t,v 1.2 2010-11-25 01:46:07 dpchrist Exp $
#
# Test script for gen_hidden().
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#######################################################################

use Test::More tests => 6;

use strict;
use warnings;

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI		qw( calc_checksum gen_hidden );

local $| 			= 1;
local $Data::Dumper::Sortkeys 	= 1;

my (@r, $s, $s2, @a, @a2, $md5, $t, $t2);

@r = eval {
    gen_hidden();
};
ok (								#     1
    $@ =~ /ERROR: requires exactly four arguments/,
    'call with no arguments should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    gen_hidden(1, 2, 3, 4);
};
ok (								#     2
    $@ =~ /ERROR: argument '-name' missing/,
    'call without -name argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    gen_hidden(-name => undef, 3, 4);
};
ok (								#     3
    $@ =~ /ERROR: argument '-name' must be a CGI parameter name/,
    'call with undefined -name argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    $s = join ' ', __FILE__, __LINE__;
    gen_hidden(-name => $s, 3, 4);
};
ok (								#     4
    $@ =~ /ERROR: argument '-value' missing/,
    'call without -value argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, \@r], [qw(@ *r)]),
);

@r = eval {
    gen_hidden(-name => $s, -value => undef);
};
ok (								#     5
    $@ =~ /ERROR: argument '-value' must be a string or an array refe/,
    'call with undefined -value argument should throw exception'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, \@r], [qw(@ s *r)]),
);

@r = eval {
    $s2 = join ' ', __FILE__, __LINE__;
    @a = (-name => $s, -value => $s2);
    $t = hidden(@a);
    $md5 = calc_checksum(@a);
    @a2 = (-name => $s . '_ck', -value => $md5);
    $t2 = hidden(@a2);
    gen_hidden(@a);
};
ok (								#     6
    !$@
    && @r == 2
    && $r[0] eq $t
    && $r[1] eq $t2,
    'call with arguments should generate corresponding HTML'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$@, $s, $s2, \@a, $t, $md5, \@a2, $t2, \@r],
		     [qw(@   s   s2   *a   t   md5   *a2   t2   *r)]),
);

