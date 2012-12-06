use strict;
use warnings;

use Alien::Base::ModuleBuild;

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
	dist_author => 'Johanna Amann <johanna@icir.org',
	alien_name => 'dontpanic',
	alien_repository => {
		protocol => 'ftp',
		host => 'ftp.mozilla.org',
		location => '/pub/mozilla.org/security/nss/releases/NSS_3_14_RTM/src/',
		pattern  => qr/^nss-([\d\.]+)-with-nspr-.*\.tar\.gz$/,
	},

	# who needs configure, etc.
	alien_build_commands => [
		'rm -r mozilla/security/nss/cmd/shlibsign/', # fix build for OSx
		'make -C mozilla/security/nss nss_build_all BUILD_OPT=1 $([ $(uname -m) = x86_64 ] && echo USE_64=1)',
	],
	alien_install_commands => [
		'if [ ! -e %s ] ; then mkdir %s; fi',
		'if [ ! -e %s/include ] ; then mkdir %s/include; fi',
		'if [ ! -e %s/lib ] ; then mkdir %s/lib; fi',
		'cp -L mozilla/dist/public/nss/* %s/include',
		'cp -L -R mozilla/dist/*.OBJ/include/* %s/include',
		'cp -L -R mozilla/dist/*.OBJ/lib/* %s/lib',
	],


);


$builder->create_build_script;
