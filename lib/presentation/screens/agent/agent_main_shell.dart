import 'package:essivi_mobile/presentation/screens/agent/agent_dashboard.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_profile_screen.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AgentMainShell extends StatefulWidget {
  const AgentMainShell({super.key});

  @override
  State<AgentMainShell> createState() => _AgentMainShellState();
}

class _AgentMainShellState extends State<AgentMainShell> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    AgentDashboard(), // The real robust dashboard
    Center(
      child: Text(
        "Deliveries Map Placeholder",
        style: TextStyle(color: Colors.white),
      ),
    ),
    AgentProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
