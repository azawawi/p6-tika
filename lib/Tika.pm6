use v6;

#
# A simple Tika server wrapper that provides the following methods:
# - meta
# - text
# - version
#
unit class Tika;

use HTTP::UserAgent;
use HTTP::Request::Common;

has Str $.hostname = 'localhost';
has Int $.port     = 9998;
has Proc::Async $!tika-server-process;
has HTTP::UserAgent $!ua;

method BUILD {
	$!ua          = HTTP::UserAgent.new;
	$!ua.timeout  = 10;
}

method start {
	my $proc = Proc::Async.new('java', '-jar', 'tika-server-1.19.1.jar');

	$proc.stdout.tap(
		-> $v   { print "Output: $v" },
		quit => { say 'caught exception ' ~ .^name }
	);
	$proc.stderr.tap(
		-> $v { print "Error:  $v" }
	);

	say $proc;
	$!tika-server-process = $proc;

	say "Starting Tika Server...";
	my $promise = $proc.start;
	say "Started!";
	#TODO what to do with promise
}

method stop {
	say "Stopping Tika Server...";
	$!tika-server-process.kill if $!tika-server-process.defined;
	say "Stopped!";
}

method rmeta {
  # TODO: rmeta
  ...
}

method unpack {
  ...
}

method parsers {
	my $response = $!ua.get(self._url("parsers"));
	die $response.status-line unless $response.is-success;
	$response.content;
}

method detectors {
	my $response = $!ua.get(self._url("detectors"));
  die $response.status-line unless $response.is-success;
	$response.content;
}

method version {
	my $response = $!ua.get(self._url("version"));
  die $response.status-line unless $response.is-success;
	my $version = $response.content;
}

method meta(Str $filename, $content-type = Nil) {
#TODO content_type ||= MIME::Types.type_for(filename).first.content_type
	my $request = PUT(
		self._url('meta'),
		:content($filename.IO.slurp(:bin)),
		:Content-Type($content-type)
	);
	my $response = $!ua.request($request);
	die $response.status-line unless $response.is-success;
	return $response.content;
}

method text(Str $filename, $content-type = Nil) {
# TODO content_type ||= MIME::Types.type_for(filename).first.content_type
	my $request = PUT(
		self._url('tika'),
		:content($filename.IO.slurp(:bin)),
		:Content-Type($content-type)
	);
	my $response = $!ua.request($request);
	die $response.status-line unless $response.is-success;
	return $response.content;
}

method mime-type(Str $filename) {
	my $request = PUT(
		self._url('detect/stream'),
		:content($filename.IO.slurp(:bin)),
		:Content-Disposition("attachment; filename=$filename")
	);
	my $response = $!ua.request($request);
	die $response.status-line unless $response.is-success;
	return $response.content;
}

method language(Str $string) {
	my $request = PUT(
		self._url('language/string'),
		:content($string)
	);
	my $response = $!ua.request($request);
	die $response.status-line unless $response.is-success;
	return $response.content;
}

method _url(Str $endpoint) {
  "http://$!hostname:$!port/$endpoint"
}

method _truncate(Str $string, Int $length) {
  if $string.chars <= $length {
    $string
  } else {
    $string.substr(0..$length - 3).trim ~ '...'
  }
}