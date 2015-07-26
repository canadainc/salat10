import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Menu.definition: CanadaIncMenu
    {
        id: menuDef
        projectName: "salat10"
        allowDonations: true
        bbWorldID: "21198062"
        help.imageSource: "images/menu/ic_help.png"
        help.title: qsTr("Help") + Retranslate.onLanguageChanged
        settings.imageSource: "images/menu/ic_settings.png"
        settings.title: qsTr("Settings") + Retranslate.onLanguageChanged
        
        onFinished: {
            notification.currentEventChanged.connect(onCurrentEventChanged);
            onCurrentEventChanged();
            
            timings.anim.play();
        }
    }
    
    Page
    {
        id: tabsPage

        Container
        {
            layout: DockLayout {}
            
            gestureHandlers: [
                TapHandler {
                    onTapped: {
                        if (!boundary.calculationFeasible) {
                            recorder.record("NoLocationsSetTapped");
                            menuDef.settings.triggered();
                        }
                    }
                }
            ]
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                layout: DockLayout {}
                
                ImageView
                {
                    id: bg
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    scalingMethod: ScalingMethod.AspectFill
                }
                
                ImageView
                {
                    id: bg2
                    opacity: timings.draggingStarted ? 1 : 0
                    loadEffect: ImageViewLoadEffect.FadeZoom
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    scalingMethod: ScalingMethod.AspectFill
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    background: Color.Black
                    opacity: bg2.opacity == 1 ? 0.35 : 0
                }
            }
            
            ResultListView
            {
                id: timings
                anim.onEnded: {
                    permissions.process();
                    
                    if (boundary.calculationFeasible)
                    {
                        if ( !persist.containsFlag("athanPrompted") ) {
                            showAthanPrompt();
                        } else {
                            tutorial.execCentered("randomBenefit", qsTr("You can tap on the author's name to find out more information about them (you need to have the Quran10 app installed).") );
                            tutorial.exec("todaysHijriDate", qsTr("This is today's Hijri date."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(17) );
                            tutorial.exec("exportToCalendar", qsTr("You can tap on the calendar icon to export the timings right to your calendar so that you can get prayer time reminders to show up directly on your device's calendar. This will also allow reminders to be shown even while the app is closed!"), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(17) );
                            tutorial.exec("editDate", qsTr("If the date is incorrect, press-and-hold on it and choose 'Edit Date' from the menu."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(17) );
                            tutorial.exec("currentEvent", qsTr("This displays the current event that is already in progress."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(10), 0, 0, ui.du(8) );
                            tutorial.exec("toggleCurrentEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that specific event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(8) );
                            tutorial.exec("nextEvent", qsTr("This displays the next event that is coming up."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(10), 0, 0, ui.du(1) );
                            tutorial.exec("toggleNextEvent", qsTr("Tapping on the icon will toggle the athan and notification settings for that next event. So if you want to turn on or turn off the athan and notifications tap on the icon."), HorizontalAlignment.Left, VerticalAlignment.Bottom, ui.du(2), 0, 0, ui.du(1) );
                            tutorial.exec("footerTap", qsTr("Tap anywhere on this strip to expand it and see the details for today."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, ui.du(8), 0, ui.du(1) );
                            tutorial.exec("expandFooter", qsTr("You can also expand this strip by swiping-up on it and see the details."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(2), "images/menu/ic_top.png");
                            tutorial.exec("openAppMenu", qsTr("Swipe down from the top-bezel to display the Settings and Help and file bugs!"), HorizontalAlignment.Center, VerticalAlignment.Top, 0, 0, 0, ui.du(2), "images/menu/ic_bottom.png", "d");
                        }
                        
                        if (boundary.atLeastOneAthanScheduled)
                        {
                            if ( !persist.containsFlag("athanPicked") ) {
                                var picker = definition.init("AthanPreviewSheet.qml");
                                picker.all = ["dhuhr", "asr", "maghrib", "isha"];
                                picker.open();
                            } else if ( !persist.containsFlag("tutorialMuteAthan") ) {
                                var picker = definition.init("MuteAthanTutorial.qml");
                                picker.open();
                            }
                        }
                    } else {
                        quoteLabel.text = qsTr("No location has been set...");
                    }
                }
                
                onFooterGone: {
                    tutorial.execBelowTitleBar( "selectiveAthan", qsTr("Do you want to enable some athans but disable other ones?\n\nYou can do this by tapping on the prayers that you want to play the athan for (ie: Fajr, Maghrib) so they become highlighted. Then from the menu choose 'Enable Alarams/Athans'.") );
                    tutorial.execBelowTitleBar( "editTimings", qsTr("Are your timings off by a few minutes from your local masjid?\n\nThat's easy to fix, simply press-and-hold on the time that is off (ie: Maghrib), and from the menu on the right side choose 'Edit'. You will then be able to adjust the results by up to 10 minutes."), 10 );
                    tutorial.execBelowTitleBar( "setIqamah", qsTr("You can also set iqamah times for when they pray at your local masjid/musalla by pressing-and-holding on the event and choosing 'Set Iqamah'."), 20 );
                }
                
                function onExportReady(daysToExport, result, accountId)
                {
                    progressDelegate.delegateActive = true;
                    offloader.exportToCalendar(daysToExport, result, accountId);
                    
                    navigationPane.pop();
                }
                
                function hasCalendar()
                {
                    if ( offloader.hasCalendarAccess() ) {
                        return true;
                    } else {
                        var allMessages = [];
                        var allIcons = [];
                        allMessages.push("Warning: It seems like the app does not have access to your Calendar. This permission is needed for the app to respond to 'calendar' commands if you want to ever check your device's local calendar remotely. If you leave this permission off, some features may not work properly. Tap OK to enable the permissions in the Application Permissions page.");
                        allIcons.push("images/toast/ic_calendar_empty.png");
                        permissions.messages = allMessages;
                        permissions.icons = allIcons;
                        permissions.delegateActive = true;
                    }
                    
                    return false;
                }
                
                function exportToCalendar()
                {
                    if ( hasCalendar() )
                    {
                        definition.source = "CalendarExport.qml";
                        
                        var exporter = definition.createObject();
                        exporter.exportingReady.connect(onExportReady);
                        
                        navigationPane.push(exporter);
                    }
                }
                
                function onFinished(confirmed)
                {
                    if (confirmed) {
                        console.log("UserEvent: ClearCalendarPromptYes");
                        progressDelegate.delegateActive = true;
                        offloader.cleanupCalendarEvents();
                    } else {
                        console.log("UserEvent: ClearCalendarPromptNo");
                    }
                    
                    reporter.record("ClearCalendarResult", confirmed.toString());
                }
                
                function clearCalendar()
                {
                    if ( hasCalendar() ) {
                        persist.showDialog( timings, qsTr("Confirmation"), qsTr("Are you sure you want to clear all favourites?") );
                    }
                }
                
                onCreationCompleted: {
                    timings.maxWidth = deviceUtils.pixelSize.width
                    timings.maxHeight = deviceUtils.pixelSize.height
                    quoteLabel.maxWidth = timings.maxWidth-100;
                }
                
                onFooterShown: {
                    if (boundary.calculationFeasible) {
                        sql.fetchRandomBenefit(quoteLabel);
                    }
                }
            }
            
            TextArea
            {
                id: quoteLabel
                backgroundVisible: false
                editable: false
                textStyle.fontSize: FontSize.XXSmall
                opacity: ( timings.lssh.firstVisibleItem.length == 1 && !timings.lssh.scrolling ) || !boundary.calculationFeasible ? 1 : 0
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Center
                topMargin: 0; bottomMargin: 0
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.GetRandomBenefit)
                    {
                        var quote = data[0];
                        text = "<html><i>\n“%1”</i>\n\n- <b><a href=\"%5\">%2</a>%4</b>\n\n[%3]\n</html>".arg( quote.body.replace(/&/g,"&amp;") ).arg(quote.author).arg( quote.reference.replace(/&/g,"&amp;") ).arg( global.getSuffix(quote.birth, quote.death, quote.is_companion == 1, quote.female == 1) ).arg( quote.id.toString() );
                    }
                }
                
                activeTextHandler: ActiveTextHandler
                {
                    id: ath
                    
                    onTriggered: {
                        var link = event.href.toString();
                        
                        if ( link.match("\\d+") ) {
                            persist.invoke("com.canadainc.Quran10.bio.previewer", "", "", "", link, global);
                            reporter.record("OpenAuthorLink", link);
                        }
                        
                        event.abort();
                    }
                }
            }
            
            ControlDelegate
            {
                id: progressDelegate
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                delegateActive: false;
                visible: delegateActive
                
                function onProgressChanged(current, total)
                {
                    control.showBusy = false;
                    control.value = current;
                    control.toValue = total;
                }
                
                function onComplete(message, icon)
                {
                    delegateActive = false;
                    persist.showToast(message, icon);
                }
                
                onCreationCompleted: {
                    offloader.operationProgress.connect(onProgressChanged);
                    offloader.operationComplete.connect(onComplete);
                }
                
                sourceComponent: ComponentDefinition
                {
                    Container
                    {
                        property alias value: progress.value
                        property alias toValue: progress.toValue
                        property alias showBusy: busy.running
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        ActivityIndicator
                        {
                            id: busy
                            horizontalAlignment: HorizontalAlignment.Center
                            preferredHeight: 100; preferredWidth: 100
                            running: true
                        }
                        
                        ProgressIndicator
                        {
                            id: progress
                            fromValue: 0;
                            horizontalAlignment: HorizontalAlignment.Center
                            state: ProgressIndicatorState.Progress
                        }
                    }
                }
            }
            
            PermissionToast
            {
                id: permissions
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                function process()
                {
                    var allMessages = [];
                    var allIcons = [];
                    
                    if ( !persist.hasLocationAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to access your device's location. This permission is needed to detect your GPS location so that accurate calculations can be made. If you keep this permission off, the app may not work properly.\n\nPress OK to launch the application permissions, then go to Salat10 and please enable the Location permission.");
                        allIcons.push("images/toast/ic_location_failed.png");
                    }
                    
                    if ( !persist.hasSharedFolderAccess() ) {
                        allMessages.push("Warning: It seems like the app does not have access to access your shared folder. This permission is needed to allow you to set custom athan sounds. Without this permission some features may not work properly.");
                        allIcons.push("images/toast/ic_no_shared_folder.png");
                    }
                    
                    if ( !offloader.isServiceRunning() )
                    {
                        allMessages.push("Warning: It seems like the Salat10 background service is not running. The Run In Background permission is necessary for the athaan and notifications to function properly.");
                        allIcons.push("images/toast/no_service.png");
                    }
                    
                    if (allMessages.length > 0)
                    {
                        messages = allMessages;
                        icons = allIcons;
                        delegateActive = true;
                    }
                }
            }
        }
    }
    
    function onCurrentEventChanged()
    {
        if (boundary.calculationFeasible)
        {
            var current = boundary.getCurrent( new Date() );
            var k = current.key;
            
            if (k == "halfNight" || k == "lastThirdNight") {
                k = "isha";
            }
            
            var src = "images/graphics/%1.jpg".arg(k);
            bg.imageSource = src;
            offloader.blur(bg2, src);
        } else {
            bg.imageSource = "images/graphics/background.png";
        }
    }
}