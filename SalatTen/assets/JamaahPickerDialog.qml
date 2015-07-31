import bb.cascades 1.0

FullScreenDialog
{
    property variant base
    property string key
    
    onBaseChanged: {
        dtp.minimum = base;
        
        var max = base;
        max.setMinutes( base.getMinutes()+15 );
        dtp.value = max;
        
        max.setHours( max.getHours()+2 );
        dtp.maximum = max;
    }
    
    onClosing: {
        reporter.record( "SaveIqamah", key+"="+dtp.value.toString() );
        app.saveIqamah(key, dtp.value);
        persist.showToast( qsTr("Iqamah time set to: %1").arg( offloader.renderStandardTime(dtp.value) ), "", "asset:///images/empty/ic_no_coordinates.png" );
    }
    
    onOpened: {
        tt.play();
    }
    
    dialogContent: Container
    {
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        animations: [
            TranslateTransition
            {
                id: tt
                fromY: -720
                toY: 0
                easingCurve: StockCurve.ExponentialOut
                duration: 1000
                
                onEnded: {
                    dtp.expanded = true;
                    tutorial.execCentered( "jamaah", qsTr("Please set the time the congregational prayer for %1 at the masjid/musalla. Then tap anywhere outside the picker to save and dismiss it.").arg( translator.render(key) ) );
                }
            }
        ]
        
        DateTimePicker
        {
            id: dtp
            mode: DateTimePickerMode.Time
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            title: qsTr("Jamaah Time") + Retranslate.onLanguageChanged
        }
    }
}