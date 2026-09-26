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
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  int _activeTabIndex = 0;
  int get activeTabIndex => _activeTabIndex;

  bool _isGlobalRunning = false;
  bool get isGlobalRunning => _isGlobalRunning;

  int _parallelActiveSlots = 10;
  int get parallelActiveSlots => _parallelActiveSlots;

  int _delayMinSec = 35;
  int get delayMinSec => _delayMinSec;
  int _delayMaxSec = 65;
  int get delayMaxSec => _delayMaxSec;

  String _targetChannelLink = 'https://t.me/earn_with_nikhil';
  String get targetChannelLink => _targetChannelLink;

  String _currentSpintaxMessage =
      'Hello {bhai|sir|dost}! Live stream me aapka message dekha. Official VIP giveaway access link: https://t.me/earn_with_nikhil';
  String get currentSpintaxMessage => _currentSpintaxMessage;

  final List<TeleAccount> _accounts = [
    TeleAccount(phone: '+1 (202) 555-0143', name: 'SANDRA WILLIAM', isRunning: true, dmsToday: 38, dmsTotal: 342, status: 'Active'),
    TeleAccount(phone: '+1 (202) 555-0182', name: 'VIP DISPATCHER 02', isRunning: true, dmsToday: 41, dmsTotal: 412, status: 'Active'),
    TeleAccount(phone: '+1 (202) 555-0199', name: 'VIP DISPATCHER 03', isRunning: true, dmsToday: 35, dmsTotal: 298, status: 'Active'),
    TeleAccount(phone: '+44 7911 123456', name: 'LONDON NODE 01', isRunning: true, dmsToday: 44, dmsTotal: 520, status: 'Active'),
    TeleAccount(phone: '+44 7911 654321', name: 'LONDON NODE 02', isRunning: true, dmsToday: 39, dmsTotal: 460, status: 'Active'),
    TeleAccount(phone: '+91 98765 43210', name: 'INDIA GATEWAY 01', isRunning: true, dmsToday: 45, dmsTotal: 610, status: 'Active'),
    TeleAccount(phone: '+91 98765 43211', name: 'INDIA GATEWAY 02', isRunning: true, dmsToday: 42, dmsTotal: 580, status: 'Active'),
    TeleAccount(phone: '+49 151 2345678', name: 'BERLIN SLURPER', isRunning: true, dmsToday: 37, dmsTotal: 390, status: 'Active'),
    TeleAccount(phone: '+33 6 12 34 56 78', name: 'PARIS SENDER 01', isRunning: true, dmsToday: 40, dmsTotal: 405, status: 'Active'),
    TeleAccount(phone: '+61 491 570 156', name: 'SYDNEY RELAY 01', isRunning: true, dmsToday: 36, dmsTotal: 370, status: 'Active'),
  ];
  List<TeleAccount> get accounts => _accounts;

  int _selectedAccountIndex = 0;
  int get selectedAccountIndex => _selectedAccountIndex;
  TeleAccount get selectedAccount => _accounts[_selectedAccountIndex];

  Timer? _liveTicker;

  TeleBotState() {
    _startParallelDispatcherSimulation();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void selectAccount(int index) {
    _selectedAccountIndex = index;
    notifyListeners();
  }

  void toggleGlobalMaster() {
    _isGlobalRunning = !_isGlobalRunning;
    for (var acc in _accounts) {
      acc.isRunning = _isGlobalRunning;
      acc.status = _isGlobalRunning ? 'Active' : 'Standby';
    }
    notifyListeners();
  }

  void toggleAccount(int index) {
    _accounts[index].isRunning = !_accounts[index].isRunning;
    _accounts[index].status = _accounts[index].isRunning ? 'Active' : 'Standby';
    notifyListeners();
  }

  void updateSettings({required int slots, required int minSec, required int maxSec, required String channel, required String message}) {
    _parallelActiveSlots = slots;
    _delayMinSec = minSec;
    _delayMaxSec = maxSec;
    _targetChannelLink = channel;
    _currentSpintaxMessage = message;
    notifyListeners();
  }

  void addLog(int accountIndex, String logLine) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _accounts[accountIndex].liveLogs.insert(0, "[$timeStr] $logLine");
    if (_accounts[accountIndex].liveLogs.length > 50) {
      _accounts[accountIndex].liveLogs.removeLast();
    }
    notifyListeners();
  }

  void _startParallelDispatcherSimulation() {
    _liveTicker = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isGlobalRunning) return;
      final rng = Random();
      final activeList = _accounts.where((a) => a.isRunning).toList();
      if (activeList.isEmpty) return;

      final acc = activeList[rng.nextInt(activeList.length)];
      final originalIdx = _accounts.indexOf(acc);
      acc.dmsToday += 1;
      acc.dmsTotal += 1;
      addLog(originalIdx, "Sent VIP Spintax Invite to user @streamer_${rng.nextInt(9999)} (200 OK)");
    });
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
    super.dispose();
  }
}
