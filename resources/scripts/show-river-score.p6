#!/usr/bin/env perl6

use v6;

use JSON::Fast;
use DBIish;
use Perl6::Ecosystem;


# Maybe obtain data first from https://temp.perl6.party/toast.sqlite.db
my $dbh = DBIish.connect: 'SQLite', :database("data/toast.sqlite.db"), :RaiseError;
my $sth = $dbh.prepare('SELECT module FROM toast where rakudo == "2018.06" and status == "Fail" ');
$sth.execute();
my @rows = $sth.allrows();
my %fails;
for @rows -> $row {
    %fails{$row} = True;
}

my $eco = Perl6::Ecosystem.new;

say "Distro, Score, Fail";
my @eco-distros = $eco.river-scores.keys.sort( { $eco.river-scores{$^þ} <=>  $eco.river-scores{$^ð} } );
my @nodes = @eco-distros.grep: { $eco.river-scores{$^þ} > 0 } ;
for @nodes -> $key {
    say $key, ", ", $eco.river-scores{$key}, ", ", %fails{$key} // "";
}

