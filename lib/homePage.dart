import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mbh/model/weightEntry.dart';
import 'package:mbh/weightEntryDialog.dart';
import 'package:mbh/weightListItem.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<WeightEntry> weightEntries = new List();
  ScrollController _listViewScrollController = new ScrollController();
  double _itemExtent = 50.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: _listViewScrollController,
        itemCount: weightEntries.length,
        itemBuilder: (buildContext, index) {
          //calculating difference
          double difference = index == 0
              ? 0.0
              : weightEntries[index].weight - weightEntries[index - 1].weight;
          return new InkWell(
              onTap: () => _editEntry(weightEntries[index]),
              child: new WeightListItem(weightEntries[index], difference));
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _openAddEntryDialog,
        tooltip: 'Add new weight entry',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _addWeightEntry(WeightEntry we) {
    setState(() {
      weightEntries.add(we);
      _listViewScrollController.animateTo(
        weightEntries.length * _itemExtent,
        duration: const Duration(microseconds: 1),
        curve: new ElasticInCurve(0.01),
      );
    });
  }

  _editEntry(WeightEntry weightSave) {
    Navigator
        .of(context)
        .push(
      new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.edit(weightSave);
        },
        fullscreenDialog: true,
      ),
    )
        .then((newSave) {
      if (newSave != null) {
        setState(() => weightEntries[weightEntries.indexOf(weightSave)] = newSave);
      }
    });
  }

  Future _openAddEntryDialog() async {
    WeightEntry we =
    await Navigator.of(context).push(new MaterialPageRoute<WeightEntry>(
        builder: (BuildContext context) {
          return new WeightEntryDialog.add(
              weightEntries.isNotEmpty ? weightEntries.last.weight : 60.0);
        },
        fullscreenDialog: true));
    if (we != null) {
      _addWeightEntry(we);
    }
  }
}