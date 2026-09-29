import 'package:flutter/material.dart';
import '../../services/location_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _locationState = 'Loading...';
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final state = await _locationService.getCurrentState();
    if (mounted) {
      setState(() {
        _locationState = state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        "Creyo",
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
            const SizedBox(width: 4),
            Text(
              _locationState,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.blueGrey),
          onPressed: () {
            // Handle notification button press
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
