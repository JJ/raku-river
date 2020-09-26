use Zef::Config;

unit class Raku::Ecosystem::Sources;

my @.sources;

submethod TWEAK {
    my %config = Zef::Config.parse-file( Zef::Config.guess-path );
    @!sources = %config<Repository>.grep( .<options><mirrors> ).map: .first;
}

