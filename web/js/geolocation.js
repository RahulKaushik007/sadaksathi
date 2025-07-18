var fixmystreet = fixmystreet || {};

fixmystreet.geolocate = function(element, success_callback) {
    element.addEventListener('click', function(e) {
        var link = this;
        e.preventDefault();
        
        // Show loading state
        link.className += ' loading';
        link.disabled = true;
        
        // Show loading text
        var originalText = link.innerHTML;
        link.innerHTML = '<svg class="geolocate-link__loading" width="16" height="16" viewBox="0 0 16 16" role="img" aria-hidden="true" xmlns="http://www.w3.org/2000/svg"><g fill="currentColor" fill-rule="nonzero"><path d="M16 8a8 8 0 11-8-8v2a6 6 0 106 6z"></path><circle cx="8" cy="1" r="1"></circle><circle cx="15" cy="8" r="1"></circle></g></svg> Getting location...';
        
        navigator.geolocation.getCurrentPosition(function(pos) {
            // Success - restore button and redirect
            link.className = link.className.replace(/loading/, ' ');
            link.disabled = false;
            link.innerHTML = originalText;
            success_callback(pos);
        }, function(err) {
            // Error - restore button and show error
            link.className = link.className.replace(/loading/, ' ');
            link.disabled = false;
            link.innerHTML = originalText;
            
            if (err.code === 1) { // User said no
                link.innerHTML = 'Location access denied';
            } else if (err.code === 2) { // No position
                link.innerHTML = 'Location unavailable';
            } else if (err.code === 3) { // Too long
                link.innerHTML = 'Location timeout';
            } else { // Unknown
                link.innerHTML = 'Location error';
            }
            
            // Reset button after 3 seconds
            setTimeout(function() {
                link.innerHTML = originalText;
            }, 3000);
        }, {
            enableHighAccuracy: false,
            timeout: 5000,
            maximumAge: 60000
        });
    });
};

(function(){
    var link = document.getElementById('geolocate_link');
    var currentLocationBtn = document.getElementById('current_location_btn');
    var https = window.location.protocol.toLowerCase() === 'https:';
    var localhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    
    // Always hide the old geolocate link since we have the new button
    if (link) {
        link.style.display = 'none';
    }
    
    // Allow geolocation on HTTPS or localhost
    if ('geolocation' in navigator && (https || localhost) && window.addEventListener) {
        // Handle the new current location button
        if (currentLocationBtn) {
            currentLocationBtn.style.display = 'inline-block';
            fixmystreet.geolocate(currentLocationBtn, function(pos) {
                var latitude = pos.coords.latitude.toFixed(6);
                var longitude = pos.coords.longitude.toFixed(6);
                var coords = 'lat=' + latitude + '&lon=' + longitude;
                var baseUrl = window.location.pathname === '/' ? '/around' : window.location.pathname;
                var separator = baseUrl.indexOf('?') > -1 ? '&' : '?';
                location.href = baseUrl + separator + coords;
            });
        }
    } else {
        if (currentLocationBtn) currentLocationBtn.style.display = 'none';
    }
})();
