#######################################################################
# $Id: Checkbox.pm,v 1.5 2010-11-16 05:28:51 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::CGI::Widget::Checkbox;

use 5.010;
use strict;
use warnings;

use constant DEBUG		=> 0;

use constant ATTR_NAME_DEFAULT	=> 'checkbox';
use constant CGI_CHECKBOX_ARGS_ALLOWED => {
    -checked	=> 1,
    -force	=> 1,
    -label	=> 1,
    -name	=> 1,
    -on		=> 1,
    -onClick	=> 1,
    -override	=> 1,
    -selected	=> 1,
    -value	=> 1,
};
use constant GENHTML_WIDGET_ARGS_ALLOWED => {
    -checked	=> 1,
    -force	=> 1,
    -label	=> 1,
    -name	=> 0,
    -on		=> 1,
    -onClick	=> 1,
    -override	=> 1,
    -selected	=> 1,
    -value	=> 1,
};
use constant NEW_ARGS_ALLOWED => {
    -checked	=> 1,
    -force	=> 1,
    -label	=> 1,
    -name	=> 1,
    -on		=> 1,
    -onClick	=> 1,
    -override	=> 1,
    -selected	=> 1,
    -value	=> 1,
};

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp;
use CGI				qw( :standard );
use Data::Dumper;
use Dpchrist::CGI::Widget;
use Dpchrist::Debug		qw( :all );
use Dpchrist::Is		qw( :all );

#######################################################################
# globals:
#----------------------------------------------------------------------

our %Checkbox = (
    -object_serial	=> 0,
);

our @ISA = qw(Dpchrist::CGI::Widget);

our $VERSION = sprintf "%d.%03d", q$Revision: 1.5 $ =~ /(\d+)/g;

#######################################################################

=head1 NAME

Dpchrist::CGI::Widget::Checkbox - derived class for CGI checkboxes

=head2 CONSTRUCTOR

=head3 new

    CLASS->new [KEY=>VALUE]...

Creates a checkbox object with specified attributes.
The following attributes are recognized:

    -checked
    -force
    -label
    -name
    -on	
    -onClick
    -override
    -selected
    -value

If -name is omitted,
constructor sets attribute to "textboxN";
where N is an automatically incrementing serial number
starting at 0.

If -value is specified,
calls CGI::param() and sets the -name parameter to the value specified.

Calls Carp::confess() on error.

=cut

sub new
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    my $class = shift;
    confess join (' ',
	'ERROR: class method called incorrectly',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless isa_class($class, __PACKAGE__);

    my %args = @_;
    foreach (keys %args) {
	my @e = grep {!NEW_ARGS_ALLOWED->{$_}} keys %args;
	confess join(' ',
    	    'ERROR: argument(s) unknown or not allowed',
	    Data::Dumper->Dump([\@e], [qw(e)]),
	) if @e;
    }

    my $self = {};

    $self->{-name} = exists($args{-name})
	? $args{-name}
	: ATTR_NAME_DEFAULT . $Checkbox{-object_serial}++;

    CGI::param(
	-name  => $self->{-name},
	-value => $args{-value},
    ) if exists $args{-value};

    foreach (qw(
	-checked -selected -on -label -onClick -override -force )) {
	$self->{$_} = $args{$_} if exists $args{$_};
    }

    bless ($self, $class);

    ddump('return', [$self], [qw(self)]) if DEBUG;
    return $self;
}

#######################################################################

=head2 OBJECT METHODS

=head3 genhtml_widget

    OBJECT->genhtml_widget [KEY=>VALUE]...

Returns HTML fragment for displaying a checkbox widget in a web page.
Provided attributes, if any,
temporarily override object attributes of the same name.
The following attributes are recognized:

    -checked
    -force
    -label
    -on	
    -onClick
    -override
    -selected
    -value

Calls Carp::confess() on error.

=cut

# object methods:
#----------------------------------------------------------------------

sub genhtml_widget
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    my $self = shift;
    confess join(' ',
	'ERROR: object method called incorrectly',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless isa_object($self, __PACKAGE__);

    my %args = @_;
    foreach (keys %args) {
	my @e = grep {!GENHTML_WIDGET_ARGS_ALLOWED->{$_}} keys %args;
	confess join(' ',
    	    'ERROR: argument(s) unknown or not allowed',
	    Data::Dumper->Dump([\@e], [qw(e)]),
	) if @e;
    }

    my %h = (%$self, %args);
    ddump([\%h], [qw(h)]) if DEBUG;

    my @html = CGI::checkbox(%h);

    ddump('return', [\@html], [qw(*html)]) if DEBUG;
    return @html;
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
    Dpchrist::CGI::Widget


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
