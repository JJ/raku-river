# -*- mode: perl6 -*-

use Test;

use Perl6::Ecosystem;

my $eco = Perl6::Ecosystem.new;

cmp-ok $eco.modules.keys.elems, ">", 1000, "Number of modules OK";
isa-ok $eco.modules, Hash,  "Modules hash";
isa-ok $eco.modules<6pm>, Hash, "Module hash";
isa-ok $eco.modules<6pm><depends>, Set, "Depends set";
done-testing;
