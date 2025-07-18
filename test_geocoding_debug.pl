#!/usr/bin/perl

use strict;
use warnings;

# Add the perllib directory to the Perl path
use lib 'perllib';

use FixMyStreet;
use FixMyStreet::Geocode::OSM;
use FixMyStreet::Cobrand::Bilaspur;

# Initialize FixMyStreet
FixMyStreet->test_mode(1);

# Create a mock context
my $c = bless {}, 'MockContext';
$c->{stash} = {};

# Create Bilaspur cobrand
my $cobrand = FixMyStreet::Cobrand::Bilaspur->new;
$c->{cobrand} = $cobrand;

# Test the disambiguate_location method
print "Testing disambiguate_location method:\n";
my $params = $cobrand->disambiguate_location("Gandhi Chowk");
print "Params: " . Data::Dumper::Dumper($params);

# Test geocoding
print "\nTesting geocoding for 'Gandhi Chowk':\n";
my $result = FixMyStreet::Geocode::OSM->string("Gandhi Chowk", $c);
print "Result: " . Data::Dumper::Dumper($result);

# Print the URL that was generated
print "\nGenerated URL: " . $c->stash->{geocoder_url} . "\n";

package MockContext;
sub get_param { return undef; }
sub stash { return $_[0]->{stash}; } 