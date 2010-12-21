# $Id: _calc_checksum.t,v 1.4 2010-12-20 06:05:19 dpchrist Exp $

use strict;
use warnings;

use Test::More tests		=> 3;

use Dpchrist::CGI		qw(
    $CHECKSUM_SALT
    _calc_checksum
);

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Digest::MD5                 qw( md5_hex );
use File::Basename;

use constant CHECKSUM_LENGTH	=> 32;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;


my $r;
my $s;
my $t;

$r = eval {
    _calc_checksum;
};
ok(								#     1
    $@ =~ 'ERROR: requires at least 1 arguments',
    'call without arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    _calc_checksum undef;
};
ok(								#     2
    $@ =~ 'ERROR: arguments must be strings or array references',
    'call with bad arguments should throw exception'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r], [qw(@ r)]),
);

$r = eval {
    $s = basename(__FILE__) . __LINE__;
    $t = md5_hex($CHECKSUM_SALT, $s);
    _calc_checksum $s;
};
ok(								#     3
    !$@
    && defined($r)
    && $r eq $t
    && length $r == CHECKSUM_LENGTH,
    'call with valid argument should return checksum'
) or confess join(' ',
    Data::Dumper->Dump([$@, $r, $s, $t],
		     [qw(@   r   s   t)]),
);

