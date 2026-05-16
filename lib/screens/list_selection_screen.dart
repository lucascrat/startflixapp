import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';

import 'main_tab_screen.dart';

class ListSelectionScreen extends StatefulWidget {
  const ListSelectionScreen({super.key});

  @override
  State<ListSelectionScreen> createState() => _ListSelectionScreenState();
}

class _ListSelectionScreenState extends State<ListSelectionScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _availableLists = [];
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // 1. Get current profile URL
      final profile = await _authService.getUserProfile();
      final currentUrl = profile?['m3u_url'] as String?;

      // 2. Fetch default lists
      final response = await _supabase
          .schema('startflix')
          .from('default_m3u_lists')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: false);

      final List<Map<String, dynamic>> lists = List<Map<String, dynamic>>.from(
        response,
      );

      if (mounted) {
        setState(() {
          _currentUrl = currentUrl;
          _availableLists = lists;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading lists: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar listas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectList(String url, String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Update profile with selected URL
      await _supabase
          .schema('startflix')
          .from('profiles')
          .update({'m3u_url': url})
          .eq('id', user.id);

      // Force reload of profile in AuthService if needed (it usually fetches fresh)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lista "$name" selecionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to MainTabScreen effectively restarting the app flow
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error selecting list: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar seleção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Selecionar Servidor',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : _availableLists.isEmpty
          ? Center(
              child: Text(
                'Nenhuma lista disponível no momento.',
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availableLists.length,
              itemBuilder: (context, index) {
                final list = _availableLists[index];
                final name = list['name'] as String? ?? 'Servidor ${index + 1}';
                final url = list['m3u_url'] as String;
                final description =
                    list['description'] as String? ?? 'Toque para selecionar';

                final isSelected = _currentUrl == url;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryRed.withOpacity(0.1)
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryRed
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryRed
                            : Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.dns, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: GoogleFonts.outfit(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryRed,
                            size: 28,
                          )
                        : const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                    onTap: () => _selectList(url, name),
                  ),
                );
              },
            ),
    );
  }
}
