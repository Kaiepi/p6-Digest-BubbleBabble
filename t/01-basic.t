use v6.c;
use Test;
use Digest::BubbleBabble;

plan 2;

my %tests = (
    ''           => 'xexax',
    'Pineapple'  => 'xigak-nyryk-humil-bosek-sonax',
    '1234567890' => 'xesef-disof-gytuf-katof-movif-baxux'
);

subtest 'Encoding' => {
    plan +%tests * 2;
    for %tests.kv -> $digest, $fingerprint {
        my $result;
        lives-ok { $result = Digest::BubbleBabble.encode($digest.encode) }, "Encoding '$digest' fails";
        is $result.decode, $fingerprint, "Encoding '$digest' gives the wrong fingerprint";
    }
}

subtest 'Decoding' => {
    plan +%tests * 2;
    for %tests.kv -> $digest, $fingerprint {
        my $result;
        lives-ok { $result = Digest::BubbleBabble.decode($fingerprint.encode) }, "Decoding '$fingerprint' fails";
        is $result.decode, $digest, "Decoding '$fingerprint' gives the wrong digest";
    }
}
