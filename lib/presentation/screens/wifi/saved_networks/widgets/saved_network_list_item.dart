import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/domain/entities/saved_network.dart';
import 'package:stpvelox/domain/entities/wifi_credentials.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/saved_networks/saved_networks_event.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/client/wifi_client_event.dart';

class SavedNetworkListItem extends StatefulWidget {
  final SavedNetwork network;

  const SavedNetworkListItem({super.key, required this.network});

  @override
  State<SavedNetworkListItem> createState() => _SavedNetworkListItemState();
}

class _SavedNetworkListItemState extends State<SavedNetworkListItem> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          widget.network.ssid,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last connected: ${_formatDateTime(widget.network.lastConnected)}',
              style: const TextStyle(color: Colors.grey),
            ),
            if (widget.network.credentials is PersonalCredentials) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Password: ${_getPasswordText()}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ] else if (widget.network.credentials is EnterpriseCredentials) ...[
              const SizedBox(height: 4),
              const Text(
                'Enterprise Network',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        leading: Icon(
          Icons.bookmark,
          color: widget.network.autoConnect ? Colors.green : Colors.grey,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<WifiClientBloc>()
                      .add(ConnectToNetworkEvent(widget.network.ssid, widget.network.encryptionType, widget.network.credentials));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.wifi, size: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showRemoveDialog(context, widget.network.ssid);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.delete, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  String _getPasswordText() {
    if (widget.network.credentials is PersonalCredentials) {
      final creds = widget.network.credentials as PersonalCredentials;
      return _showPassword ? creds.password : '••••••••';
    }
    return '';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showRemoveDialog(BuildContext context, String ssid) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Network'),
          content: Text('Remove "$ssid" from saved networks?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SavedNetworksBloc>().add(RemoveSavedNetworkEvent(ssid));
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}