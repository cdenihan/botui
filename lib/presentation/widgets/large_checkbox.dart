import 'package:flutter/material.dart';

class LargeCheckbox extends StatefulWidget {
  /// Indicates whether the checkbox is initially checked.
  final bool initialValue;

  /// Callback function to notify when the checkbox state changes.
  final ValueChanged<bool> onChanged;

  /// Optional label displayed next to the checkbox.
  final String? label;

  /// Size of the checkbox in pixels.
  final double size;

  /// Color of the checkbox when checked.
  final Color activeColor;

  /// Color of the checkmark icon.
  final Color checkColor;

  /// Color of the checkbox border when unchecked.
  final Color borderColor;

  /// Duration of the animation when toggling.
  final Duration animationDuration;

  const LargeCheckbox({
    Key? key,
    this.initialValue = false,
    required this.onChanged,
    this.label,
    this.size = 60.0, // Default size
    this.activeColor = Colors.blue,
    this.checkColor = Colors.white,
    this.borderColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _LargeCheckboxState createState() => _LargeCheckboxState();
}

class _LargeCheckboxState extends State<LargeCheckbox>
    with SingleTickerProviderStateMixin {
  late bool _isChecked;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialValue;

    // Initialize animation controller for scaling effect
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Define a Tween for scaling from 1.0 to 1.2
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCheckbox() {
    setState(() {
      _isChecked = !_isChecked;
    });

    // Trigger the scaling animation
    if (_isChecked) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    } else {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    // Notify external widgets
    widget.onChanged(_isChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label ?? 'Checkbox',
      checked: _isChecked,
      button: true,
      child: GestureDetector(
        onTap: _toggleCheckbox,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Checkbox Container
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color:
                  _isChecked ? widget.activeColor : Colors.transparent,
                  border: Border.all(
                    color: _isChecked ? widget.activeColor : widget.borderColor,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: _isChecked
                    ? Icon(
                  Icons.check,
                  size: widget.size * 0.6,
                  color: widget.checkColor,
                )
                    : null,
              ),
            ),
            if (widget.label != null) ...[
              SizedBox(width: widget.size * 0.2),
              Flexible(
                child: Text(
                  widget.label!,
                  style: TextStyle(fontSize: widget.size * 0.3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}