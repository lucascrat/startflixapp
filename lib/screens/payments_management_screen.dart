import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';

// Schema name for Supabase queries
const String _supabaseSchema = 'startflix';

class PaymentsManagementScreen extends StatefulWidget {
  const PaymentsManagementScreen({super.key});

  @override
  State<PaymentsManagementScreen> createState() =>
      _PaymentsManagementScreenState();
}

class _PaymentsManagementScreenState extends State<PaymentsManagementScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  // Helper to access tables with correct schema
  SupabaseQueryBuilder _from(String table) =>
      _supabase.schema(_supabaseSchema).from(table);

  late TabController _tabController;

  // Date Selection for Revenue View
  DateTime _selectedDate = DateTime.now();

  // Data Lists
  List<Map<String, dynamic>> _dayPayments = [];
  List<Map<String, dynamic>> _monthPayments = [];

  // Client Status Lists
  List<Map<String, dynamic>> _expiredClients = [];
  List<Map<String, dynamic>> _expiringClients = []; // expiring in < 5 days
  List<Map<String, dynamic>> _activeClients = [];

  bool _isLoading = true;

  // Revenue Stats
  double _totalToday = 0;
  double _totalMonth = 0;
  int _payingClientsMonth = 0;
  int _paymentsCountToday = 0;

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
      await Future.wait([_loadRevenueStats(), _loadClientStatuses()]);

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRevenueStats() async {
    // 1. Get payments for selected day
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final dayPaymentsResult = await _from('payments')
        .select('*, profiles(full_name, avatar_url, email)')
        .gte('created_at', startOfDay.toUtc().toIso8601String())
        .lt('created_at', endOfDay.toUtc().toIso8601String())
        .order('created_at', ascending: false);

    // 2. Get payments for current month
    final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);

    final monthPaymentsResult = await _from('payments')
        .select('*, profiles(full_name, email)')
        .gte('created_at', startOfMonth.toUtc().toIso8601String())
        .lt('created_at', endOfMonth.toUtc().toIso8601String())
        .order('created_at', ascending: false);

    // 3. Process Stats
    double totalToday = 0;
    for (var payment in dayPaymentsResult) {
      totalToday += (payment['amount'] ?? 0).toDouble();
    }

    double totalMonth = 0;
    Set<String> uniqueClients = {};
    for (var payment in monthPaymentsResult) {
      totalMonth += (payment['amount'] ?? 0).toDouble();
      if (payment['user_id'] != null) {
        uniqueClients.add(payment['user_id']);
      }
    }

    if (!mounted) return;
    setState(() {
      _dayPayments = List<Map<String, dynamic>>.from(dayPaymentsResult);
      _monthPayments = List<Map<String, dynamic>>.from(monthPaymentsResult);
      _totalToday = totalToday;
      _totalMonth = totalMonth;
      _payingClientsMonth = uniqueClients.length;
      _paymentsCountToday = dayPaymentsResult.length;
    });
  }

  Future<void> _loadClientStatuses() async {
    // 1. Fetch all profiles with expiration info
    final profilesResult = await _from('profiles')
        .select('id, full_name, email, expiration_date, avatar_url, phone')
        .not(
          'expiration_date',
          'is',
          null,
        ) // Only interested where expiration is set
        .order(
          'expiration_date',
          ascending: true,
        ); // Show closest to expiry first

    // 2. Fetch latest payment for each user (Optimization: fetch all recent payments and group in app)
    // Fetching last 3 months of payments to find the "latest" relevant one
    final recentPayments = await _from('payments')
        .select('user_id, amount, created_at, status')
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(1000);

    // Create a map of UserID -> LastPayment
    Map<String, Map<String, dynamic>> latestPaymentsMap = {};
    for (var p in recentPayments) {
      final userId = p['user_id'];
      if (userId != null && !latestPaymentsMap.containsKey(userId)) {
        latestPaymentsMap[userId] = p;
      }
    }

    // 3. Process each profile to determine status
    List<Map<String, dynamic>> expired = [];
    List<Map<String, dynamic>> expiring = [];
    List<Map<String, dynamic>> active = [];

    final now = DateTime.now();
    final warningThreshold = now.add(const Duration(days: 5));

    for (var profile in profilesResult) {
      final String? expString = profile['expiration_date'];
      if (expString == null) continue;

      DateTime expirationDate = DateTime.parse(expString).toLocal();
      Map<String, dynamic>? lastPayment = latestPaymentsMap[profile['id']];

      // Build the rich client object
      final clientData = {
        'profile': profile,
        'last_payment': lastPayment,
        'expiration_date': expirationDate,
        'days_until_expire': expirationDate.difference(now).inDays,
      };

      if (expirationDate.isBefore(now)) {
        expired.add(clientData);
      } else if (expirationDate.isBefore(warningThreshold)) {
        expiring.add(clientData);
      } else {
        active.add(clientData);
      }
    }

    if (!mounted) return;
    setState(() {
      _expiredClients = expired;
      _expiringClients = expiring;
      _activeClients = active;
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadRevenueStats(); // Only reload revenue, easier
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadRevenueStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Painel de Pagamentos',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Visão Geral"),
            Tab(text: "Gestão de Clientes"),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildOverviewTab(), _buildClientsTab()],
            ),
    );
  }

  // ============================================
  // TAB 1: OVERVIEW (Receitas e Feed)
  // ============================================
  Widget _buildOverviewTab() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryRed.withOpacity(0.9), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'RESUMO MENSAL',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'R\$ ${_totalMonth.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_monthPayments.length} transações de $_payingClientsMonth clientes',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Date Selector (Same as before)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => _changeDate(-1),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Column(
                          children: [
                            Text(
                              isToday
                                  ? 'HOJE'
                                  : dateFormat.format(_selectedDate),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isToday)
                              Text(
                                DateFormat('EEEE', 'pt_BR').format(
                                  _selectedDate,
                                ), // Requires intl initialized with locale ideally
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: isToday ? Colors.grey[800] : Colors.white,
                      ),
                      onPressed: isToday ? null : () => _changeDate(1),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Stats Row for the selected day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSmallStatCard(
                      'R\$ ${_totalToday.toStringAsFixed(2)}',
                      'Receita do Dia',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallStatCard(
                      '$_paymentsCountToday',
                      'Pagamentos',
                      Icons.receipt,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Transactions Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Transações do Dia',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_dayPayments.isEmpty)
              _buildEmptyState('Nenhum pagamento nesta data')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dayPayments.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(_dayPayments[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // TAB 2: CLIENT STATUS (Gestão)
  // ============================================
  Widget _buildClientsTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF141414),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.primaryRed,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text('VENCIDOS (${_expiredClients.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text('A VENCER (${_expiringClients.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text('EM DIA (${_activeClients.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildClientList(_expiredClients, 'expired'),
                _buildClientList(_expiringClients, 'expiring'),
                _buildClientList(_activeClients, 'active'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList(List<Map<String, dynamic>> clients, String type) {
    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'Nenhum cliente nesta lista',
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        return _buildClientStatusCard(clients[index], type);
      },
    );
  }

  Widget _buildClientStatusCard(Map<String, dynamic> data, String type) {
    final profile = data['profile'];
    final lastPayment = data['last_payment'];
    final DateTime expirationDate = data['expiration_date'];
    final int daysUntil = data['days_until_expire'];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (type == 'expired') {
      statusColor = AppColors.primaryRed;
      statusText = 'Vencido há ${daysUntil.abs()} dias';
      statusIcon = Icons.error_outline;
    } else if (type == 'expiring') {
      statusColor = Colors.orange;
      statusText = 'Vence em $daysUntil dias';
      statusIcon = Icons.timer;
    } else {
      statusColor = Colors.green;
      statusText = 'Em dia';
      statusIcon = Icons.check_circle_outline;
    }

    // Last payment formatting
    String lastPaymentInfo = 'Nenhum pagamento encontrado';
    String monthReference = '';

    if (lastPayment != null) {
      final paymentDate = DateTime.parse(lastPayment['created_at']);
      final amount = (lastPayment['amount'] as num).toDouble();
      final monthName = _getMonthName(paymentDate.month);

      lastPaymentInfo =
          'Último pag: ${DateFormat('dd/MM').format(paymentDate)} (R\$ ${amount.toStringAsFixed(0)})';
      monthReference = 'Ref: $monthName';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[800],
          backgroundImage: profile['avatar_url'] != null
              ? NetworkImage(profile['avatar_url'])
              : null,
          child: profile['avatar_url'] == null
              ? Text(
                  (profile['full_name'] ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          profile['full_name'] ?? 'Sem Nome',
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
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 14),
                const SizedBox(width: 6),
                Text(
                  'Vence: ${DateFormat('dd/MM/yyyy').format(expirationDate)}',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black12,
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.email,
                  'Email',
                  profile['email'] ?? 'Não informado',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.phone,
                  'Telefone',
                  profile['phone'] ?? 'Não informado',
                ),
                const Divider(color: Colors.grey, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Último Pagamento',
                          style: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastPaymentInfo,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (monthReference.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          monthReference,
                          style: GoogleFonts.outfit(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (type == 'expired' && profile['phone'] != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('Cobrar no WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final phone = profile['phone'].toString().replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        );
                        final name = profile['full_name'] ?? 'Cliente';
                        final message = Uri.encodeComponent(
                          'Olá $name, notamos que sua assinatura no StartFlix está vencida. Gostaria de regularizar?',
                        );
                        final url = Uri.parse(
                          'https://wa.me/$phone?text=$message',
                        );

                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Não foi possível abrir o WhatsApp',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // Cards Helpers
  Widget _buildSmallStatCard(
    String value,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> payment) {
    final profile = payment['profiles'] as Map<String, dynamic>?;
    final name = profile?['full_name'] ?? 'Cliente';
    final amount = (payment['amount'] ?? 0).toDouble();
    final date = DateTime.parse(payment['created_at']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[800],
            backgroundImage: profile?['avatar_url'] != null
                ? NetworkImage(profile!['avatar_url'])
                : null,
            child: profile?['avatar_url'] == null
                ? Icon(Icons.person, size: 18, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(date),
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '+ R\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(msg, style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }
}
