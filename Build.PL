use strict;
use warnings;

use Alien::Base::ModuleBuild;
use Data::Dumper;

my $make;

`gmake --version 2>&1`;
if ( $? == 0 ) {
	$make = 'gmake';
} elsif ( `make --version 2>&1` =~ m#GNU# ) {
	$make = 'make';
} else {
	print STDERR "No suitable make could be found\n";
	my $makeversion = `make --version 2>&1`;
	print STDERR "Result of trying make --version:\n$makeversion\n";
	exit(0);
}

my $arch = `uname -m`;
warn "\nArchitecture: $arch\n";
my $add64 = "";
if ( $arch =~ m#64# ) {
	$add64 = "USE_64=1";
}

my $builder = Alien::Base::ModuleBuild->new (
	module_name => 'Alien::NSS',
	license => 'mozilla',
	configure_requires => {
		'Alien::Base' => '0.001',
		'Module::Build' => '0.38',
	},
	requires => {
		'perl' => '5.8.1',
		'Alien::Base' => 0,
	},
	dist_author => 'Johanna Amann <johanna@icir.org>',
	alien_name => 'nss',
	alien_repository => {
		protocol => 'ftp',
		host => 'ftp.mozilla.org',
		location => '/pub/mozilla.org/security/nss/releases/NSS_3_14_RTM/src/',
		pattern  => qr/^nss-([\d\.]+)-with-nspr-.*\.tar\.gz$/,
	},

	# who needs configure, etc.
	alien_build_commands => [
		"echo 'Option add64: $add64'",
		'uname',
		'uname -m',
		'uname -a',
		'rm -r mozilla/security/nss/cmd/shlibsign/', # fix build for OSx
		'bash -c \''.$make.' -C mozilla/security/nss nss_build_all BUILD_OPT=1 '.$add64.'\'',
		'rm -r mozilla/nsprpub/*.OBJ/config/nspr.pc' # and remove the nspr.pc to make alien happy
	],
	alien_install_commands => [
		'if [ ! -e %s ] ; then mkdir %s; fi',
		'if [ ! -e %s/include ] ; then mkdir %s/include; fi',
		'if [ ! -e %s/lib ] ; then mkdir %s/lib; fi',
		'if [ -d mozilla ]; then cp -L mozilla/dist/public/nss/* %s/include; fi',
		'if [ -d mozilla ]; then cp -L -R mozilla/dist/*.OBJ/include/* %s/include; fi',
		'if [ -d mozilla ]; then cp -L -R mozilla/dist/*.OBJ/lib/* %s/lib; fi',
	],


);


$builder->create_build_script;
