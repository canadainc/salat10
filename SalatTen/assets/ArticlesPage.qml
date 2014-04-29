import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            id: titleControl
            kind: TitleBarKind.FreeForm
            scrollBehavior: TitleBarScrollBehavior.NonSticky
            kindProperties: FreeFormTitleBarKindProperties
            {
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    topPadding: 10; bottomPadding: 20; leftPadding: 10
                    
                    Label {
                        text: qsTr("Articles") + Retranslate.onLanguageChanged
                        verticalAlignment: VerticalAlignment.Center
                        textStyle.color: Color.White
                        textStyle.base: SystemDefaults.TextStyles.BigText
                    }
                }
                
                expandableArea
                {
                    expanded: true
                    
                    content: DropDown
                    {
                        id: filter
                        horizontalAlignment: HorizontalAlignment.Fill
                        title: qsTr("Filter") + Retranslate.onLanguageChanged

                        Option {
                            text: qsTr("Common Mistakes") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to errors") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_mistakes.png"
                            value: "event_key='mistakes'"
                        }
                        
                        Option {
                            text: qsTr("Duha") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salat-ul Duha") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_asr_hanafi.png"
                            value: "event_key='duha'"
                        }
                        
                        Option {
                            text: qsTr("Eid") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salat-Eid") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_eid.png"
                            value: "event_key='eid'"
                        }
                        
                        Option {
                            text: qsTr("Fard") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the 5 wajib prayers") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_fard.png"
                            value: "event_key='fajr' OR event_key='dhuhr' OR event_key='asr' OR event_key='maghrib' OR event_key='isha'"
                        }
                        
                        Option {
                            text: qsTr("Fiqh") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the the fiqh of Salah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_fiqh.png"
                            value: "event_key='fiqh'"
                        }
                        
                        Option {
                            text: qsTr("Istikhaarah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the Salat-ul Istikhaarah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_gold.png"
                            value: "event_key='istikhaarah'"
                        }
                        
                        Option {
                            text: qsTr("Janaza") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the Funeral Prayer") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_janaza.png"
                            value: "event_key='janaza'"
                        }
                        
                        Option {
                            text: qsTr("Jumu'ah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles and fatwa related to Salatul-Jumu'ah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_asr_shafii.png"
                            value: "event_key='jumuah'"
                        }
                        
                        Option {
                            text: qsTr("Sutrah") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to the the sutrah") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_sutrah.png"
                            value: "event_key='sutrah'"
                        }
                        
                        Option {
                            text: qsTr("Tahiyyatul-Masjid") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to Tahiyyatul-Masjid") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_masjid.png"
                            value: "event_key='masjid'"
                        }
                        
                        Option {
                            id: uncatFilter
                            text: qsTr("Uncategorized") + Retranslate.onLanguageChanged
                            description: qsTr("Unclassified articles") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_article_filter.png"
                            value: "event_key ISNULL"
                        }
                        
                        Option {
                            text: qsTr("Witr") + Retranslate.onLanguageChanged
                            description: qsTr("Articles related to Salatul-Witr") + Retranslate.onLanguageChanged
                            imageSource: "images/dropdown/ic_moon.png"
                            value: "event_key='witr'"
                        }
                        
                        onSelectedOptionChanged:
                        {
                            sql.query = "SELECT * from articles WHERE %1".arg(selectedOption.value);
                            sql.load();
                        }
                    }
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: back.imagePaint
            layout: DockLayout {}
            
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/graphics/background.png"
                }
            ]
            
            EmptyDelegate {
                id: emptyDelegate
                graphic: "images/empty/ic_no_articles.png"
                labelText: qsTr("There are no articles loaded. Select a category from the dropdown to load them or tap here.")
                delegateActive: true
                
                onImageTapped: {
                    filter.expanded = true;
                }
            }
            
            ListView
            {
                id: listView
                visible: false

                dataModel: GroupDataModel
                {
                    id: gdm
                    grouping: ItemGrouping.ByFullValue
                    sortingKeys: ["title"]
                }
                
                listItemComponents:
                [
                    ListItemComponent {
                        type: "header"
                        
                        Header {
                            title: ListItemData
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "item"
                        
                        Container
                        {
                            id: sli
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            opacity: 0
                            animations: [
                                FadeTransition
                                {
                                    id: showAnim
                                    fromOpacity: 0
                                    toOpacity: 1
                                    duration: sli.ListItem.indexInSection*300
                                }
                            ]
                            
                            onCreationCompleted: {
                                showAnim.play();
                            }
                            
                            gestureHandlers: [
                                TapHandler {
                                    onTapped: {
                                        bodyDelegate.delegateActive = !bodyDelegate.delegateActive;
                                    }
                                }
                            ]
                            
                            StandardListItem {
                                title: ListItemData ? ListItemData.author : ""
                                description: ListItemData ? ListItemData.title : ""
                                imageSource: "images/ic_article.png"
                            }
                            
                            ControlDelegate
                            {
                                id: bodyDelegate
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                delegateActive: false

                                sourceComponent: ComponentDefinition
                                {
                                    Container
                                    {
                                        horizontalAlignment: HorizontalAlignment.Fill
                                        verticalAlignment: VerticalAlignment.Fill
                                        leftPadding: 10; rightPadding: 10; topPadding: 10; bottomPadding: 10
                                        
                                        Label {
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            text: ListItemData.body
                                            multiline: true
                                        }
                                        
                                        Label {
                                            topMargin: 20
                                            horizontalAlignment: HorizontalAlignment.Fill
                                            text: ListItemData.reference
                                            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
                                            multiline: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                ]

                onCreationCompleted: {
                    sql.dataLoaded.connect( function(id, data)
                    {
                        if (id == QueryId.GetArticles)
                        {
                            busy.running = false;
                            
                            gdm.clear();
                            gdm.insertList(data);

                            listView.visible = data.length > 0;
                            emptyDelegate.delegateActive = data.length == 0;
                        }
                    });
                }
            }
            
            ActivityIndicator
            {
                id: busy
                preferredHeight: 200
                horizontalAlignment: HorizontalAlignment.Center
                running: false
            }
        }
    }
}