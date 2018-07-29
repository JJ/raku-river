use v6.c;

use JSON::Fast;

unit class Perl6::Ecosystem:ver<0.0.1>;


has @!sources =
‘https://raw.githubusercontent.com/ugexe/Perl6-ecosystems/master/cpan.json’,
‘http://ecosystem-api.p6c.org/projects.json’,
;

has %.modules;
has %.depended;
has %.depends-on;
has @.dependency-lists; 

method TWEAK {
    for @!sources -> $source {
        my $err = open :w, '/tmp/perl6-eco-err.txt';
        my $json = from-json run(<curl -->, $source, :out, :err($err)).out.slurp-rest;

        for @$json {
            my $name = .<name>;
            for <depends test-depends build-depends> -> $dep-type {
                %.depended{$_}++ for @(.{$dep-type} // ());
                %.depends-on{$name}{$_} = True for @(.{$dep-type} // ());
                %.modules{$name}{$dep-type} ∪= ~$_ for @(.{$dep-type} // ());
                %.modules{$name}<all-deps>  ∪= ~$_ for @(.{$dep-type} // ());
            }

            for %.modules{$name}<all-deps> -> $dep {
                push @.dependency-lists, [$name, $dep];
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
    say $eco.depended;
    say $eco.depends-on;

=head1 DESCRIPTION


=head1 METHODS

=head2 method new( )

Creates the object, downloading and filling it with information. Error output goes to C</tmp/perl6-eco-err.txt>

=head2 method modules

Returns a C<hash> with module names, dependencies and URLs.

=head2 method depended

Returns a C<hash> with module names and the number of other modules it depends on.

=head2 method depends-on

Returns a C<hash> with module names and its dependencies.

=head1 SEE ALSO

L<Perl6 module ecosystem|https://modules.perl6.org>. 

=head1 AUTHOR

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
