package Test2::Tools::Warnings;
use strict;
use warnings;

our $VERSION = '0.000112';

use Test2::API qw/context/;

our @EXPORT = qw/warns warning warnings no_warnings/;
use base 'Exporter';

sub warns(&) {
    my $code = shift;
    my $warnings = 0;
    local $SIG{__WARN__} = sub { $warnings++ };
    $code->();
    return $warnings;
}

sub no_warnings(&) { return !&warns(@_) }

sub warning(&) {
    my $code = shift;
    my @warnings;
    {
        local $SIG{__WARN__} = sub { push @warnings => @_ };
        $code->();
        return unless @warnings;
    }

    if (@warnings > 1) {
        my $ctx = context();
        $ctx->alert("Extra warnings in warning { ... }");
        $ctx->note($_) for @warnings;
        $ctx->release;
    }

    return $warnings[0];
}

sub warnings(&) {
    my $code = shift;

    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings => @_ };
    $code->();

    return \@warnings;
}

1;


__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Tools::Warnings - Tools to verify warnings.

=head1 DESCRIPTION

This is a collection of tools that can be used to test code that issues
warnings.

=head1 SYNOPSIS

    use Test2::Tools::Warnings qw/warns warning warnings no_warnings/;

    ok(warns { warn 'a' }, "the code warns");
    ok(!warns { 1 }, "The code does not warn");
    is(warns { warn 'a'; warn 'b' }, 2, "got 2 warnings");

    ok(no_warnings { ... }, "code did not warn");

    like(
        warning { warn 'xxx' },
        qr/xxx/,
        "Got expected warning"
    );

    is(
        warnings { warn "a\n"; warn "b\n" },
        [
            "a\n",
            "b\n",
        ],
        "Got 2 specific warnings"
    );

=head1 EXPORTS

All subs are exported by default.

=over 4

=item $count = warns { ... }

Returns the count of warnings produced by the block. This will always return 0,
or a positive integer.

=item $warning = warning { ... }

Returns the first warning generated by the block. If the block produces more
than one warning, they will all be shown as notes, and an actual warning will tell
you about it.

=item $warnings_ref = warnings { ... }

Returns an arrayref with all the warnings produced by the block. This will
always return an array reference. If there are no warnings, this will return an
empty array reference.

=item $bool = no_warnings { ... }

Return true if the block has no warnings. Returns false if there are warnings.

=back

=head1 SOURCE

The source code repository for Test2-Suite can be found at
F<https://github.com/Test-More/Test2-Suite/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2017 Chad Granum E<lt>exodist@cpan.orgE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut
