import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

Page {
    id: instancePickerPage
    anchors.fill: parent
    Component.onCompleted: getSample ()

    /* Load list of Mastodon Instances from https://instances.social
    * The Response is in format:
    * { id, name, added_at, updated_at, checked_at, uptime, up, dead, version,
    * ipv6, https_score, https_rank, obs_score, obs_rank, users, statuses,
    * connections, open_registrations, info { short_description, full_description,
    *      topic, languages[], other_languages_accepted, federates_with,
    *      prhobited_content[], categories[]}, thumbnail, active_users }
    */
    function getSample (filterFunction) {

        var http = new XMLHttpRequest();
        var data = "?" +
        "format=json&" +
        "key="+token;
        http.open("GET", "https://podupti.me/api.php" + data, true);
        http.setRequestHeader('Content-type', 'application/json; charset=utf-8')
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                var response = JSON.parse(http.responseText);
				var pods = (filterFunction) ? filterFunction(response.pods) : response.pods;
                instanceList.writeInList ( pods )
            }
        }
        loading.running = true;
        http.send();
    }


    function search ()  {
		var searchTerm = customInstanceInput.displayText;
		//If  the  search starts with http(s) then go to the url 
		if(searchTerm.indexOf("http") == 0 ) {
			settings.instance = searchTerm
			mainStack.push (Qt.resolvedUrl("./DiasporaWebview.qml"))
			return
		}
		
		// filter the  pod list results
		function filter(list) {
			var retList = [];
			for(var i in list) {
				if(list[i].domain && list[i].domain.match(new RegExp(searchTerm))) {
					retList.push(list[i]);
				}
			}
			return retList;
		}
		getSample(filter);
    }



    header: PageHeader {
        id: header
        title: i18n.tr('Choose a Disapora instance')
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
// 				enabled:false
                onTriggered: {
                    if ( customInstanceInput.displayText == "" ) {
                        customInstanceInput.focus = true
                    }
                    else search ()
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
// 		enabled:false
        id: customInstanceInput
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: height
        width: parent.width - height
        placeholderText: i18n.tr("Search or enter a custom address")
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
                list.sort(function(a,b) {!a.uptimelast7 ? -1 : (!b.uptimelast7 ? 1 : parseFloat(a.uptimelast7) - parseFloat(b.uptimelast7));});
                for ( var i = 0; i < list.length; i++ ) {
                    var item = Qt.createComponent("../components/InstanceItem.qml")
                    item.createObject(this, {
                        "text": list[i].domain,
                        "country": list[i].country != null ? list[i].country : "",
                        "uptime": list[i].uptimelast7 != null ? list[i].uptimelast7 : "",
                        "iconSource":  list[i].thumbnail != null ? list[i].thumbnail : "../../assets/logo.svg",
						"status":  list[i].status != null ? list[i].status : 0,
						"rating":  list[i].score != null ? list[i].score : 0
                    })
                }
            }
        }
    }

}
