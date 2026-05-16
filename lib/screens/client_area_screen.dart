import 'package:flutter/material.dart';
import '../services/m3u_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';
import 'my_list_screen.dart';
import 'list_selection_screen.dart';

class ClientAreaScreen extends StatefulWidget {
  const ClientAreaScreen({super.key});

  @override
  State<ClientAreaScreen> createState() => _ClientAreaScreenState();
}

class _ClientAreaScreenState extends State<ClientAreaScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userTvs = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _authService.getUserProfile();
    final user = _authService.currentUser;
    List<Map<String, dynamic>> tvs = [];
    if (user != null) {
      tvs = await _authService.getClientTvs(user.id);
    }

    if (mounted) {
      setState(() {
        _profile = profile;
        _userTvs = tvs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    final bool tvEnabled = _profile?['tv_enabled'] ?? false;
    final String? tvAppName = _profile?['tv_app_name'] as String?;
    final String? tvAppImage = _profile?['tv_app_image'] as String?;
    final String? tvAuthType = _profile?['tv_app_auth_type'] as String?;
    final String? tvMac = _profile?['tv_app_mac'] as String?;
    final String? tvUser = _profile?['tv_app_user'] as String?;
    final String? tvPass = _profile?['tv_app_pass'] as String?;
    final String? tvEmail = _profile?['tv_app_email'] as String?;
    final String? tvPassEmail = _profile?['tv_app_pass_email'] as String?;

    final appImageUrl = tvEnabled
        ? tvAppImage
        : (_profile?['app_image_url'] as String?);
    final appMac = tvEnabled
        ? (tvAuthType == 'mac' ? tvMac : tvEmail)
        : (_profile?['app_mac'] as String?);
    final appPass = tvEnabled
        ? (tvAuthType == 'mac' ? tvPass : tvPassEmail)
        : (_profile?['app_creds_password'] as String?);

    final String? expirationDateStr = _profile?['expiration_date'] as String?;
    final appProviderUrl = _profile?['app_provider_url'] as String?;
    final appUsername = tvEnabled && tvAuthType == 'mac'
        ? tvUser
        : (_profile?['app_username'] as String?);
    final appPasswordApp = _profile?['app_password_app'] as String?;

    DateTime? expirationDate;
    if (expirationDateStr != null) {
      expirationDate = DateTime.tryParse(expirationDateStr);
    }

    final hasAppData =
        tvEnabled ||
        (appImageUrl != null && appImageUrl.isNotEmpty) ||
        (appProviderUrl != null && appProviderUrl.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          tvEnabled ? (tvAppName ?? 'Área do Cliente') : 'Área do Cliente',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profile?['avatar_url'] != null
                        ? NetworkImage(_profile!['avatar_url'])
                        : null,
                    backgroundColor: Colors.grey[800],
                    child: _profile?['avatar_url'] == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _profile?['full_name'] ?? 'Cliente',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_profile?['phone'] != null &&
                      (_profile?['phone'] as String).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _profile!['phone'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Banner Ad
            AdService.createBannerAd(),
            const SizedBox(height: 16),

            // Status Card (Expiration)
            if (expirationDate != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: expirationDate.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.green,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Status da Assinatura (TV)",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      expirationDate.isBefore(DateTime.now())
                          ? "VENCIDO"
                          : "ATIVO",
                      style: TextStyle(
                        color: expirationDate.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Vence em: ${DateFormat('dd/MM/yyyy').format(expirationDate)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

            const Text(
              "Seus Aplicativos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Utilize as credenciais abaixo para acessar os apps parceiros.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            if (hasAppData)
              _buildAppCard(
                appImageUrl,
                tvEnabled
                    ? (tvAppName ?? "App de TV")
                    : "Aplicativo de Conteúdo",
                tvEnabled
                    ? (tvAuthType == 'mac' ? "MAC / ID" : "E-mail")
                    : "MAC / Usuário",
                appMac,
                appPass,
                appProviderUrl,
                appUsername,
                appPasswordApp,
              )
            else if (_profile?['has_signal'] == true)
              // Show signal acquisition message
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Lista Automática Ativa",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Suas credenciais são gerenciadas automaticamente pelo nosso estoque. O conteúdo já deve estar disponível na tela principal.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await M3uService().releaseSignal();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Sinal liberado com sucesso! Feche o app para completar.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text("FECHAR LISTA (LIBERAR)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Nenhum aplicativo configurado pelo administrador.",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // TV Credentials Section - OCULTO (expunha dados da lista M3U)
            // if (_userTvs.isNotEmpty)
            //   ..._userTvs.map((tv) => _buildTvCredentialsCard(tv))
            // else if (_profile?['tv_username'] != null)
            //   _buildTvCredentialsCard({
            //     'provider_name': _profile?['tv_provider_name'],
            //     'username': _profile?['tv_username'],
            //     'password': _profile?['tv_password'],
            //     'dns': _profile?['tv_dns'],
            //   }),

            const SizedBox(height: 20),

            // Select List Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1E88E5,
                  ), // Blue distinct from Red
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ListSelectionScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.dns),
                label: Text(
                  "Selecionar Servidor / Lista",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // My List Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyListScreen()),
                  );
                },
                icon: const Icon(Icons.bookmark),
                label: Text(
                  "Minha Lista",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _showPaymentHistory,
                icon: const Icon(Icons.history),
                label: const Text("Histórico de Pagamentos"),
              ),
            ),

            const SizedBox(height: 12),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  // Unregister device
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final deviceId = prefs.getString('app_device_id');
                    if (deviceId != null) {
                      await Supabase.instance.client
                          .from('active_devices')
                          .delete()
                          .eq('device_id', deviceId);
                    }
                  } catch (e) {
                    print('Error unregistering device: $e');
                  }

                  await _authService.signOut();
                  // The AuthGate in main.dart should handle the redirect,
                  // but we can also pop to be sure or in case AuthGate isn't immediate
                  if (mounted) {
                    // Check if MainTabScreen is the parent, usually we just let the stream handle it.
                    // But let's show a snackbar or loading just in case.
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(
                  "Sair da Conta",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Promote Plans
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryRed.withOpacity(0.8), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Quer mais telas?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Faça um upgrade no seu plano hoje mesmo!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/plans');
                    },
                    child: const Text(
                      "VER PLANOS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(
    String? imageUrl,
    String appName,
    String authLabel,
    String? mac,
    String? pass,
    String? providerUrl,
    String? username,
    String? passwordApp,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Imagem App
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Xtream Codes Section
                if (providerUrl != null && providerUrl.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_circle,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Credenciais Xtream Codes",
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCredentialRow("URL do Provedor", providerUrl),
                  const SizedBox(height: 8),
                  _buildCredentialRow("Usuário", username ?? "Não definido"),
                  const SizedBox(height: 8),
                  _buildCredentialRow("Senha", passwordApp ?? "Não definida"),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),
                ],

                // MAC/Legacy credentials section
                if (mac != null && mac.isNotEmpty) ...[
                  const Text(
                    "Credenciais de Acesso",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  _buildCredentialRow(authLabel, mac),
                  const SizedBox(height: 8),
                  _buildCredentialRow("Senha", pass ?? "Não definida"),
                ],

                // If no credentials at all
                if ((providerUrl == null || providerUrl.isEmpty) &&
                    (mac == null || mac.isEmpty))
                  const Center(
                    child: Text(
                      "Nenhuma credencial configurada",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTvCredentialsCard(Map<String, dynamic> tv) {
    final provider = tv['provider_name'] as String? ?? "TV";
    final username = tv['username'] as String? ?? "Não definido";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tv, color: AppColors.primaryRed),
              const SizedBox(width: 10),
              Text(
                "Credenciais IPTV ($provider)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCredentialRow("Usuário", username),
          const SizedBox(height: 8),
          _buildCredentialRow("Status", "Protegido e Conectado"),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        SelectableText(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _showPaymentHistory() async {
    // Show Loading Dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      ),
    );

    final user = _authService.currentUser;
    List<Map<String, dynamic>> payments = [];
    if (user != null) {
      payments = await _authService.getPayments(userId: user.id);
    }

    if (mounted) {
      Navigator.pop(context); // Close loading

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Histórico de Pagamentos",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: payments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Nenhum pagamento encontrado.",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final pay = payments[index];
                      final date = DateTime.parse(pay['created_at']);
                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(
                          pay['description'] ?? 'Pagamento',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(date),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Text(
                          "R\$ ${(pay['amount'] as num).toDouble().toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Fechar"),
            ),
          ],
        ),
      );
    }
  }
}
