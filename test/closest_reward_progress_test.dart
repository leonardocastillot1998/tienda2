import 'package:flutter_test/flutter_test.dart';
import 'package:tienda/services/auth_service.dart';

void main() {
  group('calculateClosestRewardProgress', () {
    test('returns null when there are no rewards', () {
      final result = AuthService.calculateClosestRewardProgress(50, []);

      expect(result, isNull);
    });

    test('calculates progress toward the next reward when none are redeemable', () {
      final result = AuthService.calculateClosestRewardProgress(30, [
        {'title': 'Coffee', 'points': 50},
        {'title': 'Headphones', 'points': 100},
        {'title': 'Weekend Trip', 'points': 200},
      ]);

      expect(result, isNotNull);
      expect(result!['rewardTitle'], 'Coffee');
      expect(result['pointsRequired'], 50);
      expect(result['pointsNeeded'], 20);
      expect(result['progress'], 60.0);
      expect(result['canRedeem'], isFalse);
      expect(result['hasRedeemableReward'], isFalse);
      expect(result['statusLabel'], 'Progreso hacia recompensa');
    });

    test('shows ready to redeem when at least one reward is available', () {
      final result = AuthService.calculateClosestRewardProgress(120, [
        {'title': 'Coffee', 'points': 50},
        {'title': 'Headphones', 'points': 100},
        {'title': 'Weekend Trip', 'points': 200},
      ]);

      expect(result, isNotNull);
      expect(result!['rewardTitle'], 'Headphones');
      expect(result['pointsRequired'], 100);
      expect(result['pointsNeeded'], 0);
      expect(result['progress'], 100.0);
      expect(result['canRedeem'], isTrue);
      expect(result['hasRedeemableReward'], isTrue);
      expect(result['statusLabel'], 'Listo para canjear!');
      expect(result['message'], 'Puedes canjear esta recompensa ahora');
    });
  });

  group('calculateRewardProgress', () {
    test('shows progress percentage for a product not yet redeemable', () {
      final result = AuthService.calculateRewardProgress(30, 100);

      expect(result['progress'], 30.0);
      expect(result['canRedeem'], isFalse);
      expect(result['pointsNeeded'], 70);
      expect(result['statusLabel'], 'Progreso hacia este premio');
      expect(result['message'], 'Te faltan 70 puntos');
    });

    test('shows ready state when product is redeemable', () {
      final result = AuthService.calculateRewardProgress(100, 100);

      expect(result['progress'], 100.0);
      expect(result['canRedeem'], isTrue);
      expect(result['pointsNeeded'], 0);
      expect(result['statusLabel'], 'Listo para canjear!');
      expect(result['message'], 'Puedes canjear este producto ahora');
    });
  });
}
