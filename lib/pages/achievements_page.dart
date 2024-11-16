import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
            centerTitle: true,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 600 
                    ? 600 
                    : MediaQuery.of(context).size.width,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProgressHeader(context, gameProvider),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: 0.75, // Adjusted for better card proportions
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final achievement = gameProvider.achievements[index];
                          return _buildAchievementCard(achievement);
                        },
                        childCount: gameProvider.achievements.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(BuildContext context, GamificationProvider gameProvider) {
    return Consumer<GamificationProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Level',
                      gameProvider.level.toString(),
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Points',
                      gameProvider.points.toString(),
                      Icons.stars,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Streak',
                      '${gameProvider.streak} days',
                      Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Next Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: gameProvider.getLevelProgress(),
                        minHeight: 12,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${gameProvider.points} / ${gameProvider.getPointsForNextLevel()} XP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: achievement.isUnlocked
                      ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                      : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(fontSize: 32),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (achievement.isUnlocked)
                        const Positioned(
                          right: -4,
                          top: -4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked ? Colors.green : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: achievement.progress / achievement.requiredCount,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            '${achievement.progress}/${achievement.requiredCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
