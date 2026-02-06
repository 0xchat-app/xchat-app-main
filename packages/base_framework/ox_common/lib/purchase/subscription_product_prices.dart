import 'package:flutter/foundation.dart';

/// Cache of subscription product prices by productId.
///
/// Each entry is [ValueNotifier<String?>]: null = not loaded, non-null = localized price string.
/// [getLowestPrice] / [lowestPriceNotifier]: the display price of the cheapest product among those that currently have a price (by rawPrice); null if none.
class SubscriptionProductPrices {
  SubscriptionProductPrices._();

  static final SubscriptionProductPrices instance = SubscriptionProductPrices._();

  final Map<String, ValueNotifier<String?>> _cache = {};
  final Map<String, double> _rawPrices = {};

  /// Notifier for the lowest price (display string) among products that have a price. Updated when any price is set/cleared.
  final ValueNotifier<String?> lowestPriceNotifier = ValueNotifier<String?>(null);

  /// Returns [ValueNotifier<String?>] for [productId]. Creates one (value null) if absent.
  ValueNotifier<String?> getNotifier(String productId) {
    return _cache.putIfAbsent(productId, () => ValueNotifier<String?>(null));
  }

  /// Sets price and rawPrice for [productId]. Call from PurchaseManager when refreshing. Updates [lowestPriceNotifier].
  void setPrice(String productId, String? priceString, double? rawPrice) {
    getNotifier(productId).value = priceString;
    if (rawPrice != null) {
      _rawPrices[productId] = rawPrice;
    } else {
      _rawPrices.remove(productId);
    }
    _updateLowestPrice();
  }

  /// Called by PurchaseManager when preload completes. Updates notifiers and rawPrices. Updates [lowestPriceNotifier].
  void updateFromMap(Map<String, String> idToPrice, [Map<String, double>? idToRawPrice]) {
    if (idToPrice.isEmpty) {
      clear();
      return;
    }
    for (final e in idToPrice.entries) {
      getNotifier(e.key).value = e.value;
      final raw = idToRawPrice?[e.key];
      if (raw != null) {
        _rawPrices[e.key] = raw;
      } else {
        _rawPrices.remove(e.key);
      }
    }
    _updateLowestPrice();
  }

  void _updateLowestPrice() {
    String? minId;
    double minRaw = double.infinity;
    for (final id in _rawPrices.keys) {
      final p = getNotifier(id).value;
      if (p == null || p.isEmpty) continue;
      final r = _rawPrices[id]!;
      if (r < minRaw) {
        minRaw = r;
        minId = id;
      }
    }
    lowestPriceNotifier.value = minId != null ? getNotifier(minId).value : null;
  }

  /// Returns current lowest price (display string) among products that have a price; null if none. See [lowestPriceNotifier] for reactive UI.
  String? getLowestPrice() => lowestPriceNotifier.value;

  /// Called by PurchaseManager on dispose (e.g. logout). Clears all notifier values and [lowestPriceNotifier].
  void clear() {
    for (final n in _cache.values) {
      n.value = null;
    }
    _rawPrices.clear();
    lowestPriceNotifier.value = null;
  }
}
