// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current search text. Auto-disposes when the screen is gone,
/// so the search resets itself next time the user opens History.

@ProviderFor(OrderSearchController)
final orderSearchControllerProvider = OrderSearchControllerProvider._();

/// Holds the current search text. Auto-disposes when the screen is gone,
/// so the search resets itself next time the user opens History.
final class OrderSearchControllerProvider
    extends $NotifierProvider<OrderSearchController, String> {
  /// Holds the current search text. Auto-disposes when the screen is gone,
  /// so the search resets itself next time the user opens History.
  OrderSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderSearchControllerHash();

  @$internal
  @override
  OrderSearchController create() => OrderSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$orderSearchControllerHash() =>
    r'2f04a932f36205ca8774ea3efe8114fdb2a252d5';

/// Holds the current search text. Auto-disposes when the screen is gone,
/// so the search resets itself next time the user opens History.

abstract class _$OrderSearchController extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Orders after applying the search. Rebuilds when either the saved
/// orders or the query changes, so newly confirmed orders still show up live.

@ProviderFor(filteredOrders)
final filteredOrdersProvider = FilteredOrdersProvider._();

/// Orders after applying the search. Rebuilds when either the saved
/// orders or the query changes, so newly confirmed orders still show up live.

final class FilteredOrdersProvider
    extends
        $FunctionalProvider<
          List<SavedOrder>,
          List<SavedOrder>,
          List<SavedOrder>
        >
    with $Provider<List<SavedOrder>> {
  /// Orders after applying the search. Rebuilds when either the saved
  /// orders or the query changes, so newly confirmed orders still show up live.
  FilteredOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredOrdersHash();

  @$internal
  @override
  $ProviderElement<List<SavedOrder>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SavedOrder> create(Ref ref) {
    return filteredOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SavedOrder> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SavedOrder>>(value),
    );
  }
}

String _$filteredOrdersHash() => r'dcfe029455840a20d96632c8460227c2e9ba82f2';
