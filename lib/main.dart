import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TeleBotState(),
      child: const TeleBotApp(),
    ),
  );
}

class TeleBotApp extends StatelessWidget {
  const TeleBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TeleBotState>(context);
    return MaterialApp(
      title: 'TeleBot VIP Native',
      debugShowCheckedModeBanner: false,
      theme: TeleBotTheme.lightTheme,
      darkTheme: TeleBotTheme.darkTheme,
      themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TeleBotState>(context);
    final isDark = state.isDarkMode;

    final List<Widget> screens = [
      const HomeOverviewTab(),
      const AccountsFleetTab(),
      const SettingsMasterTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'TELEBOT NATIVE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: TeleBotTheme.primaryCoral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: TeleBotTheme.primaryCoral, width: 0.8),
                  ),
                  child: const Text(
                    '10 SLOTS PARALLEL',
                    style: TextStyle(color: TeleBotTheme.primaryCoral, fontSize: 9.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            Text(
              state.isGlobalRunning ? '🟢 All Workers Firing Live' : '⚪ Engine on Standby',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Day / Night Switch Button
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : TeleBotTheme.primaryCoral,
            ),
            tooltip: isDark ? 'Switch to Day (Light) Mode' : 'Switch to Night (Dark) Mode',
            onPressed: () => state.toggleTheme(),
          ),
          // Master Power Switch
          Switch(
            value: state.isGlobalRunning,
            activeColor: TeleBotTheme.primaryCoral,
            onChanged: (val) => state.toggleGlobalMaster(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: screens[state.activeTabIndex],
      // Clean, Compact 3-Tab Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: state.activeTabIndex,
          onTap: (index) => state.setTab(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded, color: TeleBotTheme.primaryCoral),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              activeIcon: Icon(Icons.people_alt_rounded, color: TeleBotTheme.primaryCoral),
              label: 'Accounts & Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune_rounded, color: TeleBotTheme.primaryCoral),
              label: 'Master Config',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TAB 1: HOME OVERVIEW (Live KPIs & Engine)
// ==========================================
class HomeOverviewTab extends StatelessWidget {
  const HomeOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TeleBotState>(context);
    final isDark = state.isDarkMode;

    final totalDmsToday = state.accounts.fold<int>(0, (sum, a) => sum + a.dmsToday);
    final runningCount = state.accounts.where((a) => a.isRunning).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Status Hero Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF270C20), Color(0xFF4A153A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: TeleBotTheme.primaryCoral.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DISPATCH FLEET ENGINE',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: state.isGlobalRunning ? TeleBotTheme.successGreen : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.isGlobalRunning ? '10 SLOTS FIRING' : 'IDLE',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '$totalDmsToday',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'DMs Today\n100% Native Socket',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Target Channel Live Tag
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.podcasts_rounded, color: TeleBotTheme.primaryCoral, fontSize: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target: ${state.targetChannelLink}',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.hub_rounded,
                title: 'Parallel Slots',
                value: '${state.parallelActiveSlots} Active',
                color: TeleBotTheme.primaryCoral,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.bolt_rounded,
                title: 'Safe Gap Delay',
                value: '${state.delayMinSec}s - ${state.delayMaxSec}s',
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.shield_rounded,
                title: 'Spam Shield',
                value: 'Anti-Freeze 20s',
                color: TeleBotTheme.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.groups_rounded,
                title: 'Running Accounts',
                value: '$runningCount / ${state.accounts.length}',
                color: Colors.purpleAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Quick Master Action Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: state.isGlobalRunning ? const Color(0xFFEF4444) : TeleBotTheme.primaryCoral,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
          ),
          onPressed: () => state.toggleGlobalMaster(),
          icon: Icon(state.isGlobalRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
          label: Text(
            state.isGlobalRunning ? 'STOP ALL 10 DISPATCH WORKERS' : 'START 10 PARALLEL ACCOUNTS NOW',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================
// TAB 2: ACCOUNTS FLEET & ID-WISE LIVE LOGS (Dedicated UX)
// ========================================================
class AccountsFleetTab extends StatelessWidget {
  const AccountsFleetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TeleBotState>(context);
    final isDark = state.isDarkMode;

    return Column(
      children: [
        // Horizontal Account Selector Pills (Switch ID to view its real-time logs)
        Container(
          height: 62,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1422) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: state.accounts.length,
            itemBuilder: (context, i) {
              final acc = state.accounts[i];
              final isSelected = state.selectedAccountIndex == i;
              return GestureDetector(
                onTap: () => state.selectAccount(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TeleBotTheme.primaryCoral
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? TeleBotTheme.primaryCoral
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: acc.isRunning ? TeleBotTheme.successGreen : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        acc.name.length > 12 ? '${acc.name.substring(0, 11)}...' : acc.name,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${acc.dmsToday})',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Selected Account Control Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF131C2E) : const Color(0xFFF8FAFC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedAccount.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  Text(
                    '${state.selectedAccount.phone} • Today: ${state.selectedAccount.dmsToday} DMs',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                ],
              ),
              Switch(
                value: state.selectedAccount.isRunning,
                activeColor: TeleBotTheme.primaryCoral,
                onChanged: (val) => state.toggleAccount(state.selectedAccountIndex),
              ),
            ],
          ),
        ),

        // Live Real-Time ID Logs Stream (Terminal Style)
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF06090F) : const Color(0xFF0F172A),
            child: state.selectedAccount.liveLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs yet for this account.\nWorker listening to MTProto socket...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.selectedAccount.liveLogs.length,
                    itemBuilder: (context, idx) {
                      final line = state.selectedAccount.liveLogs[idx];
                      Color logColor = const Color(0xFF38BDF8); // Default Cyan
                      if (line.contains('DM SENT') || line.contains('DELIVERED')) {
                        logColor = const Color(0xFF4ADE80); // Green
                      } else if (line.contains('WARN') || line.contains('WAIT')) {
                        logColor = const Color(0xFFFBBF24); // Yellow
                      } else if (line.contains('ERROR') || line.contains('FAIL')) {
                        logColor = const Color(0xFFF87171); // Red
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          line,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: logColor,
                            height: 1.4,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// TAB 3: SETTINGS & MASTER CONFIG (Global Controls)
// =====================================================
class SettingsMasterTab extends StatefulWidget {
  const SettingsMasterTab({super.key});

  @override
  State<SettingsMasterTab> createState() => _SettingsMasterTabState();
}

class _SettingsMasterTabState extends State<SettingsMasterTab> {
  late TextEditingController _channelCtrl;
  late TextEditingController _spintaxCtrl;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<TeleBotState>(context, listen: false);
    _channelCtrl = TextEditingController(text: state.targetChannelLink);
    _spintaxCtrl = TextEditingController(text: state.currentSpintaxMessage);
  }

  @override
  void dispose() {
    _channelCtrl.dispose();
    _spintaxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TeleBotState>(context);
    final isDark = state.isDarkMode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Parallel Running Concurrency Control
        _buildSectionHeader('⚡ Parallel Execution Engine'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Parallel Slots:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(
                      '${state.parallelActiveSlots} IDs Simultaneously',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: TeleBotTheme.primaryCoral),
                    ),
                  ],
                ),
                Slider(
                  value: state.parallelActiveSlots.toDouble(),
                  min: 5,
                  max: 20,
                  divisions: 15,
                  activeColor: TeleBotTheme.primaryCoral,
                  label: '${state.parallelActiveSlots} Accounts',
                  onChanged: (val) {
                    state.updateSettings(slots: val.toInt());
                  },
                ),
                Text(
                  'Minimum 10 slots active ensures fast live stream hooking with high throughput without phone overheating.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Safe Human Delay Gap
        _buildSectionHeader('⏳ Human Delay Intervals (Safe Anti-Flood)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Min Delay: ${state.delayMinSec}s | Max Delay: ${state.delayMaxSec}s',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  'Maintains Telegram safe gaps between DMs to prevent FLOOD_WAIT and Peer Flood warnings.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Target Channel Link
        _buildSectionHeader('📡 Target Channel & Voice Stream'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _channelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Channel / Group Username or Link',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                  onChanged: (val) => state.updateSettings(chLink: val),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Dynamic Hinglish Message Spintax
        _buildSectionHeader('💬 Dynamic Message Rotation (Spintax)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: _spintaxCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message Template with Spintax {a|b|c}',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => state.updateSettings(spintax: val),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Battery Optimization Warning & Guidance
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.battery_alert_rounded, color: Colors.amber, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Android Settings: Please keep "Unrestricted Battery" enabled for TeleBot to run 24/7 in the background.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5),
      ),
    );
  }
}
