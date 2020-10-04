#!/usr/bin/env perl6

use v6;

use Raku::Ecosystem;


my $eco = Raku::Ecosystem.new;
my @eco = $eco.depends-on.keys.Array;
my @nodes = @eco.append( $eco.depended.keys.list )
        .unique.sort;
say @nodes;
my %inverse-mapping;
 say "*Vertices ", @nodes.elems;
 for @nodes.kv -> $idx, $val {
     my $n = $idx + 1;
     %inverse-mapping{$val} = $n;
     say "$n \"$val\" ", ($val ∈ @eco)??"Eco"!!"Core" ;
 }
    
 say "*arcs";
 for $eco.depends-on.kv -> $key, $links {
     for $links.kv -> $target, $value {
         say "%inverse-mapping{$key} %inverse-mapping{$target} $value ";
     }
 }


