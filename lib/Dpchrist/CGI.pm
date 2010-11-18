#######################################################################
# $Id: CGI.pm,v 1.24 2010-11-18 23:24:09 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::CGI;

use 5.010;
use strict;
use warnings;

use constant DEBUG		=> 0;

use constant RX_UNTAINT_PATH	=> qr/([^\x00]+)/;
use constant RX_UNTAINT_TEXTAREA => qr/([\PC\n\r]+)/;
use constant RX_UNTAINT_TEXTFIELD => qr/([\PC]+)/;

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

our $VERSION = sprintf "%d.%03d", q$Revision: 1.24 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp			qw( cluck confess );
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::Debug		qw( :all );
use Dpchrist::Is		qw( :all );

#######################################################################

=head1 NAME

Dpchrist::CGI - utility subroutines for CGI scripts

=head1 SYNOPSIS

See synopsis.cgi in the source distribution cgi-bin/ directory:

    #! /usr/bin/perl -T
    use 5.010;
    use strict;
    use warnings;

    use CGI                         qw( :standard );
    use Dpchrist::CGI               qw( :all );

    my $pinfo   = untaint_path path_info;
    my $name    = untaint_textfield param('name');
    my $comment = untaint_textarea param('comment');
    my $special = untaint_regex(qr/([a-z ]+)/, param('special'));
    my $cookie  = cookie(-name => 'mycookie', -value => 'chololate chip');

    print(
	header(-cookie => $cookie),
	start_html,
	start_form,
	'name:',     nbsp(4), textfield(-name => 'name'   ), br,
	'comment: ',          textarea( -name => 'comment'), br,
	'special: ', nbsp(2), textfield(-name => 'special'), br,
	submit, br,
	a({
	    -href => script_name . '/path/info?' . join('&',
		'name=<strong>attempted%20sneaky%20tags</strong>',
		'comment=One%20bright%20day%0D%0A' .
			'In%20the%20middle%20of%20the%20night,',
		'special=Regex%20matches%20lowercase%20and%20whitespacE',
		),
	    },
	    'test link'
	), br,
	end_form, hr,
	'path info: ',       escapeHTML($pinfo),    br,
	'name:',    nbsp(4), escapeHTML($name),     br,
	'comment:',      pre(escapeHTML($comment)), br,
	'special:', nbsp(2), escapeHTML($special),  br,
	pre(
	    escapeHTML(dump_cookies),
	    escapeHTML(dump_params),
	), br,
	end_html,
    );


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
    dump_params OBJECT

Calls get_params_as_rha() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

If OBJECT is provided,
it must be a CGI object or derived from CGI.

=cut

sub dump_params
{
    my $params = get_params_as_rha(@_);

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
    get_params_as_rha OBJECT

Calls CGI::param($i) in list context for all CGI parameters,
populating a hash-of-arrays data structure along the way,
and returns a reference to the data structure.

If OBJECT is provided,
it must be a CGI object or derived from CGI.

=cut

sub get_params_as_rha
{
    ### $CGI::Q may be undefined if no CGI calls made yet

    my $q = shift;

    my @params = $q ? $q->param() : param();

    $q = $CGI::Q unless $q;

    confess join(' ', 'ERROR: bad CGI object',
	Data::Dumper->Dump([\@_, \@params, $q], [qw(*_ params q)]),
    ) unless isa_object($q, 'CGI');

    my $rha = {};

    foreach (@params) {
	$rha->{$_} = [ $q->param($_) ];
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

Passes through call to untaint_regex()
using a RX suitable for Unix paths
(everying except NULL).

=cut

sub untaint_path
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex(RX_UNTAINT_PATH, @_);
}

#----------------------------------------------------------------------

=head3 untaint_regex

    untaint_regex RX,LIST

Apply regular expression to each element in LIST.
If LIST is empty, return void.
In list context, process LIST
and return first captured substrings for each LIST item.
In scalar context, process first LIST item
and return first captured substring.

Caller usually creates RX with the quote regex operator 'qr()'.

Returns undef for LIST elements that are references.

Calls Carp::confess() on error.

=cut

sub untaint_regex
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: first argument must be a regular expression',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless @_ && ref($_[0]) eq 'Regexp';

    my $rx = shift;

    if (@_) {
	my @r;
	foreach (@_) {
	    cluck join(' ',
		'attempt to apply regular expression',
		'to undefined value',
	    ) unless defined($_);
	    cluck 'attempt to apply regular expression to reference'
		if ref($_);
	    if (defined($_) && !ref($_)) {
		$_ =~ $rx;
		push @r, $1;
	    }
	    else {
		push @r, undef;
	    }
	    last unless wantarray;
	}
	ddump('return',
	    wantarray ? ([\@r],   ['*r']  )
		      : ([$r[0]], ['r[0]'])
	) if DEBUG;
	return (wantarray) ? @r : $r[0];
    }
    dprint 'returning void' if DEBUG;
    return;
}

#----------------------------------------------------------------------

=head3 untaint_textarea

    untaint_textarea LIST

Passes through call to untaint_regex()
using a RX suitable for text areas
(printable characters plus carriage return and line feed).

=cut

sub untaint_textarea
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex(RX_UNTAINT_TEXTAREA, @_);
}

#----------------------------------------------------------------------

=head3 untaint_textfield

    untaint_textfield LIST

Passes through call to untaint_regex()
using a RX suitable for text areas
(printable characters).

=cut

sub untaint_textfield
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex(RX_UNTAINT_TEXTFIELD, @_);
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
