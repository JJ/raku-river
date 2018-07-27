#!/usr/bin/env perl6

use v6;

use JSON::Fast;

sub MAIN( $dir = "../../forks/perl6/perl6-all-modules/" ) {
    my %dependencies;
    chdir($dir);
    my $eco = ().SetHash;
    my $ls-files = qx{git ls-files *.json};
    my @files = $ls-files.split(/\n/).grep: /META6/;
    for @files -> $file {
        my $content =  $file.IO.slurp;
        my $data = from-json $content;
        CATCH {
	    default {
	      say $file.IO.slurp;
	      say .backtrace;
	  }
        }
        my $this-distro = $data<name>;
        $eco   ∪= $this-distro;
        for <build-depends depends test-depends> -> $key {
            for $data{$key}.values -> $distro {
                %dependencies{$distro}++;
            }
        }
    }

    say "Distro, Deps";
    my @eco-distros = %dependencies.keys.sort( { %dependencies{$^þ} <=>  %dependencies{$^ð} } );
    for @eco-distros -> $distro {
        say "$distro, %dependencies{$distro}" if  %dependencies{$distro}> 1 and $eco{$distro};
    }
    
}
