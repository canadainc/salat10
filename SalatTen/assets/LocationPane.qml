import bb.cascades 1.0
import bb.cascades.places 1.0
import bb.cascades.maps 1.0

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    layout: DockLayout {}
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        TextField
        {
            id: searchField
            hintText: qsTr("Enter location to search...") + Retranslate.onLanguageChanged
            horizontalAlignment: HorizontalAlignment.Fill
            bottomMargin: 0
            
            input {
                submitKey: SubmitKey.Search
                flags: TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                
                onSubmitted: {
                    busy.running = true;
                    
                    var query = searchField.text.trim();
                    notification.geoLookup(query);
                }
            }
            
            onCreationCompleted: {
                input["keyLayout"] = 7;
            }
        }
        
        DropDown
        {
            id: locations
            title: qsTr("No Locations Found") + Retranslate.onLanguageChanged
            
            function onLocationsFound(result)
            {
                if (result.status == "OK")
                {
                    locations.removeAll();
                    var n = result.results.length;
                    
                    for (var i = 0; i < n; i++) {
                        var option = optionDef.createObject();
                        option.value = result.results[i];
                        
                        locations.add(option);
                    }
                    
                    locations.title = qsTr("%n locations found", "", n);
                    tb.kindProperties.expandableArea.expanded = true;
                    locations.expanded = true;
                } else {
                    persist.showToast( qsTr("Could not fetch geolocation results. Please either use the 'Choose Location' from the bottom, tap on the 'Refresh' button use your GPS or please try again later."), "", "asset:///images/toast/ic_location_failed.png" );
                }
                
                busy.running = false;
            }
            
            onSelectedValueChanged: {
                var parts = selectedValue.address_components;
                var city = "";
                var country = "";
                var latitude = selectedValue.geometry.location.lat;
                var longitude = selectedValue.geometry.location.lng;
                
                for (var i = parts.length-1; i >= 0; i--)
                {
                    var types = parts[i].types;
                    
                    if ( types.indexOf("country") != -1 ) {
                        country = parts[i].long_name;
                    } else if ( types.indexOf("locality") != -1 ) {
                        city = parts[i].long_name;
                    }
                }
                
                mapViewDelegate.delegateActive = true;
                mapViewDelegate.control.animateToLocation(latitude, longitude, 50000);
                
                persist.saveValueFor("location", selectedValue.formatted_address);
                persist.saveValueFor("latitude", latitude, true);
                persist.saveValueFor("longitude", longitude, true);
                
                if (city.length > 0) {
                    persist.saveValueFor("city", place.city, false);
                }
                
                if (country.length > 0) {
                    persist.saveValueFor("country", place.country, false);
                }
                
                locationAction.title = selectedValue.formatted_address;
            }
            
            onCreationCompleted: {
                notification.locationsFound.connect(onLocationsFound);
            }
            
            attachedObjects: [
                ComponentDefinition
                {
                    id: optionDef
                    
                    Option
                    {
                        imageSource: "file:///usr/share/icons/ic_map_all.png"
                        
                        onValueChanged: {
                            text = value.formatted_address;
                            description = "(" + value.geometry.location.lat + ", " + value.geometry.location.lng + ")";
                        }
                    }
                }
            ]
        }
        
        ControlDelegate
        {
            id: mapViewDelegate
            delegateActive: false
            
            sourceComponent: ComponentDefinition
            {
                MapView {
                    id: mapView
                    altitude: 100000000
                    tilt: 2
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    
                    function onMapDataLoaded(data)
                    {
                        var allKeys = translator.eventKeys();
                        var max = 1000*60*30;
                        
                        for (var i = data.length-1; i >= 0; i--)
                        {
                            var current = data[i];
                            var name = current.location;
                            var key = current.current;
                            var rendered;
                            
                            if (current.diff < max) // less than 30 mins
                            {
                                var index = allKeys.indexOf(key);
                                
                                if (index < allKeys.length-1) {
                                    ++index;
                                } else {
                                    index = 0;
                                }
                                
                                key = allKeys[index];
                                rendered = qsTr("Almost %1").arg( translator.render(key) );
                            } else {
                                rendered = translator.render(key);
                            }
                            
                            app.renderMap(mapView, current.latitude, current.longitude, name, rendered);
                        }
                    }
                    
                    onCreationCompleted: {
                        notification.mapDataLoaded.connect(onMapDataLoaded);
                        notification.fetchCheckins();
                    }
                }
            }
        }
    }
    
    ImageButton
    {
        defaultImageSource: "images/menu/ic_reset.png"
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Bottom
        
        function onFound(l,p) {
            busy.running = false;
        }
        
        onClicked: {
            console.log("UserEvent: RefreshLocation");
            
            var geoFinder = app.refreshLocation();
            
            if (geoFinder) {
                busy.running = true;
                geoFinder.finished.connect(onFound)
            }
        }
    }
    
    ActivityIndicator
    {
        id: busy
        running: false
        visible: running
        preferredHeight: 200
        preferredWidth: 200
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
    }
    
    function onSettingChanged(key)
    {
        if (key == "longitude" && boundary.calculationFeasible)
        {
            mapViewDelegate.delegateActive = true;
            
            var location = persist.getValueFor("location");
            location = location ? location : qsTr("Choose Location");
            locationAction.title = location;
            var current = boundary.getCurrent( new Date() );
            
            app.renderMap(mapViewDelegate.control, persist.getValueFor("latitude"), persist.getValueFor("longitude"), location, translator.render(current.key), true);
        }
    }
    
    onCreationCompleted: {
        persist.settingChanged.connect(onSettingChanged);
        onSettingChanged("longitude");
        
        if ( !persist.contains("longitude") ) {
            searchField.requestFocus();
        }
    }
}