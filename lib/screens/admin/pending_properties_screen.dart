import 'package:flutter/material.dart';
import 'package:landeed/screens/admin/property_verification_screen.dart';

class PendingPropertiesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> pendingProperties;
  final VoidCallback onVerificationComplete;

  const PendingPropertiesScreen({
    Key? key,
    required this.pendingProperties,
    required this.onVerificationComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Properties'),
      ),
      body: pendingProperties.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No pending properties',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pendingProperties.length,
              itemBuilder: (context, index) {
                final property = pendingProperties[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      property['title'] ?? 'Untitled Property',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(property['location'] ?? 'No location'),
                        if (property['price'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Price: \$${property['price']}'),
                        ],
                        if (property['type'] != null) ...[
                          const SizedBox(height: 4),
                          Text('Type: ${property['type']}'),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyVerificationScreen(
                            property: property,
                            onVerificationComplete: onVerificationComplete,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
} 