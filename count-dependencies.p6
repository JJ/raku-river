#!/usr/bin/env perl6

use v6;

use JSON::Fast;
use DBIish;

sub MAIN( $dir = "../../forks/perl6/perl6-all-modules/" ) {
    my $dbh = DBIish.connect: 'SQLite', :database("toast.sqlite.db"), :RaiseError;
    my $sth = $dbh.prepare('SELECT module FROM toast where rakudo == "2018.06" and status != "Succ" ');
    $sth.execute();
    my @rows = $sth.allrows();
    my %fails;
    for @rows -> $row {
        %fails{$row} = True;
    }
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
        say "$distro, %dependencies{$distro}" if  %dependencies{$distro}>= 1 and %fails{$distro};
    }
    
}
