import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        CallItem(
          imageUrl: 'https://via.placeholder.com/150',
          name: 'John Doe',
          time: 'Today, 10:00 AM',
          callType: CallType.incoming,
        ),
        CallItem(
          imageUrl: 'https://via.placeholder.com/150',
          name: 'Jane Smith',
          time: 'Yesterday, 4:30 PM',
          callType: CallType.outgoing,
        ),
        CallItem(
          imageUrl: 'https://via.placeholder.com/150',
          name: 'Alex Johnson',
          time: '2 days ago, 3:00 PM',
          callType: CallType.missed,
        ),
        // Add more CallItem widgets as needed
      ],
    );
  }
}

enum CallType { incoming, outgoing, missed }

class CallItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String time;
  final CallType callType;

  const CallItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.time,
    required this.callType,
  });

  @override
  Widget build(BuildContext context) {
    IconData callIcon;
    Color callIconColor;

    switch (callType) {
      case CallType.incoming:
        callIcon = Icons.call_received;
        callIconColor = Colors.green;
        break;
      case CallType.outgoing:
        callIcon = Icons.call_made;
        callIconColor = Colors.blue;
        break;
      case CallType.missed:
        callIcon = Icons.call_missed;
        callIconColor = Colors.red;
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(name),
      subtitle: Row(
        children: [
          Icon(callIcon, color: callIconColor, size: 16),
          const SizedBox(width: 5),
          Text(time),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, color: Colors.green),
        onPressed: () {
          // Add call functionality here
        },
      ),
    );
  }
}
