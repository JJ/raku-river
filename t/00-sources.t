use Test;

use Raku::Ecosystem::Sources;

my @sources = Raku::Ecosystem::Sources.new.sources;
ok( @sources, "Obtains sources" );
cmp-ok( @sources.elems, ">", 1, "There's more than one source");
done-testing;
