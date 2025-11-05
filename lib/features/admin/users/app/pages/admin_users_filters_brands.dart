import 'package:flutter/material.dart';
import '../../../../../utils/constants/app_colors.dart';

class AdminUsersFiltersBrandsPage extends StatefulWidget {
  const AdminUsersFiltersBrandsPage({super.key});

  @override
  State<AdminUsersFiltersBrandsPage> createState() => _AdminUsersFiltersBrandsPageState();
}

class _AdminUsersFiltersBrandsPageState extends State<AdminUsersFiltersBrandsPage> {
  String _role = 'Tout';
  String _status = 'Tout';

  void _apply() {
    Navigator.of(context).pop({'role': _role, 'status': _status});
  }

  void _clear() {
    setState(() {
      _role = 'Tout';
      _status = 'Tout';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientFromScheme(Theme.of(context).colorScheme),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              children: [
                // header with centered title
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.arrow_back, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Center(
                        child: Text('Filtrer les utilisateurs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 24),

                // Role selector
                Align(alignment: Alignment.centerLeft, child: Text('Rôle', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<String>(value: 'Tout', groupValue: _role, title: const Text('Tout'), onChanged: (v) => setState(() => _role = v!)),
                      RadioListTile<String>(value: 'Grossiste', groupValue: _role, title: const Text('Grossiste'), onChanged: (v) => setState(() => _role = v!)),
                      RadioListTile<String>(value: 'Superette', groupValue: _role, title: const Text('Superette'), onChanged: (v) => setState(() => _role = v!)),
                      RadioListTile<String>(value: 'Admin', groupValue: _role, title: const Text('Admin'), onChanged: (v) => setState(() => _role = v!)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status selector
                Align(alignment: Alignment.centerLeft, child: Text('Statut', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<String>(value: 'Tout', groupValue: _status, title: const Text('Tout'), onChanged: (v) => setState(() => _status = v!)),
                      RadioListTile<String>(value: 'Actif', groupValue: _status, title: const Text('Actif'), onChanged: (v) => setState(() => _status = v!)),
                      RadioListTile<String>(value: 'Suspendue', groupValue: _status, title: const Text('Suspendue'), onChanged: (v) => setState(() => _status = v!)),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clear,
                        style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _apply,
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: const StadiumBorder()),
                        child: const Text('Appliquer', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
