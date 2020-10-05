[![Build Status](https://travis-ci.org/JJ/raku-river.svg?branch=master)](https://travis-ci.org/JJ/raku-river)

NAME
====

Raku::Ecosystem - Obtains information from Raku modules in the ecosystem

SYNOPSIS
========

    use Raku::Ecosystem;
    my $eco = Raku::Ecosystem.new;

    say $eco.modules;
    say $eco.depended;
    say $eco.depends-on;

And probably, the most interesting one:

    say $eco.river-scores

These last give every distribution a score based on how far upstream
they are from other distributions. A distribution depending on other
will get a 1 score, for instance. A depends on B which depends on C
will get a score of two, and so on.

DESCRIPTION
===========

A tool to analyze the Raku ecosystem by downloading all modules and finding out
 how they depend on each other. Main objective is to find the chain of
 dependencies, but also find out the *core* distributions in the ecosystem.

METHODS
=======

method new( )
-------------

Creates the object, downloading and filling it with information. Error output
 goes to `/tmp/raku-eco-err.txt`

method modules
--------------

Returns a `hash` with module names, dependencies and URLs.

method depended
---------------

Returns a `hash` with module names and the number of other modules it depends on.

method depends-on
-----------------

Returns a `hash` with module names and its dependencies.

method river-scores --> Hash
----------------------------

Computes the "river-score" by looking at all dependency chains and giving a score according to the position. That is, if there's this dependency chain

    Foo ← Bar ← Baz

`Foo` will have a 0 score for appearing in the first position (which
is actually the module whose dependencies we're looking at), up to
`Baz` which will have score equal to 2. The total score of every module
is computed by adding up scores for every chain.

SEE ALSO
========

[Raku module ecosystem](https://modules.raku.org).

KNOWN BUGS
==========

It skips distributions if there's some error in META6.json. It also
uses verbatim dependency specifications that are understood by `zef`
but are somehow not standard, like Foo::Bar:ver(3).

AUTHOR
======

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018, 2020 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

