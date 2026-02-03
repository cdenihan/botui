import 'package:flutter/material.dart';

class SliderInputWidget extends StatefulWidget {
  final String id;
  final double min;
  final double max;
  final double value;
  final String? label;
  final bool showValue;
  final void Function(double) onChanged;

  const SliderInputWidget({
    super.key,
    required this.id,
    required this.min,
    required this.max,
    required this.value,
    this.label,
    this.showValue = true,
    required this.onChanged,
  });

  @override
  State<SliderInputWidget> createState() => _SliderInputWidgetState();
}

class _SliderInputWidgetState extends State<SliderInputWidget> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(SliderInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null || widget.showValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: const TextStyle(fontSize: 16),
                  ),
                if (widget.showValue)
                  Text(
                    _value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: Colors.blue,
            overlayColor: Colors.blue.withOpacity(0.2),
            trackHeight: 8,
          ),
          child: Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
