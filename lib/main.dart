import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipto/views/voucher_purchase_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _seedFirestoreIfNeeded();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zepto Instant Voucher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A), // Purple Zepto Color
          primary: const Color(0xFF6A1B9A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
      ),
      home: const VoucherPurchaseScreen(voucherId: 'zepto-100'),
    );
  }
}

Future<void> _seedFirestoreIfNeeded() async {
  try {
    final doc = FirebaseFirestore.instance
        .collection('vouchers')
        .doc('zepto-100');
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        "id": "zepto-100",
        "title": "Zepto Instant Voucher",
        "minAmount": 50,
        "maxAmount": 10000,
        "disablePurchase": false,
        "discounts": [
          {"method": "UPI", "percent": 4},
          {"method": "CARD", "percent": 4},
        ],
        "redeemSteps": [
          "Login to Zepto Platform",
          "Click on My profile / Settings",
          "Go to Zepto Cash & Gift Card",
          "Click on Add Card option",
        ],
      });
    }
  } catch (e) {
    debugPrint('Failed to seed firestore: $e');
  }
}
