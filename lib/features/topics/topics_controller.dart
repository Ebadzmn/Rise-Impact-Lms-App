import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

class TopicModel {
  final String title;
  final IconData icon;

  TopicModel({required this.title, required this.icon});
}

class TopicsController extends GetxController {
  final topics = <TopicModel>[
    TopicModel(title: 'Credit\nManagement', icon: Icons.attach_money),
    TopicModel(
      title: 'Business\nBuilding',
      icon: Icons.business_center_outlined,
    ),
    TopicModel(title: 'Asset\nManagement', icon: Icons.pie_chart_outline),
    TopicModel(title: 'Smart\nDecisions', icon: Icons.psychology_outlined),
    TopicModel(title: 'Emotional\nIntelligence', icon: Icons.favorite_border),
  ];

  final selectedTopics = <int>[].obs;

  void toggleTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
  }

  void continueToHome() {
    // Navigate to home logic
    AppRouter.router.go(AppRoutes.home);
  }
}
