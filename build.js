const fs = require('fs');
const { execSync } = require('child_process');
const path = require('path');

// Helper para copiar pastas recursivamente usando fs nativo
function copyFolderSync(from, to) {
    if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });
    fs.readdirSync(from).forEach(element => {
        if (fs.lstatSync(path.join(from, element)).isDirectory()) {
            copyFolderSync(path.join(from, element), path.join(to, element));
        } else {
            fs.copyFileSync(path.join(from, element), path.join(to, element));
        }
    });
}

// Helper para deletar pastas recursivamente
function deleteFolderRecursive(dirPath) {
    if (fs.existsSync(dirPath)) {
        fs.readdirSync(dirPath).forEach((file) => {
            const curPath = path.join(dirPath, file);
            if (fs.lstatSync(curPath).isDirectory()) {
                deleteFolderRecursive(curPath);
            } else {
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(dirPath);
    }
}

async function build() {
    const rootDir = __dirname;
    const distDir = path.join(rootDir, 'dist');
    const adminDir = path.join(rootDir, 'admin_web');

    try {
        console.log('--- Iniciando Build do Painel Admin ---');

        // 1. Limpar diretório dist
        console.log('Limpando diretório dist...');
        deleteFolderRecursive(distDir);
        fs.mkdirSync(distDir, { recursive: true });

        // 2. Build do Painel Admin
        console.log('Instalando dependências no admin_web...');
        execSync('npm install', { cwd: adminDir, stdio: 'inherit' });

        console.log('Compilando Painel Admin...');
        execSync('npm run build', { cwd: adminDir, stdio: 'inherit' });

        // 3. Copiar o resultado para a raiz do dist
        console.log('Movendo arquivos (Vite build) para a raiz do deploy...');
        const adminDist = path.join(adminDir, 'dist');
        if (fs.existsSync(adminDist)) {
            copyFolderSync(adminDist, distDir);
        }

        console.log('--- Build concluído com sucesso! ---');
    } catch (error) {
        console.error('Erro no build:', error);
        process.exit(1);
    }
}

build();
