# LB Phone — Especificação Funcional Completa

> Documento de referência para alimentar o Claude Web (sem acesso ao git) durante a montagem do PRD da versão **s&box** deste telefone.
> Baseado no conteúdo real do repositório `KiKoZl1/FivemPhone` (LB Phone v2.3.7, FiveM/GTA V, Lua 5.4 + UI Vue/JS, banco MySQL via `oxmysql`).
> **Nada foi omitido**: cobre arquitetura, todos os apps, todas as tabelas do banco, configurações, permissões, recursos transversais, eventos, integrações, assets e gaps a portar para s&box.

---

## 0. Visão geral

- **Nome do recurso:** `lb-phone`
- **Versão:** 2.3.7
- **Plataforma original:** FiveM (GTA V) — `fx_version "cerulean"`, `lua54 "yes"`
- **Stack:**
  - Backend in-game: Lua 5.4 (cliente + servidor)
  - Persistência: MySQL/MariaDB via `oxmysql` (74 tabelas)
  - UI: bundle JS/CSS pré-buildado em `ui/dist/` (Vue + Vite, code-splitting por app)
  - Voz: pma-voice (recomendado), mumble, salty ou tokovoip
  - Mídia: uploads via Fivemanage / LBUpload / método custom
  - WebRTC: para Live (InstaPic) e vídeochamadas — STUN/TURN configurável (Cloudflare suportado)
- **Modelo de uso:** item de inventário ("phone") que abre uma NUI fullscreen simulando smartphone iOS.

---

## 1. Arquitetura física do repositório

```
fxmanifest.lua          # Manifesto FiveM (declara scripts, dependências, ui_page)
phone.sql               # Schema completo (74 tabelas)
inventoryitem.png       # Ícone do item no inventário
README.md               # README curto
PHONE_SPEC.md           # ESTE documento

config/
├── config.lua          # 831 linhas — configuração principal
├── config.json         # 250 linhas — wallpapers, sons, apps (UI)
├── defaultSettings.json# Configurações default por usuário
├── cellTowers.lua      # Posições das torres de celular (sinal)
├── music.lua           # Catálogo do app Music
├── cache/              # Cache runtime
└── locales/            # 26 idiomas (ar, ba, cs, de, dk, en, es, fr, hu, it,
                          ja, nl, no, pl, pt-br, pt-pt, ro, ru, sl, sv, th,
                          tr, ua, zh-cn)

shared/
├── functions.lua       # Helpers Lua compartilhados client/server
└── upload.lua          # Lógica de upload de mídia

lib/
├── client/             # keybinds, registerCallbacks, triggerCallbacks
└── server/             # registerCallbacks, triggerCallbacks
                        # (sistema de RPC client↔server estilo callback)

client/
├── client.lua                          # Bootstrap do client
├── apps/
│   ├── custom.lua                      # Loader de apps customizados
│   ├── default/                        # Apps "stock" (10)
│   │   appstore.lua, camera.lua, clock.lua, mail.lua, maps.lua,
│   │   messages.lua, notes.lua, phone.lua, voicememo.lua, weather.lua
│   ├── social/                         # Sociais (4)
│   │   instagram.lua, tiktok.lua, tinder.lua, twitter.lua
│   ├── other/                          # Diversos (5)
│   │   crypto.lua, darkchat.lua, marketplace.lua, music.lua, yellowpages.lua
│   └── framework/                      # Dependentes de framework (4 + casas)
│       garage.lua, services.lua, wallet.lua,
│       home/{loaf_housing.lua, qb-houses.lua, qs-housing.lua}
├── custom/
│   ├── frameworks/                     # Bridges esx, qb, qbox, ox, vrp2, standalone
│   ├── functions/                      # animations, cellTowers, death, face,
│   │                                     functions, item, voice
│   └── uniquePhones/                   # Bridges para cada inventário (telefone único)
│       codem-inventory, core_inventory, mf-inventory, ox_inventory,
│       qb-inventory, qs-inventory
└── misc/                               # Subsystems transversais
    accountSwitcher, airshare, backup, battery, controllerCompatibility,
    customApp, debug, errors, exports, flashlight, hearNearby, notifications,
    recordNearbyVoices, security, walkableCam

server/
├── server.lua                          # Bootstrap do server
├── apiKeys.lua                         # Webhooks Discord / Fivemanage / API keys
├── versionCheck.lua                    # Verifica updates remotos
├── apps/                               # Espelha client/apps (lógica server-side)
│   default/, social/, other/, framework/
├── custom/
│   ├── frameworks/                     # esx, qb, qbox, ox, vrp2, standalone
│   │   (commands, money, mail, services, vehicles, qb-specific)
│   ├── functions/                      # blacklist, entities, functions,
│   │                                     htmlToMarkdown, item, logs, misc,
│   │                                     voice, webrtc
│   └── uniquePhones/                   # Bridges server-side dos inventários
├── data/                               # Dados estáticos do server
└── misc/                               # Subsystems server
    accountSwitcher, airshare, autoDeleteNotifications, backup, battery,
    databaseChecker/{databaseChecker, defaultTables}, debug, errors, exports,
    notifications, security, statistics

ui/
├── components.js                       # JS extra (componentes globais)
└── dist/                               # Build Vite pronto
    ├── index.html
    └── assets/
        ├── *.js, *.css                 # ~30 chunks por app + index principal
        ├── fonts/                      # Inter (UI) + lockscreen/ (8 fontes display)
        │                                 (AbrilFatface, Gloock, Library3am,
        │                                  Limelight, Monoton, Nunito-Black,
        │                                  Nunito-Medium, ProtestGuerrilla)
        ├── img/
        │   ├── backgrounds/default/    # ~50+ wallpapers (cloud, mountain, desert,
        │   │                              rose, wallpaper1-21, Boat, Globe, Moon,
        │   │                              police, thunder, underwater, etc.)
        │   │   apps/                   # Backgrounds específicos por app
        │   │     garage/, home/, weather/
        │   ├── icons/
        │   │   apps/                   # Ícones dos apps (33 .jpg/.png)
        │   │   appstore/appimages/     # Screenshots dos apps na loja
        │   │     Crypto, DarkChat, Instagram, MarketPlace, Music,
        │   │     TikTok, Tinder, Twitter, YellowPages
        │   │   instagram/, maps/, messages/, music/, setup/, tinder/,
        │   │   twitter/, weather/
        │   ├── avatar-placeholder-{dark,light}.svg
        │   ├── placeholder-{dark,light}.svg
        │   ├── card.png, cryptogradient.png, lbos.webp, no-pfp.png
        │   └── blacklogo.png
        └── sound/
            ├── ringtones/              # default, apex, harp, radar, sencha,
            │                             silk, summit (.mp3) + vibrate.ogg
            ├── texttones/               # default.mp3
            ├── songs/                   # PLACE_SONGS_HERE (vazio — user-supplied)
            └── other/voicemail/         # Mensagens de voicemail
```

---

## 2. Frameworks e inventários suportados

### Frameworks (auto-detect ou manual via `Config.Framework`)
| Framework | Identificador | Notas |
|-----------|---------------|-------|
| ESX (esx-legacy) | `esx` | `es_extended` |
| QBCore | `qb` | `qb-core` |
| Qbox | `qbox` | `qbx_core` |
| OX Core | `ox` | `ox_core` |
| vRP 2.0 | `vrp2` | Apenas oficial — não funciona com forks |
| Standalone | `standalone` | Sem framework. Apps de framework ficam off, salvo se `Config.CustomFramework = true` |

Cada framework tem bridges em `client/custom/frameworks/<fw>/` e `server/custom/frameworks/<fw>/`. Convenção de arquivos: `commands.lua`, `money.lua`, `mail.lua`, `services.lua`, `vehicles.lua`, `<fw>.lua` (entry).

### Inventários (auto-detect via `Config.Item.Inventory`)
- `ox_inventory`
- `qb-inventory`
- `lj-inventory`
- `core_inventory`
- `mf-inventory`
- `qs-inventory`
- `codem-inventory`

Bridges em `client/custom/uniquePhones/` e `server/custom/uniquePhones/` — só ativam quando `Config.Item.Unique = true` (cada telefone = item único com identidade própria).

### Voz
- `pma` (pma-voice — RECOMENDADO)
- `mumble` (mumble-voip — não recomendado)
- `salty` (saltychat — não recomendado)
- `toko` (tokovoip — não recomendado)

### Housing (app Home)
- `loaf_housing`
- `qb-houses`
- `qs-housing`

---

## 3. Banco de dados (74 tabelas)

> Todas começam com prefixo `phone_`. Schema em `phone.sql` (1359 linhas).

### Núcleo / identidade
- `phone_phones` — Telefones (id, número, owner, settings, frame_color, etc.)
- `phone_last_phone` — Último telefone usado por jogador
- `phone_logged_in_accounts` — Contas logadas em apps (declarada 2× no SQL — observação)
- `phone_backups` — Backups de configurações/dados

### Phone (chamadas e contatos)
- `phone_phone_contacts` — Agenda
- `phone_phone_calls` — Histórico
- `phone_phone_blocked_numbers` — Bloqueados
- `phone_phone_voicemail` — Caixa postal

### Messages (SMS)
- `phone_message_channels` — Conversas
- `phone_message_members` — Participantes (1-1 e grupos)
- `phone_message_messages` — Mensagens (texto, mídia, áudio, transferência $)

### Mail
- `phone_mails`, `phone_mail_addresses` (parte do schema; verifique nomes exatos no SQL)

### Notes
- `phone_notes`

### Notifications
- `phone_notifications` — Push notifications

### Photos / Camera
- `phone_photos` — Itens de mídia (foto/vídeo)
- `phone_photo_albums` — Álbuns
- `phone_photo_album_members` — Membros de álbuns compartilhados
- `phone_photo_album_photos` — Junction álbum↔foto

### Clock
- `phone_clock_alarms`

### Voice Memo
- `phone_voice_memos_recordings`

### Maps
- `phone_maps_locations` — Pins salvos pelo usuário

### Crypto
- `phone_crypto` — Carteiras / holdings

### Wallet
- `phone_wallet_transactions`

### Marketplace
- `phone_marketplace_posts`

### Yellow Pages
- `phone_yellow_pages_posts`

### Music
- `phone_music_playlists`, `phone_music_saved_playlists`

### DarkChat (chat anônimo criptografado)
- `phone_darkchat_accounts`, `phone_darkchat_channels`, `phone_darkchat_members`, `phone_darkchat_messages`

### Twitter (Birdy)
- `phone_twitter_accounts`, `phone_twitter_follows`, `phone_twitter_follow_requests`,
  `phone_twitter_tweets`, `phone_twitter_likes`, `phone_twitter_retweets`,
  `phone_twitter_promoted`, `phone_twitter_messages`, `phone_twitter_notifications`,
  `phone_twitter_hashtags`

### Instagram (InstaPic)
- `phone_instagram_accounts`, `phone_instagram_follows`, `phone_instagram_follow_requests`,
  `phone_instagram_posts`, `phone_instagram_comments`, `phone_instagram_likes`,
  `phone_instagram_messages`, `phone_instagram_notifications`,
  `phone_instagram_stories`, `phone_instagram_stories_views`

### TikTok (Trendy)
- `phone_tiktok_accounts`, `phone_tiktok_follows`, `phone_tiktok_videos`,
  `phone_tiktok_likes`, `phone_tiktok_views`, `phone_tiktok_saves`,
  `phone_tiktok_comments`, `phone_tiktok_comments_likes`,
  `phone_tiktok_channels`, `phone_tiktok_messages`, `phone_tiktok_pinned_videos`,
  `phone_tiktok_notifications`, `phone_tiktok_unread_messages`

### Tinder (Spark)
- `phone_tinder_accounts`, `phone_tinder_swipes`, `phone_tinder_matches`, `phone_tinder_messages`

### Services (companies/jobs)
- `phone_services_channels`, `phone_services_messages`

---

## 4. Apps — especificação funcional completa

### Convenção de nomes UI vs internos
Alguns apps têm nome técnico ≠ nome exibido. Sempre que houver divergência, está marcado como **Display: "X"**.

| Identificador | Display | Removível | Tamanho (KB simulado) |
|---|---|---|---|
| `Phone` | Phone | Não | 1.900 |
| `Messages` | Messages | Não | 4.400 |
| `Notes` | Notes | Não | 18.600 |
| `Settings` | Settings | Não | 2.300 |
| `Photos` | Photos | Não | 9.000 |
| `Camera` | Camera | Não | 1.200 |
| `Weather` | Weather | Não | 9.400 |
| `Calculator` | Calculator | Não | 831 |
| `AppStore` | Apps | Não | 84.000 |
| `Clock` | Clock | Não | 1.200 |
| `Maps` | Maps | Não | 63.400 |
| `YellowPages` | **Pages** | Sim | 84.400 |
| `MarketPlace` | MarketPlace | Sim | 84.400 |
| `Wallet` | Wallet | Não | 2.000 |
| `Home` | Home | Não | 19.200 |
| `Garage` | Garage | Não | 17.400 |
| `Music` | Music | Sim | 17.400 |
| `DarkChat` | Dark Chat | Sim | 98.500 |
| `Twitter` | **Birdy** | Sim | 256.700 |
| `Crypto` | Crypto | Sim | 256.700 |
| `Mail` | Mail | Não | 23.200 |
| `Services` | Services | Não | 23.200 |
| `VoiceMemo` | Voice Memos | Não | 28.200 |
| `Instagram` | **InstaPic** | Sim | 223.000 |
| `Tinder` | **Spark** | Sim | 187.500 |
| `TikTok` | **Tiktok / Trendy** | Sim | 223.000 |

> Apps "removível = sim" são instaláveis/desinstaláveis pela App Store interna.

---

### 4.1 Phone (chamadas)
- Discador, lista de contatos, favoritos, histórico (recebidas, perdidas, feitas).
- Voicemail (caixa postal com áudio gravado).
- Bloqueio de números.
- Caller ID (mostrar/ocultar número — `phone.showCallerId` em settings).
- Chamada anônima (depende de `Config.Companies.AllowAnonymous` para empresas).
- Speaker mode com efeitos de áudio opcionais (`Config.Voice.CallEffects`).
- "Hear nearby" — players próximos podem ouvir a chamada se speaker ativo (depende de pma-voice).
- Empresas (Companies): jogadores podem ligar/mandar SMS para empresas (police, ambulance, mecânico, etc.) — config em `Config.Companies.Services`.

### 4.2 Messages (SMS)
- Conversas 1-1 e grupos.
- Texto + emoji + GIFs (Tenor — filtro por `Config.GIFsFilter`).
- Anexos: foto, vídeo, áudio (voice messages — `Config.EnableVoiceMessages`).
- Transferência de dinheiro inline (`Config.EnableMessagePay`, limite por `Config.MaxTransferAmount`).
- Deletar mensagens (`Config.DeleteMessages`).
- Notificações push.

### 4.3 Mail
- Caixa de entrada / enviados / lixeira.
- Editor rich text (compatível com QB mail events via `Config.QBMailEvent`).
- Domínio configurável (`Config.EmailDomain`, default `calyx.com`).
- Auto-criar email no setup (`Config.AutoCreateEmail`).
- Conversão HTML→Markdown (`Config.ConvertMailToMarkdown`) — função em `server/custom/functions/htmlToMarkdown.lua`.
- Permitir delete (`Config.DeleteMail`).

### 4.4 Camera
- 4 modos: foto, vídeo, selfie, normal (com flip).
- Câmera "walkable" — anda enquanto filma (`Config.Camera.Enabled`, `walkableCam.lua`).
- Roll lateral (Z/C), zoom (FOV configurável), flash (`toggleCameraFlash`).
- Modo Freeze: trava a câmera no espaço, anda em volta para fotografar em 3ª pessoa (`Config.Camera.Freeze`).
- FOVs distintos para infantaria, veículos e selfie.
- Upload via Fivemanage / LBUpload / custom.
- Captura nearby voices em vídeos (`Config.Voice.RecordNearby`).
- Vídeo: bitrate, framerate, max size, max duration configuráveis.
- Imagem: webp/png/jpg, quality 0.95.
- Sync de flash entre players (`Config.SyncFlash`).

### 4.5 Photos (Galeria)
- Álbuns próprios e compartilhados (membros).
- Visualização foto/vídeo.
- Importar links externos (`Config.AllowExternal.Gallery`) — sujeito à blacklist/whitelist de domínios.
- Compartilhar para outros apps (Birdy, InstaPic, etc.).

### 4.6 Notes
- Notas de texto (CRUD simples).
- Sync entre dispositivos do mesmo player (via DB).

### 4.7 Settings
- Display: brilho, tamanho da UI (zoom), tema (light/dark/automatic).
- Som: volume geral, volume de chamada, ringtone, texttone, modo silencioso.
- Wallpaper: ~50+ default + custom + blur.
- Lockscreen: cor (gradient/sólida), fontStyle (1-N), layout (1-N).
- Segurança: PIN, FaceID (FaceID via `client/custom/functions/face.lua` — fingerprinting do ped).
- Notificações: por-app on/off, do-not-disturb, modo avião, modo streamer.
- Time: relógio 12h/24h.
- Weather: °C/°F.
- Frame color (`Config.AllowFrameColorChange`): cor da moldura física.
- Storage: usado/total simulado (não real, marketing visual).
- Locale (26 idiomas) + DateLocale (`Intl.DateTimeFormat`).

### 4.8 AppStore
- Loja in-game.
- Apps "removable" podem ser desinstalados/reinstalados.
- Cada app tem: nome, descrição, ícone, screenshots (`images: ["1.webp", ...]`).
- Whitelist/blacklist por job (`Config.WhitelistApps`, `Config.BlacklistApps`).
- Suporte a apps customizados (`Config.CustomApps`) — docs em https://docs.lbscripts.com/phone/custom-apps/.
- Custom app loader em `client/misc/customApp.lua`.

### 4.9 Clock
- Relógio mundial (configurável — `world_clock_locations` em `config.json`: NY, London, Paris, Tokyo, Sydney, LA, Delhi, HK, Rio, Mexico, Cape Town, Stockholm, Hawaii).
- Alarmes (CRUD + recorrência) — persistido em `phone_clock_alarms`.
- Cronômetro (lap/split).
- Timer (countdown).
- Real time vs in-game time (`Config.RealTime`, `Config.CustomTime`).

### 4.10 Maps
- Mapa estilizado (não é o GPS do GTA — UI customizada).
- Pins do servidor (`Config.Locations`) — LSPD, Pillbox, etc.
- Pins do usuário (`phone_maps_locations`).
- Setar GPS no jogo a partir do app.
- Empresas mostradas se `Config.Companies.Services[*].location` definido.

### 4.11 Calculator
- Calculadora estilo iOS — operações básicas + memória.

### 4.12 Weather
- Clima de "Calyx" (`Config.CityName`).
- Sincroniza com weather do servidor (rain, snow, etc.).
- Temperatura °C/°F.
- Forecast.

### 4.13 Voice Memo
- Gravação de áudio com waveform.
- Reprodução, rename, delete.
- Compartilhar para outros apps.

### 4.14 Wallet
- Saldo (cash + bank) puxado do framework.
- Transações (depósito, saque, transferência).
- Limites: por-transação (`Config.MaxTransferAmount`), diários e semanais (`Config.TransferLimits`).
- Transferir para players offline (`Config.TransferOffline`).
- Histórico em `phone_wallet_transactions`.

### 4.15 Garage (framework)
- Lista veículos do player.
- **Valet** (`Config.Valet.Enabled`): pedir veículo entregue por NPC (`Config.Valet.Drive` — true = NPC dirige até você; false = spawn na frente).
- Preço configurável (`Config.Valet.Price`).
- Reparar ao retirar (`Config.Valet.FixTakeOut`).
- Filtro por tipo (`Config.Valet.VehicleTypes`).

### 4.16 Home (framework)
- Listar imóveis do player.
- Compartilhar acesso com outros players.
- Mover-se até a casa.
- Suporte: loaf_housing, qb-houses, qs-housing.

### 4.17 Services (framework)
- Chat de empresa (entre funcionários).
- Hire/fire/promote (`Config.Companies.Management`).
- Deposit/withdraw caixa da empresa.
- Duty (entrar/sair de serviço).
- Lista de funcionários (`Config.Companies.SeeEmployees`: everyone/employees/none).
- Receber chamadas/SMS de civis (se `canCall`/`canMessage`).

### 4.18 Music
- Playlists próprias e salvas.
- Player com play/pause/seek/skip/shuffle/repeat.
- Catálogo definido em `config/music.lua`.
- User songs em `ui/dist/assets/sound/songs/` (PLACE_SONGS_HERE).

### 4.19 DarkChat (chat anônimo)
- Canais criados por jogadores (criptografados).
- Cada usuário tem identidade própria por canal.
- Mudar senha (`Config.ChangePassword.DarkChat`).
- Logs opcionais (`Config.Logs.Actions.DarkChat`).

### 4.20 MarketPlace
- Anúncios de itens (CRUD).
- Categorias, preço, fotos.
- Mensagens entre comprador e vendedor via Messages.
- Logs (`Config.Logs.Actions.Marketplace`).

### 4.21 Yellow Pages (Pages)
- Anúncios de empresas/serviços (paineizinho de anúncio).
- Logs (`Config.Logs.Actions.YellowPages`).

### 4.22 Crypto
- Portfólio de criptos.
- Preços ao vivo via CoinGecko (`Config.Crypto.Coins`: BTC, ETH, USDT, BNB, USDC, XRP, BUSD, ADA, DOGE, SOL, SHIB, DOT, LTC, BCH).
- Cache 5min (`Config.Crypto.Refresh`).
- Buy/Sell com limites (`Config.Crypto.Limits.Buy/Sell`).
- Integração com `qb-crypto` (`Config.Crypto.QBit`).
- Currency configurável (`Config.Crypto.Currency` — usd default).

### 4.23 Twitter (Birdy)
- Tweets (texto + mídia).
- Feed: timeline, trending hashtags (reset 7d via `Config.BirdyTrending.Reset`).
- Likes, retweets, replies.
- Follows / requests (suporta contas privadas).
- DMs (`phone_twitter_messages`).
- Notificações (`Config.BirdyNotifications` — todos vs só followers).
- **Promoted posts** (`Config.PromoteBirdy`): pagar para boost (cost, views).
- Auto-follow accounts no signup (`Config.AutoFollow.Birdy.Accounts`).
- Webhook Discord para novos posts (`Config.Post.Birdy`).
- Word blacklist (`Config.WordBlacklist.Apps.Birdy`).
- Username regex (`Config.UsernameFilter.Regex`).

### 4.24 Instagram (InstaPic)
- Posts (foto/vídeo + caption).
- Stories com views (`phone_instagram_stories_views`).
- **Live** (WebRTC) — broadcast com chat ao vivo.
  - `Config.Voice.HearNearby` para nearby audio na live.
  - `Config.EndLiveClose` — encerrar ao fechar phone.
  - `Config.InstaPicLiveNotifications` — notificar todos vs só followers.
- Likes, comentários.
- DMs com mídia.
- Follows / follow requests (contas privadas).
- Auto-follow no signup.
- Webhook Discord (`Config.Post.InstaPic`).

### 4.25 TikTok (Trendy / Tiktok)
- Vídeos curtos (foto vertical / vídeo).
- Likes, saves, views, shares.
- Comentários + likes em comentários.
- Pinned videos (até N por canal).
- Channels (mensagens diretas estilo TikTok).
- **Text-to-Speech** com 30+ vozes (`Config.TrendyTTS`):
  EN US/UK/AU (M/F), FR, DE, ES, ES-MX, PT-BR (3 vozes), JP (4 vozes), KR (3 vozes), ID,
  Ghostface, Chewbacca, C3PO, Stitch, Stormtrooper, Rocket, vozes cantadas.
- Notificações + unread messages count.

### 4.26 Tinder (Spark)
- Swipe left/right.
- Matches.
- Chat com matches.
- Auto-disable de contas inativas (`Config.AutoDisableSparkAccounts` — default 7 dias).

---

## 5. Recursos transversais ("misc")

### Client
- **`accountSwitcher`** — alternar entre múltiplas contas (Insta/Birdy/Trendy) sem deslogar.
- **`airshare`** — envio P2P de fotos/vídeos para players próximos (estilo AirDrop).
- **`backup`** — backup automático ao trocar de telefone (`Config.AutoBackup`).
- **`battery`** — bateria do telefone (drain por tempo + drain quando inativo).
  - `Config.Battery.ChargeInterval`, `DischargeInterval`, `DischargeWhenInactiveInterval`.
- **`controllerCompatibility`** — suporte a gamepad.
- **`customApp`** — runtime de apps customizados (`Config.CustomApps`).
- **`debug`** — logs de debug (`Config.Debug`).
- **`errors`** — handler global de erros.
- **`exports`** — API pública para outros recursos (`exports['lb-phone']:Foo()`).
- **`flashlight`** — lanterna do telefone (com sync entre players).
- **`hearNearby`** — players próximos ouvem o telefone.
- **`notifications`** — sistema de toast/banner.
- **`recordNearbyVoices`** — captura áudio de quem está perto em vídeos.
- **`security`** — proteção contra exploits/devtools (UploadWhitelistedDomains).
- **`walkableCam`** — câmera customizada que permite andar.

### Server
- **`accountSwitcher`** — server-side counterpart.
- **`airshare`** — handler server.
- **`autoDeleteNotifications`** — limpa notifs antigas (`Config.AutoDeleteNotifications`, `Config.MaxNotifications`).
- **`backup`** — sistema de backup (`phone_backups`).
- **`battery`** — sync de bateria (exports).
- **`databaseChecker/`** — auto-detect e auto-fix de schema (`Config.DatabaseChecker.Enabled`, `AutoFix`).
- **`debug`**, **`errors`**, **`exports`** — server counterparts.
- **`notifications`** — entrega de push notifs.
- **`security`** — anti-cheat / validação de input.
- **`statistics`** — telemetria de uso por app.
- **`versionCheck`** — checa updates remotos contra a Loaf.

---

## 6. Configuração — chaves principais (`config/config.lua`, 831 linhas)

### Geral
- `Config.Debug` (bool)
- `Config.Logs.{Enabled, Service[discord/fivemanage/ox_lib], Avatar, Dataset, Actions{...}}`
- `Config.DatabaseChecker.{Enabled, AutoFix}`

### Framework & inventário
- `Config.Framework` (auto/esx/qb/qbox/ox/vrp2/standalone)
- `Config.CustomFramework` (bool)
- `Config.QBMailEvent`, `Config.QBOldJobMethod`
- `Config.Item.{Require, Name, Names[], Unique, Inventory}`
- `Config.ServerSideSpawn` (bool)

### Visual / UX
- `Config.PhoneModel` (hash GTA, default `lb_phone_prop`)
- `Config.PhoneRotation`, `Config.PhoneOffset` (vector3)
- `Config.DynamicIsland` (estilo iPhone 14 Pro)
- `Config.SetupScreen` (boot inicial)
- `Config.FrameColor`, `Config.AllowFrameColorChange`
- `Config.DefaultLocale`, `Config.DateLocale`, `Config.DateFormat`

### Telefonia
- `Config.PhoneNumber.{Format, Length, Prefixes[]}`
- `Config.CellTowers.{Enabled, Debug, MinService, Range[bars→meters]}`
- `Config.AllowNoService` (algumas operações sem sinal)

### Bateria
- `Config.Battery.{Enabled, ChargeInterval, DischargeInterval, DischargeWhenInactive*}`

### Dinheiro
- `Config.CurrencyFormat` (default `"$%s"`)
- `Config.MaxTransferAmount`, `Config.TransferOffline`
- `Config.TransferLimits.{Daily, Weekly}`
- `Config.EnableMessagePay`, `Config.EnableVoiceMessages`, `Config.EnableGIFs`, `Config.GIFsFilter`

### Mail
- `Config.EmailDomain`, `Config.AutoCreateEmail`, `Config.DeleteMail`, `Config.ConvertMailToMarkdown`, `Config.DeleteMessages`

### Empresas
- `Config.Companies.{Enabled, MessageOffline, DefaultCallsDisabled, AllowAnonymous, SeeEmployees, DeleteConversations, AllowNoService, Services[], Contacts, Management{Enabled, Duty, Deposit, Withdraw, Hire, Fire, Promote}}`

### Casas / Garage
- `Config.HouseScript` (auto/loaf/qb/qs)
- `Config.Valet.{Enabled, VehicleTypes, Price, Model, Drive, DisableDamages, FixTakeOut}`

### Voz
- `Config.Voice.{System, CallEffects, HearNearby, RecordNearby, WaitUntilNotTalking}`
- `Config.SyncFlash`
- `Config.DisableFocusTalking`

### Câmera
- `Config.Camera.{ShowTip, Enabled, Roll, AllowRunning, MaxFOV, DefaultFOV, MinFOV, MaxLookUp, MaxLookDown, Vehicle{...}, Selfie{Offset, Rotation, FOVs}, Freeze{Enabled, MaxDistance, MaxTime}}`

### Mídia / upload
- `Config.UploadMethod.{Video, Image, Audio}` (Fivemanage/LBUpload/Custom)
- `Config.UploadWhitelistedDomains[]`
- `Config.Video.{Bitrate, FrameRate, MaxSize, MaxDuration}`
- `Config.Image.{Mime, Quality}`
- `Config.AllowExternal.{Gallery, Birdy, InstaPic, Spark, Trendy, Pages, MarketPlace, Mail, Messages, Other}`
- `Config.ExternalBlacklistedDomains[]`, `Config.ExternalWhitelistedDomains[]`

### Filtros & moderação
- `Config.NameFilter` (regex)
- `Config.WordBlacklist.{Enabled, Apps{...}, Words[]}`
- `Config.UsernameFilter.{Regex, LuaPattern}`

### Apps específicos
- `Config.AutoFollow.{Enabled, Birdy, InstaPic, Trendy}.{Enabled, Accounts[]}`
- `Config.AutoBackup`
- `Config.Post.{Birdy, InstaPic, Accounts{Birdy{Username, Avatar}, InstaPic{...}}}` (webhooks)
- `Config.BirdyTrending.{Enabled, Reset}`
- `Config.BirdyNotifications`, `Config.InstaPicLiveNotifications`
- `Config.PromoteBirdy.{Enabled, Cost, Views}`
- `Config.TrendyTTS[]` (lista 30+ vozes)
- `Config.Crypto.{Enabled, Coins[], Currency, Refresh, QBit, Limits.{Buy, Sell}}`
- `Config.ChangePassword.{Trendy, InstaPic, Birdy, DarkChat, Mail}`
- `Config.DeleteAccount.{Trendy, InstaPic, Birdy, DarkChat, Mail, Spark}`
- `Config.AutoDisableSparkAccounts`

### Notificações
- `Config.AutoDeleteNotifications`, `Config.MaxNotifications`, `Config.DisabledNotifications[]`

### Permissões por job
- `Config.WhitelistApps{[appId] = {jobs[] | {job=grade}}}`
- `Config.BlacklistApps{...}`

### Mapa
- `Config.Locations[]` (pins padrão)
- `Config.CityName` (default "Calyx")
- `Config.RealTime`, `Config.CustomTime`

### WebRTC
- `Config.DynamicWebRTC.{Enabled, Service[cloudflare], RemoveStun}`
- `Config.RTCConfig.{iceServers[]}`

### Keybinds (`Config.KeyBinds`)
- `Open` (F1) — abrir telefone
- `Focus` (LMENU/Alt) — toggle cursor
- `StopSounds`
- `FlipCamera` (UP), `TakePhoto` (RETURN), `ToggleFlash` (E)
- `LeftMode` (LEFT), `RightMode` (RIGHT)
- `RollLeft` (Z), `RollRight` (C), `FreezeCamera` (X)
- `AnswerCall` (RETURN), `DeclineCall` (BACK), `UnlockPhone` (SPACE)
- `Config.KeepInput` (manter input enquanto NUI focada)

---

## 7. Configuração — `config/config.json` (UI)

### Wallpapers (~50+ chaves → arquivos .jpg)
default, cloud[2-12], pier, wheel, wheel2, lift, boat, yacht, cactus, police, thunder, underwater, globe, globeNight, moon, mountain[2-7], desert[2-5], rose[2-3], wallpaper[2-21]

### Sons
- **Ringtones:** default, harp, apex, radar, sencha, silk, summit (.mp3) + vibrate.ogg
- **Texttones:** default
- **App notifications:** vazio (extensível)

### World clock locations (13)
NY, London, Paris, Tokyo, Sydney, LA, Delhi, HK, Rio, Mexico, Cape Town, Stockholm, Hawaii

### Apps (catálogo da App Store) — ver §4

---

## 8. Settings padrão (`defaultSettings.json`)

Todo telefone novo nasce com:
```json
{
  "airplaneMode": false, "streamerMode": false, "doNotDisturb": false, "name": "",
  "display": { "brightness": 1.0, "size": 0.7, "theme": "light", "automatic": false },
  "security": { "pinCode": false, "faceId": false },
  "wallpaper": { "background": "cloud8", "blur": false },
  "time": { "twelveHourClock": false },
  "sound": { "volume": 0.5, "callVolume": 0.5, "ringtone": "default", "texttone": "default", "silent": false },
  "weather": { "celcius": false },
  "notifications": {},
  "storage": { "used": 8576331, "total": 128000000 },
  "phone": { "showCallerId": true },
  "lockscreen": { "color": "gradient", "fontStyle": 1, "layout": 1 },
  "apps": [
    ["Phone", "Messages", "Camera", "Photos"],          // dock (4 apps)
    ["Settings", "AppStore", "Clock", "Mail", "Weather", "Wallet", "Garage",
     "Home", "Maps", "Notes", "Calculator", "VoiceMemo", "Music", "Services"]  // home grid
  ]
}
```

---

## 9. Sistema de RPC interno (Lua)

`lib/client/registerCallbacks.lua` + `lib/server/registerCallbacks.lua` implementam um sistema **request/response com promessas** sobre os events do FiveM:

- `RegisterCallback(name, cb)` — handler.
- `TriggerCallback(name, ...) → Promise` — chama o outro lado e aguarda retorno.
- Arquitetura idêntica a `qb-core:RegisterCallback` mas com timeout e error handling próprios.

**Por que importa para o port:** todo o tráfego entre UI ↔ Lua client ↔ Lua server passa por esse pipe. No s&box vira `[Rpc.*]` direto + `[Sync]` — não precisa do middleware.

---

## 10. NUI (UI ↔ Lua)

A UI (`ui/dist/`) é uma SPA Vue. Comunica com o Lua client via:
- `SendNUIMessage({ action, data })` — Lua → UI
- `fetch("https://lb-phone/<event>", { body: JSON })` — UI → Lua (registrado via `RegisterNUICallback`)

A UI consome dados como se fosse um app real:
- **Code-splitting por app:** cada app é um chunk lazy-loaded (`Calculator-*.js`, `Camera-*.js`, …).
- **Roteamento interno:** Vue Router simulando navegação iOS.
- **Estado global:** Pinia/Vuex (provável — bundle minificado).
- **Internacionalização:** vue-i18n com 26 locales.

---

## 11. Integrações externas

### Mídia (uploads)
- **Fivemanage** (recomendado, com cupom `LBPHONE10`)
- **LBUpload** (self-host: github.com/lbphone/lb-upload)
- **Custom** (implementar em `shared/upload.lua`)

### Logging
- **Discord** (webhook em `server/apiKeys.lua`)
- **Fivemanage Logs Pro** (cupom `LBLOGS`)
- **ox_lib** (built-in)

### Voz nas chamadas / Live
- **pma-voice** (recomendado — única que suporta Hear Nearby e gravação nearby)
- mumble-voip / saltychat / tokovoip (legados)

### WebRTC (Live, vídeochamadas)
- STUN/TURN configurável (Cloudflare suportado nativamente em `Config.DynamicWebRTC`)
- Função custom em `server/custom/functions/webrtc.lua`

### Crypto prices
- **CoinGecko API** (`api.coingecko.com/api/v3/simple/...`)

### GIFs
- **Tenor** (filter level por `Config.GIFsFilter`)

### Webhooks Discord para posts
- Birdy / InstaPic — anuncia novos posts em canais Discord (`Config.Post.Accounts`)

### Versão
- Endpoint da Loaf consultado por `server/versionCheck.lua`

---

## 12. Localização

26 idiomas em `config/locales/*.json`:
`ar, ba, cs, de, dk, en, es, fr, hu, it, ja, nl, no, pl, pt-br, pt-pt, ro, ru, sl, sv, th, tr, ua, zh-cn`

- `Config.Locales[]` define o catálogo exibido no Settings.
- `Config.DefaultLocale` (default `"de"` — provavelmente herdado do servidor original).
- `Config.DateLocale` (BCP-47, ex: `"es-HN"`) controla `Intl.DateTimeFormat` da UI.
- `Config.DateFormat` (auto ou string custom estilo `"DDDD, MMMM DD"`).

---

## 13. Performance / segurança

- **Storage simulado** — barra "10MB used / 128MB" é cosmética (não há limite real).
- **Cache de dados** em `config/cache/`.
- **Auto-delete notifications** + cap em `Config.MaxNotifications`.
- **Word blacklist** opcional por app.
- **Domain whitelist** para uploads externos (anti-NSFW/anti-gore).
- **`Config.UploadWhitelistedDomains`** previne uso de devtools para subir mídia arbitrária.
- **`security.lua`** (client+server) — proteções anti-cheat.
- **`Config.DisableOpenNUI`** — não abre se outro recurso já tem foco NUI.

---

## 14. Apps customizados (extensibilidade)

`Config.CustomApps` + `client/misc/customApp.lua` permitem que desenvolvedores terceiros publiquem apps no LB Phone sem fork. Documentação: https://docs.lbscripts.com/phone/custom-apps/

Cada custom app traz:
- ID único
- Ícone, nome, descrição
- Bundle JS/CSS próprio
- Eventos NUI próprios
- Regras de permissão (job whitelist/blacklist)

---

## 15. Mapeamento para o port s&box (anotações para o PRD)

> Esta seção serve para o Claude Web tomar decisões durante o PRD. Não é gospel; é o mapa do território.

### 15.1 O que se reaproveita 100%
- **Assets gráficos:** ícones, wallpapers, fontes lockscreen (8), sons (ringtones, texttones), placeholders.
- **Design / fluxos / IA:** layout das telas, estrutura dos apps, hierarquia de navegação.
- **Schema de dados (lógico):** as 74 tabelas viram 74 entidades C# (POCO) — o backing store muda.
- **i18n:** os 26 JSONs viram `Localization/<locale>/phone.json` (s&box suporta 31 línguas).
- **Catálogo de wallpapers, sons, world clocks, apps removíveis:** copiar JSONs como recursos.

### 15.2 O que se reescreve do zero
- **Lua → C#** (todos os ~150 arquivos Lua).
- **Vue/SCSS → Razor/SCSS** com flexbox-only (s&box não tem `display: block/grid`).
- **NUI fetch → eventos C# diretos** (sem wrapper RPC, sem RegisterNUICallback).
- **oxmysql → backend HTTP externo + `Sandbox.Http`** (s&box não acessa MySQL direto, sem `System.IO.File`).
- **Frameworks ESX/QB/Qbox/OX/vRP/standalone → seu próprio "framework"** (s&box é greenfield — você define money, jobs, items).
- **Bridges de inventário (6) → seu próprio inventário** (irrelevante no s&box).
- **pma-voice → API nativa de Voice do s&box.**
- **WebRTC custom → ScenePanel/WebPanel ou implementação própria** (Live é o app mais difícil de portar).

### 15.3 O que muda de paradigma
- **Owner-authoritative:** estado do telefone vai num `PhoneComponent` no player com `[Sync]`. Chamadas/SMS via `[Rpc.Owner]` direcionado.
- **Persistência por jogador:** `FileSystem.Data` para configs locais; backend HTTP (Postgres/Supabase/D1) para feeds globais (Insta, Tinder, Marketplace, Birdy, TikTok, Crypto holdings, DarkChat).
- **WorldPanel vs ScreenPanel:** o telefone na mão (3D) usa `WorldPanel`, mas a interação geralmente é melhor com `ScreenPanel` overlay quando "abre" o telefone.
- **Camera walkable:** s&box tem `CameraComponent` próprio — recriar `walkableCam` é trivial.
- **Battery, sinal celular, flashlight, AirShare:** componentes pequenos, fáceis de portar.

### 15.4 Riscos / blockers para o PRD
1. **Backend de dados** — você precisa hospedar uma API HTTP. Não é blocker técnico, é operacional.
2. **WebRTC (Live, vídeochamadas)** — mais complexo no s&box. Pode ser cortado do MVP.
3. **TTS do TikTok** — depende de API externa (a UI original chama TTS no client). No s&box, fazer via `Http.RequestAsync` para um proxy.
4. **Word blacklist + moderação** — manter, é barato.
5. **Apps customizados de terceiros** — o sistema de plugins do LB Phone não tem equivalente direto no s&box; você define como.
6. **Escala da UI** — 25 apps × 5–15 telas cada = 200+ painéis Razor. Maior gasto de esforço.

### 15.5 Sugestão de fases (não vinculante)
- **Fase 0 — Esqueleto:** PhoneComponent, ScreenPanel root, NavigationHost, lockscreen, home grid, settings básicos.
- **Fase 1 — MVP comunicação:** Phone (chamadas), Messages (SMS), Contacts.
- **Fase 2 — Mídia:** Camera (foto), Photos (galeria), Voice Memo.
- **Fase 3 — Utilitários:** Clock, Calculator, Weather, Notes, Maps.
- **Fase 4 — Sociais (gold):** InstaPic (sem Live), Birdy, Trendy, Spark.
- **Fase 5 — Economia:** Wallet, Marketplace, YellowPages, Crypto.
- **Fase 6 — Extra:** DarkChat, Music, Mail, AppStore, Garage/Home/Services (depende do "framework" do seu jogo).
- **Fase 7 — Avançado:** Camera modo vídeo, InstaPic Live (WebRTC), notifications push, battery, flashlight, AirShare, TTS Trendy.

---

## 16. Glossário rápido

- **NUI** — interface web que o FiveM injeta no jogo (CEF).
- **fxmanifest** — manifesto do recurso.
- **escrow_ignore** — arquivos que ficam abertos quando o recurso é vendido com proteção (LB Phone é pago).
- **InstaPic / Birdy / Trendy / Spark / Pages** — nomes de marca dos clones de Instagram / Twitter / TikTok / Tinder / Yellow Pages dentro do telefone.
- **Loaf** — empresa por trás do LB Phone (loaf-scripts.com).
- **oxmysql** — driver MySQL padrão do ecossistema FiveM moderno.
- **pma-voice** — sistema de voz proximity (lib padrão).
- **Companies** — empregadores (police, ambulance, mecânico…) que recebem ligações/SMS.
- **Spark accounts** — contas Tinder.
- **Dynamic Island** — UI estilo iPhone 14 Pro no topo da tela.

---

*Fim. Para qualquer arquivo específico, recorra ao GitHub: https://github.com/KiKoZl1/FivemPhone (ou clone local).*
