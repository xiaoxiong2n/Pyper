import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

TableView{
    x: 10
    y: 140
    width: 180
    height: 400
    alternatingRowColors: true
    sortIndicatorVisible : false

    function getRow(iface, idx){}

    function getData(iface){
        var idx=0;
        var result;
        mod.clear();
        while (true){
            result = getRow(iface, idx);
            if (result === -1){
                break;
            } else if (result === undefined){
                break;
            } else {
                mod.append({"frameId": parseInt(result[0]),
                           "x": parseFloat(result[1]),
                           "y": parseFloat(result[2]),
                           "centerDist": parseFloat(result[3]),
                           "borderDist": parseFloat(result[4])});
                idx += 1;
            }
        }
    }

    model: ListModel {
        id: mod
        ListElement{ // Necessary to create model with one item at beginnning otherwise all empty (type)
            frameId: 0
            x: 0.0
            y: 0.0
            centerDist: -1.0
            boderDist: -1.0
        }
    }
    Component.onCompleted: {
        getData();
    }

    TableViewColumn{
        role: "frameId"
        title: "Frame"
        width: 60
    }
    TableViewColumn{
        role: "x"
        title: "X"
        width: 60
    }
    TableViewColumn{
        role: "y"
        title: "Y"
        width: 60
    }
    TableViewColumn{
        role: "centerDist"
        title: "to center"
        width: 60
    }
    TableViewColumn{
        role: "borderDist"
        title: "to border"
        width: 60
    }
}
