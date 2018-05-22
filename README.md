[![Build Status](https://travis-ci.org/Kaiepi/p6-Digest-BubbleBabble.svg?branch=master)](https://travis-ci.org/Kaiepi/p6-Digest-BubbleBabble)

NAME
====

Digest::BubbleBabble - Support for BubbleBabble string encoding and decoding

SYNOPSIS
========

    use Digest::BubbleBabble;

    my $digest = ''.encode; # For the sake of simplicity, let's not use a real hash
    my $fingerprint = Digest::BubbleBabble.encode($digest);
    say $fingerprint.decode; # xexax

    # TODO: decoding support

DESCRIPTION
===========

Digest::BubbleBabble is a way of encoding digests in such a way that it can be more easily legible and memorable for humans. This is useful for cryptographic purposes.

METHODS
=======

  * **Digest::BubbleBabble.encode**(Blob *$digest* --> Blob)

Returns the given digest blob, encoded as a BubbleBabble fingerprint.

AUTHOR
======

Ben Davies <kaiepi@outlook.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

