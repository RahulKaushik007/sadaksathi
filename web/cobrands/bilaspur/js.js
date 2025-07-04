// Bilaspur-specific JavaScript functionality

$(document).ready(function() {
    // Bilaspur city initialization
    console.log('Bilaspur FixMyStreet initialized');
    
    // Custom map center for Bilaspur (approximate coordinates)
    if (typeof OpenLayers !== 'undefined') {
        // Set default map center to Bilaspur city center
        var bilaspurCenter = new OpenLayers.LonLat(82.1599, 22.0735);
        
        // Override default map center if not already set
        if (typeof map !== 'undefined' && map.center) {
            map.setCenter(bilaspurCenter, 12);
        }
    }
    
    // Custom form validation for Indian phone numbers
    $('input[name="phone"]').on('blur', function() {
        var phone = $(this).val();
        var indianPhoneRegex = /^[6-9]\d{9}$/;
        
        if (phone && !indianPhoneRegex.test(phone)) {
            $(this).addClass('error');
            if (!$(this).next('.error-message').length) {
                $(this).after('<span class="error-message">Please enter a valid Indian mobile number</span>');
            }
        } else {
            $(this).removeClass('error');
            $(this).next('.error-message').remove();
        }
    });
    
    // Custom welcome message for Bilaspur
    if ($('.welcome-message').length === 0) {
        $('body').prepend('<div class="welcome-message" style="background: #4CAF50; color: white; padding: 10px; text-align: center;">Welcome to Bilaspur FixMyStreet - Report civic issues in your city!</div>');
    }
}); 