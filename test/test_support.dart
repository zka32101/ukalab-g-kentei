import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テスト用の広告バックエンド。何も表示せず、常に準備済みとして振る舞う。
class FakeAdsBackend implements AdsBackend {
  @override
  Future<bool> initialize(AdConfig config) async => true;

  @override
  Future<void> preloadInterstitial() async {}

  @override
  bool get isInterstitialReady => true;

  @override
  Future<bool> showInterstitial() async => true;

  @override
  Future<bool> showRewarded() async => true;

  @override
  Widget buildBanner(BannerPlacement placement) => const SizedBox.shrink();
}

const _testAdUnitIds = AdUnitIds(banner: 'test', interstitial: 'test', rewarded: 'test');

/// テスト用の [AdGate]。[FakeAdsBackend] を使い、SDK初期化や実際の広告表示を行わない。
Future<AdGate> testAdGate() async {
  SharedPreferences.setMockInitialValues({});
  return AdGate.init(
    config: const AdConfig(unitIds: _testAdUnitIds),
    adsHidden: () => false,
    backend: FakeAdsBackend(),
  );
}
