import https from 'https';
import fs from 'fs';
import path from 'path';

// Configurações da Efí (Serão lidas das variáveis de ambiente da Vercel)
const credentials = {
    client_id: process.env.EFI_CLIENT_ID,
    client_secret: process.env.EFI_CLIENT_SECRET,
    pix_key: process.env.EFI_PIX_KEY || process.env.CHAVE_PIX,
    cert_base64: process.env.EFI_CERT_BASE64,
    passphrase: process.env.EFI_CERT_PASSPHRASE || '',
};

// Caminho temporário para o certificado
const certPath = '/tmp/cert.p12';

export default async function handler(req, res) {
    // Habilitar CORS
    res.setHeader('Access-Control-Allow-Credentials', true);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
    );

    if (req.method === 'OPTIONS') {
        res.status(200).end();
        return;
    }

    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Método não permitido' });
    }

    try {
        const body = req.body || {};
        const { action, planId, amount, user, payerData } = body;

        console.log('Recebida ação:', action);

        if (action === 'test') {
            return res.status(200).json({
                status: 'ok',
                message: 'Serviço de pagamentos Vercel ativo!',
                env_check: {
                    has_client_id: !!process.env.EFI_CLIENT_ID,
                    has_cert: !!process.env.EFI_CERT_BASE64,
                    has_pix_key: !!(process.env.EFI_PIX_KEY || process.env.CHAVE_PIX),
                    pix_key_length: (process.env.EFI_PIX_KEY || process.env.CHAVE_PIX || '').length
                }
            });
        }

        if (action === 'check') {
            const { txid } = body;
            if (!txid) return res.status(400).json({ error: 'txid obrigatório para verificação' });

            // 1. Preparar Certificado
            if (!credentials.cert_base64) {
                return res.status(500).json({ error: 'Configuração ausente: EFI_CERT_BASE64' });
            }
            const certBuffer = Buffer.from(credentials.cert_base64, 'base64');
            fs.writeFileSync(certPath, certBuffer);

            // 2. Obter Token
            const tokenData = await getAccessToken();
            const accessToken = tokenData.access_token;

            // 3. Consultar cobrança
            const cob = await getCharge(accessToken, txid);

            // 4. Mapear status Efí para status App
            // Status Efí: ATIVA, CONCLUIDA, REMOVIDA_PELO_USUARIO, REMOVIDA_PELO_PSP
            let appStatus = 'pending';
            if (cob.status === 'CONCLUIDA') appStatus = 'approved';
            else if (cob.status === 'REMOVIDA_PELO_USUARIO' || cob.status === 'REMOVIDA_PELO_PSP') appStatus = 'cancelled';

            return res.status(200).json({
                txid: cob.txid,
                status: appStatus,
                original_status: cob.status,
                pix: cob.pix // Contém detalhes do pagamento se concluído
            });
        }

        if (action !== 'create') {
            return res.status(400).json({ error: 'Ação inválida' });
        }

        // 1. Preparar Certificado
        if (!credentials.cert_base64) {
            return res.status(500).json({ error: 'Configuração ausente: EFI_CERT_BASE64' });
        }

        const certBuffer = Buffer.from(credentials.cert_base64, 'base64');
        fs.writeFileSync(certPath, certBuffer);

        // 2. Obter Token OAuth2
        const tokenData = await getAccessToken();
        const accessToken = tokenData.access_token;

        // 3. Criar Cobrança Pix (Cobrança Imediata)
        const cob = await createImmediateCharge(accessToken, amount, payerData);

        // 4. Gerar QR Code e Copia e Cola
        const qrcodeData = await getQrCode(accessToken, cob.loc.id);

        // 5. Retornar dados para o App
        return res.status(200).json({
            txid: cob.txid,
            pix_copia_e_cola: qrcodeData.qrcode,
            imagem_qr_code: qrcodeData.imagemQrcode,
            status: 'pending'
        });

    } catch (error) {
        console.error('Erro no processamento Efí:', error);
        return res.status(500).json({
            error: 'Erro interno ao processar pagamento',
            details: error.message
        });
    }
}

// --- Funções Auxiliares para API da Efí ---

async function getAccessToken() {
    const auth = Buffer.from(`${credentials.client_id}:${credentials.client_secret}`).toString('base64');

    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api-pix.gerencianet.com.br',
            port: 443,
            path: '/oauth/token',
            method: 'POST',
            pfx: fs.readFileSync(certPath),
            passphrase: credentials.passphrase,
            headers: {
                'Authorization': `Basic ${auth}`,
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (res.statusCode === 200) resolve(parsed);
                else reject(new Error(`OAuth Error: ${data}`));
            });
        });

        req.on('error', reject);
        req.write(JSON.stringify({ grant_type: 'client_credentials' }));
        req.end();
    });
}

async function createImmediateCharge(token, amount, payer) {
    return new Promise((resolve, reject) => {
        const body = {
            calendario: { expiracao: 3600 },
            devedor: {
                cpf: payer.cpf,
                nome: payer.name
            },
            valor: { original: amount.toFixed(2) },
            chave: credentials.pix_key,
            solicitacaoPagador: "Assinatura StartFlix"
        };

        const options = {
            hostname: 'api-pix.gerencianet.com.br',
            port: 443,
            path: '/v2/cob',
            method: 'POST',
            pfx: fs.readFileSync(certPath),
            passphrase: credentials.passphrase,
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (res.statusCode === 201) resolve(parsed);
                else reject(new Error(`Charge Error: ${data}`));
            });
        });

        req.on('error', reject);
        req.write(JSON.stringify(body));
        req.end();
    });
}

async function getQrCode(token, locId) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api-pix.gerencianet.com.br',
            port: 443,
            path: `/v2/loc/${locId}/qrcode`,
            method: 'GET',
            pfx: fs.readFileSync(certPath),
            passphrase: credentials.passphrase,
            headers: {
                'Authorization': `Bearer ${token}`
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (res.statusCode === 200) resolve(parsed);
                else reject(new Error(`QrCode Error: ${data}`));
            });
        });

        req.on('error', reject);
        req.end();
    });
}

async function getCharge(token, txid) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api-pix.gerencianet.com.br',
            port: 443,
            path: `/v2/cob/${txid}`,
            method: 'GET',
            pfx: fs.readFileSync(certPath),
            passphrase: credentials.passphrase,
            headers: {
                'Authorization': `Bearer ${token}`
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => data += chunk);
            res.on('end', () => {
                const parsed = JSON.parse(data);
                if (res.statusCode === 200) resolve(parsed);
                else reject(new Error(`GetCharge Error: ${data}`));
            });
        });

        req.on('error', reject);
        req.end();
    });
}
