#!/usr/bin/env perl6

use v6;

use JSON::Fast;
use Perl6::Ecosystem;

my $data-file = "data.json";

my %data = from-json $data-file.IO.slurp or fail "Problems reading file";


my %fails;
for %data.keys -> $module {
    %fails{$module} = %data{$module}<status> if %data{$module}<status> ne "OK";
}


my $eco = Perl6::Ecosystem.new;

say "Distro, Score, Fail";
my @eco-distros = $eco.river-scores.keys.sort( { $eco.river-scores{$^þ} <=>  $eco.river-scores{$^ð} } );
my @nodes = @eco-distros.grep: { $eco.river-scores{$^þ} > 0 } ;
for @nodes -> $key {
    say $key, ", ", $eco.river-scores{$key}, ", ", %fails{$key} // "";
}

