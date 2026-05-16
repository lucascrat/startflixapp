import {
  createIcons,
  LayoutDashboard,
  Users,
  CreditCard,
  Monitor,
  Package,
  Settings,
  LogOut,
  RefreshCw,
  DollarSign,
  Zap,
  ZapOff,
  Plus,
  Edit,
  Edit2,
  Trash2,
  UserPlus,
  Unlink,
  User,
  AlertCircle,
  Copy,
  MessageCircle,
  Calendar,
  CheckCircle,
  XCircle,
  Signal,
  SignalLow,
  Trash
} from 'lucide';
import { supabase } from './src/supabase';

// App State
const state = {
  activePage: 'dashboard',
  user: null,
  users: [],
  apps: [],
  plans: [],
  settings: [],
  revenueChart: null,
  realtimeSubscriptions: {} // Track active realtime subscriptions
};

// UI Elements
const loginOverlay = document.getElementById('login-overlay');
const dynamicContent = document.getElementById('dynamic-content');
const dashboardView = document.getElementById('dashboard-view');
const pageTitle = document.getElementById('page-title');
const navLinks = document.querySelectorAll('.nav-link');

function initIcons() {
  try {
    createIcons({
      icons: {
        LayoutDashboard, Users, CreditCard, Monitor, Package, Settings, LogOut, RefreshCw, DollarSign, Zap, ZapOff, Plus, Edit, Edit2, Trash2, UserPlus, Unlink, User, AlertCircle, Copy, MessageCircle, Calendar, CheckCircle, XCircle, Signal, SignalLow, Trash
      }
    });
  } catch (err) {
    console.warn("Lucide Icons error:", err);
  }
}

// --- Initialization ---
async function init() {
  console.log("Admin Panel: Iniciando...");
  console.log("Supabase Client Config:", { 
    url: supabase.supabaseUrl, 
    schema: supabase.options?.db?.schema || 'public (default)'
  });
  initIcons();
  setupSidebar();
  setupModals();
  setupRealtimeSubscriptions(); // Enable auto-refresh

  // Check for active session
  const session = localStorage.getItem('admin_session');
  if (session === 'true') {
    loginOverlay.style.display = 'none';
    navigateTo('dashboard');
  } else {
    loginOverlay.style.display = 'flex';
  }

  // Setup Login Form
  document.getElementById('login-form').addEventListener('submit', handleLogin);
}

function setupSidebar() {
  navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const page = link.getAttribute('data-page');
      navigateTo(page);
    });
  });

  document.getElementById('logout-btn').addEventListener('click', () => {
    supabase.auth.signOut();
    localStorage.removeItem('admin_session');
    location.reload();
  });
}

function setupModals() {
  // User Form
  document.getElementById('user-form')?.addEventListener('submit', handleUserSubmit);
  // App Form
  document.getElementById('app-form')?.addEventListener('submit', handleAppSubmit);
  // Plan Form
  document.getElementById('plan-form')?.addEventListener('submit', handlePlanSubmit);
  // Assign Form
  document.getElementById('assign-form')?.addEventListener('submit', handleAssignSubmit);
  // Settings Form
  document.getElementById('settings-form')?.addEventListener('submit', handleSettingsSubmit);
  // Access Code Form
  document.getElementById('access-code-form')?.addEventListener('submit', handleAccessCodeSubmit);

  // TV Toggle Logic
  const tvEnabled = document.getElementById('user-tv-enabled');
  const tvFields = document.getElementById('tv-fields');
  tvEnabled?.addEventListener('change', (e) => {
    tvFields.style.display = e.target.checked ? 'block' : 'none';
  });

  const tvAuthType = document.getElementById('user-tv-auth-type');
  const authMac = document.getElementById('tv-auth-mac');
  const authEmail = document.getElementById('tv-auth-email');
  tvAuthType?.addEventListener('change', (e) => {
    if (e.target.value === 'mac') {
      authMac.style.display = 'grid';
      authEmail.style.display = 'none';
    } else {
      authMac.style.display = 'none';
      authEmail.style.display = 'grid';
    }
  });
}

// --- Realtime Subscriptions (Auto-Refresh) ---
function setupRealtimeSubscriptions() {
  console.log('📡 Setting up realtime subscriptions...');

  // Subscribe to media_accounts changes (Inventory)
  const inventoryChannel = supabase
    .channel('inventory-changes')
    .on(
      'postgres_changes',
      {
        event: '*', // Listen to INSERT, UPDATE, DELETE
        schema: 'startflix',
        table: 'media_accounts'
      },
      (payload) => {
        console.log('📡 Inventory change detected:', payload.eventType);

        // Only refresh if we're on the inventory page
        if (state.activePage === 'inventory') {
          console.log('🔄 Auto-refreshing inventory view...');
          refreshInventoryData();
        }

        // Also refresh dashboard stats
        if (state.activePage === 'dashboard') {
          loadDashboardData();
        }
      }
    )
    .subscribe((status) => {
      console.log('📡 Inventory subscription status:', status);
    });

  state.realtimeSubscriptions.inventory = inventoryChannel;

  // Subscribe to profiles changes (Users)
  const usersChannel = supabase
    .channel('users-changes')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'startflix',
        table: 'profiles'
      },
      (payload) => {
        console.log('📡 User change detected:', payload.eventType);

        if (state.activePage === 'users') {
          console.log('🔄 Auto-refreshing users view...');
          renderUsersView();
        }

        if (state.activePage === 'dashboard') {
          loadDashboardData();
        }
      }
    )
    .subscribe((status) => {
      console.log('📡 Users subscription status:', status);
    });

  state.realtimeSubscriptions.users = usersChannel;

  // Subscribe to payments changes
  const paymentsChannel = supabase
    .channel('payments-changes')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'startflix',
        table: 'payments'
      },
      (payload) => {
        console.log('📡 Payment change detected:', payload.eventType);

        if (state.activePage === 'payments') {
          console.log('🔄 Auto-refreshing payments view...');
          renderPaymentsView();
        }

        if (state.activePage === 'dashboard') {
          loadDashboardData();
        }
      }
    )
    .subscribe((status) => {
      console.log('📡 Payments subscription status:', status);
    });

  state.realtimeSubscriptions.payments = paymentsChannel;
}

// Fast refresh for inventory without re-rendering entire view
async function refreshInventoryData() {
  try {
    const { data: accounts, error } = await supabase.from('media_accounts')
      .select('*, profiles(email, full_name)')
      .order('created_at', { ascending: false });

    if (error) throw error;

    const total = accounts.length;
    const used = accounts.filter(a => a.user_id).length;
    const free = total - used;

    // Update stats
    const totalEl = document.getElementById('inv-total');
    const freeEl = document.getElementById('inv-free');
    const usedEl = document.getElementById('inv-used');

    if (totalEl) totalEl.innerText = total;
    if (freeEl) freeEl.innerText = free;
    if (usedEl) usedEl.innerText = used;

    // Update table
    const tbody = document.getElementById('inventory-list');
    if (!tbody) return;

    if (total === 0) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhuma conta cadastrada.</td></tr>';
      return;
    }

    tbody.innerHTML = accounts.map(a => {
      const isUsed = !!a.user_id;
      const clientName = a.profiles?.full_name || a.profiles?.email || (isUsed ? 'ID: ' + a.user_id.substr(0, 8) : '---');

      return `
        <tr>
          <td>
            <strong style="color: white;">${a.provider_name || 'Genérico'}</strong>
            <div style="font-size: 0.75rem; color: var(--text-dim);">${a.dns || 'Sem DNS'}</div>
          </td>
          <td>
            <div style="font-family: monospace; font-size: 0.9rem;">
              <span style="color: #aaa;">U:</span> ${a.username}<br>
              <span style="color: #aaa;">P:</span> ${a.password}
            </div>
          </td>
          <td>
            <span class="status-pill ${isUsed ? 'status-inactive' : 'status-active'}" 
                  style="${isUsed ? 'background:rgba(245, 158, 11, 0.1); color:#f59e0b;' : ''}">
              ${isUsed ? 'EM USO' : 'LIVRE'}
            </span>
          </td>
          <td>
            ${isUsed ?
          `<div style="display:flex; align-items:center; gap:0.5rem;">
                 <i data-lucide="user" style="width:14px;"></i> ${clientName}
               </div>`
          : '<span style="opacity:0.3;">---</span>'}
          </td>
          <td>
             <div style="display:flex; gap:0.5rem;">
               ${isUsed ?
          `<button class="btn-icon-small" onclick="releaseInventoryItem('${a.id}')" title="Liberar (Remover Cliente)" style="color:#f59e0b;"><i data-lucide="unlink"></i></button>`
          : `<button class="btn-icon-small" onclick="openAssignModal('${a.id}')" title="Vincular a Cliente" style="color:var(--success);"><i data-lucide="user-plus"></i></button>`}
               <button class="btn-icon-small danger" onclick="deleteInventoryItem('${a.id}')" title="Excluir"><i data-lucide="trash-2"></i></button>
             </div>
          </td>
        </tr>
      `;
    }).join('');

    initIcons();

    // Show toast notification
    showToast('🔄 Lista atualizada automaticamente!', 'success');

  } catch (err) {
    console.error('Error refreshing inventory:', err);
  }
}

// Toast notification helper
window.showToast = function (message, type = 'info') {
  // Remove existing toast
  const existing = document.querySelector('.toast-notification');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.className = 'toast-notification';
  toast.innerHTML = message;
  toast.style.cssText = `
    position: fixed;
    bottom: 100px;
    right: 20px;
    background: ${type === 'success' ? 'rgba(16, 185, 129, 0.95)' : type === 'error' ? 'rgba(239, 68, 68, 0.95)' : 'rgba(59, 130, 246, 0.95)'};
    color: white;
    padding: 12px 20px;
    border-radius: 10px;
    font-size: 0.85rem;
    font-weight: 500;
    z-index: 9999;
    animation: slideInRight 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
    box-shadow: 0 4px 20px rgba(0,0,0,0.3);
  `;

  document.body.appendChild(toast);

  setTimeout(() => {
    toast.remove();
  }, 3000);
}

// Add animation styles
const toastStyles = document.createElement('style');
toastStyles.textContent = `
  @keyframes slideInRight {
    from { transform: translateX(100px); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
  }
  @keyframes fadeOut {
    from { opacity: 1; }
    to { opacity: 0; }
  }
`;
document.head.appendChild(toastStyles);
async function navigateTo(page) {
  state.activePage = page;

  // Update UI active state
  navLinks.forEach(l => l.classList.toggle('active', l.getAttribute('data-page') === page));

  // Hide all main views
  dashboardView.style.display = 'none';
  dynamicContent.style.display = 'block';

  // Update Title
  const titles = {
    dashboard: 'Dashboard',
    users: 'Gestão de Clientes',
    payments: 'Histórico de Pagamentos',
    apps: 'Listas e Aplicativos',
    inventory: 'Estoque / Mídia',
    settings: 'Configurações do Sistema',
    access_codes: 'Códigos de Acesso'
  };
  pageTitle.innerText = titles[page] || 'Painel';

  // Render specific view
  switch (page) {
    case 'dashboard':
      dashboardView.style.display = 'block';
      dynamicContent.style.display = 'none';
      loadDashboardData();
      break;
    case 'users':
      renderUsersView();
      break;
    case 'apps':
      renderAppsView();
      break;
    case 'plans':
      renderPlansView();
      break;
    case 'payments':
      renderPaymentsView();
      break;
    case 'inventory':
      renderInventoryView();
      break;
    case 'settings':
      renderSettingsView();
      break;
    case 'access_codes':
      renderAccessCodesView();
      break;
    default:
      dynamicContent.innerHTML = `<div class="stat-card"><h3>Em breve: ${page}</h3></div>`;
  }

  initIcons();
}

// --- Dashboard Logic ---
// --- Dashboard Logic ---
async function loadDashboardData() {
  try {
    // Total Users
    const { count: uCount, error: uCountErr } = await supabase.from('profiles').select('*', { count: 'exact', head: true });
    if (uCountErr) {
      console.error('Erro ao buscar total de usuários:', uCountErr);
      showToast('Erro ao carregar total de usuários: ' + uCountErr.message, 'error');
    }
    document.getElementById('total-users').innerText = uCount || 0;

    // Subscriptions Status
    const { data: allUsers, error: allUsersErr } = await supabase.from('profiles').select('expiration_date');
    if (allUsersErr) {
      console.error('Erro ao buscar status de assinaturas:', allUsersErr);
    }
    const now = new Date();
    const active = allUsers?.filter(u => u.expiration_date && new Date(u.expiration_date) > now).length || 0;
    const expired = (uCount || 0) - active;

    document.getElementById('active-subs').innerText = active;
    document.getElementById('expired-subs').innerText = expired;

    // Monthly Revenue & Chart Data
    // Fetch distinct payments to avoid issues with views
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).toISOString();

    const { data: payments, error: payErr } = await supabase.from('payments')
      .select('amount, created_at, status')
      .eq('status', 'approved')
      .order('created_at', { ascending: true });

    if (payErr) console.error('Error fetching payments for dashboard:', payErr);

    const currentMonthTotal = payments?.filter(p => p.created_at >= startOfMonth)
      .reduce((acc, curr) => acc + curr.amount, 0) || 0;

    document.getElementById('total-revenue').innerText = `R$ ${currentMonthTotal.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;

    // Recent Payments Table (Limit 5)
    // We fetch a fresh slice for the list to include profile info (optional, or just stick to basic for now and let the full view handle details)
    // To match the Dashboard "Últimos Pix" we just show basic info or do a join if we want names.
    // Let's stick to the basic join-like manual fetch or just raw data if that's what was there. 
    // The previous code called `renderRecentPayments(pData)`.
    // Let's do a separate query for recent payments with names.

    const { data: recentPayments } = await supabase.from('payments')
      .select('payment_id, amount, created_at, user_id')
      .eq('status', 'approved')
      .order('created_at', { ascending: false })
      .limit(5);

    // Fetch profiles for these recent payments to show names
    if (recentPayments && recentPayments.length > 0) {
      const userIds = recentPayments.map(p => p.user_id);
      const { data: profiles } = await supabase.from('profiles').select('id, full_name, email').in('id', userIds);

      recentPayments.forEach(p => {
        const profile = profiles?.find(u => u.id === p.user_id);
        p.user_name = profile?.full_name || profile?.email || 'Desconhecido';
      });
    }

    renderRecentPayments(recentPayments);

    // Initialize/Update Chart
    initRevenueChart(payments);

  } catch (err) {
    console.error("Erro dashboard:", err);
    showToast("Erro ao carrergar dados do dashboard: " + err.message, "error");
  }
}

function initRevenueChart(payments) {
  const ctx = document.getElementById('revenueChart')?.getContext('2d');
  if (!ctx || !payments) return;

  // Process data for the last 7 days
  const last7Days = [...Array(7)].map((_, i) => {
    const d = new Date();
    d.setDate(d.getDate() - (6 - i));
    return d.toISOString().split('T')[0];
  });

  const revenueData = last7Days.map(date => {
    return payments
      .filter(p => p.created_at.startsWith(date))
      .reduce((acc, curr) => acc + curr.amount, 0);
  });

  if (state.revenueChart) {
    state.revenueChart.destroy();
  }

  state.revenueChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: last7Days.map(d => new Date(d).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' })),
      datasets: [{
        label: 'Receita (R$)',
        data: revenueData,
        borderColor: '#e50914',
        backgroundColor: 'rgba(229, 9, 20, 0.1)',
        fill: true,
        tension: 0.4,
        borderWidth: 3,
        pointRadius: 4,
        pointBackgroundColor: '#e50914'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: 'rgba(255, 255, 255, 0.05)' },
          ticks: { color: '#94a3b8' }
        },
        x: {
          grid: { display: false },
          ticks: { color: '#94a3b8' }
        }
      }
    }
  });
}

function renderRecentPayments(payments) {
  const tbody = document.getElementById('payments-list');
  if (!tbody) return;

  if (!payments || payments.length === 0) {
    tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhum pagamento.</td></tr>';
    return;
  }
  tbody.innerHTML = payments.map(p => {
    const amountVal = p.amount ? Number(p.amount) : 0;
    return `
    <tr>
      <td>
        <div style="font-weight: 600;">${p.user_name || 'Pix User'}</div>
        <div style="font-size: 0.75rem; color: var(--text-dim);">${p.payment_id || new Date(p.created_at).toLocaleDateString()}</div>
      </td>
      <td>R$ ${amountVal.toFixed(2)}</td>
      <td>
        <i data-lucide="copy" class="copy-btn" onclick="navigator.clipboard.writeText('${p.payment_id}')" title="Copiar ID"></i>
      </td>
    </tr>
  `}).join('');
  initIcons();
}

// --- Users View (Payment Dashboard) ---
async function renderUsersView() {
  dynamicContent.innerHTML = `
    <div class="animate-fade-in">
      <div class="dashboard-header-custom" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem;">
         <div>
            <h2 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Gestão de Assinantes</h2>
            <p style="color: var(--text-dim);">Controle total de vencimentos e pagamentos.</p>
         </div>
         <button class="btn btn-primary" onclick="confirmMassRenew()" style="background-color: #f59e0b; color: black; margin-right: 10px;">
            <i data-lucide="zap"></i> Renovar Todos (+30d)
         </button>
         <button class="btn btn-primary" onclick="liberarTodos()" style="background-color: #22c55e; color: black; margin-right: 10px;">
            <i data-lucide="zap"></i> Liberar Todos
         </button>
         <button class="btn btn-primary" onclick="document.getElementById('user-modal').style.display='flex'; document.getElementById('user-form').reset(); document.getElementById('user-id').value='';">
            <i data-lucide="plus"></i> Novo Assinante
          </button>
      </div>

      <!-- Stats Summary -->
      <div class="stats-grid" id="client-stats" style="margin-bottom: 2rem;">
         <div style="padding: 2rem; text-align: center;">Carregando estatísticas...</div>
      </div>

      <!-- Filters/Tabs -->
      <div class="table-header" style="background: transparent; border: none; padding: 0; margin-bottom: 1rem; flex-direction: column; align-items: flex-start; gap: 1rem;">
         <div style="display: flex; gap: 2rem; border-bottom: 1px solid var(--border); width: 100%; padding-bottom: 0;">
            <button class="tab-btn active" onclick="filterUsers('all', this)" id="tab-all">Todos</button>
            <button class="tab-btn" onclick="filterUsers('expired', this)" id="tab-expired">Vencidos <span class="badge-count" id="count-expired">0</span></button>
            <button class="tab-btn" onclick="filterUsers('expiring', this)" id="tab-expiring">Próx. Vencimento <span class="badge-count" id="count-expiring">0</span></button>
            <button class="tab-btn" onclick="filterUsers('active', this)" id="tab-active">Em Dia</button>
         </div>
         <input type="text" id="user-search" placeholder="Buscar por nome, email ou status..." style="width: 100%; max-width: 400px; padding: 0.8rem 1rem; background: rgba(255,255,255,0.05); border: 1px solid var(--border); border-radius: 8px; color: white;">
      </div>
      
      <div id="users-grid" class="users-grid">
         <div style="padding: 2rem; grid-column: 1/-1; text-align: center;">Carregando clientes...</div>
      </div>
    </div>
  `;
  initIcons();

  // Load Data - Direto na tabela física para evitar problemas com Views
  const { data: usersData, error: uErr } = await supabase.from('profiles').select('*').order('created_at', { ascending: false });
  const { data: paymentsData, error: pErr } = await supabase.from('payments').select('*').eq('status', 'approved').order('created_at', { ascending: false });

  if (uErr) {
    console.error(uErr);
    document.getElementById('users-grid').innerHTML = `<div style="padding: 2rem; color: var(--danger); grid-column: 1/-1;">Erro ao carregar clientes: ${uErr.message || JSON.stringify(uErr)}</div>`;
    document.getElementById('client-stats').innerHTML = `<div style="padding: 2rem; color: var(--danger);">Falha no Schema/RLS</div>`;
    showToast(`Erro Supabase: ${uErr.message}`, 'error');
    return;
  }

  // Process Data
  const now = new Date();
  const warningThreshold = new Date();
  warningThreshold.setDate(now.getDate() + 5);

  const processedUsers = (usersData || []).map(u => {
    const expiry = u.expiration_date ? new Date(u.expiration_date) : null;
    const isExpired = !expiry || expiry < now;
    const isExpiring = !isExpired && expiry < warningThreshold;

    // Payment Info
    const userPayments = paymentsData ? paymentsData.filter(p => p.user_id === u.id) : [];
    const lastPayment = userPayments.length > 0 ? userPayments[0] : null;

    let status = 'active';
    if (isExpired) status = 'expired';
    else if (isExpiring) status = 'expiring';

    return {
      ...u,
      status,
      expiryDate: expiry,
      lastPayment,
      paymentsCount: userPayments.length
    };
  });

  state.users = processedUsers;

  // Render Stats
  const total = processedUsers.length;
  const expiredCount = processedUsers.filter(u => u.status === 'expired').length;
  const expiringCount = processedUsers.filter(u => u.status === 'expiring').length;
  const activeCount = processedUsers.filter(u => u.status === 'active').length;

  document.getElementById('count-expired').innerText = expiredCount;
  document.getElementById('count-expiring').innerText = expiringCount;

  document.getElementById('client-stats').innerHTML = `
    <div class="stat-card">
      <div class="stat-label">Total Clientes</div>
      <div class="stat-value">${total}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: var(--danger);">Vencidos</div>
       <div class="stat-value" style="color: var(--danger);">${expiredCount}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: #f59e0b;">A Vencer (5 dias)</div>
       <div class="stat-value" style="color: #f59e0b;">${expiringCount}</div>
    </div>
    <div class="stat-card">
       <div class="stat-label" style="color: var(--success);">Em Dia</div>
       <div class="stat-value" style="color: var(--success);">${activeCount}</div>
    </div>
  `;

  // Render Grid Function
  // Moved to global scope below

  document.getElementById('user-search').addEventListener('input', () => {
    const activeTab = document.querySelector('.tab-btn.active');
    const type = activeTab ? activeTab.id.replace('tab-', '') : 'all';
    window.filterUsers(type, activeTab);
  });

  // Initial Render (All)
  window.filterUsers('all', document.getElementById('tab-all'));
}

// Global Filter Function
window.filterUsers = (filterType, btnElement) => {
  if (btnElement) {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btnElement.classList.add('active');
  }

  const searchInput = document.getElementById('user-search');
  const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';

  const filtered = state.users.filter(u => {
    const matchesSearch = (u.full_name?.toLowerCase() || '').includes(searchTerm) || (u.email?.toLowerCase() || '').includes(searchTerm);
    if (!matchesSearch) return false;

    if (filterType === 'all') return true;
    return u.status === filterType;
  });

  renderUserGrid(filtered);
};

function renderUserGrid(usersList) {
  const grid = document.getElementById('users-grid');
  if (usersList.length === 0) {
    grid.innerHTML = '<div style="padding: 2rem; grid-column: 1/-1; text-align: center; color: var(--text-dim);">Nenhum cliente encontrado nesta categoria.</div>';
    return;
  }

  grid.innerHTML = usersList.map(u => {
    const expiryFormatted = u.expiryDate ? u.expiryDate.toLocaleDateString('pt-BR') : 'Sem data';

    // Last Payment Logic
    let paymentInfo = '<span style="color: var(--text-dim); font-size: 0.8rem;">Nunca pagou</span>';
    if (u.lastPayment) {
      const lpDate = new Date(u.lastPayment.created_at);
      const monthName = lpDate.toLocaleDateString('pt-BR', { month: 'long' });
      paymentInfo = `
                <div style="font-size: 0.85rem; color: #fff;">
                   <i data-lucide="calendar" style="width: 12px; display: inline; margin-right: 4px;"></i>
                   ${lpDate.toLocaleDateString('pt-BR')}
                </div>
                <div style="font-size: 0.75rem; color: var(--success); margin-top: 2px;">
                   Ref: <strong>${monthName.charAt(0).toUpperCase() + monthName.slice(1)}</strong>
                </div>
            `;
    }

    // WhatsApp Logic
    let whatsappBtn = '';
    if (u.status === 'expired') {
      const phone = ''; // We don't have phone in profiles yet, but specific logic requested.
      // If we had phone: const phone = u.phone ...
      // Assuming no phone for now, or we can look for it in metadata if stored.
      // Using a generic link or manual for now as 'Cobrar' button.
      // StartFlix usually doesn't capture phone on signup based on my memory, 
      // but the Flutter code checked 'profile['phone']'. 
      // I'll check if 'phone' exists in vw_profiles. Assuming yes or null.

      const msg = encodeURIComponent(`Olá ${u.full_name || 'Cliente'}, sua assinatura venceu em ${expiryFormatted}. Regularize agora para continuar assistindo!`);
      const phoneNum = u.phone || '';

      if (phoneNum) {
        whatsappBtn = `
                <a href="https://wa.me/${phoneNum.replace(/\D/g, '')}?text=${msg}" target="_blank" class="btn btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem; background: #25D366; border: none;">
                    <i data-lucide="message-circle"></i> Cobrar no WhatsApp
                </a>
                `;
      } else {
        // Open whatsapp list to search manually or just show button that asks for number
        whatsappBtn = `
                <button onclick="promptWhatsApp('${u.full_name}', '${expiryFormatted}')" class="btn btn-primary" style="width: 100%; justify-content: center; margin-top: 1rem; background: #25D366; border: none;">
                    <i data-lucide="message-circle"></i> Cobrar (WhatsApp)
                </button>
                `;
      }
    }

    let statusBadge = '';
    if (u.status === 'expired') statusBadge = '<span class="status-pill status-inactive">VENCIDO</span>';
    else if (u.status === 'expiring') statusBadge = '<span class="status-pill" style="background: rgba(245, 158, 11, 0.2); color: #f59e0b;">A VENCER</span>';
    else statusBadge = '<span class="status-pill status-active">ATIVO</span>';

    return `
            <div class="user-card" style="border-left: 4px solid ${u.status === 'expired' ? 'var(--danger)' : (u.status === 'expiring' ? '#f59e0b' : 'var(--success)')};">
               <div style="display: flex; justify-content: space-between; margin-bottom: 1rem;">
                  <div style="display: flex; gap: 1rem; align-items: center;">
                      <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(u.full_name || 'U')}&background=random" class="user-avatar-small">
                      <div>
                          <div style="font-weight: bold; font-size: 1.1rem;">${u.full_name || 'Sem Nome'}</div>
                          <div style="color: var(--text-dim); font-size: 0.85rem;">${u.email}</div>
                      </div>
                  </div>
                  <div class="card-options">
                      <button class="btn-icon-small" onclick="editUser('${u.id}')"><i data-lucide="edit-2"></i></button>
                  </div>
               </div>

               <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; background: rgba(0,0,0,0.2); padding: 1rem; border-radius: 8px;">
                   <div>
                       <div style="font-size: 0.7rem; text-transform: uppercase; color: var(--text-dim); margin-bottom: 4px;">Vencimento</div>
                       <div style="font-size: 1rem; font-weight: bold;">${expiryFormatted}</div>
                       <div style="margin-top: 4px;">${statusBadge}</div>
                   </div>
                   <div>
                       <div style="font-size: 0.7rem; text-transform: uppercase; color: var(--text-dim); margin-bottom: 4px;">Último Pagamento</div>
                       ${paymentInfo}
                   </div>
               </div>

               ${whatsappBtn}
               
               <!-- Link M3U Proprietário (IBO Player / Outros) -->
               <div style="margin-top: 1rem; border: 1px dashed rgba(255, 255, 255, 0.2); padding: 0.75rem; border-radius: 10px; background: rgba(255, 255, 255, 0.03);">
                   <div style="font-size: 0.65rem; color: var(--text-dim); text-transform: uppercase; margin-bottom: 6px; letter-spacing: 0.05em;">Link M3U (Para IBO Player / SS IPTV)</div>
                   <div style="display: flex; gap: 0.5rem; align-items: center;">
                       <div style="font-family: monospace; font-size: 0.75rem; color: var(--primary-light); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; background: rgba(0,0,0,0.3); padding: 4px 8px; border-radius: 4px;">
                           https://m3ustartflix.appbr.pro/${u.id}.m3u
                       </div>
                       <button class="btn-icon-small" title="Copiar Link" onclick="navigator.clipboard.writeText('https://m3ustartflix.appbr.pro/${u.id}.m3u'); showToast('🔗 Link M3U copiado!', 'success');">
                           <i data-lucide="copy" style="width: 14px;"></i>
                       </button>
                   </div>
                   <div style="font-size: 0.6rem; color: var(--text-muted); margin-top: 5px;">
                       * Formato compatível com Smart TVs e TV Boxes.
                   </div>
               </div>

               <div style="display: flex; gap: 0.5rem; margin-top: 1rem;">
                   ${u.has_signal ?
        `<button onclick="toggleSignal('${u.id}', false)" class="btn btn-ghost" style="flex: 1; color: var(--danger); background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); justify-content: center; font-size: 0.75rem; padding: 0.6rem;">
                           <i data-lucide="zap-off" style="width: 14px;"></i> Bloquear Sinal
                       </button>` :
        `<button onclick="toggleSignal('${u.id}', true)" class="btn btn-primary" style="flex: 1; background: var(--success); border: none; justify-content: center; font-size: 0.75rem; padding: 0.6rem;">
                           <i data-lucide="zap" style="width: 14px;"></i> Liberar Sinal
                       </button>`
      }
               </div>
            </div>
        `;
  }).join('');
  initIcons();
}

// Global helper for manual whatsapp prompt since we might not have phone numbers
window.promptWhatsApp = (name, expiry) => {
  const phone = prompt(`Digite o número do WhatsApp para cobrar ${name}:`, "");
  if (phone) {
    const msg = encodeURIComponent(`Olá ${name}, sua assinatura venceu em ${expiry}. Regularize agora para continuar assistindo!`);
    window.open(`https://wa.me/${phone.replace(/\D/g, '')}?text=${msg}`, '_blank');
  }
};

window.toggleSignal = async (userId, status) => {
  try {
    const { error } = await supabase.from('profiles').update({ has_signal: status }).eq('id', userId);
    if (error) throw error;

    // Se estiver bloqueando, vamos forçar a liberação do media_account no banco para que outro possa usar
    if (!status) {
      await supabase.rpc('release_signal', { p_user_id: userId });
    }

    showToast(status ? "Sinal liberado para o cliente!" : "Sinal bloqueado!", "success");
    renderUsersView();
  } catch (err) {
    showToast("Erro ao alterar sinal: " + err.message, "error");
  }
};

// --- Apps/Lists View ---
async function renderAppsView() {
  dynamicContent.innerHTML = `
    <div class="data_container animate-fade-in">
      <div class="table-header">
        <h3>Apps dos Clientes</h3>
        <button class="btn btn-primary" onclick="document.getElementById('app-modal').style.display='flex'; document.getElementById('app-form').reset(); document.getElementById('app-id-field').value='';">
          <i data-lucide="plus"></i> Configurar Novo App
        </button>
      </div>
      <div class="stats-grid" id="apps-grid" style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));">
        <div style="padding: 2rem;">Carregando...</div>
      </div>
    </div>
  `;

  try {
    const { data: apps, error } = await supabase.from('apps').select('*').order('created_at', { ascending: false });
    if (error) throw error;

    const grid = document.getElementById('apps-grid');
    if (!grid) return;

    if (!apps || apps.length === 0) {
      grid.innerHTML = '<div style="padding: 2rem;">Nenhum app configurado.</div>';
      return;
    }

    grid.innerHTML = apps.map(a => `
      <div class="stat-card app-card">
        <div class="app-banner" style="height: 120px; background: #222; border-radius: 8px; overflow: hidden; display: flex; align-items: center; justify-content: center; position: relative;">
          ${a.image_url ? `<img src="${a.image_url}" style="width: 100%; height: 100%; object-fit: cover;">` : `<i data-lucide="monitor" style="width: 48px; height: 48px; opacity: 0.2;"></i>`}
          <div style="position: absolute; top: 8px; right: 8px; display: flex; gap: 4px;">
             <button class="btn" style="padding: 0.3rem; background: rgba(0,0,0,0.5); border-radius: 6px;" onclick="editApp('${a.id}')"><i data-lucide="edit" style="width: 14px; color: #fff;"></i></button>
             <button class="btn" style="padding: 0.3rem; background: rgba(229, 9, 20, 0.5); border-radius: 6px;" onclick="deleteApp('${a.id}')"><i data-lucide="trash-2" style="width: 14px; color: #fff;"></i></button>
          </div>
        </div>
        <div style="margin-top: 1rem;">
          <div style="display: flex; justify-content: space-between; align-items: start;">
             <strong style="font-size: 1.1rem; color: #e50914;">${a.name}</strong>
             <span class="status-pill status-active" style="font-size: 0.7rem; text-transform: uppercase;">${a.auth_type}</span>
          </div>
          <p style="font-size: 0.8rem; color: var(--text-dim); margin-top: 0.5rem; word-break: break-all;">${a.download_url}</p>
        </div>
      </div>
    `).join('');
    initIcons();
  } catch (err) {
    console.error("Error apps:", err);
    const grid = document.getElementById('apps-grid');
    if (grid) grid.innerHTML = `<div style="padding: 2rem; color: var(--danger);">Erro: ${err.message}</div>`;
  }
}

// --- Inventory View (Estoque) ---
async function renderInventoryView() {
  dynamicContent.innerHTML = `
    <div class="animate-fade-in">
      <!-- Master Link Global Section -->
      <div style="background: linear-gradient(135deg, rgba(229, 9, 20, 0.1) 0%, rgba(0,0,0,0.4) 100%); border: 1px solid var(--primary); padding: 1.5rem; border-radius: 15px; margin-bottom: 2rem; display: flex; align-items: center; justify-content: space-between; gap: 2rem;">
          <div style="flex: 1;">
              <h3 style="color: var(--primary-light); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                <i data-lucide="zap"></i> Link M3U Master (Global)
              </h3>
              <p style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.4;">
                Use este link único para qualquer player externo. Ele busca automaticamente uma lista disponível no seu estoque e a libera por <strong>1 hora</strong> para o usuário antes de rotacionar.
              </p>
          </div>
          <div style="background: rgba(0,0,0,0.3); padding: 1rem; border-radius: 12px; border: 1px solid rgba(255,255,255,0.1); flex: 1; display: flex; align-items: center; gap: 1rem;">
              <div style="font-family: monospace; font-size: 0.85rem; color: var(--text-main); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1;">
                https://m3ustartflix.appbr.pro/master.m3u
              </div>
              <button class="btn btn-primary btn-sm" onclick="navigator.clipboard.writeText('https://m3ustartflix.appbr.pro/master.m3u'); showToast('🔗 Link Master Copiado!', 'success');">
                <i data-lucide="copy" style="width: 16px;"></i> Copiar
              </button>
          </div>
      </div>

      <div class="table-header">
        <h3>Estoque de Contas (IPTV/Mídia)</h3>
        <button class="btn btn-primary" onclick="openInventoryModal()">
          <i data-lucide="plus"></i> Adicionar Conta
        </button>
      </div>

      <!-- Stats -->
      <div class="stats-grid" style="margin-bottom: 2rem; margin-top: 1rem;">
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label">Total Contas</div>
          <div class="stat-value" id="inv-total">0</div>
        </div>
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label" style="color: var(--success);">Disponíveis</div>
          <div class="stat-value" id="inv-free" style="color: var(--success);">0</div>
        </div>
        <div class="stat-card" style="padding: 1.5rem;">
          <div class="stat-label" style="color: var(--warning);">Em Uso</div>
          <div class="stat-value" id="inv-used" style="color: var(--warning);">0</div>
        </div>
      </div>

      <div class="data-table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Fornecedor</th>
              <th>Login info</th>
              <th>Status</th>
              <th>Cliente Atual</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody id="inventory-list">
            <tr><td colspan="5" style="text-align:center; padding: 2rem;">Carregando...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  `;
  initIcons();

  // Fetch Data
  try {
    // We need to fetch profiles via user_id, but supabase-js simple query might simply return the ID.
    // Ideally we join, but let's try simple first to not break if permissions are weird on join.
    // select(*, profiles(email))
    const { data: accounts, error } = await supabase.from('media_accounts')
      .select('*, profiles(email, full_name)') // Trying join since I fixed profiles RLS
      .order('created_at', { ascending: false });

    if (error) throw error;

    const total = accounts.length;
    const used = accounts.filter(a => a.user_id).length;
    const free = total - used;

    document.getElementById('inv-total').innerText = total;
    document.getElementById('inv-free').innerText = free;
    document.getElementById('inv-used').innerText = used;

    const tbody = document.getElementById('inventory-list');
    if (total === 0) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhuma conta cadastrada.</td></tr>';
      return;
    }

    tbody.innerHTML = accounts.map(a => {
      const isUsed = !!a.user_id;
      const clientName = a.profiles?.full_name || a.profiles?.email || (isUsed ? 'ID: ' + a.user_id.substr(0, 8) : '---');

      return `
        <tr>
          <td>
            <strong style="color: white;">${a.provider_name || 'Genérico'}</strong>
            <div style="font-size: 0.75rem; color: var(--text-dim);">${a.dns || 'Sem DNS'}</div>
          </td>
          <td>
            <div style="font-family: monospace; font-size: 0.9rem;">
              <span style="color: #aaa;">U:</span> ${a.username}<br>
              <span style="color: #aaa;">P:</span> ${a.password}
            </div>
          </td>
          <td>
            <span class="status-pill ${isUsed ? 'status-inactive' : 'status-active'}" 
                  style="${isUsed ? 'background:rgba(245, 158, 11, 0.1); color:#f59e0b;' : ''}">
              ${isUsed ? 'EM USO' : 'LIVRE'}
            </span>
          </td>
          <td>
            ${isUsed ?
          `<div style="display:flex; align-items:center; gap:0.5rem;">
                 <i data-lucide="user" style="width:14px;"></i> ${clientName}
               </div>`
          : '<span style="opacity:0.3;">---</span>'}
          </td>
          <td>
             <div style="display:flex; gap:0.5rem;">
               ${isUsed ?
          `<button class="btn-icon-small" onclick="releaseInventoryItem('${a.id}')" title="Liberar (Remover Cliente)" style="color:#f59e0b;"><i data-lucide="unlink"></i></button>`
          : `<button class="btn-icon-small" onclick="openAssignModal('${a.id}')" title="Vincular a Cliente" style="color:var(--success);"><i data-lucide="user-plus"></i></button>`}
               <button class="btn-icon-small danger" onclick="deleteInventoryItem('${a.id}')" title="Excluir"><i data-lucide="trash-2"></i></button>
             </div>
          </td>
        </tr>
      `;
    }).join('');
    initIcons();

  } catch (err) {
    console.error(err);
    document.getElementById('inventory-list').innerHTML = `<tr><td colspan="5" style="color:red; text-align:center;">Erro: ${err.message}</td></tr>`;
  }
}

// Handlers
window.openInventoryModal = () => {
  document.getElementById('inv-form').reset();
  document.getElementById('inventory-modal').style.display = 'flex';
};

window.handleInventorySubmit = async (e) => {
  e.preventDefault();
  const provider = document.getElementById('inv-provider').value;
  const username = document.getElementById('inv-user').value;
  const password = document.getElementById('inv-pass').value;
  const dns = document.getElementById('inv-dns').value;

  try {
    const { error } = await supabase.from('media_accounts').insert({
      provider_name: provider,
      username,
      password,
      dns
    });

    if (error) throw error;

    showToast("Conta adicionada ao estoque!", "success");
    document.getElementById('inventory-modal').style.display = 'none';
    renderInventoryView();
  } catch (err) {
    showToast("Erro: " + err.message, "error");
  }
};

window.deleteInventoryItem = async (id) => {
  if (confirm("Excluir esta conta do estoque?")) {
    await supabase.from('media_accounts').delete().eq('id', id);
    renderInventoryView();
  }
};

window.releaseInventoryItem = async (id) => {
  if (confirm("Desvincular cliente desta conta? Ela voltará a ficar LIVRE.")) {
    await supabase.from('media_accounts').update({ user_id: null }).eq('id', id);
    renderInventoryView();
  }
};

window.openAssignModal = async (accountId) => {
  document.getElementById('assign-account-id').value = accountId;
  const userSelect = document.getElementById('assign-user-id');
  userSelect.innerHTML = '<option value="">Carregando clientes...</option>';
  document.getElementById('assign-modal').style.display = 'flex';

  try {
    const { data: users } = await supabase.from('profiles').select('id, full_name, email').order('full_name');
    if (users) {
      userSelect.innerHTML = '<option value="">Selecione um Cliente</option>' +
        users.map(u => `<option value="${u.id}">${u.full_name || u.email}</option>`).join('');
    }
  } catch (err) {
    userSelect.innerHTML = '<option value="">Erro ao carregar clientes</option>';
  }
};

window.handleAssignSubmit = async (e) => {
  e.preventDefault();
  const accountId = document.getElementById('assign-account-id').value;
  const userId = document.getElementById('assign-user-id').value;

  if (!userId) {
    showToast("Selecione um cliente!", "warning");
    return;
  }

  try {
    const { error } = await supabase.from('media_accounts').update({ user_id: userId }).eq('id', accountId);
    if (error) throw error;

    showToast("Conta vinculada com sucesso!", "success");
    document.getElementById('assign-modal').style.display = 'none';
    renderInventoryView();
  } catch (err) {
    showToast("Erro ao vincular: " + err.message, "error");
  }
};

// --- Plans View (Existing) ---
async function renderPlansView() {
  dynamicContent.innerHTML = `
    <div class="data-table-container animate-fade-in">
      <div class="table-header">
        <h3>Planos de Assinatura</h3>
        <button class="btn btn-primary" onclick="document.getElementById('plan-modal').style.display='flex'; document.getElementById('plan-form').reset(); document.getElementById('plan-id').value='';">
          <i data-lucide="plus"></i> Novo Plano
        </button>
      </div>
      <div class="stats-grid" id="plans-grid" style="grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));">
        <div style="padding: 2rem;">Carregando...</div>
      </div>
    </div>
  `;

  try {
    const { data: plans, error } = await supabase.from('plans').select('*').order('price', { ascending: true });
    if (error) throw error;

    const grid = document.getElementById('plans-grid');
    if (!grid) return;

    if (!plans || plans.length === 0) {
      grid.innerHTML = '<div style="padding: 2rem;">Nenhum plano cadastrado.</div>';
      return;
    }

    grid.innerHTML = plans.map(p => {
      const priceVal = p.price ? Number(p.price) : 0;
      return `
      <div class="stat-card">
        <div style="display: flex; justify-content: space-between; align-items: start;">
          <div class="stat-icon" style="background: rgba(229, 9, 20, 0.1); color: #e50914;"><i data-lucide="package"></i></div>
          <div style="display: flex; gap: 0.5rem;">
            <button class="btn" style="padding: 0.2rem; background: transparent;" onclick="editPlan('${p.id}')"><i data-lucide="edit" style="width: 14px; color: #3b82f6;"></i></button>
            <button class="btn" style="padding: 0.2rem; background: transparent;" onclick="deletePlan('${p.id}')"><i data-lucide="trash-2" style="width: 14px; color: #ff4444;"></i></button>
          </div>
        </div>
        <div style="margin-top: 1rem;">
          <h4 style="font-size: 1.25rem; margin-bottom: 0.25rem; text-transform: capitalize;">${p.name}</h4>
          <div style="font-size: 1.5rem; font-weight: bold; color: #fff; margin-bottom: 0.5rem;">
            R$ ${priceVal.toFixed(2)} <span style="font-size: 0.8rem; font-weight: normal; color: #888;">/ ${p.duration_days} dias</span>
          </div>
          <p style="font-size: 0.85rem; color: #888;">${p.description || 'Sem descrição'}</p>
        </div>
      </div>
    `}).join('');
    initIcons();
  } catch (err) {
    console.error("Error plans:", err);
    const grid = document.getElementById('plans-grid');
    if (grid) grid.innerHTML = `<div style="padding: 2rem; color: var(--danger);">Erro: ${err.message}</div>`;
  }
}

// --- Payments View ---
async function renderPaymentsView() {
  dynamicContent.innerHTML = `
    <div class="data-table-container animate-fade-in">
      <div class="table-header">
        <h3>Histórico Pix</h3>
        <button class="btn btn-ghost btn-icon" onclick="renderPaymentsView()" title="Atualizar Lista">
           <i data-lucide="refresh-cw"></i>
        </button>
      </div>
      <table class="data-table">
        <thead>
          <tr>
            <th>Cliente / Usuário</th>
            <th>Valor</th>
            <th>Novo Vencimento</th>
            <th>Status</th>
            <th>Data Pagamento</th>
            <th>Ref.</th>
          </tr>
        </thead>
        <tbody id="full-payments-list">
          <tr><td colspan="6" style="text-align:center; padding: 2rem;">Carregando...</td></tr>
        </tbody>
      </table>
    </div>
  `;

  // Fetch payments separately
  const { data: payments, error: payError } = await supabase
    .from('payments')
    .select('*')
    .order('created_at', { ascending: false });

  if (payError) {
    console.error(payError);
    document.getElementById('full-payments-list').innerHTML = `<tr><td colspan="6" style="text-align:center; color:red;">Erro ao carregar pagamentos: ${payError.message}</td></tr>`;
    return;
  }

  // Fetch profiles separately for manual join
  const { data: profiles, error: profError } = await supabase
    .from('profiles')
    .select('id, full_name, email, expiration_date');

  // Map profiles by ID for O(1) lookup
  const profileMap = {};
  if (profiles) {
    profiles.forEach(p => {
      profileMap[p.id] = p;
    });
  }

  const tbody = document.getElementById('full-payments-list');

  tbody.innerHTML = (payments || []).map(p => {
    // Manual Join
    const profile = profileMap[p.user_id] || {};

    // Prioritize Name -> Email -> 'Desconhecido'
    const name = profile.full_name || profile.email || 'Usuário Desconhecido';
    const email = profile.email || 'Email n/a';

    // Format Expiration Date
    let expiryDisplay = '---';
    if (profile.expiration_date) {
      const d = new Date(profile.expiration_date);
      expiryDisplay = d.toLocaleDateString('pt-BR');
    }

    const payDate = new Date(p.created_at);
    const amountVal = p.amount ? Number(p.amount) : 0;

    return `
    <tr>
      <td>
        <div style="font-weight: 600; color: white; font-size: 0.95rem;">${name}</div>
        <div style="font-size: 0.8rem; color: var(--text-dim); margin-top: 2px;">${email}</div>
      </td>
      <td style="font-weight: bold; color: #fff;">R$ ${amountVal.toFixed(2)}</td>
      <td>
        <div style="display: flex; align-items: center; gap: 6px;">
            <i data-lucide="calendar" style="width: 14px; color: var(--success);"></i>
            <span style="color: var(--success); font-weight: 600;">${expiryDisplay}</span>
        </div>
      </td>
      <td>
        <span class="status-pill ${p.status === 'approved' ? 'status-active' : 'status-inactive'}">
            ${p.status || 'pending'}
        </span>
      </td>
      <td style="color: var(--text-dim); font-size: 0.9rem;">
        ${payDate.toLocaleDateString('pt-BR')} <span style="font-size:0.75rem">${payDate.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}</span>
      </td>
      <td>
         <i data-lucide="copy" class="copy-btn" onclick="navigator.clipboard.writeText('${p.payment_id}')" title="Copiar ID: ${p.payment_id}"></i>
      </td>
    </tr>
    `;
  }).join('') || '<tr><td colspan="6" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhum pagamento registrado.</td></tr>';

  initIcons();
}

// --- Handlers ---
async function handleUserSubmit(e) {
  e.preventDefault();
  const btn = e.target.querySelector('button[type="submit"]');
  btn.innerText = 'Salvando...';

  const id = document.getElementById('user-id').value;
  const email = document.getElementById('user-email').value.trim();
  const password = document.getElementById('user-password-field').value.trim();
  const name = document.getElementById('user-name').value.trim();
  const phone = document.getElementById('user-phone').value.trim();
  const m3u = document.getElementById('user-m3u').value.trim();
  const appId = document.getElementById('user-app-id').value;
  const appImage = document.getElementById('user-app-image').value.trim();
  const expiry = document.getElementById('user-expiry').value;
  const status = document.getElementById('user-status').value === 'true';

  try {
    const updates = {
      full_name: name,
      phone: phone,
      m3u_url: m3u,
      app_id: appId || null,
      app_image_url: appImage,
      expiration_date: expiry ? new Date(expiry).toISOString() : null,
      is_active: status,
      has_signal: document.getElementById('user-has-signal').checked,
      // Novos campos de TV
      tv_enabled: document.getElementById('user-tv-enabled').checked,
      tv_app_name: document.getElementById('user-tv-app-name').value,
      tv_app_image: document.getElementById('user-tv-app-image').value,
      tv_app_auth_type: document.getElementById('user-tv-auth-type').value,
      tv_app_mac: document.getElementById('user-tv-mac').value,
      tv_app_user: document.getElementById('user-tv-user').value,
      tv_app_pass: document.getElementById('user-tv-pass').value,
      tv_app_email: document.getElementById('user-tv-email').value,
      tv_app_pass_email: document.getElementById('user-tv-pass-email').value
    };

    if (!id) {
      // Create NEW user
      const { data, error } = await supabase.auth.signUp({
        email: email.includes('@') ? email : `${email}@startflix.app`,
        password: password || '123456'
      });
      if (error) throw error;

      // Update the profile created (the trigger might be disabled, so we force update)
      await supabase.from('profiles').update(updates).eq('id', data.user.id);
    } else {
      // Update EXISTING
      console.log("Atualizando perfil:", id, "com lista:", m3u);
      const { error: updateErr } = await supabase.from('profiles').update(updates).eq('id', id);

      if (updateErr) throw updateErr;
      console.log("Perfil atualizado com sucesso!");
    }

    showToast("Operação concluída e Salva!", "success");
    document.getElementById('user-modal').style.display = 'none';

    // Pequeno delay para o banco processar antes de recarregar a lista
    setTimeout(() => renderUsersView(), 500);
  } catch (err) {
    showToast("Erro: " + err.message, "error");
  } finally {
    btn.innerText = 'Salvar Cliente';
  }
}

async function handleAppSubmit(e) {
  e.preventDefault();
  const id = document.getElementById('app-id-field').value;
  const name = document.getElementById('app-name').value;
  const imageUrl = document.getElementById('app-image-url').value;
  const url = document.getElementById('app-url').value;
  const type = document.getElementById('app-type').value;

  try {
    if (!id) {
      const { error } = await supabase.from('apps').insert([
        { name, image_url: imageUrl, download_url: url, auth_type: type, is_active: true }
      ]);
      if (error) throw error;
    } else {
      const { error } = await supabase.from('apps').update({
        name, image_url: imageUrl, download_url: url, auth_type: type
      }).eq('id', id);
      if (error) throw error;
    }

    showToast("Operação realizada com sucesso!", "success");
    document.getElementById('app-modal').style.display = 'none';
    renderAppsView();
  } catch (err) {
    showToast("Erro: " + err.message, "error");
  }
}

async function handlePlanSubmit(e) {
  e.preventDefault();
  const id = document.getElementById('plan-id').value;
  const name = document.getElementById('plan-name').value;
  const price = parseFloat(document.getElementById('plan-price').value);
  const days = parseInt(document.getElementById('plan-days').value);
  const desc = document.getElementById('plan-desc').value;

  try {
    if (!id) {
      const { error } = await supabase.from('plans').insert([
        { name, price, duration_days: days, description: desc }
      ]);
      if (error) throw error;
    } else {
      const { error } = await supabase.from('plans').update({
        name, price, duration_days: days, description: desc
      }).eq('id', id);
      if (error) throw error;
    }

    showToast("Plano salvo com sucesso!", "success");
    document.getElementById('plan-modal').style.display = 'none';
    renderPlansView();
  } catch (err) {
    showToast("Erro: " + err.message, "error");
  }
}

// --- Login Handler ---
async function handleLogin(e) {
  e.preventDefault();
  const password = document.getElementById('login-password').value;

  // Senha definida pelo usuário
  if (password === '01Deus02@@@@') {
    localStorage.setItem('admin_session', 'true');
    document.getElementById('login-overlay').style.display = 'none';
    navigateTo('dashboard');
  } else {
    showToast("Senha incorreta!", "error");
  }
}

// Exposed to window for onclick
window.editUser = async (id) => {
  const { data: u } = await supabase.from('profiles').select('*').eq('id', id).single();

  // Populate Apps Dropdown
  const { data: apps } = await supabase.from('apps').select('id, name');
  const appSelect = document.getElementById('user-app-id');
  if (appSelect) {
    appSelect.innerHTML = '<option value="">Nenhum (Usar Padrão)</option>' +
      (apps?.map(a => `<option value="${a.id}">${a.name}</option>`).join('') || '');
  }

  if (u) {
    document.getElementById('user-id').value = u.id;
    document.getElementById('user-email').value = u.email || '';
    document.getElementById('user-name').value = u.full_name || '';
    document.getElementById('user-phone').value = u.phone || '';
    document.getElementById('user-m3u').value = u.m3u_url || '';
    document.getElementById('user-app-id').value = u.app_id || '';
    document.getElementById('user-app-image').value = u.app_image_url || '';
    document.getElementById('user-expiry').value = u.expiration_date ? u.expiration_date.split('T')[0] : '';
    document.getElementById('user-status').value = String(u.is_active);
    document.getElementById('user-has-signal').checked = !!u.has_signal;

    // Populate TV Fields
    const tvEnabled = !!u.tv_enabled;
    document.getElementById('user-tv-enabled').checked = tvEnabled;
    document.getElementById('tv-fields').style.display = tvEnabled ? 'block' : 'none';

    document.getElementById('user-tv-app-name').value = u.tv_app_name || '';
    document.getElementById('user-tv-app-image').value = u.tv_app_image || '';
    document.getElementById('user-tv-auth-type').value = u.tv_app_auth_type || 'mac';
    document.getElementById('user-tv-mac').value = u.tv_app_mac || '';
    document.getElementById('user-tv-user').value = u.tv_app_user || '';
    document.getElementById('user-tv-pass').value = u.tv_app_pass || '';
    document.getElementById('user-tv-email').value = u.tv_app_email || '';
    document.getElementById('user-tv-pass-email').value = u.tv_app_pass_email || '';

    // Trigger auth section visibility
    const isMac = (u.tv_app_auth_type || 'mac') === 'mac';
    document.getElementById('tv-auth-mac').style.display = isMac ? 'grid' : 'none';
    document.getElementById('tv-auth-email').style.display = isMac ? 'none' : 'grid';

    document.getElementById('user-modal-title').innerText = 'Editar Cliente';
    document.getElementById('user-modal').style.display = 'flex';
  }
};

window.promptWhatsApp = (name, expiry) => {
  const number = prompt(`Digite o WhatsApp de ${name} (com DDD, somente números):`);
  if (!number) return;
  const cleanNumber = number.replace(/\D/g, '');
  const msg = encodeURIComponent(`Olá ${name}, sua assinatura venceu em ${expiry}. Regularize agora para continuar assistindo!`);
  window.open(`https://wa.me/${cleanNumber}?text=${msg}`, '_blank');
};

window.deleteUser = async (id) => {
  if (confirm("Tem certeza que deseja excluir este cliente?")) {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      showToast("Cliente excluído com sucesso!", "success");
      renderUsersView();
    } catch (err) {
      showToast("Erro ao excluir cliente: " + err.message, "error");
    }
  }
};

window.deleteApp = async (id) => {
  if (confirm("Excluir esta configuração?")) {
    try {
      await supabase.from('apps').delete().eq('id', id);
      showToast("Configuração excluída com sucesso!", "success");
      renderAppsView();
    } catch (err) {
      showToast("Erro ao excluir configuração: " + err.message, "error");
    }
  }
};

window.editApp = async (id) => {
  const { data: a } = await supabase.from('apps').select('*').eq('id', id).single();
  if (a) {
    document.getElementById('app-id-field').value = a.id;
    document.getElementById('app-name').value = a.name;
    document.getElementById('app-image-url').value = a.image_url || '';
    document.getElementById('app-url').value = a.download_url;
    document.getElementById('app-type').value = a.auth_type;
    document.getElementById('app-modal-title').innerText = 'Editar Configuração';
    document.getElementById('app-modal').style.display = 'flex';
  }
};

window.editPlan = async (id) => {
  const { data: p } = await supabase.from('plans').select('*').eq('id', id).single();
  if (p) {
    document.getElementById('plan-id').value = p.id;
    document.getElementById('plan-name').value = p.name;
    document.getElementById('plan-price').value = p.price;
    document.getElementById('plan-days').value = p.duration_days;
    document.getElementById('plan-desc').value = p.description || '';
    document.getElementById('plan-modal-title').innerText = 'Editar Plano';
    document.getElementById('plan-modal').style.display = 'flex';
  }
};

window.deletePlan = async (id) => {
  if (confirm("Deseja excluir este plano definitivamente?")) {
    try {
      await supabase.from('plans').delete().eq('id', id);
      showToast("Plano excluído com sucesso!", "success");
      renderPlansView();
    } catch (err) {
      showToast("Erro ao excluir plano: " + err.message, "error");
    }
  }
};

// Mobile Logout
document.getElementById('mobile-logout-btn')?.addEventListener('click', () => {
  supabase.auth.signOut();
  localStorage.removeItem('admin_session');
  location.reload();
});

// PWA Service Worker Registration
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js')
      .then(reg => console.log('ServiceWorker registered:', reg.scope))
      .catch(err => console.log('ServiceWorker registration failed:', err));
  });
}


// --- Mass Renew Logic ---
window.confirmMassRenew = async () => {
  if (!confirm("Tem certeza que deseja renovar TODOS os usuários por 30 dias?\n\n- Vencidos: +30 dias a partir de hoje.\n- Ativos: +30 dias no vencimento atual.")) {
    return;
  }

  showToast('🔄 Iniciando renovação em massa... Aguarde.', 'info');

  try {
    const { data: profiles, error } = await supabase.from('profiles').select('*');
    if (error) throw error;

    let successCount = 0;
    let errorCount = 0;
    const now = new Date();

    for (const profile of profiles) {
      try {
        let currentExp = profile.expiration_date ? new Date(profile.expiration_date) : new Date();

        // Se a data do usuário for inválida ou anterior a hoje, começa de hoje
        if (isNaN(currentExp.getTime()) || currentExp < now) {
          currentExp = new Date();
        }

        // Adiciona 30 dias
        currentExp.setDate(currentExp.getDate() + 30);

        const { error: updateError } = await supabase
          .from('profiles')
          .update({
            expiration_date: currentExp.toISOString(),
            is_active: true // Reativa se estiver inativo
          })
          .eq('id', profile.id);

        if (updateError) throw updateError;
        successCount++;
      } catch (err) {
        console.error(`Erro ao renovar usuário ${profile.email}:`, err);
        errorCount++;
      }
    }

    showToast(`✅ Concluído! ${successCount} renovados. ${errorCount > 0 ? errorCount + ' erros.' : ''}`, 'success');

    // Refresh view if on users page
    if (state.activePage === 'users') {
      renderUsersView();
    }

  } catch (err) {
    console.error("Erro geral na renovação em massa:", err);
    showToast('❌ Erro ao processar renovação em massa.', 'error');
  }
};

window.liberarTodos = async () => {
  if (!confirm("Deseja liberar o sinal de TODOS os clientes cadastrados?")) return;

  showToast('🔄 Liberando sinal para todos... Aguarde.', 'info');

  try {
    const { error } = await supabase.from('profiles')
      .update({ 
        has_signal: true,
        is_active: true 
      })
      .neq('id', '00000000-0000-0000-0000-000000000000'); 

    if (error) throw error;

    showToast('✅ Sinal liberado para todos os clientes!', 'success');
    
    if (state.activePage === 'users') {
      renderUsersView();
    }
  } catch (err) {
    console.error("Erro ao liberar todos:", err);
    showToast('❌ Erro ao liberar todos: ' + err.message, 'error');
  }
};

// --- Settings View ---
async function renderSettingsView() {
  dynamicContent.innerHTML = `
    <div class="animate-fade-in">
      <div class="stat-card" style="max-width: 600px; margin: 0 auto;">
        <h3 style="margin-bottom: 1.5rem; display: flex; align-items: center; gap: 0.5rem;">
          <i data-lucide="settings"></i> Configurações de Anúncios
        </h3>
        <form id="settings-form">
          <div class="form-group">
            <label>Tempo de Recompensa (Acesso Grátis após Vídeo)</label>
            <select id="ad-reward-duration" class="form-control" style="background: var(--surface); color: white; border: 1px solid var(--border); padding: 0.8rem; border-radius: 8px; width: 100%;">
              <option value="30">30 Minutos</option>
              <option value="60">1 Hora</option>
              <option value="90">1 Hora e 30 Minutos</option>
              <option value="120">2 Horas</option>
              <option value="180">3 Horas</option>
              <option value="240">4 Horas</option>
            </select>
            <p style="font-size: 0.8rem; color: var(--text-dim); margin-top: 0.5rem;">
              Este é o tempo que o usuário ganhará de acesso ao assistir um anúncio premiado (Rewarded Ad).
            </p>
          </div>
          <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
            Salvar Configurações
          </button>
        </form>
      </div>
    </div>
  `;
  initIcons();

  // Load current settings
  try {
    const { data, error } = await supabase.from('admin_settings').select('value').eq('key', 'ad_config').maybeSingle();
    if (data) {
      document.getElementById('ad-reward-duration').value = data.value.reward_duration_minutes || 90;
    }
  } catch (err) {
    console.error("Error loading settings:", err);
  }
}

window.handleSettingsSubmit = async (e) => {
  e.preventDefault();
  const duration = parseInt(document.getElementById('ad-reward-duration').value);

  try {
    const { error } = await supabase.from('admin_settings').upsert({
      key: 'ad_config',
      value: { reward_duration_minutes: duration },
      updated_at: new Date().toISOString()
    }, { onConflict: 'key' });

    if (error) throw error;
    showToast("Configurações salvas com sucesso!", "success");
  } catch (err) {
    showToast("Erro ao salvar: " + err.message, "error");
  }
};

// --- Access Codes View ---
async function renderAccessCodesView() {
  dynamicContent.innerHTML = `
    <div class="animate-fade-in">
      <div class="table-header">
        <h3>Códigos de Acesso Rápido</h3>
        <button class="btn btn-primary" onclick="openAccessCodeModal()">
          <i data-lucide="plus"></i> Novo Código
        </button>
      </div>
      <div class="data-table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>Código</th>
              <th>Descrição / Nome</th>
              <th>URL M3U Vinculada</th>
              <th>Status</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody id="access-codes-list">
            <tr><td colspan="5" style="text-align:center; padding: 2rem;">Carregando...</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  `;
  initIcons();

  try {
    const { data: codes, error } = await supabase.from('access_codes').select('*').order('created_at', { ascending: false });
    if (error) throw error;

    const tbody = document.getElementById('access-codes-list');
    if (!codes || codes.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding: 2rem; color: var(--text-dim);">Nenhum código cadastrado.</td></tr>';
      return;
    }

    tbody.innerHTML = codes.map(c => `
      <tr>
        <td><strong style="color: var(--primary-light); font-family: monospace; font-size: 1.1rem;">${c.code}</strong></td>
        <td>${c.description || '---'}</td>
        <td style="max-width: 300px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 0.8rem; color: var(--text-dim);">
          ${c.m3u_url}
        </td>
        <td>
          <span class="status-pill ${c.is_active ? 'status-active' : 'status-inactive'}">
            ${c.is_active ? 'ATIVO' : 'INATIVO'}
          </span>
        </td>
        <td>
          <div style="display:flex; gap:0.5rem;">
            <button class="btn-icon-small danger" onclick="deleteAccessCode('${c.id}')"><i data-lucide="trash-2"></i></button>
          </div>
        </td>
      </tr>
    `).join('');
    initIcons();
  } catch (err) {
    console.error("Error access codes:", err);
  }
}

window.openAccessCodeModal = () => {
  document.getElementById('access-code-form').reset();
  document.getElementById('access-code-id').value = '';
  document.getElementById('access-code-modal').style.display = 'flex';
};

window.handleAccessCodeSubmit = async (e) => {
  e.preventDefault();
  const code = document.getElementById('ac-code').value.trim().toUpperCase();
  const url = document.getElementById('ac-url').value.trim();
  const desc = document.getElementById('ac-desc').value.trim();

  try {
    const { error } = await supabase.from('access_codes').insert({
      code, m3u_url: url, description: desc
    });

    if (error) throw error;

    showToast("Código de acesso criado!", "success");
    document.getElementById('access-code-modal').style.display = 'none';
    renderAccessCodesView();
  } catch (err) {
    showToast("Erro: " + err.message, "error");
  }
};

window.deleteAccessCode = async (id) => {
  if (confirm("Excluir este código de acesso?")) {
    await supabase.from('access_codes').delete().eq('id', id);
    renderAccessCodesView();
  }
};

init();
