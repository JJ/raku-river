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

my $eco = Raku::Ecosystem.new;

say "Distro, Deps";
my @eco-distros = $eco.depended.keys.sort( { $eco.depended{$^þ} <=>  $eco.depended{$^ð} } );
my @nodes = @eco-distros.grep: { $eco.depended{$^þ}>= 1 and %fails{$^þ} };
my %inverse-mapping;
say "*Vertices ", @nodes.elems;
for @nodes.kv -> $idx, $val {
    my $n = $idx + 1;
    %inverse-mapping{$val} = $n;
    say "$n \"$val\" " ;
}

say "*arcs";
for @nodes -> $distro {
    for $eco.depends-on{$distro}.keys -> $deps {
        if %fails{$deps} {
          say "%inverse-mapping{$distro} %inverse-mapping{$deps} 1";
        }
    }
}
