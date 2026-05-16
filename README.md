# StartFlix Pro

Um player de vídeo estilo Netflix para Android, construído com Flutter e integrado com Supabase.

## Configuração

### 1. Supabase
Para o gerenciamento de usuários funcionar, você precisa configurar suas credenciais do Supabase.
Abra o arquivo `lib/core/constants.dart` e substitua os valores:

```dart
static const String supabaseUrl = 'SUA_URL_DO_SUPABASE';
static const String supabaseAnonKey = 'SUA_CHAVE_ANON_DO_SUPABASE';
```

### 2. Lista M3U
Por padrão, o app carrega uma lista de teste pública. Para usar sua própria lista:
1. Abra `lib/screens/home_screen.dart`.
2. Localize a variável `testUrl` dentro de `_loadM3u()`.
3. Substitua pela URL da sua lista M3U.

## Como Rodar

Certifique-se de ter um emulador Android rodando ou um dispositivo conectado.

```bash
flutter run
```

## Estrutura do Projeto

- `lib/models`: Modelos de dados (MediaItem).
- `lib/services`: Serviços para API (M3U, Supabase).
- `lib/screens`: Telas do app (Home, Player).
- `lib/widgets`: Componentes reutilizáveis (MovieCard).
- `lib/core`: Constantes e configurações.
