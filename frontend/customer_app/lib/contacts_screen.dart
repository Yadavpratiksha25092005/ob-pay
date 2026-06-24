import 'package:flutter/material.dart';
import 'api_service.dart';
import 'wallet_screen.dart';
import 'theme_toggle.dart';

class ContactsScreen extends StatefulWidget {
  final String userId;

  const ContactsScreen({super.key, required this.userId});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  static const Color primary = Color(0xFF6C63FF);
  static const Color bgPage = Color(0xFFF2F4F7);
  static const Color textDark = Color(0xFF1A202C);
  static const Color textLight = Color(0xFF718096);

  List<dynamic> contacts = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await ApiService.getBeneficiaries(widget.userId);
    setState(() {
      contacts = data;
      isLoading = false;
    });
  }

  List<dynamic> get _filtered {
    if (_searchQuery.isEmpty) return contacts;
    final q = _searchQuery.toLowerCase();
    return contacts.where((c) =>
        (c['name'] ?? '').toLowerCase().contains(q) ||
        (c['nickname'] ?? '').toLowerCase().contains(q) ||
        (c['phone'] ?? '').contains(q)).toList();
  }

  // avatar initials from name
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _avatarColor(String name) {
    const colors = [
      Color(0xFF6C63FF), Color(0xFF43C6AC), Color(0xFFFF6584),
      Color(0xFFFFA630), Color(0xFF4FC3F7), Color(0xFF81C784),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  void _showAddSheet({Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] ?? '');
    final nickCtrl = TextEditingController(text: existing?['nickname'] ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(existing != null ? Icons.edit_rounded : Icons.person_add_rounded,
                    color: primary),
                const SizedBox(width: 8),
                Text(existing != null ? 'Edit Contact' : 'Add Contact',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              ]),
              const SizedBox(height: 20),
              _sheetField('Full Name', nameCtrl, Icons.person_rounded,
                  enabled: existing == null),
              const SizedBox(height: 14),
              _sheetField('Phone Number', phoneCtrl, Icons.phone_rounded,
                  keyboard: TextInputType.phone,
                  enabled: existing == null),
              const SizedBox(height: 14),
              _sheetField('Nickname (optional)', nickCtrl, Icons.label_rounded),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          if (name.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Name must be at least 2 characters'),
                                backgroundColor: Colors.red));
                            return;
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Phone must be exactly 10 digits'),
                                backgroundColor: Colors.red));
                            return;
                          }
                          setSheetState(() => saving = true);
                          if (existing != null) {
                            await ApiService.updateBeneficiaryNickname(
                                existing['id'], nickCtrl.text.trim());
                          } else {
                            await ApiService.addBeneficiary(
                              userId: widget.userId,
                              name: name,
                              phone: phone,
                              nickname: nickCtrl.text.trim(),
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          await _load();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: saving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(existing != null ? 'Save Changes' : 'Add Contact',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboard, bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary, size: 20),
        filled: true,
        fillColor: enabled ? bgPage : Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Contact'),
        content: Text(
            'Remove ${contact['name']} from your contacts?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService.deleteBeneficiary(contact['id']);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Contacts',
            style: TextStyle(
                color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: textDark),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: primary),
            onPressed: _showAddSheet,
            tooltip: 'Add Contact',

          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: Colors.black38),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _contactCard(_filtered[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Contact',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _contactCard(Map<String, dynamic> c) {
    final name = c['name'] ?? '';
    final phone = c['phone'] ?? '';
    final nick = (c['nickname'] ?? '').toString().trim();
    final color = _avatarColor(name);

    return Dismissible(
      key: Key(c['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        await _confirmDelete(c);
        return false; // we handle deletion manually
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: color,
            radius: 24,
            child: Text(_initials(name),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          title: Text(nick.isNotEmpty ? nick : name,
              style: const TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          subtitle: Text(
              nick.isNotEmpty ? '$name · $phone' : phone,
              style: const TextStyle(color: textLight, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit nickname
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: Colors.grey, size: 18),
                onPressed: () => _showAddSheet(existing: c),
                tooltip: 'Edit',
              ),
              // Send money
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WalletScreen(
                      userId: widget.userId,
                      receiverPhone: phone,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Pay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No contacts yet',
              style: TextStyle(
                  color: textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Add contacts to send money quickly',
              style: TextStyle(color: textLight, fontSize: 13)),
        ],
      ),
    );
  }
}
