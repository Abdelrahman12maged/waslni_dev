import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';

class OfflineConnectivityBanner extends StatefulWidget {
  const OfflineConnectivityBanner({super.key});

  @override
  State<OfflineConnectivityBanner> createState() => _OfflineConnectivityBannerState();
}

class _OfflineConnectivityBannerState extends State<OfflineConnectivityBanner> {
  late StreamSubscription<List<ConnectivityResult>> _sub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final isOffline = results.contains(ConnectivityResult.none);
      if (mounted && isOffline != _isOffline) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.red.shade800,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            S.of(context).noInternetOffline,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
