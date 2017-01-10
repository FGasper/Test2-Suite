package Test2::Compare::Scalar;
use strict;
use warnings;

use base 'Test2::Compare::Base';

our $VERSION = '0.000064';

use Test2::Util::HashBase qw/item/;

use Carp qw/croak confess/;
use Scalar::Util qw/reftype blessed/;

sub init {
    my $self = shift;
    croak "'item' is a required attribute"
        unless $self->{+ITEM};

    $self->SUPER::init();
}

sub name     { '<SCALAR>' }
sub operator { '${...}' }

sub verify {
    my $self   = shift;
    my %params = @_;
    my ($got, $exists) = @params{qw/got exists/};

    return 0 unless $exists;
    return 0 unless defined $got;
    return 0 unless ref($got);
    return 0 unless reftype($got) eq 'SCALAR';
    return 1;
}

sub deltas {
    my $self   = shift;
    my %params = @_;
    my ($got, $convert, $seen) = @params{qw/got convert seen/};

    my $item  = $self->{+ITEM};
    my $check = $convert->($item);

    return (
        $check->run(
            id      => ['SCALAR' => '$*'],
            got     => $$got,
            convert => $convert,
            seen    => $seen,
            exists  => 1,
        ),
    );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Compare::Scalar - Representation of a Scalar Ref in deep
comparisons

=head1 DESCRIPTION

This is used in deep comparisons to represent a scalar reference.

=head1 SYNOPSIS

    my $sr = Test2::Compare::Scalar->new(item => 'foo');

    is([\'foo'], $sr, "pass");
    is([\'bar'], $sr, "fail, different value");
    is(['foo'],  $sr, "fail, not a ref");

=cut
