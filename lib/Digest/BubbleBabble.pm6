use v6.c;
unit class Digest::BubbleBabble:ver<0.0.1>:auth<github:Kaiepi>;

constant VOWELS = <a e i o u y>;
constant CONSONANTS = <b c d f g h k l m n p r s t v z x>;

method encode(Blob $digest --> Blob) {
    my $len = $digest.elems;
    my $seed = 1;
    my @result = 'x';

    for 0...^$len div 2 -> $i {
        my $byte1 = $digest[$i * 2];
        @result.push(
            VOWELS[((($byte1 +> 6) +& 3) + $seed) % 6],
            CONSONANTS[($byte1 +> 2) +& 15],
            VOWELS[(($byte1 +& 3) + $seed div 6) % 6]
        );

        my $byte2 = $digest[$i * 2 + 1];
        @result.push(
            CONSONANTS[($byte2 +> 4) +& 15],
            '-',
            CONSONANTS[$byte2 +& 15]
        );

        $seed = (($seed * 5) + ($byte1 * 7) + $byte2) % 36;
    }

    if $len %% 2 {
        @result.push(
            VOWELS[$seed % 6],
            CONSONANTS[16],
            VOWELS[$seed div 6]
        );
    } else {
        my $byte3 = $digest[$len - 1];
        @result.push(
            VOWELS[((($byte3 +> 6) +& 3) + $seed) % 6],
            CONSONANTS[($byte3 +> 2) +& 15],
            VOWELS[(($byte3 +& 3) + $seed div 6) % 6]
        );
    }

    @result.push('x');

    Blob.new(@result.map: *.ord);
}

# TODO: decoding support
method decode(Blob $fingerprint --> Blob) { ... }

=begin pod

=head1 NAME

Digest::BubbleBabble - Support for BubbleBabble string encoding and decoding

=head1 SYNOPSIS

  use Digest::BubbleBabble;
  use Digest::MD5;

  my $blob = Blob.new(ords 'BubbleBabble is useful!');
  my $digest = Digest::MD5::md5($blob);
  my $fingerprint = Digest::BubbleBabble.encode($digest);
  say $fingerprint.decode; # xidez-kidoh-sucen-furyd-sodyz-gidem-doled-cezof-rexux

=head1 DESCRIPTION

Digest::BubbleBabble is a way of encoding digests in such a way that it can be
more easily legible and memorable for humans. This is useful for cryptographic
purposes.

=head1 METHODS

=item B<Digest::BubbleBabble.encode>(Blob I<$digest> --> Blob)

Returns the given digest blob, encoded as a BubbleBabble fingerprint.

=head1 AUTHOR

Ben Davies <kaiepi@outlook.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
