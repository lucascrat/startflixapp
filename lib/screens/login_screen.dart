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

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      if (username.isEmpty || password.isEmpty) {
        throw const AuthException('Por favor, preencha todos os campos.');
      }
      await _authService.signIn(username: username, password: password);
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        bool deviceAllowed = true;
        try {
          final deviceId = await _getDeviceId();
          final rpcResponse = await Supabase.instance.client.rpc(
            'register_device',
            params: {'p_device_id': deviceId, 'p_device_name': 'App Mobile'},
          );
          if (rpcResponse is Map && rpcResponse['success'] == false) {
            deviceAllowed = false;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(rpcResponse['message'] ?? 'Limite de dispositivos atingido.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ));
            }
            await _authService.signOut();
          }
        } catch (_) {}

        if (mounted && deviceAllowed) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainTabScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAdminAccessDialog() async {
    final usernameController = TextEditingController(text: 'admin');
    final passwordController = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Acesso Admin', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Usuário', labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha', labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              if (loading) const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
              onPressed: loading ? null : () async {
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
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                    }
                  } else {
                    throw Exception('Acesso negado. Apenas Admins.');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCodeAccessDialog() async {
    final codeController = TextEditingController();
    bool loading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Acesso Rápido',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  color: AppColors.primaryRed, fontSize: 32, letterSpacing: 4,
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
                onChanged: (val) {
                  final upper = val.toUpperCase();
                  if (upper != val) {
                    codeController.value = codeController.value.copyWith(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    );
                  }
                },
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
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
              onPressed: loading ? null : () async {
                final code = codeController.text.trim();
                if (code.isEmpty) return;
                setState(() => loading = true);
                try {
                  final result = await _authService.loginWithCode(code);
                  if (result != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_code_access', true);
                    await prefs.setString('access_code_used', code);
                    // m3u_url may be null (pool mode) — that is fine
                    if (result['m3u_url'] != null) {
                      await prefs.setString('temp_m3u_url', result['m3u_url']);
                    } else {
                      await prefs.remove('temp_m3u_url');
                    }
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
                      SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
              child: const Text('ACESSAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocalAccessDialog() async {
    final dnsController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();
    bool loading = false;
    bool obscurePass = true;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.dns_outlined, color: AppColors.primaryRed, size: 22),
              const SizedBox(width: 8),
              Text('Acesso Local',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conecte diretamente ao seu servidor IPTV sem precisar de conta.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                _dialogField(
                  controller: dnsController,
                  label: 'DNS / Servidor',
                  hint: 'ex: 192.168.1.1:8080 ou http://servidor.com',
                  icon: Icons.dns_outlined,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: userController,
                  label: 'Usuário',
                  hint: 'seu usuário IPTV',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (_, setPassState) => TextFormField(
                    controller: passController,
                    obscureText: obscurePass,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      hintText: 'sua senha IPTV',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () => setPassState(() => obscurePass = !obscurePass),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primaryRed, width: 1),
                      ),
                    ),
                  ),
                ),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.play_arrow, size: 18),
              onPressed: loading ? null : () async {
                final dns = dnsController.text.trim();
                final user = userController.text.trim();
                final pass = passController.text.trim();

                if (dns.isEmpty || user.isEmpty || pass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setState(() => loading = true);
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_local_access', true);
                  await prefs.setString('local_dns', dns);
                  await prefs.setString('local_username', user);
                  await prefs.setString('local_password', pass);
                  // Clear other access modes
                  await prefs.remove('is_code_access');
                  await prefs.remove('temp_m3u_url');

                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainTabScreen()),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => loading = false);
                }
              },
              label: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 1),
        ),
      ),
    );
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('app_device_id');
    if (deviceId == null) {
      deviceId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF800000), Colors.black, Colors.black],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          // Admin access icon (top-right)
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined,
                  color: Colors.white.withOpacity(0.5), size: 28),
              onPressed: _showAdminAccessDialog,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  // Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
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
                        const Text(
                          'Bem-vindo de volta',
                          style: TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          controller: _usernameController,
                          label: 'Usuário',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Senha',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 32),

                        // Login button
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
                                    height: 24, width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('ou', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Code access button
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
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Local access button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primaryRed.withOpacity(0.5)),
                              foregroundColor: AppColors.primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.dns_outlined, size: 20),
                            onPressed: _showLocalAccessDialog,
                            label: const Text(
                              'ACESSO LOCAL (DNS)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}
