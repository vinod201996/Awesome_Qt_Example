import QtQuick 2.12
import QtQuick.Controls 2.4
import QtQuick.Window 2.11

ApplicationWindow {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Table View")
    color: '#222222'
    // Array which store the selected index of all the combobox of the TableView
    property variant tabIndexComboBox : [];
    property var patternModelData: [1,2,3,4,5,6,7,8,9];

    TableView {
        id: tableView
        signal checkedChanged(int index, bool cheked)

        columnWidthProvider: function (column) { return 100; }
        rowHeightProvider: function (column) { return 60; }
        anchors.fill: parent
        //        leftMargin: rowsHeader.implicitWidth
        topMargin: columnsHeader.implicitHeight
        model: table_model
        ScrollBar.horizontal: ScrollBar{}
        ScrollBar.vertical: ScrollBar{}
        clip: true

        delegate: Rectangle {
            Loader {
                anchors.fill: parent
                sourceComponent: Component {
                    Item {
                        id: name
                        anchors.fill: parent
                        Text {
                            id: displayText
                            visible: column != 2
                            text: display
                            anchors.fill: parent
                            anchors.margins: 10
                            color: 'black'
                            font.pixelSize: 15
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log(row, column, tableView.model.data(tableView.model.index(row, column)))
                                }
                            }
                        }
                        CheckBox {
                            id: rowSelector
                            anchors.fill: parent
                            visible: column == 2 && row != 1
                            onCheckedChanged: {
                                console.log("Check box", row, column, checked, retrieveIndex(1, column))
                            }
                        }
                        ComboBox {
                            id: pattern
                            anchors.fill: parent
                            anchors.margins: 10

                            visible: column == 2 && row == 1
                            model: patternModelData//[ {"text":"Banana"}, {"text":"Apple"}, {"text":"Coconut"} ]
//                            textRole: "text";
                            onCurrentIndexChanged: {
                                console.log("Combo box", currentIndex)
                            }
                            onActivated: {
                                console.log("onCurrentIndexChanged : row=" + row + ", column=" + column + ", value set to : " + index);
                                root.manageIndex(row, column, index);
                            }
                        }
                    }
                }
            }
        }

        Rectangle { // mask the headers
            z: 3
            color: "#222222"
            y: tableView.contentY
            x: tableView.contentX
            width: tableView.leftMargin
            height: tableView.topMargin
        }

        Row {
            id: columnsHeader
            y: tableView.contentY
            z: 2
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    width: tableView.columnWidthProvider(modelData)
                    height: 35
                    text: table_model.headerData(modelData, Qt.Horizontal)
                    color: '#aaaaaa'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter

                    background: Rectangle { color: "#333333" }
                }
            }
        }

        ScrollIndicator.horizontal: ScrollIndicator { }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Row {
        id:idRow
        anchors.top: tableView.bottom
        anchors.topMargin: 10
        Button {
            id:idButtonDump
            text:"Dump"
            background: Rectangle{
                anchors.fill: parent
                color: 'white'
            }
            onPressed: {
                console.log("DUMP START tabIndexComboBox");
                for(var i=0; i<tabIndexComboBox.length;i++)
                {
                    var indexObjectExisting = tabIndexComboBox[i];

                    console.log("tabIndexComboBox i=" + i + ", value=" + JSON.stringify(indexObjectExisting));
                }
                console.log("DUMP STOP tabIndexComboBox");
            }
        }


        Button {
            id:idButtonClear
            text:"Clear"
            background: Rectangle{
                anchors.fill: parent
                color: 'white'
            }
            onPressed: {
                tabIndexComboBox = [];
            }
        }
    }

    // Retrieve the data position on the list tabIndexComboBox
    function findPosInArray(iRow, iColumn)
    {
        var posToReturn = -1;

        for(var i=0; i<tabIndexComboBox.length;i++)
        {
            var indexObjectExisting = tabIndexComboBox[i];

            if( (indexObjectExisting._row===iRow) && (indexObjectExisting._column===iColumn) )
            {
                posToReturn = i;
                break;
            }
        }

        console.log("findPosInArray : called with iRow=" + iRow + " and iColumn=" + iColumn + ", returned index=" + posToReturn);

        return posToReturn;
    }

    // Add data position on the list tabIndexComboBox
    function manageIndex(iRow, iColumn, iIndex) {
        var indexObject = {};
        indexObject._row = iRow;
        indexObject._column = iColumn;
        indexObject._selectedIndex = iIndex;

        var indexCb = findPosInArray(iRow, iColumn);
        if(-1 === indexCb)
        {
            tabIndexComboBox.push(indexObject);
            console.log("manageIndex : object non trouve et ajoute index=" + iIndex);
        }
        else
        {
            tabIndexComboBox[indexCb] = indexObject;
            console.log("manageIndex : object trouve et MAJ index=" + iIndex);
        }

        console.log("manageIndex.length : " + tabIndexComboBox.length);
    }

    // Retrieve selected index of the combobox
    function retrieveIndex(iRow, iColumn) {
        var indexToRetrieve = -1;
        var indexCb = findPosInArray(iRow, iColumn);

        if(-1 !== indexCb)
            indexToRetrieve = tabIndexComboBox[indexCb]._selectedIndex;

        return indexToRetrieve;
    }
}
