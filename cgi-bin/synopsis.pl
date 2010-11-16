    use CGI		qw(:standard);
    use Dpchrist::CGI	qw(:all);

    my $path_info	= untaint_path(path_info()	  ) || '';
    my $path_translated	= untaint_path(path_translated()  ) || '';
    my $name    = untaint_textfield(      param('name')	  ) || '';
    my $comment = untaint_textarea(       param('comment')) || '';
    my $special = untaint_regex('[abc]*', param('special')) || '';

    print join("\n",
	header,
	start_html,
	pre(dump_cookies), br,
	pre(dump_params), br,
	nbsp(4), pre("path_info:       $path_info"      ),
	nbsp(4), pre("path_translated: $path_translated"),
	start_form,
	textfield(-name => 'name'),
	textarea (-name => 'comment'),
	textfield(-name => 'special'),
	end_form,
	end_html,
    );
