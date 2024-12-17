import 'package:flutter/material.dart';

class LargeDropdown extends StatefulWidget {
  /// List of string options to display in the dropdown.
  final List<String> options;

  /// The initially selected value.
  final String? initialSelected;

  /// Callback function to notify parent widgets of selection changes.
  final ValueChanged<String> onChanged;

  /// Optional hint text when no value is selected.
  final String? hint;

  /// Optional label text displayed above the dropdown.
  final String? label;

  /// Font size for the dropdown items and texts.
  final double fontSize;

  /// Height of the dropdown button.
  final double height;

  /// Width of the dropdown button.
  final double width;

  /// Background color of the dropdown button.
  final Color backgroundColor;

  /// Text color of the selected value.
  final Color textColor;

  /// Border color of the dropdown button.
  final Color borderColor;

  const LargeDropdown({
    Key? key,
    required this.options,
    this.initialSelected,
    required this.onChanged,
    this.hint,
    this.label,
    this.fontSize = 18.0,
    this.height = 60.0,
    this.width = double.infinity,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.borderColor = Colors.grey,
  }) : super(key: key);

  @override
  _LargeDropdownState createState() => _LargeDropdownState();
}

class _LargeDropdownState extends State<LargeDropdown> {
  String? _currentSelected;

  @override
  void initState() {
    super.initState();
    // Initialize the selected value. If initialSelected is not in options, default to the first option.
    if (widget.initialSelected != null &&
        widget.options.contains(widget.initialSelected)) {
      _currentSelected = widget.initialSelected;
    } else if (widget.options.isNotEmpty) {
      _currentSelected = widget.options[0];
    } else {
      _currentSelected = null;
    }
  }

  @override
  void didUpdateWidget(covariant LargeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the options list changes and the current selected is no longer valid, update it.
    if (!widget.options.contains(_currentSelected)) {
      if (widget.initialSelected != null &&
          widget.options.contains(widget.initialSelected)) {
        _currentSelected = widget.initialSelected;
      } else if (widget.options.isNotEmpty) {
        _currentSelected = widget.options[0];
      } else {
        _currentSelected = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle the case where options list is empty
    if (widget.options.isEmpty) {
      return Text(
        'No options available',
        style: TextStyle(fontSize: widget.fontSize, color: widget.textColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.bold,
              color: widget.textColor,
            ),
          ),
          SizedBox(height: 8.0),
        ],
        Container(
          height: widget.height,
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(color: widget.borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _currentSelected,
              hint: widget.hint != null
                  ? Text(
                widget.hint!,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Colors.grey,
                ),
              )
                  : null,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 32.0,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: widget.textColor,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentSelected = newValue;
                  });
                  widget.onChanged(newValue);
                }
              },
              items: widget.options
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: widget.fontSize),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
