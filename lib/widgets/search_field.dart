import 'dart:async';

import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String hint;
  final Duration debounce;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    this.hint = 'Ara...',
    this.debounce = const Duration(milliseconds: 300),
    required this.onChanged,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _ctrl = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _handleChanged(String v) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(v));
    setState(() {});
  }

  void _clear() {
    _ctrl.clear();
    _timer?.cancel();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: _handleChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _ctrl.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clear,
              ),
        isDense: true,
      ),
    );
  }
}
