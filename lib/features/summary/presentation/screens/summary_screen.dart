// lib/features/summary/presentation/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:order_link/core/router/app_routes.dart';
import 'package:order_link/features/summary/domain/entities/order_draft.dart';
import 'package:order_link/features/summary/presentation/controllers/order_draft_controller.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  // The order is NOT passed in: the screen reads it from orderDraftProvider.
  // Past orders are shown by OrderDetailScreen instead.
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  // After Confirm the draft becomes null while this page is still sliding
  // away. Keeping the last order stops the page from flashing empty.
  OrderDraft? _lastLiveOrder;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  void _handleRerecord() => context.pushReplacement(AppRoutes.voiceIntake);

  bool _saving = false;

  Future<void> _handleConfirm() async {
    if (_saving) return;
    setState(() => _saving = true);

    // Saves to Firestore (returns right away, even offline) and clears the draft.
    final saved = await ref.read(orderDraftProvider.notifier).confirm();
    if (!mounted) return;

    if (saved) {
      context.go(AppRoutes.dashboard);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save order. Try again.')),
      );
    }
  }

  Future<void> _editItem(OrderDraft order, int index) async {
    final updated = await showModalBottomSheet<OrderDraftItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditItemSheet(item: order.items[index]),
    );
    if (updated == null || !mounted) return;

    ref.read(orderDraftProvider.notifier).updateItem(index, updated);
  }

  Future<void> _editShopName(OrderDraft order) async {
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditShopSheet(current: order.shopName),
    );
    if (name == null || !mounted) return;

    ref.read(orderDraftProvider.notifier).updateShopName(name);
  }

  /// Removes an item, with an Undo in case it was an accidental tap.
  void _removeItem(OrderDraft order, int index) {
    final removed = order.items[index];
    ref.read(orderDraftProvider.notifier).removeItem(index);

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref
                .read(orderDraftProvider.notifier)
                .insertItem(index, removed),
          ),
        ),
      );
  }

  /// Confirm needs at least one item, and every item needs a price.
  bool _canConfirm(OrderDraft? order) =>
      order != null && order.items.isNotEmpty && !_needsPrices(order);

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(orderDraftProvider);
    if (live != null) _lastLiveOrder = live;
    final order = _lastLiveOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: order == null
            ? _buildEmpty()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildShopCard(order),
                    const SizedBox(height: 20),
                    _buildItemsCard(order),
                    const SizedBox(height: 20),
                    _buildTotalBar(order),
                    const SizedBox(height: 24),
                    if (order.items.isEmpty)
                      _buildNoItemsHint()
                    else if (_needsPrices(order))
                      _buildPriceHint(),
                    _buildActions(),
                  ],
                ),
              ),
      ),
    );
  }

  /// The AI only fills in a price when the salesman said one out loud.
  /// An order with a missing price can't be confirmed.
  bool _needsPrices(OrderDraft? order) =>
      order != null && order.items.any((item) => item.unitPrice <= 0);

  Widget _buildPriceHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap the pencil on each item to add its price.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoItemsHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No items left. Tap Re-record to say the order again.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Shown if this route is opened with no order in progress.
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No order in progress',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _handleRerecord,
                    child: const Text('Record an order'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _handleBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Order Summary',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopCard(OrderDraft order) {
    return _SummaryCard(
      label: 'Shop Name',
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, color: Colors.black, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              order.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => _editShopName(order),
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.edit_outlined,
                size: 17,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderDraft order) {
    final items = order.items;

    return _SummaryCard(
      label: 'Items (${items.length})',
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 20, thickness: 0.6),
            _ItemRow(
              index: i,
              item: items[i],
              onEdit: () => _editItem(order, i),
              onDelete: () => _removeItem(order, i),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalBar(OrderDraft order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total Amount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRupees(order.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleRerecord,
            icon: const Icon(Icons.mic_rounded, size: 16),
            label: const Text('Re-record'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: (_saving || !_canConfirm(_lastLiveOrder))
                ? null
                : _handleConfirm,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Confirm Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _SummaryCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final OrderDraftItem item;

  /// Null hides the pencil.
  final VoidCallback? onEdit;

  /// Null hides the trash icon.
  final VoidCallback? onDelete;

  const _ItemRow({
    required this.index,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatQuantity(item.quantity)} ${item.unit} × ${formatRupees(item.unitPrice)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.unitPrice > 0 ? formatRupees(item.lineTotal) : 'Add price',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: item.unitPrice > 0 ? Colors.black : Colors.orange.shade800,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: onEdit,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.edit_outlined,
                size: 17,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
        if (onDelete != null)
          InkWell(
            onTap: onDelete,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Colors.red.shade400,
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom sheet for fixing a shop name the AI or microphone got wrong.
class _EditShopSheet extends StatefulWidget {
  final String current;

  const _EditShopSheet({required this.current});

  @override
  State<_EditShopSheet> createState() => _EditShopSheetState();
}

class _EditShopSheetState extends State<_EditShopSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // "Shop not mentioned" is a placeholder, so start with an empty box.
    _controller = TextEditingController(
      text: widget.current == 'Shop not mentioned' ? '' : widget.current,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().isNotEmpty;

  void _save() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit shop name',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (_isValid) _save();
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Shop name',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditItemSheet extends StatefulWidget {
  final OrderDraftItem item;

  const _EditItemSheet({required this.item});

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: formatQuantity(widget.item.quantity),
    );
    _priceController = TextEditingController(
      // Empty (not "0") when the AI did not hear a price.
      text: widget.item.unitPrice > 0
          ? formatQuantity(widget.item.unitPrice)
          : '',
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double? get _qty => double.tryParse(_qtyController.text);
  double? get _price => double.tryParse(_priceController.text);

  bool get _isValid => (_qty ?? 0) > 0 && (_price ?? 0) > 0;

  void _save() {
    Navigator.pop(
      context,
      widget.item.copyWith(quantity: _qty, unitPrice: _price),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _isValid ? _qty! * _price! : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit ${widget.item.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: _qtyController,
                      label: 'Quantity (${widget.item.unit})',
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _priceController,
                      label: 'Price per ${widget.item.unit}',
                      prefix: '₨ ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Line total',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                    Text(
                      formatRupees(total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? prefix,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(color: Colors.black),
      ),
    );
  }
}
