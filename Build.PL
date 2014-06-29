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
	# patch out @execute_path...
	'perl -pi -e \'s/\@executable_path/\$\(INSTALL_DIR\)/g\' nss/lib/freebl/config.mk',
	'perl -pi -e \'s/\@executable_path/\$\(INSTALL_DIR\)/g\' nss/coreconf/Darwin.mk',
	'perl -pi -e \'s/\@executable_path/\$\(INSTALL_DIR\)/g\' nspr/configure',
	'perl -pi -e \'s/\@executable_path/\$\(INSTALL_DIR\)/g\' nspr/configure.in',
	"echo 'Option add64: $add64'",
	'uname',
	'uname -m',
	'uname -a',
	#'rm -r nss/cmd/shlibsign/', # fix build for OSx
	'bash -c \''.$make.' -C nss nss_build_all INSTALL_DIR=%s/lib BUILD_OPT=1 '.$add64.'\'',
	'mkdir stage',
	'mkdir stage/include',
	'mkdir stage/lib',
	'cp -L dist/public/nss/* stage/include',
	'cp -L -R dist/*.OBJ/include/* stage/include',
	'cp -L -R dist/*.OBJ/lib/* stage/lib',
	'rm -r dist nss nspr'
);

my $builder = Alien::Base::ModuleBuild->new (
	(sign => 1),
	module_name => 'Alien::NSS',
	license => 'mozilla',
	configure_requires => {
		'Alien::Base' => '0.003', # 0.002 has a breaking bug, 0.001 also works
		'Module::Build' => '0.38',
		'Test::More' => 0,
	},
	requires => {
		'perl' => '5.8.1',
		'Alien::Base' => '0.003',
	},
	dist_author => 'Johanna Amann <johanna@icir.org>',
	alien_name => 'nss',
	alien_repository => {
		protocol => 'ftp',
		host => 'ftp.mozilla.org',
		location => 'pub/mozilla.org/security/nss/releases/NSS_3_16_2_RTM/src/',
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
	resources => {
		license => ['http://www.mozilla.org/MPL/2.0/'],
		homepage => 'https://github.com/0xxon/alien-nss',
		bugtracker  => {
			web => 'https://github.com/0xxon/alien-nss/issues',
		},
		repository  => {
			url => 'https://github.com/0xxon/alien-nss.git',
			type => 'git',
		},
	},

);

if ( defined($builder->args->{'patchnss'}) ) {
	print "Adding command to patch NSS to Build\n";
	unshift(@build_commands, "patch -p1 < ../../patch/nss.patch");
}

$builder->alien_build_commands(\@build_commands);

$builder->create_build_script;
