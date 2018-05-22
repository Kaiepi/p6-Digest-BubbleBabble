use v6.c;
use Test;
use Digest::BubbleBabble;

plan 1;

subtest 'Encodings' => {
	plan 3;
	my @encodings = ['', 'Pineapple', '1234567890'].map({ Blob.new($_.ords) });
	my @encoded   = ['xexax', 'xigak-nyryk-humil-bosek-sonax', 'xesef-disof-gytuf-katof-movif-baxux'];
	for @encodings Z @encoded -> $digest, $fingerprint {
		is Digest::BubbleBabble.encode($digest).decode, $fingerprint, "Encoding '{$digest.decode}' gives the wrong fingerprint!";
	}
}
