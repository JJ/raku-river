[![Build Status](https://travis-ci.org/JJ/p6-river.svg?branch=master)](https://travis-ci.org/JJ/p6-river)

NAME
====

Perl6::Ecosystem - Obtains information from Perl6 modules in the ecosystem

SYNOPSIS
========

    use Perl::Ecosystem;
    my $eco = Perl6::Ecosystem.new;

    say $eco.modules;
    say $eco.depended;
    say $eco.depends-on;

DESCRIPTION
===========

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

Computes the "river-score" by looking at all dependency chains and giving a score according to the position. That is, if there's this dependenci chain

    Foo → Bar → Baz

Foo will have a 0 score for appearing in the first position, up to Baz which will have score equal to 2. The total score of every module is computed by adding all scores.

SEE ALSO
========

[Perl6 module ecosystem](https://modules.perl6.org). 

AUTHOR
======

Alex Daniel, JJ Merelo <jjmerelo@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Alex Daniel, JJ Merelo

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

