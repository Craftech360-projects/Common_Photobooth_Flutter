import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';

class VirtualKeyboard extends StatefulWidget {
  final TextEditingController? controller;
  final VoidCallback? onSubmit;
  final bool showSubmitButton;
  final String submitButtonText;
  final double keyHeight;
  final double keySpacing;
  final bool isVisible;
  final VoidCallback? onClose;

  const VirtualKeyboard({
    super.key,
    this.controller,
    this.onSubmit,
    this.showSubmitButton = true,
    this.submitButtonText = 'Done',
    this.keyHeight = 50.0,
    this.keySpacing = 4.0,
    this.isVisible = true,
    this.onClose,
  });

  @override
  State<VirtualKeyboard> createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isShiftPressed = false;
  bool _capsLock = false;

  final List<List<String>> _keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  final Map<String, String> _shiftMap = {
    '1': '!',
    '2': '@',
    '3': '#',
    '4': '\$',
    '5': '%',
    '6': '.',
    '7': '&',
    '8': '*',
    '9': '(',
    '0': ')',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(VirtualKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String key) {
    if (widget.controller == null) return;

    final controller = widget.controller!;
    final currentText = controller.text;
    final selection = controller.selection;

    if (key == 'backspace') {
      if (selection.start > 0) {
        final newText = currentText.substring(0, selection.start - 1) +
            currentText.substring(selection.end);
        controller.text = newText;
        controller.selection = TextSelection.collapsed(
          offset: selection.start - 1,
        );
      }
    } else if (key == 'space') {
      final newText =
          '${currentText.substring(0, selection.start)} ${currentText.substring(selection.end)}';
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start + 1,
      );
    } else if (key == 'shift') {
      setState(() {
        _isShiftPressed = !_isShiftPressed;
      });
    } else if (key == 'caps') {
      setState(() {
        _capsLock = !_capsLock;
      });
    } else {
      String keyToInsert = key;

      // Handle shift/caps lock
      if (_shiftMap.containsKey(key) && (_isShiftPressed || _capsLock)) {
        keyToInsert = _shiftMap[key]!;
      } else if (key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
        keyToInsert = (_isShiftPressed || _capsLock)
            ? key.toUpperCase()
            : key.toLowerCase();
      }

      final newText =
          '${currentText.substring(0, selection.start)}$keyToInsert${currentText.substring(selection.end)}';
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start + keyToInsert.length,
      );

      // Reset shift after key press (but not caps lock)
      if (_isShiftPressed && !_capsLock) {
        setState(() {
          _isShiftPressed = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkGrey.withValues(alpha: 0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (widget.onClose != null)
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.greyDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.keyboard_hide,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 16),

                // Keyboard rows
                ..._keyboardLayout.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final row = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: widget.keySpacing),
                    child: _buildKeyboardRow(row, rowIndex),
                  );
                }),

                // Bottom row with special keys
                Padding(
                  padding: EdgeInsets.only(bottom: widget.keySpacing),
                  child: _buildBottomRow(),
                ),

                // Submit button
                if (widget.showSubmitButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: widget.keyHeight,
                      child: ElevatedButton(
                        onPressed: widget.onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.submitButtonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboardRow(List<String> keys, int rowIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.keySpacing / 2),
            child: _buildKey(key),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Caps Lock
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.keySpacing / 2),
            child: _buildSpecialKey('caps', 'CAPS', _capsLock),
          ),
        ),
        // Shift
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.keySpacing / 2),
            child: _buildSpecialKey('shift', 'SHIFT', _isShiftPressed),
          ),
        ),
        // Space
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.keySpacing / 2),
            child: _buildSpecialKey('space', 'SPACE', false),
          ),
        ),
        // Backspace
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.keySpacing / 2),
            child: _buildSpecialKey('backspace', '⌫', false),
          ),
        ),
      ],
    );
  }

  Widget _buildKey(String key) {
    String displayKey = key;
    if (_shiftMap.containsKey(key) && (_isShiftPressed || _capsLock)) {
      displayKey = _shiftMap[key]!;
    } else if (key.length == 1 && key.toLowerCase() != key.toUpperCase()) {
      displayKey = (_isShiftPressed || _capsLock)
          ? key.toUpperCase()
          : key.toLowerCase();
    }

    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        height: widget.keyHeight,
        decoration: BoxDecoration(
          color: AppColors.greyDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            displayKey,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String key, String label, bool isPressed) {
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        height: widget.keyHeight,
        decoration: BoxDecoration(
          color: isPressed ? AppColors.blue : AppColors.greyDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isPressed ? AppColors.white : AppColors.lightGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
