import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/custom_app_bar.dart';
import 'progress_controller.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Progress & Achievements',
          showBackButton: true,
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF2C3E50),
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Tab Switcher
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.switchTab(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? const Color(0xFF6A7554)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: controller.selectedTab.value == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  color: controller.selectedTab.value == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    color: controller.selectedTab.value == 0
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.switchTab(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? const Color(0xFF6A7554)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: controller.selectedTab.value == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  color: controller.selectedTab.value == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Achievements',
                                  style: TextStyle(
                                    color: controller.selectedTab.value == 1
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 32),

              // 4. Tab Content
              Obx(
                () => controller.selectedTab.value == 0
                    ? _buildProgressTab()
                    : _buildAchievementsTab(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6A7554), // Dark Green
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Overall',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '72%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Completed',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 100, // Same height
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE09F3E), // Mustard/Gold
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Points',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Earned',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 100, // Same height
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5722), // Orange
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Streak',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Days',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return Column(
      children: [
        // Progress by Topic
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.donut_large, color: Color(0xFF6A7554), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Progress by Topic',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                icon: Icons.attach_money,
                color: const Color(0xFFD4F8E8),
                iconColor: const Color(0xFF2ECC71),
                title: 'Credit',
                percentage: 0.85,
                progressColor: const Color(0xFFE09F3E),
              ),
              _buildProgressItem(
                icon: Icons.business_center_outlined,
                color: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF2196F3),
                title: 'Business',
                percentage: 0.65,
                progressColor: const Color(0xFFE09F3E),
              ),
              _buildProgressItem(
                icon: Icons.psychology_outlined,
                color: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                title: 'Logic',
                percentage: 0.40,
                progressColor: const Color(0xFFE09F3E),
              ),
              _buildProgressItem(
                icon: Icons.favorite_border,
                color: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFE91E63),
                title: 'EQ',
                percentage: 0.25,
                progressColor: const Color(0xFFE09F3E),
                bottomPadding: 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 30-Day Streak Calendar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF576045),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '30-Day Streak Calendar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Calendar Grid (7 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  // Make days 5-11 active (green) as per image active state
                  final isActive = day >= 5 && day <= 11;
                  return Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF6A7554)
                          : const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Recent Quiz Results
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Quiz Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFEEEEEE)),
              _buildQuizResultItem(
                title: 'Credit Basics Quiz',
                subtitle: 'Credit Mastery • 2024-02-03',
                score: '90%',
              ),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              _buildQuizResultItem(
                title: 'Business Planning Quiz',
                subtitle: 'Business 101 • 2024-02-01',
                score: '85%',
                scoreColor: Colors.blue,
              ),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              _buildQuizResultItem(
                title: 'Decision Making Quiz',
                subtitle: 'Smart Decisions • 2024-01-30',
                score: '100%',
                scoreColor: const Color(0xFF00C853),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Points Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD88B2F), Color(0xFFC17A26)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC17A26).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.emoji_events_outlined, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text(
                'Total Points',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '3 of 8 badges unlocked',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Badges Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6, // Adjust based on content height
          clipBehavior: Clip.none,
          children: [
            _buildBadgeCard(
              icon: Icons.auto_fix_high, // Wizard-like
              iconColor: Colors.purple,
              iconBgColor: Colors.purple.shade50,
              title: 'Credit\nWizard',
              description: 'Completed Credit Mastery course',
              rarity: 'common',
              date: 'Unlocked\n2024-01-15',
              isUnlocked: true,
            ),
            _buildBadgeCard(
              icon: Icons.local_fire_department, // Flame
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.shade50,
              title: 'Week\nWarrior',
              description: 'Maintained a 7-day streak',
              rarity: 'rare',
              date: 'Unlocked\n2024-02-01',
              isUnlocked: true,
            ),
            _buildBadgeCard(
              icon: Icons.track_changes, // Target
              iconColor: Colors.red,
              iconBgColor: Colors.red.shade50,
              title: 'Quiz\nMaster',
              description: 'Scored 100% on 3 quizzes',
              rarity: 'rare',
              date: 'Unlocked\n2024-01-28',
              isUnlocked: true,
            ),
            _buildBadgeCard(
              icon: Icons.lock,
              iconColor: Colors.grey,
              iconBgColor: Colors.grey.shade100,
              title: 'Early\nBird',
              description: 'Complete 5 lessons before 9 AM',
              rarity: 'uncommon',
              date: 'Locked',
              isUnlocked: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required String rarity,
    required String date,
    required bool isUnlocked,
  }) {
    Color rarityBgColor;
    Color rarityTextColor;

    switch (rarity.toLowerCase()) {
      case 'rare':
        rarityBgColor = const Color(0xFFE3F2FD); // Light Blue
        rarityTextColor = const Color(0xFF2196F3);
        break;
      case 'uncommon':
        rarityBgColor = const Color(0xFFE8F5E9); // Light Green
        rarityTextColor = const Color(0xFF4CAF50);
        break;
      default:
        rarityBgColor = const Color(0xFFF5F5F5); // Light Grey
        rarityTextColor = Colors.grey.shade700;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isUnlocked ? iconBgColor : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isUnlocked ? iconColor : Colors.grey.shade400,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? const Color(0xFF2C3E50) : Colors.grey,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Rarity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rarityBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rarity,
                      style: TextStyle(
                        color: rarityTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 8),
                    Text(
                      date,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Share Button or Locked
          if (isUnlocked)
            Container(
              width: double.infinity,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE09F3E), // Gold
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 16), // Padding for locked bottom
        ],
      ),
    );
  }

  Widget _buildQuizResultItem({
    required String title,
    required String subtitle,
    required String score,
    Color scoreColor = const Color(0xFF00C853), // Standard green
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: isLast ? 0 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required double percentage,
    required Color progressColor,
    double bottomPadding = 20.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
