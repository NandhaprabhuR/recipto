import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipto/models/voucher_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class VoucherRepository {
  Stream<VoucherModel?> watchVoucher(String voucherId);
}

class FirebaseVoucherRepository implements VoucherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<VoucherModel?> watchVoucher(String voucherId) {
    return _firestore.collection('vouchers').doc(voucherId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return VoucherModel.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}

final voucherRepositoryProvider = Provider<VoucherRepository>((ref) {
  return FirebaseVoucherRepository();
});
