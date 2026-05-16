import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

// Schema name for Supabase queries
const String _supabaseSchema = 'startflix';

class AppsManagementScreen extends StatefulWidget {
  const AppsManagementScreen({super.key});

  @override
  State<AppsManagementScreen> createState() => _AppsManagementScreenState();
}

class _AppsManagementScreenState extends State<AppsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  // Helper to access tables with correct schema
  SupabaseQueryBuilder _from(String table) =>
      _supabase.schema(_supabaseSchema).from(table);

  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> _defaultLists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final apps = await _from('apps').select().order('name');

      final lists = await _from(
        'default_m3u_lists',
      ).select().order('priority', ascending: false);

      if (!mounted) return;
      setState(() {
        _apps = List<Map<String, dynamic>>.from(apps);
        _defaultLists = List<Map<String, dynamic>>.from(lists);
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Upload image to Supabase Storage
  Future<String?> _uploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final Uint8List fileBytes;

      if (kIsWeb) {
        if (file.bytes == null) return null;
        fileBytes = file.bytes!;
      } else {
        if (file.path == null) return null;
        fileBytes = await io.File(file.path!).readAsBytes();
      }
      final fileName =
          'app_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // Try to upload to Supabase Storage
      try {
        await _supabase.storage
            .from('app-images')
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        final publicUrl = _supabase.storage
            .from('app-images')
            .getPublicUrl(fileName);
        return publicUrl;
      } catch (storageError) {
        print('Storage error: $storageError');
        // If storage fails, show error and return null
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao fazer upload. Crie o bucket "app-images" no Supabase Storage.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Gerenciar Apps & Listas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.apps), text: 'Apps'),
            Tab(icon: Icon(Icons.list_alt), text: 'Listas M3U'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Novo App' : 'Nova Lista'),
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddAppDialog();
          } else {
            _showAddListDialog();
          }
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildAppsTab(), _buildListsTab()],
            ),
    );
  }

  // ===== APPS TAB =====
  Widget _buildAppsTab() {
    if (_apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Nenhum app cadastrado',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em + para adicionar',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];
        return _buildAppCard(app);
      },
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app) {
    final authTypeLabels = {
      'mac': 'MAC Address',
      'xtream': 'Xtream Codes',
      'url': 'URL M3U',
    };

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            image:
                app['image_url'] != null &&
                    app['image_url'].toString().isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(app['image_url']),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
          ),
          child: app['image_url'] == null || app['image_url'].toString().isEmpty
              ? const Icon(Icons.apps, color: Colors.white54, size: 30)
              : null,
        ),
        title: Text(
          app['name'] ?? 'Sem nome',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getAuthTypeColor(app['auth_type']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                authTypeLabels[app['auth_type']] ?? 'Desconhecido',
                style: TextStyle(
                  color: _getAuthTypeColor(app['auth_type']),
                  fontSize: 11,
                ),
              ),
            ),
            if (app['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                app['description'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: app['is_active'] ?? true,
              activeThumbColor: Colors.green,
              onChanged: (value) => _toggleAppActive(app['id'], value),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditAppDialog(app),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteApp(app['id']),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAuthTypeColor(String? type) {
    switch (type) {
      case 'mac':
        return Colors.orange;
      case 'xtream':
        return Colors.purple;
      case 'url':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ===== LISTS TAB =====
  Widget _buildListsTab() {
    if (_defaultLists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma lista padrão cadastrada',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Novos usuários não terão lista M3U',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _defaultLists.length,
      itemBuilder: (context, index) {
        final list = _defaultLists[index];
        return _buildListCard(list, index);
      },
    );
  }

  Widget _buildListCard(Map<String, dynamic> list, int index) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: index == 0
                ? Colors.green.withOpacity(0.2)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '#${list['priority'] ?? 0}',
              style: GoogleFonts.outfit(
                color: index == 0 ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                list['name'] ?? 'Sem nome',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (index == 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PRINCIPAL',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              list['m3u_url'] ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: list['is_active'] ?? true,
              activeThumbColor: Colors.green,
              onChanged: (value) => _toggleListActive(list['id'], value),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditListDialog(list),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteList(list['id']),
            ),
          ],
        ),
      ),
    );
  }

  // ===== DIALOGS =====
  Future<void> _showAddAppDialog() => _showAppDialog(null);
  Future<void> _showEditAppDialog(Map<String, dynamic> app) =>
      _showAppDialog(app);

  Future<void> _showAppDialog(Map<String, dynamic>? app) async {
    final nameController = TextEditingController(text: app?['name']);
    final imageController = TextEditingController(text: app?['image_url']);
    final descController = TextEditingController(text: app?['description']);
    String authType = app?['auth_type'] ?? 'mac';
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            app == null ? 'Novo App' : 'Editar App',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Nome do App', Icons.apps),
                const SizedBox(height: 12),

                // Image section with preview and upload button
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Image preview
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          image: imageController.text.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageController.text),
                                  fit: BoxFit.cover,
                                  onError: (_, __) {},
                                )
                              : null,
                        ),
                        child: imageController.text.isEmpty
                            ? const Icon(
                                Icons.apps,
                                color: Colors.grey,
                                size: 40,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Upload button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: isUploading
                                  ? null
                                  : () async {
                                      setDialogState(() => isUploading = true);
                                      final url = await _uploadImage();
                                      if (url != null) {
                                        setDialogState(() {
                                          imageController.text = url;
                                          isUploading = false;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Imagem enviada com sucesso!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        setDialogState(
                                          () => isUploading = false,
                                        );
                                      }
                                    },
                              icon: isUploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.upload, size: 18),
                              label: Text(
                                isUploading ? 'Enviando...' : 'Upload Local',
                              ),
                            ),
                          ),
                          if (imageController.text.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setDialogState(() => imageController.text = '');
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Or URL input
                      TextField(
                        controller: imageController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          labelText: 'ou cole URL da imagem',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                          prefixIcon: const Icon(
                            Icons.link,
                            color: Colors.grey,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (_) => setDialogState(() {}),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _buildTextField(descController, 'Descrição', Icons.description),
                const SizedBox(height: 16),
                const Text(
                  'Tipo de Autenticação:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildAuthTypeChip(
                      'MAC',
                      'mac',
                      authType,
                      (v) => setDialogState(() => authType = v),
                    ),
                    const SizedBox(width: 8),
                    _buildAuthTypeChip(
                      'Xtream',
                      'xtream',
                      authType,
                      (v) => setDialogState(() => authType = v),
                    ),
                    const SizedBox(width: 8),
                    _buildAuthTypeChip(
                      'URL',
                      'url',
                      authType,
                      (v) => setDialogState(() => authType = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'image_url': imageController.text.isEmpty
                      ? null
                      : imageController.text,
                  'description': descController.text.isEmpty
                      ? null
                      : descController.text,
                  'auth_type': authType,
                };

                try {
                  if (app == null) {
                    await _from('apps').insert(data);
                  } else {
                    await _from('apps').update(data).eq('id', app['id']);
                  }
                  Navigator.pop(ctx);
                  _loadData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(app == null ? 'Criar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddListDialog() => _showListDialog(null);
  Future<void> _showEditListDialog(Map<String, dynamic> list) =>
      _showListDialog(list);

  Future<void> _showListDialog(Map<String, dynamic>? list) async {
    final nameController = TextEditingController(text: list?['name']);
    final urlController = TextEditingController(text: list?['m3u_url']);
    final priorityController = TextEditingController(
      text: (list?['priority'] ?? 0).toString(),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          list == null ? 'Nova Lista M3U' : 'Editar Lista',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, 'Nome da Lista', Icons.label),
              const SizedBox(height: 12),
              _buildTextField(urlController, 'URL da Lista M3U', Icons.link),
              const SizedBox(height: 12),
              _buildTextField(
                priorityController,
                'Prioridade (maior = principal)',
                Icons.sort,
                isNumber: true,
              ),
              const SizedBox(height: 8),
              Text(
                'A lista com maior prioridade será usada para novos usuários',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            onPressed: () async {
              final data = {
                'name': nameController.text,
                'm3u_url': urlController.text,
                'priority': int.tryParse(priorityController.text) ?? 0,
              };

              try {
                if (list == null) {
                  await _from('default_m3u_lists').insert(data);
                } else {
                  await _from(
                    'default_m3u_lists',
                  ).update(data).eq('id', list['id']);
                }
                Navigator.pop(ctx);
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(list == null ? 'Criar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAuthTypeChip(
    String label,
    String value,
    String selected,
    Function(String) onSelect,
  ) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _getAuthTypeColor(value) : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ===== ACTIONS =====
  Future<void> _toggleAppActive(String id, bool value) async {
    await _from('apps').update({'is_active': value}).eq('id', id);
    _loadData();
  }

  Future<void> _toggleListActive(String id, bool value) async {
    await _from('default_m3u_lists').update({'is_active': value}).eq('id', id);
    _loadData();
  }

  Future<void> _deleteApp(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Excluir App?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _from('apps').delete().eq('id', id);
      _loadData();
    }
  }

  Future<void> _deleteList(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Excluir Lista?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Novos usuários não receberão esta lista.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _from('default_m3u_lists').delete().eq('id', id);
      _loadData();
    }
  }
}
