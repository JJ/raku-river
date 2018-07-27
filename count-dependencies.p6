#!/usr/bin/env perl6

use v6;

use JSON::Fast;
use DBIish;



my $dbh = DBIish.connect: 'SQLite', :database("toast.sqlite.db"), :RaiseError;
my $sth = $dbh.prepare('SELECT module FROM toast where rakudo == "2018.06" and ( status == "Fail" or status == "Kill" ) ');
$sth.execute();
my @rows = $sth.allrows();
my %fails;
for @rows -> $row {
    %fails{$row} = True;
}
my %dependencies;

my @sources =
‘https://raw.githubusercontent.com/ugexe/Perl6-ecosystems/master/cpan.json’,
‘http://ecosystem-api.p6c.org/projects.json’,
;

my %modules;
for @sources {
    my $json = from-json run(:out, <curl -->, $_).out.slurp-rest;
    CATCH {
	default {
	    say $_;
	    say .backtrace;
	}
    }
    for @$json -> $data {
        my $this-distro = $data<name>;
        for <build-depends depends test-depends> -> $key {
            for $data{$key}.values -> $distro {
                %dependencies{$distro}++;
            }
        }
    }
}

say "Distro, Deps";
my @eco-distros = %dependencies.keys.sort( { %dependencies{$^þ} <=>  %dependencies{$^ð} } );
for @eco-distros -> $distro {
    say "$distro, %dependencies{$distro}" if  %dependencies{$distro}>= 1 and %fails{$distro};
}
