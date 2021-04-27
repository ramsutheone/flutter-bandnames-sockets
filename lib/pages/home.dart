import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/model/band.dart';
import 'package:band_names/services/socket_service.dart';

import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //esta es una lista temporal pero no será la que tome sino la del backend
  List<Band> bands = [
    Band(id: '1', name: 'Cypress Hill', votes: 1),
    Band(id: '2', name: 'The lox', votes: 6),
    Band(id: '3', name: 'Ac Dc', votes: 4),
    Band(id: '4', name: 'Queen', votes: 1),
    Band(id: '5', name: 'Beastie Boys', votes: 2),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('bandasActivas', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bandasActivas');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Nombre de la Banda', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.cloud_done, color: Colors.blue[600])
                  : Icon(Icons.cloud_off, color: Colors.red))
          //? Icon(Icons.phonelink_ring, color: Colors.blue[600])
          //: Icon(Icons.phonelink_erase, color: Colors.red))
        ],
      ),
      body: Column(
        children: [
          _mostrarGrafica(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, i) => _bandTile(bands[i])),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand,
      ),
    );
  }

  Widget _bandTile(Band banda) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': banda.id}),
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Borrar Banda',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(banda.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(banda.name),
        trailing: Text(
          '${banda.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.emit('vote-band', {'id': banda.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    //siempre Importar el de "import from 'dart:io'" y NO el de dart.html"
    if (Platform.isAndroid) {
      //Todo esto sería SOLO para Android
      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Nombre Nueva Banda'),
              content: TextField(
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                    child: Text('Agregar Banda'),
                    elevation: 5,
                    textColor: Colors.blue,
                    onPressed: () => addBandToList(textController.text)),
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('Nombre Nueva Banda'),
            content: CupertinoTextField(controller: textController),
            actions: <Widget>[
              CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Agregar Banda'),
                  onPressed: () => addBandToList(textController.text)),
              CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Cerrar'),
                  onPressed: () => Navigator.pop(context)),
            ],
          );
        });
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      /*
      forma manual
        this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
      */
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _mostrarGrafica() {
    Map<String, double> dataMap = new Map();
    //"Flutter": 5,
    bands.forEach((banda) {
      dataMap.putIfAbsent(banda.name, () => banda.votes.toDouble());
    });
    final List<Color> colorList = [
      Colors.blue[100],
      Colors.blue[300],
      Colors.pink[100],
      Colors.pink[300],
      Colors.yellow[100],
      Colors.yellow[300],
      Colors.green[100],
      Colors.green[300],
    ];

    return Container(
        padding: EdgeInsets.only(top: 15),
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 1000),
          chartLegendSpacing: 35,
          chartRadius: MediaQuery.of(context).size.width / 2.2,
          colorList: colorList,
          chartType: ChartType.ring,
          ringStrokeWidth: 20,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.left,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
        ));
  }
}
