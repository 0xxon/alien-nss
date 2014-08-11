package Alien::NSS;

use strict;
use warnings;

our $VERSION = '0.19';

use parent 'Alien::Base';

1;

__END__

=head1 NAME

Alien::NSS - Alien wrapper for NSS ( Network Security Services )

=head1 SYNOPSIS

  use strict;
  use warnings;

  use Module::Build;
  use Alien::NSS;

  my $cflags = Alien::NSS->cflags;
  my $ldflags = Alien::NSS->libs;

  my $builder = Module::Build->new(
    module_name => 'my_lib',
    extra_compiler_flags => $cflags,
    extra_linker_flags => $ldflags,
    configure_requires => {
      'Alien::NSS => 0
    },
  );

  $builder->create_build_script;


=head1 ABSTRACT

Alien wrapper for NSS ( Network Security Services )

=head1 DESCRIPTION

This library provides an alien wrapper for NSS, the cryptographic
library that is ( among others ) used in Mozilla Firefox and Google Chrome.

