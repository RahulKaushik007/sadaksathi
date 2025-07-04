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

print "Content-Type: text/html\n\n";
print "<!DOCTYPE html>\n";
print "<html>\n";
print "<head>\n";
print "<title>All Reports - Bilaspur</title>\n";
print "<style>\n";
print "body { font-family: Arial, sans-serif; margin: 20px; }\n";
print ".report { border: 1px solid #ccc; margin: 10px 0; padding: 15px; border-radius: 5px; }\n";
print ".report h3 { margin: 0 0 10px 0; color: #333; }\n";
print ".report-meta { color: #666; font-size: 14px; }\n";
print ".report-status { font-weight: bold; }\n";
print ".status-confirmed { color: green; }\n";
print ".status-unconfirmed { color: orange; }\n";
print ".status-open { color: blue; }\n";
print ".status-fixed { color: green; }\n";
print ".status-closed { color: red; }\n";
print "</style>\n";
print "</head>\n";
print "<body>\n";
print "<h1>All Reports - Bilaspur Municipal Corporation</h1>\n";

# Get all problems from database
my $problems = FixMyStreet::DB->resultset('Problem')->search({}, {
    order_by => { -desc => 'id' }
});

my $count = $problems->count;
print "<p><strong>Total Reports: $count</strong></p>\n";

if ($count == 0) {
    print "<p>No reports found in the database.</p>\n";
} else {
    while (my $problem = $problems->next) {
        my $status_class = "status-" . $problem->state;
        print "<div class='report'>\n";
        print "<h3><a href='/report/" . $problem->id . "'>" . $problem->title . "</a></h3>\n";
        print "<div class='report-meta'>\n";
        print "<strong>Category:</strong> " . ($problem->category || 'N/A') . "<br>\n";
        print "<strong>Area:</strong> " . ($problem->bodies_str || 'Bilaspur Municipal Corporation') . "<br>\n";
        print "<strong>Date:</strong> " . $problem->created->strftime('%d/%m/%Y %H:%M') . "<br>\n";
        print "<strong>Status:</strong> <span class='report-status $status_class'>" . $problem->state . "</span><br>\n";
        print "<strong>Location:</strong> " . $problem->latitude . ", " . $problem->longitude . "<br>\n";
        if ($problem->user) {
            print "<strong>Reported by:</strong> " . $problem->user->name . " (" . $problem->user->email . ")<br>\n";
        }
        print "</div>\n";
        print "</div>\n";
    }
}

print "</body>\n";
print "</html>\n"; 