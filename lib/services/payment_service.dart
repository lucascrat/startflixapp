import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import 'supabase_helper.dart';

class PaymentService {
  // VPS URL from constants
  final String _vpsUrl = AppConstants.vpsUrl;

  final SupabaseClient _supabase = Supabase.instance.client;

  // Helper to access tables with correct schema/view via SupabaseHelper
  SupabaseQueryBuilder _from(String table) => SupabaseHelper.from(table);
  SupabaseQueryBuilder _table(String table) => SupabaseHelper.table(table);

  /// Get available plans from database
  Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      print('Buscando planos da tabela plans (startflix)...');
      final response = await _from(
        'plans',
      ).select().eq('is_active', true).order('price', ascending: true);

      if (response.isEmpty) {
        throw Exception('Nenhum plano ativo em startflix.plans');
      }
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao carregar planos em startflix: $e');
      try {
        print('Tentando carregar planos da tabela public.plans...');
        final response = await _supabase
            .from('plans')
            .select()
            .eq('is_active', true)
            .order('price', ascending: true);
        return List<Map<String, dynamic>>.from(response);
      } catch (e2) {
        print('Falha total ao carregar planos: $e2');
        return [];
      }
    }
  }

  // Cria um pagamento via Pix usando a VPS (Integração Efí)
  Future<Map<String, dynamic>?> createPixPayment({
    required String planId,
    required double amount,
    required String email,
    required String cpf,
    required String name,
  }) async {
    print('=== CRIANDO PAGAMENTO PIX VIA VPS (EFÍ/GERENCIANET) ===');
    print('URL: $_vpsUrl');

    try {
      final user = _supabase.auth.currentUser;

      // Clean CPF (Numbers only)
      final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

      // Efí/Gerencianet payload pattern via VPS
      final body = {
        'action': 'create', // Maintain compatibility with existing VPS action
        'planId': planId,
        'amount': amount,
        'user': {'id': user?.id, 'email': email, 'name': name},
        'payerData': {'cpf': cleanCpf, 'email': email, 'name': name},
      };

      print('Payload: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(_vpsUrl),
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('VPS Response: $data');

        // Adapt the response fields for the App
        // Efí usually returns txid, pix_copia_e_cola and imagem_qr_code
        return {
          'qr_code':
              data['pix_copia_e_cola'] ??
              data['qr_code'] ??
              data['copyPaste'] ??
              '',
          'qr_code_base64':
              data['imagem_qr_code'] ??
              data['qr_code_base64'] ??
              data['qrcodeImage'] ??
              '',
          'id':
              data['txid'] ?? data['paymentId'] ?? data['id']?.toString() ?? '',
          'status': data['status'] ?? 'pending',
        };
      } else {
        print('Erro VPS (${response.statusCode}): ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao criar Pix na VPS: $e');
      return null;
    }
  }

  /// Verifica o status de um pagamento
  /// Agora verifica na tabela 'payments' do Supabase, pois a VPS deve atualizar lá via Webhook
  Future<Map<String, dynamic>?> checkPaymentStatus(dynamic paymentId) async {
    try {
      print('Verificando status do pagamento: $paymentId');
      // 1. Primeiro tenta na VPS para ver o status real na Efí
      final response = await http.post(
        Uri.parse(_vpsUrl),
        headers: {
          'Content-Type': 'application/json',
          'apikey': AppConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
        },
        body: jsonEncode({'action': 'check', 'txid': paymentId.toString()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Resposta VPS (Check): $data');
        return {
          'id': data['txid'],
          'status': data['status'], // 'approved' ou 'pending'
          'original_status': data['original_status'],
          'pix': data['pix'], // Detalhes do Pix se houver
        };
      }

      print('Falha na VPS check (${response.statusCode}): ${response.body}');

      // 2. Fallback: Busca na tabela payments do Supabase
      // Isso é importante caso o webhook tenha chegado mas a VPS esteja instável
      final dbResponse = await _from(
        'payments',
      ).select().eq('payment_id', paymentId.toString()).maybeSingle();

      if (dbResponse != null) {
        print(
          'Pagamento encontrado no banco de dados: ${dbResponse['status']}',
        );
        return {'id': dbResponse['payment_id'], 'status': dbResponse['status']};
      }

      return {'status': 'pending'};
    } catch (e) {
      print('Erro ao verificar pagamento: $e');
      return {'status': 'pending', 'error': e.toString()};
    }
  }

  /// Registra o pagamento no histórico e renova a assinatura
  Future<bool> registerPaymentAndRenew({
    required String userId,
    required double amount,
    required dynamic paymentId,
    String? description,
    int daysToAdd = 30,
  }) async {
    print('=== REGISTRANDO PAGAMENTO E RENOVANDO ===');
    print('User ID: $userId');
    print('Amount: $amount');
    print('Payment ID: $paymentId');

    try {
      // PASSO 1: Registrar pagamento no histórico
      print('PASSO 1: Verificando/Inserindo na tabela payments...');
      try {
        final paymentIdStr = paymentId.toString();

        // Verificar se já existe para evitar duplicidade
        final existing = await _from(
          'payments',
        ).select('id').eq('payment_id', paymentIdStr).maybeSingle();

        if (existing == null) {
          await _table('payments').insert({
            'user_id': userId,
            'amount': amount,
            'description': description ?? 'Pagamento Pix #$paymentIdStr',
            'payment_id': paymentIdStr,
            'payment_method': 'pix',
            'status': 'approved',
          });
          print('✅ PASSO 1 OK: Pagamento registrado');
        } else {
          print(
            'ℹ️ PASSO 1: Pagamento já existe no histórico, pulando inserção.',
          );
        }
      } catch (e) {
        print('❌ PASSO 1 FALHOU: Erro ao inserir payment: $e');
        // Continuar mesmo se falhar o registro do pagamento
      }

      // PASSO 2: Buscar data de vencimento atual
      print('PASSO 2: Buscando perfil do usuário...');
      Map<String, dynamic>? profile;
      try {
        profile = await _from(
          'profiles',
        ).select('expiration_date').eq('id', userId).maybeSingle();
        print('✅ PASSO 2 OK: Perfil encontrado');
      } catch (e) {
        print('❌ PASSO 2 FALHOU: Erro ao buscar perfil: $e');
        profile = null;
      }

      // PASSO 3: Calcular nova data
      print('PASSO 3: Calculando nova data de vencimento...');
      DateTime newExpirationDate;
      final currentExpiration = profile?['expiration_date'];

      if (currentExpiration != null) {
        try {
          final currentDate = DateTime.parse(currentExpiration);
          if (currentDate.isAfter(DateTime.now())) {
            newExpirationDate = currentDate.add(Duration(days: daysToAdd));
          } else {
            newExpirationDate = DateTime.now().add(Duration(days: daysToAdd));
          }
        } catch (e) {
          newExpirationDate = DateTime.now().add(Duration(days: daysToAdd));
        }
      } else {
        newExpirationDate = DateTime.now().add(Duration(days: daysToAdd));
      }
      print('✅ PASSO 3 OK: Nova data = $newExpirationDate');

      // PASSO 4: Atualizar perfil
      print('PASSO 4: Atualizando perfil...');
      try {
        await _table('profiles')
            .update({
              'expiration_date': newExpirationDate.toIso8601String(),
              'is_active': true,
            })
            .eq('id', userId);
        print('✅ PASSO 4 OK: Perfil atualizado!');
      } catch (e) {
        print('❌ PASSO 4 FALHOU: Erro ao atualizar perfil: $e');
        return false;
      }

      print('🎉 ATIVAÇÃO COMPLETA! Assinatura até: $newExpirationDate');
      return true;
    } catch (e) {
      print('❌ ERRO GERAL: $e');
      return false;
    }
  }

  /// Verifica pagamento em loop (polling) até ser aprovado ou expirar
  Future<bool> waitForPaymentApproval({
    required dynamic paymentId,
    required String userId,
    required double amount,
    String? description,
    int maxAttempts = 60,
    Duration interval = const Duration(seconds: 5),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      print('Verificando pagamento... Tentativa ${i + 1}/$maxAttempts');

      final status = await checkPaymentStatus(paymentId);

      if (status != null) {
        final paymentStatus = status['status'];
        print('Status: $paymentStatus');

        if (paymentStatus == 'approved') {
          print('✅ PAGAMENTO APROVADO!');
          final success = await registerPaymentAndRenew(
            userId: userId,
            amount: amount,
            paymentId: paymentId,
            description: description,
          );
          return success;
        } else if (paymentStatus == 'rejected' ||
            paymentStatus == 'cancelled') {
          print('❌ Pagamento $paymentStatus');
          return false;
        }
      }

      await Future.delayed(interval);
    }

    print('⏰ Timeout');
    return false;
  }
}
