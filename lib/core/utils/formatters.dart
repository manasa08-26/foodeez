import 'package:intl/intl.dart';

class AppFormatters {
  static final _currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final _timeFmt = DateFormat('hh:mm a');

  static String currency(num amount) => _currencyFmt.format(amount);
  static String date(DateTime dt) => _dateFmt.format(dt);
  static String dateTime(DateTime dt) => _dateTimeFmt.format(dt);
  static String time(DateTime dt) => _timeFmt.format(dt);

  static String orderStatus(String status) {
    return switch (status.toUpperCase()) {
      'PLACED' => 'Placed',
      'CONFIRMED' => 'Confirmed',
      'ACCEPTED' => 'Accepted',
      'PREPARING' => 'Preparing',
      'READY' => 'Ready',
      'READY_FOR_PICKUP' => 'Ready for Pickup',
      'OUT_FOR_DELIVERY' => 'Out for Delivery',
      'DELIVERED' => 'Delivered',
      'CANCELLED' => 'Cancelled',
      _ => status,
    };
  }

  static String paymentMethod(String method) {
    return switch (method.toUpperCase()) {
      'COD' => 'Cash on Delivery',
      'WALLET' => 'Wallet',
      'CARD' => 'Card',
      'UPI' => 'UPI',
      'NET_BANKING' => 'Net Banking',
      _ => method,
    };
  }
}
