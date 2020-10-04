#!/usr/bin/env perl6

use v6;

use Raku::Ecosystem;

my $eco = Raku::Ecosystem.new;

say "Distro, Score";
my @eco-distros = $eco.river-scores.keys.sort( { $eco.river-scores{$^þ} <=>  $eco.river-scores{$^ð} } );
my @nodes = @eco-distros.grep: { $eco.river-scores{$^þ} > 0 } ;
for @nodes -> $key {
    say $key, ", ", $eco.river-scores{$key};
}

