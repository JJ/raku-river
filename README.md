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

DESCRIPTION
===========

A tool to analyze the Perl 6 ecosystem by downloading all modules and finding out how they depend on each other.

METHODS
=======

method new( )
-------------

Creates the object, downloading and filling it with information. Error output goes to `/tmp/perl6-eco-err.txt`

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

    Foo → Bar → Baz

Foo will have a 0 score for appearing in the first position, up to Baz which will have score equal to 2. The total score of every module is computed by adding all scores.

SEE ALSO
========

[Raku module ecosystem](https://modules.raku.org).

KNOWN BUGS
==========

It chokes on circular references. Right now they are blacklisted.

AUTHOR
======

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

