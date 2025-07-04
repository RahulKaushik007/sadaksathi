#!/usr/bin/env perl

use warnings;
use strict;

BEGIN {
    use File::Basename qw(dirname);
    use File::Spec;
    my $d = dirname(File::Spec->rel2abs($0));
    require "$d/setenv.pl";
}

use FixMyStreet;
use FixMyStreet::DB;

print "Testing reports filtering...\n";

# Check what states are available
my $visible_states = FixMyStreet::DB::Result::Problem->visible_states;
print "Visible states: " . join(", ", keys %$visible_states) . "\n";

# Check if unconfirmed is in visible states
if ($visible_states->{unconfirmed}) {
    print "✅ unconfirmed is in visible states\n";
} else {
    print "❌ unconfirmed is NOT in visible states\n";
}

# Check all states
my $all_states = FixMyStreet::DB::Result::Problem->all_states;
print "All states: " . join(", ", keys %$all_states) . "\n";

# Check hidden states
my $hidden_states = FixMyStreet::DB::Result::Problem->hidden_states;
print "Hidden states: " . join(", ", keys %$hidden_states) . "\n";

# Check if unconfirmed is in hidden states
if ($hidden_states->{unconfirmed}) {
    print "✅ unconfirmed is in hidden states\n";
} else {
    print "❌ unconfirmed is NOT in hidden states\n";
}

# Test the cobrand hook
my $cobrand = FixMyStreet::Cobrand::Bilaspur->new;
my @status = ('all');
print "Before hook: @status\n";
$cobrand->hook_report_filter_status(\@status);
print "After hook: @status\n";

print "\nDone!\n"; 