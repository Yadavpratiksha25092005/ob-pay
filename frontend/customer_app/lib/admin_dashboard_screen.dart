import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'auth_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final _secureStorage = const FlutterSecureStorage();

  static const Color bgPage = Color(0xFFF2F4F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF6C63FF);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  List<dynamic> users = [];
  List<dynamic> transactions = [];
  Map<String, dynamic> stats = {};
  bool isLoading = true;
  String _searchQuery = '';
  int _txTabIndex = 0; // 0=All, 1=Users, 2=Merchants
  Map<String, String> _userRoleMap = {}; // userId → role

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getAllUsers(),
        ApiService.getAllTransactions(),
        ApiService.getAdminStats(),
      ]);
      final loadedUsers = results[0] as List<dynamic>;
      setState(() {
        users = loadedUsers;
        transactions = results[1] as List<dynamic>;
        stats = results[2] as Map<String, dynamic>;
        _userRoleMap = {
          for (final u in loadedUsers)
            if (u['id'] != null) u['id'] as String: (u['role'] ?? 'customer') as String
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboard(),
                _buildUsers(),
                _buildTransactions(),
                _buildSettings(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, 'Dashboard'),
                _navItem(1, Icons.people_rounded, 'Users'),
                _navItem(2, Icons.receipt_long_rounded, 'Txns'),
                _navItem(3, Icons.settings_rounded, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primary : Colors.black38, size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: isSelected ? primary : Colors.black38,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  // ─── DASHBOARD ───
  Widget _buildDashboard() {
    final totalRevenue = stats['total_revenue'] ?? 0;
    final totalTx = stats['total_transactions'] ?? 0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Admin Panel',
                            style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Welcome, ${widget.userName}',
                            style: const TextStyle(color: textLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 4),
                        Text('Live', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _statCard('${users.length}', 'Total Users', Icons.people_rounded,
                      const Color(0xFF6C63FF), const Color(0xFFEEEDFE)),
                  _statCard('₹$totalRevenue', 'Total Revenue', Icons.currency_rupee_rounded,
                      const Color(0xFF48BB78), const Color(0xFFE8F5E9)),
                  _statCard('$totalTx', 'Transactions', Icons.receipt_long_rounded,
                      const Color(0xFF3D5AF1), const Color(0xFFEEEDFE)),
                  _statCard('${transactions.length}', 'All Payments', Icons.payments_rounded,
                      const Color(0xFFED8936), const Color(0xFFFFF3E0)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Transactions',
                      style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: const Text('See all',
                        style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No transactions yet',
                            style: TextStyle(color: textLight))),
                      )
                    : Column(
                        children: transactions.take(5).toList().asMap().entries.map((entry) {
                          final i = entry.key;
                          final tx = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.swap_horiz_rounded,
                                          color: Colors.green, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${tx['sender_name'] ?? 'Unknown'} → ${tx['receiver_name'] ?? 'Unknown'}',
                                              style: const TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 13)),
                                          Text(tx['description'] ?? 'Payment',
                                              style: const TextStyle(color: textLight, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('₹${tx['amount']}',
                                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(tx['status'] ?? 'success',
                                              style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (i < 4)
                                Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 66),
                            ],
                          );
                        }).toList(),
                      ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ─── USERS ───
  Widget _buildUsers() {
    final filteredUsers = _searchQuery.isEmpty
        ? users
        : users.where((u) =>
            (u['full_name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (u['phone'] ?? '').contains(_searchQuery)).toList();

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: bgCard,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Users Management',
                        style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${users.length} Users',
                          style: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by name or phone...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('No users found', style: TextStyle(color: textLight)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final name = user['full_name'] ?? 'Unknown';
                      final phone = user['phone'] ?? '';
                      final isActive = user['is_active'] ?? true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 14)),
                                  Text(phone, style: const TextStyle(color: textLight, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(isActive ? 'Active' : 'Blocked',
                                      style: TextStyle(
                                          color: isActive ? Colors.green : Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _toggleUserBlock(user),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(isActive ? 'Block' : 'Unblock',
                                        style: TextStyle(
                                            color: isActive ? Colors.red : Colors.green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TRANSACTIONS ───
  bool _isMerchantTx(dynamic t) {
    final senderRole = _userRoleMap[t['sender_user_id'] as String? ?? ''] ??
        (t['sender_role'] ?? 'customer') as String;
    final receiverRole = _userRoleMap[t['receiver_user_id'] as String? ?? ''] ??
        (t['receiver_role'] ?? 'customer') as String;
    return senderRole == 'merchant' || receiverRole == 'merchant';
  }

  List<dynamic> get _txForTab {
    List<dynamic> base;
    if (_txTabIndex == 1) {
      base = transactions.where((t) => !_isMerchantTx(t)).toList();
    } else if (_txTabIndex == 2) {
      base = transactions.where(_isMerchantTx).toList();
    } else {
      base = transactions;
    }
    if (_searchQuery.isEmpty) return base;
    return base.where((t) =>
        (t['sender_name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (t['receiver_name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Widget _buildTransactions() {
    final filteredTx = _txForTab;
    final merchantCount = transactions.where(_isMerchantTx).length;
    final tabs = [
      ('All', transactions.length),
      ('Users', transactions.length - merchantCount),
      ('Merchants', merchantCount),
    ];

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: bgCard,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Transactions',
                        style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${filteredTx.length} shown',
                          style: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Category tabs
                Row(
                  children: List.generate(tabs.length, (i) {
                    final selected = _txTabIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _txTabIndex = i;
                          _searchQuery = '';
                        }),
                        child: Container(
                          margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? primary : bgPage,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? primary : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(tabs[i].$1,
                                  style: TextStyle(
                                    color: selected ? Colors.white : textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                              const SizedBox(height: 2),
                              Text('${tabs[i].$2}',
                                  style: TextStyle(
                                    color: selected ? Colors.white70 : textLight,
                                    fontSize: 11,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.black38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: filteredTx.isEmpty
                ? const Center(child: Text('No transactions found', style: TextStyle(color: textLight)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTx.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTx[index];
                      final isMerchantTx = _isMerchantTx(tx);
                      final iconColor = isMerchantTx ? Colors.purple : Colors.green;
                      final iconData = isMerchantTx
                          ? Icons.store_rounded
                          : Icons.swap_horiz_rounded;
                      return GestureDetector(
                        onTap: () => _showTransactionDetails(tx),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgCard,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(iconData, color: iconColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${tx['sender_name'] ?? 'Unknown'} → ${tx['receiver_name'] ?? 'Unknown'}',
                                      style: const TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 13),
                                    ),
                                    Text(tx['description'] ?? 'Payment',
                                        style: const TextStyle(color: textLight, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${tx['amount']}',
                                      style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 15)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: iconColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(tx['status'] ?? 'success',
                                        style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _detailRow('Transaction ID', (tx['id'] ?? '').toString().length > 8
                ? (tx['id'] ?? '').toString().substring(0, 8).toUpperCase()
                : tx['id'] ?? 'N/A'),
            _detailRow('Sender', tx['sender_name'] ?? 'Unknown'),
            _detailRow('Receiver', tx['receiver_name'] ?? 'Unknown'),
            _detailRow('Amount', '₹${tx['amount']}'),
            _detailRow('Status', tx['status'] ?? 'success'),
            _detailRow('Description', tx['description'] ?? 'Payment'),
            _detailRow('Date', tx['created_at']?.toString().substring(0, 10) ?? 'N/A'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    label: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Refund initiated!'), backgroundColor: Colors.orange),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, color: Colors.white),
                    label: const Text('Refund', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textLight, fontSize: 13)),
          Text(value, style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── SETTINGS ───
  Widget _buildSettings() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.userName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Super Admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 12),
                        SizedBox(width: 4),
                        Text('Verified Admin',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _settingsTile(Icons.people_rounded, const Color(0xFF6C63FF), const Color(0xFFEEEDFE),
                'Manage Users', '${users.length} total users',
                () => setState(() => _currentIndex = 1)),
            _settingsTile(Icons.receipt_long_rounded, const Color(0xFF48BB78), const Color(0xFFE8F5E9),
                'All Transactions', '${transactions.length} total transactions',
                () => setState(() => _currentIndex = 2)),
            _settingsTile(Icons.notifications_rounded, const Color(0xFFED8936), const Color(0xFFFFF3E0),
                'Send Notifications', 'Broadcast to all users',
                () => _showNotificationsSheet()),
            _settingsTile(Icons.verified_user_rounded, const Color(0xFF00B5D8), const Color(0xFFE0F7FA),
                'KYC Management', 'Approve/Reject KYC',
                () => _showKYCSheet()),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _secureStorage.deleteAll();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text('Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: const Icon(Icons.title_rounded, color: primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                prefixIcon: const Icon(Icons.message_rounded, color: primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (titleController.text.isEmpty || messageController.text.isEmpty) return;
                  for (final user in users) {
                    await ApiService.sendNotification(
                      userId: user['id'],
                      title: titleController.text,
                      message: messageController.text,
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sent to ${users.length} users!'),
                      backgroundColor: const Color(0xFF48BB78),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text('Send to All',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 void _showKYCSheet() {
  int _kycTabIndex = 0;
  final customers = users.where((u) => u['role'] == 'customer').toList();
  final merchants = users.where((u) => u['role'] == 'merchant').toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => StatefulBuilder(
      builder: (context, setModal) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KYC Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => _kycTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _kycTabIndex == 0 ? primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Customers (${customers.length})',
                              style: TextStyle(
                                  color: _kycTabIndex == 0 ? Colors.white : textLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setModal(() => _kycTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _kycTabIndex == 1 ? primary : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('Merchants (${merchants.length})',
                              style: TextStyle(
                                  color: _kycTabIndex == 1 ? Colors.white : textLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: _kycTabIndex == 0 ? customers.length : merchants.length,
                  itemBuilder: (context, index) {
                    final user = _kycTabIndex == 0 ? customers[index] : merchants[index];
                    final name = user['full_name'] ?? 'Unknown';
                    final phone = user['phone'] ?? '';
                    final kycStatus = user['kyc_status'] ?? 'pending';
                    final role = user['role'] ?? 'customer';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: role == 'merchant'
                                      ? const Color(0xFFED8936).withOpacity(0.1)
                                      : primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: TextStyle(
                                        color: role == 'merchant'
                                            ? const Color(0xFFED8936)
                                            : primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 14)),
                                    Text(phone, style: const TextStyle(color: textLight, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: role == 'merchant'
                                          ? const Color(0xFFED8936).withOpacity(0.1)
                                          : primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role == 'merchant' ? 'Merchant' : 'Customer',
                                      style: TextStyle(
                                          color: role == 'merchant'
                                              ? const Color(0xFFED8936)
                                              : primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: kycStatus == 'verified'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      kycStatus == 'verified' ? '✅ Verified' : '⏳ Pending',
                                      style: TextStyle(
                                          color: kycStatus == 'verified' ? Colors.green : Colors.orange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (kycStatus != 'verified') ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _approveKYC(user);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text('Approve',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _rejectKYC(user);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text('Reject',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _kycStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label: $count',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

 void _approveKYC(Map<String, dynamic> user) async {
  await ApiService.sendNotification(
    userId: user['id'],
    title: 'KYC Approved! ✅',
    message: 'Congratulations! Your KYC has been verified. You can now access all OB Pay features.',
  );
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${user['full_name']} KYC Approved! ✅'), backgroundColor: Colors.green),
  );
  _loadData();
}

  void _rejectKYC(Map<String, dynamic> user) async {
  await ApiService.sendNotification(
    userId: user['id'],
    title: 'KYC Rejected ❌',
    message: 'Your KYC verification was unsuccessful. Please resubmit with correct documents.',
  );
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${user['full_name']} KYC Rejected! ❌'), backgroundColor: Colors.red),
  );
  _loadData();
}
  void _toggleUserBlock(Map<String, dynamic> user) {
    final isActive = user['is_active'] ?? true;
    final name = user['full_name'] ?? 'User';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isActive ? Icons.block_rounded : Icons.check_circle_rounded,
              color: isActive ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(isActive ? 'Block User' : 'Unblock User'),
          ],
        ),
        content: Text(
          isActive ? 'Block $name from OB Pay?' : 'Unblock $name?',
          style: const TextStyle(color: Color(0xFF718096)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isActive ? '$name blocked! 🚫' : '$name unblocked! ✅'),
                  backgroundColor: isActive ? Colors.red : Colors.green,
                ),
              );
              _loadData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(isActive ? 'Block' : 'Unblock',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, Color color, Color bg, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: const TextStyle(color: textLight, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: textLight, fontSize: 11)),
        ],
      ),
    );
  }
}