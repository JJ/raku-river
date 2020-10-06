use v6.c;

use JSON::Fast;
use Dist::META;
use Zef::Identity;

use Raku::Ecosystem::Sources;
constant @reject-list = <Foo::Dependencies::A-on-B Foo::Dependencies::B-on-A
                        Foo::Dependencies::Self Test>;

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

        for @$json -> %meta6 {
            my $dist-meta;
            try {
                $dist-meta = Dist::META.new( json => to-json %meta6);
            }
            if $! {
                warn "There's some kind of error in %meta6<name>: $!";
                next;
            }
            # say "Processing %meta6<name> →", $dist-meta;
            my $name = %meta6<name>;
            next if $name ∈ @reject-list;
            next unless $dist-meta.dependencies;
            # say "Dependencies ", $dist-meta.dependencies;
            for $dist-meta.dependencies.unique -> $dep {
                next unless $dep ~~ Str;
                my $identity = Zef::Identity.new: $dep;
                my $dep-name;
                if $identity ~~ Zef::Identity {
                    $dep-name = $identity.name;
                } else {
                    warn "In $name dep is $dep and identity ", $identity.raku;
                    $dep-name = $dep;
                }
                next if $dep-name ∈ @reject-list;
#               say "$name depends on $dep-name";
                if $name eq $dep-name {
                    warn "Circular dependency $name\n", %meta6;
                    next;
                }
                %!depended{$dep-name}++;
                %!depends-on{$name}{$dep-name} = True;
                %!modules{$name}{$dep.DependencyType} ∪= $dep-name;
                %!modules{$name}<all-deps>  ∪= $dep-name;
            }

            for %!modules{$name}<all-deps>.keys -> $dep {
                push @!dependency-lists, [$name, $dep];
            }

        }
    }

    # Populate dependency list
    my $dependencies = %!depended.keys.elems; #Initializes with number of depended-upon modules
    my @temp-dep-list = @!dependency-lists;
    my $length = 2;
    while $dependencies > 0 {
        $dependencies = 0;
        my @generation-dep-list;
        my @with-length = @temp-dep-list.grep: *.elems == $length;
        say @with-length;
        for @with-length -> @list {
            my $depended = @list[* - 1]; # last
#            say "Depended $depended";
            if %!depends-on{$depended}.keys.elems > 0 {
#                say "Depends on ", %!depends-on{$depended};
                my @this-list = @list;
                for %!depends-on{$depended}.keys -> $deps {
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
