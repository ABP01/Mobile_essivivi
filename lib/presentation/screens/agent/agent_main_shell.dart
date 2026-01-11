import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:essivi_mobile/providers/notification_provider.dart';
import 'agent_dashboard.dart';
import 'agent_deliveries_screen.dart';
import 'agent_earnings_screen.dart';
import 'agent_profile_screen.dart';

class AgentMainShell extends StatefulWidget {
  const AgentMainShell({super.key});

  @override
  State<AgentMainShell> createState() => _AgentMainShellState();
}

class _AgentMainShellState extends State<AgentMainShell> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          AgentDashboard(),
          AgentDeliveriesScreen(),
          AgentEarningsScreen(),
          AgentProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return _buildNavItem(
                  0, 
                  FluentIcons.home_24_filled, 
                  FluentIcons.home_24_regular, 
                  AppLocalizations.of(context)!.home,
                  badgeCount: provider.unreadCount,
                );
              },
            ),
            _buildNavItem(1, FluentIcons.box_24_filled, FluentIcons.box_24_regular, AppLocalizations.of(context)!.active),
            _buildNavItem(2, FluentIcons.money_24_filled, FluentIcons.money_24_regular, AppLocalizations.of(context)!.earnings),
            _buildNavItem(3, FluentIcons.person_24_filled, FluentIcons.person_24_regular, AppLocalizations.of(context)!.profile),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label, {int badgeCount = 0}) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: isSelected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(selectedIcon, color: AppColors.primary),
                      if (badgeCount > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(unselectedIcon, color: Colors.grey),
                if (badgeCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
