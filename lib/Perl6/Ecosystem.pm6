use v6.c;

use JSON::Fast;

unit class Perl6::Ecosystem:ver<0.0.1>;


has @!sources =
‘https://raw.githubusercontent.com/ugexe/Perl6-ecosystems/master/cpan.json’,
‘http://ecosystem-api.p6c.org/projects.json’,
;

has %.modules;

method TWEAK {
    for @!sources -> $source {
        my $err = open :w, '/tmp/perl6-eco-err.txt';
        my $json = from-json run(<curl -->, $source, :out, :err($err)).out.slurp-rest;

        for @$json {
            my $name = .<name>;
            for <depends test-depends build-depends> -> $dep-type {
                %.modules{$name}{$dep-type} ∪= ~$_ for @(.{$dep-type} // ());
            }
            
            with .<source-url> {
                %.modules{$name}<href> = .subst: /^‘git://’/, ‘http://’; # quick hack
            }
        }
    }
}

=begin pod

=head1 NAME

Perl6::Ecosystem - Obtains information from Perl6 modules in the ecosystem

=head1 SYNOPSIS

    use Perl::Ecosystem;
    my $eco = Perl6::Ecosystem.new;

    say $eco.modules;

=head1 DESCRIPTION


=head1 METHODS

=head2 method new( )

Creates the object, downloading and filling it with information. Error output goes to C</tmp/perl6-eco-err.txt>

=head2 method modules

Returns a C<hash> with module names, dependencies and URLs.

=head1 SEE ALSO

L<Perl6 module ecosystem|https://modules.perl6.org>. 

=head1 AUTHOR

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
