#/usr/bin/env perl

use strict;
use warnings;

# I tried 'require'-ing modules but that did not work.

use CGI::Session; # For the version #.

use Test::More;

use base;
use CGI;
use Digest::MD5;
use Data::Dumper;
use DB_File;
use DBD::Pg;
use DBI;
use Digest::MD5;
use Fcntl;
use File::Basename;
use File::Spec;
use FreezeThaw;
use overload;
use Safe;
use Scalar::Util;
use Storable;
use strict;
use vars;

# ----------------------

pass('All external modules loaded');

my(@modules) = qw
/
	base
	CGI
	Digest::MD5
	Data::Dumper
	DB_File
	DBD::Pg
	DBI
	Digest::MD5
	Fcntl
	File::Basename
	File::Spec
	FreezeThaw
	overload
	Safe
	Scalar::Util
	Storable
	strict
	vars
/;

diag "Testing CGI::Session V $CGI::Session::VERSION";

for my $module (@modules)
{
	no strict 'refs';

	my($ver) = ${$module . '::VERSION'} || 'N/A';

	diag "Using $module V $ver";
}

done_testing;
