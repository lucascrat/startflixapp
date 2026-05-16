# Download and install Supabase CLI
$url = "https://github.com/supabase/cli/releases/latest/download/supabase_windows_amd64.zip"
$output = "$env:TEMP\supabase.zip"
$destination = "$env:USERPROFILE\supabase-cli"

Write-Host "Downloading Supabase CLI..." -ForegroundColor Green
Invoke-WebRequest -Uri $url -OutFile $output

Write-Host "Extracting..." -ForegroundColor Green
Expand-Archive -Path $output -DestinationPath $destination -Force

Write-Host "Supabase CLI instalado com sucesso em: $destination" -ForegroundColor Green
Write-Host "Execute: supabase --version" -ForegroundColor Yellow
