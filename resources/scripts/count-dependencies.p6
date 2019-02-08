#!/usr/bin/env perl6

use v6;

use JSON::Fast;

my $data-file = "data.json";

my %data = from-json $data-file.IO.slurp or fail "Problems reading file";


my %fails;
for %data.keys -> $module {
    %fails{$module} = %data{$module}<status> if %data{$module}<status> ne "OK";
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
