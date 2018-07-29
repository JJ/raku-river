# -*- mode: perl6 -*-

use Test;

use Perl6::Ecosystem;

my $eco = Perl6::Ecosystem.new;

cmp-ok $eco.modules.keys.elems, ">", 1000, "Number of modules OK";
cmp-ok $eco.dependency-lists.elems, ">", 0, "Number of depencencies OK";
say $eco.dependency-lists;
isa-ok $eco.modules, Hash,  "Modules hash";
isa-ok $eco.depended, Hash,  "Modules hash";
isa-ok $eco.depends-on, Hash,  "Modules hash";
isa-ok $eco.modules<6pm>, Hash, "Module hash";
isa-ok $eco.modules<6pm><depends>, Set, "Depends set";

done-testing;
