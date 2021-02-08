#/usr/bin/env perl

use strict;
use warnings;

# I tried 'require'-ing modules but that did not work.

use CGI::Session; # For the version #.

use Test::More;

use CGI;
use Digest::MD5;
use Data::Dumper;
use Test::More;
use Scalar::Util;

# ----------------------

pass('All external modules loaded');

my(@modules) = qw
/
	CGI
	Digest::MD5
	Data::Dumper
	Test::More
	Scalar::Util
/;

diag "Testing CGI::Session V $CGI::Session::VERSION";

for my $module (@modules)
{
	no strict 'refs';

	my($ver) = ${$module . '::VERSION'} || 'N/A';

	diag "Using $module V $ver";
}

done_testing;
