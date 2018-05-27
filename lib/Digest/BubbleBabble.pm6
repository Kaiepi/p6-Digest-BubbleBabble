use v6.c;
unit class Digest::BubbleBabble:ver<0.0.1>:auth<github:Kaiepi>;

constant VOWELS     = <a e i o u y>;
constant CONSONANTS = <b c d f g h k l m n p r s t v z x>;

method encode(Blob $digest --> Blob) {
    my $len    = $digest.elems;
    my $seed   = 1;
    my @result = ord 'x';

    for 0..^$len div 2 -> $i {
        my $byte1 = $digest[$i * 2];
        @result.push(ord VOWELS[((($byte1 +> 6) +& 3) + $seed) % 6]);
        @result.push(ord CONSONANTS[($byte1 +> 2) +& 15]);
        @result.push(ord VOWELS[(($byte1 +& 3) + $seed div 6) % 6]);

        my $byte2 = $digest[$i * 2 + 1];
        @result.push(ord CONSONANTS[($byte2 +> 4) +& 15]);
        @result.push(ord '-');
        @result.push(ord CONSONANTS[$byte2 +& 15]);

        $seed = (($seed * 5) + ($byte1 * 7) + $byte2) % 36;
    }

    if $len %% 2 {
        @result.push(ord VOWELS[$seed % 6]);
        @result.push(ord CONSONANTS[16]);
        @result.push(ord VOWELS[$seed div 6]);
    } else {
        my $byte3 = $digest[$len - 1];
        @result.push(ord VOWELS[((($byte3 +> 6) +& 3) + $seed) % 6]);
        @result.push(ord CONSONANTS[($byte3 +> 2) +& 15]);
        @result.push(ord VOWELS[(($byte3 +& 3) + $seed div 6) % 6]);
    }

    @result.push(ord 'x');

    Blob.new(@result);
}

method !decode-tuple(@tuple --> Array[Int]) {
    my Int @decoded = [
        VOWELS.first(@tuple[0], :k),
        CONSONANTS.first(@tuple[1], :k),
        VOWELS.first(@tuple[2], :k)
    ];

    if +@tuple > 3 {
        @decoded.push(CONSONANTS.first(@tuple[3], :k));
        @decoded.push(CONSONANTS.first(@tuple[5], :k));
    }

    @decoded;
};

method !decode-byte-double(Int $byte1, Int $byte2, Int $pos --> Int) {
    die "Invalid fingerprint at offset $pos"       if $byte1 > 16;
    die "Invalid fingerprint at offset {$pos + 2}" if $byte2 > 16;

    ($byte1 +< 4) +| $byte2;
}

method !decode-byte-triple(Int $byte1, Int $byte2, Int $byte3, Int $seed, Int $pos --> Int) {
    my $high = ($byte1 - ($seed % 6) + 6) % 6;
    die "Invalid fingerprint at offset $pos" if $high >= 4;
    my $mid = $byte2;
    die "Invalid fingerprint at offset {$pos + 1}" if $mid > 16;
    my $low = ($byte3 - ($seed div 6 % 6) + 6) % 6;
    die "Invalid fingerprint at offset {$pos + 2}" if $low >= 4;

    $high +< 6 +| $mid +< 2 +| $low;
}

method decode(Blob $fingerprint --> Blob) {
    die 'Invalid fingerprint: must start with x' if $fingerprint.head != ord 'x';
    die 'Invalid fingerprint: must end with x'   if $fingerprint.tail != ord 'x';
    die 'Invalid fingerprint: invalid length'    if +$fingerprint % 6 != 5;

    my @tuples = $fingerprint.contents[1..^*-1].rotor(6, :partial);
    my $seed   = 1;
    my @result;
    for 0..^+@tuples -> $i {
        my @tuple = self!decode-tuple(@tuples[$i]>>.chr);
        my $pos   = $i * 6;
        if $i == +@tuples - 1 {
            if @tuple[1] == 16 {
                die "Invalid fingerprint at offset $pos"       if @tuple[0] != $seed % 6;
                die "Invalid fingerprint at offset {$pos + 2}" if @tuple[2] != $seed div 6;
            } else {
                my $byte = self!decode-byte-triple(@tuple[0], @tuple[1], @tuple[2], $seed, $pos);
                @result.push($byte);
            }
        } else {
            my $byte1 = self!decode-byte-triple(@tuple[0], @tuple[1], @tuple[2], $seed, $pos);
            my $byte2 = self!decode-byte-double(@tuple[3], @tuple[4], $pos);
            @result.push($byte1, $byte2);
            $seed = ($seed * 5 + $byte1 * 7 + $byte2) % 36;
        }
    }

    Blob.new(@result);
}

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

  $digest = Digest::BubbleBabble.decode($fingerprint);
  say $digest.decode; # BubbleBabble is useful!

=head1 DESCRIPTION

Digest::BubbleBabble is a way of encoding digests in such a way that it can be
more easily legible and memorable for humans. This is useful for cryptographic
purposes.

=head1 METHODS

=item B<Digest::BubbleBabble.encode>(Blob I<$digest> --> Blob)

Returns the given digest blob, encoded as a BubbleBabble fingerprint.

=item B<Digest::BubbleBabble.decode>(Blob I<$fingerprint> --> Blob)

Returns the decoded BubbleBabble fingerprint blob.

=head1 AUTHOR

Ben Davies (kaiepi)

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
