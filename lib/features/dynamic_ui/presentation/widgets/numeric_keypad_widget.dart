import 'package:flutter/material.dart';

class NumericKeypadWidget extends StatelessWidget {
  final void Function(String key) onKeyPress;

  const NumericKeypadWidget({
    super.key,
    required this.onKeyPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(label: '1', onTap: () => onKeyPress('1')),
            _KeypadButton(label: '2', onTap: () => onKeyPress('2')),
            _KeypadButton(label: '3', onTap: () => onKeyPress('3')),
          ],
        ),
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(label: '4', onTap: () => onKeyPress('4')),
            _KeypadButton(label: '5', onTap: () => onKeyPress('5')),
            _KeypadButton(label: '6', onTap: () => onKeyPress('6')),
          ],
        ),
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(label: '7', onTap: () => onKeyPress('7')),
            _KeypadButton(label: '8', onTap: () => onKeyPress('8')),
            _KeypadButton(label: '9', onTap: () => onKeyPress('9')),
          ],
        ),
        // Row 4: ., 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _KeypadButton(label: '.', onTap: () => onKeyPress('.')),
            _KeypadButton(label: '0', onTap: () => onKeyPress('0')),
            _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () => onKeyPress('back'),
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white24,
          child: Container(
            width: 72,
            height: 56,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, size: 26, color: color ?? Colors.white)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
