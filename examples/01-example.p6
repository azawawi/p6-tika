#!/usr/bin/env perl6

use v6;

use lib 'lib';
my $t = Tika.new;
# $t.start;

# Handle Ctrl-C
# signal(SIGINT).tap: {
# 	$t.stop if $t.defined;
# 	exit;
# }

#TODO find if server is up or not...
# sleep 2;

say "Found {$t.version} server";
#say $t.detectors;
my @files = 'data/demo.docx', 'data/a.docx';
for @files -> $filename {
  my $content-type = $t.mime-type($filename);
  say "Detected stream type $content-type";

	my $metadata = $t.meta($filename, $content-type);
	say "Metadata for $filename:\n{$t._truncate($metadata, 40)}";

  my $text = $t.text($filename, $content-type);
  say "Found {$text.chars} plain text";

  my $language = $t.language($text);
  say "Detected language #{$language}";
}

# sleep 15;
LEAVE {
	# $t.stop if $t.defined;
}
