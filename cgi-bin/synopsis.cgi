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
