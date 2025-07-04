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
        span   => '0.25,0.3',
        bounds => [ 21.9500, 82.0000, 22.2000, 82.3000 ],
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
    
    # Check if coordinates are within Bilaspur bounds
    if (defined $lat && defined $lon && 
        $lat >= 21.9500 && $lat <= 22.2000 && 
        $lon >= 82.0000 && $lon <= 82.3000) {
        
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
    # Return empty array to avoid default area types, but we'll handle areas manually
    return [];
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

1; 