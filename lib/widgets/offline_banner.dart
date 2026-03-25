import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final offline = context.watch<ConnectivityProvider>().isOffline;
    
    if (!offline) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      color: Colors.redAccent,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            loc.noInternet,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 13, 
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }
}
