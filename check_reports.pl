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

print "Checking reports in database...\n";

# Get all problems
my $problems = FixMyStreet::DB->resultset('Problem')->search({});

print "Total problems: " . $problems->count . "\n";

if ($problems->count > 0) {
    print "\nRecent problems:\n";
    print "-" x 80 . "\n";
    
    my $recent = $problems->search({}, {
        order_by => { -desc => 'id' },
        rows => 10
    });
    
    while (my $p = $recent->next) {
        print "ID: " . $p->id . "\n";
        print "Title: " . $p->title . "\n";
        print "State: " . $p->state . "\n";
        print "Category: " . $p->category . "\n";
        print "Bodies: " . ($p->bodies_str || 'None') . "\n";
        print "Created: " . $p->created . "\n";
        print "User: " . ($p->user ? $p->user->email : 'None') . "\n";
        print "-" x 40 . "\n";
    }
} else {
    print "No problems found in database.\n";
}

# Check if there are any bodies configured
my $bodies = FixMyStreet::DB->resultset('Body')->search({});
print "\nTotal bodies: " . $bodies->count . "\n";

if ($bodies->count > 0) {
    print "\nBodies:\n";
    while (my $b = $bodies->next) {
        print "- " . $b->name . " (ID: " . $b->id . ")\n";
    }
} 