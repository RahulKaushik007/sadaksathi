#!/usr/bin/env perl

use warnings;
use strict;

BEGIN {
    use File::Basename qw(dirname);
    use File::Spec;
    my $d = dirname(File::Spec->rel2abs($0));
    require "$d/../setenv.pl";
}

use FixMyStreet;
use FixMyStreet::DB;

print "Creating test user account...\n";

# Create a test user directly in the database
my $user = FixMyStreet::DB->resultset('User')->create({
    email => 'test@example.com',
    name => 'Test User',
    email_verified => 1,  # Mark as verified so no email confirmation needed
    password => 'testpassword123',
});

if ($user) {
    print "✅ Test user created successfully!\n";
    print 'Email: test@example.com' . "\n";
    print "Password: testpassword123\n";
    print "User ID: " . $user->id . "\n";
    print "\nYou can now log in at: http://localhost:3000/auth\n";
} else {
    print "❌ Failed to create test user\n";
} 