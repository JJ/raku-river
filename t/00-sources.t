use Test;

use Raku::Ecosystem::Sources;

ok( Raku::Ecosystem::Sources.new.sources, "Obtains sources" );

done-testing;
