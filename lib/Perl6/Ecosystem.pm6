use v6.c;

use JSON::Fast;

unit class Perl6::Ecosystem:ver<0.0.2>;


has @!sources =
‘https://raw.githubusercontent.com/ugexe/Perl6-ecosystems/master/cpan.json’,
‘http://ecosystem-api.p6c.org/projects.json’,
;

has %.modules;
has %.depended;
has %.depends-on;
has @.dependency-lists; 
has %.river-scores;

method TWEAK {
    for @!sources -> $source {
        my $err = open :w, $*TMPDIR.add: 'perl6-eco-err.txt';
        my $json = from-json run(<curl -->, $source, :out, :err($err)).out.slurp-rest;

        for @$json {
            my $name = .<name>;
            next if $name ~~ /Foo\:\:Dependencies/;
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
                    %.depended{$_}++;
                    %.depends-on{$name}{$_} = True;
                    %.modules{$name}{$dep-type} ∪= ~$_;
                    %.modules{$name}<all-deps>  ∪= ~$_;
                }
            }

            for %.modules{$name}<all-deps>.keys -> $dep {
                push @.dependency-lists, [$name, $dep];
            }
            with .<source-url> {
                %.modules{$name}<href> = .subst: /^‘git://’/, ‘http://’; # quick hack
            }

        }
    }

    # Populate dependency list
    my $dependencies = %.depended.keys.elems; #Initializes with number of depended-upon modules
    my @temp-dep-list = @.dependency-lists;
    my $length = 2;
    while $dependencies > 0 {
        $dependencies = 0;
        my @generation-dep-list;
        for @temp-dep-list.grep: *.elems == $length -> @list {
            my $depended = @list[* - 1]; #last
            if $.depends-on{$depended}.keys.elems > 0 {
                my @this-list = @list;
                for $.depends-on{$depended}.keys -> $deps {
                    $dependencies++;
                    push @generation-dep-list: flat @list, $deps;
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
            %.river-scores{$value} += $idx;
        }
    }
    @.dependency-lists = @temp-dep-list;
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

=head2 method river-scores --> Hash

Computes the "river-score" by looking at all dependency chains and
giving a score according to the position. That is,
if there's this dependenci chain

   Foo → Bar → Baz

Foo will have a 0 score for appearing in the first position,
up to Baz which will have score equal to 2. The total score of every
module is computed by adding all scores.

=head1 SEE ALSO

L<Perl6 module ecosystem|https://modules.perl6.org>. 

=head1 AUTHOR

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
