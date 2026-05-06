# LB Phone — Especificação Visual (inferida)

> Companion do `PHONE_SPEC.md`. Foca em **identidade visual, design tokens, layout e iconografia** — extraídos diretamente do bundle CSS minificado (`ui/dist/assets/*.css`), do `index.html`, e dos assets em `ui/dist/assets/img/`.
> Use isto + screenshots reais (quando você capturar) para fechar o PRD do port s&box.
> **Confiança:** alta para tokens (cores, fontes, animações, raios), média para layouts (inferido por nomes de classes), baixa para microinterações (precisa screenshot/vídeo).

---

## 1. Stack visual

- **Bundler:** Vite (chunks por app com hash no nome).
- **Framework UI:** Vue 3 (montado em `<div id="root">`).
- **Mapas:** Leaflet (classes `.leaflet-*` presentes no CSS — confirma).
- **Emoji picker:** `emoji-picker-react` (classes `.EmojiPickerReact`, `.epr-*`).
- **Icon set primário:** Font Awesome Pro v5.15.4 (CDN).
- **Icon set secundário:** React Icons (referenciado em `Config.Companies` como `IoShield`).

## 2. Tipografia

Fontes carregadas globalmente (em `index.html`):

| Família | Pesos disponíveis | Uso provável |
|---|---|---|
| **Inter** | 100–900 (variable) | Padrão da UI (textos, labels) |
| **Poppins** | 100–900, italic | Headings, botões maiores, marcas |
| **Roboto** | 100, 300, 400, 500, 700, 900 + italic | Específico de apps (Birdy, Trendy) |
| **Proxima Nova 2** | (cdnfonts) | Específico de algum app (provavelmente Spark/Birdy) |

Fontes locais (`ui/dist/assets/fonts/lockscreen/`) — usadas só na **lockscreen** (estilos selecionáveis em `lockscreen.fontStyle`):

- AbrilFatface.ttf
- Gloock.ttf
- Library3am.otf
- Limelight.ttf
- Monoton.ttf
- Nunito-Black.ttf, Nunito-Medium.ttf
- ProtestGuerrilla.ttf

Tamanhos de fonte mais usados (extraídos do CSS):
`12px, 13px, 14px, 15px, 16px, .75rem, 1.15rem, 1.5rem, 1.9rem`. Padrão **iOS-like** (base 14–16, títulos 1.5–1.9rem).

---

## 3. Design tokens — cores

> Todos os tokens aparecem em pares **light / dark** (`[data-theme=dark]`). Essa é a fonte da verdade — copiar literal para o s&box.

### 3.1 Tokens globais do telefone (`--phone-*`)

| Token | Light | Dark |
|---|---|---|
| `--phone-color-primary` | (default) | `#000000` |
| `--phone-color-blue` | `#0a84ff` | `#076bcf` |
| `--phone-color-green` | `#32d74b` | `#32d74b` |
| `--phone-color-green-secondary` | `#092911` | `#092911` |
| `--phone-color-red` | `#ff3b30` | `#ff3b30` |
| `--phone-color-pink` | `#ff3b30` | `#ff3b30` |
| `--phone-color-orange` | `rgb(255, 157, 10)` | `rgb(255, 157, 10)` |
| `--phone-color-yellow` | `#cca250` | `#cca250` |
| `--phone-color-grey` | `#8e8e93` | `#636366` |
| `--phone-text-primary` | `rgb(0, 0, 0)` | `#f2f2f7` |
| `--phone-text-secondary` | `rgb(142, 142, 147)` | `#6f6f6f` |
| `--phone-color-highlight` | `rgb(250, 250, 250)` | `rgb(15, 15, 15)` |
| `--phone-color-highlight2` | `rgb(240, 240, 240)` | `rgb(20, 20, 20)` |
| `--phone-color-highlight3` | `rgb(220, 220, 220)` | `rgb(25, 25, 25)` |
| `--phone-color-hover` | `rgb(240, 240, 240)` | `rgb(30, 30, 30)` |
| `--phone-color-input` | `rgba(241, 241, 241, .656)` | `rgba(60, 60, 67, .6)` |
| `--phone-color-border` | `rgba(200, 200, 200, .4)` | `rgba(150, 150, 150, .2)` |
| `--phone-color-opacity` | `rgba(242, 242, 242, .4)` | `rgb(30, 30, 30, .5)` |
| `--phone-highlight-opacity15` | `rgba(145, 145, 145, .15)` | `rgba(145, 145, 145, .15)` |
| `--phone-highlight-opacity35` | `rgba(145, 145, 145, .35)` | `rgba(145, 145, 145, .35)` |
| `--phone-highlight-opacity45` | `rgba(145, 145, 145, .45)` | `rgba(50, 50, 50, .6)` |
| `--phone-highlight-opacity55` | `rgba(145, 145, 145, .55)` | `rgb(60, 60, 60, .8)` |

> **Observação iOS DNA:** os tokens batem 1:1 com o System Colors da Apple (`#0a84ff` é o systemBlue dark, `#32d74b` é systemGreen dark, `#ff3b30` é systemRed). É um clone deliberado do iOS.

### 3.2 Tokens de componentes genéricos (`--components-*`, `--app-*`)

| Token | Light | Dark |
|---|---|---|
| `--components-bg` | `#eeeeee` | `#000000` |
| `--components-secondary` | `#ffffff` | `#141414` |
| `--components-highlight` | `#cccccc` | `#696969` |
| `--app-bg` | `#ececec` | `#000000` |
| `--app-bg2` | `#ffffff` | `#000000` |
| `--app-secondary` | `#ffffff` | `#141414` |
| `--app-secondary2` | `#ececec` | `#141414` |
| `--app-border` | `#cccccc` | `#666666` |
| `--app-button` | `#ffffff` | `#333333` |
| `--app-highlight` | `#cccccc` | (não definido — herda) |
| `--app-highlight2` | `#999999` | `#696969` |
| `--app-highlight3` | `#ffffff` | `#212121` |
| `--app-slider` | `#cccccc` | `#999999` |
| `--app-slider-active` | `#ffffff` | `#333333` |

### 3.3 Notification & Control Center

| Token | Light | Dark |
|---|---|---|
| `--notification-primary` | `rgba(215, 215, 215, .5)` | `rgba(0, 0, 0, .1)` |
| `--notification-secondary` | `rgba(215, 215, 215, .1)` | `rgba(0, 0, 0, .12)` |
| `--controlcentre-opacity` | `rgba(255, 255, 255, .15)` | `rgba(0, 0, 0, .15)` |
| `--controlcentre-opacity2` | `rgba(255, 255, 255, .2)` | `rgba(0, 0, 0, .2)` |
| `--controlcentre-active` | `rgba(255, 255, 255, .5)` | `rgba(0, 0, 0, .5)` |

### 3.4 Lockscreen Editor

| Token | Light | Dark |
|---|---|---|
| `--lockscreeneditor-background` | `rgba(255, 255, 255, .75)` | `rgba(0, 0, 0, .8)` |
| `--lockscreeneditor-secondary` | `#d9d9d9` | `#333333` |

### 3.5 Browser-like (DarkChat ou navegador interno)

| Token | Light | Dark |
|---|---|---|
| `--browser-primary` | `rgb(245, 245, 245)` | `rgb(15, 15, 15)` |
| `--browser-secondary` | `rgba(153, 153, 153, .15)` | (mesmo) |
| `--browser-text-secondary` | `#999999` | `#696969` |
| `--browser-border` | `rgba(102, 102, 102, .75)` | (mesmo) |
| `--browser-footer` | `rgba(255, 255, 255, .75)` | `rgba(51, 51, 51, .75)` |
| `--browser-gradient` | `linear-gradient(230deg, #f4d6ff, #c5f1ff)` | `linear-gradient(230deg, #453b48, #2f393d)` |

### 3.6 Por-app (palette própria — fundamentais para identidade)

#### Instagram (InstaPic)
| Token | Light | Dark |
|---|---|---|
| `--instagram-primary` | `#ffffff` | `#000000` |
| `--instagram-primary-text` | `rgb(38, 38, 38)` | `rgb(250, 250, 250)` |
| `--instagram-secondary-text` | `rgb(142, 142, 142)` | (mesmo) |
| `--instagram-border` | `rgb(219, 219, 219)` | `rgb(54, 54, 54)` |
| `--instagram-stroke` | `rgb(219, 219, 219)` | (mesmo) |
| `--instagram-highlight` | `rgb(239, 239, 239)` | `rgb(38, 38, 38)` |
| `--instagram-blue` | `rgb(0, 149, 246)` | (mesmo) |
| `--instagram-red` | `rgb(237, 73, 86)` | (mesmo) |

#### Twitter (Birdy)
| Token | Light | Dark |
|---|---|---|
| `--twitter-primary` | `#f5f8fa` | `#000000` |
| `--twitter-primary-text` | `#f5f8fa` (espelho) | `#14171a` |
| `--twitter-secondary` | `#f5f8fa` | `#14171a` |
| `--twitter-secondary-text` | `#aab8c2` | `#657786` |
| `--twitter-blue` | `#1d9bf0` | (mesmo) |
| `--twitter-action` | `#1d9bf0` | `#14171a` |
| `--twitter-alt-text` | `#657786` | (mesmo) |
| `--twitter-border` | `#bdc5cd75` | `#38444d` |
| `--twitter-border-secondary` | `#38444d` | `#1d9bf0` |
| `--twitter-highlight` | `#dcdcdc` | `#1d9bf0` |
| `--twitter-background-highlight` | `rgb(239, 243, 244)` | `rgb(20, 20, 20)` |
| `--twitter-hover` | `rgba(150, 150, 150, .1)` | `rgba(15, 20, 25, .1)` |

#### TikTok (Trendy)
| Token | Light | Dark |
|---|---|---|
| `--tiktok-primary` | `#ffffff` | (mesmo) |
| `--tiktok-secondary` | `#000000` | (mesmo) |
| `--tiktok-text-primary` | `#000000` | `#f2f2f7` |
| `--tiktok-text-secondary` | `#86878b` | `#6f6f6f` |
| `--tiktok-color-pink` | `#fe2c55` | (mesmo) |
| `--tiktok-color-aqua` | `#00f2ea` | (mesmo) |
| `--tiktok-color-blue` | `#479fc5` | (mesmo) |
| `--tiktok-color-yellow` | `#f8cd14` | (mesmo) |
| `--tiktok-color-border` | `#d0d1d3` | `#96969633` |
| `--tiktok-color-unread` | `rgba(254, 44, 86, .2)` | (mesmo) |

#### Tinder (Spark)
| Token | Valor |
|---|---|
| `--tinder-color-pink` | `#ff4573` |
| `--tinder-color-orange` | `#ff5f65` |
| `--tinder-color-mix` | `#f5547c` |

> Note o gradiente característico do Tinder (`#ff4573 → #ff5f65`).

#### Crypto
| Token | Light | Dark |
|---|---|---|
| `--crypto-color-primary` | `rgb(255, 255, 255)` | `rgb(24, 26, 32)` |

---

## 4. Tipografia base e elementos

- **Base text:** `Inter` 14–16px / `--phone-text-primary`.
- **Títulos de seção:** ~`.title { font-size: 14px–15px }` (em context menus e share components).
- **Headings de página:** 1.5rem ~ 1.9rem.
- **Botões:** padding flex, `border-radius: 12–15px` (recorrente nos tokens).
- **Cards / surfaces:** `border-radius: 14–15px` (estilo iOS).
- **Avatares:** `border-radius: 100%` (círculos perfeitos).
- **Notification banners:** `border-radius: 18px` (padrão iOS notif).

---

## 5. Animações & transições (extraídas do CSS)

Todas declaradas em `index-5a998551.css`:

| Keyframe | O que faz | Onde se usa (provável) |
|---|---|---|
| `zoomIn` | `scale(.5) → 1` | Abertura de app / modal |
| `zoomOut` | `scale(1.5) → 1` | Fechamento (reverso) |
| `slideDown` | `translateY(-20%) → 0` | Notificações, menus topo |
| `slideUp` | `translateY(40%) → 0` | Sheets, control center |
| `slideRight` | `translate(-10%) → 0` | Push de navegação (back) |
| `slideLeft` | `translate(10%) → 0` | Push de navegação (forward) |
| `appJiggle` | `rotate(-1deg)` (oscila) | **Modo edit da home** (apps tremendo) |
| `widgetJiggle` | similar | Modo edit de widgets |
| `wrongCode` | shake | PIN errado na lockscreen |
| `clear` | (não inspecionado em detalhe) | Notification clear |
| `loadNotification` | (entrada animada) | Push de notificação |

> **Hint para o port s&box:** todos esses keyframes equivalem a `@keyframes` em SCSS no s&box (suporta nativamente). Os pares `:intro/:outro` do s&box podem substituir `slideUp/slideDown` para criação/destruição de painéis.

---

## 6. Estrutura de tela (inferida por nomes de classe)

### 6.1 Frame físico do telefone
Classes encontradas:
- `.phone-frame` — moldura externa.
- `.frame-buttons` (`.left`, `.right`) — botões físicos laterais (volume, power, mute switch). Cada botão tem altura própria (`3em` para o primeiro do bloco esquerdo).
- `.frame-button` — botão individual.
- `.notch-wrapper` → `.notch` → `.notch-content` — **Dynamic Island** (config `Config.DynamicIsland`).
- Cor da moldura: configurável pelo player (`Config.FrameColor`, default `#39334d` "silver").

### 6.2 Notch (Dynamic Island)
- Container: `.notch-wrapper` → `.notch` → `.notch-content`.
- Modos detectados:
  - `.call` (chamada ativa, tem `.left.green`, `.user .name`)
  - `.airdrop-mode` (recebendo AirShare — `.airdrop-header .avatar`)
  - Música tocando (provável, dado o `.music-player` no control center)
- Animado, expande/contrai (estilo iPhone 14 Pro).

### 6.3 Lockscreen
Classes/configs:
- `lockscreen.color`: `gradient` (default) ou cor sólida.
- `lockscreen.fontStyle`: 1..N (uma das 8 fontes em `fonts/lockscreen/`).
- `lockscreen.layout`: 1..N (variações de layout).
- Editor próprio (`--lockscreeneditor-*` tokens) — usuário customiza ao vivo.
- Falha de PIN: anima `wrongCode` (shake horizontal).
- Suporta **FaceID** (`security.faceId`) e **PIN code** (`security.pinCode`).
- Asset hint: `img/icons/setup/lock.svg`, `faceUnlock.png`, `theme.svg`, `logo.svg`.

### 6.4 Home (springboard)
Classes:
- `.app-grid` / `.app-items` — grid de apps.
- `.app-icon` / `.app-name` — cada app.
- `.app-wrapper` → `.image .appDelete` (X de remover) com `.appDeleteBlur`.
- `.drag-app` — arrasto de app entre páginas/dock.
- `.app-canister` / `.app-containerbox` / `.app-content` — estrutura de cada slot.
- Animação de jiggle em modo edit (`appJiggle`, `widgetJiggle`).
- `defaultSettings.json → apps` define dois "rows": **dock fixo (4 apps)** + **grid principal (até 14 apps default)**.

### 6.5 Control Center
- Classes `.control-centre`, `.control-centre-bar`, `.control-centre-body`, `.control-centre-container`.
- `.music-player` (com `.song .song-info`, `.slider`) — controle de música ativa.
- Contém toggles (Wi-Fi, Bluetooth, Airplane, DnD, Streamer Mode, Brightness, Volume).
- Cores opacas/translúcidas (`--controlcentre-opacity*`).

### 6.6 Notifications
Classes `.notification`, `.notification-wrapper`, `.notification-stack`, `.notification-container`, `.notification-content`, `.notification-header`, `.notification-actions`.
- Animação de entrada (`loadNotification`).
- Avatar circular `2.75rem`, raio 100%.
- Stack agrupada (estilo iOS).

### 6.7 Sheets / Modais
- `.context-wrapper` → `.context-container` → `.context-buttons` (action sheets).
- `.share-component` → `.app-items` / `.airdrop` (share sheet com AirShare integrado).
- `.color-picker-container` (full color picker para wallpaper/lockscreen).
- `.emoji-container` → `.emoji-picker` (emoji-picker-react).

---

## 7. Apps — visual app-by-app

### 7.1 Phone (`Phone-*.css`, ~28 KB)

Classes principais:
- `.phone-app-container` (root)
- `.contacts-header`, `.contacts`, `.contact-list`, `.contact` (lista A-Z estilo iOS Contacts)
- `.recent-calls`, `.call-item`, `.call-content`, `.call-duration` — histórico
- `.keypad-wrapper` → `.keypad-container` → `.keypad` (teclado discador)
  - `.input` / `.inputbox` (display do número)
  - `.letters` (as letras ABC sob cada número)
  - `.phone_number` / `.phone-number`
- `.favourites` / `.favourite` (estrela de favoritos)
- `.profile` → `.profile-image` / `.profile-info` (tela do contato)
- `.call-content`, `.call-duration`, `.call`, `.green` / `.red` / `.blue` (estados de botão chamada)
- `.animation-container` (animação de chamada ativa)
- `.searchbox` (busca)
- Tabs inferidas (3–4): Favoritos, Recentes, Contatos, Teclado, Voicemail.

### 7.2 Messages (`Messages-*.css`, ~43 KB — **maior chunk**)
- Implica UI mais rica: bubbles de mensagem, multimedia, GIFs, áudio, transferência $, contact selector, AirDrop.
- Classes esperadas (padrão de bubble chat iOS): bubbles azul (sent) e cinza (received) com cantos arredondados em 18–22px.
- Suporte a anexos: `gallery.png` em `img/icons/messages/`.

### 7.3 Camera (`Camera-*.css`, ~10 KB)
Classes:
- `.camera-container` → `.camera-body` / `.camera-header` / `.camera-bottom`
- `.camera-button` / `.camera-button-container` / `.camera-button-inner` (shutter circular)
- `.camera-buttons`, `.camera-types` (tabs: foto, vídeo, selfie, etc.)
- `.flip-camera` (botão flip)
- `.activephoto-container` (preview pós-foto)

### 7.4 Settings (`Settings-*.css`, ~22 KB)
Estrutura iOS Settings: lista de seções com chevron (`>`), agrupadas em cards arredondados sobre fundo cinza claro/preto.
- `.section`, `.option`, `.divider` (linhas separadoras)
- `.color-picker-*` (para wallpaper/frame color)
- Switches (`.checkbox`, `.checked`) e sliders (`.duration-slider`, `Slider-*.css` chunk separado).

### 7.5 Home (`Home-*.css`, ~9 KB)
Inclui:
- Grid de imóveis (background em `img/backgrounds/default/apps/home/`)
- Detalhes da casa, lista de membros, ações (compartilhar acesso).

### 7.6 Calculator (`Calculator-*.css`, ~7 KB)
- Layout iOS Calculator clássico: display superior + grid 4 colunas × 5 linhas.
- Botões circulares, cores: cinza (números), laranja (`#ff9d0a`) operadores, cinza claro (AC, +/-, %).

### 7.7 Clock (`Clock-*.css`, ~24 KB)
Implica 4 sub-telas (World Clock, Alarm, Stopwatch, Timer).
- `.clock-alert` (notificação de alarme).
- World clock cards com TZ (lista de 13 cidades pré-cadastradas).
- Stopwatch com lap list.

### 7.8 Maps (`Maps-*.css`, ~9 KB)
- Usa Leaflet (`.leaflet-popup-content`, raio 12px).
- `mappin.png`, `pin.svg` (marcadores).
- Search bar, lista de pontos, route preview.

### 7.9 Notes (`Notes-*.css`)
- Lista de notas (cards), editor minimalista estilo iOS Notes.

### 7.10 Mail (`Mail-*.css`)
- Inbox / pastas, lista de emails (avatar + preview), composer rich text.

### 7.11 VoiceMemo (`VoiceMemo-*.css`)
- Botão de gravação central com pulso animado, waveform.
- Lista de gravações (rename, share, delete).

### 7.12 Weather (`Weather-*.css`)
Assets: `cloudy.png, drizzle.png, fog.png, heavy-rain.png, night.png, partly-cloudy-night.png, partly-cloudy-sunny.png, rain.png, snow.png, sunny.png, thunder.png, tornado.png, wind.png, windy.png` (14 ícones de clima).
- Background dinâmico em `img/backgrounds/default/apps/weather/`.
- Forecast cards horizontais.

### 7.13 Garage (`Garage-*.css`)
- Background em `img/backgrounds/default/apps/garage/`.
- Lista de veículos (cards com imagem do carro), botão Valet com preço.

### 7.14 Wallet (`Wallet-*.css`)
- Card visual (`card.png`) — provavelmente mostra saldo estilo cartão.
- Lista de transações (debit/credit, ícone por categoria, valor).
- Botões grandes (Send, Request).

### 7.15 Music (`Music-*.css`)
- Player full-screen com artwork central, scrubber, controles.
- Lista de playlists, busca, agora-tocando integrado ao Control Center.

### 7.16 Marketplace (`Marketplace-*.css`)
- Grid de anúncios (estilo OLX/marketplace), filtros por categoria.
- Detalhes do anúncio com galeria horizontal.

### 7.17 YellowPages (`YellowPages-*.css`)
- Lista de empresas, busca, criar anúncio.

### 7.18 Crypto (`Crypto-*.css`)
- Background `cryptogradient.png`.
- Cards de moedas com sparkline, preço, variação 24h.
- Tela de buy/sell com slider de quantidade.

### 7.19 DarkChat (`DarkChat-*.css`)
- Visual escuro forçado (anônimo). Salas, lista de membros.

### 7.20 Twitter / Birdy (`Twitter-*.css`)
Assets:
- `banner.png` (banner padrão de perfil)
- `heart.svg` (ícone like)
- `logo.png`
Layout:
- Timeline com tweets (avatar 48px, nome bold, @handle cinza, timestamp).
- Bottom tabs (Home, Search, Notifications, Messages).
- FAB de novo tweet (azul `#1d9bf0`).
- Tendências, threads.

### 7.21 Instagram / InstaPic (`Instagram-*.css`)
Assets:
- `icon.svg` (logo)
- `LiveCircle.svg`, `StoryCircle.svg` (anéis de stories e live — gradiente característico)
- `Verified.svg` (selo verificado azul)
- `logo.png`
Layout:
- Feed vertical, header com logo central.
- Stories rail no topo com gradient ring (Live em vermelho).
- Bottom tabs (Home, Search, Add, Reels, Profile).
- Botão Live em destaque.

### 7.22 TikTok / Trendy (`Tiktok-*.css`)
Layout:
- Feed vertical full-screen estilo TikTok.
- Lateral direita: like (coração), comentário, share, save (`--tiktok-color-pink #fe2c55`).
- TTS: 30+ vozes selecionáveis na composição.
- Cores da marca: pink `#fe2c55` + aqua `#00f2ea` + azul `#479fc5` + amarelo `#f8cd14`.

### 7.23 Tinder / Spark (`Tinder-*.css`)
Assets:
- `logo.svg` / `logo-white.svg` (logo)
- `match.png` (overlay de match)
Layout:
- Card swipeável central (foto + nome + idade + bio).
- Botões inferiores: dislike (X vermelho), super-like (estrela azul), like (coração rosa).
- Cores da marca: gradient `#ff4573 → #ff5f65`.

### 7.24 Services (`Services-*.css`)
- Chat de empresa (similar ao Messages mas restrito).
- Painel de boss (Hire/Fire/Promote/Deposit/Withdraw) — só para `bossRanks`.
- Lista de funcionários com online status.

---

## 8. Iconografia

### 8.1 Ícones de apps (`img/icons/apps/`, 33 arquivos)
Cada app tem seu ícone `.jpg` (256×256 provável). Lista completa:
`AppStore, Birdy, Calculator, Camera, Clock, Crypto, Cryptopng, DarkChat, FaceTime, Garage, Health, Home, InstaPic, Mail, Maps, MarketPlace, Messages, Music, Notes, Phone, Photos, Racing, Safari, Services, Settings, Spark, Trendy, VoiceMemo, Wallet, Weather, YellowPages, unknown`.

> Note: existem ícones para apps **não implementados** ainda (`FaceTime`, `Health`, `Racing`, `Safari`) — sinalizam roadmap futuro.

### 8.2 Screenshots da App Store (`img/icons/appstore/appimages/<App>/<n>.webp`)
Cada app removível tem 1–8 screenshots vendidos na loja:
- Crypto (2), DarkChat (4), Instagram (7), MarketPlace (4), Music (2), TikTok (1), Tinder (5), Twitter (8), YellowPages (2)

### 8.3 Avatares e placeholders
- `avatar-placeholder-{dark,light}.svg` — placeholder de pessoa (initial fallback).
- `placeholder-{dark,light}.svg` — placeholder de imagem genérica.
- `no-pfp.png` — sem profile picture.

### 8.4 Wallpapers (`img/backgrounds/default/`)
~50 wallpapers padrão organizados em categorias:
- Naturais: `cloud[1-12]`, `mountain_[01-07]`, `desert_[01-05]`, `rose[1-3]`, `cactus`, `pier`, `wheel[1-2]`, `lift`, `Boat`, `yacht`, `underwater`, `Globe`, `GlobeNight`, `Moon`
- Tema: `police`, `thunder`, `default`
- Genéricos: `wallpaper[1-21]`

Cada app pode ter background dedicado (`apps/garage/`, `apps/home/`, `apps/weather/`).

### 8.5 Ícones específicos de feature
- `setup/`: `faceUnlock.png`, `lock.svg`, `logo.svg`, `theme.svg` (telas de setup wizard).
- `messages/`: `gallery.png` (botão galeria no chat).
- `maps/`: `mappin.png`, `pin.svg`.
- `weather/`: 14 ícones meteorológicos (`.png`).

---

## 9. Sons (`ui/dist/assets/sound/`)

### 9.1 Ringtones (`ringtones/`)
`apex.mp3, default.mp3, harp.mp3, radar.mp3, sencha.mp3, silk.mp3, summit.mp3` + `vibrate.ogg`

> Nomes idênticos a ringtones reais do iOS (`apex`, `radar`, `sencha`, `silk`, `summit`) — mais um sinal do clone iOS deliberado.

### 9.2 Texttones (`texttones/`)
`default.mp3` (extensível pelo servidor).

### 9.3 Songs (`songs/`)
`PLACE_SONGS_HERE` + `READ_ME.txt` — vazio por design, o servidor adiciona MP3s próprios para o app Music.

### 9.4 Outros
`other/voicemail/` — clipes de voicemail padrão.

---

## 10. Responsividade & dimensões

- Telefone simulado em **resolução fixa** (não inspecionado o ratio exato, mas o NUI roda fullscreen e o telefone é desenhado dentro).
- Tamanho da UI escalável pelo player: `display.size: 0.7` default (faixa provável 0.5–1.5).
- `Length` units no s&box equivalentes: `Length.Pixels`, `Length.Percent`, `Length.ViewHeight` — usar `vh`/`vw` para o telefone seguir o tamanho de tela.

---

## 11. Resumo executivo para o port s&box

### Identidade visual = clone iOS deliberado
- System Colors da Apple copiados literalmente.
- Ringtones com nomes Apple.
- Componentes: Dynamic Island, Control Center, Notification Center, lockscreen com PIN/FaceID, app jiggle no modo edit.
- Tipografia Inter (system font padrão moderno).

### O port deve respeitar
1. **Tokens de cor light/dark** (copiar tabelas §3 literal — funcionam como `--var` no SCSS do s&box).
2. **Border-radius padrão iOS:** 10–18px para cards/botões/notifs.
3. **Animações:** `zoomIn/Out`, `slideUp/Down/Left/Right`, `appJiggle`, `wrongCode` — todas implementáveis em SCSS keyframes ou pelos `:intro/:outro` do s&box.
4. **Hierarquia visual:** lockscreen → home (dock + grid) → app fullscreen → modal sheets sobrepostas.
5. **Iconografia:** ícones `.jpg` 256×256 dos apps — copiar diretamente para o projeto s&box (`assets/img/icons/apps/`).
6. **Dynamic Island** como `Panel` ancorada no topo, com transições de tamanho/conteúdo conforme o estado (call, music, airdrop).

### O que ainda precisa screenshot
- Layout exato da home grid (colunas/linhas/spacing).
- Forma e dimensões da Dynamic Island.
- Spacing dos elementos no Control Center.
- Microcopy em PT-BR vs EN.
- Estados de loading, erro, vazio em cada app.
- Lockscreen layouts 1..N (8 fontes × N layouts).

> Capture **22 prints** (lockscreen, home, control center, notif center, e cada app aberto na sua tela principal) e o conjunto `PHONE_SPEC.md` + `PHONE_VISUAL_SPEC.md` + screenshots fecha o PRD do port.

---

## 12. Mapa rápido CSS chunk → tamanho

| App | Tamanho CSS (chars) | Complexidade visual |
|---|---:|---|
| Messages | 43.655 | **Muito alta** (chats, mídia, GIFs, AirDrop, transfer $) |
| Phone | 28.885 | Alta (tabs, keypad, calls, contacts) |
| VoiceMemo | (verificar) | Média (waveform, lista) |
| Clock | 24.248 | Alta (4 sub-apps em um) |
| Settings | 22.291 | Alta (muitas seções) |
| Camera | 10.625 | Média |
| Maps | 9.202 | Média (Leaflet faz o trabalho pesado) |
| Home | 9.091 | Baixa-média |
| Calculator | 6.709 | Baixa |
| **index global** | **154.995** | Frame, lockscreen, springboard, notch, control center, notifs, sheets, color picker, emoji picker, share, animações, tokens — toda a infra |

Esse mapeamento é útil para **estimar esforço de port por app**: Messages / Phone / Clock / Settings vão consumir 60–70% do tempo de UI; Calculator/Home/Maps são quick wins.

---

*Fim. Para refinar com pixel-perfect real, é só capturar prints e reabrir esta spec — eu adiciono uma seção de medições por screenshot.*
