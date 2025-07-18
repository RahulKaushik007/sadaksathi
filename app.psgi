use strict;
use warnings;

use FixMyStreet::App;
use Plack::Builder;
use Catalyst::Utils;

my $app = FixMyStreet::App->apply_default_middlewares(FixMyStreet::App->psgi_app);

builder {
    $app;
};
