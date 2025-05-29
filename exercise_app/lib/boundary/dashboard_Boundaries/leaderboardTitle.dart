import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int level;
  final int points;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.level,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    String rankBadge;
    Color avatarColor;

    switch (rank) {
      case 1:
        rankBadge = "🥇";
        avatarColor = const Color(0xFFFFD700);
        break;
      case 2:
        rankBadge = "🥈";
        avatarColor = const Color(0xFFC0C0C0);
        break;
      case 3:
        rankBadge = "🥉";
        avatarColor = const Color(0xFFCD7F32);
        break;
      default:
        rankBadge = "$rank";
        avatarColor = const Color(0xFF2E7D32); // Christmas pine green
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF006400), // Dark forest green
            Color(0xFF00FF7F), // Mint green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF7F).withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Text(
              rankBadge,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$points pts",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Lvl $level",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
