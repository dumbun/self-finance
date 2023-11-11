import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputDatePicker extends StatefulWidget {
  const InputDatePicker({
    super.key,
    required this.controller,
    required this.labelText,
    this.onChanged,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
  });
  final TextEditingController controller;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final String labelText;
  final Function? onChanged;
  @override
  State<InputDatePicker> createState() => _InputDatePickerState();
}

class _InputDatePickerState extends State<InputDatePicker> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid value';
        }
        return null;
      },
      onSaved: widget.onChanged as void Function(String?)?,
      onChanged: widget.onChanged as void Function(String)?,
      keyboardType: TextInputType.datetime,
      controller: widget.controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        // icon: const Icon(Icons.calendar_today), //icon of text field
        labelText: widget.labelText, //label text of field
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.initialDate,
          currentDate: DateTime.now(),
          keyboardType: TextInputType.datetime,
          initialDatePickerMode: DatePickerMode.year,
          firstDate: widget.firstDate,
          //DateTime.now() - not to allow to choose before today.
          lastDate: widget.lastDate,
        );
        if (pickedDate != null) {
          //pickedDate output format => 2021-03-10 00:00:00.000
          String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
          //formatted date output using intl package =>  2021-03-16
          setState(() {
            widget.controller.text = formattedDate; //set output date to InputTextField value.
          });
        } else {}
      },
    );
  }
}
