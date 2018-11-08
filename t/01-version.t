use v6;
use Test;

plan 1;

use Tika;

my $version = Tika.new.version;
diag $version.perl;
ok $version ~~ Str, "Version string";
