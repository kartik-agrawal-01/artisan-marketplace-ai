import 'package:artisans/screens/home/modules/analytics_card.dart';
import 'package:artisans/screens/home/modules/communitycorner_card.dart';
import 'package:artisans/screens/home/modules/post_card.dart';
import 'package:flutter/material.dart';

import '../overall/appbar.dart';
import '../overall/drawer.dart';
import 'modules/learning_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
            PostCard(),
              SizedBox(height: 16),
              AnalyticsCardWidget(),
              SizedBox(height: 16),
              LearningSupportCard(),
              SizedBox(height: 16),
              const SizedBox(height: 16),
              CommunityCornerCard(),
              SizedBox(height: 16),
            ],
          ),
        ),
      )
    );
  }
}
