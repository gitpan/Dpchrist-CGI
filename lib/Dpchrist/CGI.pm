#######################################################################
# $Id: CGI.pm,v 1.44 2010-11-26 20:46:41 dpchrist Exp $
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
	$CHECKSUM_SALT
	%PASSWORD_FIELD_ARGS
	%TEXTAREA_ARGS
	%TEXTFIELD_ARGS
	%TH_ATTR
	calc_checksum
	dump_cookies
	dump_params
	gen_checkbox
	gen_hidden
	gen_password_field
	gen_textarea
	gen_td
	gen_textfield
	gen_th
	get_params_as_rha
	get_cookies_as_rhh
	merge_args
	merge_attr
	nbsp
	untaint_checkbox
	untaint_path
	untaint_regex
	untaint_textarea
	untaint_textfield
	validate_checkbox
	validate_hidden
	validate_parameter_present
	validate_password_field
	validate_textarea
	validate_textfield
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = sprintf "%d.%03d", q$Revision: 1.44 $ =~ /(\d+)/g;

#######################################################################
# uses:
#----------------------------------------------------------------------

use Carp			qw( cluck confess );
use CGI				qw( :standard );
use Data::Dumper;
use Digest::MD5			qw( md5_hex );
use Dpchrist::Debug		qw( :all );
use Dpchrist::Is		qw( :all );

#######################################################################

=head1 NAME

Dpchrist::CGI - utility subroutines for CGI scripts


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.44 $.


This is alpha test level software
and may change or disappear at any time.


=head2 GLOBALS

=cut

#----------------------------------------------------------------------

=head3 %CHECKBOX_ARGS

    %CHECKBOX_ARGS = ();

Default argments used by gen_checkbox().

=cut

our %CHECKBOX_ARGS = ();

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

Default argments used by gen_password().

=cut

our %PASSWORD_FIELD_ARGS = (
    -size      => 70,
    -maxlength => 80,
);

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_CHECKBOX

    $RX_UNTAINT_CHECKBOX = qr/(on)/;

Regular expression used for untainting paths.

=cut

our $RX_UNTAINT_CHECKBOX = qr/(on)/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_PATH

    $RX_UNTAINT_PATH = qr/([^\x00]+)/;

Regular expression used for untainting paths.

=cut

our $RX_UNTAINT_PATH = qr/([^\x00]+)/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_TEXTAREA
    
    $RX_UNTAINT_TEXTAREA = qr/([\PC\n\r]+)/;

Regular expression used for untainting textareas.

=cut

our $RX_UNTAINT_TEXTAREA	= qr/([\PC\n\r]+)/;

#----------------------------------------------------------------------

=head3 $RX_UNTAINT_TEXTFIELD

    $RX_UNTAINT_TEXTFIELD = qr/([\PC]+)/;

Regular expression used for untainting textfields and password fields.

=cut

our $RX_UNTAINT_TEXTFIELD	= qr/([\PC]+)/;

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

#----------------------------------------------------------------------

=head3 calc_checksum

    my $md5 = calc_checksum(LIST);

    # LIST are items to be fed into the checksum

Walks list and expands array references.
Passes through call to Digest::MD5::md5_hex()
using $CHECKSUM_SALT and walked list.

LIST items, and referenced array items,
should be strings,
otherwise the checksum seems to be different
for each hit (?).

Calls Carp::confess() on error.

=cut

sub calc_checksum
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires at least one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_;

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

#----------------------------------------------------------------------

=head3 dump_cookies

    push @debug_html, pre(escapeHTML(dump_cookies()));

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

    push @debug_html, pre(escapeHTML(dump_params()));

    push @debug_html, pre(escapeHTML(dump_params(OBJECT)));

    # OBJECT (optional) is a CGI object or CGI-derived object

Calls get_params_as_rha() (see below),
feeds the returned reference to Data::Dumper->Dump(),
and returns the result.

=cut

sub dump_params
{
    my $params = get_params_as_rha(@_);

    return Data::Dumper->Dump([$params], [qw(params)]);
}

#----------------------------------------------------------------------

=head3 gen_checkbox

    push @html, gen_checkbox(ARGS);

    # ARGS are named arguments

Merges named arguments ARGS
with default arguments %CHECKBOX_ARGS
(ARGS have priority),
and passes through call with net arguments to CGI::checkbox().

=cut

sub gen_checkbox
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%CHECKBOX_ARGS);

    ddump('pass through call to CGI::checkbox()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::checkbox(@_);
}

#----------------------------------------------------------------------

=head3 gen_hidden

    push @html, gen_hidden(-name => NAME, -value => VALUE);

    # NAME is a CGI parameter name

    # VALUE is the parameter value, or a reference to a list of values

Returns an array of HTML elements:

[0]  A hidden control with name NAME and value VALUE.

[1]  A hidden control with name given by
NAME with '_ck' suffix
and value given by
calling calc_checksum()
with $CHECKSUM_SALT and incoming arguments.

Calls Carp::confess() on error.

=cut

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

    my $md5 = calc_checksum(@_);
    ddump([$md5], [qw(md5)]) if DEBUG;

    push @html, CGI::hidden(-name => $name . '_ck', -value => $md5);

    ddump('return', [\@html], [qw(*html)]) if DEBUG;
    return @html;
}

#----------------------------------------------------------------------

=head3 gen_password_field

    push @html, gen_password_field(ARGS);

    # ARGS are named arguments

Merges named arguments ARGS
with default arguments %PASSWORD_FIELD_ARGS
(ARGS have priority),
and passes through call with net arguments to CGI::password_field().

=cut

sub gen_password_field
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%PASSWORD_FIELD_ARGS);

    ddump('pass through call to CGI::password_field()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::password_field(@_);
}

#----------------------------------------------------------------------

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

sub gen_td
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_attr(\@_, \%TD_ATTR);

    ddump('pass through call to CGI::td()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::td(@_);
}

#----------------------------------------------------------------------

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

sub gen_textarea
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%TEXTAREA_ARGS);

    ddump('pass through call to CGI::textarea()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::textarea(@_);
}

#----------------------------------------------------------------------

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

sub gen_textfield
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_args(\@_, \%TEXTFIELD_ARGS);

    ddump('pass through call to CGI::textfield()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::textfield(@_);
}

#----------------------------------------------------------------------

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

sub gen_th
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    merge_attr(\@_, \%TH_ATTR);

    ddump('pass through call to CGI::th()',
	[\@_], [qw(*_)]) if DEBUG;
    CGI::th(@_);
}

#----------------------------------------------------------------------

=head3 get_cookies_as_rhh

    my $cookies = get_cookies_as_rhh();

Calls CGI::cookie() in list context for all CGI cookies
and returns a reference to a hash-of-hashes data structure.

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

    my $params = get_params_as_rha();

    my $params = get_params_as_rha(OBJECT);

    # OBJECT (optional) is a CGI object or CGI-derived object

Calls CGI::param() in list context for all CGI parameters
and returns a hash-of-arrays data structure.

Calls Carp::confess() on error.

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

#----------------------------------------------------------------------

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
Returns void.
Doesn't bother to merge if reference array is empty.
Returns void.

Calls Carp::confess() on error.

=cut

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

#----------------------------------------------------------------------

=head3 nbsp

    push @html, nbsp();

    push @html, nbsp(EXPR);

    # EXPR (optional) is a whole number

Returns one or more nonbreaking space HTML character entities.

Calls Carp::confess() on error.

=cut

sub nbsp
{
    confess join(' ',
	'ERROR: argument is not a whole number',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) if @_ && !is_wholenumber($_[0]);

    my $n = shift || 1;

    my $s = '&nbsp; ';

    return $s x $n;
}

#----------------------------------------------------------------------

=head3 untaint_checkbox

    my @untainted = untaint_checkbox(LIST);

    # LIST are strings to be untainted

Passes through call to untaint_regex()
using a RX suitable for checkboxs
('on').

=cut

sub untaint_checkbox
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex($RX_UNTAINT_CHECKBOX, @_);
}

#----------------------------------------------------------------------

=head3 untaint_path

    my @untainted = untaint_path(LIST);

    # LIST are strings to be untainted

Passes through call to untaint_regex()
using a RX suitable for Unix paths
(everying except NULL).

=cut

sub untaint_path
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex($RX_UNTAINT_PATH, @_);
}

#----------------------------------------------------------------------

=head3 untaint_regex

    my @untainted = untaint_regex(RX, LIST);

    # RX is a regular epxression

    # LIST are strings to be untainted

Applies regular expression to each element in LIST.
If LIST is empty, returns void.
In list context, process LIST
and return first captured substrings for each LIST item.
In scalar context, process first LIST item
and return first captured substring.

Caller usually creates RX with
the quote regular expression operator 'qr()'.

Returns undef for LIST elements that are references.

Calls Carp::confess() on error.

Calls Carp::cluck() if LIST contains undefined values
or references.

=cut

sub untaint_regex
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: first argument must be a regular expression',
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless @_ && is_rxref($_[0]);

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

    my @untainted = untaint_textarea(LIST);

    # LIST are strings to be untainted

Passes through call to untaint_regex()
using a RX suitable for text areas
(printable characters plus carriage return and line feed).

=cut

sub untaint_textarea
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex($RX_UNTAINT_TEXTAREA, @_);
}

#----------------------------------------------------------------------

=head3 untaint_textfield

    my @untainted = untaint_textfield(LIST);

    # LIST are strings to be untainted

Passes through call to untaint_regex()
using a RX suitable for textfields
(printable characters).

=cut

sub untaint_textfield
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    dprint('passing through call to untaint_regex()') if DEBUG;
    return untaint_regex($RX_UNTAINT_TEXTFIELD, @_);
}

#----------------------------------------------------------------------

=head3 validate_checkbox

    push @errors, validate_checkbox(NAME);

    # NAME is a CGI parameter name

Performs checkbox checks on 
CGI parameter with name NAME.
Skips checks if CGI parameter does not exist (e.g. empty or fresh hit).
Returns error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_checkbox
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 1;

    confess join(' ',
	'ERROR: argument must be a CGI parameter name',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_nonempty_string $_[0];

    my $name = shift;
    my $p = param($name);
    my @errors;

    if ($p) {
	my $u = untaint_checkbox($p);
	push @errors, (
	    "ERROR: parameter '$name' contains invalid characters",
	) unless $u && $p eq $u;
    }

    ddump('return', [\@errors], [qw(errors)]) if DEBUG;
    return @errors;
}

#----------------------------------------------------------------------

=head3 validate_hidden

    push @errors, validate_hidden(NAME);

    # NAME is a CGI parameter name

Performs hidden field checks on
CGI parameter with name NAME.
Skips checks if no CGI parameters exist (e.g. fresh hit).
Returns error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_hidden
{
    ddump('call', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires exactly one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 1;

    my ($name) = @_;
    ddump([$name], [qw(name)]) if DEBUG;

    confess join(' ',
	"ERROR: argument must be a CGI parameter name",
	Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless is_nonempty_string($name);

    my @errors;

    goto DONE unless param();

    my @value = param($name);
    ddump([\@value], [qw(*value)]) if DEBUG;

    unless (@value) {
	push @errors, "ERROR: parameter '$name' missing";
	goto DONE;
    }

    my $ck = param($name . '_ck');
    ddump([$ck], [qw(ck)]) if DEBUG;

    unless ($ck) {
	push @errors, (
	    "ERROR: parameter '$name' checksum missing",
	);
	goto DONE;
    }

    my $md5 = calc_checksum(-name => $name, -value => \@value);
    ddump([$md5], [qw(md5)]) if DEBUG;

    push @errors, (
	"ERROR: parameter '$name' checksum bad"
    ) unless $ck eq $md5;

  DONE:

    ddump('return', [\@errors], [qw(*errors)]) if DEBUG;
    return @errors;
}

#----------------------------------------------------------------------

=head3 validate_parameter_present

    push @errors, validate_required_parameters(LIST);

    # LIST are CGI parameter names

Checks that the CGI parameters with names in LIST
are defined and have values.
Skips checks if no CGI parameters exist (e.g. fresh hit).
Returns list of error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_parameter_present
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires at least one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_;

    confess join(' ',
	'ERROR: arguments must be CGI parameter names',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) if grep {!is_nonempty_string $_} @_;

    my @errors;

    goto DONE unless param();

    foreach (@_) {
	my $v = param($_);
	push @errors, join('',
	    "ERROR: parameter '$_' missing",
	) unless is_nonempty_string $v;
    }

  DONE:

    ddump('return', [\@errors], [qw(errors)]) if DEBUG;
    return @errors;
}

#----------------------------------------------------------------------

=head3 validate_password_field

    push @errors, validate_password_field(NAME);

    # NAME is a CGI parameter name

Performs password field checks on 
CGI parameter with name NAME.
Skips checks if CGI parameter does not exist (e.g. empty or fresh hit).
Returns error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_password_field
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 1;

    confess join(' ',
	'ERROR: argument must be a CGI parameter name',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_nonempty_string $_[0];

    my $name = shift;
    my $p = param($name);
    my @errors;

    if ($p) {
	push @errors, (
	    "ERROR: parameter '$name' is too long",
	) if $PASSWORD_FIELD_ARGS{-maxlength} < length $p;

	my $u = untaint_textfield($p);
	push @errors, (
	    "ERROR: parameter '$name' contains invalid characters",
	) unless $u && $p eq $u;
    }

    ddump('return', [\@errors], [qw(errors)]) if DEBUG;
    return @errors;
}

#----------------------------------------------------------------------

=head3 validate_textarea

    push @error, validate_textarea(NAME);

    # NAME is a CGI parameter name

Performs textarea checks
on CGI parameter with name NAME.
Skips checks if parameter does not exist (e.g. empty or fresh hit).
Returns error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_textarea
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 1;

    confess join(' ',
	'ERROR: argument must be a CGI parameter name',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_nonempty_string $_[0];

    my $name = shift;
    my $p = param($name);
    my @errors;

    if ($p) {
	push @errors, (
	    "ERROR: parameter '$name' is too long",
	) if $TEXTAREA_ARGS{-maxlength} < length $p;

	my $u = untaint_textarea($p);
	push @errors, (
	    "ERROR: parameter '$name' contains invalid characters",
	) unless $u && $p eq $u;
    }

    ddump('return', [\@errors], [qw(errors)]) if DEBUG;
    return @errors;
}

#----------------------------------------------------------------------

=head3 validate_textfield

    push @errors, validate_textfield(NAME);

    # NAME is a CGI parameter name

Performs textfield checks
on CGI parameter with name NAME.
Skips checks if parameter does not exist (e.g. empty or fresh hit).
and returns error strings if problems found.

Calls Carp::confess() on error.

=cut

sub validate_textfield
{
    ddump('enter', [\@_], [qw(*_)]) if DEBUG;

    confess join(' ',
	'ERROR: requires one argument',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless @_ == 1;

    confess join(' ',
	'ERROR: argument must be a CGI parameter name',
	Data::Dumper->Dump([\@_], [qw(*_)])
    ) unless is_nonempty_string $_[0];

    my $name = shift;
    my $p = param($name);
    my @errors;

    if ($p) {
	push @errors, (
	    "ERROR: parameter '$name' is too long",
	) if $TEXTFIELD_ARGS{-maxlength} < length $p;

	my $u = untaint_textfield($p);
	push @errors, (
	    "ERROR: parameter '$name' contains invalid characters",
	) unless $u && $p eq $u;
    }

    ddump('return', [\@errors], [qw(errors)]) if DEBUG;
    return @errors;
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

Old school:

    perl Makefile.PL
    make
    make test
    make install

Minimal:

    cpan Dpchrist::CGI

Complete:

    cpan Bundle::Dpchrist


=head2 DEPENDENCIES

See Makefile.PL in source distribution root directory.


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
