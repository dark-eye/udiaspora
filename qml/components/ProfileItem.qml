import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

ListItem {
    id: task

    property var text: ""
    property var url: ""
	property var status: 0
	property var size: 0

    height: layout.height

    ListItemLayout {
        id: layout
        title.text: text
        summary.text: url ? url : ""

        Icon {
			name: "starred"
			visible : status != 0
			SlotsLayout.position: SlotsLayout.Last;
			width: units.gu(2)
		}

    }
    Component {
		id:starIcon
		Icon {
			width:units.gu(2)
			height:width
			name:"starred"
		}
	}
}
