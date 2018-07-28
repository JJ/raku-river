#!/usr/bin/env perl6

# run it like this:
#    /dep-to-dot.p6 > modules.dot && dot -T svg -o modules.svg modules.dot

# Ignore some modules to prevent ratsnests
my @ignore-modules = <
    Task::Galaxy
    Task::Noise
    Task::Popular
>;
# Show some deps multiple times to prevent ratsnests
my @ignore-deps    = <
   DBIish
   Digest
   File::Find
   File::Temp
   JSON::Fast
   JSON::Tiny
   LibraryMake
   NativeCall
   Test::META
   URI
   XML
>;

my @sources =
‘https://raw.githubusercontent.com/ugexe/Perl6-ecosystems/master/cpan.json’,
‘http://ecosystem-api.p6c.org/projects.json’,
;

my %modules;

for @sources {
    use JSON::Fast;
    my $json = from-json run(:out, <curl -->, $_).out.slurp-rest;

    for @$json {
        my $name = .<name>;
        %modules{$name}<     depends> ∪= ~$_ for @(.<     depends> // ());
        %modules{$name}<test-depends> ∪= ~$_ for @(.<test-depends> // ());
        with .<source-url> {
            %modules{$name}<href> = .subst: /^‘git://’/, ‘http://’; # quick hack
        }
    }
}

put ‘digraph modules {’;
put ‘    rankdir=RL;’;
put ‘    ranksep=8;’;
for %modules.keys.sort -> $module {
    next if $module eq @ignore-modules.any;
    with %modules{$module}<href> {
        put “    "$module" [href="$_"];”;
    } else {
        put “    "$module";”;
    }
    for (%modules{$module}<depends> // ()).keys.sort -> $dep {
        my $rand-color = sprintf “#%02s%02s%02s”, ((^220).pick xx 3)».base: 16;
        if $dep eq @ignore-deps.any {
            my $rand-name = "$dep" ~ (^9999999).pick;
            put “    "$rand-name" [label="$dep*"];”;
            put “    "$module" -> "$rand-name" [color="$rand-color"];”;
            next
        }
        put “    "$module" -> "$dep" [color="$rand-color"];”;
    }
    put ‘’;
}
put ‘}’;
