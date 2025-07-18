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

print "Testing Bilaspur geocoding restrictions:\n\n";

# Test cases
my @test_cases = (
    { name => "Bilaspur (should work)", query => "Bilaspur" },
    { name => "Gandhi Chowk Bilaspur (should work)", query => "Gandhi Chowk Bilaspur" },
    { name => "Mumbai (should be blocked)", query => "Mumbai" },
    { name => "Delhi (should be blocked)", query => "Delhi" },
    { name => "Bilaspur coordinates (should work)", query => "22.0735,82.1599" },
    { name => "Outside bounds coordinates (should be blocked)", query => "19.0760,72.8777" }, # Mumbai coordinates
);

foreach my $test (@test_cases) {
    print "Testing: " . $test->{name} . "\n";
    print "Query: " . $test->{query} . "\n";
    
    my $result = FixMyStreet::Geocode::OSM->string($test->{query}, $c);
    
    if ($result->{error}) {
        print "Result: ERROR - " . $result->{error} . "\n";
    } elsif ($result->{latitude} && $result->{longitude}) {
        print "Result: SUCCESS - Lat: " . $result->{latitude} . ", Lon: " . $result->{longitude} . "\n";
        print "Address: " . ($result->{address} || "N/A") . "\n";
    } elsif (ref($result->{error}) eq 'ARRAY') {
        print "Result: MULTIPLE MATCHES - " . scalar(@{$result->{error}}) . " results\n";
        foreach my $match (@{$result->{error}}) {
            print "  - " . $match->{address} . " (Lat: " . $match->{latitude} . ", Lon: " . $match->{longitude} . ")\n";
        }
    } else {
        print "Result: NO MATCHES\n";
    }
    print "\n";
}

print "Geocoding URL used: " . ($c->stash->{geocoder_url} || "N/A") . "\n";

package MockContext;
sub get_param { return undef; }
sub stash { return $_[0]->{stash}; } 