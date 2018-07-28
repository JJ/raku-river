#!/usr/bin/env perl6

use v6;

use JSON::Fast;
use DBIish;
use Perl6::Ecosystem;


my $dbh = DBIish.connect: 'SQLite', :database("data/toast.sqlite.db"), :RaiseError;
my $sth = $dbh.prepare('SELECT module FROM toast where rakudo == "2018.06" and status == "Fail" ');
$sth.execute();
my @rows = $sth.allrows();
my %fails;
for @rows -> $row {
    %fails{$row} = True;
}

my $eco = Perl6::Ecosystem.new;

say "Distro, Deps";
my @eco-distros = $eco.depended.keys.sort( { $eco.depended{$^þ} <=>  $eco.depended{$^ð} } );
for @eco-distros -> $distro {
    if  $eco.depended{$distro}>= 1 and %fails{$distro} {
say "$distro, ", $eco.depended{$distro}
}
}
