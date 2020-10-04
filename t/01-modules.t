# -*- mode: perl6 -*-

use Test;

use Raku::Ecosystem;

my $eco = Raku::Ecosystem.new;

cmp-ok $eco.modules.keys.elems, ">", 967, "Number of modules OK";
cmp-ok $eco.dependency-lists.elems, ">", 0, "Number of depencencies OK";
cmp-ok $eco.river-scores<Test>, ">", 0, "River scores settled";
isa-ok $eco.modules, Hash,  "Modules hash";
isa-ok $eco.depended, Hash,  "Modules hash";
isa-ok $eco.depends-on, Hash,  "Modules hash";
isa-ok $eco.modules<6pm>, Hash, "Module hash";
isa-ok $eco.modules<6pm><RUNTIMEDEP>, Set, "Depends set";

done-testing;
