Write-Host "Limpando e preparando build Web do Flutter..."
flutter clean
flutter pub get

Write-Host "Compilando Flutter Web (Release)..."
flutter build web --release

Write-Host "Criando regras de roteamento do Vercel..."
$vercelJson = @'
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
'@
Set-Content -Path "build\web\vercel.json" -Value $vercelJson -Encoding UTF8

Write-Host "Iniciando deploy no Vercel..."
Set-Location -Path "build\web"
npx vercel --prod --token Bge0nCtIx1WnyJyUk0SV4yem --yes

Write-Host "Processo concluído!"
