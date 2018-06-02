import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:mbh/model/weightEntry.dart';
import 'package:image_picker/image_picker.dart';

///
///
///
class WeightEntryDialog extends StatefulWidget {
  final double initialWeight;
  final WeightEntry weighEntryToEdit;

  //
  WeightEntryDialog.add(this.initialWeight) : weighEntryToEdit = null;

  //
  WeightEntryDialog.edit(this.weighEntryToEdit)
      : initialWeight = weighEntryToEdit.weight;

  @override
  WeightEntryDialogState createState() {
    if (weighEntryToEdit != null) {
      return new WeightEntryDialogState(
        weighEntryToEdit.dateTime,
          weighEntryToEdit.weight, 
          weighEntryToEdit.note,
          weighEntryToEdit.image);
    } else {
      return new WeightEntryDialogState(
          new DateTime.now(), initialWeight, null, null);
    }
  }
}

///
///
///
class WeightEntryDialogState extends State<WeightEntryDialog> {
  DateTime _dateTime = new DateTime.now();
  double _weight;
  String _note;
  File _image;
  TextEditingController _textController;

  // Constructor
  WeightEntryDialogState(this._dateTime, this._weight, this._note, this._image);

  // getImage
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  //
  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.weighEntryToEdit == null
          ? const Text("New Location")
          : const Text("Edit Location"),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator
                .of(context)
                .pop(new WeightEntry(_dateTime, _weight, _note, _image));
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController(text: _note);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(context),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Location Title',
              ),
              controller: _textController,
              onChanged: (value) => _note = value,
            ),
          ),
          new ListTile(
            leading: new Icon(Icons.today, color: Colors.grey[500]),
            title: new DateTimeItem(
              dateTime: _dateTime,
              onChanged: (dateTime) => setState(() => _dateTime = dateTime),
            ),
          ),
          new ListTile(
            leading: new Image.asset(
              "assets/scale-bathroom.png",
              color: Colors.grey[500],
              height: 24.0,
              width: 24.0,
            ),
            title: new Text(
              "$_weight kg",
            ),
            onTap: () => _showWeightPicker(context),
          ),
          _image != null
              ? new Image.file(_image, height: 200.0, fit: BoxFit.cover)
              : new Container(),
          new ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              new RaisedButton(
                child: new Text("Mark this Spot"),
                color: Colors.greenAccent,
                onPressed: () {/* Do something here */},
              ),
            ],
          ),
          new ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              new RaisedButton(
                child: new Text("Find this Spot"),
                color: Colors.greenAccent,
                onPressed: () {/* Do something here */},
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }

  _showWeightPicker(BuildContext context) {
    showDialog(
      context: context,
      // next line was 'child:'
      builder: (BuildContext context) => new NumberPickerDialog.decimal(
            minValue: 1,
            maxValue: 150,
            initialDoubleValue: _weight,
            title: new Text("Enter your weight"),
          ),
    ).then((value) {
      if (value != null) {
        setState(() => _weight = value);
      }
    });
  }
}

///
///
///
class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = dateTime == null
            ? new DateTime.now()
            : new DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = dateTime == null
            ? new DateTime.now()
            : new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            onTap: (() => _showDatePicker(context)),
            child: new Padding(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                child: new Text(new DateFormat('EEEE, MMMM d').format(date))),
          ),
        ),
        new InkWell(
          onTap: (() => _showTimePicker(context)),
          child: new Padding(
              padding: new EdgeInsets.symmetric(vertical: 8.0),
              child: new Text('$time')),
        ),
      ],
    );
  }

  Future _showDatePicker(BuildContext context) async {
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date.subtract(const Duration(days: 20000)),
        lastDate: new DateTime.now());

    if (dateTimePicked != null) {
      onChanged(new DateTime(dateTimePicked.year, dateTimePicked.month,
          dateTimePicked.day, time.hour, time.minute));
    }
  }

  Future _showTimePicker(BuildContext context) async {
    TimeOfDay timeOfDay =
        await showTimePicker(context: context, initialTime: time);

    if (timeOfDay != null) {
      onChanged(new DateTime(
          date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute));
    }
  }
}
