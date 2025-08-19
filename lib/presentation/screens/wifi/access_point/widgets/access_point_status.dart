
import 'package:flutter/material.dart';

class AccessPointStatus extends StatelessWidget {
  final bool isStarted;
  final String ssid;

  const AccessPointStatus({
    super.key,
    required this.isStarted,
    required this.ssid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isStarted ? Colors.green[900] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStarted ? Colors.green[400]! : Colors.grey[600]!,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isStarted ? Icons.router : Icons.router_outlined,
                color: isStarted ? Colors.green[300] : Colors.grey[400],
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                isStarted ? 'Hotspot Active' : 'Hotspot Inactive',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isStarted ? Colors.green[300] : Colors.grey[300],
                ),
              ),
            ],
          ),
          if (isStarted) ...[
            const SizedBox(height: 12),
            Text(
              'Network: $ssid',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'IP Address: 192.168.4.1',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
