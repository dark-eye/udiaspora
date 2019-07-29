import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

import "../components"

Page {
    id: instancePickerPage
    anchors.fill: parent
    
    property bool searchRunning:false
    property var lastList: []
    property var updateTime: null

    Component.onCompleted: getSample ()
	
	WorkerScript {
		id:asyncProcess
		source:'../components/jslibs/FilterPods.js'
		onMessage:instanceList.writeInList (  messageObject.reply );
	}

   CachedHttpRequest {
		id:cachedRequest

		url:"https://podupti.me/api.php"
		getData: {
			"format" : "json",
			"key" : token,
		}

		onResponseDataUpdated : {
			searchRunning = false;
				var pods = response.pods;
				lastList = pods;
				updateTime = Date.now();
				asyncProcess.sendMessage( {searchTerm : customInstanceInput.displayText , inData : pods });
		}

		onRequestError: {
			console.log(errorResults)
			instancePickerPage.errorOnRequest();
		}

		onRequestStarted: {
			loading.running = true;
			loadingError.visible = false;
		}
	}

    function getSample () {
		if(searchRunning) { return; }
		searchRunning = true;
       cachedRequest.send("getlist");
    }


    function search ()  {

		var searchTerm = customInstanceInput.displayText;
		//If  the  search starts with http(s) then go to the url 
		if(searchTerm.indexOf("http") == 0 ) {
			appSettings.instance = searchTerm
			mainStack.push (Qt.resolvedUrl("./DiasporaWebview.qml"))
			return
		}
	
		if(updateTime < Date.now()-60000) {
			loading.visible = true
			instanceList.children = ""
			getSample();
		} else {
			asyncProcess.sendMessage( {searchTerm : searchTerm , inData : lastList });
		}
    }



    header: PageHeader {
        id: header
        title: i18n.tr('Choose a Diaspora instance')
        StyleHints {
            foregroundColor: theme.palette.normal.backgroundText
            backgroundColor: theme.palette.normal.background
        }
        trailingActionBar {
            actions: [
            Action {
                text: i18n.tr("Info")
                iconName: "info"
                onTriggered: {
                    mainStack.push(Qt.resolvedUrl("./Information.qml"))
                }
            },
            Action {
                iconName: "search"
                onTriggered: {
                    if ( customInstanceInput.displayText == "" ) {
                        customInstanceInput.focus = true
                    } else search ()
                }
            }
            ]
        }
    }

    ActivityIndicator {
        id: loading
        visible: true
        running: true
        anchors.centerIn: parent
    }


    TextField {
        id: customInstanceInput
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: height
        width: parent.width - height
        placeholderText: i18n.tr("Search or enter a custom address")
		onDisplayTextChanged: if(displayText.length > 2) {search();}
        Keys.onReturnPressed: search ()
    }
    
    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height - 3*customInstanceInput.height
        anchors.top: customInstanceInput.bottom
        anchors.topMargin: customInstanceInput.height
        contentItem: Column {
            id: instanceList
            width: root.width


            // Write a list of instances to the ListView
            function writeInList ( list ) {
                instanceList.children = ""
                loading.visible = false
                list.sort(function(a,b) {return !a.uptimelast7 ? (!b.uptimelast7 ? 0 : 1) : (!b.uptimelast7 ? -1 : parseFloat(b.uptimelast7) - parseFloat(a.uptimelast7));});
                for ( var i = 0; i < list.length; i++ ) {
                    var item = Qt.createComponent("../components/InstanceItem.qml")
                    item.createObject(this, {
                        "text": list[i].domain,
                        "country": list[i].country != null ? list[i].country : "",
                        "uptime": list[i].uptimelast7 != null ? list[i].uptimelast7 : "",
                        "iconSource":  list[i].thumbnail != null ? list[i].thumbnail : "../../assets/diaspora-asterisk.png",
						"status":  list[i].status != null ? list[i].status : 0,
						"rating":  list[i].score != null ? list[i].score : 0
                    })
                }
            }
        }
    }
    
    Label {
		id:noResultsLabel
		visible: !instanceList.children.length && !loading.visible
		anchors.centerIn: scrollView;
		text:customInstanceInput.length ? i18n.tr("No pods fund for search : %1").arg(customInstanceInput.displayText) :  i18n.tr("No pods returned from server");
	}

}
