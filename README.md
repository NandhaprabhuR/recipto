

A Flutter application implementing the Zepto Instant Voucher purchase flow.



State Management & Flow (Repository → State → UI):


This project uses **Riverpod** for reactive state management following a strict unidirectional data flow. 
- **Repository:** `lib/repositories/voucher_repository.dart` creates a real-time `Stream` pipe directly to Cloud Firestore.
- **State:** `VoucherController` (a Riverpod `Notifier`) watches the Repository stream, crunches calculations, and holds the active `VoucherState`.
- **UI:** The `VoucherPurchaseScreen` acts as a `ConsumerWidget` that listens to the Controller and rebuilds immediately when the State updates.



Pay Button Enable/Disable Logic :


The `StickyPayButton` state is determined by a reactive boolean flag `isDisabled` calculated locally inside the controller. The pay button is **disabled** if any of the following three conditions are met:
1. `disablePurchase` flag from the Firebase Database evaluates to `true`.
2. The user's typed amount is outside the `minAmount` and `maxAmount` bounds.
3. The final `youPay` amount computes to `0` or less.
