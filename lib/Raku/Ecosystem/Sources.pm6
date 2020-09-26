use Zef::Config;

unit class Raku::Ecosystem::Sources;

has @.sources;

submethod TWEAK {
    my %config = Zef::Config::parse-file( Zef::Config::guess-path );
    @!sources = %config<Repository>.grep( { $_.<options><mirrors> } )
            .map: *<options><mirrors>.first;
}

