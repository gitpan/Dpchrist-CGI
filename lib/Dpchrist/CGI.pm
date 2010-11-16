#######################################################################
# $Id: CGI.pm,v 1.18 2010-11-16 05:28:51 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::CGI;

use 5.010;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	dump_cookies
	dump_params
	get_params_as_rha
	get_cookies_as_rhh
	nbsp
	untaint_path
	untaint_regex
	untaint_textarea
	untaint_textfield
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = sprintf "%d.%03d", q$Revision: 1.18 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp;
use CGI				qw(:standard);
use Data::Dumper;

#######################################################################

=head1 NAME

Dpchrist::CGI - utility subroutines for CGI scripts

=head2 SUBROUTINES

=cut

#----------------------------------------------------------------------

=head3 dump_cookies

    dump_cookies

Calls get_cookies_as_rhh() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

=cut

sub dump_cookies
{
    my $cookies = get_cookies_as_rhh();

    return Data::Dumper->Dump([$cookies], [qw(cookies)]);
}

#----------------------------------------------------------------------

=head3 dump_params

    dump_params

Calls get_params_as_rha() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

=cut

sub dump_params
{
    my $params = get_params_as_rha();

    return Data::Dumper->Dump([$params], [qw(params)]);
}

#----------------------------------------------------------------------

=head3 get_cookies_as_rhh

    get_cookies_as_rhh

Calls CGI::cookie($i) in list context for all CGI cookies,
populating a hash-of-hashes data structure along the way,
and returns a reference to the data structure.

=cut

sub get_cookies_as_rhh
{
    my $cookies;

    foreach (cookie()) {
	$cookies->{$_} = { cookie($_) };
    }

    return $cookies;
}

#----------------------------------------------------------------------

=head3 get_params_as_rha

    get_params_as_rha

Calls CGI::param($i) in list context for all CGI parameters,
populating a hash-of-arrays data structure along the way,
and returns a reference to the data structure.

=cut

sub get_params_as_rha
{
    my $rha = {};

    foreach (param()) {
	$rha->{$_} = [ param($_) ];
    }

    return $rha;
}

#----------------------------------------------------------------------

=head3 nbsp

    nbsp EXPR

Returns EXPR nonbreaking space HTML character entities.

=cut

sub nbsp
{
    my $n = shift || 1;

    my $s = '&nbsp; ';

    return $s x $n;
}

#----------------------------------------------------------------------

=head3 untaint_path

    untaint_path LIST

Calls untaint_regex(PATTERN,LIST)
using a PATTERN suitable for Unix paths
(everying except NULL)
and returns result.

=cut

sub untaint_path
{
    return untaint_regex('[^\x00]*', @_);
}

#----------------------------------------------------------------------

=head3 untaint_regex

    untaint_regex PATTERN,LIST

Untaints each LIST element using PATTERN.
In scalar context,
returns first matching substring for first item in LIST.
In list context,
returns an array of first matching substrings
for entire list.

Calls Carp::confess() on error.

=cut

sub untaint_regex
{
    confess 'required parameter 1 ($regex) missing'
	unless $_[0];

    my $regex = shift;

    my @retval;
    foreach (@_) {
	if (defined $_) {
	    $_ =~ /($regex)/;
	    push @retval, $1;
	}
	else {
	    push @retval, undef;
	}
    }

    return (wantarray)
	? @retval
	: $retval[0];
}

#----------------------------------------------------------------------

=head3 untaint_textarea

    untaint_textarea LIST

Calls untaint_regex(PATTERN,LIST)
using a PATTERN suitable for text areas
(all printing characters including \n, \r, and \t)
and returns result.

=cut

sub untaint_textarea
{
    return untaint_regex('[a-zA-Z0-9\`\~\!\@\#\$\%\^\&\*\(\)\-\_\=\+\[\{\]\}\\\|\;\:\'\"\,\<\.\>\/\? \n\r\t]*', @_);
}

#----------------------------------------------------------------------

=head3 untaint_textfield

    untaint_textfield LIST

Calls untaint_regex(PATTERN,LIST)
using a PATTERN suitable for text fields
(all printing characters, not including \n, \r, and \t)
and returns result.

=cut

sub untaint_textfield
{
    return untaint_regex('[a-zA-Z0-9\`\~\!\@\#\$\%\^\&\*\(\)\-\_\=\+\[\{\]\}\\\|\;\:\'\"\,\<\.\>\/\? ]*', @_);
}

#######################################################################
# end of module:
#----------------------------------------------------------------------

1;

__END__

#######################################################################

=head2 EXPORT

None by default.

All of the subroutines may be imported by using the ':all' tag:

    use Dpchrist::CGI		qw( :all ); 

See 'perldoc Export' for everything in between.


=head1 INSTALLATION

Minimal:

    cpan Dpchrist::CGI

Complete:

    cpan Bundle::Dpchrist


=head1 SEE ALSO

    CGI.pm
    Dpchrist::CGI::Widget
    Dpchrist::CGI::Widget::Checkbox


=head1 AUTHOR

David Paul Christensen dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by David Paul Christensen

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################
