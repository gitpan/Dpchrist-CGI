#######################################################################
# $Id: Makefile.PL,v 1.12 2010-11-25 20:52:50 dpchrist Exp $
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#######################################################################

use ExtUtils::MakeMaker;

use Dpchrist::Module::MakefilePL (
    -mcpani		=> $ENV{CPAN_AUTHORID},
    -pod2html	 	=> qw(lib/Dpchrist/CGI.pm),
    -readme	 	=> qw(lib/Dpchrist/CGI.pm),
    -release		=> $ENV{RELEASE_ROOT},
);

WriteMakefile(
    NAME		=> 'Dpchrist::CGI',
    VERSION_FROM	=> 'lib/Dpchrist/CGI.pm',
    ABSTRACT_FROM	=> 'lib/Dpchrist/CGI.pm',
    PREREQ_PM		=> {
	'Dpchrist::Debug'	=> 1.041,
	'Dpchrist::Is'		=> 1.024,
	'Dpchrist::LangUtil'	=> 1.010,
	'Dpchrist::Module'	=> 1.021,
	'Capture::Tiny'		=> 0,
	'feature'		=> 0,
    },
    AUTHOR		=>
	'David Paul Christensen <dpchrist@holgerdanske.com>',
    clean		=> {
	FILES => q( *~tmp */*~tmp Dpchrist* debug.log ),
    },
);

#######################################################################
