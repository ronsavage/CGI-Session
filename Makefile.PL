# $Id$

use strict;
use Text::Wrap;
use File::Spec;
use lib './t/lib';
use ExtUtils::MakeMaker;

# ------------------------------------------------

sub create_changelog_ini
{
	my($error);

	eval "require Module::Metadata::Changes";

	if ($@)
	{
		$error = $@;
	}
	else
	{
		# Ensure Changelog.ini is writable.

		if (-e 'Changelog.ini' && ! -w 'Changelog.ini')
		{
			$error = (chmod 0200, 'Changelog.ini' == 0) ? 'Could not make Changelog.ini writable' : '';
		}

		if (! $error)
		{
			eval
			{
				print "Regenerating Changelog.ini...\n";

				`ini.report.pl -c -i Changes`;

				if (! -e 'Changelog.ini')
				{
					# Warning: Can't use $@ to carry msg out of block(s).

					$error = 'Failed to generate Changelog.ini';
				}
				else
				{
					my(@stat) = stat 'Changelog.ini';

					# Was the file modified in the last 2 seconds?

					if ( (time() - $stat[9]) < 2)
					{
						# Yes. Do nothing.
					}
					else
					{
						$error = 'Failed to update Changelog.ini';
					}
				}
			};

			if ($@)
			{
				$error = $@;
			}
		}
	}

	# We ignore the precise value of $@ here.

	if ($error)
	{
		print "Warning: Module::Metadata::Changes's ini.report.pl failed to generate or update Changelog.ini. \n";
	}
	else
	{
		print "Changelog.ini generated or updated. \n";
	}

} # End of create_changelog_ini.

# ------------------------------------------------

print "-" x 40, "\n";
print fill("", "", <<'MESSAGE');
#### WARNING ####

If you are using custom CGI::Session drivers they may not be compatible with the current driver specifications. You will need to make some changes to your drivers' code before proceeding with this installation to make it compatible with CGI::Session 4.x.

Fortunately, current driver specifications are a lot easier to adapt to. Should you have any assistance re-coding your current drivers, please let me know.

Current driver specs are documented in CGI/Session/Driver.pm

#### TESTING #####

You are encouraged to run tests for the backend you will be using. The database backends that need a customized connection string won't run by default. To run them, some environment variables must be set.

The simplest method is to use the standard "DBI_DSN/DBI_USER/DBI_PASS" environment variables.

Otherwise, you can set these variables:
MESSAGE

print "
For PostgreSQL:
    CGISESS_PG_DSN
    CGISESS_PG_USER
    CGISESS_PG_PASS

For MySQL:
    CGISESS_MYSQL_DSN
    CGISESS_MYSQL_USER
    CGISESS_MYSQL_PASS
    CGISESS_MYSQL_SOCKET
";

print "\n";
print "-" x 40, "\n";

create_changelog_ini();
print "-" x 40, "\n";

my(%params) =
(
	($] ge '5.005') ?
	(
		'AUTHOR'	=> 'Sherzod Ruzmetov <sherzodr@cpan.org>',
		'ABSTRACT'	=> 'Persistent session data in CGI applications',
    ) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST CGI-Session-* t/cgisess.* t/sessiondata'
	},
	dist =>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	NAME         => 'CGI::Session',
	LICENSE		=> 'perl',
	PL_FILES     => {},
	PREREQ_PM    =>
	{
		'base'				=> 0,
		'CGI'               => 3.26,
		'Digest::MD5'       => 0,
		'Data::Dumper'      => 0,
		'DB_File'			=> 0,
		'DBD::Pg'			=> 0,
		'DBI'				=> 0,
		'Digest::MD5'		=> 0,
		'Fcntl'				=> 0,
		'File::Basename'	=> 0,
		'File::Spec'		=> 0,
		'FreezeThaw'		=> 0,
		'overload'			=> 0,
		'Safe'				=> 0,
		'Scalar::Util'      => 0,
		'Storable'			=> 0,
		'strict'			=> 0,
		'vars'				=> 0,
    },
	TEST_REQUIRES =>
	{
		'Env'			=> 0,
		'Test::More'	=> 0,
	},
	EXTRA_META => "
no_index:
    package:
    - CGI::Session::Test::SimpleObjectClass
    - CGI::Session::Test::Default
    - OverloadedObjectClass
    - OverloadedClass
",
	VERSION_FROM	=> 'lib/CGI/Session.pm',
	INSTALLDIRS		=> 'site',
	EXE_FILES		=> [],
);


if ( ($ExtUtils::MakeMaker::VERSION =~ /^\d\.\d\d$/) && ($ExtUtils::MakeMaker::VERSION > 6.30) )
{
	$params{LICENSE} = 'perl';
}

if ($ExtUtils::MakeMaker::VERSION ge '6.46')
{
	$params{META_MERGE} =
	{
		'meta-spec' =>
		{
			version => 2,
		},
		resources   =>
		{
			bugtracker =>
			{
				web => 'https://github.com/ronsavage/CGI-Session/issues',
			},
			license		=> 'http://opensource.org/licenses/Perl',
			repository	=>
			{
				type	=> 'git',
				url		=> 'https://github.com/ronsavage/CGI-Session.git',
				web		=> 'https://github.com/ronsavage/CGI-Session',
			},
		},
	};
}

WriteMakefile(%params);

#
# Creating place for test-scripts. Some of the scripts needs this to be present
#
mkdir(File::Spec->catfile('t', 'sessiondata'));

package MY;
use strict;

sub postamble {
    return <<'MAKE_TEXT';
prepare_dist ::	metafile manifest dist
	$(NOECHO) $(NOOP)
MAKE_TEXT
}

sub libscan {
    my ($self, $path) = @_;
    return '' if $path =~ m/\.svn/;
    return $path;
}


