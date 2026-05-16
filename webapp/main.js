import { createIcons, Search, Bell, ChevronDown, Play, Info, Flame, Shield, Check } from 'lucide';
import { supabase } from './src/supabase';

// STATE
const state = {
    plans: [],
    movies: [
        { id: 1, title: 'Stranger Things', img: 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?auto=format&fit=crop&q=80&w=400' },
        { id: 2, title: 'The Witcher', img: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?auto=format&fit=crop&q=80&w=400' },
        { id: 3, title: 'Breaking Bad', img: 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?auto=format&fit=crop&q=80&w=400' },
        { id: 4, title: 'Cyberpunk', img: 'https://images.unsplash.com/photo-1614728263952-84ea206f2c41?auto=format&fit=crop&q=80&w=400' },
        { id: 5, title: 'Matrix Resurrections', img: 'https://images.unsplash.com/photo-1621955964441-c173e01c135b?auto=format&fit=crop&q=80&w=400' },
        { id: 6, title: 'Inception', img: 'https://images.unsplash.com/photo-1542204113-e935400bdc21?auto=format&fit=crop&q=80&w=400' },
        { id: 7, title: 'Interstellar', img: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&q=80&w=400' }
    ]
};

// INITIALIZATION
function init() {
    createIcons({
        icons: { Search, Bell, ChevronDown, Play, Info, Flame, Shield, Check }
    });

    setupNavbar();
    loadMovies();
    loadPlans();
}

// UI LOGIC
function setupNavbar() {
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });
}

function loadMovies() {
    const containers = ['popular-movies', 'continue-watching', 'my-list'];

    containers.forEach(id => {
        const container = document.getElementById(id);
        if (!container) return;

        // Shuffle movies for variety
        const displayMovies = [...state.movies].sort(() => Math.random() - 0.5);

        container.innerHTML = displayMovies.map(movie => `
            <div class="movie-card">
                <img src="${movie.img}" alt="${movie.title}">
                <div class="movie-info">
                    <strong>${movie.title}</strong>
                    <div style="display: flex; gap: 8px; margin-top: 5px;">
                        <button class="btn" style="padding: 5px; border-radius: 50%; width: 30px; height: 30px; justify-content: center; background: white; color: black;"><i data-lucide="play" style="width: 14px;"></i></button>
                        <button class="btn" style="padding: 5px; border-radius: 50%; width: 30px; height: 30px; justify-content: center; background: rgba(255,255,255,0.1); color: white; border: 1px solid white;"><i data-lucide="check" style="width: 14px;"></i></button>
                    </div>
                </div>
            </div>
        `).join('');
    });

    createIcons({ icons: { Play, Check } });
}

async function loadPlans() {
    try {
        const { data, error } = await supabase
            .schema('startflix')
            .from('plans')
            .select('*')
            .order('price', { ascending: true });

        if (error) throw error;
        state.plans = data || [];

        const grid = document.getElementById('plans-grid');
        if (!grid) return;

        if (state.plans.length === 0) {
            grid.innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: var(--text-muted);">Nenhum plano disponível no momento.</p>';
            return;
        }

        grid.innerHTML = state.plans.map(plan => `
            <div class="plan-card">
                <div class="plan-name">${plan.name}</div>
                <div class="plan-price">R$ ${plan.price.toFixed(2)} <span>/ ${plan.duration_days} dias</span></div>
                <ul class="plan-features">
                    <li><i data-lucide="check"></i> Acesso em todos os dispositivos</li>
                    <li><i data-lucide="check"></i> Qualidade 4K Ultra HD</li>
                    <li><i data-lucide="check"></i> Sem anúncios</li>
                    <li><i data-lucide="check"></i> Download para assistir offline</li>
                </ul>
                <button class="btn btn-subscribe" onclick="subscribeToPlan('${plan.id}')">Assinar Agora</button>
            </div>
        `).join('');

        createIcons({ icons: { Check } });

    } catch (err) {
        console.error("Erro ao carregar planos:", err);
    }
}

window.subscribeToPlan = (id) => {
    const plan = state.plans.find(p => p.id === id);
    if (!plan) return;

    // Criar modal de checkout Pix dinâmico
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.style.display = 'flex';
    modal.id = 'checkout-modal';

    modal.innerHTML = `
        <div class="plan-card" style="max-width: 450px; background: #13151b; position: relative;">
            <button class="btn" style="position: absolute; top: 10px; right: 10px; background: transparent; color: white; font-size: 1.5rem;" onclick="document.getElementById('checkout-modal').remove()">×</button>
            <div class="plan-name">Pagamento via Pix</div>
            <div style="margin: 20px 0; background: white; padding: 20px; border-radius: 12px; display: inline-block;">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://startflix.app/pix-pay/${id}" alt="Pix QR Code" style="width: 200px; height: 200px;">
            </div>
            <div style="margin-bottom: 20px; text-align: left;">
                <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 10px;">Plano: <strong>${plan.name}</strong></p>
                <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 10px;">Valor: <strong style="color: white;">R$ ${plan.price.toFixed(2)}</strong></p>
                <div style="background: rgba(255,255,255,0.05); padding: 12px; border-radius: 8px; font-family: monospace; font-size: 0.75rem; word-break: break-all; margin-top: 15px;">
                    00020126360014BR.GOV.BCB.PIX0114+55119999999995204000053039865405${plan.price.toFixed(2)}5802BR5913STARTFLIX6009SAO PAULO62070503***6304E2D1
                </div>
            </div>
            <button class="btn btn-subscribe" onclick="navigator.clipboard.writeText('00020126...6304E2D1'); alert('Código Pix copiado!');">Copiar Código Pix</button>
            <p style="font-size: 0.7rem; color: #46d369; margin-top: 15px;"><i data-lucide="check" style="width: 12px;"></i> Liberação imediata após o pagamento!</p>
        </div>
    `;

    document.body.appendChild(modal);
    createIcons({ icons: { Check, Shield } });
};

// Start the app
init();
