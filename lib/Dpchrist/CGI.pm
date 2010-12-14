#######################################################################
# $Id: CGI.pm,v 1.58 2010-12-14 06:05:36 dpchrist Exp $
#######################################################################
# package:
#----------------------------------------------------------------------

package Dpchrist::CGI;

use constant DEBUG		=> 0;

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	%CHECKBOX_ARGS
	$CHECKSUM_LENGTH
	$CHECKSUM_SALT
	%PASSWORD_FIELD_ARGS
	$RX_PASSTHROUGH
	$RX_UNTAINT_CHECKBOX
	$RX_UNTAINT_CHECKSUM
	$RX_UNTAINT_PASSWORD_FIELD
	$RX_UNTAINT_PATH
	$RX_UNTAINT_RADIO_GROUP
	$RX_UNTAINT_TEXTAREA
	$RX_UNTAINT_TEXTFIELD
	%TD_ATTR
	%TEXTAREA_ARGS
	%TEXTFIELD_ARGS
	%TH_ATTR
	dump_cookies
	dump_params
	gen_checkbox
	gen_hidden
	gen_password_field
	gen_td
	gen_textarea
	gen_textfield
	gen_th
	get_cookies_as_rhh
	get_params_as_rha
	merge_args
	merge_attr
	nbsp
	untaint_checkbox
	untaint_password_field
	untaint_path
	untaint_radio_group
	untaint_textarea
	untaint_textfield
	validate_checkbox
	validate_hidden
	validate_parameter_is_required
	validate_password_field
	validate_radio_group
	validate_textarea
	validate_textfield
) ] );

our @EXPORT_OK = (
    @{ $EXPORT_TAGS{'all'} },
    qw(
	_calc_checksum
	_untaint_regexp
	_validate_checksum
	_validate_textual
    ),
);

our @EXPORT = qw( );

our $VERSION = sprintf "%d.%03d", q$Revision: 1.58 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp			qw( cluck confess );
use CGI				qw( :standard );
use Data::Dumper;
use Digest::MD5			qw( md5_hex );
use Dpchrist::Debug		qw( :all );
use Dpchrist::Is		qw( :all );
use Dpchrist::LangUtil		qw( :all );

#######################################################################

=head1 NAME

Dpchrist::CGI - utility subroutines for CGI scripts


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.58 $.


This is alpha test level software
and may change or disappear at any time.


=head2 GLOBALS

=cut

#----------------------------------------------------------------------

=head3 %CHECKBOX_ARGS

    %CHECKBOX_ARGS = (
	-value => 'on',
    );

Default argments used by gen_checkbox().

=cut

our %CHECKBOX_ARGS = (
    -value => 'on',
);

#----------------------------------------------------------------------

=head3 $CHECKSUM_LENGTH

    $CHECKSUM_LENGTH = 32;

Length of checksum strings.

=cut

our $CHECKSUM_LENGTH = 32;

#----------------------------------------------------------------------

=head3 $CHECKSUM_SALT

    $CHECKSUM_SALT = join ' ', __PACKAGE__, __FILE__, __LINE__;

Default hashing salt used by gen_hidden_checksum().
Caller should set this value after use'ing this module.

=cut

our $CHECKSUM_SALT = join ' ', __PACKAGE__, __FILE__, __LINE__;

#----------------------------------------------------------------------

=head3 %PASSWORD_FIELD_ARGS

    %PASSWORD_FIELD_ARGS = (
	-size      => 70,
	-maxlength => 80,
    );

Default argments used by gen_password_field().

=cut

our %PASSWORD_FIELD_ARGS = (
    -size      => 70,
    -maxlength => 80,
);

#----------------------------------------------------------------------

=head3 $RX_PASSTHROUGH

    $RX_PASSTHROUGH    => qr/^(.*)$/;

Regular expression for testing untaint_*() subroutines.
Passes all characters.

=cut

our $RX_PASSTHROUGH    = qr/^(.*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_CHECKBOX

    $RX_UNTAINT_CHECKBOX = qr/^([\PC]*)$/;

Regular expression for untainting checkbox parameter values.
Passes printable characters.

=cut

our $RX_UNTAINT_CHECKBOX = qr/^([\PC]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_CHECKSUM

    $RX_UNTAINT_CHECKSUM = qr/^[0-9a-f]{32}$/;

Regular expression for untainting checksum parameter values.

=cut

our $RX_UNTAINT_CHECKSUM = qr/^([0-9a-f]{32})$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_PASSWORD_FIELD

    $RX_UNTAINT_PASSWORD_FIELD = qr/^([\PC]*)$/;

Regular expression used for untainting password field parameter values.
Passes printable characters.

=cut

our $RX_UNTAINT_PASSWORD_FIELD	= qr/^([\PC]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_PATH

    $RX_UNTAINT_PATH = qr/^([^\x00]*)$/;

Regular expression used for untainting paths.
Passes all characters except NUL.

=cut

our $RX_UNTAINT_PATH = qr/^([^\x00]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_POPUP

    $RX_UNTAINT_POPUP = qr/^([\PC]*)$/;

Regular expression used for untainting popup parameter values.
Passes printable characters.

=cut

our $RX_UNTAINT_POPUP	= qr/^([\PC]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_RADIO_GROUP

    $RX_UNTAINT_RADIO_GROUP = qr/^([\PC]*)$/;

Regular expression used for untainting radio group parameter values.
Passes printable characters.

=cut

our $RX_UNTAINT_RADIO_GROUP	= qr/^([\PC]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_TEXTAREA
    
    $RX_UNTAINT_TEXTAREA = qr/^([\PC\r\n]*)$/;

Regular expression used for untainting textarea parameter values.
Passes printable characters plus carriage return and linefeed.

=cut

our $RX_UNTAINT_TEXTAREA	= qr/^([\PC\n\r]*)$/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_TEXTFIELD

    $RX_UNTAINT_TEXTFIELD = qr/^([\PC]*)$/;

Regular expression used for untainting textfield parameter values.
Passes printable characters.

=cut

our $RX_UNTAINT_TEXTFIELD	= qr/^([\PC]*)$/;

#----------------------------------------------------------------------

=head3 %TD_ATTR

    %TD_ATTR = (
	-align  => 'LEFT', 
	-valign => 'TOP',
    );

Default attributes used by gen_td().

=cut

our %TD_ATTR = (
    -align  => 'LEFT', 
    -valign => 'TOP',
);

#----------------------------------------------------------------------

=head3 %TEXTAREA_ARGS

    TEXTAREA_ARGS = (    
	-maxlength => 32*1024,
	-columns   => 80,
	-rows      => 24,
	-wrap      => 'physical',
    );

Default arguments used by gen_textarea().

=cut

our %TEXTAREA_ARGS = (    
    -maxlength => 32*1024,
    -columns   => 80,
    -rows      => 24,
    -wrap      => 'physical',
);

#----------------------------------------------------------------------

=head3 %TEXTFIELD_ARGS

    %TEXTFIELD_ARGS = (
	-size      => 70,
	-maxlength => 80,
    );

Default arguments used by gen_textfield().

=cut

our %TEXTFIELD_ARGS = (
    -size      => 70,
    -maxlength => 80,
);

#----------------------------------------------------------------------

=head3 %TH_ATTR

    %TH_ATTR = (
	-align  => 'LEFT', 
	-valign => 'TOP',
	-width  => '20%',
    );

Default attributes used by gen_th().

=cut

our %TH_ATTR = (
    -align  => 'LEFT', 
    -valign => 'TOP',
    -width  => '20%',
);

#######################################################################

=head2 SUBROUTINES

=cut

#######################################################################
# private subroutines:
#======================================================================

sub _assert_positional_argument_n_must_be_arrayref
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be array reference",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_arrayref $_[1]->[$_[0]];
    
    return 1;
}

#======================================================================

sub _assert_positional_argument_n_must_be_coderef
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be code reference",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_coderef $_[1]->[$_[0]];
    
    return 1;
}

#======================================================================

sub _assert_positional_argument_n_must_be_defined
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be defined",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless defined $_[1]->[$_[0]];
    
    return 1;
}

#======================================================================

sub _assert_positional_argument_n_must_be_parameter_name
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be parameter name",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_nonempty_string $_[1]->[$_[0]];
}

#======================================================================

sub _assert_positional_argument_n_must_be_wholenumber
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be whole number",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_wholenumber $_[1]->[$_[0]];
    
    return 1;
}

#======================================================================

sub _assert_positional_argument_n_must_be_regexpref
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: positional argument $_[0] must be",
	'regular expression reference',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_regexpref $_[1]->[$_[0]];
    
    return 1;
}

#======================================================================

sub _assert_requires_at_least_n_arguments
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: requires at least $_[0] arguments",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless $_[0] <= scalar @{$_[1]};
}

#======================================================================

sub _assert_requires_exactly_n_arguments
{
    # my ($n, $ra_args) = @_;

    confess join(' ',
	"ERROR: requires exactly $_[0] arguments",
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless scalar @{$_[1]} == $_[0];
}

#======================================================================

sub _calc_checksum
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_at_least_n_arguments(1, \@_);

    my @args = ($CHECKSUM_SALT);
    foreach (@_) {
	confess join(' ',
	    'ERROR: arguments must be strings or array references',
	    Data::Dumper->Dump([\@_], [qw(*_)]),
	) unless is_string($_) || is_arrayref($_);

	push @args, ref($_) ? @$_ : $_;
    }
    ddump([\@args], [qw(*args)]) if DEBUG;

    my $md5 = md5_hex(@args);

    ddump('return', [$md5], [qw(md5)]) if DEBUG;
    return $md5;
}

#======================================================================

sub _error_parameter_is_required
{
    # my ($ra_errors, $name) = @_;

    _assert_requires_exactly_n_arguments(2, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);

    push @{$_[0]}, (
	"ERROR: parameter '$_[1]' is required",
    );

    return 1;
}

#======================================================================

sub _untaint_checksum
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_CHECKSUM, @_);
}

#======================================================================

sub _untaint_regexp
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_at_least_n_arguments(1, \@_);
    _assert_positional_argument_n_must_be_regexpref(0, \@_);

    my ($rx, @values) = @_;

    my @r;

    foreach (@_[1 .. $#_]) {
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

  DONE:
    ddump('return',
	wantarray ? ([\@r],   ['*r']  )
		  : ([$r[0]], ['r[0]'])
    ) if DEBUG;
    return (wantarray) ? @r : $r[0];
}

#======================================================================

sub _validate_checksum
{
    _assert_requires_exactly_n_arguments(2, \@_);

    dprint('passing through call to _validate_textual()') if DEBUG;
    return _validate_textual(
	@_, \&_untaint_checksum, $CHECKSUM_LENGTH
    );
}

#======================================================================

sub _validate_parameter_length_must_be_n_characters_or_less
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    # my ($ra_errors, $name, $uvalue, $maxlength) = @_;

    _assert_requires_exactly_n_arguments(4, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);
    _assert_positional_argument_n_must_be_defined(2, \@_);
    _assert_positional_argument_n_must_be_wholenumber(3, \@_);

    my $r;

    if ($_[3] < length $_[2]) {
	push @{$_[0]}, (
	    "ERROR: parameter '$_[1]' length must be " . 
	    "$_[3] characters or less",
	);
	goto DONE;
    }
    $r = 1;

  DONE:

    ddump('return', [\@_, $r], [qw(*_ r)]) if DEBUG;
    return $r;
}

#======================================================================

sub _validate_parameter_must_have_single_value
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    # my ($ra_errors, $name, $ra_values) = @_;

    _assert_requires_exactly_n_arguments(3, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);
    _assert_positional_argument_n_must_be_arrayref(2, \@_);
    
    my $r;

    if (1 < scalar @{$_[2]}) {
	push @{$_[0]}, (
	    "ERROR: parameter '$_[1]' must have single value",
	);
	goto DONE;
    }

    $r = 1;

  DONE:

    ddump('return', [\@_, $r], [qw(*_ r)]) if DEBUG;
    return $r;
}

#======================================================================

sub _validate_parameter_must_contain_valid_characters
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    # my ($ra_errors, $name, $value, $uvalue) = @_;

    _assert_requires_exactly_n_arguments(4, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);
    _assert_positional_argument_n_must_be_defined(2, \@_);
    ### arg 3 will be undef if failed to untaint

    my ($ra, $rb);

    if (is_arrayref $_[2]) {
	$ra = $_[2];
	$rb = $_[3];
    }
    else {
	$ra = [$_[2]];
	$rb = [$_[3]];
    }
    ddump([$ra, $rb], [qw(ra rb)]) if DEBUG;

    my $r = 1;

    if (arrayref_cmp $ra, $rb) {
	push @{$_[0]}, join(' ',
    	    "ERROR: parameter '$_[1]' must contain valid characters",
	);
	$r = undef;
    }

  DONE:

    ddump('return', [\@_, $r], [qw(*_ r)]) if DEBUG;
    return $r;
}

#======================================================================

sub _validate_textual
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    # my ($ra_errors, $name, $rc_untaint, $maxlength) = @_;

    _assert_requires_exactly_n_arguments(4, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);
    _assert_positional_argument_n_must_be_coderef(2, \@_);
    _assert_positional_argument_n_must_be_wholenumber(3, \@_);

    my @values = param($_[1]);
    ddump([\@values], [qw(*values)]) if DEBUG;

    my $r;
    my $uvalue;

    if (scalar @values) {

        _validate_parameter_must_have_single_value(
	    @_[0, 1], \@values
	) or goto DONE;

	$uvalue = $_[2]->($values[0]);
	ddump([$uvalue], [qw(uvalue)]) if DEBUG;

        _validate_parameter_must_contain_valid_characters(
	    @_[0, 1], $values[0], $uvalue
	) or goto DONE;

	_validate_parameter_length_must_be_n_characters_or_less(
	    @_[0, 1], $uvalue, $_[3]
	) or goto DONE;

	$r = $uvalue;
	ddump([$r], [qw(r)]) if DEBUG;
    }

  DONE:

    ddump('return', [$_[0], $r], [qw(_[0] r)]) if DEBUG;
    return $r;
}

#######################################################################
# public subroutines:
#======================================================================

=head3 dump_cookies

    push @debug_html, pre(escapeHTML(dump_cookies()));

Calls get_cookies_as_rhh() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

=cut

#----------------------------------------------------------------------

sub dump_cookies
{
    my $cookies = get_cookies_as_rhh();

    return Data::Dumper->Dump([$cookies], [qw(cookies)]);
}

#======================================================================

=head3 dump_params

    push @debug_html, pre(escapeHTML(dump_params()));

    push @debug_html, pre(escapeHTML(dump_params(OBJECT)));

    # OBJECT (optional) is a CGI object or CGI-derived object

Calls get_params_as_rha() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

=cut

#----------------------------------------------------------------------

sub dump_params
{
    my $params = get_params_as_rha(@_);

    return Data::Dumper->Dump([$params], [qw(params)]);
}

#======================================================================

=head3 gen_checkbox

    push @html, gen_checkbox(ARGS);

    # ARGS are named arguments

Merges named arguments ARGS
with default arguments %CHECKBOX_ARGS
(ARGS have priority),
and passes through call with net arguments to CGI::checkbox().

=cut

#----------------------------------------------------------------------

sub gen_checkbox
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%CHECKBOX_ARGS);

    ddump('pass through call to CGI::checkbox()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::checkbox(@_);
}

#======================================================================

=head3 gen_hidden

    push @html, gen_hidden(-name => NAME, -value => VALUE);

    # NAME is a CGI parameter name

    # VALUE is the parameter value, or a reference to a list of values

Returns an array of HTML elements:

[0]  A hidden control with name NAME and value VALUE.

[1]  A hidden control with name given by
NAME with '_ck' suffix
and md5_hex() checksum value given by
$CHECKSUM_SALT and incoming arguments.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub gen_hidden
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires exactly four arguments',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 4;

    my %hargs = @_;

    confess join(' ',
	"ERROR: argument '-name' missing",
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless exists $hargs{-name};

    my $name = $hargs{-name};

    confess join(' ',
	"ERROR: argument '-name' must be a CGI parameter name",
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless is_nonempty_string($name);

    confess join(' ',
	"ERROR: argument '-value' missing",
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless exists $hargs{-value};

    my $value = $hargs{-value};

    confess join(' ',
	"ERROR: argument '-value' must be a string",
	'or an array reference',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless is_string($value) || is_arrayref($value);

    my @html;

    push @html, CGI::hidden(@_);

    my $md5 = _calc_checksum(@_);
    ddump([$md5], [qw(md5)]) if DEBUG;

    push @html, CGI::hidden(-name => $name . '_ck', -value => $md5);

    ddump('return', [\@html], [qw(*html)]) if DEBUG;
    return @html;
}

#======================================================================

=head3 gen_password_field

    push @html, gen_password_field(ARGS);

    # ARGS are named arguments

Merges named arguments ARGS
with default arguments %PASSWORD_FIELD_ARGS
(ARGS have priority),
and passes through call with net arguments to CGI::password_field().

=cut

#----------------------------------------------------------------------

sub gen_password_field
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%PASSWORD_FIELD_ARGS);

    ddump('pass through call to CGI::password_field()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::password_field(@_);
}

#======================================================================

=head3 gen_td

    push @html, table( Tr([
	th('one') . gen_td(ARGS),
	th('two') . gen_td(ATTR, ARGS),
    ]));

    # ARGS are named arguments

    # ATTR (optional) is a reference to a hash of attributes

Merges named attributes ATTR
with default attributes %TD_ATTR
(ATTR has priority)
and passes through call
with net attributes and arguments
to CGI::td().

=cut

#----------------------------------------------------------------------

sub gen_td
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_attr(\@_, \%TD_ATTR);

    ddump('pass through call to CGI::td()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::td(@_);
}

#======================================================================

=head3 gen_textarea

    push @html, gen_textarea(ARGS);

    # ARGS is a list of named arguments

Merges name arguments ARGS
with default arguments %TEXTAREA_ARGS
(ARGS has priority)
and passes through call
with net arguments
to CGI::textarea().

=cut

#----------------------------------------------------------------------

sub gen_textarea
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%TEXTAREA_ARGS);

    ddump('pass through call to CGI::textarea()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::textarea(@_);
}

#======================================================================

=head3 gen_textfield

    push @html, gen_textfield(ARGS);

    # ARGS is a list of named arguments

Merges named arguments ARGS
with default arguments %TEXTAREA_ARGS
(ARGS has priority)
and passes through call
with net attributes and arguments
to CGI::textfield().

=cut

#----------------------------------------------------------------------

sub gen_textfield
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%TEXTFIELD_ARGS);

    ddump('pass through call to CGI::textfield()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::textfield(@_);
}

#======================================================================

=head3 gen_th

    push @html, table( Tr([
	gen_th(ARGS)       . td(1),
	gen_th(ATTR, ARGS) . td(2),
    ]));

    # ARGS is a list of arguments

    # ATTR (optional) is a reference to a hash of named attributes

Merges named attributes ATTR
with default attributes %TH_ATTR
(ATTR has priority)
and passes through call
with net attributes and arguments
to CGI::th().

=cut

#----------------------------------------------------------------------

sub gen_th
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_attr(\@_, \%TH_ATTR);

    ddump('pass through call to CGI::th()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::th(@_);
}

#======================================================================

=head3 get_cookies_as_rhh

    my $cookies = get_cookies_as_rhh();

Calls CGI::cookie() in list context for all CGI cookies
and returns a reference to a hash-of-hashes data structure.

=cut

#----------------------------------------------------------------------

sub get_cookies_as_rhh
{
    my $cookies;

    foreach (cookie()) {
	$cookies->{$_} = { cookie($_) };
    }

    return $cookies;
}

#======================================================================

=head3 get_params_as_rha

    my $params = get_params_as_rha();

    my $params = get_params_as_rha(OBJECT);

    # OBJECT (optional) is a CGI object or CGI-derived object

Calls CGI::param() in list context for all CGI parameters
and returns a hash-of-arrays data structure.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

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

#======================================================================

=head3 merge_args

    merge_args(ARRAYREF, ARGS);

    # ARRAYREF is a reference to an array

    # ARGS is a reference to a hash of named arguments

Inserts or merges named arguments ARGS
into array referenced by ARRAYREF.
Typically used with CGI.pm widget generating functions,
such as textarea().
Referenced array is modified in the process,
and key/value pairs may be reordered.
Returns void.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub merge_args
{
    my $arg_dump = Data::Dumper->Dump([\@_], [qw(*_)]);

    my ($ra, $rh) = @_;
    ddump([$ra, $rh], [qw(ra rh)]) if DEBUG;

    confess 'ERROR: requires two arguments ARRAYREF and HASHREF'
	unless @_ == 2;

    confess 'ERROR: first argument must be reference to array'
	unless is_arrayref $ra;

    confess 'ERROR: second argument must be reference to hash'
	unless is_hashref $rh;

    my %h = (%$rh, @$ra);

    @$ra = %h;
    ddump([$ra], [qw(ra)]) if DEBUG;

    dprint('return void') if DEBUG;
    return;
}

#======================================================================

=head3 merge_attr

    merge_attr(ARRAYREF, ATTR);

    # ARRAYREF is a reference to an array

    # ATTR is a reference to a hash of named attributes

Inserts or merges named attributes ATTR
into array referenced by ARRAYREF.
Attributes in first element of referenced array
take precedence over attributes in ATTR.
Typically used with CGI.pm tag generating functions,
such as td().
First element of referenced array
may be created or modified in the process.
Doesn't bother to merge if reference array is empty.
Returns void.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub merge_attr
{
    my $arg_dump = Data::Dumper->Dump([\@_], [qw(*_)]);

    dprint('call', $arg_dump) if DEBUG;

    my ($ra, $rh) = @_;
    ddump([$ra, $rh], [qw(ra rh)]) if DEBUG;

    confess 'ERROR: requires two arguments ARRAYREF and HASHREF'
	unless @_ == 2;

    confess 'ERROR: first argument must be reference to array'
	unless is_arrayref $ra;

    confess 'ERROR: second argument must be reference to hash'
	unless is_hashref $rh;

    if (@$ra) {
	my $attr = {};
	
	if ($ra->[0] && ref($ra->[0]) eq 'HASH') {
	    my $rh2 = shift @$ra;
	    $attr = {%$rh, %$rh2};
	    ddump([$ra, $rh2, $attr], [qw(ra rh2 attr)]) if DEBUG;
	}
	else {
	    $attr = {%$rh};
	    ddump([$attr], [qw(attr)]) if DEBUG;
	}

	unshift @$ra, $attr;
	ddump([$ra], [qw(ra)]) if DEBUG;
    }

    dprint('return void') if DEBUG;
    return;
}

#======================================================================

=head3 nbsp

    push @html, nbsp();

    push @html, nbsp(EXPR);

    # EXPR (optional) is a whole number

Returns zero or more non-breaking space HTML character entities.
Call without arguments returns one non-breaking space.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub nbsp
{
    confess join(' ',
	'ERROR: argument is not a whole number',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if @_ && !is_wholenumber($_[0]);

    my $n = defined_or(shift, 1);

    my $s = '&nbsp;';

    return $s x $n;
}

#======================================================================

=head3 untaint_checkbox

    my @untainted = untaint_checkbox(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_CHECKBOX.

=cut

#----------------------------------------------------------------------

sub untaint_checkbox
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_CHECKBOX, @_);
}

#======================================================================

=head3 untaint_hidden

    my @untainted = untaint_hidden(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_PASSTHROUGH.

=cut

#----------------------------------------------------------------------

sub untaint_hidden
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_PASSTHROUGH, @_);
}

#======================================================================

=head3 untaint_password_field

    my @untainted = untaint_password_field(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_PASSWORD_FIELD.

=cut

#----------------------------------------------------------------------

sub untaint_password_field
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_PASSWORD_FIELD, @_);
}

#======================================================================

=head3 untaint_path

    my @untainted = untaint_path(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_PATH.

=cut

#----------------------------------------------------------------------

sub untaint_path
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_PATH, @_);
}

#======================================================================

=head3 untaint_popup

    my @untainted = untaint_popup(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_POPUP.

=cut

#----------------------------------------------------------------------

sub untaint_popup
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_POPUP, @_);
}

#======================================================================

=head3 untaint_radio_group

    my @untainted = untaint_radio_group(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_RADIO_GROUP.

=cut

#----------------------------------------------------------------------

sub untaint_radio_group
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_RADIO_GROUP, @_);
}

#======================================================================

=head3 untaint_textarea

    my @untainted = untaint_textarea(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_TEXTAREA.

=cut

#----------------------------------------------------------------------

sub untaint_textarea
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_TEXTAREA, @_);
}

#======================================================================

=head3 untaint_textfield

    my @untainted = untaint_textfield(LIST);

    # LIST are strings to be untainted

Passes through call to _untaint_regexp()
using $RX_UNTAINT_TEXTFIELD.

=cut

#----------------------------------------------------------------------

sub untaint_textfield
{
    dprint('passing through call to _untaint_regexp()') if DEBUG;
    return _untaint_regexp($RX_UNTAINT_TEXTFIELD, @_);
}

#======================================================================

=head3 validate_checkbox

    my $v = validate_checkbox(RA_ERRORS, NAME);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter name

Untaints, validates, and returns value of checkbox CGI parameter NAME
-- must have single value,
must contain valid characters (calls untaint_checkbox()),
and must contain valid value (compares to $CHECKBOX_ARGS{-value}).
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Per CGI.pm, note that return value
will also be undef when checkbox is unchecked.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_checkbox
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_exactly_n_arguments(2, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);

    my @values = param($_[1]);
    ddump([\@values], [qw(*values)]) if DEBUG;

    my $uvalue;
    my $r;

    if (scalar @values) {

	_validate_parameter_must_have_single_value(
	    @_[0, 1], \@values
	) or goto DONE;

	$uvalue = untaint_checkbox($values[0]);
	ddump([$uvalue], [qw(uvalue)]) if DEBUG;

	_validate_parameter_must_contain_valid_characters(
	    @_[0, 1], $values[0], $uvalue
	) or goto DONE;

	ddump([\%CHECKBOX_ARGS], [qw(*CHECKBOX_ARGS)]) if DEBUG;

	unless ($uvalue eq $CHECKBOX_ARGS{-value}) {
	    push @{$_[0]}, (
		"ERROR: parameter '$_[1]' must contain valid value",
	    );
	    goto DONE;
	}

	$r = $uvalue;
    }

  DONE:

    ddump('return', [$_[0], $r], [qw(_[0] r)]) if DEBUG;
    return $r;
}

#======================================================================

=head3 validate_hidden

    my $v = validate_hidden(RA_ERRORS, NAME);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter name

Untaints, validates, and returns value of hidden CGI parameter NAME
-- hidden parameter(s) required if any parameters exist,
checksum parameter is required,
checksum parameter must validate as textual field,
hidden parameter(s) must contain valid characters,
and hidden parameter(s) checksum must match checksum parameter.
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Returns empty list if no CGI parameters exist (e.g. fresh hit).

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_hidden
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_exactly_n_arguments(2, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);

    my @r;

    goto DONE unless param();

    my @values = param($_[1]);
    ddump([\@values], [qw(*values)]) if DEBUG;

    if (scalar @values) {

	my $nx = $_[1] . '_ck';
	ddump([$nx], [qw(nx)]) if DEBUG;

	validate_parameter_is_required($_[0], $nx)
	    or do {
	    push @{$_[0]}, "ERROR: parameter '$_[1]' checksum missing";
	    goto DONE;
	};

	my $ck = _validate_checksum($_[0], $nx)
	    or do {
	    push @{$_[0]}, "ERROR: parameter '$_[1]' checksum bad";
	    goto DONE;
	};
	ddump([$ck], [qw(ck)]) if DEBUG;

	my @uvalues = untaint_hidden(@values);
	ddump([\@uvalues], [qw(*uvalues)]) if DEBUG;

	_validate_parameter_must_contain_valid_characters(
	    @_[0, 1], \@values, \@uvalues
	) or goto DONE;

	my $md5 = _calc_checksum(-name => $_[1], -value => \@uvalues);
    	ddump([$md5], [qw(md5)]) if DEBUG;

	unless ($ck eq $md5) {
	    push @{$_[0]}, (
		"ERROR: parameter '$_[1]' checksum bad"
	    );
	    goto DONE;
	}

	@r = @uvalues;
    }
    else {
	_error_parameter_is_required @_[0, 1];
    }

  DONE:

    if (wantarray) {
	ddump('return', [$_[0], \@r], [qw(_[0] *r)]) if DEBUG;
	return @r;
    }
    else {
	ddump('return', [$_[0], $r[0]], [qw(_[0] r)]) if DEBUG;
	return $r[0];
    }
}

#======================================================================

=head3 validate_parameter_is_required

    my $ok = validate_parameter_is_required(RA_ERRORS, LIST);

    # RA_ERRORS is reference to array of error messages

    # LIST are CGI parameter names

Verifies that CGI parameters named in LIST exist,
including the undefined value.
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Returns empty list if no CGI parameters exist (e.g. fresh hit).

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_parameter_is_required
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_at_least_n_arguments(2, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    for (my $i = 1; $i < scalar @_; $i++) {
	_assert_positional_argument_n_must_be_parameter_name($i, \@_);
    }

    my $r = 1;

    goto DONE unless param();

    foreach (@_[1 .. $#_]) {
	my @v = param($_);
	unless (0 < scalar @v) {
	    push @{$_[0]}, join('',
		"ERROR: parameter '$_' is required",
	    );
	    $r = undef;
	}
    }

  DONE:

    ddump('return', [$_[0], $r], [qw(_[0] r)]) if DEBUG;
    return $r;
}

#======================================================================

=head3 validate_password_field

    my $v = validate_password_field(RA_ERRORS, NAME);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter name

Untaints, validates, and returns value of password field
CGI parameter NAME
-- must have single value,
must contain valid characters (calls untaint_password_field()),
and length must be n characters or less
(compares to $PASSWORD_FIELD_ARGS{-maxlength}).
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_password_field
{
    _assert_requires_exactly_n_arguments(2, \@_);

    dprint('passing through call to _validate_textual()') if DEBUG;
    return _validate_textual(
	@_, \&untaint_password_field, $PASSWORD_FIELD_ARGS{-maxlength}
    );
}

#======================================================================

=head3 validate_radio_group

    my $v = validate_radio_group(RA_ERRORS, NAME, RA_VALUES);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter nameo

    # RA_VALUES is reference to array of allowed values

Untaints, validates, and returns radio group CGI parameter NAME --
is required,
must have single value,
must contain valid characters (calls untaint_radio_group()),
and must contain valid value (be in @RA_VALUES).
If any problems are found,
pushes error messages onto @RA_ERRORS
and returns undef.

Returns undef if no CGI parameters exist (e.g. fresh hit).

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_radio_group
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    _assert_requires_exactly_n_arguments(3, \@_);
    _assert_positional_argument_n_must_be_arrayref(0, \@_);
    _assert_positional_argument_n_must_be_parameter_name(1, \@_);
    _assert_positional_argument_n_must_be_arrayref(2, \@_);

    my $r;

    goto DONE unless param;

    my @values = param($_[1]);
    ddump([\@values], [qw(*values)]) if DEBUG;

    my $uvalue;

    if (scalar @values) {

        _validate_parameter_must_have_single_value(
	    @_[0, 1], \@values 
	) or goto DONE;

        $uvalue = untaint_radio_group($values[0]);
	ddump([$uvalue], [qw(uvalue)]) if DEBUG;

        _validate_parameter_must_contain_valid_characters(
	    @_[0, 1], $values[0], $uvalue
	) or goto DONE; 

	unless (grep {$uvalue eq $_} @{$_[2]}) {
	    push @{$_[0]}, join(' ',
		"ERROR: parameter '$_[1]' must contain valid value",
	    );
	    goto DONE;
	}

	$r = $uvalue;
    }
    else {
	_error_parameter_is_required @_[0, 1];
    }

  DONE:

    ddump('return', [$_[0], $r], [qw(_[0] r)]) if DEBUG;
    return $r;
}

#======================================================================

=head3 validate_textarea

    my $v = validate_textarea(RA_ERRORS, NAME);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter name

Untaints, validates, and returns value of textarea CGI parameter NAME
-- must have single value,
must contain valid characters (calls untaint_textarea()),
and length must be n characters or less
(compares to $TEXTAREA_ARGS{-maxlength}).
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_textarea
{
    _assert_requires_exactly_n_arguments(2, \@_);

    dprint('passing through call to _validate_textual()') if DEBUG;
    return _validate_textual(
	@_, \&untaint_textarea, $TEXTAREA_ARGS{-maxlength}
    );
}

#======================================================================

=head3 validate_textfield

    my $v = validate_textfield(RA_ERRORS, NAME);

    # RA_ERRORS is reference to array of error messages

    # NAME is a CGI parameter name

Untaints, validates, and returns value of textfield CGI parameter NAME
-- must have single value,
must contain valid characters (calls untaint_textfield()),
and length must be n characters or less
(compares to $TEXTFIELD_ARGS{-maxlength}).
If any problems found,
pushes error messages onto @RA_ERRORS
and returns undef.

Calls Carp::confess() on error.

=cut

#----------------------------------------------------------------------

sub validate_textfield
{
    _assert_requires_exactly_n_arguments(2, \@_);

    dprint('passing through call to _validate_textual()') if DEBUG;
    return _validate_textual(
	@_, \&untaint_textfield, $TEXTFIELD_ARGS{-maxlength}
    );
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


=head1 INSTALLATION

Old school:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

Minimal:

    $ cpan Dpchrist::CGI

Complete:

    $ cpan Bundle::Dpchrist


=head2 PREREQUISITES

See Makefile.PL in the source distribution root directory.


=head1 SEE ALSO

    CGI.pm


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
