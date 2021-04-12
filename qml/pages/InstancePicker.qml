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
		onMessage:instanceList.writeInList (  messageObject.reply , messageObject.userdata);
	}

	CachedHttpRequest {
		id:cachedRequest

		url:"https://the-federation.info/graphql"
		getData: {
			"operationName" : "Platform",
			"variables" : '{"name":"diaspora"}',
			"query" : "query Platform($name: String!) {
							platforms(name: $name) {
								name
								code
								displayName
								description
								tagline
								website
								icon
								__typename
							}
							nodes(platform: $name) {
								id
								name
								version
								openSignups
								host
								platform {
								name
								icon
								__typename
								}
								countryCode
								countryFlag
								countryName
								services {
								name
								__typename
								}
								__typename
							}
							statsNodes(platform: $name) {
								node {
								id
								__typename
								}
								usersTotal
								usersHalfYear
								usersMonthly
								localPosts
								localComments
								__typename
							}
						}"
		}

		onResponseDataUpdated : {
			searchRunning = false;
			var data = response.data;
			lastList = data;
			updateTime = Date.now();
			asyncProcess.sendMessage( {searchTerm : customInstanceInput.displayText , inData : data });
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


	function search (autoComplete)  {

		var searchTerm = customInstanceInput.displayText;
		//If  the  search starts with http(s) then go to the url 
		if(!autoComplete  && searchTerm.indexOf("http") == 0 ) {
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
					} else search (false)
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
		onDisplayTextChanged: if(displayText.length > 2) {search(true);}
		Keys.onReturnPressed: search (false)
	}

	ListView {
		id: instanceList
		width: parent.width
		height: parent.height - header.height - 3*customInstanceInput.height
		anchors.top: customInstanceInput.bottom
		anchors.topMargin: customInstanceInput.height
		clip:true
		model: []
		delegate: InstanceItem {
			text:modelData.text
			country:modelData.country
			version: modelData.version
			iconSource: modelData.iconSource
			status: modelData.status
			activeUsers: modelData.activeUsers
		}
		// Write a list of instances to the ListView
		function writeInList ( list ,userdata) {
			var newModel = []
			loading.visible = false
			
			for ( var i = 0; i < list.length; i++ ) {
				//Find 
				var usersCount = null;
				for(var statIdx in userdata.statsNodes) {
					if(userdata.statsNodes[statIdx].node.id == list[i].id) {
						usersCount = userdata.statsNodes[statIdx].usersMonthly;
						break;
					}
				}
				
				newModel.push(
				 {
					"text": list[i].host,
					"country": list[i].countryFlag != null ? list[i].countryFlag : "",
					"version": list[i].version != null ? list[i].version : "",
					"iconSource":  list[i].thumbnail != null ? list[i].thumbnail : "../../assets/diaspora-asterisk.png",
					"status":  list[i].openSignups != null ? list[i].openSignups : 0,
					"activeUsers":  usersCount != null ? usersCount : 0
				})
			}
			instanceList.model.sort(function(a,b) {
				return a.activeUsers -  b.activeUsers +
				(10*(!a.version ? (!b.version ? 0 : 1) : (!b.version ? -1 : parseFloat(b.version) - parseFloat(a.version))));
			});
			instanceList.model = newModel;
		}

	}

	Label {
		id:noResultsLabel
		visible: !instanceList.children.length && !loading.visible
		anchors.centerIn: instanceList;
		text:customInstanceInput.length ? i18n.tr("No pods fund for search : %1").arg(customInstanceInput.displayText) :  i18n.tr("No pods returned from server");
	}

}
