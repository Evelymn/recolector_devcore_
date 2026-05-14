import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const CustomAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.recycling, color: Colors.green),
          const SizedBox(width: 8),
          const Text(
            "EcoRecolector",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const Spacer(),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  userName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Text(userName, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
