import bb.cascades 1.0

QtObject
{
    id: root
    
    function onFinished(result, cookie, data)
    {
        if (data == "locationServices")
        {
            if (!result && cookie) {
                persist.setFlag("hideLocationServicesWarning", 1);
            }
            
            if (result) {
                persist.launchSettingsApp("location");
            }
        } else {
            if (result && cookie.app == "quran10") {
                persist.openUri("http://quran10.canadainc.org");
            }
            
            reporter.record(cookie, result);
        }
    }
    
    function getRandomReal(min, max) {
        return Math.random() * (max - min) + min;
    }
    
    function onTargetLookupFinished(target, success)
    {
        if (!success) {
            persist.showDialog(root, {'app': "quran10"}, qsTr("Quran10"), qsTr("This feature requires the app Quran10 v4.0.0.0 or greater to be installed on your device. Would you like to download and install it now?"), qsTr("Yes"), qsTr("No") );
        }
    }
    
    function getSuffix(birth, death, isCompanion, female)
    {
        if (isCompanion)
        {
            if (female) {
                return qsTr("رضي الله عنها");
            } else {
                return qsTr("رضي الله عنه");
            }
        } else if (death) {
            return qsTr(" (رحمه الله)");
        } else if (birth) {
            return qsTr(" (حفظه الله)");
        }
        
        return "";
    }
    
    function showLocationServices()
    {
        if ( !persist.containsFlag("hideLocationServicesWarning") ) {
            persist.showDialog(root, "locationServices", qsTr("Location Services"), qsTr("Warning: It seems like the location services is not enabled on your BlackBerry 10 device so the app will not be able to fetch real-time data and map information.\n\nWould you like to launch the Location Services screen and enable the Location Services permission there?"), qsTr("Yes"), qsTr("No"), true, qsTr("Don't ask again"), false );
        }
    }
    
    function renderAthanStatus(ListItemData)
    {
        if (ListItemData.athaan == true && ListItemData.isSalat) {
            return "images/list/ic_athaan_enable.png";
        } else if (ListItemData.notification == true) {
            return "images/list/ic_notification_enable.png";
        } else {
            return "images/list/ic_athaan_mute.png";
        }
    }
}