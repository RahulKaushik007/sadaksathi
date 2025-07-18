package FixMyStreet::Cobrand::Bilaspur;
use parent 'FixMyStreet::Cobrand::Default';

use strict;
use warnings;

use Moo;

=head1 NAME

FixMyStreet::Cobrand::Bilaspur - code specific to the Bilaspur cobrand

=head1 SYNOPSIS

Bilaspur is a municipal corporation in Chhattisgarh, India.

=head1 DESCRIPTION

=cut

sub country {
    return 'IN';
}

sub languages { [ 'en-gb,English,en_GB', 'hi-in,Hindi,hi_IN' ] }
sub language_override { 'hi' }

sub enter_postcode_text {
    my ( $self ) = @_;
    return _('Enter a Bilaspur postcode, or street name and area');
}

sub disambiguate_location {
    my $self    = shift;
    my $string  = shift;

    return {
        %{ $self->SUPER::disambiguate_location() },
        centre => '22.0735,82.1599',
        span   => '0.4,0.5',
        bounds => [ 20.6000, 76.9000, 22.2500, 82.4000 ],
        town => 'Bilaspur',
        country => 'IN',
        result_strip => ', Bilaspur, Chhattisgarh, India',
    };
}

sub area_check {
    my ( $self, $params, $context ) = @_;
    
    # Get coordinates from the context (catalyst stash)
    my $lat = $self->{c}->stash->{latitude};
    my $lon = $self->{c}->stash->{longitude};
    
    # Check if coordinates are within Bilaspur bounds (expanded)
    if (defined $lat && defined $lon && 
        $lat >= 20.6000 && $lat <= 22.2500 && 
        $lon >= 76.9000 && $lon <= 82.4000) {
        
        # If no areas found in params, add Bilaspur area
        if ($params->{all_areas} && !%{$params->{all_areas}}) {
            my $bilaspur_area = $self->council_area_hashref;
            $params->{all_areas}->{$bilaspur_area->{id}} = $bilaspur_area;
        }
        
        return ( 1, '' );
    }
    
    return ( 0, _('That location is not covered by Bilaspur Municipal Corporation.') );
}

sub area_types {
    my $self = shift;
    # Return the area types we want to look up
    return [ 'local-authority-district' ];
}

# Override to ensure Bilaspur area is always included
sub add_extra_area_types {
    my ($self, $area_types) = @_;
    # Add our custom area type
    push @$area_types, 'local-authority-district';
    return $area_types;
}

# Hook to ensure Bilaspur area is always included when no MapIt areas are found
sub call_hook {
    my ($self, $hook, @args) = @_;
    
    if ($hook eq 'munge_all_areas') {
        my $all_areas = $args[0];
        
        # If no areas found, add Bilaspur area
        if (!%$all_areas) {
            my $bilaspur_area = $self->council_area_hashref;
            $all_areas->{$bilaspur_area->{id}} = $bilaspur_area;
        }
        
        return $all_areas;
    }
    
    # Call parent method for other hooks
    return $self->SUPER::call_hook($hook, @args);
}

# Filter geocoding results to only include Bilaspur locations
sub geocoder_munge_results {
    my ($self, $result) = @_;
    
    # Check if the result is within Bilaspur bounds
    my $lat = $result->{lat};
    my $lon = $result->{lon};
    
    if (defined $lat && defined $lon) {
        # Check if coordinates are within Bilaspur bounds (expanded)
        if ($lat < 20.6000 || $lat > 22.2500 || $lon < 76.9000 || $lon > 82.4000) {
            # Mark this result as invalid by clearing display_name
            $result->{display_name} = '';
            return;
        }
    }
    
    # Additional check: ensure the result contains "Bilaspur" in the display name
    # But be more lenient - allow results that are clearly in the Bilaspur area
    my $display_name = $result->{display_name} || '';
    
    # If the result doesn't contain "Bilaspur", check if it's within our bounds
    # and has coordinates that suggest it's in the Bilaspur area
    unless ($display_name =~ /Bilaspur/i || 
            ($lat && $lon && $lat >= 20.6000 && $lat <= 22.2500 && $lon >= 76.9000 && $lon <= 82.4000)) {
        # Mark this result as invalid
        $result->{display_name} = '';
        return;
    }
}

# Override geocoding to ensure only Bilaspur results
sub geocoder_munge_query_params {
    my ($self, $params) = @_;
    
    # Add Bilaspur to the search query if not already present
    my $q = $params->{q} || '';
    unless ($q =~ /Bilaspur/i) {
        $params->{q} = $q . ', Bilaspur, Chhattisgarh, India';
    }
    
    # Ensure bounded search is enabled
    $params->{bounded} = 1;
}

# Override to provide Bilaspur-specific error messages
sub geocoding_error_message {
    my ($self, $error) = @_;
    
    # If the error is about not finding the location, provide a Bilaspur-specific message
    if ($error =~ /could not find that location/i) {
        return _('Sorry, we could not find that location in Bilaspur. Please try searching for a location within Bilaspur city limits.');
    }
    
    return $error;
}

# Hook to modify filter states to include unconfirmed reports
sub hook_report_filter_status {
    my ($self, $status) = @_;
    # If 'all' is in the status, ensure unconfirmed is also included
    if (grep { $_ eq 'all' } @$status) {
        push @$status, 'unconfirmed' unless grep { $_ eq 'unconfirmed' } @$status;
    }
}

# Override to handle case where no MapIt areas are found
sub remove_redundant_areas {
    my ($self, $all_areas) = @_;
    
    # If no areas found, add Bilaspur area
    if (!%$all_areas) {
        my $bilaspur_area = $self->council_area_hashref;
        $all_areas->{$bilaspur_area->{id}} = $bilaspur_area;
    }
    
    return $all_areas;
}

# Always return a hashref for the council area
sub council_area_hashref {
    return {
        id    => 999999,
        name  => 'Bilaspur Municipal Corporation',
        type  => 'local-authority-district',
        codes => { gss => 'E999999' },
    };
}

# If you have a council_area method, make sure it returns the hashref too
sub council_area {
    my $self = shift;
    return $self->council_area_hashref;
}

sub council_name { return 'Bilaspur Municipal Corporation'; }
sub council_url { return 'bilaspur'; }

sub responsible_for_areas {
    my ($self, $councils) = @_;
    
    # For Bilaspur, we want to be responsible for any area that's within our bounds
    # Since we're using a custom area system, we'll return true for any area
    # that matches our council area hashref
    my $bilaspur_area = $self->council_area_hashref;
    
    # Check if any of the councils match our area
    foreach my $area_id (keys %$councils) {
        my $area = $councils->{$area_id};
        if ($area && $area->{name} && $area->{name} eq $bilaspur_area->{name}) {
            return 1;
        }
    }
    
    # If no exact match, check coordinates if available
    my $lat = $self->{c}->stash->{latitude};
    my $lon = $self->{c}->stash->{longitude};
    
    if (defined $lat && defined $lon && 
        $lat >= 21.9500 && $lat <= 22.2000 && 
        $lon >= 82.0000 && $lon <= 82.3000) {
        return 1;
    }
    
    return 0;
}

sub munge_report_new_bodies {
    my ($self, $bodies) = @_;
    
    # Always include Bilaspur Municipal Corporation
    my $bilaspur_body = FixMyStreet::DB->resultset('Body')->find({
        name => 'Bilaspur Municipal Corporation'
    });
    
    if ($bilaspur_body) {
        $bodies->{$bilaspur_body->id} = $bilaspur_body;
        
        # Update contact emails based on category
        my $c = $self->{c};
        my $category = $c->get_param('category') || $c->stash->{category};
        
        if ($category) {
            my $contact = FixMyStreet::DB->resultset('Contact')->find({
                body_id => $bilaspur_body->id,
                category => $category,
            });
            
            if ($contact) {
                # Set appropriate email based on category
                my $email;
                if ($category eq 'Water Supply') {
                    $email = 'ee-phebilaspur.cg@nic.in';  # PHE Department
                } elsif ($category eq 'Traffic Signals') {
                    $email = 'sp-bilaspur.cg@nic.in';     # Traffic Police
                } else {
                    # General civic issues - Municipal Corporation
                    $email = 'nigam.bilaspur.cg@nic.in';
                }
                
                $contact->email($email);
                $contact->update;
            }
        }
    }
}

sub default_map_zoom { 12 }

sub send_questionnaires { 0 }

sub ask_ever_reported { 0 }

# Ensure all reports are shown by default
sub on_map_default_status { 'all' }

# Show unconfirmed reports in Bilaspur
sub show_unconfirmed_reports { 1 }

# Override visible states to include unconfirmed reports
sub visible_states {
    my $self = shift;
    my $states = FixMyStreet::DB::Result::Problem->visible_states;
    # Add unconfirmed to visible states
    $states->{unconfirmed} = 1;
    return $states;
}

# Defensive override for short_name to handle string area IDs
sub short_name {
    my ($self, $area) = @_;
    # If $area is a string, convert to hashref
    if (!ref $area) {
        return 'Bilaspur Municipal Corporation';
    }
    my $name = $area->{name} || $area->name;
    return $name || 'Bilaspur Municipal Corporation';
}

# --- ADMIN MENU SUPPORT ---

# Allow admin access for a specific user (by email)
sub admin_allow_user {
    my ( $self, $user ) = @_;
    return 1 if $user && $user->email && $user->email eq 'yashwantsingh@gmail.com';
    return 1 if $user && $user->is_superuser; # fallback for superusers
    return;
}

# Define admin menu/pages for Bilaspur
sub admin_pages {
    my $self = shift;
    my $user = $self->{c}->user;
    my $pages = {
        'summary' => [_('Summary'), 0],
        'reports'  => [_('Reports'), 2],
        'users'    => [_('Users'), 5],
        'bodies'   => [_('Bodies'), 1],
    };
    return $pages;
}

1; 