# LB Phone — FiveM

Recurso de celular completo para servidores **FiveM** (GTA V).
Versão atual: **2.3.7** • Engine: `cerulean` • Lua **5.4** • Banco: `oxmysql`

> Documentação oficial do meu telefone: https://docs.lbscripts.com/

---

## O que é

Um sistema de smartphone in-game para roleplay, com interface Vue/JS empacotada (NUI) e backend em Lua. Suporta os principais frameworks do ecossistema FiveM e os principais inventários, com mais de 25 idiomas e dezenas de aplicativos prontos.

## Frameworks suportados

Detecção automática via `Config.Framework = "auto"` ou manual:

- **ESX** (`es_extended` — esx-legacy)
- **QBCore** (`qb-core`)
- **Qbox** (`qbx_core`)
- **OX Core** (`ox_core`)
- **vRP 2.0** (oficial)
- **Standalone** (sem framework — apps dependentes ficam desativados, salvo se você implementar as funções via `Config.CustomFramework`)

## Inventários suportados (item único do telefone)

`ox_inventory`, `qb-inventory`, `qs-inventory`, `codem-inventory`, `core_inventory`, `mf-inventory` — com auto-detecção.

---

## Aplicativos inclusos

### Padrão (`apps/default`)
- **Phone** (telefonia / chamadas)
- **Messages** (SMS)
- **Mail** (e-mail)
- **Camera** (foto/vídeo + uploads)
- **Maps**
- **Notes**
- **Clock** (relógio, alarme, timer, cronômetro)
- **Voice Memo**
- **Weather**
- **App Store**

### Sociais (`apps/social`)
- **Instagram** (InstaPic)
- **Twitter** (Birdy)
- **TikTok** (Trendy)
- **Tinder**

### Outros (`apps/other`)
- **Marketplace**
- **Crypto**
- **DarkChat**
- **Music**
- **YellowPages**

### Framework (`apps/framework`)
- **Garage** (veículos)
- **Wallet** (carteira/saldo)
- **Services** (polícia, ambulância, mecânico…)
- **Home** (housing — integrações: `loaf_housing`, `qs-housing`, `qb-houses`)

---

## Estrutura do repositório

```
.
├── fxmanifest.lua          # Manifesto do recurso FiveM (v2.3.7)
├── phone.sql               # Schema completo do banco de dados
├── inventoryitem.png       # Ícone do item no inventário
├── README.md
│
├── config/                 # Toda configuração editável
│   ├── config.lua          # Principal (framework, item, logs, etc.)
│   ├── config.json         # Configurações da UI
│   ├── defaultSettings.json
│   ├── cellTowers.lua      # Posições/raio de torres de celular
│   ├── music.lua           # Catálogo do app Music
│   └── locales/            # 25+ traduções (pt-br, en, es, fr, de, ja, …)
│
├── shared/                 # Lua compartilhado client+server
│   ├── functions.lua
│   └── upload.lua
│
├── lib/                    # Wrapper de callbacks
│   ├── client/  (keybinds, register/triggerCallbacks)
│   └── server/  (register/triggerCallbacks)
│
├── client/
│   ├── apps/               # Lógica client de cada app
│   │   ├── default/        # phone, messages, mail, camera, maps, notes, clock, voicememo, weather, appstore
│   │   ├── social/         # instagram, twitter, tiktok, tinder
│   │   ├── other/          # marketplace, crypto, darkchat, music, yellowpages
│   │   └── framework/      # garage, wallet, services, home/*
│   ├── custom/
│   │   ├── frameworks/     # bridges: esx, qb, qbox, ox, vrp2, standalone
│   │   ├── functions/      # animations, cellTowers, death, face, voice, item, etc.
│   │   └── uniquePhones/   # bridges para inventários (telefones únicos)
│   ├── lib/
│   └── misc/
│
├── server/
│   ├── apiKeys.lua         # Webhooks/API keys (Discord, fivemanage…)
│   ├── apps/               # Espelha client/apps no lado server
│   │   ├── default/, social/, other/, framework/
│   ├── custom/
│   │   ├── frameworks/     # bridges esx/qb/qbox/ox/vrp2/standalone (commands, money, mail, services, vehicles)
│   │   ├── functions/      # blacklist, entities, htmlToMarkdown, item, logs, voice, webrtc, …
│   │   └── uniquePhones/   # bridges de inventário server-side
│   ├── data/
│   └── misc/
│       ├── backup.lua
│       ├── debug.lua
│       └── databaseChecker/  # auto-fix do schema
│
└── ui/                     # Frontend (build pronta)
    ├── components.js
    └── dist/
        ├── index.html
        └── assets/         # JS/CSS por app + fontes, imagens, ringtones, songs, texttones
```

---

## Pré-requisitos

- Servidor FiveM com `lua54 yes`
- [`oxmysql`](https://github.com/overextended/oxmysql) iniciado **antes** deste recurso
- Banco MySQL/MariaDB
- (Opcional) `pma-voice` ou similar para voz nas chamadas
- (Opcional) `fivemanage` ou Discord webhook para logs/uploads

## Instalação rápida

1. Clone/baixe esta pasta para `resources/[lb]/lb-phone` (ou nome equivalente).
2. Importe o schema:
   ```sql
   SOURCE phone.sql;
   ```
3. Em `config/config.lua` ajuste:
   - `Config.Framework` (deixe `"auto"` na maioria dos casos)
   - `Config.Item` (nome do item, único ou não, inventário)
   - `Config.Logs` (Discord/fivemanage/ox_lib)
4. Em `server/apiKeys.lua` configure webhooks/keys.
5. Adicione no `server.cfg`:
   ```
   ensure oxmysql
   ensure lb-phone
   ```
6. Crie o item `phone` no seu inventário (use `inventoryitem.png` como ícone).

> Guia completo, screenshots e troubleshooting: **https://docs.lbscripts.com/**

## Logs e uploads

Suporta três provedores configuráveis em `Config.Logs.Service`:
- `discord` — webhook em `server/apiKeys.lua`
- `fivemanage` — plano Logs Pro (cupom `LBLOGS` para 20% off)
- `ox_lib`

Eventos logados: chamadas, mensagens, InstaPic, Birdy, YellowPages, Marketplace, Mail, Wallet, DarkChat, Services, Crypto, Trendy, Uploads.

## Telefones únicos / múltiplos modelos

`Config.Item.Unique = true` permite cada telefone ter sua própria identidade, fotos, contatos, apps. Vários itens com cores/modelos diferentes via `Config.Item.Names` (exemplo comentado no `config.lua`).

## Internacionalização

26 idiomas em `config/locales/` (incluindo **pt-br** e **pt-pt**). Para adicionar/editar, copie um JSON existente e referencie em `config.lua`.

---
