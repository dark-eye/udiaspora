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

		url:"https://the-federation.info/graphql"
		getData: {
			"operationName" : "Platform",
			"variables" : '{"name":"diaspora"}',
			"query" : "query Platform($name: String!) {  platforms(name: $name) {    name    code    displayName    description    tagline    website    icon    __typename  }  nodes(platform: $name) {    id    name    version    openSignups    host    platform {      name      icon      __typename    }    countryCode    countryFlag    countryName    services {      name      __typename    }    __typename  }  statsGlobalToday(platform: $name) {    usersTotal    usersHalfYear    usersMonthly    localPosts    localComments    __typename  }  statsNodes(platform: $name) {    node {      id      __typename    }    usersTotal    usersHalfYear    usersMonthly    localPosts    localComments    __typename  }}"
		}

		onResponseDataUpdated : {
			searchRunning = false;
			var pods = response.data.nodes;
			lastList = pods;
			updateTime = Date.now();
			asyncProcess.sendMessage( {searchTerm : customInstanceInput.displayText , inData : pods });
		}

		onRequestError: {
			searchRunning = false;
			console.log(errorResults)
			instancePickerPage.errorOnRequest();
		}

		onRequestStarted: {
			loading.running = true;
			searchRunning = true;
			loadingError.visible = false;
		}
	}

	function getSample () {
		if(searchRunning) { return; }
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


	Label {
		id: loadingError
		anchors.centerIn: parent
		visible:false
		text : i18n.tr("Error loading instances nodes")
		color:theme.palette.normal.negative
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

	ListView {
		id: instanceList
		width: parent.width
		anchors.bottom:parent.bottom
		anchors.top: customInstanceInput.bottom
		anchors.topMargin: customInstanceInput.height
		clip:true
		model: []
		delegate: InstanceItem {
			text:modelData.text
			host:modelData.host
			country:modelData.country
			uptime: modelData.uptime
			iconSource: modelData.iconSource
			status: modelData.status
			rating: modelData.rating

			onClicked: {
				appSettings.instance = host
				mainStack.push (Qt.resolvedUrl("../pages/DiasporaWebview.qml"))
			}
		}
		// Write a list of instances to the ListView
		function writeInList ( list ) {
			var newModel = []
			loading.visible = false
			list.sort(function(a,b) {return !a.uptimelast7 ? (!b.uptimelast7 ? 0 : 1) : (!b.uptimelast7 ? -1 : parseFloat(b.uptimelast7) - parseFloat(a.uptimelast7));});
			for ( var i = 0; i < list.length; i++ ) {
				newModel.push(
				 {
					"text": list[i].name,
					"host" :list[i].host,
					"country": list[i].countryName != null ? list[i].countryName : "",
					"uptime": list[i].uptimelast7 != null ? list[i].uptimelast7 : "",
					"iconSource":  list[i].thumbnail != null ? list[i].thumbnail : "../../assets/diaspora-asterisk.png",
					"status":  list[i].status != null ? list[i].status : 0,
					"rating":  list[i].score != null ? list[i].score : 0
				})
			}
			instanceList.model = newModel;
		}

	}

	Label {
		id:noResultsLabel
		visible: !instanceList.model.length && !loading.visible
		anchors.centerIn: instanceList;
		text:customInstanceInput.length ? i18n.tr("No pods fund for search : %1").arg(customInstanceInput.displayText) :  i18n.tr("No pods returned from server");
	}

}
