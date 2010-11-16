#######################################################################
# $Id: Widget.pm,v 1.4 2010-11-16 05:28:51 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::CGI::Widget;

use 5.010;
use strict;
use warnings;

use constant DEBUG		=> 0;

our $VERSION = sprintf "%d.%03d", q$Revision: 1.4 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::Debug		qw( :all );
use Dpchrist::Is		qw( :all );

#######################################################################

=head1 NAME

Dpchrist::CGI::Widget - base class for CGI widgets

=head2 OBJECT METHODS

=cut

#----------------------------------------------------------------------

=head3 name

    OBJECT->name

Returns -name attribute of object.
Cannot be used to set attribute.

Calls Carp::confess() on error.

=cut

sub name
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    my $self = shift;
    confess join(' ',
	'ERROR: object method called incorrectly',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless isa_object($self, __PACKAGE__);
    confess join(' ',
	"ERROR: attribute 'name' is read only",
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if @_;

    my $name = $self->{-name};

    ddump('return', [$name], [qw(name)]) if DEBUG;
    return $name;
}

#----------------------------------------------------------------------

=head3 value

    OBJECT->value
    OBJECT->value EXPR

If EXPR provided,
sets CGI parameter per OBJECT -name to -value.
Returns (existing or updated) CGI parameter.
Semantics match CGI::param() as much as possible.
See 'perldoc CGI' for details.

Calls Carp::confess() on error.

=cut

sub value
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    my $self = shift;
    confess join(' ',
	'ERROR: object method called incorrectly',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless isa_object($self, __PACKAGE__);

    confess join(' ',
	'ERROR: accepts zero or one arguments',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if 1 < @_;

    my $name = $self->name;

    CGI::param(
	-name => $name,
	-value => $_[0],
    ) if @_;

    if (wantarray) {
	my @value = CGI::param($name);
	ddump('return', [\@value], [qw(*value)]) if DEBUG;
	return @value;
    }
    else
    {
	my $value = CGI::param($name);
	ddump('return', [$value], [qw(value)]) if DEBUG;
	return $value;
    }
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;

__END__

#######################################################################

=head1 INSTALLATION

Installed as part of Dpchrist::CGI.


=head1 SEE ALSO

    CGI
    Dpchrist::CGI
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
