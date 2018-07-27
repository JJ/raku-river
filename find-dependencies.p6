#!/usr/bin/env perl6

use v6;

use JSON::Fast;

sub MAIN( $dir = "../../forks/perl6/perl6-all-modules/" ) {
    my $names = ().SetHash;
    my $eco = ().SetHash;
    my %links;
    my %type;
    chdir($dir);
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
        $names ∪= $this-distro;
        $eco   ∪= $this-distro;
        for <build-depends depends test-depends> -> $key {
            for $data{$key}.values -> $distro {
                %links{$this-distro}{$distro}++;
                $names ∪= $distro;
            }
        }
    }

    my @nodes = $names.keys;
    my %inverse-mapping;
    say "*Vertices ", @nodes.elems;
    for @nodes.kv -> $idx, $val {
        my $n = $idx + 1;
        %inverse-mapping{$val} = $n;
        say "$n \"$val\" ", $eco{$val}??"Eco"!!"Core" ;
    }
    
    say "*arcs";
    for %links.kv -> $key, $links {
        for $links.kv -> $target, $value {
	    say "%inverse-mapping{$key} %inverse-mapping{$target} $value ";
        }
    }

}
