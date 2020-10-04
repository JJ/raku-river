use v6.c;

use JSON::Fast;
use Raku::Ecosystem::Sources;

unit class Raku::Ecosystem:ver<0.0.3>;

has %.modules;
has %.depended;
has %.depends-on;
has @.dependency-lists;
has %.river-scores;

submethod TWEAK {
    my @sources = Raku::Ecosystem::Sources.new.sources;
    for @sources -> $source {
        my $err = open :w, $*TMPDIR.add: 'raku-eco-err.txt';
        my $json = from-json run(<curl -->, $source, :out, :$err).out.slurp-rest;

        for @$json {
            my $name = .<name>;
            for <depends test-depends build-depends> -> $dep-type {
                my @these-deps = ();
                if $dep-type eq "depends" and .{$dep-type}.WHAT.^name eq "Hash" {
                    for <test runtime build> -> $subdep-type {
                        @these-deps.append(values(.{$dep-type}{$subdep-type})[*;*]);
                    }
                } else {
                    @these-deps = @(.{$dep-type} // ());
                }
                for @these-deps {
                    if $_.WHAT.^name ne "Str" { next };
                    %!depended{$_}++;
                    %!depends-on{$name}{$_} = True;
                    %!modules{$name}{$dep-type} ∪= ~$_;
                    %!modules{$name}<all-deps>  ∪= ~$_;
                }
            }

            for %!modules{$name}<all-deps>.keys -> $dep {
                push @!dependency-lists, [$name, $dep];
            }
            with .<source-url> {
                %!modules{$name}<href> = .subst: /^‘git://’/, ‘http://’; # quick hack
            }

        }
    }

    # Track infinite recursion for modules with incorrect deps
    my %seen-deps;

    # Populate dependency list
    my $dependencies = %!depended.keys.elems; #Initializes with number of depended-upon modules
    my @temp-dep-list = @!dependency-lists;
    my $length = 2;
    while $dependencies > 0 {
        $dependencies = 0;
        my @generation-dep-list;
        for @temp-dep-list.grep: *.elems == $length -> @list {
            my $depended = @list[* - 1]; #last
            if %!depends-on{$depended}.keys.elems > 0 {
                my @this-list = @list;
                for %!depends-on{$depended}.keys -> $deps {
                    without %seen-deps{$deps} {
                        %seen-deps{$deps} = True;
                        $dependencies++;
                        push @generation-dep-list: flat @list, $deps;
                    }
                }
            } else {
                push @generation-dep-list: @list;
            }
        }
        for @generation-dep-list -> $seqs {
            @temp-dep-list.push: $seqs.Array;
        }
        $length++;
    }

    for @temp-dep-list -> @list {
        for @list.kv -> $idx, $value {
            %!river-scores{$value} += $idx;
        }
    }
    @!dependency-lists = @temp-dep-list;
}

=begin pod

=head1 NAME

Raku::Ecosystem - Obtains information from Raku modules in the ecosystem

=head1 SYNOPSIS

    use Raku::Ecosystem;
    my $eco = Raku::Ecosystem.new;

    say $eco.modules;
    say $eco.depended;
    say $eco.depends-on;

=head1 DESCRIPTION

A tool to analyze the Raku ecosystem by downloading all modules and finding out
how they depend on each other.

=head1 METHODS

=head2 method new( )

Creates the object, downloading and filling it with information. Error output goes to C</tmp/perl6-eco-err.txt>

=head2 method modules

Returns a C<hash> with module names, dependencies and URLs.

=head2 method depended

Returns a C<hash> with module names and the number of other modules it depends on.

=head2 method depends-on

Returns a C<hash> with module names and its dependencies.

=head2 method river-scores --> Hash

Computes the "river-score" by looking at all dependency chains and
giving a score according to the position. That is,
if there's this dependency chain

   Foo → Bar → Baz

Foo will have a 0 score for appearing in the first position,
up to Baz which will have score equal to 2. The total score of every
module is computed by adding all scores.

=head1 SEE ALSO

L<Perl6 module ecosystem|https://modules.raku.org>.

=head1 KNOWN BUGS

It chokes on circular references. Right now they are blacklisted.

=head1 AUTHOR

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018,2019,2020 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
