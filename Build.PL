use strict;
use warnings;

use Alien::Base::ModuleBuild;

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

my @build_commands = (
	"patch -p1 < ../../patch/shlibsign.patch", 
	"echo 'Option add64: $add64'",
	'uname',
	'uname -m',
	'uname -a',
	'rm -r mozilla/security/nss/cmd/shlibsign/', # fix build for OSx
	'bash -c \''.$make.' -C mozilla/security/nss nss_build_all BUILD_OPT=1 '.$add64.'\'',
	'mkdir stage',
	'mkdir stage/include',
	'mkdir stage/lib',
	'cp -L mozilla/dist/public/nss/* stage/include',
	'cp -L -R mozilla/dist/*.OBJ/include/* stage/include',
	'cp -L -R mozilla/dist/*.OBJ/lib/* stage/lib',
	'rm -r mozilla'
);

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
		location => 'pub/mozilla.org/security/nss/releases/NSS_3_14_1_RTM/src/',
		pattern  => qr/^nss-([\d\.]+)-with-nspr-.*\.tar\.gz$/,
	},

	# who needs configure, etc.
	alien_install_commands => [
		'if [ ! -e %s ] ; then mkdir %s; fi',
		'if [ ! -e %s/include ] ; then mkdir %s/include; fi',
		'if [ ! -e %s/lib ] ; then mkdir %s/lib; fi',
		'if [ -d stage ]; then cp -L -R stage/include/* %s/include; fi',
		'if [ -d stage ]; then cp -L -R stage/lib/* %s/lib; fi',
	],
);

if ( defined($builder->args->{'patchnss'}) ) {
	print "Adding command to patch NSS to Build\n";
	unshift(@build_commands, "patch -p1 < ../../patch/nss.patch");
}

$builder->alien_build_commands(\@build_commands);

$builder->create_build_script;
