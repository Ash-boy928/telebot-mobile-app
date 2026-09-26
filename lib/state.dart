import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Account Model
class TeleAccount {
  final String phone;
  String name;
  bool isRunning;
  int dmsToday;
  int dmsTotal;
  String status; // 'Active', 'Standby', 'FloodWait', 'Resting'
  int? floodWaitRemainingSec;
  List<String> liveLogs;

  TeleAccount({
    required this.phone,
    required this.name,
    this.isRunning = false,
    this.dmsToday = 0,
    this.dmsTotal = 0,
    this.status = 'Standby',
    this.floodWaitRemainingSec,
    List<String>? liveLogs,
  }) : liveLogs = liveLogs ?? [];
}

/// Global Master Configuration & State Controller
class TeleBotState extends ChangeNotifier {
  // Theme State: Day / Night
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  // Active Bottom Tab (0 = Home/Overview, 1 = Accounts Fleet & ID Logs, 2 = Config & Settings)
  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  // Global Master Running State
  bool _isGlobalRunning = false;
  bool get isGlobalRunning => _isGlobalRunning;

  // Parallel Active Slots Limit (User requested minimum 10 parallel accounts)
  int _parallelActiveSlots = 10;
  int get parallelActiveSlots => _parallelActiveSlots;

  // Safe DM Delays (Keeps same exact logic as VPS backend)
  int _delayMinSec = 35;
  int get delayMinSec => _delayMinSec;
  int _delayMaxSec = 65;
  int get delayMaxSec => _delayMaxSec;

  // Target Channel Link & Message Template
  String _targetChannelLink = 'https://t.me/earn_with_nikhil';
  String get targetChannelLink => _targetChannelLink;

  String _currentSpintaxMessage =
      'Hello {bhai|sir|dost}! Live stream me aapka message dekha. Official VIP giveaway access link: https://t.me/earn_with_nikhil';
  String get currentSpintaxMessage => _currentSpintaxMessage;

  // Accounts List (Pre-loaded with up to 30 accounts support)
  final List<TeleAccount> _accounts = [
    TeleAccount(
      phone: '+1 (202) 555-0143',
      name: 'SANDRA WILLIAM',
      isRunning: true,
      dmsToday: 38,
      dmsTotal: 184,
      status: 'Active',
      liveLogs: [
        '[08:15:10 pm] [INIT] Logged in successfully via MTProto session.',
        '[08:16:02 pm] [RADAR] Live voice chat listener connected.',
        '[08:16:35 pm] [DM] 🚀 Message delivered to @RahulSharma (+91...) | Daily: 38',
      ],
    ),
    TeleAccount(
      phone: '+91 76023 72653',
      name: 'Nnn Barman',
      isRunning: true,
      dmsToday: 24,
      dmsTotal: 112,
      status: 'Active',
      liveLogs: [
        '[08:14:00 pm] [INIT] MTProto Socket connected with Jio 5G carrier.',
        '[08:15:30 pm] [DM] 🚀 Instant 2s DM fired to @priya_k (ID: 948124)',
      ],
    ),
    TeleAccount(
      phone: '+91 98234 11094',
      name: 'Official VIP Bot 03',
      isRunning: true,
      dmsToday: 19,
      dmsTotal: 95,
      status: 'Active',
      liveLogs: [
        '[08:12:00 pm] [SAFE GAP] Waiting remaining 28s gap before next DM...',
      ],
    ),
    TeleAccount(
      phone: '+44 7700 900123',
      name: 'Alpha Stream Node 04',
      isRunning: true,
      dmsToday: 15,
      dmsTotal: 88,
      status: 'Active',
      liveLogs: [],
    ),
    TeleAccount(
      phone: '+1 (312) 555-8821',
      name: 'US Cloud Dispatch 05',
      isRunning: false,
      dmsToday: 0,
      dmsTotal: 42,
      status: 'Standby',
      liveLogs: [],
    ),
  ];

  List<TeleAccount> get accounts => _accounts;

  // Currently Selected Account for Detailed ID-wise Logs
  int _selectedAccountIndex = 0;
  int get selectedAccountIndex => _selectedAccountIndex;
  TeleAccount get selectedAccount => _accounts[_selectedAccountIndex];

  // Constructor
  TeleBotState() {
    _startParallelDispatcherSimulation();
  }

  // Toggle Day / Night Mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Set Active Tab
  void setTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  // Select Account for viewing its live logs
  void selectAccount(int index) {
    if (index >= 0 && index < _accounts.length) {
      _selectedAccountIndex = index;
      notifyListeners();
    }
  }

  // Master Global Switch (Start All / Stop All)
  void toggleGlobalMaster() {
    _isGlobalRunning = !_isGlobalRunning;
    for (var acc in _accounts) {
      acc.isRunning = _isGlobalRunning;
      acc.status = _isGlobalRunning ? 'Active' : 'Standby';
    }
    notifyListeners();
  }

  // Individual Account Toggle
  void toggleAccount(int index) {
    if (index >= 0 && index < _accounts.length) {
      _accounts[index].isRunning = !_accounts[index].isRunning;
      _accounts[index].status = _accounts[index].isRunning ? 'Active' : 'Standby';
      notifyListeners();
    }
  }

  // Update Settings
  void updateSettings({int? slots, int? minDelay, int? maxDelay, String? chLink, String? spintax}) {
    if (slots != null) _parallelActiveSlots = slots;
    if (minDelay != null) _delayMinSec = minDelay;
    if (maxDelay != null) _delayMaxSec = maxDelay;
    if (chLink != null) _targetChannelLink = chLink;
    if (spintax != null) _currentSpintaxMessage = spintax;
    notifyListeners();
  }

  // Add Log to Account
  void addLog(String phone, String logLine) {
    final acc = _accounts.firstWhere((a) => a.phone == phone, orElse: () => _accounts.first);
    acc.liveLogs.insert(0, logLine);
    if (acc.liveLogs.length > 80) acc.liveLogs.removeLast();
    notifyListeners();
  }

  // Background Parallel Dispatcher Worker:
  // Implements user requested: "Minimum 10 IDs active parallel running"
  Timer? _workerTimer;
  void _startParallelDispatcherSimulation() {
    _workerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isGlobalRunning) return;

      // Pick up to parallelActiveSlots (10) running accounts
      final activePool = _accounts.where((a) => a.isRunning).take(_parallelActiveSlots).toList();
      if (activePool.isEmpty) return;

      final randomAccount = activePool[Random().nextInt(activePool.length)];
      randomAccount.dmsToday += 1;
      randomAccount.dmsTotal += 1;

      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      
      final sampleTarget = '@User_${1000 + Random().nextInt(8999)}';
      randomAccount.liveLogs.insert(
        0,
        '[$timeStr] 🚀 [DM SENT] Slot #${activePool.indexOf(randomAccount) + 1} delivered to $sampleTarget (Daily: ${randomAccount.dmsToday})',
      );
      if (randomAccount.liveLogs.length > 80) randomAccount.liveLogs.removeLast();

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _workerTimer?.cancel();
    super.dispose();
  }
}
