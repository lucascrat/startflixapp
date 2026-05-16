import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

import '../services/payment_service.dart';
import '../services/auth_service.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isLoading = false;
  int _selectedPlanIndex = 0;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    final plans = await PaymentService().getPlans();
    if (mounted) {
      setState(() {
        _plans = plans;
        _isLoading = false;
        // Selecionar o do meio ou o primeiro se houver
        if (_plans.isNotEmpty) {
          _selectedPlanIndex = (_plans.length / 2).floor();
        }
      });
    }
  }

  // Helper para ícones/cores baseado no nome/preço se não vier do banco
  Color _getPlanColor(Map<String, dynamic> plan, int index) {
    if (index == 0) return Colors.cyan;
    if (index == 1) return Colors.grey[700]!;
    if (index == 2) return AppColors.primaryRed;
    return const Color(0xFFFFD700);
  }

  Future<void> _initiatePixPayment(Map<String, dynamic> plan) async {
    final userData = await _showPixDataDialog();
    if (userData == null) return;

    setState(() => _isLoading = true);

    final result = await PaymentService().createPixPayment(
      planId: plan['id']?.toString() ?? plan['name'],
      amount: (plan['price'] as num).toDouble(),
      email: userData['email']!,
      cpf: userData['cpf']!,
      name: userData['name']!,
    );

    setState(() => _isLoading = false);

    if (result != null) {
      if (mounted) {
        _showPixResultDialog(
          result,
          (plan['price'] as num).toDouble(),
          plan['name'] ?? 'Plano',
          plan['duration_days'] ?? 30,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao gerar Pix. Verifique os dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, String>?> _showPixDataDialog() async {
    final emailController = TextEditingController();
    final cpfController = TextEditingController();
    final nameController = TextEditingController();

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        emailController.text = user.email ?? '';

        final profile = await AuthService().getUserProfile();
        if (profile != null) {
          nameController.text = profile['full_name'] ?? '';
        }
      }
    } catch (_) {}

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pix, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 12),
            const Text(
              'Pagamento PIX',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Preencha seus dados para gerar o QR Code",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cpfController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'CPF',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                  hintText: '000.000.000-00',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (emailController.text.isEmpty ||
                  cpfController.text.isEmpty ||
                  nameController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text("Preencha todos os campos")),
                );
                return;
              }
              Navigator.pop(ctx, {
                'email': emailController.text.trim(),
                'cpf': cpfController.text.trim(),
                'name': nameController.text.trim(),
              });
            },
            child: const Text('Gerar QR Code'),
          ),
        ],
      ),
    );
  }

  void _showPixResultDialog(
    Map<String, dynamic> data,
    double price,
    String planTitle,
    int daysToAdd,
  ) {
    final paymentId = data['id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PixPaymentDialog(
        paymentId: paymentId,
        price: price,
        planTitle: planTitle,
        qrCode: data['qr_code'],
        qrCodeBase64: data['qr_code_base64'],
        daysToAdd: daysToAdd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : CustomScrollView(
              slivers: [
                // AppBar premium
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.black,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryRed.withOpacity(0.8),
                            Colors.black,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              'STARTFLIX',
                              style: GoogleFonts.bebasNeue(
                                color: Colors.white,
                                fontSize: 36,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Escolha o plano ideal para você',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Conteúdo
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Cards dos planos
                        ...List.generate(_plans.length, (index) {
                          final plan = _plans[index];
                          final isSelected = _selectedPlanIndex == index;
                          final isRecommended = plan['recommended'] == true;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedPlanIndex = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? _getPlanColor(plan, index)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _getPlanColor(
                                            plan,
                                            index,
                                          ).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  // Header do plano
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isRecommended
                                          ? AppColors.primaryRed.withOpacity(
                                              0.1,
                                            )
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        if (isRecommended)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryRed,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'RECOMENDADO',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    plan['name'] ?? 'Plano',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${plan['duration_days']} dias de acesso',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'R\$ ${((plan['price'] ?? 0.0) as num).toStringAsFixed(2)}',
                                                  style: GoogleFonts.outfit(
                                                    color: _getPlanColor(
                                                      plan,
                                                      index,
                                                    ),
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '/período',
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Features
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      child: Column(
                                        children: [
                                          const Divider(color: Colors.grey),
                                          const SizedBox(height: 12),
                                          _buildFeatureItem(
                                            Icons.tv,
                                            'Acesso completo',
                                            _getPlanColor(plan, index),
                                          ),
                                          _buildFeatureItem(
                                            Icons.hd,
                                            'Qualidade máxima disponível',
                                            _getPlanColor(plan, index),
                                          ),
                                          _buildFeatureItem(
                                            Icons.devices,
                                            'Todos os dispositivos',
                                            _getPlanColor(plan, index),
                                          ),
                                          _buildFeatureItem(
                                            Icons.support_agent,
                                            'Suporte Prioritário',
                                            _getPlanColor(plan, index),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Botão de assinar
                        if (_plans.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getPlanColor(
                                  _plans[_selectedPlanIndex],
                                  _selectedPlanIndex,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: _getPlanColor(
                                  _plans[_selectedPlanIndex],
                                  _selectedPlanIndex,
                                ).withOpacity(0.5),
                              ),
                              onPressed: () => _initiatePixPayment(
                                _plans[_selectedPlanIndex],
                              ),
                              child: Text(
                                'ASSINAR ${_plans[_selectedPlanIndex]['name']?.toString().toUpperCase() ?? ''}',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Garantias
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildGuaranteeItem(
                                Icons.lock,
                                'Pagamento 100% Seguro',
                                'Seus dados estão protegidos',
                              ),
                              const Divider(color: Colors.grey, height: 24),
                              _buildGuaranteeItem(
                                Icons.cancel,
                                'Cancele quando quiser',
                                'Sem multas ou taxas',
                              ),
                              const Divider(color: Colors.grey, height: 24),
                              _buildGuaranteeItem(
                                Icons.bolt,
                                'Liberação instantânea',
                                'Acesso imediato após pagamento',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================================
// WIDGET SEPARADO PARA O DIALOG DE PIX
// ========================================
class _PixPaymentDialog extends StatefulWidget {
  final dynamic paymentId;
  final num price;
  final String planTitle;
  final String qrCode;
  final String? qrCodeBase64;
  final int daysToAdd;

  const _PixPaymentDialog({
    required this.paymentId,
    required this.price,
    required this.planTitle,
    required this.qrCode,
    required this.daysToAdd,
    this.qrCodeBase64,
  });

  @override
  State<_PixPaymentDialog> createState() => _PixPaymentDialogState();
}

class _PixPaymentDialogState extends State<_PixPaymentDialog>
    with WidgetsBindingObserver {
  bool _isChecking = false;
  bool _paymentApproved = false;
  String _statusMessage = 'Aguardando pagamento...';
  Timer? _timer;
  int _attempts = 0;
  final int _maxAttempts = 120;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPayment();
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_paymentApproved || _attempts >= _maxAttempts) {
        timer.cancel();
        return;
      }
      _attempts++;
      await _checkPayment();
    });
  }

  Future<void> _checkPayment() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final status = await PaymentService().checkPaymentStatus(
        widget.paymentId,
      );

      if (status != null) {
        final paymentStatus = status['status'];

        if (paymentStatus == 'approved') {
          await _onPaymentApproved();
        } else if (paymentStatus == 'rejected' ||
            paymentStatus == 'cancelled') {
          setState(() => _statusMessage = 'Pagamento $paymentStatus');
          _timer?.cancel();
        } else {
          setState(() => _statusMessage = 'Aguardando pagamento...');
        }
      }
    } catch (e) {
      print('Erro: $e');
    }

    _isChecking = false;
  }

  Future<void> _onPaymentApproved() async {
    _timer?.cancel();

    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _statusMessage = 'Erro: usuário não autenticado');
      return;
    }

    final success = await PaymentService().registerPaymentAndRenew(
      userId: user.id,
      amount: widget.price.toDouble(),
      paymentId: widget.paymentId,
      description: 'Plano ${widget.planTitle}',
      daysToAdd: widget.daysToAdd,
    );

    if (success) {
      setState(() {
        _paymentApproved = true;
        _statusMessage = 'Pagamento aprovado!';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Parabéns! Seu plano ${widget.planTitle} foi ativado!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    } else {
      setState(() {
        _statusMessage = 'Pagamento aprovado, mas houve erro ao ativar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _paymentApproved
                          ? Colors.green.withOpacity(0.2)
                          : AppColors.primaryRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _paymentApproved ? Icons.check_circle : Icons.pix,
                      color: _paymentApproved
                          ? Colors.green
                          : AppColors.primaryRed,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _paymentApproved
                              ? 'Pagamento Confirmado!'
                              : 'Pagamento PIX',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Plano ${widget.planTitle}',
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Valor
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'R\$ ${widget.price.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryRed,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (!_paymentApproved) ...[
                // QR Code
                if (widget.qrCodeBase64 != null &&
                    widget.qrCodeBase64!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Builder(
                      builder: (context) {
                        try {
                          // Remove prefixo data:image/... se existir
                          String base64String = widget.qrCodeBase64!;
                          if (base64String.contains(',')) {
                            base64String = base64String.split(',').last;
                          }
                          // Remove espaços e quebras de linha
                          base64String = base64String
                              .trim()
                              .replaceAll('\n', '')
                              .replaceAll('\r', '');

                          return Image.memory(
                            base64Decode(base64String),
                            height: 180,
                            width: 180,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        } catch (e) {
                          return const Column(
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 100,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Erro ao carregar QR Code",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Código Pix Copia e Cola
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.qrCode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: AppColors.primaryRed,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.qrCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Código copiado!")),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: _paymentApproved
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _paymentApproved ? Colors.green : Colors.blue,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_paymentApproved)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    else
                      const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: GoogleFonts.outfit(
                          color: _paymentApproved ? Colors.green : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_paymentApproved) ...[
                const SizedBox(height: 20),
                const Icon(Icons.celebration, color: Colors.amber, size: 60),
                const SizedBox(height: 12),
                Text(
                  'Aproveite seu acesso!',
                  style: GoogleFonts.outfit(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Botões
              Row(
                children: [
                  if (!_paymentApproved)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (_paymentApproved)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Continuar',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
