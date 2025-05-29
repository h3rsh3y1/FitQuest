import 'package:exercise_app/boundary/dashboard_Boundaries/leaderboardTitle.dart';
import 'package:exercise_app/controller/leaderboardServices.dart';
import 'package:flutter/material.dart';

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  List<Map<String, dynamic>> topUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    final users = await LeaderboardService().fetchTopUsers();
    setState(() {
      topUsers = users;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: topUsers.length,
            padding: const EdgeInsets.only(top: 16),
            itemBuilder: (context, index) {
              final user = topUsers[index];
              return LeaderboardTile(
                rank: index + 1,
                name: user['name'],
                points: user['points'],
                level: user['level'],
              );
            },
          );
  }
}
