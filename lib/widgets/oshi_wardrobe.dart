import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// G検定の資格ID（衣装・テーマ用）。
const UkalabCert kGKenteiCert = UkalabCert.gKentei;

/// main.dart で実体を差し込む。
final outfitServiceProvider = Provider<OutfitService>(
  (ref) => OutfitService(store: InMemoryOutfitStore()),
);

/// 着ている衣装。着替えると画面が更新される。
class EquippedOutfitNotifier extends Notifier<Outfit?> {
  @override
  Outfit? build() {
    final id = ref.read(outfitServiceProvider).equippedId;
    return id == null ? null : OutfitCatalog.byId(id);
  }

  /// 着る。着られなければ false。
  Future<bool> equip(String id, {ExamPhase examPhase = ExamPhase.none}) async {
    final owned = ref.read(coinServiceProvider).ownedItemIds;
    final ok = await ref
        .read(outfitServiceProvider)
        .equip(id, purchasedIds: owned, examPhase: examPhase);
    if (ok) state = OutfitCatalog.byId(id);
    return ok;
  }
}

final equippedOutfitProvider =
    NotifierProvider<EquippedOutfitNotifier, Outfit?>(EquippedOutfitNotifier.new);

/// 着られない理由。着られるときは空。
String outfitLockedReason(OutfitAvailability a, {int price = 0}) {
  switch (a) {
    case OutfitAvailability.available:
      return '';
    case OutfitAvailability.notPurchased:
      return '$priceコインで購入できます';
    case OutfitAvailability.notPassed:
      return '合格したときに解放されます';
    case OutfitAvailability.noExamDate:
      return '試験日を設定すると着られます';
    case OutfitAvailability.notReady:
      return '準備完了の目標を達成すると解放されます';
  }
}

/// 衣装のショップ・着替え画面。コインは学習の成長でだけ増える（課金・広告では増えない）。
class OshiWardrobeView extends ConsumerWidget {
  const OshiWardrobeView({super.key, this.examPhase = ExamPhase.none});

  final ExamPhase examPhase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coin = ref.watch(coinProvider);
    final equipped = ref.watch(equippedOutfitProvider);
    final outfits = OutfitCatalog.forCert(kGKenteiCert);
    final outfitService = ref.read(outfitServiceProvider);
    final theme = Theme.of(context);

    Future<void> buy(Outfit o) async {
      final r = await ref.read(coinProvider.notifier).purchase(o.id);
      if (!context.mounted) return;
      final msg = switch (r) {
        PurchaseResult.purchased => '${o.name}を購入しました',
        PurchaseResult.insufficient => 'コインが足りません。学習すると貯まります',
        PurchaseResult.alreadyOwned => 'すでに持っています',
        PurchaseResult.unknownItem => '購入できません',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    Future<void> wear(Outfit o) async {
      final ok = await ref
          .read(equippedOutfitProvider.notifier)
          .equip(o.id, examPhase: examPhase);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('この衣装は今は着られません')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('着替え・ショップ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: MascotWidget(
                outfit: equipped,
                examPhase: examPhase,
                size: 140,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('学習コイン ${coin.balance}', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'コインは学習で貯まります。衣装は見た目だけで、学習の内容には影響しません。',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            for (final o in outfits) ...[
              _OutfitTile(
                outfit: o,
                availability: outfitService.availability(
                  o,
                  purchasedIds: coin.owned,
                  examPhase: examPhase,
                ),
                wearing: equipped?.id == o.id,
                onBuy: () => buy(o),
                onWear: () => wear(o),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutfitTile extends StatelessWidget {
  const _OutfitTile({
    required this.outfit,
    required this.availability,
    required this.wearing,
    required this.onBuy,
    required this.onWear,
  });

  final Outfit outfit;
  final OutfitAvailability availability;
  final bool wearing;
  final VoidCallback onBuy;
  final VoidCallback onWear;

  @override
  Widget build(BuildContext context) {
    final available = availability == OutfitAvailability.available;
    final Widget trailing;
    if (wearing) {
      trailing = const Icon(Icons.check_circle);
    } else if (available) {
      trailing = OutlinedButton(onPressed: onWear, child: const Text('着る'));
    } else if (availability == OutfitAvailability.notPurchased) {
      trailing = FilledButton(onPressed: onBuy, child: Text('${outfit.price}コイン'));
    } else {
      trailing = const Icon(Icons.lock_outline);
    }
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(outfit.name),
        subtitle: Text(
          wearing
              ? '着ています'
              : available
                  ? '着られます'
                  : outfitLockedReason(availability, price: outfit.price),
        ),
        trailing: trailing,
      ),
    );
  }
}
