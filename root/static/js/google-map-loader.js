/**
 * This script will load the Google Maps
 */

(function(jQuery) {
    
    var map         = null;
    var geocoder    = null;
    
    /**
     * This sets up the Google Maps functionality when the document is loaded.
     */
    jQuery(document).ready(
        function() {
            load_google_maps();
            load_google_maps_show();
            jQuery('#google-map-address-search').click(search_address);
        }
    );
    
    /**
     * This unloads the Google Maps functionality when the document is
     * destroyed.
     */
    jQuery(document).unload(
        function() {
            unload_google_maps();
        }
    );
    
    function load_google_maps() {
        if (GBrowserIsCompatible()) {
            var map_elm = document.getElementById('google-map');
            if (!map_elm) return false;
            
            map = new GMap2(map_elm);
            
            map.addControl(new GLargeMapControl());
            map.addControl(new GMapTypeControl());
            
            map.setCenter(new GLatLng(63.3915, 10.1074), 4);
            
            geocoder = new GClientGeocoder();
            GEvent.addListener(map, 'moveend', update_coordinates);
        }
    }
    
    function load_google_maps_show() {
        if (GBrowserIsCompatible()) {
            var map_elm = document.getElementById('google-map-show');
            if (!map_elm) return false;
            
            var map         = new GMap2(map_elm);
            var latitude    = jQuery('#google-map-geo-lat').val();
            var longitude   = jQuery('#google-map-geo-long').val();
            
            var point       = new GLatLng(latitude, longitude);
            map.setCenter(point, 12);
            
            var marker = new GMarker(point);
            map.addOverlay(marker);
            marker.openInfoWindowHtml("Du vil motta værvarsel herfra");
        }
    }
    
    function search_address() {
        var address = jQuery('#google-map-address').val();
        
        jQuery(document.getElementById('varsle-reg.geosearch')).val(address);
        
        if (geocoder && address) {
            geocoder.getLatLng(
				address,
				function(point) {
					if (!point) {
					   alert("Fant ikke " + address + ". Prøv heller navnet på nærmeste tettsted eller by.");
					}
					else {
						map.setCenter(point, 13);
						var marker = new GMarker(point);
						map.addOverlay(marker);
						marker.openInfoWindowHtml(address);
					}
				}
            );
        }
        
        return false;
    }
    
    function update_coordinates() {
        var map_center = map.getCenter();
        var input_elm = jQuery(document.getElementById('varsle-reg.geo'));
        input_elm.val(map_center.toString());
    }
    
    function unload_google_maps() {
        GUnload();
    }

})(jQuery);
