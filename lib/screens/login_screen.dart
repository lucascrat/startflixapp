import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'main_tab_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between Login and Sign Up
  String? _selectedAvatar;

  final _nameController = TextEditingController();

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      if (username.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
        throw const AuthException('Por favor, preencha todos os campos.');
      }

      if (_isLogin) {
        await _authService.signIn(username: username, password: password);
      } else {
        await _authService.createUser(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: name,
          avatarUrl: _selectedAvatar,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      // Check if logged in (Sign Up might auto-login if confirm is off)
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        // --- DEVICE LIMIT CHECK ---
        bool deviceAllowed = true;
        try {
          final deviceId = await _getDeviceId();
          final rpcResponse = await Supabase.instance.client.rpc(
            'register_device',
            params: {'p_device_id': deviceId, 'p_device_name': 'App Mobile'},
          );

          // Check if boolean or json (my SQL returns jsonb)
          if (rpcResponse is Map && rpcResponse['success'] == false) {
            deviceAllowed = false;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    rpcResponse['message'] ??
                        'Limite de dispositivos atingido.',
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            // Sign out immediately
            await _authService.signOut();
          }
        } catch (e) {
          print('Device check skipped or failed: $e');
          // If RPC is missing, we allow login (Fail Open) to avoid breaking app if SQL wasn't run
        }

        if (mounted && deviceAllowed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainTabScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message = e.message;
        if (message.contains('User already registered') ||
            message.contains('already registered')) {
          message = 'Este usuário já existe. Tente fazer login.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // ...
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAdminAccessDialog() async {
    final usernameController = TextEditingController(text: 'admin');
    final passwordController = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Acesso Admin',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                TextField(
                  controller: passwordController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                  obscureText: true,
                ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);
                        try {
                          await _authService.signIn(
                            username: usernameController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          final profile = await _authService.getUserProfile();
                          if (profile != null && profile['role'] == 'admin') {
                            if (mounted) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminScreen(),
                                ),
                              );
                            }
                          } else {
                            throw Exception('Acesso negado. Apenas Admins.');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => loading = false);
                        }
                      },
                child: const Text('Entrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCodeAccessDialog() async {
    final codeController = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF141414),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Acesso Rápido',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digite o código fornecido pelo seu administrador para acessar sua lista instantaneamente.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: codeController,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  maxLength: 15,
                  style: GoogleFonts.bebasNeue(
                    color: AppColors.primaryRed,
                    fontSize: 32,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CÓDIGO',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                    counterText: '',
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  onChanged: (val) => codeController.text = val.toUpperCase(),
                ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(color: AppColors.primaryRed),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) return;

                        setState(() => loading = true);
                        try {
                          final result = await _authService.loginWithCode(code);
                          if (result != null) {
                            // Store the M3U URL in preferences for temporary access
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('temp_m3u_url', result['m3u_url']);
                            await prefs.setBool('is_code_access', true);
                            await prefs.setString('access_code_used', code);

                            if (mounted) {
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const MainTabScreen()),
                              );
                            }
                          } else {
                            throw Exception('Código inválido ou expirado.');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => loading = false);
                        }
                      },
                child: const Text('ACESSAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('app_device_id');
    if (deviceId == null) {
      deviceId =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
      await prefs.setString('app_device_id', deviceId);
    }
    return deviceId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Premium Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF800000), // Deep Red Center
                  Colors.black,
                  Colors.black,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Subtle Pattern or Overlay (Optional)
          Container(color: Colors.black.withOpacity(0.3)),

          // Lock Icon (Admin Access)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white.withOpacity(0.5),
                size: 28,
              ),
              onPressed: () {
                _showAdminAccessDialog();
              },
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Text(
                    'STARTFLIX',
                    style: GoogleFonts.bebasNeue(
                      color: AppColors.primaryRed,
                      fontSize: 56,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Glassmorphism Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Bem-vindo de volta' : 'Criar Conta',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (!_isLogin) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Selecione um Avatar",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: kAvatars.map((url) {
                                final isSelected = _selectedAvatar == url;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedAvatar = url),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.primaryRed,
                                              width: 3,
                                            )
                                          : Border.all(
                                              color: Colors.transparent,
                                              width: 3,
                                            ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: NetworkImage(url),
                                      backgroundColor: Colors.grey[800],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nome Completo',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _usernameController,
                          label: 'Usuário',
                          icon: Icons.person,
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'ENTRAR' : 'CADASTRAR',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick Access Code Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            onPressed: _showCodeAccessDialog,
                            label: const Text(
                              'ENTRAR COM CÓDIGO',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.7),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: _isLogin
                                  ? 'Novo no StartFlix? '
                                  : 'Já tem uma conta? ',
                              style: TextStyle(color: Colors.grey[400]),
                              children: [
                                TextSpan(
                                  text: _isLogin
                                      ? 'Assine agora.'
                                      : 'Conecte-se.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword,
      keyboardType: keyboardType,
      cursorColor: AppColors.primaryRed,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF333333),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}
