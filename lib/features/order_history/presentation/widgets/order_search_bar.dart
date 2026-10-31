// lib/features/order_history/presentation/widgets/order_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_link/features/order_history/presentation/controllers/order_search_controller.dart';

class OrderSearchBar extends ConsumerStatefulWidget {
  const OrderSearchBar({super.key});

  @override
  ConsumerState<OrderSearchBar> createState() => _OrderSearchBarState();
}

class _OrderSearchBarState extends ConsumerState<OrderSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Start from whatever the controller holds (usually empty).
    _controller = TextEditingController(
      text: ref.read(orderSearchControllerProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(orderSearchControllerProvider.notifier).clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: ref.read(orderSearchControllerProvider.notifier).setQuery,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by shop or item',
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.black54),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: Colors.black54,
                  onPressed: _clear,
                ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
