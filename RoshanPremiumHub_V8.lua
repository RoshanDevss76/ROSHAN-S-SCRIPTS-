--[[
    ROSHAN'S PREMIUM HUB V8  |  Doors (Archives + Stairwell + Candy Vault)
    - Roles: Guest / Member / Booster / VIP + staff
    - Pantalla de carga, pestaña Perfil, Bridge Saver (Mines)
    - Key system + UI móvil
    - Idiomas: Español / English / Português
    - Zona VIP (devs, staff y boosters con key VIP) + herramientas Dev
    - ESP / Anti por EVENTOS (sin escaneos pesados = sin lag)
    - Sin sistema de kick / sin control remoto
    - V6.1: pantalla de carga nueva, barra lateral en PC, Salto infinito, Anti AFK,
      Quitar niebla, Tercera persona, Sin jumpscares, sin sacudida de cámara
    - V6.2+: extras de Rush Hub (Door Reach, Closet Delay, Escondites transparentes,
      Quitar cutscenes, Audio), rango Premium, Auto Interact inteligente (sin sillas),
      insignia Verified, herramientas de staff, registros locales agrupados en tablas
    - Extras: pestaña Estado (usuarios activos / ejecuciones), Mis Apps,
      Auto Door 50 / 100 (BETA), mensaje VIP, extras Boost/VIP, carga mejorada
    - Archives: Anti Ransom (congela), Anti Drones, Anti Forget-Me-Not
    - Candy Vault (Hollow): ESP caramelos/llaves/calderos + alertas Sir Abe/Socker
    - Anti Lag mejorado (luces, trails, auto-FPS) + extras VIP
    - Key: minimizar/cerrar, sección VIP/Boost, canje de key dentro del hub (se reconstruye)
    - Rol Veteran, Mines ESP, Anti Ragdoll, Anti Drones mejorado, Door 100 reescrito
    - V6.2: pantalla de carga nueva (estrellas, escaner, checklist), UI pulida (brillo, hover,
      transiciones), Door 100 con remote EBF, Anticheat Bypass con re-deteccion, antis a nivel
      workspace (Drones/Alma/Scribbles/Ransom/Closet Trash), Agua electrica, Stop Time + reloj,
      Pack Bypass (Banana/Jeff/Lava/Seeking Wall/Vacuum), extras Boost y VIP
    - V7 (version final): Godmode estilo Nova, Delete Seek/Figure, Items infinitos, Prompt Clip, Auto Heartbeat,
      Freecam, Revive/Play Again/Lobby, teleports a modos, config guardada, panico, apagado sin fugas, arranque protegido.
    - V7 (insano): Auto Godmode + Figure God Mode (sin saltos, sin hundirte), Anti A-90 con remote falso,
      Anti Bash/A-120 reforzados para Rooms, ESP con presupuesto de resaltados, Auto Minecart, Auto A-1000,
      FPS con medicion real, anti-manipulacion de la key (+ validacion en servidor opcional), insignia Verified.
    - V6.3: limpieza de codigo duplicado (Infinite Jump / Anti AFK / traducciones), keys
      solo como huellas hash (sin texto plano) con sesion firmada por UserId, bloqueo por
      intentos y revalidacion al arrancar, pantalla de carga nueva a pantalla completa y responsive
    - V8: Anti Noise (modo silencio), Anti Glitch (Rooms/Backdoor), Anti Lookman con auto
      apartado de camara, Seek God Mode (Godmode automatico en persecuciones de Seek),
      alertas de Glitch y Screech, Candy Vault+ (Auto Calderos, contador de dulces, TP a la
      candy mas cercana), Stairwell+ (Stairwell Guard, ESP Camino), registro de entidades con
      hora/piso/sala, HUD de entidades activas, zoom de camara libre, cache de traducciones
      (tr mas rapido) y Auto Godmode ampliado (Glitch y Lookman).
    - V8 (Roshan): Anti Noise/Hijack (eliminar), Anti Socker, Anti Haste + Auto palanca de tiempo (Backdoor),
      Anti Vacuum + rescate del vacio, Auto Scrap / Candy / Gold por cercania, Auto Puertas (speedrun),
      HUD FPS/Ping/Sala + cuenta atras Candy Vault, diagnosticos (entidades/remotes y Auto Godmode),
      Auto Godmode arreglado (ya no exige Y > -4: no detectaba en pisos profundos), Bypass Seek Wall reescrito,
      Auto A-1000 actualizado y ventana de la Key con boton Pegar + cuenta atras.
]]

-- Compatibilidad: si el ejecutor no trae alguna función, usamos un reemplazo seguro
local getgenv = getgenv or function() return _G end
local setclipboard = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
local fireproximityprompt = fireproximityprompt or function(prompt)
    pcall(function()
        prompt:InputHoldBegin()
        task.wait((prompt.HoldDuration or 0) + 0.05)
        prompt:InputHoldEnd()
    end)
end

if getgenv().RoshanHubLoaded then
    warn("ROSHAN'S PREMIUM HUB ya está ejecutándose.")
    return
end
getgenv().RoshanHubLoaded = true

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local CONFIG = {
    Name = "ROSHAN'S PREMIUM HUB V8",
    Accent = Color3.fromRGB(170, 70, 255),
    SaveFile = "RoshanHub_Key.txt",
    MemberFile = "RoshanHub_Member.txt",
    UsesFile = "RoshanHub_Uses.txt",
    LangFile = "RoshanHub_Lang.txt",
    Discord = "https://discord.gg/V9xwwk6fuT",
    DiscordUser = "roshan_dvvss", -- DM para VIP Key / Boost

    -- Mis Apps (redes del creador): { texto, usuario, link, color }
    Socials = {
        { "📸 Instagram", "roshan_.sv", "https://www.instagram.com/roshan_.sv", Color3.fromRGB(193, 53, 132) },
        { "🎵 TikTok", "@roshandvss", "https://www.tiktok.com/@roshandvss", Color3.fromRGB(37, 37, 48) },
        { "▶️ YouTube", "@ROSHAN_DVSS", "https://www.youtube.com/@ROSHAN_DVSS", Color3.fromRGB(190, 30, 40) },
    },

    -- Validación EN SERVIDOR (opcional, la única protección real contra quien edite el script).
    -- Pon la URL https de tu endpoint: se le envía ?h=<huella>&u=<UserId>&j=<JobId> y debe responder
    -- JSON {"valid":true}. Si responde false, el hub se apaga. Vacío = desactivado.
    -- KeyServerStrict = true: si el servidor no responde, también se apaga (por defecto se deja pasar).
    KeyServer = "",
    KeyServerStrict = false,

    -- Estadísticas globales (opcional). Pon aquí la URL de tu Firebase Realtime Database,
    -- ej: "https://tu-proyecto-default-rtdb.firebaseio.com"  (vacío = desactivado, sin red).
    -- Solo se envía un ID anónimo aleatorio (nada de usuario, ID de Roblox ni ejecutor).
    StatsDB = "",
    AnonFile = "RoshanHub_AnonId.txt",

    -- (V7) Las keys ya no viven aquí: ver KeyGuard (solo huellas hash).

    DevsByName = {
        ["theander324"]         = "Owner",
        ["kya23712"]            = "Co-Owner",
        ["thiax_8x"]            = "Dev",
        ["gracebutbad_creator"] = "Tester",
        ["luky_duki0"]          = "Owner Sister",
    },
    DevsById = {
        [4848254000] = "Owner",
    },
    -- Miembros Premium (nombre de usuario en minúsculas): rango Premium + zona VIP, sin herramientas Dev
    PremiumByName = {
        ["elorionyt"] = true,
    },
    -- Insignia "Verified" en Créditos: solo aparece cuando el owner abre el hub
    VerifiedById = { [4848254000] = true },
    VerifiedByName = { ["theander324"] = true },
    DevList = {
        { "Theander324", "Owner" },
        { "Kya23712", "Co-Owner" },
        { "thiax_8x", "Dev" },
        { "gracebutbad_creator", "Tester" },
        { "Luky_duki0", "Owner Sister" },
        { "elOrioNYT", "Collaborator • Premium" },
    },

    Sounds = {
        danger = "rbxassetid://5034170",
        warn   = "rbxassetid://4590662766",
        info   = "rbxassetid://6895079853",
        ok     = "rbxassetid://4590657391",
    },
}

----------------------------------------------------------------------
-- IDIOMAS (la base es español; solo se traduce lo que cambia)
----------------------------------------------------------------------
local LANGS = { "es", "en", "pt" }
local LANG_NAMES = { es = "Español", en = "English", pt = "Português" }
local Lang = "es"
pcall(function()
    if isfile and readfile and isfile(CONFIG.LangFile) then
        local l = readfile(CONFIG.LangFile)
        if LANG_NAMES[l] then Lang = l end
    end
end)

local TR = {
    en = {
        ["Ingresa tu key para continuar"] = "Enter your key to continue",
        ["🔑  Escribe tu key aquí..."] = "🔑  Type your key here...",
        ["✔  VERIFICAR KEY"] = "✔  VERIFY KEY",
        ["🔗  GET KEY (copiar Discord)"] = "🔗  GET KEY (copy Discord)",
        ["V7  •  Entra al Discord para conseguir tu key"] = "V7  •  Join the Discord to get your key",
        ["✅ Link copiado, pégalo en tu navegador"] = "✅ Link copied, paste it in your browser",
        ["✅ Key correcta, cargando..."] = "✅ Valid key, loading...",
        ["❌ Key inválida"] = "❌ Invalid key",

        ["Principal"] = "Main", ["Pisos"] = "Floors",
        ["🔍 Buscar función..."] = "🔍 Search feature...",
        ["Interacción"] = "Interaction", ["Movimiento"] = "Movement",
        ["Anti-Entidades"] = "Anti-Entities", ["Supervivencia"] = "Survival",
        ["Alertas"] = "Alerts", ["Pantalla"] = "Display", ["Efectos"] = "Effects",
        ["Sonido"] = "Sound", ["Sistema"] = "System", ["Idioma"] = "Language",
        ["Tema"] = "Theme", ["Zona VIP"] = "VIP Zone", ["Herramientas Dev"] = "Dev Tools",

        ["📍 TP a la puerta (riesgo anticheat)"] = "📍 TP to door (anticheat risk)",
        ["Anti Entidades (Spoof Crouch)"] = "Anti Entities (Spoof Crouch)",
        ["Anti Dupe (puertas falsas)"] = "Anti Dupe (fake doors)",
        ["Anti Obstáculos (Seek/Chandelier)"] = "Anti Obstacles (Seek/Chandelier)",
        ["Objetivos (llaves, fusibles...)"] = "Objectives (keys, fuses...)",
        ["Entidades"] = "Entities", ["Escondites"] = "Hiding spots",
        ["Cofres"] = "Chests", ["Jugadores"] = "Players",
        ["Notificar entidades + sonido"] = "Entity alerts + sound",
        ["Flash de pantalla en peligro"] = "Danger screen flash",
        ["Brillo Fullbright"] = "Fullbright level",
        ["Anticheat Bypass (escaleras)"] = "Anticheat Bypass (ladders)",

        ["Radar de entidades"] = "Entity radar",
        ["📡 Volcar entidades activas"] = "📡 Dump active entities",
        ["🗂 Listar workspace (consola)"] = "🗂 List workspace (console)",
        ["📋 Copiar info del servidor"] = "📋 Copy server info",
        ["🔔 Probar todas las alertas"] = "🔔 Test all alerts",

        ["📍 Piso: %s"] = "📍 Floor: %s",
        ["👤 Tú: %s"] = "👤 You: %s",
        ["⚡ FPS: %d  |  Ping: %s"] = "⚡ FPS: %d  |  Ping: %s",
        ["— Equipo —"] = "— Team —",

        ["Hotel: activa AntiSpeed Bypass antes de usar Speed."] = "Hotel: enable AntiSpeed Bypass before using Speed.",
        ["Mines: Anti Giggle y el ESP de entidades cubren a Giggle y Grumble."] = "Mines: Anti Giggle and Entity ESP cover Giggle and Grumble.",
        ["Outdoors: avisamos de Bramble, Caws, Eyestalk, Grampy, Groundskeeper, Mandrake, Monument, Surge y World Lotus. Anti Snare funciona aquí."] = "Outdoors: alerts for Bramble, Caws, Eyestalk, Grampy, Groundskeeper, Mandrake, Monument, Surge and World Lotus. Anti Snare works here.",
        ["Backdoor: alertas de Haste, Blitz y Lookman. Anti Eyes cubre a Lookman."] = "Backdoor: alerts for Haste, Blitz and Lookman. Anti Eyes covers Lookman.",
        ["Archives: Ransom = quédate quieto. Scribbles = escóndete en un closet. Bash = esquívalo."] = "Archives: Ransom = stand still. Scribbles = hide in a closet. Bash = dodge it.",
        ["Daily Run: las entidades vienen de cualquier piso, deja las alertas activadas."] = "Daily Run: entities come from any floor, keep alerts on.",
        ["⏳ Reset Daily Run (~20:00 UTC) en %s"] = "⏳ Daily Run reset (~20:00 UTC) in %s",

        ["Sonidos"] = "Sounds", ["Volumen"] = "Volume",
        ["🔔 Probar notificación"] = "🔔 Test notification",
        ["Destruir script"] = "Destroy script",
        ["Toca R (botón flotante) para abrir/cerrar. En PC: RightShift."] = "Tap R (floating button) to open/close. On PC: RightShift.",
        ["Morado"] = "Purple", ["Rojo"] = "Red", ["Azul"] = "Blue",
        ["Verde"] = "Green", ["Dorado"] = "Gold", ["Rosa"] = "Pink",

        ["📡 %s · %d studs"] = "📡 %s · %d studs",
        ["⭐ Bienvenido %s %s"] = "⭐ Welcome %s %s",
        ["✅ %s cargado"] = "✅ %s loaded",
        ["⭐ %s %s entró al servidor"] = "⭐ %s %s joined the server",
        ["❌ No se encontró CollisionPart"] = "❌ CollisionPart not found",
        ["⚠️ Activa AntiSpeed Bypass primero"] = "⚠️ Enable AntiSpeed Bypass first",
        ["⚠️ [Bypass] Espera 2s y no te muevas"] = "⚠️ [Bypass] Wait 2s and don't move",
        ["📍 Teletransportado a la puerta %d"] = "📍 Teleported to door %d",
        ["❌ No se encontró la puerta"] = "❌ Door not found",
        ["✅ Ajustes reseteados"] = "✅ Settings reset",
        ["🔔 Prueba de sonido y alerta"] = "🔔 Sound and alert test",
        ["📋 Info copiada al portapapeles"] = "📋 Info copied to clipboard",
        ["🌐 Idioma: %s"] = "🌐 Language: %s",
        ["🎨 Tema: %s"] = "🎨 Theme: %s",
        ["🔒 Tema exclusivo VIP"] = "🔒 VIP-only theme",

        ["✅ Rush ya pasó"] = "✅ Rush has passed",
        ["✅ Ambush se fue (puede volver)"] = "✅ Ambush left (it may return)",
        ["✅ Eyes desapareció"] = "✅ Eyes disappeared",
        ["✅ Seek terminó"] = "✅ Seek chase ended",
        ["⚠️ ¡RUSH viene! Escóndete YA"] = "⚠️ RUSH is coming! Hide NOW",
        ["⚠️ ¡AMBUSH! Volverá varias veces"] = "⚠️ AMBUSH! It will come back several times",
        ["👁️ ¡EYES! No lo mires"] = "👁️ EYES! Don't look at it",
        ["🔵 HALT: date la vuelta cuando aparezca"] = "🔵 HALT: turn around when it appears",
        ["⚫ ¡SEEK! Corre y esquiva"] = "⚫ SEEK! Run and dodge",
        ["👹 FIGURE en la sala: muévete en silencio"] = "👹 FIGURE in the room: move quietly",
        ["😈 GIGGLE cerca"] = "😈 GIGGLE nearby",
        ["👾 GRUMBLE: aléjate de la reina"] = "👾 GRUMBLE: stay away from the queen",
        ["📎 HONCHO (jefe de Archives) apareció"] = "📎 HONCHO (Archives boss) appeared",
        ["🛸 DRONE cerca: cuida cómo te mueves"] = "🛸 DRONE nearby: watch how you move",
        ["🎫 TELLER: atiende su pedido"] = "🎫 TELLER: handle its request",
        ["🕯 ALMA detectada"] = "🕯 ALMA detected",
        ["🔊 NOISE: no hagas ruido"] = "🔊 NOISE: stay quiet",
        ["🪵 CREAK cerca"] = "🪵 CREAK nearby",
        ["🌱 STEM apareció"] = "🌱 STEM appeared",
        ["🖼 PORTRAIT: no copies sus movimientos"] = "🖼 PORTRAIT: don't copy its movements",
        ["🐟 FIH apareció"] = "🐟 FIH appeared",
        ["🌸 FORGET-ME-NOT apareció"] = "🌸 FORGET-ME-NOT appeared",
        ["💥 BASH viene (antes A-60)"] = "💥 BASH incoming (was A-60)",
        ["💣 RANSOM: QUÉDATE QUIETO, no te muevas"] = "💣 RANSOM: STAND STILL, don't move",
        ["✏️ SCRIBBLES: escóndete en un closet"] = "✏️ SCRIBBLES: hide in a closet",
        ["🌿 BRAMBLE cerca"] = "🌿 BRAMBLE nearby",
        ["🐦 CAWS cerca"] = "🐦 CAWS nearby",
        ["👁 EYESTALK: no lo mires"] = "👁 EYESTALK: don't look at it",
        ["🧓 GRAMPY apareció"] = "🧓 GRAMPY appeared",
        ["🧑‍🌾 GROUNDSKEEPER: cuidado con los cobertizos"] = "🧑‍🌾 GROUNDSKEEPER: watch the sheds",
        ["🌱 MANDRAKE cerca"] = "🌱 MANDRAKE nearby",
        ["🗿 MONUMENT apareció"] = "🗿 MONUMENT appeared",
        ["⚡ SURGE cerca"] = "⚡ SURGE nearby",
        ["🪷 WORLD LOTUS apareció"] = "🪷 WORLD LOTUS appeared",
        ["⏱ HASTE: ¡corre, el tiempo corre!"] = "⏱ HASTE: run, time is ticking!",
        ["⚡ BLITZ apareció"] = "⚡ BLITZ appeared",
        ["👀 LOOKMAN: no lo mires"] = "👀 LOOKMAN: don't look at it",
        ["🕷 TIMOTHY: cuidado con los cajones"] = "🕷 TIMOTHY: careful with the drawers",
        ["🦇 GLOOMBAT cerca"] = "🦇 GLOOMBAT nearby",
    },
    pt = {
        ["Ingresa tu key para continuar"] = "Digite sua key para continuar",
        ["🔑  Escribe tu key aquí..."] = "🔑  Digite sua key aqui...",
        ["✔  VERIFICAR KEY"] = "✔  VERIFICAR KEY",
        ["🔗  GET KEY (copiar Discord)"] = "🔗  GET KEY (copiar Discord)",
        ["V7  •  Entra al Discord para conseguir tu key"] = "V7  •  Entre no Discord para pegar sua key",
        ["✅ Link copiado, pégalo en tu navegador"] = "✅ Link copiado, cole no seu navegador",
        ["✅ Key correcta, cargando..."] = "✅ Key correta, carregando...",
        ["❌ Key inválida"] = "❌ Key inválida",

        ["Principal"] = "Principal", ["Pisos"] = "Andares",
        ["🔍 Buscar función..."] = "🔍 Buscar função...",
        ["Interacción"] = "Interação", ["Movimiento"] = "Movimento",
        ["Anti-Entidades"] = "Anti-Entidades", ["Supervivencia"] = "Sobrevivência",
        ["Alertas"] = "Alertas", ["Pantalla"] = "Tela", ["Efectos"] = "Efeitos",
        ["Sonido"] = "Som", ["Sistema"] = "Sistema", ["Idioma"] = "Idioma",
        ["Tema"] = "Tema", ["Zona VIP"] = "Zona VIP", ["Herramientas Dev"] = "Ferramentas Dev",

        ["📍 TP a la puerta (riesgo anticheat)"] = "📍 TP para a porta (risco anticheat)",
        ["Anti Entidades (Spoof Crouch)"] = "Anti Entidades (Spoof Crouch)",
        ["Anti Dupe (puertas falsas)"] = "Anti Dupe (portas falsas)",
        ["Anti Obstáculos (Seek/Chandelier)"] = "Anti Obstáculos (Seek/Chandelier)",
        ["Objetivos (llaves, fusibles...)"] = "Objetivos (chaves, fusíveis...)",
        ["Entidades"] = "Entidades", ["Escondites"] = "Esconderijos",
        ["Cofres"] = "Baús", ["Jugadores"] = "Jogadores",
        ["Notificar entidades + sonido"] = "Alertas de entidades + som",
        ["Flash de pantalla en peligro"] = "Flash de tela em perigo",
        ["Brillo Fullbright"] = "Brilho do Fullbright",
        ["Anticheat Bypass (escaleras)"] = "Anticheat Bypass (escadas)",

        ["Radar de entidades"] = "Radar de entidades",
        ["📡 Volcar entidades activas"] = "📡 Listar entidades ativas",
        ["🗂 Listar workspace (consola)"] = "🗂 Listar workspace (console)",
        ["📋 Copiar info del servidor"] = "📋 Copiar info do servidor",
        ["🔔 Probar todas las alertas"] = "🔔 Testar todos os alertas",

        ["📍 Piso: %s"] = "📍 Andar: %s",
        ["👤 Tú: %s"] = "👤 Você: %s",
        ["⚡ FPS: %d  |  Ping: %s"] = "⚡ FPS: %d  |  Ping: %s",
        ["— Equipo —"] = "— Equipe —",

        ["Hotel: activa AntiSpeed Bypass antes de usar Speed."] = "Hotel: ative o AntiSpeed Bypass antes de usar o Speed.",
        ["Mines: Anti Giggle y el ESP de entidades cubren a Giggle y Grumble."] = "Mines: Anti Giggle e o ESP de entidades cobrem Giggle e Grumble.",
        ["Outdoors: avisamos de Bramble, Caws, Eyestalk, Grampy, Groundskeeper, Mandrake, Monument, Surge y World Lotus. Anti Snare funciona aquí."] = "Outdoors: avisamos sobre Bramble, Caws, Eyestalk, Grampy, Groundskeeper, Mandrake, Monument, Surge e World Lotus. Anti Snare funciona aqui.",
        ["Backdoor: alertas de Haste, Blitz y Lookman. Anti Eyes cubre a Lookman."] = "Backdoor: alertas de Haste, Blitz e Lookman. Anti Eyes cobre o Lookman.",
        ["Archives: Ransom = quédate quieto. Scribbles = escóndete en un closet. Bash = esquívalo."] = "Archives: Ransom = fique parado. Scribbles = esconda-se num armário. Bash = desvie.",
        ["Daily Run: las entidades vienen de cualquier piso, deja las alertas activadas."] = "Daily Run: as entidades vêm de qualquer andar, mantenha os alertas ligados.",
        ["⏳ Reset Daily Run (~20:00 UTC) en %s"] = "⏳ Reset da Daily Run (~20:00 UTC) em %s",

        ["Sonidos"] = "Sons", ["Volumen"] = "Volume",
        ["🔔 Probar notificación"] = "🔔 Testar notificação",
        ["Destruir script"] = "Destruir script",
        ["Toca R (botón flotante) para abrir/cerrar. En PC: RightShift."] = "Toque em R (botão flutuante) para abrir/fechar. No PC: RightShift.",
        ["Morado"] = "Roxo", ["Rojo"] = "Vermelho", ["Azul"] = "Azul",
        ["Verde"] = "Verde", ["Dorado"] = "Dourado", ["Rosa"] = "Rosa",

        ["📡 %s · %d studs"] = "📡 %s · %d studs",
        ["⭐ Bienvenido %s %s"] = "⭐ Bem-vindo %s %s",
        ["✅ %s cargado"] = "✅ %s carregado",
        ["⭐ %s %s entró al servidor"] = "⭐ %s %s entrou no servidor",
        ["❌ No se encontró CollisionPart"] = "❌ CollisionPart não encontrado",
        ["⚠️ Activa AntiSpeed Bypass primero"] = "⚠️ Ative o AntiSpeed Bypass primeiro",
        ["⚠️ [Bypass] Espera 2s y no te muevas"] = "⚠️ [Bypass] Espere 2s e não se mova",
        ["📍 Teletransportado a la puerta %d"] = "📍 Teleportado para a porta %d",
        ["❌ No se encontró la puerta"] = "❌ Porta não encontrada",
        ["✅ Ajustes reseteados"] = "✅ Configurações resetadas",
        ["🔔 Prueba de sonido y alerta"] = "🔔 Teste de som e alerta",
        ["📋 Info copiada al portapapeles"] = "📋 Info copiada para a área de transferência",
        ["🌐 Idioma: %s"] = "🌐 Idioma: %s",
        ["🎨 Tema: %s"] = "🎨 Tema: %s",
        ["🔒 Tema exclusivo VIP"] = "🔒 Tema exclusivo VIP",

        ["✅ Rush ya pasó"] = "✅ Rush já passou",
        ["✅ Ambush se fue (puede volver)"] = "✅ Ambush foi embora (pode voltar)",
        ["✅ Eyes desapareció"] = "✅ Eyes desapareceu",
        ["✅ Seek terminó"] = "✅ Seek terminou",
        ["⚠️ ¡RUSH viene! Escóndete YA"] = "⚠️ RUSH vem aí! Esconda-se JÁ",
        ["⚠️ ¡AMBUSH! Volverá varias veces"] = "⚠️ AMBUSH! Vai voltar várias vezes",
        ["👁️ ¡EYES! No lo mires"] = "👁️ EYES! Não olhe",
        ["🔵 HALT: date la vuelta cuando aparezca"] = "🔵 HALT: vire-se quando aparecer",
        ["⚫ ¡SEEK! Corre y esquiva"] = "⚫ SEEK! Corra e desvie",
        ["👹 FIGURE en la sala: muévete en silencio"] = "👹 FIGURE na sala: mova-se em silêncio",
        ["😈 GIGGLE cerca"] = "😈 GIGGLE por perto",
        ["👾 GRUMBLE: aléjate de la reina"] = "👾 GRUMBLE: fique longe da rainha",
        ["📎 HONCHO (jefe de Archives) apareció"] = "📎 HONCHO (chefe de Archives) apareceu",
        ["🛸 DRONE cerca: cuida cómo te mueves"] = "🛸 DRONE por perto: cuidado como se move",
        ["🎫 TELLER: atiende su pedido"] = "🎫 TELLER: atenda o pedido",
        ["🕯 ALMA detectada"] = "🕯 ALMA detectada",
        ["🔊 NOISE: no hagas ruido"] = "🔊 NOISE: não faça barulho",
        ["🪵 CREAK cerca"] = "🪵 CREAK por perto",
        ["🌱 STEM apareció"] = "🌱 STEM apareceu",
        ["🖼 PORTRAIT: no copies sus movimientos"] = "🖼 PORTRAIT: não copie os movimentos",
        ["🐟 FIH apareció"] = "🐟 FIH apareceu",
        ["🌸 FORGET-ME-NOT apareció"] = "🌸 FORGET-ME-NOT apareceu",
        ["💥 BASH viene (antes A-60)"] = "💥 BASH vem aí (antes A-60)",
        ["💣 RANSOM: QUÉDATE QUIETO, no te muevas"] = "💣 RANSOM: FIQUE PARADO, não se mova",
        ["✏️ SCRIBBLES: escóndete en un closet"] = "✏️ SCRIBBLES: esconda-se num armário",
        ["🌿 BRAMBLE cerca"] = "🌿 BRAMBLE por perto",
        ["🐦 CAWS cerca"] = "🐦 CAWS por perto",
        ["👁 EYESTALK: no lo mires"] = "👁 EYESTALK: não olhe",
        ["🧓 GRAMPY apareció"] = "🧓 GRAMPY apareceu",
        ["🧑‍🌾 GROUNDSKEEPER: cuidado con los cobertizos"] = "🧑‍🌾 GROUNDSKEEPER: cuidado com os galpões",
        ["🌱 MANDRAKE cerca"] = "🌱 MANDRAKE por perto",
        ["🗿 MONUMENT apareció"] = "🗿 MONUMENT apareceu",
        ["⚡ SURGE cerca"] = "⚡ SURGE por perto",
        ["🪷 WORLD LOTUS apareció"] = "🪷 WORLD LOTUS apareceu",
        ["⏱ HASTE: ¡corre, el tiempo corre!"] = "⏱ HASTE: corra, o tempo está passando!",
        ["⚡ BLITZ apareció"] = "⚡ BLITZ apareceu",
        ["👀 LOOKMAN: no lo mires"] = "👀 LOOKMAN: não olhe",
        ["🕷 TIMOTHY: cuidado con los cajones"] = "🕷 TIMOTHY: cuidado com as gavetas",
        ["🦇 GLOOMBAT cerca"] = "🦇 GLOOMBAT por perto",
    },
}

-- Textos nuevos V5 (se fusionan con las tablas de arriba)
local TR_V5 = {
    en = {
        ["Perfil"] = "Profile", ["Mines"] = "Mines", ["Stairwell"] = "Stairwell",
        ["💡 Consejo: activa AntiSpeed Bypass antes de usar Speed."] = "💡 Tip: enable AntiSpeed Bypass before using Speed.",
        ["💡 Consejo: en Mines usa Bridge Saver durante la persecución de Seek."] = "💡 Tip: in Mines use Bridge Saver during the Seek chase.",
        ["💡 Consejo: en Archives, Ransom = quédate quieto."] = "💡 Tip: in Archives, Ransom = stand still.",
        ["💡 Consejo: toca R (botón flotante) para abrir el menú."] = "💡 Tip: tap R (floating button) to open the menu.",
        ["Iniciando módulos..."] = "Starting modules...", ["Cargando ESP por eventos..."] = "Loading event-based ESP...",
        ["Preparando filtros Anti..."] = "Preparing Anti filters...", ["Sincronizando idioma..."] = "Syncing language...",
        ["Construyendo interfaz..."] = "Building interface...", ["¡Listo!"] = "Ready!",
        ["Botón de Saltar"] = "Jump Button", ["Altura de salto"] = "Jump Height",
        ["Bridge Saver (puentes de Seek)"] = "Bridge Saver (Seek bridges)",
        ["Plataforma segura (anti caída)"] = "Safe Platform (anti fall)",
        ["Anti Void (rescate)"] = "Anti Void (rescue)", ["Anti Timothy"] = "Anti Timothy",
        ["Anti Bash (A-60)"] = "Anti Bash (A-60)", ["Anti Scribbles (A-120)"] = "Anti Scribbles (A-120)",
        ["Anti Gloombat"] = "Anti Gloombat", ["Anti Lag (limpiar efectos)"] = "Anti Lag (clean effects)",
        ["ESP Escaleras"] = "Ladder ESP",        ["🌉 Puente roto: bloque verde creado"] = "🌉 Bridge broke: green block created",
        ["Mines: Bridge Saver crea un bloque verde donde se rompe un puente en la persecución de Seek. La plataforma segura te sigue por debajo si caes."] = "Mines: Bridge Saver creates a green block where a bridge breaks during the Seek chase. Safe Platform follows under you if you fall.",
        ["Stairwell (nueva subfloor, se entra desde Mines): usa Debug para ver nombres internos de sus entidades."] = "Stairwell (new subfloor, entered from Mines): use Debug to see internal names of its entities.",
        ["Archives: Discoloration y Currents también viven aquí; Fih se alimenta con Fih Food."] = "Archives: Discoloration and Currents also live here; feed Fih with Fih Food.",
        ["Rol"] = "Rank", ["Nombre"] = "Name", ["Usuario"] = "Username", ["ID"] = "ID",
        ["Cuenta"] = "Account", ["Sesión"] = "Session", ["Dispositivo"] = "Device", ["Ejecutor"] = "Executor",
        ["Móvil"] = "Mobile", ["Tu perfil"] = "Your profile", ["días"] = "days",
        ["🌈 DISCOLORATION cerca"] = "🌈 DISCOLORATION nearby", ["🌊 CURRENTS: cuidado con la corriente"] = "🌊 CURRENTS: watch the current",
        ["Guest: primera vez en el hub. Vuelve y serás Member."] = "Guest: first time in the hub. Come back and you'll be Member.",
        ["Member: gracias por volver al hub."] = "Member: thanks for coming back to the hub.",
        ["Booster: gracias por apoyar el Discord."] = "Booster: thanks for supporting the Discord.",
        ["VIP: acceso a la zona VIP."] = "VIP: access to the VIP zone.",
        ["Staff: equipo del hub."] = "Staff: hub team.",
    },
    pt = {
        ["Perfil"] = "Perfil", ["Mines"] = "Minas", ["Stairwell"] = "Stairwell",
        ["💡 Consejo: activa AntiSpeed Bypass antes de usar Speed."] = "💡 Dica: ative o AntiSpeed Bypass antes de usar o Speed.",
        ["💡 Consejo: en Mines usa Bridge Saver durante la persecución de Seek."] = "💡 Dica: nas Minas use o Bridge Saver na perseguição do Seek.",
        ["💡 Consejo: en Archives, Ransom = quédate quieto."] = "💡 Dica: em Archives, Ransom = fique parado.",
        ["💡 Consejo: toca R (botón flotante) para abrir el menú."] = "💡 Dica: toque em R (botão flutuante) para abrir o menu.",
        ["Iniciando módulos..."] = "Iniciando módulos...", ["Cargando ESP por eventos..."] = "Carregando ESP por eventos...",
        ["Preparando filtros Anti..."] = "Preparando filtros Anti...", ["Sincronizando idioma..."] = "Sincronizando idioma...",
        ["Construyendo interfaz..."] = "Construindo interface...", ["¡Listo!"] = "Pronto!",
        ["Botón de Saltar"] = "Botão de Pular", ["Altura de salto"] = "Altura do pulo",
        ["Bridge Saver (puentes de Seek)"] = "Bridge Saver (pontes do Seek)",
        ["Plataforma segura (anti caída)"] = "Plataforma segura (anti queda)",
        ["Anti Void (rescate)"] = "Anti Void (resgate)", ["Anti Timothy"] = "Anti Timothy",
        ["Anti Bash (A-60)"] = "Anti Bash (A-60)", ["Anti Scribbles (A-120)"] = "Anti Scribbles (A-120)",
        ["Anti Gloombat"] = "Anti Gloombat", ["Anti Lag (limpiar efectos)"] = "Anti Lag (limpar efeitos)",
        ["ESP Escaleras"] = "ESP Escadas",        ["🌉 Puente roto: bloque verde creado"] = "🌉 Ponte quebrou: bloco verde criado",
        ["Mines: Bridge Saver crea un bloque verde donde se rompe un puente en la persecución de Seek. La plataforma segura te sigue por debajo si caes."] = "Minas: o Bridge Saver cria um bloco verde onde a ponte quebra na perseguição do Seek. A plataforma segura te segue por baixo se você cair.",
        ["Stairwell (nueva subfloor, se entra desde Mines): usa Debug para ver nombres internos de sus entidades."] = "Stairwell (nova subfloor, entrada pelas Minas): use o Debug para ver os nomes internos das entidades.",
        ["Archives: Discoloration y Currents también viven aquí; Fih se alimenta con Fih Food."] = "Archives: Discoloration e Currents também vivem aqui; alimente o Fih com Fih Food.",
        ["Rol"] = "Cargo", ["Nombre"] = "Nome", ["Usuario"] = "Usuário", ["ID"] = "ID",
        ["Cuenta"] = "Conta", ["Sesión"] = "Sessão", ["Dispositivo"] = "Dispositivo", ["Ejecutor"] = "Executor",
        ["Móvil"] = "Celular", ["Tu perfil"] = "Seu perfil", ["días"] = "dias",
        ["🌈 DISCOLORATION cerca"] = "🌈 DISCOLORATION por perto", ["🌊 CURRENTS: cuidado con la corriente"] = "🌊 CURRENTS: cuidado com a correnteza",
        ["Guest: primera vez en el hub. Vuelve y serás Member."] = "Guest: primeira vez no hub. Volte e será Member.",
        ["Member: gracias por volver al hub."] = "Member: obrigado por voltar ao hub.",
        ["Booster: gracias por apoyar el Discord."] = "Booster: obrigado por apoiar o Discord.",
        ["VIP: acceso a la zona VIP."] = "VIP: acesso à zona VIP.",
        ["Staff: equipo del hub."] = "Staff: equipe do hub.",
    },
}
for lg, t in pairs(TR_V5) do
    for k, v in pairs(t) do TR[lg][k] = v end
end

-- Textos nuevos V6
local TR_V6 = {
    en = {
        ["Créditos"] = "Credits", ["Equipo del hub"] = "Hub team", ["Conectado"] = "Online", ["Desconectado"] = "Offline",
["📋 Copiar Discord"] = "📋 Copy Discord",
        ["📋 Usuario copiado"] = "📋 Username copied", ["📋 Discord copiado"] = "📋 Discord copied",
        ["Auto Hide (entidades peligrosas)"] = "Auto Hide (dangerous entities)",
        ["Auto Hide (experimental): al venir Rush/Ambush te mete en el escondite más cercano. Sal con el botón de escondite."] = "Auto Hide (experimental): when Rush/Ambush spawn it puts you in the nearest hiding spot. Leave with the hide button.",
        ["🫥 Auto Hide: escondiéndote"] = "🫥 Auto Hide: hiding you",
        ["Figure God Mode (EXPERIMENTAL)"] = "Figure God Mode (EXPERIMENTAL)",
        ["Anti Damage (EXPERIMENTAL)"] = "Anti Damage (EXPERIMENTAL)",
        ["Mines: Anti Damage y Figure God Mode son prototipos; el servidor puede ignorarlos. Usa Debug para ver si funcionan."] = "Mines: Anti Damage and Figure God Mode are prototypes; the server may ignore them. Use Debug to check.",
        ["Escala de UI"] = "UI scale", ["Duración de avisos"] = "Notification time", ["Máx. avisos en pantalla"] = "Max on-screen alerts",
        ["FPS/Ping en pantalla"] = "On-screen FPS/Ping", ["Sin sofás en Auto Interact"] = "Skip couches in Auto Interact",
        ["Mostrar avisos de jugadores staff"] = "Show staff join alerts",
        ["🧹 FPS Booster activado"] = "🧹 FPS Booster enabled", ["🧹 Anti Lag activado"] = "🧹 Anti Lag enabled",
        ["Entidades vistas"] = "Entities seen",["Oro recogido"] = "Gold looted",
        ["Habitación actual"] = "Current room", ["Vida"] = "Health",        ["Jugadores"] = "Players", ["Servidor"] = "Server", ["Estadísticas de sesión"] = "Session stats",
        ["📋 Copiar mi ID"] = "📋 Copy my ID", ["📋 Copiar mi usuario"] = "📋 Copy my username",
        ["Discord del hub"] = "Hub Discord", ["Gracias por usar el hub 💜"] = "Thanks for using the hub 💜",
    },
    pt = {
        ["Créditos"] = "Créditos", ["Equipo del hub"] = "Equipe do hub", ["Conectado"] = "Online", ["Desconectado"] = "Offline",
["📋 Copiar Discord"] = "📋 Copiar Discord",
        ["📋 Usuario copiado"] = "📋 Usuário copiado", ["📋 Discord copiado"] = "📋 Discord copiado",
        ["Auto Hide (entidades peligrosas)"] = "Auto Hide (entidades perigosas)",
        ["Auto Hide (experimental): al venir Rush/Ambush te mete en el escondite más cercano. Sal con el botón de escondite."] = "Auto Hide (experimental): quando Rush/Ambush aparecem, te coloca no esconderijo mais próximo. Saia com o botão de esconderijo.",
        ["🫥 Auto Hide: escondiéndote"] = "🫥 Auto Hide: te escondendo",
        ["Figure God Mode (EXPERIMENTAL)"] = "Figure God Mode (EXPERIMENTAL)",
        ["Anti Damage (EXPERIMENTAL)"] = "Anti Damage (EXPERIMENTAL)",
        ["Mines: Anti Damage y Figure God Mode son prototipos; el servidor puede ignorarlos. Usa Debug para ver si funcionan."] = "Minas: Anti Damage e Figure God Mode são protótipos; o servidor pode ignorá-los. Use o Debug para ver se funcionam.",
        ["Escala de UI"] = "Escala da UI", ["Duración de avisos"] = "Duração dos avisos", ["Máx. avisos en pantalla"] = "Máx. avisos na tela",
        ["FPS/Ping en pantalla"] = "FPS/Ping na tela", ["Sin sofás en Auto Interact"] = "Ignorar sofás no Auto Interact",
        ["Mostrar avisos de jugadores staff"] = "Mostrar avisos de staff",
        ["🧹 FPS Booster activado"] = "🧹 FPS Booster ativado", ["🧹 Anti Lag activado"] = "🧹 Anti Lag ativado",
        ["Entidades vistas"] = "Entidades vistas",["Oro recogido"] = "Ouro coletado",
        ["Habitación actual"] = "Sala atual", ["Vida"] = "Vida",        ["Jugadores"] = "Jogadores", ["Servidor"] = "Servidor", ["Estadísticas de sesión"] = "Estatísticas da sessão",
        ["📋 Copiar mi ID"] = "📋 Copiar meu ID", ["📋 Copiar mi usuario"] = "📋 Copiar meu usuário",
        ["Discord del hub"] = "Discord do hub", ["Gracias por usar el hub 💜"] = "Obrigado por usar o hub 💜",
    },
}
for lg, t in pairs(TR_V6) do
    for k, v in pairs(t) do TR[lg][k] = v end
end

-- Textos nuevos (ventana Boost / contacto)
local TR_V7 = {
    en = {
        ["💎 ¿Quieres VIP Key o Boost? Escríbeme al DM:"] = "💎 Want a VIP Key or Boost? DM me:",
        ["copiar"] = "copy", ["✅ Usuario de Discord copiado"] = "✅ Discord username copied",
        ["Boost"] = "Boost",
        ["🔒 Ventana Boost: exclusiva de Boosters del servidor y staff."] = "🔒 Boost window: server Boosters and staff only.",
        ["🚀 Ventana Boost activa: opciones mejoradas."] = "🚀 Boost window active: improved options.",
        ["Opciones mejoradas"] = "Improved options", ["Auto"] = "Auto",
        ["Speed Pro: actívalo con el toggle Speed de Pisos (necesita AntiSpeed Bypass)."] = "Speed Pro: enable it with the Speed toggle in Floors (needs AntiSpeed Bypass).",
        ["Auto Proxi (mantener R)"] = "Auto Proxi (hold R)",
        ["Auto Proxi: mantén R (PC) para interactuar con todo lo cercano. No toca sofás ni escondites."] = "Auto Proxi: hold R (PC) to interact with everything nearby. Skips couches and hiding spots.",
    },
    pt = {
        ["💎 ¿Quieres VIP Key o Boost? Escríbeme al DM:"] = "💎 Quer uma VIP Key ou Boost? Me chame no DM:",
        ["copiar"] = "copiar", ["✅ Usuario de Discord copiado"] = "✅ Usuário do Discord copiado",
        ["Boost"] = "Boost",
        ["🔒 Ventana Boost: exclusiva de Boosters del servidor y staff."] = "🔒 Janela Boost: exclusiva de Boosters do servidor e staff.",
        ["🚀 Ventana Boost activa: opciones mejoradas."] = "🚀 Janela Boost ativa: opções melhoradas.",
        ["Opciones mejoradas"] = "Opções melhoradas", ["Auto"] = "Auto",
        ["Speed Pro: actívalo con el toggle Speed de Pisos (necesita AntiSpeed Bypass)."] = "Speed Pro: ative com o toggle Speed em Andares (precisa do AntiSpeed Bypass).",
        ["Auto Proxi (mantener R)"] = "Auto Proxi (segurar R)",
        ["Auto Proxi: mantén R (PC) para interactuar con todo lo cercano. No toca sofás ni escondites."] = "Auto Proxi: segure R (PC) para interagir com tudo por perto. Ignora sofás e esconderijos.",
    },
}
for lg, t in pairs(TR_V7) do
    for k, v in pairs(t) do TR[lg][k] = v end
end

local TR_V8 = {
    en = {
        ["Estado"] = "Status", ["Estado del script"] = "Script status", ["Mis Apps"] = "My Apps",
        ["En línea"] = "Online", ["Conectando..."] = "Connecting...",
        ["Sin conexión con el servidor"] = "No connection to the server",
        ["Estadísticas globales sin configurar (CONFIG.StatsDB)"] = "Global stats not configured (CONFIG.StatsDB)",
        ["Usando ahora"] = "Using it now", ["Ejecuciones totales"] = "Total executions",
        ["Usuarios únicos"] = "Unique users", ["Versión"] = "Version",
        ["🔄 Actualizar ahora"] = "🔄 Refresh now",
        ["🔒 Solo se envía un ID anónimo aleatorio (sin usuario ni datos personales)."] = "🔒 Only a random anonymous ID is sent (no username or personal data).",
        ["Hotel+ (Puertas 50 y 100)"] = "Hotel+ (Doors 50 & 100)",
        ["Auto Door 50 (código Biblioteca)"] = "Auto Door 50 (Library code)",
        ["Auto Door 100 (minijuego breakers) BETA"] = "Auto Door 100 (breaker minigame) BETA",
        ["🧪 Copiar diagnóstico Door 50/100"] = "🧪 Copy Door 50/100 diagnostics",
        ["Anti AFK"] = "Anti AFK", ["Alerta de vida baja"] = "Low health alert",
        ["Extras V6"] = "V6 extras", ["HUD de run (puerta y tiempo)"] = "Run HUD (door and time)",
        ["📋 Copiar resumen de sesión"] = "📋 Copy session summary",
        ["🔗 Copiar link del Discord"] = "🔗 Copy Discord link",
        ["Ejecución"] = "Run",
    },
    pt = {
        ["Estado"] = "Status", ["Estado del script"] = "Status do script", ["Mis Apps"] = "Meus Apps",
        ["En línea"] = "Online", ["Conectando..."] = "Conectando...",
        ["Sin conexión con el servidor"] = "Sem conexão com o servidor",
        ["Usando ahora"] = "Usando agora", ["Ejecuciones totales"] = "Execuções totais",
        ["Usuarios únicos"] = "Usuários únicos", ["Versión"] = "Versão",
        ["🔄 Actualizar ahora"] = "🔄 Atualizar agora",
        ["Hotel+ (Puertas 50 y 100)"] = "Hotel+ (Portas 50 e 100)",
        ["Extras V6"] = "Extras V6",
        ["📋 Copiar resumen de sesión"] = "📋 Copiar resumo da sessão",
        ["🔗 Copiar link del Discord"] = "🔗 Copiar link do Discord",
    },
}
for lg, t in pairs(TR_V8) do
    for k, v in pairs(t) do TR[lg][k] = v end
end

local TR_V9 = {
    en = {
        ["Anti Ransom, Anti Drones y Anti Forget-Me-Not están en la pestaña Anti."] = "Anti Ransom, Anti Drones and Anti Forget-Me-Not are in the Anti tab.",
        ["Auto Anti Lag (si bajan los FPS)"] = "Auto Anti Lag (when FPS drop)",
        ["Anti Lag Pro (todo en uno)"] = "Anti Lag Pro (all in one)",
        ["Bypass A-90 (Hotel+ / Stairwell)"] = "A-90 Bypass (Hotel+ / Stairwell)",
        ["Candy Vault: Sir Abe te sigue; míralo para espantarlo. Activa Candy Vault ESP (pestaña Visual) y Auto Interact para recoger candy y usar los calderos."] = "Candy Vault: Sir Abe follows you; look at him to scare him off. Turn on Candy Vault ESP (Visual tab) and Auto Interact to collect candy and use the cauldrons.",
        ["Toca para saltar"] = "Tap to skip",
        ["Door 50: recoge el papel y los libros (Auto Interact ayuda). El código sale solo, se copia y se intenta meter en el candado."] = "Door 50: pick up the paper and the books (Auto Interact helps). The code shows up by itself, gets copied and is entered on the padlock.",
        ["Door 100: lee el código de la caja y pulsa el breaker correcto (BETA)."] = "Door 100: reads the box code and flips the right breaker (BETA).",
        ["🎯 Espía de remotes (activar)"] = "🎯 Remote spy (enable)",
        ["📋 Copiar log del espía"] = "📋 Copy spy log",
        ["🔌 Breaker %s (%s)"] = "🔌 Breaker %s (%s)",
        ["⚠️ Door 100: no pude pulsar el breaker"] = "⚠️ Door 100: I couldn't flip the breaker",
        ["🎯 Espía activo: pulsa un breaker a mano y copia el log"] = "🎯 Spy on: flip a breaker by hand and copy the log",
        ["❌ Tu ejecutor no soporta hookmetamethod"] = "❌ Your executor doesn't support hookmetamethod",
        ["ESP Arcoíris"] = "Rainbow ESP",
        ["Rendimiento y Visual VIP"] = "VIP Performance & Visual",
        ["⚡ FPS muy bajos: FPS Booster activado"] = "⚡ Very low FPS: FPS Booster enabled",
        ["✅ Ransom terminó, ya puedes moverte"] = "✅ Ransom is over, you can move now",
        ["❤️ ¡Vida baja! (%s HP)"] = "❤️ Low health! (%s HP)",
        ["🍬 Candy Vault ESP (caramelos, llaves, calderos)"] = "🍬 Candy Vault ESP (candy, keys, cauldrons)",
        ["⛏ Mines ESP (huevos, vagoneta, estalagmitas)"] = "⛏ Mines ESP (eggs, minecart, stalagmites)",
        ["💎 ZONA VIP & BOOSTER"] = "💎 VIP & BOOSTER ZONE",
        ["💎 ¡Gracias por ser VIP!"] = "💎 Thanks for being VIP!",
        ["💡 Consejo: Anti Ransom te congela solo cuando aparece Ransom."] = "💡 Tip: Anti Ransom freezes you automatically when Ransom shows up.",
        ["💡 Consejo: Auto Anti Lag sube tus FPS solo cuando bajan."] = "💡 Tip: Auto Anti Lag boosts your FPS only when they drop.",
        ["💡 Consejo: Auto Door 50 te da el código de la Biblioteca."] = "💡 Tip: Auto Door 50 gives you the Library code.",
        ["💡 Consejo: en el Candy Vault activa Candy Vault ESP (pestaña Visual)."] = "💡 Tip: in the Candy Vault turn on Candy Vault ESP (Visual tab).",
        ["💡 Consejo: mira la pestaña Estado para ver cuánta gente usa el hub."] = "💡 Tip: check the Status tab to see how many people use the hub.",
        ["💣 Ransom: te congelé, no te muevas"] = "💣 Ransom: I froze you, don't move",
        ["📋 Link copiado: %s"] = "📋 Link copied: %s",
        ["📚 Faltan pistas: recoge más libros"] = "📚 Missing clues: pick up more books",
        ["🔄 Actualizando..."] = "🔄 Refreshing...",
        ["🔓 Código de la Biblioteca: %s"] = "🔓 Library code: %s",
        ["🧪 Copiar diagnóstico Candy Vault"] = "🧪 Copy Candy Vault diagnostics",
        ["🧪 Copiar diagnóstico Ransom"] = "🧪 Copy Ransom diagnostics",
        ["🧹 FPS bajos (%s): Anti Lag activado"] = "🧹 Low FPS (%s): Anti Lag enabled",
        ["🧹 Limpiar memoria de ESP"] = "🧹 Clean ESP memory",
        ["🧹 Limpieza hecha"] = "🧹 Cleanup done",
        ["🧹 Anti Lag Pro activado"] = "🧹 Anti Lag Pro enabled",
        ["🧹 Anti Lag Pro desactivado"] = "🧹 Anti Lag Pro disabled",
        ["🎩 SIR ABE C. II te sigue: mírale para espantarlo"] = "🎩 SIR ABE C. II is following you: look at him to scare him off",
        ["🧦 SOCKER cerca: detecta tus dulces"] = "🧦 SOCKER nearby: it senses your candy",
        ["🥚 Huevo de Gloombat: no lo pises"] = "🥚 Gloombat egg: don't step on it",
        ["😨 DREAD: no te quedes mucho tiempo en la sala"] = "😨 DREAD: don't stay too long in the room",
        ["¡Desbloquea todo el poder del hub y apoya el proyecto!"] = "Unlock the full power of the hub and support the project!",
        ["✨ Rainbow UI y temas exclusivos (Dorado y Rosa)"] = "✨ Rainbow UI and exclusive themes (Gold and Pink)",
        ["📡 Radar de entidades y Auto Hide"] = "📡 Entity radar and Auto Hide",
        ["💰 Auto Loot Gold y FPS Booster"] = "💰 Auto Loot Gold and FPS Booster",
        ["🚀 Boosters del servidor: ventana Boost (Speed, Fly y Reach Pro, Auto Proxi, Anti AFK, vida baja) + zona VIP"] = "🚀 Server Boosters: Boost window (Speed, Fly and Reach Pro, Auto Proxi, Anti AFK, low health) + VIP zone",
        ["⏱ HUD de run, resumen de sesión, Anti Lag Pro y ESP Arcoíris"] = "⏱ Run HUD, session summary, Anti Lag Pro and Rainbow ESP",
        ["Escríbeme por Discord para conseguir tu VIP Key o boostea el servidor 💜"] = "DM me on Discord to get your VIP Key or boost the server 💜",
        ["Tu apoyo mantiene vivo el hub. Disfruta la zona VIP 💜"] = "Your support keeps the hub alive. Enjoy the VIP zone 💜",
        ["📋 Info copiada al portapapeles"] = "📋 Info copied to clipboard",
        ["💎 ¿Tienes VIP o Boost? (activar)"] = "💎 Got VIP or Boost? (activate)",
        ["🔑 Escribe tu key VIP o Boost..."] = "🔑 Type your VIP or Boost key...",
        ["💎 ACTIVAR VIP / BOOST"] = "💎 ACTIVATE VIP / BOOST",
        ["💎 Activar key"] = "💎 Activate key",
        ["🔑 Canjear key VIP / Boost"] = "🔑 Redeem VIP / Boost key",
        ["❌ Esa key no es VIP ni Boost"] = "❌ That key is not VIP or Boost",
        ["✅ ¡Rango activado! Actualizando el hub..."] = "✅ Rank activated! Updating the hub...",
        ["Veteran: más de 10 ejecuciones, gracias por quedarte."] = "Veteran: more than 10 runs, thanks for sticking around.",
        ["Ejecuciones tuyas"] = "Your runs",
        ["Mines (piso 2): Seek corre entre las puertas 140-149 y Grumble espera en la 150. Giggle: no pases debajo. Gloombats: apaga la linterna."] = "Mines (floor 2): Seek chases between doors 140-149 and Grumble waits at 150. Giggle: don't walk under it. Gloombats: turn your flashlight off.",
        ["Auto optimizar en Mines (menos lag)"] = "Auto optimize in Mines (less lag)",
        ["⛏ Mines detectado: Anti Lag activado"] = "⛏ Mines detected: Anti Lag enabled",
        ["🛸 ¡STAMPEDE de Drones! Sal del pasillo central o escóndete"] = "🛸 Drone STAMPEDE! Get out of the middle corridor or hide",
        ["🛸 Drone muy cerca: me aparté"] = "🛸 Drone too close: I moved away",
        ["Anti Ragdoll / Knockdown"] = "Anti Ragdoll / Knockdown",
        ["Candy Vault (Hollow)"] = "Candy Vault (Hollow)",
        ["Debug (consola)"] = "Debug (console)",
        ["Interfaz"] = "Interface",
    },
    pt = {
        ["Anti Ransom, Anti Drones y Anti Forget-Me-Not están en la pestaña Anti."] = "Anti Ransom, Anti Drones e Anti Forget-Me-Not estão na aba Anti.",
        ["Auto Anti Lag (si bajan los FPS)"] = "Auto Anti Lag (quando o FPS cair)",
        ["Anti Lag Pro (todo en uno)"] = "Anti Lag Pro (tudo em um)",
        ["Bypass A-90 (Hotel+ / Stairwell)"] = "Bypass do A-90 (Hotel+ / Stairwell)",
        ["Candy Vault: Sir Abe te sigue; míralo para espantarlo. Activa Candy Vault ESP (pestaña Visual) y Auto Interact para recoger candy y usar los calderos."] = "Candy Vault: Sir Abe te segue; olhe para ele para assustá-lo. Ative o Candy Vault ESP (aba Visual) e o Auto Interact para pegar doces e usar os caldeirões.",
        ["Toca para saltar"] = "Toque para pular",
        ["Door 50: recoge el papel y los libros (Auto Interact ayuda). El código sale solo, se copia y se intenta meter en el candado."] = "Door 50: pegue o papel e os livros (o Auto Interact ajuda). O código aparece sozinho, é copiado e tentamos colocá-lo no cadeado.",
        ["Door 100: lee el código de la caja y pulsa el breaker correcto (BETA)."] = "Door 100: lê o código da caixa e aciona o breaker certo (BETA).",
        ["🎯 Espía de remotes (activar)"] = "🎯 Espião de remotes (ativar)",
        ["📋 Copiar log del espía"] = "📋 Copiar log do espião",
        ["🔌 Breaker %s (%s)"] = "🔌 Breaker %s (%s)",
        ["⚠️ Door 100: no pude pulsar el breaker"] = "⚠️ Door 100: não consegui acionar o breaker",
        ["🎯 Espía activo: pulsa un breaker a mano y copia el log"] = "🎯 Espião ativo: acione um breaker à mão e copie o log",
        ["❌ Tu ejecutor no soporta hookmetamethod"] = "❌ Seu executor não suporta hookmetamethod",
        ["ESP Arcoíris"] = "ESP Arco-íris",
        ["Rendimiento y Visual VIP"] = "Desempenho e Visual VIP",
        ["⚡ FPS muy bajos: FPS Booster activado"] = "⚡ FPS muito baixo: FPS Booster ativado",
        ["✅ Ransom terminó, ya puedes moverte"] = "✅ Ransom acabou, você já pode se mover",
        ["❤️ ¡Vida baja! (%s HP)"] = "❤️ Vida baixa! (%s HP)",
        ["🍬 Candy Vault ESP (caramelos, llaves, calderos)"] = "🍬 Candy Vault ESP (doces, chaves, caldeirões)",
        ["⛏ Mines ESP (huevos, vagoneta, estalagmitas)"] = "⛏ Mines ESP (ovos, vagoneta, estalagmites)",
        ["💎 ZONA VIP & BOOSTER"] = "💎 ZONA VIP & BOOSTER",
        ["💎 ¡Gracias por ser VIP!"] = "💎 Obrigado por ser VIP!",
        ["💡 Consejo: Anti Ransom te congela solo cuando aparece Ransom."] = "💡 Dica: o Anti Ransom te congela sozinho quando o Ransom aparece.",
        ["💡 Consejo: Auto Anti Lag sube tus FPS solo cuando bajan."] = "💡 Dica: o Auto Anti Lag aumenta seu FPS só quando ele cai.",
        ["💡 Consejo: Auto Door 50 te da el código de la Biblioteca."] = "💡 Dica: o Auto Door 50 te dá o código da Biblioteca.",
        ["💡 Consejo: en el Candy Vault activa Candy Vault ESP (pestaña Visual)."] = "💡 Dica: no Candy Vault ative o Candy Vault ESP (aba Visual).",
        ["💡 Consejo: mira la pestaña Estado para ver cuánta gente usa el hub."] = "💡 Dica: veja a aba Status para ver quantas pessoas usam o hub.",
        ["💣 Ransom: te congelé, no te muevas"] = "💣 Ransom: congelei você, não se mova",
        ["📋 Link copiado: %s"] = "📋 Link copiado: %s",
        ["📚 Faltan pistas: recoge más libros"] = "📚 Faltam pistas: pegue mais livros",
        ["🔄 Actualizando..."] = "🔄 Atualizando...",
        ["🔓 Código de la Biblioteca: %s"] = "🔓 Código da Biblioteca: %s",
        ["🧪 Copiar diagnóstico Candy Vault"] = "🧪 Copiar diagnóstico do Candy Vault",
        ["🧪 Copiar diagnóstico Ransom"] = "🧪 Copiar diagnóstico do Ransom",
        ["🧪 Copiar diagnóstico Door 50/100"] = "🧪 Copiar diagnóstico Door 50/100",
        ["🧹 FPS bajos (%s): Anti Lag activado"] = "🧹 FPS baixo (%s): Anti Lag ativado",
        ["🧹 Limpiar memoria de ESP"] = "🧹 Limpar memória do ESP",
        ["🧹 Limpieza hecha"] = "🧹 Limpeza feita",
        ["🧹 Anti Lag Pro activado"] = "🧹 Anti Lag Pro ativado",
        ["🧹 Anti Lag Pro desactivado"] = "🧹 Anti Lag Pro desativado",
        ["🎩 SIR ABE C. II te sigue: mírale para espantarlo"] = "🎩 SIR ABE C. II está te seguindo: olhe para ele para assustá-lo",
        ["🧦 SOCKER cerca: detecta tus dulces"] = "🧦 SOCKER por perto: ele sente seus doces",
        ["🥚 Huevo de Gloombat: no lo pises"] = "🥚 Ovo de Gloombat: não pise nele",
        ["😨 DREAD: no te quedes mucho tiempo en la sala"] = "😨 DREAD: não fique muito tempo na sala",
        ["¡Desbloquea todo el poder del hub y apoya el proyecto!"] = "Desbloqueie todo o poder do hub e apoie o projeto!",
        ["✨ Rainbow UI y temas exclusivos (Dorado y Rosa)"] = "✨ Rainbow UI e temas exclusivos (Dourado e Rosa)",
        ["📡 Radar de entidades y Auto Hide"] = "📡 Radar de entidades e Auto Hide",
        ["💰 Auto Loot Gold y FPS Booster"] = "💰 Auto Loot Gold e FPS Booster",
        ["🚀 Boosters del servidor: ventana Boost (Speed, Fly y Reach Pro, Auto Proxi, Anti AFK, vida baja) + zona VIP"] = "🚀 Boosters do servidor: janela Boost (Speed, Fly e Reach Pro, Auto Proxi, Anti AFK, vida baixa) + zona VIP",
        ["⏱ HUD de run, resumen de sesión, Anti Lag Pro y ESP Arcoíris"] = "⏱ HUD da run, resumo da sessão, Anti Lag Pro e ESP Arco-íris",
        ["Escríbeme por Discord para conseguir tu VIP Key o boostea el servidor 💜"] = "Me chame no Discord para conseguir sua VIP Key ou dê boost no servidor 💜",
        ["Tu apoyo mantiene vivo el hub. Disfruta la zona VIP 💜"] = "Seu apoio mantém o hub vivo. Aproveite a zona VIP 💜",
        ["📋 Info copiada al portapapeles"] = "📋 Info copiada para a área de transferência",
        ["Alerta de vida baja"] = "Alerta de vida baixa",
        ["Anti AFK"] = "Anti AFK",
        ["Auto Door 100 (minijuego breakers) BETA"] = "Auto Door 100 (minijogo dos breakers) BETA",
        ["Auto Door 50 (código Biblioteca)"] = "Auto Door 50 (código da Biblioteca)",
        ["Ejecución"] = "Execução",
        ["Estadísticas globales sin configurar (CONFIG.StatsDB)"] = "Estatísticas globais não configuradas (CONFIG.StatsDB)",
        ["HUD de run (puerta y tiempo)"] = "HUD da run (porta e tempo)",
        ["🔒 Solo se envía un ID anónimo aleatorio (sin usuario ni datos personales)."] = "🔒 Só é enviado um ID anônimo aleatório (sem usuário nem dados pessoais).",
        ["💎 ¿Tienes VIP o Boost? (activar)"] = "💎 Tem VIP ou Boost? (ativar)",
        ["🔑 Escribe tu key VIP o Boost..."] = "🔑 Digite sua key VIP ou Boost...",
        ["💎 ACTIVAR VIP / BOOST"] = "💎 ATIVAR VIP / BOOST",
        ["💎 Activar key"] = "💎 Ativar key",
        ["🔑 Canjear key VIP / Boost"] = "🔑 Resgatar key VIP / Boost",
        ["❌ Esa key no es VIP ni Boost"] = "❌ Essa key não é VIP nem Boost",
        ["✅ ¡Rango activado! Actualizando el hub..."] = "✅ Rank ativado! Atualizando o hub...",
        ["Veteran: más de 10 ejecuciones, gracias por quedarte."] = "Veteran: mais de 10 execuções, obrigado por ficar.",
        ["Ejecuciones tuyas"] = "Suas execuções",
        ["Mines (piso 2): Seek corre entre las puertas 140-149 y Grumble espera en la 150. Giggle: no pases debajo. Gloombats: apaga la linterna."] = "Mines (andar 2): o Seek corre entre as portas 140-149 e o Grumble espera na 150. Giggle: não passe por baixo. Gloombats: apague a lanterna.",
        ["Auto optimizar en Mines (menos lag)"] = "Otimizar automaticamente nas Mines (menos lag)",
        ["⛏ Mines detectado: Anti Lag activado"] = "⛏ Mines detectado: Anti Lag ativado",
        ["🛸 ¡STAMPEDE de Drones! Sal del pasillo central o escóndete"] = "🛸 STAMPEDE de Drones! Saia do corredor central ou se esconda",
        ["🛸 Drone muy cerca: me aparté"] = "🛸 Drone muito perto: me afastei",
        ["Anti Ragdoll / Knockdown"] = "Anti Ragdoll / Knockdown",
        ["Candy Vault (Hollow)"] = "Candy Vault (Hollow)",
        ["Debug (consola)"] = "Debug (console)",
        ["Interfaz"] = "Interface",
    },
}
for lg, t in pairs(TR_V9) do
    for k, v in pairs(t) do TR[lg][k] = v end
end
local TR_V10 = {
    en = {
        ["Potencia de salto"] = "Jump power",
        ["🛡 AntiSpeed activado automáticamente"] = "🛡 AntiSpeed enabled automatically",
        ["Animaciones de la UI (más bonito, más lag)"] = "UI animations (prettier, more lag)",
        ["Supervivencia Boost"] = "Boost survival",
        ["Anti oxígeno (no morir ahogado)"] = "Anti oxygen (don't drown)",
        ["Auto revivir (usa tus revives)"] = "Auto revive (uses your revives)",
        ["🔄 Auto revive: pulsando Revive"] = "🔄 Auto revive: pressing Revive",
        ["⚠️ Auto revive: no vi el botón de Revive"] = "⚠️ Auto revive: I didn't see the Revive button",
        ["Anti oxígeno engaña el aviso de 'bajo el agua' al servidor y mantiene tu oxígeno. Auto revive pulsa el botón de Revive si lo tienes."] = "Anti oxygen spoofs the 'underwater' report to the server and keeps your oxygen up. Auto revive presses the Revive button if you have one.",
        ["Anti Seek (manos y obstáculos)"] = "Anti Seek (hands and obstacles)",
        ["Anti Grumble (Mines)"] = "Anti Grumble (Mines)",
        ["Anti Electricidad (Currents)"] = "Anti Electricity (Currents)",
        ["Rush, Ambush y Figure matan desde el servidor: no existe un bypass seguro del lado del cliente. Usa alertas, ESP de escondites y escóndete a tiempo."] = "Rush, Ambush and Figure kill from the server: there is no safe client-side bypass. Use the alerts, hiding-spot ESP and hide in time.",
        ["Auto recoger items cercanos"] = "Auto pick up nearby items",
        ["Aura de color"] = "Color aura",
        ["Archives (sectores)"] = "Archives (sectors)",
        ["📚 Sector %s • sala %d/50 • faltan %d para el siguiente"] = "📚 Sector %s • room %d/50 • %d left to the next one",
        ["📚 Solo disponible dentro de The Archives"] = "📚 Only available inside The Archives",
        ["Archives: Currents (puddles con electricidad) → activa Anti Electricidad en Anti. Drones → Anti Drones. Ransom → Anti Ransom."] = "Archives: Currents (electric puddles) → enable Anti Electricity in Anti. Drones → Anti Drones. Ransom → Anti Ransom.",
        ["⚠️ %s: no encontrado en esta versión del juego"] = "⚠️ %s: not found in this game version",
        ["Anti Rush/Ambush son experimentales y pueden no responder en todas las versiones del juego."] = "Anti Rush/Ambush are experimental and may not respond on every game version.",
    },
    pt = {
        ["Potencia de salto"] = "Potência de pulo",
        ["🛡 AntiSpeed activado automáticamente"] = "🛡 AntiSpeed ativado automaticamente",
        ["Animaciones de la UI (más bonito, más lag)"] = "Animações da UI (mais bonito, mais lag)",
        ["Supervivencia Boost"] = "Sobrevivência Boost",
        ["Anti oxígeno (no morir ahogado)"] = "Anti oxigênio (não se afogar)",
        ["Auto revivir (usa tus revives)"] = "Auto reviver (usa seus revives)",
        ["🔄 Auto revive: pulsando Revive"] = "🔄 Auto revive: apertando Revive",
        ["⚠️ Auto revive: no vi el botón de Revive"] = "⚠️ Auto revive: não vi o botão de Revive",
        ["Anti oxígeno engaña el aviso de 'bajo el agua' al servidor y mantiene tu oxígeno. Auto revive pulsa el botón de Revive si lo tienes."] = "Anti oxigênio engana o aviso de 'debaixo d'água' ao servidor e mantém seu oxigênio. Auto reviver aperta o botão de Revive se você tiver.",
        ["Anti Seek (manos y obstáculos)"] = "Anti Seek (mãos e obstáculos)",
        ["Anti Grumble (Mines)"] = "Anti Grumble (Mines)",
        ["Anti Electricidad (Currents)"] = "Anti Eletricidade (Currents)",
        ["Rush, Ambush y Figure matan desde el servidor: no existe un bypass seguro del lado del cliente. Usa alertas, ESP de escondites y escóndete a tiempo."] = "Rush, Ambush e Figure matam pelo servidor: não existe bypass seguro no cliente. Use os alertas, o ESP de esconderijos e se esconda a tempo.",
        ["Auto recoger items cercanos"] = "Auto pegar itens próximos",
        ["Aura de color"] = "Aura de cor",
        ["Archives (sectores)"] = "Archives (setores)",
        ["📚 Sector %s • sala %d/50 • faltan %d para el siguiente"] = "📚 Setor %s • sala %d/50 • faltam %d para o próximo",
        ["📚 Solo disponible dentro de The Archives"] = "📚 Só disponível dentro de The Archives",
        ["Archives: Currents (puddles con electricidad) → activa Anti Electricidad en Anti. Drones → Anti Drones. Ransom → Anti Ransom."] = "Archives: Currents (poças elétricas) → ative Anti Eletricidade em Anti. Drones → Anti Drones. Ransom → Anti Ransom.",
        ["⚠️ %s: no encontrado en esta versión del juego"] = "⚠️ %s: não encontrado nesta versão do jogo",
        ["Anti Rush/Ambush son experimentales y pueden no responder en todas las versiones del juego."] = "Anti Rush/Ambush são experimentais e podem não responder em todas as versões do jogo.",
    },
}
for lg, t in pairs(TR_V10) do
    for k, v in pairs(t) do TR[lg][k] = v end
end
-- Español: nombres que estaban en inglés, ahora en español claro (se deja el término original
-- entre paréntesis para que el buscador siga encontrándolos).
local TR_ES = {
    ["Speed"] = "Velocidad (Speed)",
    ["Speed Pro"] = "Velocidad Pro (Speed Pro)",
    ["Speed Value"] = "Valor de velocidad",
    ["Fly"] = "Volar (Fly)",
    ["Fly Speed"] = "Velocidad de vuelo",
    ["Fly Speed Pro"] = "Velocidad de vuelo Pro",
    ["Noclip"] = "Atravesar paredes (Noclip)",
    ["Infinite Jump"] = "Salto infinito (Infinite Jump)",
    ["No Acceleration"] = "Sin aceleración (No Acceleration)",
    ["Fullbright"] = "Brillo total (Fullbright)",
    ["Instant Prompts"] = "Prompts instantáneos (Instant Prompts)",
    ["Prompt Reach"] = "Alcance de prompts (Prompt Reach)",
    ["Prompt Reach Pro"] = "Alcance de prompts Pro",
    ["Auto Interact"] = "Auto interactuar (Auto Interact)",
    ["Auto Loot Gold"] = "Auto recoger oro (Auto Loot Gold)",
    ["Hide UI"] = "Ocultar interfaz (Hide UI)",
    ["Reset All Settings"] = "Restablecer todos los ajustes",
    ["Daily Run"] = "Run diario (Daily Run)",
    ["Rainbow UI"] = "Interfaz arcoíris (Rainbow UI)",
    ["FPS Booster"] = "Aumentar FPS (FPS Booster)",
    ["AntiSpeed Bypass"] = "Bypass de AntiSpeed",
    ["Items"] = "Objetos (Items)",
    ["Gold"] = "Oro (Gold)",
    ["Doors"] = "Puertas (Doors)",
    ["FOV"] = "Campo de visión (FOV)",
    ["Outdoors"] = "Luz exterior (Outdoors)",
    ["📋 Copy JobId"] = "📋 Copiar JobId",
    ["🔄 Rejoin"] = "🔄 Reconectar (Rejoin)",
}

do
    local TR_V11 = {
        en = {
            ["Movimiento+"] = "Movement+", ["Permitir saltar"] = "Allow jumping", ["Salto infinito"] = "Infinite jump",
            ["Anti AFK"] = "Anti AFK", ["Cámara y efectos"] = "Camera & effects", ["Quitar niebla"] = "Remove fog",
            ["Tercera persona (EXP)"] = "Third person (EXP)", ["3ª persona X"] = "3rd person X",
            ["3ª persona Y"] = "3rd person Y", ["3ª persona Z"] = "3rd person Z",
            ["3ª persona: anti-paredes"] = "3rd person: wall check",
            ["Quitar sacudida de cámara"] = "Remove camera shake", ["Quitar balanceo de cámara"] = "Remove camera bobbing",
            ["Sin jumpscares (Glitch/Void/Timothy)"] = "No jumpscares (Glitch/Void/Timothy)",
            ["Extras V6.1: si algo no responde en tu ejecutor, activa Debug en Config."] = "V6.1 extras: if something does not respond on your executor, enable Debug in Config.",
        },
        pt = {
            ["Movimiento+"] = "Movimento+", ["Permitir saltar"] = "Permitir pular", ["Salto infinito"] = "Pulo infinito",
            ["Anti AFK"] = "Anti AFK", ["Cámara y efectos"] = "Câmera e efeitos", ["Quitar niebla"] = "Remover névoa",
            ["Tercera persona (EXP)"] = "Terceira pessoa (EXP)", ["3ª persona X"] = "3ª pessoa X",
            ["3ª persona Y"] = "3ª pessoa Y", ["3ª persona Z"] = "3ª pessoa Z",
            ["3ª persona: anti-paredes"] = "3ª pessoa: anti-paredes",
            ["Quitar sacudida de cámara"] = "Remover tremor da câmera", ["Quitar balanceo de cámara"] = "Remover balanço da câmera",
            ["Sin jumpscares (Glitch/Void/Timothy)"] = "Sem jumpscares (Glitch/Void/Timothy)",
            ["Extras V6.1: si algo no responde en tu ejecutor, activa Debug en Config."] = "Extras V6.1: se algo não responder no seu executor, ative o Debug em Config.",
        },
    }
    for lg, t in pairs(TR_V11) do
        for k, v in pairs(t) do TR[lg][k] = v end
    end
end

do
    local TR_V63 = {
        en = {
            ["Extras (Rush Hub)"] = "Extras (Rush Hub)",
            ["Door Reach (abrir puertas desde lejos)"] = "Door Reach (open doors from far away)",
            ["Quitar delay del armario"] = "Remove closet delay",
            ["Extras visuales (Rush Hub)"] = "Visual extras (Rush Hub)",
            ["Escondites transparentes"] = "Transparent hiding spots",
            ["Transparencia del escondite"] = "Hiding spot transparency",
            ["Quitar cutscenes"] = "Remove cutscenes",
            ["Audio"] = "Audio",
            ["Quitar sonido de pasos"] = "Remove footstep sounds",
            ["Quitar sonidos de interacción"] = "Remove interaction sounds",
            ["Quitar música Jammin"] = "Remove Jammin music",
            ["Premium: miembro premium del hub."] = "Premium: premium hub member.",
        },
        pt = {
            ["Extras (Rush Hub)"] = "Extras (Rush Hub)",
            ["Door Reach (abrir puertas desde lejos)"] = "Door Reach (abrir portas de longe)",
            ["Quitar delay del armario"] = "Remover atraso do armário",
            ["Extras visuales (Rush Hub)"] = "Extras visuais (Rush Hub)",
            ["Escondites transparentes"] = "Esconderijos transparentes",
            ["Transparencia del escondite"] = "Transparência do esconderijo",
            ["Quitar cutscenes"] = "Remover cutscenes",
            ["Audio"] = "Áudio",
            ["Quitar sonido de pasos"] = "Remover sons de passos",
            ["Quitar sonidos de interacción"] = "Remover sons de interação",
            ["Quitar música Jammin"] = "Remover música Jammin",
            ["Premium: miembro premium del hub."] = "Premium: membro premium do hub.",
        },
    }
    for lg, t in pairs(TR_V63) do
        for k, v in pairs(t) do TR[lg][k] = v end
    end
end

do
    local TR_V64 = {
        en = {
            ["Herramientas de staff"] = "Staff tools",
            ["Jugador objetivo"] = "Target player",
            ["⏭ Siguiente jugador"] = "⏭ Next player",
            ["📍 TP al jugador"] = "📍 TP to player",
            ["👁 Espectar jugador"] = "👁 Spectate player",
            ["📋 Copiar ID del jugador"] = "📋 Copy player ID",
            ["ℹ️ Info del jugador"] = "ℹ️ Player info",
            ["🧭 ESP de jugadores (vida / distancia)"] = "🧭 Player ESP (health / distance)",
            ["🌐 Probar StatsDB (servidor de stats)"] = "🌐 Test StatsDB (stats server)",
            ["⚠️ No hay otros jugadores"] = "⚠️ No other players",
            ["⚠️ Elige un jugador primero"] = "⚠️ Pick a player first",
            ["📋 ID copiado: %s"] = "📋 ID copied: %s",
            ["ℹ️ %s | Vida %s | %s studs | ID %s"] = "ℹ️ %s | Health %s | %s studs | ID %s",
            ["🌐 StatsDB desactivado: pon tu URL en CONFIG.StatsDB"] = "🌐 StatsDB is off: set your URL in CONFIG.StatsDB",
            ["🌐 StatsDB OK (%s ms)"] = "🌐 StatsDB OK (%s ms)",
            ["🌐 StatsDB no responde"] = "🌐 StatsDB is not responding",
            ["Sin objetos cargables en Auto Interact"] = "Skip carryable objects in Auto Interact",
            ["Anti re-sentarse (pausa tras levantarte)"] = "Anti re-sit (pause after standing up)",
            ["Aprender prompts molestos (auto)"] = "Learn annoying prompts (auto)",
            ["🧹 Olvidar prompts ignorados"] = "🧹 Forget ignored prompts",
            ["🧹 Lista de prompts ignorados limpiada"] = "🧹 Ignored prompts list cleared",
            ["🪑 Auto Interact: ignoraré «%s»"] = "🪑 Auto Interact: I will ignore '%s'",
            ["🔌 Door 100: interactúa con la caja, se resuelve sola"] = "🔌 Door 100: interact with the box, it solves itself",
            ["✔ Verified Owner: bienvenido, %s"] = "✔ Verified Owner: welcome, %s",
        },
        pt = {
            ["Herramientas de staff"] = "Ferramentas de staff",
            ["Jugador objetivo"] = "Jogador alvo",
            ["⏭ Siguiente jugador"] = "⏭ Próximo jogador",
            ["📍 TP al jugador"] = "📍 TP até o jogador",
            ["👁 Espectar jugador"] = "👁 Espiar jogador",
            ["📋 Copiar ID del jugador"] = "📋 Copiar ID do jogador",
            ["ℹ️ Info del jugador"] = "ℹ️ Info do jogador",
            ["🧭 ESP de jugadores (vida / distancia)"] = "🧭 ESP de jogadores (vida / distância)",
            ["🌐 Probar StatsDB (servidor de stats)"] = "🌐 Testar StatsDB (servidor de stats)",
            ["⚠️ No hay otros jugadores"] = "⚠️ Não há outros jogadores",
            ["⚠️ Elige un jugador primero"] = "⚠️ Escolha um jogador primeiro",
            ["📋 ID copiado: %s"] = "📋 ID copiado: %s",
            ["ℹ️ %s | Vida %s | %s studs | ID %s"] = "ℹ️ %s | Vida %s | %s studs | ID %s",
            ["🌐 StatsDB desactivado: pon tu URL en CONFIG.StatsDB"] = "🌐 StatsDB desativado: coloque sua URL em CONFIG.StatsDB",
            ["🌐 StatsDB OK (%s ms)"] = "🌐 StatsDB OK (%s ms)",
            ["🌐 StatsDB no responde"] = "🌐 StatsDB não responde",
            ["Sin objetos cargables en Auto Interact"] = "Ignorar objetos carregáveis no Auto Interact",
            ["Anti re-sentarse (pausa tras levantarte)"] = "Anti sentar de novo (pausa ao levantar)",
            ["Aprender prompts molestos (auto)"] = "Aprender prompts chatos (auto)",
            ["🧹 Olvidar prompts ignorados"] = "🧹 Esquecer prompts ignorados",
            ["🧹 Lista de prompts ignorados limpiada"] = "🧹 Lista de prompts ignorados limpa",
            ["🪑 Auto Interact: ignoraré «%s»"] = "🪑 Auto Interact: vou ignorar «%s»",
            ["🔌 Door 100: interactúa con la caja, se resuelve sola"] = "🔌 Door 100: interaja com a caixa, ela se resolve sozinha",
            ["✔ Verified Owner: bienvenido, %s"] = "✔ Verified Owner: bem-vindo, %s",
        },
    }
    for lg, t in pairs(TR_V64) do
        for k, v in pairs(t) do TR[lg][k] = v end
    end
end

pcall(function()
    TR.en["⛔ Demasiados intentos. Espera %ds"] = "⛔ Too many attempts. Wait %ds"
    TR.pt["⛔ Demasiados intentos. Espera %ds"] = "⛔ Muitas tentativas. Espere %ds"
    TR.en["Anti Alma (Archives)"] = "Anti Alma (Archives)"
    TR.en["Anti Closet Trash (Archives)"] = "Anti Closet Trash (Archives)"
    TR.en["Anti Ransom (eliminar modelo)"] = "Anti Ransom (delete model)"
    TR.en["Anti Agua Eléctrica (Archives)"] = "Anti Electric Water (Archives)"
    TR.en["Archives / Stairwell (V6.2)"] = "Archives / Stairwell (V6.2)"
    TR.en["Pack Bypass (V6.2)"] = "Bypass Pack (V6.2)"
    TR.en["Bypass Killbricks (lava)"] = "Bypass Killbricks (lava)"
    TR.en["Archives Pro (V6.2)"] = "Archives Pro (V6.2)"
    TR.en["Reloj de Archives (HUD)"] = "Archives Clock (HUD)"
    TR.en["Stop Time / Anti Stampede"] = "Stop Time / Anti Stampede"
    TR.pt["Anti Ransom (eliminar modelo)"] = "Anti Ransom (remover modelo)"
    TR.pt["Anti Agua Eléctrica (Archives)"] = "Anti Água Elétrica (Archives)"
    TR.pt["Pack Bypass (V6.2)"] = "Pacote Bypass (V6.2)"
    TR.pt["Reloj de Archives (HUD)"] = "Relógio do Archives (HUD)"
end)

-- (V8) marca: textos del pie de la ventana de la key
local TR_V8BRAND = {
    en = { ["V8  •  Entra al Discord para conseguir tu key"] = "V8  •  Join the Discord to get your key" },
    pt = { ["V8  •  Entra al Discord para conseguir tu key"] = "V8  •  Entre no Discord para pegar sua key" },
}
for lg, t in pairs(TR_V8BRAND) do
    for k, v in pairs(t) do TR[lg][k] = v end
end

-- (V8) cache de traducciones: tr() se llama cientos de veces al construir la UI y en cada
-- aviso; con la cache es un solo lookup. Se limpia al cambiar de idioma y al fusionar textos
-- nuevos en tiempo de ejecucion (para que una key traducida tarde no quede con el texto de reserva).
local TR_CACHE = {}
local function trFlush()
    TR_CACHE = {}
end
local function tr(key)
    if Lang == "es" then return TR_ES[key] or key end
    local c = TR_CACHE[Lang]
    if not c then c = {} TR_CACHE[Lang] = c end
    local v = c[key]
    if v == nil then
        local t = TR[Lang]
        v = (t and t[key]) or key
        c[key] = v
    end
    return v
end

local function trf(key, ...)
    local ok, res = pcall(string.format, tr(key), ...)
    return ok and res or tr(key)
end

local langHooks = {}
local function setLang(l)
    Lang = l
    trFlush()
    pcall(function()
        if writefile then writefile(CONFIG.LangFile, l) end
    end)
    for _, h in ipairs(langHooks) do pcall(h) end
end
local function nextLang()
    for i, l in ipairs(LANGS) do
        if l == Lang then return LANGS[i % #LANGS + 1] end
    end
    return "es"
end

----------------------------------------------------------------------
-- SERVICIOS / UTILIDADES
----------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
-- Móvil = pantalla táctil sin teclado (laptops táctiles cuentan como PC)
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ROWH = IS_MOBILE and 34 or 30
local function findPlayerCI(name)
    local l = name:lower()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Name:lower() == l then return pl end
    end
end

-- (V7) nombres aleatorios por sesión: no se puede detectar el hub buscando "RoshanHubUI" & co.
local function rndName()
    local ok, g = pcall(function() return game:GetService("HttpService"):GenerateGUID(false) end)
    return ok and g:gsub("[^%w]", ""):sub(1, 14) or tostring(math.random(1e9, 9e9))
end

local function parentGui(gui)
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local ok = pcall(function()
        if gethui then
            gui.Parent = gethui()
        else
            gui.Parent = game:GetService("CoreGui")
        end
    end)
    if not ok or not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
end

local function stroke(parent, color, thick)
    return new("UIStroke", {
        Color = color or CONFIG.Accent,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, c1, c2, rot)
    return new("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 90,
    }, parent)
end

local ANIM_COLLECT = nil -- se llena solo dentro del hub (para poder pausar las animaciones)
local function spin(grad, seconds)
    grad.Rotation = 0
    local tw = TweenService:Create(grad, TweenInfo.new(seconds or 8, Enum.EasingStyle.Linear,
        Enum.EasingDirection.In, -1), { Rotation = 360 })
    tw:Play()
    if ANIM_COLLECT then table.insert(ANIM_COLLECT, tw) end
end

local function pulse(st, c1, c2)
    st.Color = c1
    local tw = TweenService:Create(st, TweenInfo.new(1.4, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), { Color = c2 })
    tw:Play()
    if ANIM_COLLECT then table.insert(ANIM_COLLECT, tw) end
    return tw
end

local function lighten(c, a) return c:Lerp(Color3.new(1, 1, 1), a) end
local function darken(c, a) return c:Lerp(Color3.new(0, 0, 0), a) end

-- Brillo suave encima de un botón SIN teñir el texto (UIGradient en el botón pintaba el texto oscuro)
local function sheen(parent, r)
    local f = new("Frame", {
        Name = "Sheen", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, Active = false, ZIndex = (parent.ZIndex or 1),
    }, parent)
    corner(f, r or 8)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 90,
    }, f)
    return f
end

local function pressFx(btn)
    local sc = new("UIScale", { Scale = 1 }, btn)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(sc, TweenInfo.new(0.07), { Scale = 0.96 }):Play()
    end)
    local function up()
        TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Back), { Scale = 1 }):Play()
    end
    btn.MouseButton1Up:Connect(up)
    btn.MouseLeave:Connect(up)
end

local function isPremiumUser()
    local pm = CONFIG.PremiumByName
    return pm ~= nil and pm[LocalPlayer.Name:lower()] == true
end

local function isVerifiedUser()
    if CONFIG.VerifiedById[LocalPlayer.UserId] then return true end
    return CONFIG.VerifiedByName[LocalPlayer.Name:lower()] == true
end

local function getRole()
    local r = CONFIG.DevsById[LocalPlayer.UserId]
    if r then return r end
    return CONFIG.DevsByName[LocalPlayer.Name:lower()]
end

----------------------------------------------------------------------
-- KEY SYSTEM
----------------------------------------------------------------------
-- (V7) Las keys YA NO están en texto plano: solo existen sus huellas (hash estirado).
-- Cada huella lleva su nivel: u = normal, v = VIP, b = Booster (también VIP).
-- Para añadir una key nueva: calcula su huella con el script de generación y pégala aquí.
local KeyGuard = {}
do
    local SALT, ROUNDS = "rh63|k|", 300
    local HASHES = {
        ["d8ae5ecdd0a72580"] = "u", ["ab918760dec8b5ae"] = "u", ["0f4a37f9696ee08e"] = "u",
        ["db430a7ae8790490"] = "v", ["b920df5144e814d9"] = "v", ["ce7db13fd8f4d060"] = "u",
        ["aec86ab1a8c97f4d"] = "u", ["bd53addb35c45b2a"] = "u", ["2c22c579ff0a2777"] = "u",
        ["4aa7cecb362b84c1"] = "b",
    }
    local M32 = 4294967296
    local function mul32(a, b)
        local ah, al = math.floor(a / 65536), a % 65536
        return (((ah * b) % 65536) * 65536 + al * b) % M32
    end
    local function lane(s, seed)
        local h = seed
        for i = 1, #s do
            h = bit32.bxor(h, s:byte(i))
            h = mul32(h, 16777619)
            h = bit32.bxor(h, bit32.rshift(h, 15))
        end
        h = bit32.bxor(h, #s)
        h = mul32(bit32.bxor(h, bit32.rshift(h, 16)), 0x85ebca6b)
        h = mul32(bit32.bxor(h, bit32.rshift(h, 13)), 0xc2b2ae35)
        return bit32.bxor(h, bit32.rshift(h, 16))
    end
    local function digest(s)
        return string.format("%08x%08x", lane(s, 0x811C9DC5), lane(s .. "\0" .. SALT, 0x9E3779B9))
    end
    local function stretch(s)
        local d = digest(SALT .. s)
        for i = 0, ROUNDS - 1 do d = digest(d .. "|" .. i .. "|" .. s) end
        return d
    end
    local function same(a, b) -- comparación sin cortocircuito
        if #a ~= #b then return false end
        local diff = 0
        for i = 1, #a do diff = bit32.bor(diff, bit32.bxor(a:byte(i), b:byte(i))) end
        return diff == 0
    end
    local function clean(t) return ((t or ""):gsub("^%s+", ""):gsub("%s+$", "")) end
    local function uid() return tostring(LocalPlayer and LocalPlayer.UserId or 0) end
    -- firma de sesión: ligada a TU UserId, así un archivo copiado de otra cuenta no sirve
    local function sign(h) return digest(h .. "|" .. uid() .. "|" .. SALT .. "|sig") end

    -- anti-hook: las funciones del módulo deben seguir siendo closures de Lua y la huella de prueba debe coincidir
    local function hooked()
        local chk = isfunctionhooked or is_function_hooked
        if not chk then return false end
        for _, f in ipairs({ digest, stretch, same, sign }) do
            local ok, h = pcall(chk, f)
            if ok and h then return true end
        end
        return false
    end
    local function intact()
        if digest("selftest") ~= "ded650c37dd9e806" then return false end
        if hooked() then return false end -- (V7) hookfunction sobre las funciones de la key = manipulación
        local ok, bad = pcall(function()
            if islclosure then
                for _, f in ipairs({ digest, stretch, same, KeyGuard.verify, KeyGuard.revalidate, KeyGuard.owner }) do
                    if f and not islclosure(f) then return true end
                end
            end
            return false
        end)
        return ok and not bad
    end

    -- El owner se reconoce SOLO por UserId (los nombres se pueden reclamar/cambiar, los IDs no)
    local function isOwner()
        return LocalPlayer ~= nil and CONFIG.DevsById[LocalPlayer.UserId] == "Owner"
    end
    local function ctx(h)
        if h == "owner" then
            if not isOwner() then return nil end
            return { ok = true, h = "owner", vip = true, booster = false, owner = true, sig = sign("owner") }
        end
        local tier = HASHES[h]
        if not tier then return nil end
        return { ok = true, h = h, vip = (tier == "v" or tier == "b"), booster = (tier == "b"), sig = sign(h) }
    end

    function KeyGuard.verify(text)
        if not intact() then return nil end
        text = clean(text)
        if text == "" or #text > 64 then return nil end
        local h = stretch(text:upper())
        local found
        for known in pairs(HASHES) do
            if same(known, h) then found = known end -- recorre todas: tiempo constante
        end
        return found and ctx(found) or nil
    end
    -- sesión del owner: sin key (solo si tu UserId coincide)
    function KeyGuard.owner()
        if not intact() then return nil end
        return ctx("owner")
    end
    -- comprueba que un objeto de sesión no fue falsificado
    function KeyGuard.revalidate(a)
        if type(a) ~= "table" or not intact() then return nil end
        if type(a.h) ~= "string" or not (HASHES[a.h] or a.h == "owner") then return nil end
        if type(a.sig) ~= "string" or not same(a.sig, sign(a.h)) then return nil end
        return ctx(a.h)
    end

    -- archivo guardado: "v2:<huella>:<firma>" (sin la key en claro).
    -- Migra el formato viejo (key en texto plano) automáticamente.
    function KeyGuard.save(a)
        pcall(function()
            if writefile and a then writefile(CONFIG.SaveFile, "v2:" .. a.h .. ":" .. sign(a.h)) end
        end)
    end
    function KeyGuard.load()
        local ok, raw = pcall(function()
            if isfile and readfile and isfile(CONFIG.SaveFile) then return readfile(CONFIG.SaveFile) end
        end)
        if not ok or type(raw) ~= "string" then return nil end
        raw = clean(raw)
        local h, sg = raw:match("^v2:(%x+):(%x+)$")
        if h then
            if HASHES[h] and same(sg, sign(h)) and intact() then return ctx(h) end
            return nil
        end
        local a = KeyGuard.verify(raw) -- formato V6.2
        if a then KeyGuard.save(a) end
        return a
    end

    -- límite de intentos: 5 fallos => espera creciente (30s, 60s, 120s... máx. 10 min). Persistente y firmado.
    local lockFile = "RoshanHub_Lock.txt"
    local fails, lockUntil = 0, 0
    pcall(function()
        if isfile and readfile and isfile(lockFile) then
            local f, u, sg = readfile(lockFile):match("^(%d+):(%d+):(%x+)$")
            if f and sg == digest(f .. ":" .. u .. ":" .. SALT .. "|lock") then
                fails, lockUntil = tonumber(f), tonumber(u)
            else
                fails, lockUntil = 5, os.time() + 300 -- archivo manipulado: castigo
            end
        end
    end)
    local function persist()
        pcall(function()
            if writefile then
                writefile(lockFile, fails .. ":" .. lockUntil .. ":" .. digest(fails .. ":" .. lockUntil .. ":" .. SALT .. "|lock"))
            end
        end)
    end
    function KeyGuard.waitLeft() return math.max(0, lockUntil - os.time()) end
    -- Reacción a manipulación detectada: bloqueo de 10 min y se borra la key guardada
    function KeyGuard.punish()
        fails, lockUntil = 5, os.time() + 600
        persist()
        pcall(function() if writefile then writefile(CONFIG.SaveFile, "") end end)
    end
    -- devuelve (auth|nil, segundos de bloqueo)
    function KeyGuard.attempt(text)
        local left = KeyGuard.waitLeft()
        if left > 0 then return nil, left end
        task.wait(0.35) -- frena la fuerza bruta
        local a = KeyGuard.verify(text)
        if a then
            fails, lockUntil = 0, 0
            persist()
            return a, 0
        end
        fails = fails + 1
        if fails >= 5 then
            lockUntil = os.time() + math.floor(math.min(600, 30 * 2 ^ (fails - 5)))
            persist()
            return nil, KeyGuard.waitLeft()
        end
        persist()
        return nil, 0
    end
end

-- ¿Ya usó el hub antes? (Guest = primera vez, Member = ya lo usó)
local function wasMember()
    local ok, res = pcall(function()
        return isfile and isfile(CONFIG.MemberFile) or false
    end)
    return ok and res == true
end
local function markMember()
    pcall(function()
        if writefile then writefile(CONFIG.MemberFile, tostring(os.time())) end
    end)
end

-- Contador de ejecuciones (para el rol Veteran: 10+)
local function readUses()
    local n = 0
    pcall(function()
        if isfile and readfile and isfile(CONFIG.UsesFile) then n = tonumber(readfile(CONFIG.UsesFile)) or 0 end
    end)
    return n
end
local function bumpUses()
    local n = readUses() + 1
    pcall(function() if writefile then writefile(CONFIG.UsesFile, tostring(n)) end end)
    return n
end

local RANKS = {
    Guest   = { icon = "🆕", color = Color3.fromRGB(190, 190, 205), c2 = Color3.fromRGB(120, 120, 140) },
    Member  = { icon = "👤", color = Color3.fromRGB(110, 180, 255), c2 = Color3.fromRGB(60, 110, 220) },
    Veteran = { icon = "🏅", color = Color3.fromRGB(90, 235, 190), c2 = Color3.fromRGB(30, 160, 150) },
    VIP     = { icon = "💎", color = Color3.fromRGB(255, 230, 120), c2 = Color3.fromRGB(255, 170, 40) },
    Booster = { icon = "🚀", color = Color3.fromRGB(255, 130, 220), c2 = Color3.fromRGB(180, 70, 255) },
    Staff   = { icon = "⭐", color = Color3.fromRGB(255, 230, 120), c2 = Color3.fromRGB(255, 120, 40) },
    Premium = { icon = "💠", color = Color3.fromRGB(120, 235, 255), c2 = Color3.fromRGB(150, 110, 255) },
}

----------------------------------------------------------------------
-- PANTALLA DE CARGA V7 (pantalla completa, responsive, orbes, chips de módulos)
----------------------------------------------------------------------
pcall(function()
    TR.en["Núcleo"] = "Core" TR.en["ESP por eventos"] = "Event ESP"
    TR.en["Filtros Anti"] = "Anti filters" TR.en["Interfaz"] = "Interface"
    TR.pt["Núcleo"] = "Núcleo" TR.pt["ESP por eventos"] = "ESP por eventos"
    TR.pt["Filtros Anti"] = "Filtros Anti" TR.pt["Interfaz"] = "Interface"
end)

local function showLoading(rankName, rankData, userName, intro)
    local gui = new("ScreenGui", {
        Name = rndName(), ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 200, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    -- cubre TODO (notch, barras y esquinas redondeadas del móvil)
    pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
    parentGui(gui)
    local blur
    pcall(function() blur = new("BlurEffect", { Size = 0 }, Lighting) end)
    if blur then TweenService:Create(blur, TweenInfo.new(0.5), { Size = 18 }):Play() end

    local root = new("CanvasGroup", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 4, 14),
        BackgroundTransparency = 0, BorderSizePixel = 0, GroupTransparency = 1,
    }, gui)
    TweenService:Create(root, TweenInfo.new(0.35), { GroupTransparency = 0 }):Play()

    local main, alt = rankData.color, rankData.c2
    local rng = Random.new()
    local GREEN = Color3.fromRGB(120, 255, 175)
    local DIM = Color3.fromRGB(70, 58, 104)
    local cam = workspace.CurrentCamera

    -- ===== fondo: degradado, orbes de luz, cuadrícula, partículas, barrido =====
    local bg = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, root)
    gradient(bg, Color3.fromRGB(30, 16, 58), Color3.fromRGB(4, 3, 10), 70)

    local function orb(px, py, size, color, tr0, secs)
        local o = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(px, py),
            Size = UDim2.new(0, size, 0, size), BackgroundColor3 = color,
            BackgroundTransparency = tr0, BorderSizePixel = 0,
        }, bg)
        corner(o, size)
        new("UIGradient", { Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }), Rotation = 90 }, o)
        TweenService:Create(o, TweenInfo.new(secs, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Position = UDim2.fromScale(px + 0.05, py - 0.04), BackgroundTransparency = math.min(tr0 + 0.12, 0.97) }):Play()
    end
    orb(0.15, 0.2, 520, CONFIG.Accent, 0.82, 5)
    orb(0.88, 0.82, 600, alt, 0.84, 6.5)
    orb(0.5, 0.5, 420, main, 0.9, 4)

    -- cuadrícula tenue
    local gridW = 56
    for i = 1, 24 do
        new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, i * gridW, 0, 0),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.95, BorderSizePixel = 0 }, bg)
    end
    for i = 1, 14 do
        new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, i * gridW),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.95, BorderSizePixel = 0 }, bg)
    end

    local palette = { lighten(main, 0.5), CONFIG.Accent, Color3.new(1, 1, 1), lighten(alt, 0.4) }
    for _ = 1, 38 do
        local sz = rng:NextInteger(2, 5)
        local x, y = rng:NextNumber(), rng:NextNumber()
        local dot = new("Frame", {
            Size = UDim2.new(0, sz, 0, sz), Position = UDim2.fromScale(x, y),
            BackgroundColor3 = palette[rng:NextInteger(1, #palette)],
            BackgroundTransparency = 0.85, BorderSizePixel = 0,
        }, bg)
        corner(dot, 4)
        TweenService:Create(dot, TweenInfo.new(2.4 + rng:NextNumber() * 4, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true), {
            Position = UDim2.fromScale(math.clamp(x + (rng:NextNumber() - 0.5) * 0.08, 0, 1), math.clamp(y - 0.1, 0, 1)),
            BackgroundTransparency = 0.2,
        }):Play()
    end

    local scan = new("Frame", {
        Size = UDim2.new(1, 0, 0, 90), Position = UDim2.new(0, 0, 0, -90),
        BackgroundColor3 = main, BackgroundTransparency = 0.9, BorderSizePixel = 0,
    }, bg)
    new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.85, 0.2),
        NumberSequenceKeypoint.new(1, 1) }) }, scan)
    TweenService:Create(scan, TweenInfo.new(3.8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
        { Position = UDim2.new(0, 0, 1, 0) }):Play()

    -- viñeta (oscurece los bordes)
    local vig = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0, BorderSizePixel = 0, Active = false }, root)
    new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.3, 1),
        NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 0.35) }) }, vig)

    -- ===== marco de pantalla completa: esquinas, versión, usuario, pie =====
    local function cornerMark(ax, ay, px, py)
        local f = new("Frame", { AnchorPoint = Vector2.new(ax, ay), Position = UDim2.new(px, ax == 0 and 14 or -14, py, ay == 0 and 14 or -14),
            Size = UDim2.new(0, 22, 0, 22), BackgroundTransparency = 1 }, root)
        new("Frame", { Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, ay, ay == 0 and 0 or -2),
            BackgroundColor3 = main, BackgroundTransparency = 0.35, BorderSizePixel = 0 }, f)
        new("Frame", { Size = UDim2.new(0, 2, 1, 0), Position = UDim2.new(ax, ax == 0 and 0 or -2, 0, 0),
            BackgroundColor3 = main, BackgroundTransparency = 0.35, BorderSizePixel = 0 }, f)
    end
    cornerMark(0, 0, 0, 0) cornerMark(1, 0, 1, 0) cornerMark(0, 1, 0, 1) cornerMark(1, 1, 1, 1)

    new("TextLabel", {
        Position = UDim2.new(0, 44, 0, 14), Size = UDim2.new(0.4, 0, 0, 16), BackgroundTransparency = 1,
        Text = "V 7", TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = lighten(main, 0.3),
        Font = Enum.Font.GothamBlack, TextSize = 12,
    }, root)
    new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -44, 0, 14), Size = UDim2.new(0.5, 0, 0, 16),
        BackgroundTransparency = 1, Text = rankData.icon .. "  " .. userName, TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Color3.fromRGB(200, 190, 230), Font = Enum.Font.GothamMedium, TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, root)
    new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -34), Size = UDim2.new(0.9, 0, 0, 16),
        BackgroundTransparency = 1, Text = "📸 roshan_.sv   •   🎵 @roshandvss   •   ▶️ @ROSHAN_DVSS",
        TextColor3 = lighten(main, 0.15), Font = Enum.Font.GothamBold, TextSize = 12,
    }, root)
    new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16), Size = UDim2.new(0.9, 0, 0, 14),
        BackgroundTransparency = 1, Text = tr("Toca para saltar"), TextColor3 = Color3.fromRGB(130, 120, 165),
        Font = Enum.Font.Gotham, TextSize = 11,
    }, root)

    -- ===== contenido central: se escala solo según la pantalla =====
    local holder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 420, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
    }, root)
    local holderScale = new("UIScale", { Scale = 1 }, holder)
    local function calcScale()
        local vp = (cam and cam.ViewportSize) or Vector2.new(800, 400)
        local rawH = holder.AbsoluteSize.Y / math.max(holderScale.Scale, 0.01) -- altura sin escalar
        local sx = (vp.X - 40) / 440
        local sy = (vp.Y - 110) / math.max(rawH, 340)
        return math.clamp(math.min(sx, sy), 0.45, 1.5)
    end
    local function rescale()
        local target = calcScale()
        if math.abs(target - holderScale.Scale) > 0.005 then holderScale.Scale = target end
    end
    holderScale.Scale = calcScale() * 0.9
    local vpConn
    if cam then vpConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(rescale) end
    local sizeConn = holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(rescale)
    new("UIListLayout", {
        Padding = UDim.new(0, 9), HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, holder)

    -- logo: tres anillos + núcleo con latido
    local logoBox = new("Frame", { Size = UDim2.new(0, 112, 0, 112), BackgroundTransparency = 1, LayoutOrder = 1 }, holder)
    local function ring(size, thick, c, secs, reverse)
        local r = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1,
        }, logoBox)
        corner(r, size)
        local st = stroke(r, Color3.new(1, 1, 1), thick)
        local g = new("UIGradient", {
            Color = ColorSequence.new(c, lighten(c, 0.5)),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.1),
                NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1) }),
        }, st)
        TweenService:Create(g, TweenInfo.new(secs, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
            { Rotation = reverse and -360 or 360 }):Play()
    end
    ring(110, 3, CONFIG.Accent, 1.9, false)
    ring(90, 2, main, 2.8, true)
    ring(70, 2, alt, 1.4, false)
    local core = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0, 52, 0, 52), BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "R", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 30,
    }, logoBox)
    corner(core, 26)
    spin(gradient(core, main, alt, 45), 4)
    local coreScale = new("UIScale", { Scale = 0 }, core)
    local pop = TweenService:Create(coreScale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    pop:Play()
    pop.Completed:Once(function()
        if coreScale.Parent then
            TweenService:Create(coreScale, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                { Scale = 1.1 }):Play()
        end
    end)

    local titleLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "",
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextScaled = true, LayoutOrder = 2,
    }, holder)
    new("UITextSizeConstraint", { MaxTextSize = 28 }, titleLbl)
    spin(gradient(titleLbl, Color3.new(1, 1, 1), lighten(main, 0.35), 0), 4)

    local sub = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
        Text = "D O O R S   •   P R E M I U M   •   V 7", TextTransparency = 1,
        TextColor3 = Color3.fromRGB(175, 165, 210), Font = Enum.Font.GothamMedium, TextSize = 11, LayoutOrder = 3,
    }, holder)
    TweenService:Create(sub, TweenInfo.new(0.8), { TextTransparency = 0.05 }):Play()

    local pill = new("TextLabel", {
        Size = UDim2.new(0, 0, 0, 28), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(28, 20, 48), BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = rankData.icon .. " " .. rankName .. "  •  " .. userName, TextTransparency = 1,
        TextColor3 = main, Font = Enum.Font.GothamBold, TextSize = 14, LayoutOrder = 4,
    }, holder)
    corner(pill, 14)
    new("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, pill)
    local pillStroke = stroke(pill, main, 1.5)
    pillStroke.Transparency = 1
    task.delay(0.5, function()
        if pill.Parent then
            TweenService:Create(pill, TweenInfo.new(0.5), { BackgroundTransparency = 0.1, TextTransparency = 0 }):Play()
            TweenService:Create(pillStroke, TweenInfo.new(0.5), { Transparency = 0.25 }):Play()
        end
    end)

    -- ===== módulos como chips =====
    local mods = intro and { tr("Núcleo"), tr("Idioma") }
        or { tr("Núcleo"), tr("ESP por eventos"), tr("Filtros Anti"), tr("Interfaz") }
    local steps = intro
        and { tr("Iniciando módulos..."), tr("Sincronizando idioma..."), tr("¡Listo!") }
        or { tr("Iniciando módulos..."), tr("Cargando ESP por eventos..."), tr("Preparando filtros Anti..."),
             tr("Sincronizando idioma..."), tr("Construyendo interfaz..."), tr("¡Listo!") }
    local total, nm = #steps, #mods

    local chipRow = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 5 }, holder)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder }, chipRow)
    local rows = {}
    for i = 1, nm do
        local c = new("Frame", { Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(24, 18, 42), BackgroundTransparency = 0.1, BorderSizePixel = 0,
            LayoutOrder = i }, chipRow)
        corner(c, 12)
        local cs = stroke(c, DIM, 1)
        cs.Transparency = 0.3
        new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 12) }, c)
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            VerticalAlignment = Enum.VerticalAlignment.Center }, c)
        local ic = new("TextLabel", { Size = UDim2.new(0, 14, 1, 0), BackgroundTransparency = 1, Text = "○",
            TextColor3 = DIM, Font = Enum.Font.GothamBold, TextSize = 13, LayoutOrder = 1 }, c)
        local tx = new("TextLabel", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1, Text = mods[i], TextColor3 = Color3.fromRGB(130, 120, 165),
            Font = Enum.Font.GothamMedium, TextSize = 12, LayoutOrder = 2 }, c)
        rows[i] = { ic = ic, tx = tx, st = cs, state = 0 }
    end
    local function setRow(i, state)
        local rw = rows[i]
        if not rw or rw.state == state then return end
        rw.state = state
        if state == 2 then
            rw.ic.Text = "✔" rw.ic.TextColor3 = GREEN
            rw.tx.TextColor3 = Color3.fromRGB(220, 248, 230)
            rw.st.Color = GREEN rw.st.Transparency = 0.55
        elseif state == 1 then
            rw.ic.TextColor3 = lighten(main, 0.35)
            rw.tx.TextColor3 = Color3.new(1, 1, 1)
            rw.st.Color = main rw.st.Transparency = 0.2
        end
    end

    -- estado + porcentaje
    local row = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 6 }, holder)
    local status = new("TextLabel", {
        Size = UDim2.new(0.75, 0, 1, 0), BackgroundTransparency = 1, Text = "",
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(210, 200, 240),
        Font = Enum.Font.GothamMedium, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
    }, row)
    local pct = new("TextLabel", {
        Size = UDim2.new(0.25, 0, 1, 0), Position = UDim2.new(0.75, 0, 0, 0), BackgroundTransparency = 1,
        Text = "0%", TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = main,
        Font = Enum.Font.GothamBlack, TextSize = 15,
    }, row)

    local barBg = new("Frame", { Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = Color3.fromRGB(34, 26, 58),
        BorderSizePixel = 0, LayoutOrder = 7 }, holder)
    corner(barBg, 5)
    stroke(barBg, Color3.fromRGB(70, 56, 112), 1).Transparency = 0.5
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ClipsDescendants = true }, barBg)
    corner(fill, 5)
    spin(gradient(fill, main, CONFIG.Accent, 0), 2)
    local shine = new("Frame", { Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(-0.3, 0, 0, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.55, BorderSizePixel = 0 }, fill)
    TweenService:Create(shine, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
        { Position = UDim2.new(1.3, 0, 0, 0) }):Play()

    local tips = {
        tr("💡 Consejo: activa AntiSpeed Bypass antes de usar Speed."),
        tr("💡 Consejo: en Mines usa Bridge Saver durante la persecución de Seek."),
        tr("💡 Consejo: en Archives, Ransom = quédate quieto."),
        tr("💡 Consejo: toca R (botón flotante) para abrir el menú."),
        tr("💡 Consejo: mira la pestaña Estado para ver cuánta gente usa el hub."),
        tr("💡 Consejo: Auto Door 50 te da el código de la Biblioteca."),
        tr("💡 Consejo: Anti Ransom te congela solo cuando aparece Ransom."),
        tr("💡 Consejo: en el Candy Vault activa Candy Vault ESP (pestaña Visual)."),
        tr("💡 Consejo: Auto Anti Lag sube tus FPS solo cuando bajan."),
    }
    local tipLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, TextWrapped = true,
        Text = tips[rng:NextInteger(1, #tips)], TextColor3 = Color3.fromRGB(155, 145, 190),
        Font = Enum.Font.Gotham, TextSize = 12, LayoutOrder = 8,
    }, holder)

    local skip = false
    local skipBtn = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 50 }, root)
    skipBtn.Activated:Connect(function() skip = true end)
    task.spawn(function()
        local i = 1
        while gui.Parent and not skip do
            task.wait(1.7)
            if not gui.Parent or skip then break end
            i = i % #tips + 1
            local t1 = TweenService:Create(tipLbl, TweenInfo.new(0.2), { TextTransparency = 1 })
            t1:Play()
            t1.Completed:Wait()
            if not gui.Parent then break end
            tipLbl.Text = tips[i]
            TweenService:Create(tipLbl, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
        end
    end)

    -- ===== secuencia (protegida: pase lo que pase, la pantalla se cierra) =====
    local okRun = pcall(function()
        task.wait(0.25)
        rescale()
        local name = CONFIG.Name
        for i = 1, #name do
            if skip then titleLbl.Text = name break end
            titleLbl.Text = name:sub(1, i)
            task.wait(0.024)
        end
        local duration = intro and 1.2 or 2.8
        local t0 = os.clock()
        local lastIdx, frame = 0, 0
        local spin4 = { "◐", "◓", "◑", "◒" }
        while gui.Parent do
            local x = skip and 1 or math.min((os.clock() - t0) / duration, 1)
            local p = 1 - (1 - x) * (1 - x)
            fill.Size = UDim2.new(p, 0, 1, 0)
            pct.Text = math.floor(p * 100) .. "%"
            local idx = math.min(total, math.floor(p * total) + 1)
            if idx ~= lastIdx then lastIdx = idx status.Text = steps[idx] end
            local cur = math.min(nm, math.floor(p * nm) + 1)
            for i = 1, nm do
                if i < cur or p >= 1 then setRow(i, 2) elseif i == cur then setRow(i, 1) end
            end
            frame = frame + 1
            if rows[cur] and rows[cur].state == 1 then rows[cur].ic.Text = spin4[(math.floor(frame / 4) % 4) + 1] end
            if x >= 1 then break end
            task.wait()
        end
        fill.Size = UDim2.new(1, 0, 1, 0)
        pct.Text = "100%"
        status.Text = tr("¡Listo!")
        for i = 1, nm do setRow(i, 2) end
        TweenService:Create(fill, TweenInfo.new(0.25), { BackgroundColor3 = GREEN }):Play()
        task.wait(skip and 0.05 or 0.45)
        TweenService:Create(holderScale, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Scale = holderScale.Scale * 1.06 }):Play()
        TweenService:Create(root, TweenInfo.new(0.35), { GroupTransparency = 1 }):Play()
        if blur then TweenService:Create(blur, TweenInfo.new(0.35), { Size = 0 }):Play() end
        task.wait(0.4)
    end)
    if vpConn then vpConn:Disconnect() end
    sizeConn:Disconnect()
    if blur then blur:Destroy() end
    gui:Destroy()
    return okRun
end

TR.en["✅ Ya puedes intentar de nuevo"] = "✅ You can try again now"
TR.pt["✅ Ya puedes intentar de nuevo"] = "✅ Já pode tentar novamente"
local startHub -- forward

local function showKeyUI()
    local gui = new("ScreenGui", {
        Name = rndName(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    parentGui(gui)

    local blur
    pcall(function() blur = new("BlurEffect", { Size = 14 }, Lighting) end)

    local binds = {}
    local function bind(obj, prop, fn)
        obj[prop] = fn()
        table.insert(binds, { obj, prop, fn })
    end
    table.insert(langHooks, function()
        for _, b in ipairs(binds) do b[1][b[2]] = b[3]() end
    end)

    local dim = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, gui)

    -- chispas flotantes
    local rng = Random.new()
    for _ = 1, 16 do
        local size = rng:NextInteger(3, 6)
        local x = rng:NextNumber()
        local dot = new("Frame", {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(x, 0, 0.6 + rng:NextNumber() * 0.4, 0),
            BackgroundColor3 = (rng:NextNumber() > 0.5) and Color3.fromRGB(210, 150, 255) or Color3.new(1, 1, 1),
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
        }, dim)
        corner(dot, 3)
        TweenService:Create(dot, TweenInfo.new(3 + rng:NextNumber() * 4, Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out, -1), {
            Position = UDim2.new(x, 0, 0, -10),
            BackgroundTransparency = 1,
        }):Play()
    end

    local card = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.new(0.86, 0, 0, 380),
        BackgroundColor3 = Color3.new(1, 1, 1), -- base blanca: el gradiente define el color
        BorderSizePixel = 0,
    }, dim)
    corner(card, 16)
    spin(gradient(card, Color3.fromRGB(62, 36, 108), Color3.fromRGB(22, 14, 40), 70), 14)
    pulse(stroke(card, CONFIG.Accent, 2), CONFIG.Accent, Color3.fromRGB(255, 120, 220))
    local cardCons = new("UISizeConstraint", { MaxSize = Vector2.new(340, 380), MinSize = Vector2.new(240, 380) }, card)
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back),
        { Position = UDim2.fromScale(0.5, 0.46) }):Play()

    local logo = new("TextLabel", {
        Size = UDim2.new(0, 46, 0, 46),
        Position = UDim2.new(0.5, -23, 0, 14),
        BackgroundColor3 = Color3.fromRGB(150, 70, 240),
        Text = "R",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 28,
    }, card)
    corner(logo, 23)
    sheen(logo, 23)
    stroke(logo, Color3.new(1, 1, 1), 1.5)
    local logoScale = new("UIScale", { Scale = 1 }, logo)
    TweenService:Create(logoScale, TweenInfo.new(1.2, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), { Scale = 1.1 }):Play()

    -- selector de idioma
    local langBtn = new("TextButton", {
        Size = UDim2.new(0, 50, 0, 22),
        Position = UDim2.new(1, -58, 0, 8),
        BackgroundColor3 = Color3.fromRGB(50, 36, 84),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
    }, card)
    corner(langBtn, 7)
    pressFx(langBtn)
    bind(langBtn, "Text", function() return "🌐 " .. Lang:upper() end)
    langBtn.Activated:Connect(function() setLang(nextLang()) end)

    -- minimizar / cerrar la ventana de la key
    local function iconBtn(txt, x, color)
        local b = new("TextButton", {
            Size = UDim2.new(0, 24, 0, 22), Position = UDim2.new(0, x, 0, 8),
            BackgroundColor3 = color, Text = txt, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
        }, card)
        corner(b, 7)
        pressFx(b)
        return b
    end
    local minBtn = iconBtn("—", 8, Color3.fromRGB(50, 36, 84))
    local closeBtn = iconBtn("✕", 36, Color3.fromRGB(150, 40, 60))
    local pill = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 96, 0, 28), BackgroundColor3 = Color3.fromRGB(70, 40, 120),
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 13,
        Text = "🔑 Key", Visible = false, AutoButtonColor = false, ZIndex = 5,
    }, gui)
    corner(pill, 14)
    stroke(pill, CONFIG.Accent, 1.5)
    pressFx(pill)
    minBtn.Activated:Connect(function()
        dim.Visible = false
        if blur then blur.Enabled = false end
        pill.Visible = true
    end)
    pill.Activated:Connect(function()
        pill.Visible = false
        dim.Visible = true
        if blur then blur.Enabled = true end
    end)
    closeBtn.Activated:Connect(function()
        if blur then blur:Destroy() end
        gui:Destroy()
        getgenv().RoshanHubLoaded = false
    end)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 66),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextScaled = true,
    }, card)
    local sub = new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 0, 90),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(185, 170, 215),
        Font = Enum.Font.Gotham,
        TextSize = 13,
    }, card)
    bind(sub, "Text", function() return tr("Ingresa tu key para continuar") end)

    local box = new("TextBox", {
        Size = UDim2.new(1, -30, 0, 42),
        Position = UDim2.new(0, 15, 0, 114),
        BackgroundColor3 = Color3.fromRGB(34, 26, 54),
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(130, 120, 150),
        Text = "",
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
    }, card)
    corner(box, 10)
    bind(box, "PlaceholderText", function() return tr("🔑  Escribe tu key aquí...") end)
    local boxStroke = stroke(box, Color3.fromRGB(80, 60, 120), 1.5)

    -- V8: boton Pegar (solo si el ejecutor puede leer el portapapeles)
    do
        local getClip = getclipboard or fromclipboard or (syn and syn.read_clipboard)
        if getClip then
            box.Size = UDim2.new(1, -78, 0, 42)
            local pasteBtn = new("TextButton", {
                Size = UDim2.new(0, 40, 0, 42), Position = UDim2.new(1, -55, 0, 114),
                BackgroundColor3 = Color3.fromRGB(70, 40, 120), Text = "📋", TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false,
            }, card)
            corner(pasteBtn, 10)
            pressFx(pasteBtn)
            stroke(pasteBtn, CONFIG.Accent, 1).Transparency = 0.4
            pasteBtn.Activated:Connect(function()
                local okc, txt = pcall(getClip)
                if okc and type(txt) == "string" and #txt > 0 then
                    box.Text = (txt:gsub("%s+", ""))
                    boxStroke.Color = Color3.fromRGB(90, 255, 140)
                    task.delay(0.6, function() boxStroke.Color = Color3.fromRGB(80, 60, 120) end)
                end
            end)
        end
    end

    local status = new("TextLabel", {
        Size = UDim2.new(1, -30, 0, 16),
        Position = UDim2.new(0, 15, 0, 160),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 90, 90),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)

    local btn = new("TextButton", {
        Size = UDim2.new(1, -30, 0, 42),
        Position = UDim2.new(0, 15, 0, 180),
        BackgroundColor3 = Color3.fromRGB(140, 60, 235),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
    }, card)
    corner(btn, 10)
    pressFx(btn)
    sheen(btn, 10)
    bind(btn, "Text", function() return tr("✔  VERIFICAR KEY") end)

    local getBtn = new("TextButton", {
        Size = UDim2.new(1, -30, 0, 38),
        Position = UDim2.new(0, 15, 0, 230),
        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    }, card)
    corner(getBtn, 10)
    pressFx(getBtn)
    bind(getBtn, "Text", function() return tr("🔗  GET KEY (copiar Discord)") end)
    getBtn.Activated:Connect(function()
        local copyFn = setclipboard or toclipboard or (syn and syn.write_clipboard)
        local ok = copyFn and pcall(copyFn, CONFIG.Discord)
        if ok then
            status.TextColor3 = Color3.fromRGB(90, 255, 140)
            status.Text = tr("✅ Link copiado, pégalo en tu navegador")
        else
            status.TextColor3 = Color3.fromRGB(255, 190, 60)
            status.Text = CONFIG.Discord
        end
    end)

    local contact = new("TextLabel", {
        Size = UDim2.new(1, -30, 0, 16),
        Position = UDim2.new(0, 15, 0, 274),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 215, 120),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, card)
    bind(contact, "Text", function() return tr("💎 ¿Quieres VIP Key o Boost? Escríbeme al DM:") end)
    local dmBtn = new("TextButton", {
        Size = UDim2.new(1, -30, 0, 26),
        Position = UDim2.new(0, 15, 0, 292),
        BackgroundColor3 = Color3.fromRGB(50, 36, 84),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false,
    }, card)
    corner(dmBtn, 8)
    pressFx(dmBtn)
    stroke(dmBtn, Color3.fromRGB(255, 215, 120), 1).Transparency = 0.5
    bind(dmBtn, "Text", function() return "💬 Discord: " .. CONFIG.DiscordUser .. "  (" .. tr("copiar") .. ")" end)
    dmBtn.Activated:Connect(function()
        local copyFn = setclipboard
        local ok = copyFn and pcall(copyFn, CONFIG.DiscordUser)
        if ok then
            status.TextColor3 = Color3.fromRGB(90, 255, 140)
            status.Text = tr("✅ Usuario de Discord copiado")
        else
            status.TextColor3 = Color3.fromRGB(255, 190, 60)
            status.Text = "Discord: " .. CONFIG.DiscordUser
        end
    end)

    -- sección VIP / Boost (se despliega)
    local vipOpen = false
    local vipHeader = new("TextButton", {
        Size = UDim2.new(1, -30, 0, 26), Position = UDim2.new(0, 15, 0, 326),
        BackgroundColor3 = Color3.fromRGB(70, 40, 120), TextColor3 = Color3.fromRGB(255, 230, 150),
        Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
    }, card)
    corner(vipHeader, 8)
    pressFx(vipHeader)
    bind(vipHeader, "Text", function() return tr("💎 ¿Tienes VIP o Boost? (activar)") .. (vipOpen and "  ▲" or "  ▼") end)
    local vipPanel = new("Frame", {
        Size = UDim2.new(1, -30, 0, 78), Position = UDim2.new(0, 15, 0, 358),
        BackgroundTransparency = 1, Visible = false,
    }, card)
    local vipBox = new("TextBox", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(34, 26, 54),
        TextColor3 = Color3.new(1, 1, 1), PlaceholderColor3 = Color3.fromRGB(130, 120, 150),
        Text = "", ClearTextOnFocus = false, Font = Enum.Font.GothamMedium, TextSize = 14,
    }, vipPanel)
    corner(vipBox, 8)
    stroke(vipBox, Color3.fromRGB(255, 215, 120), 1).Transparency = 0.5
    bind(vipBox, "PlaceholderText", function() return tr("🔑 Escribe tu key VIP o Boost...") end)
    local vipBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(190, 120, 30), TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
    }, vipPanel)
    corner(vipBtn, 8)
    pressFx(vipBtn)
    bind(vipBtn, "Text", function() return tr("💎 ACTIVAR VIP / BOOST") end)
    vipHeader.Activated:Connect(function()
        vipOpen = not vipOpen
        vipPanel.Visible = vipOpen
        local h = vipOpen and 464 or 380
        cardCons.MinSize = Vector2.new(240, h)
        cardCons.MaxSize = Vector2.new(340, h)
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad),
            { Size = UDim2.new(0.86, 0, 0, h) }):Play()
        vipHeader.Text = tr("💎 ¿Tienes VIP o Boost? (activar)") .. (vipOpen and "  ▲" or "  ▼")
    end)

    local foot = new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.new(0, 10, 1, -20),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(140, 130, 160),
        Font = Enum.Font.Gotham,
        TextSize = 11,
    }, card)
    bind(foot, "Text", function() return tr("V8  •  Entra al Discord para conseguir tu key") end)

    local barBg = new("Frame", {
        Size = UDim2.new(1, -30, 0, 6),
        Position = UDim2.new(0, 15, 0, 224),
        BackgroundColor3 = Color3.fromRGB(50, 40, 76),
        BorderSizePixel = 0,
        Visible = false,
    }, card)
    corner(barBg, 3)
    local barFill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(90, 255, 140),
        BorderSizePixel = 0,
    }, barBg)
    corner(barFill, 3)

    local busy = false
    local lockLoop = false
    local function shake()
        local origin = card.Position
        for i = 1, 6 do
            card.Position = origin + UDim2.new(0, (i % 2 == 0) and 9 or -9, 0, 0)
            task.wait(0.035)
        end
        card.Position = origin
    end

    local function submit(requireVip, srcText)
        if busy then return end
        busy = true
        local waitLeft = KeyGuard.waitLeft()
        if waitLeft > 0 then
            status.TextColor3 = Color3.fromRGB(255, 190, 60)
            status.Text = trf("⛔ Demasiados intentos. Espera %ds", waitLeft)
            busy = false
            if not lockLoop then
                -- V8: cuenta atras en vivo del bloqueo
                lockLoop = true
                task.spawn(function()
                    while gui.Parent and KeyGuard.waitLeft() > 0 do
                        status.TextColor3 = Color3.fromRGB(255, 190, 60)
                        status.Text = trf("⛔ Demasiados intentos. Espera %ds", KeyGuard.waitLeft())
                        task.wait(1)
                    end
                    lockLoop = false
                    if gui.Parent then
                        status.TextColor3 = Color3.fromRGB(90, 255, 140)
                        status.Text = tr("✅ Ya puedes intentar de nuevo")
                    end
                end)
            end
            return
        end
        local auth, lockSecs = KeyGuard.attempt(srcText or box.Text)
        if auth and requireVip == true and not auth.vip then auth = nil end
        if auth then
            status.TextColor3 = Color3.fromRGB(90, 255, 140)
            status.Text = tr("✅ Key correcta, cargando...")
            boxStroke.Color = Color3.fromRGB(90, 255, 140)
            KeyGuard.save(auth)
            barBg.Visible = true
            getBtn.Visible = false
            TweenService:Create(barFill, TweenInfo.new(0.7), { Size = UDim2.new(1, 0, 1, 0) }):Play()
            task.wait(0.8)
            if blur then blur:Destroy() end
            gui:Destroy()
            startHub(auth)
        else
            status.TextColor3 = Color3.fromRGB(255, 90, 90)
            status.Text = (lockSecs and lockSecs > 0) and trf("⛔ Demasiados intentos. Espera %ds", lockSecs)
                or (requireVip == true and tr("❌ Esa key no es VIP ni Boost") or tr("❌ Key inválida"))
            boxStroke.Color = Color3.fromRGB(255, 90, 90)
            shake()
            task.wait(0.8)
            boxStroke.Color = Color3.fromRGB(80, 60, 120)
            busy = false
        end
    end

    btn.Activated:Connect(function() submit() end)
    box.FocusLost:Connect(function(enter)
        if enter then submit() end
    end)

    -- activar VIP / Boost desde la ventana de la key
    local function submitVip()
        submit(true, vipBox.Text)
    end
    vipBtn.Activated:Connect(submitVip)
    vipBox.FocusLost:Connect(function(enter)
        if enter then submitVip() end
    end)
end

----------------------------------------------------------------------
-- HUB PRINCIPAL
----------------------------------------------------------------------
function startHub(usedKey, isRebuild)
    -- Estado agrupado en tablas (evita el límite de 200 registros locales de Luau)
    local HUI, HPG, HESP, HANTI, HLAG, HNET, HCOL, HST = {}, {}, {}, {}, {}, {}, {}, {}
    ----------------------------------------------------------------
    -- Rol: Staff > Booster > VIP > Member > Guest
    ----------------------------------------------------------------
    HST.returning = wasMember()
    markMember()
    HST.uses = isRebuild and readUses() or bumpUses()
    -- (V7) El hub vuelve a validar la sesión: si alguien se salta la ventana de la key, no arranca.
    if type(usedKey) == "table" then
        HST.auth = KeyGuard.revalidate(usedKey)
    elseif type(usedKey) == "string" then
        HST.auth = KeyGuard.verify(usedKey)
    end
    if not HST.auth then
        warn("[Roshan] Key no válida.")
        getgenv().RoshanHubLoaded = false
        return
    end
    HST.staffRole = getRole()
    local rankName
    if HST.staffRole then
        rankName = "Staff"
    elseif HST.auth.booster then
        rankName = "Booster"
    elseif isPremiumUser() then
        rankName = "Premium"
    elseif HST.auth.vip then
        rankName = "VIP"
    elseif HST.uses >= 10 then
        rankName = "Veteran"
    elseif HST.returning then
        rankName = "Member"
    else
        rankName = "Guest"
    end
    local rankData = RANKS[rankName]
    HST.rankLabel = HST.staffRole or rankName
    if not isRebuild then pcall(showLoading, HST.rankLabel, rankData, LocalPlayer.DisplayName) end
    ANIM_COLLECT = {}

    local alive = true
    local connections, cleanups = {}, {}
    local function track(c)
        table.insert(connections, c)
        return c
    end
    local function onCleanup(fn) table.insert(cleanups, fn) end

    local S = {
        reach = 0, speedValue = 16, fov = nil, flySpeed = 40,
        volume = 0.6, sound = true, debug = false, notify = true, flash = true,
    }
    local role = getRole()
    local isVip = (role ~= nil) or HST.auth.vip or (rankName == "Premium")
    local isDev = role ~= nil

    local gui = new("ScreenGui", {
        Name = rndName(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    })
    parentGui(gui)

    -- binder de idioma
    HUI.binds, HUI.bindOf = {}, {}
    function HUI.bind(obj, prop, fn)
        obj[prop] = fn()
        local e = { obj, prop, fn }
        table.insert(HUI.binds, e)
        HUI.bindOf[obj] = e
    end
    -- cambia el texto de un bind sin recorrer toda la lista (antes era O(n) cada segundo)
    function HUI.rebind(obj, fn)
        local e = HUI.bindOf[obj]
        if e then e[3] = fn end
        obj.Text = fn()
    end
    -- (moved to tables) searchBox -- se asigna más abajo
    table.insert(langHooks, function()
        if not alive then return end
        for _, b in ipairs(HUI.binds) do b[1][b[2]] = b[3]() end
    end)

    ------------------------------------------------------------------
    -- Acento / temas
    ------------------------------------------------------------------
    HUI.accent = CONFIG.Accent
    HUI.accentFns = {}
    HUI.rainbowOn = false
    -- (moved to tables) winStroke, pulseTween
    function HUI.onAccent(fn)
        table.insert(HUI.accentFns, fn)
        fn(HUI.accent)
    end
    function HUI.setUiAnim(on)
        S.uiAnim = on
        for _, tw in ipairs(ANIM_COLLECT or {}) do
            pcall(function() if on then tw:Play() else tw:Pause() end end)
        end
    end
    function HUI.startPulse()
        if not HUI.winStroke then return end
        if HUI.pulseTween then HUI.pulseTween:Cancel() end
        HUI.pulseTween = pulse(HUI.winStroke, HUI.accent, lighten(HUI.accent, 0.45))
        if S.uiAnim == false then pcall(function() HUI.pulseTween:Pause() end) end
    end
    function HUI.setAccent(c, light)
        HUI.accent = c
        for _, fn in ipairs(HUI.accentFns) do fn(c) end
        if HUI.rainbowOn then
            if HUI.winStroke then HUI.winStroke.Color = c end
        elseif not light then
            HUI.startPulse()
        end
    end

    ------------------------------------------------------------------
    -- Sonido, flash, notificaciones (abajo-derecha, como los badges)
    ------------------------------------------------------------------
    function HUI.playSound(kind)
        if not S.sound then return end
        pcall(function()
            local snd = new("Sound", {
                SoundId = CONFIG.Sounds[kind] or CONFIG.Sounds.info,
                Volume = S.volume,
            }, SoundService)
            snd:Play()
            Debris:AddItem(snd, 6)
        end)
    end

    HUI.flashFrame = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(255, 40, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 1,
    }, gui)
    function HUI.flash(kind)
        if not S.flash then return end
        HUI.flashFrame.BackgroundColor3 = (kind == "danger") and Color3.fromRGB(255, 40, 40)
            or Color3.fromRGB(255, 170, 40)
        HUI.flashFrame.BackgroundTransparency = 0.8
        TweenService:Create(HUI.flashFrame, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
    end

    HUI.toastHolder = new("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -12, 1, UserInputService.TouchEnabled and -110 or -14),
        Size = UDim2.new(0.62, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 100,
    }, gui)
    new("UISizeConstraint", { MaxSize = Vector2.new(290, 600), MinSize = Vector2.new(200, 0) }, HUI.toastHolder)
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, HUI.toastHolder)

    HUI.toastColors = {
        danger = Color3.fromRGB(255, 70, 70),
        warn = Color3.fromRGB(255, 190, 60),
        info = Color3.fromRGB(110, 170, 255),
        ok = Color3.fromRGB(90, 230, 130),
    }
    HUI.toasts, HUI.toastOrder = {}, 0

    function HUI.notifyRaw(text, kind, duration)
        kind = kind or "info"
        duration = (duration or 4) * ((S.toastPct or 100) / 100)
        local col = HUI.toastColors[kind] or HUI.toastColors.info
        if #HUI.toasts >= (S.maxToasts or 4) then
            local old = table.remove(HUI.toasts, 1)
            if old and old.Parent then old:Destroy() end
        end
        HUI.toastOrder = HUI.toastOrder + 1
        local wrap = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = HUI.toastOrder,
        }, HUI.toastHolder)
        table.insert(HUI.toasts, wrap)
        local f = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(1, 60, 0, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            ZIndex = 101,
        }, wrap)
        corner(f, 10)
        stroke(f, col, 1.5)
        gradient(f, Color3.fromRGB(52, 38, 80), Color3.fromRGB(22, 16, 38), 0)
        new("Frame", {
            Size = UDim2.new(0, 4, 1, -12),
            Position = UDim2.new(0, 5, 0, 6),
            BackgroundColor3 = col,
            BorderSizePixel = 0,
            ZIndex = 102,
        }, f)
        new("UIPadding", {
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 10),
        }, f)
        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = text,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            ZIndex = 103,
        }, f)
        TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Back),
            { Position = UDim2.new(0, 0, 0, 0) }):Play()
        HUI.playSound(kind)
        if kind == "danger" or kind == "warn" then HUI.flash(kind) end
        task.delay(duration, function()
            if wrap and wrap.Parent then
                TweenService:Create(f, TweenInfo.new(0.3),
                    { Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1 }):Play()
                task.wait(0.32)
                wrap:Destroy()
            end
            local idx = table.find(HUI.toasts, wrap)
            if idx then table.remove(HUI.toasts, idx) end
        end)
    end

    local function notify(key, kind, duration, ...)
        local text
        if select("#", ...) > 0 then text = trf(key, ...) else text = tr(key) end
        HUI.notifyRaw(text, kind, duration)
    end
    -- (V7) un solo sitio para "copiar al portapapeles + consola + aviso" (antes repetido 4 veces)
    function HNET.copyOut(out)
        local txt = type(out) == "table" and table.concat(out, "\n") or tostring(out)
        pcall(function() if setclipboard then setclipboard(txt) end end)
        print(txt)
        notify("📋 Info copiada al portapapeles", "ok", 2)
    end

    ------------------------------------------------------------------
    -- Ventana principal
    ------------------------------------------------------------------
    function HUI.makeDraggable(handle, target, onTap)
        local dragging, dragStart, startPos = false, nil, nil
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = target.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        if onTap and (input.Position - dragStart).Magnitude < 8 then
                            onTap()
                        end
                    end
                end)
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - dragStart
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end))
    end

    local win = new("Frame", {
        Name = "Window",
        AnchorPoint = IS_MOBILE and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
        Position = IS_MOBILE and UDim2.new(0, 8, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0),
        Size = IS_MOBILE and UDim2.new(0.72, 0, 0, 322) or UDim2.new(0.56, 0, 0, 470),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, gui)
    corner(win, 12)
    gradient(win, Color3.fromRGB(34, 24, 58), Color3.fromRGB(16, 12, 28), 90)
    HUI.winStroke = stroke(win, HUI.accent, 1.5)
    HUI.startPulse()
    spin(new("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 185, 255)) }, HUI.winStroke), 6)
    new("UISizeConstraint", IS_MOBILE
        and { MaxSize = Vector2.new(300, 322), MinSize = Vector2.new(230, 322) }
        or { MaxSize = Vector2.new(800, 470), MinSize = Vector2.new(640, 470) }, win)
    HUI.winScale = new("UIScale", { Scale = 1 }, win)

    HUI.header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, win)
    corner(HUI.header, 12)
    HUI.headerGrad = gradient(HUI.header, Color3.fromRGB(80, 40, 150), Color3.fromRGB(34, 20, 60), 0)
    spin(HUI.headerGrad, 10)
    HUI.onAccent(function(c)
        HUI.headerGrad.Color = ColorSequence.new(darken(c, 0.1), darken(c, 0.55))
    end)
    HUI.hLine = new("Frame", {
        Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = HUI.accent, BorderSizePixel = 0,
    }, HUI.header)
    new("UIGradient", { Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 1) }) }, HUI.hLine)
    HUI.onAccent(function(c) HUI.hLine.BackgroundColor3 = lighten(c, 0.3) end)

    HUI.chipText = rankData.icon .. " " .. HST.rankLabel
    HUI.titleW = -140
    local title = new("TextLabel", {
        Size = UDim2.new(1, HUI.titleW, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = CONFIG.Name,
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextScaled = true,
    }, HUI.header)
    new("UITextSizeConstraint", { MaxTextSize = IS_MOBILE and 13 or 16 }, title)
    title.TextWrapped = false

    if HUI.chipText then
        local chip = new("TextLabel", {
            Size = UDim2.new(0, 70, 0, 18),
            Position = UDim2.new(1, -140, 0.5, -9),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Text = HUI.chipText,
            TextColor3 = Color3.fromRGB(40, 25, 0),
            Font = Enum.Font.GothamBold,
            TextScaled = true,
        }, HUI.header)
        corner(chip, 9)
        new("UITextSizeConstraint", { MaxTextSize = 10 }, chip)
        local chipGrad = gradient(chip, rankData.color, rankData.c2, 0)
        spin(chipGrad, 4)
        if rankName == "Guest" or rankName == "Member" then
            chip.TextColor3 = Color3.fromRGB(15, 10, 30)
        end
    end

    function HUI.headerBtn(text, xOff, color)
        local b = new("TextButton", {
            Size = UDim2.new(0, 28, 0, 24),
            Position = UDim2.new(1, xOff, 0.5, -12),
            BackgroundColor3 = color,
            Text = text,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
        }, HUI.header)
        corner(b, 6)
        pressFx(b)
        return b
    end
    HUI.minBtn = HUI.headerBtn("–", -64, Color3.fromRGB(70, 50, 110))
    HUI.closeBtn = HUI.headerBtn("X", -33, Color3.fromRGB(150, 40, 60))

    HUI.float = new("TextButton", {
        Name = "Float",
        Position = UDim2.new(0, 8, 0.14, 0),
        Size = UDim2.new(0, 44, 0, 44),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Text = "R",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 20,
    }, gui)
    corner(HUI.float, 22)
    sheen(HUI.float, 22)
    HUI.onAccent(function(c)
        HUI.float.BackgroundColor3 = darken(c, 0.1)
    end)
    stroke(HUI.float, Color3.new(1, 1, 1), 1.5)
    HUI.floatScale = new("UIScale", { Scale = 1 }, HUI.float)
    HUI.floatTw = TweenService:Create(HUI.floatScale, TweenInfo.new(1.1, Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut, -1, true), { Scale = 1.12 })
    HUI.floatTw:Play()
    if ANIM_COLLECT then table.insert(ANIM_COLLECT, HUI.floatTw) end

    function HUI.setOpen(open)
        if open then
            local target = (S.uiScalePct or 100) / 100
            HUI.winScale.Scale = target * 0.88
            win.Visible = true
            TweenService:Create(HUI.winScale, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Scale = target }):Play()
        else
            win.Visible = false
        end
        HUI.float.Visible = not open
    end

    HUI.makeDraggable(HUI.header, win)
    HUI.makeDraggable(HUI.float, HUI.float, function() HUI.setOpen(true) end)
    HUI.minBtn.Activated:Connect(function() HUI.setOpen(false) end)
    HUI.closeBtn.Activated:Connect(function() HUI.setOpen(false) end)
    track(UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift then
            HUI.setOpen(not win.Visible)
        end
    end))

    -- PC: barra lateral vertical (se leen mejor las ~13 pestañas). Móvil: barra superior como siempre.
    HUI.SIDEW = 134
    -- (moved to tables) tabBar
    if IS_MOBILE then
        HUI.tabBar = new("ScrollingFrame", {
            Position = UDim2.new(0, 6, 0, 38),
            Size = UDim2.new(1, -12, 0, 28),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            ScrollingDirection = Enum.ScrollingDirection.X,
        }, win)
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
        }, HUI.tabBar)
    else
        local side = new("Frame", {
            Position = UDim2.new(0, 6, 0, 40), Size = UDim2.new(0, HUI.SIDEW, 1, -46),
            BackgroundColor3 = Color3.fromRGB(21, 16, 36), BorderSizePixel = 0,
        }, win)
        corner(side, 10)
        stroke(side, Color3.fromRGB(60, 46, 96), 1).Transparency = 0.5
        HUI.tabBar = new("ScrollingFrame", {
            Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(1, -8, 1, -8),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, side)
        new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, HUI.tabBar)
        new("UIPadding", { PaddingRight = UDim.new(0, 3) }, HUI.tabBar)
    end

    HUI.registry, HUI.setters = {}, {}
    HUI.searchBox = new("TextBox", {
        Position = IS_MOBILE and UDim2.new(0, 6, 0, 70) or UDim2.new(0, HUI.SIDEW + 14, 0, 40),
        Size = IS_MOBILE and UDim2.new(1, -12, 0, 24) or UDim2.new(1, -(HUI.SIDEW + 20), 0, 26),
        BackgroundColor3 = Color3.fromRGB(30, 24, 48),
        PlaceholderColor3 = Color3.fromRGB(130, 120, 150),
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        TextSize = 12,
    }, win)
    corner(HUI.searchBox, 7)
    HUI.bind(HUI.searchBox, "PlaceholderText", function() return tr("🔍 Buscar función...") end)
    HUI.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = HUI.searchBox.Text:lower()
        for _, r in ipairs(HUI.registry) do
            r.row.Visible = (q == "") or (r.name():lower():find(q, 1, true) ~= nil)
        end
    end)

    HUI.pageHolder = new("Frame", {
        Position = IS_MOBILE and UDim2.new(0, 6, 0, 98) or UDim2.new(0, HUI.SIDEW + 14, 0, 72),
        Size = IS_MOBILE and UDim2.new(1, -12, 1, -104) or UDim2.new(1, -(HUI.SIDEW + 20), 1, -78),
        BackgroundTransparency = 1,
    }, win)

    HUI.pages, HUI.tabButtons, HUI.selectedTab = {}, {}, nil
    function HUI.paintTabs()
        for n, b in pairs(HUI.tabButtons) do
            local sel = (n == HUI.selectedTab)
            b.BackgroundColor3 = sel and HUI.accent or Color3.fromRGB(34, 26, 54)
            b.Font = sel and Enum.Font.GothamBold or Enum.Font.GothamMedium
            b.TextColor3 = sel and Color3.new(1, 1, 1) or Color3.fromRGB(205, 197, 228)
            local ind = b:FindFirstChild("Ind")
            if ind then ind.Visible = sel end
        end
    end
    HUI.onAccent(function() HUI.paintTabs() end)
    function HUI.selectTab(name)
        HUI.selectedTab = name
        for n, p in pairs(HUI.pages) do
            local show = (n == name)
            if show and not p.Visible then
                p.Position = UDim2.new(0, 0, 0, 10)
                TweenService:Create(p, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0, 0, 0, 0) }):Play()
            end
            p.Visible = show
        end
        HUI.paintTabs()
    end

    function HUI.addTab(name, icon)
        local b = new("TextButton", {
            Size = UDim2.new(0, 70, 1, 0),
            BackgroundColor3 = Color3.fromRGB(34, 26, 54),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
        }, HUI.tabBar)
        corner(b, 7)
        pressFx(b)
        HUI.bind(b, "Text", function() return icon .. " " .. tr(name) end)
        b.MouseEnter:Connect(function()
            if HUI.selectedTab ~= name then
                TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(50, 39, 80) }):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            if HUI.selectedTab ~= name then
                TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(34, 26, 54) }):Play()
            end
        end)
        if not IS_MOBILE then
            -- PC: botones de la barra lateral
            b.Size = UDim2.new(1, 0, 0, 30)
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.TextTruncate = Enum.TextTruncate.AtEnd
            new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 6) }, b)
            local ind = new("Frame", {
                Name = "Ind", Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, -9, 0.2, 0),
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Visible = false,
            }, b)
            corner(ind, 2)
        end
        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, HUI.pageHolder)
        HUI.onAccent(function(c) page.ScrollBarImageColor3 = c end)
        new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        new("UIPadding", { PaddingRight = UDim.new(0, 4) }, page)
        HUI.pages[name] = page
        HUI.tabButtons[name] = b
        b.Activated:Connect(function() HUI.selectTab(name) end)
        return page
    end

    ------------------------------------------------------------------
    -- Widgets
    ------------------------------------------------------------------
    function HUI.textFn(t)
        if type(t) == "function" then return t end
        return function() return tr(t) end
    end

    local function Label(page, text, color)
        local l = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = color or Color3.fromRGB(190, 180, 215),
            Font = Enum.Font.Gotham,
            TextSize = 12,
        }, page)
        HUI.bind(l, "Text", HUI.textFn(text))
        return l
    end

    local function Section(page, text)
        local fn = HUI.textFn(text)
        local l = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, page)
        HUI.bind(l, "Text", function() return "▎" .. fn():upper() end)
        local secLine = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = HUI.accent, BorderSizePixel = 0,
        }, l)
        new("UIGradient", { Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }) }, secLine)
        HUI.onAccent(function(c) l.TextColor3 = lighten(c, 0.45) secLine.BackgroundColor3 = c end)
        table.insert(HUI.registry, { row = l, name = fn })
        return l
    end

    local function Toggle(page, name, default, cb)
        local state = default or false
        local row = new("TextButton", {
            Size = UDim2.new(1, 0, 0, ROWH),
            BackgroundColor3 = Color3.fromRGB(30, 24, 48),
            Text = "",
            AutoButtonColor = false,
        }, page)
        corner(row, 8)
        pressFx(row)
        local rowStroke = stroke(row, HUI.accent, 1)
        rowStroke.Transparency = 1
        local nameLbl = new("TextLabel", {
            Size = UDim2.new(1, -56, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
        local fn = HUI.textFn(name)
        HUI.bind(nameLbl, "Text", fn)
        local pill = new("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -46, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(70, 60, 90),
            BorderSizePixel = 0,
        }, row)
        corner(pill, 10)
        local knob = new("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
        }, pill)
        corner(knob, 8)
        local onBar = new("Frame", {
            Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 3, 0, 6),
            BackgroundColor3 = HUI.accent, BackgroundTransparency = 1, BorderSizePixel = 0,
        }, row)
        corner(onBar, 2)

        local function render()
            local ti = TweenInfo.new(0.15)
            TweenService:Create(pill, ti, {
                BackgroundColor3 = state and HUI.accent or Color3.fromRGB(70, 60, 90),
            }):Play()
            TweenService:Create(knob, ti, {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            }):Play()
            TweenService:Create(rowStroke, ti, { Transparency = state and 0.35 or 1 }):Play()
            TweenService:Create(onBar, ti, { BackgroundTransparency = state and 0 or 1 }):Play()
        end
        render()
        HUI.onAccent(function(c)
            rowStroke.Color = c
            onBar.BackgroundColor3 = c
            if state then pill.BackgroundColor3 = c end
        end)
        local function set(v, silent)
            state = v
            render()
            if not silent then
                task.spawn(function()
                    local ok, err = pcall(cb, state)
                    if not ok then warn("[Roshan] " .. fn() .. ": " .. tostring(err)) end
                end)
            end
        end
        row.Activated:Connect(function() set(not state) end)
        if default then set(true) end
        table.insert(HUI.registry, { row = row, name = fn })
        if not default then table.insert(HUI.setters, set) end
        HUI.named = HUI.named or {}
        table.insert(HUI.named, { name = name, set = set, get = function() return state end })
        return set
    end

    local function Button(page, name, cb, color)
        local fn = HUI.textFn(name)
        local b = new("TextButton", {
            Size = UDim2.new(1, 0, 0, ROWH),
            BackgroundColor3 = color or Color3.fromRGB(90, 60, 150), -- color sólido: el texto ya no se tiñe
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            AutoButtonColor = false,
        }, page)
        corner(b, 8)
        pressFx(b)
        sheen(b, 8)
        if not color then
            HUI.onAccent(function(c)
                b.BackgroundColor3 = darken(c, 0.3)
            end)
            stroke(b, Color3.fromRGB(170, 140, 230), 1).Transparency = 0.6
        end
        HUI.bind(b, "Text", fn)
        b.Activated:Connect(function() pcall(cb) end)
        table.insert(HUI.registry, { row = b, name = fn })
        return b
    end

    local function Slider(page, name, min, max, def, cb)
        local fn = HUI.textFn(name)
        local cur = def
        local row = new("Frame", {
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = Color3.fromRGB(30, 24, 48),
        }, page)
        corner(row, 8)
        local lbl = new("TextLabel", {
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.new(0, 10, 0, 4),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
        }, row)
        HUI.bind(lbl, "Text", function() return fn() .. ": " .. cur end)
        local bar = new("Frame", {
            Size = UDim2.new(1, -24, 0, 8),
            Position = UDim2.new(0, 12, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60, 50, 84),
            BorderSizePixel = 0,
        }, row)
        corner(bar, 4)
        local fill = new("Frame", {
            Size = UDim2.new((def - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
        }, bar)
        corner(fill, 4)
        local fillGrad = gradient(fill, lighten(HUI.accent, 0.2), HUI.accent, 0)
        HUI.onAccent(function(c) fillGrad.Color = ColorSequence.new(lighten(c, 0.25), c) end)
        local hit = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            Position = UDim2.new(0, 0, 0.5, -13),
            BackgroundTransparency = 1,
            Text = "",
        }, bar)
        table.insert(HUI.registry, { row = row, name = fn })

        local dragging = false
        local function setFromX(x)
            local t = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local v = math.floor(min + (max - min) * t + 0.5)
            cur = v
            fill.Size = UDim2.new(t, 0, 1, 0)
            lbl.Text = fn() .. ": " .. v
            cb(v)
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(input.Position.X)
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        -- (V7) registro para guardar / cargar el valor en la config
        HUI.sliders = HUI.sliders or {}
        table.insert(HUI.sliders, {
            name = name, get = function() return cur end,
            set = function(v)
                v = math.clamp(math.floor(tonumber(v) or def), min, max)
                cur = v
                fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
                lbl.Text = fn() .. ": " .. v
                cb(v)
            end,
        })
    end

    ------------------------------------------------------------------
    -- Utilidades de juego
    ------------------------------------------------------------------
    local function getChar() return LocalPlayer.Character end
    local function getHRP()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function getHum()
        local c = getChar()
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function getRooms() return workspace:FindFirstChild("CurrentRooms") end

    HST.currentFloor = "Unknown"
    pcall(function()
        local gd = ReplicatedStorage:FindFirstChild("GameData")
        local f = gd and gd:FindFirstChild("Floor")
        if f then HST.currentFloor = tostring(f.Value) end
    end)

    HST.loops = {}
    local function startLoop(key, interval, fn)
        if HST.loops[key] then return end
        HST.loops[key] = task.spawn(function()
            while alive and S[key] do
                local ok, err = pcall(fn)
                if not ok and S.debug then warn("[Roshan:" .. key .. "] " .. tostring(err)) end
                task.wait(interval)
            end
            HST.loops[key] = nil
        end)
    end

    function HESP.promptPos(p)
        local par = p.Parent
        if not par then return nil end
        if par:IsA("BasePart") then return par.Position end
        if par:IsA("Attachment") then return par.WorldPosition end
        if par:IsA("Model") then return par:GetPivot().Position end
    end

    ------------------------------------------------------------------
    -- ESP por candidatos (event-based)
    ------------------------------------------------------------------
    HESP.esp = {
        Door = false, Objective = false, Entity = false, Gold = false,
        Chest = false, Item = false, Hide = false, Player = false, Candy = false, Mines = false,
    }
    HESP.espObjs = {}
    HESP.cands = { Door = {}, Objective = {}, Gold = {}, Chest = {}, Item = {}, Hide = {}, Candy = {}, Mines = {} }
    for k in pairs(HESP.esp) do HESP.espObjs[k] = {} end

    function HESP.addESP(kind, obj, color, text, noHL)
        if not obj or not obj.Parent then return end
        if obj:FindFirstChild("RH_BB_" .. kind) or obj:FindFirstChild("RH_HL_" .. kind) then return end
        if not noHL then
            local hl = new("Highlight", {
                Name = "RH_HL_" .. kind,
                FillColor = color,
                OutlineColor = color,
                FillTransparency = 0.6,
                OutlineTransparency = 0,
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            }, obj)
            table.insert(HESP.espObjs[kind], hl)
        end
        if text then
            local adornee = obj
            if obj:IsA("Model") then
                adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true) or obj
            end
            local bb = new("BillboardGui", {
                Name = "RH_BB_" .. kind,
                Adornee = adornee,
                AlwaysOnTop = true,
                Size = UDim2.new(0, 90, 0, 20),
                StudsOffset = Vector3.new(0, 2, 0),
                MaxDistance = 250,
            }, obj)
            new("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = color,
                TextStrokeTransparency = 0,
                TextScaled = true,
                Font = Enum.Font.GothamBold,
            }, bb)
            table.insert(HESP.espObjs[kind], bb)
        end
    end

    function HESP.clearESP(kind)
        for _, o in ipairs(HESP.espObjs[kind]) do
            if o and o.Parent then o:Destroy() end
        end
        HESP.espObjs[kind] = {}
    end

    function HESP.cand(kind, obj, color, text, noHL)
        if HESP.cands[kind][obj] then return end
        HESP.cands[kind][obj] = { color, text, noHL }
        obj.AncestryChanged:Connect(function()
            if not obj:IsDescendantOf(workspace) then HESP.cands[kind][obj] = nil end
        end)
        if HESP.esp[kind] then HESP.addESP(kind, obj, color, text, noHL) end
    end

    ------------------------------------------------------------------
    -- Entidades
    ------------------------------------------------------------------
    HCOL.RED, HCOL.ORG, HCOL.PUR, HCOL.BLU = Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 120, 30),
        Color3.fromRGB(160, 60, 255), Color3.fromRGB(60, 130, 255)
    HCOL.GRN, HCOL.YEL = Color3.fromRGB(90, 220, 120), Color3.fromRGB(255, 220, 90)
    HANTI.ENT = {
        -- Hotel
        RushMoving   = { n = "RUSH", c = HCOL.RED, k = "danger", m = "⚠️ ¡RUSH viene! Escóndete YA", pass = "✅ Rush ya pasó" },
        AmbushMoving = { n = "AMBUSH", c = HCOL.ORG, k = "danger", m = "⚠️ ¡AMBUSH! Volverá varias veces", pass = "✅ Ambush se fue (puede volver)" },
        Eyes         = { n = "EYES", c = HCOL.PUR, k = "danger", m = "👁️ ¡EYES! No lo mires", pass = "✅ Eyes desapareció" },
        Halt         = { n = "HALT", c = HCOL.BLU, k = "warn", m = "🔵 HALT: date la vuelta cuando aparezca" },
        Seek         = { n = "SEEK", c = Color3.fromRGB(30, 30, 30), k = "danger", m = "⚫ ¡SEEK! Corre y esquiva", pass = "✅ Seek terminó", cd = 45 },
        FigureRig    = { n = "FIGURE", c = HCOL.RED, k = "danger", m = "👹 FIGURE en la sala: muévete en silencio" },
        Timothy      = { n = "TIMOTHY", c = HCOL.PUR, k = "warn", m = "🕷 TIMOTHY: cuidado con los cajones" },
        -- Mines
        GiggleRig    = { n = "GIGGLE", c = Color3.fromRGB(255, 80, 150), k = "warn", m = "😈 GIGGLE cerca" },
        GrumbleRig   = { n = "GRUMBLE", c = Color3.fromRGB(150, 40, 150), k = "danger", m = "👾 GRUMBLE: aléjate de la reina" },
        Gloombat     = { n = "GLOOMBAT", c = HCOL.PUR, k = "warn", m = "🦇 GLOOMBAT cerca" },
        Snare        = { n = "SNARE", c = HCOL.RED, silent = true },
        -- Backdoor
        Haste        = { n = "HASTE", c = HCOL.ORG, k = "danger", m = "⏱ HASTE: ¡corre, el tiempo corre!" },
        Blitz        = { n = "BLITZ", c = HCOL.BLU, k = "warn", m = "⚡ BLITZ apareció" },
        Lookman      = { n = "LOOKMAN", c = HCOL.PUR, k = "danger", m = "👀 LOOKMAN: no lo mires" },
        -- Outdoors (nombres internos sin confirmar)
        Bramble      = { n = "BRAMBLE", c = HCOL.GRN, k = "warn", m = "🌿 BRAMBLE cerca" },
        Caws         = { n = "CAWS", c = HCOL.ORG, k = "warn", m = "🐦 CAWS cerca" },
        Eyestalk     = { n = "EYESTALK", c = HCOL.PUR, k = "danger", m = "👁 EYESTALK: no lo mires" },
        Grampy       = { n = "GRAMPY", c = HCOL.YEL, k = "info", m = "🧓 GRAMPY apareció" },
        Groundskeeper = { n = "GROUNDSKEEPER", c = HCOL.RED, k = "danger", m = "🧑‍🌾 GROUNDSKEEPER: cuidado con los cobertizos" },
        Mandrake     = { n = "MANDRAKE", c = HCOL.GRN, k = "warn", m = "🌱 MANDRAKE cerca" },
        Monument     = { n = "MONUMENT", c = HCOL.BLU, k = "info", m = "🗿 MONUMENT apareció" },
        Surge        = { n = "SURGE", c = HCOL.YEL, k = "warn", m = "⚡ SURGE cerca" },
        WorldLotus   = { n = "WORLD LOTUS", c = Color3.fromRGB(255, 120, 200), k = "info", m = "🪷 WORLD LOTUS apareció" },
        -- The Archives (nombres internos sin confirmar; usa Debug)
        Honcho       = { n = "HONCHO", c = HCOL.ORG, k = "danger", m = "📎 HONCHO (jefe de Archives) apareció" },
        Drone        = { n = "DRONE", c = HCOL.BLU, k = "warn", m = "🛸 DRONE cerca: cuida cómo te mueves" },
        Teller       = { n = "TELLER", c = HCOL.YEL, k = "warn", m = "🎫 TELLER: atiende su pedido" },
        Alma         = { n = "ALMA", c = HCOL.PUR, k = "warn", m = "🕯 ALMA detectada" },
        Noise        = { n = "NOISE", c = HCOL.ORG, k = "warn", m = "🔊 NOISE: no hagas ruido" },
        Creak        = { n = "CREAK", c = HCOL.ORG, k = "warn", m = "🪵 CREAK cerca" },
        Creek        = { n = "CREEK", c = HCOL.ORG, k = "warn", m = "🪵 CREAK cerca" },
        Stem         = { n = "STEM", c = HCOL.GRN, k = "info", m = "🌱 STEM apareció" },
        Portrait     = { n = "PORTRAIT", c = HCOL.PUR, k = "warn", m = "🖼 PORTRAIT: no copies sus movimientos" },
        Fih          = { n = "FIH", c = HCOL.BLU, k = "info", m = "🐟 FIH apareció" },
        ForgetMeNot  = { n = "FORGET-ME-NOT", c = HCOL.PUR, k = "warn", m = "🌸 FORGET-ME-NOT apareció" },
        Bash         = { n = "BASH", c = HCOL.RED, k = "danger", m = "💥 BASH viene (antes A-60)" },
        Ransom       = { n = "RANSOM", c = HCOL.RED, k = "danger", m = "💣 RANSOM: QUÉDATE QUIETO, no te muevas" },
        Scribbles    = { n = "SCRIBBLES", c = HCOL.RED, k = "danger", m = "✏️ SCRIBBLES: escóndete en un closet" },
        Discoloration = { n = "DISCOLORATION", c = Color3.fromRGB(255, 120, 200), k = "warn", m = "🌈 DISCOLORATION cerca" },
        Currents     = { n = "CURRENTS", c = HCOL.BLU, k = "warn", m = "🌊 CURRENTS: cuidado con la corriente" },
        A60          = { n = "A-60", c = HCOL.RED, k = "danger", m = "💥 BASH viene (antes A-60)" },
        A90          = { n = "A-90", c = HCOL.RED, k = "danger", m = "💣 RANSOM: QUÉDATE QUIETO, no te muevas" },
        A120         = { n = "A-120", c = HCOL.RED, k = "danger", m = "✏️ SCRIBBLES: escóndete en un closet" },
        Dread        = { n = "DREAD", c = HCOL.RED, k = "warn", m = "😨 DREAD: no te quedes mucho tiempo en la sala" },
        GloombatEgg  = { n = "GLOOMBAT EGG", c = HCOL.ORG, k = "warn", m = "🥚 Huevo de Gloombat: no lo pises" },
        -- Candy Vault (The Hollow, 22 oct)
        SirAbe       = { n = "SIR ABE C. II", c = HCOL.RED, k = "danger", m = "🎩 SIR ABE C. II te sigue: mírale para espantarlo" },
        Socker       = { n = "SOCKER", c = HCOL.ORG, k = "warn", m = "🧦 SOCKER cerca: detecta tus dulces" },
        -- V8: Rooms / Backdoor / Hotel (antes solo estaban en el mapa del Auto Godmode)
        Glitch       = { n = "GLITCH", c = HCOL.PUR, k = "danger", m = "🌀 GLITCH: avanza a la siguiente sala o escóndete", pass = "✅ Glitch se fue" },
        GlitchRush   = { n = "GLITCH", c = HCOL.PUR, k = "danger", m = "🌀 GLITCH: avanza a la siguiente sala o escóndete", pass = "💥 Glitch Rush se fue" },
        GlitchAmbush = { n = "GLITCH", c = HCOL.PUR, k = "danger", m = "🌀 GLITCH: avanza a la siguiente sala o escóndete", pass = "💥 Glitch Ambush se fue" },
        Screech      = { n = "SCREECH", c = HCOL.PUR, k = "warn", m = "😈 SCREECH: escucha el shhh y míralo rápido" },
    }
    HANTI.entKeyCache = {}
    function HANTI.entKey(name)
        local c = HANTI.entKeyCache[name]
        if c then return c end
        local r = name
        if name:sub(1, 4) == "Seek" then
            r = "Seek"
        else
            local ln = name:lower()
            if ln:find("creakstopher", 1, true) or ln:find("sirabe", 1, true) then r = "SirAbe"
            elseif ln == "socker" then r = "Socker" end
        end
        HANTI.entKeyCache[name] = r
        return r
    end

    HANTI.seenEnt = setmetatable({}, { __mode = "k" })
    HANTI.hooked = setmetatable({}, { __mode = "k" })
    HANTI.activeEnts = {}
    HANTI.lastNotif, HANTI.lastPass = {}, {}
    HANTI.stats = { ents = 0, gold = 0 }

    function HANTI.onEntity(inst)
        local def = HANTI.ENT[HANTI.entKey(inst.Name)]
        if not def then return end
        if HESP.esp.Entity then HESP.addESP("Entity", inst, def.c, def.n) end
        if not def.silent and not HANTI.seenEnt[inst] then
            HANTI.seenEnt[inst] = true
            HANTI.activeEnts[inst] = def
            HANTI.stats.ents = HANTI.stats.ents + 1
            -- (V8) registro de entidades: hora, nombre, piso y sala (boton de copiar en Anti)
            HST.entLog = HST.entLog or {}
            if #HST.entLog < 400 then
                local room = "?"
                pcall(function() if HNET.latestRoom then room = tostring(HNET.latestRoom()) end end)
                table.insert(HST.entLog, os.date("%H:%M:%S") .. "  " .. def.n .. "  (" .. tostring(HST.currentFloor) .. " • " .. room .. ")")
            end
            if S.autoHide and S.hideNames[def.n] and S.onDanger then pcall(S.onDanger, def) end
            local now = tick()
            if S.notify and (not HANTI.lastNotif[def.n] or now - HANTI.lastNotif[def.n] > (def.cd or 3)) then
                HANTI.lastNotif[def.n] = now
                notify(def.m, def.k, 6)
            end
        end
        if not HANTI.hooked[inst] then
            HANTI.hooked[inst] = true
            inst.AncestryChanged:Connect(function()
                if not inst:IsDescendantOf(workspace) then
                    HANTI.activeEnts[inst] = nil
                    if def.pass and alive and S.notify then
                        -- Seek crea muchas partes: solo avisamos cuando ya no queda ninguna viva
                        for other, od in pairs(HANTI.activeEnts) do
                            if od.n == def.n and other.Parent then return end
                        end
                        local nowp = tick()
                        if not HANTI.lastPass[def.n] or nowp - HANTI.lastPass[def.n] > 8 then
                            HANTI.lastPass[def.n] = nowp
                            notify(def.pass, "ok", 3)
                        end
                    end
                end
            end)
        end
    end

    ------------------------------------------------------------------
    -- Filtros anti (por evento + un pase único al activar)
    ------------------------------------------------------------------
    HANTI.disabledParts = {}
    function HANTI.disablePart(part)
        if part:IsA("BasePart") and part.CanTouch then
            part.CanTouch = false
            table.insert(HANTI.disabledParts, part)
        end
    end
    function HANTI.restoreParts(pred)
        local keep = {}
        for _, p in ipairs(HANTI.disabledParts) do
            if p and p.Parent and (not pred or pred(p)) then
                p.CanTouch = true
                p.CanQuery = true
            elseif p and p.Parent then
                table.insert(keep, p)
            end
        end
        HANTI.disabledParts = keep
    end

    -- Modelos "fantasma": sin toque ni colisión (Anti Drones / Anti Forget-Me-Not)
    HANTI.ghostOrig = setmetatable({}, { __mode = "k" })
    function HANTI.ghostTag(inst)
        local ln = inst.Name:lower()
        if S.antiDrone and ln:find("drone", 1, true) then return "drone" end
        if S.antiGrumble and ln:find("grumble", 1, true) then return "grumble" end
        if S.antiCurrents and (ln:find("current", 1, true) or ln:find("puddle", 1, true)) then return "current" end
        if S.antiFMN and (ln:find("forgetmenot", 1, true) or ln:find("forget-me-not", 1, true)
            or ln:find("forget me not", 1, true)) then return "fmn" end
    end
    function HANTI.ghostModel(inst, tag)
        -- los charcos (current) conservan la colisión: solo se apaga el contacto (si no, te caerías del piso)
        local keepCollide = (tag == "current")
        local function one(part)
            if HANTI.ghostOrig[part] == nil then
                HANTI.ghostOrig[part] = { part.CanTouch, part.CanCollide, tag }
                part.CanTouch = false
                if not keepCollide then part.CanCollide = false end
            end
        end
        if inst:IsA("BasePart") then one(inst) end
        for _, part in ipairs(inst:GetDescendants()) do
            if part:IsA("BasePart") then one(part) end
        end
    end
    function HANTI.restoreGhost(tag)
        for part, o in pairs(HANTI.ghostOrig) do
            if part and part.Parent and o[3] == tag then
                pcall(function() part.CanTouch = o[1] part.CanCollide = o[2] end)
                HANTI.ghostOrig[part] = nil
            end
        end
    end

    -- seguimiento de Drones (aviso de stampede + auto-apartarse)
    HANTI.drone = { set = {}, times = {}, stamp = 0 }
    function HANTI.droneSeen(inst)
        HANTI.drone.set[inst] = true
        local now = tick()
        table.insert(HANTI.drone.times, now)
        while #HANTI.drone.times > 0 and now - HANTI.drone.times[1] > 3 do table.remove(HANTI.drone.times, 1) end
        if #HANTI.drone.times >= 5 and now - HANTI.drone.stamp > 25 then
            HANTI.drone.stamp = now
            notify("🛸 ¡STAMPEDE de Drones! Sal del pasillo central o escóndete", "danger", 5)
        end
    end

    -- V8: deteccion de Seek Wall por nombre/atributo (antes solo "ScaryWall" exacto) + re-aplicado
    function HANTI.isSeekWall(inst)
        if not (inst:IsA("Model") or inst:IsA("BasePart")) then return false end
        local ln = inst.Name:lower()
        if ln:find("scarywall", 1, true) or ln:find("seekwall", 1, true) or ln:find("seekingwall", 1, true) then return true end
        if ln:find("wall", 1, true) and (ln:find("seek", 1, true) or ln:find("scary", 1, true)
            or ln:find("kill", 1, true) or ln:find("chase", 1, true)) then return true end
        local lm = inst:GetAttribute("LoadModule")
        return lm == "ScaryWall" or lm == "SeekWall"
    end
    HANTI.wallConn = setmetatable({}, { __mode = "k" })
    function HANTI.keepWallGhost(inst)
        local function watch(part)
            if not part:IsA("BasePart") or HANTI.wallConn[part] then return end
            HANTI.wallConn[part] = part:GetPropertyChangedSignal("CanTouch"):Connect(function()
                if S.bpWall and part.CanTouch then part.CanTouch = false end
            end)
        end
        watch(inst)
        for _, d in ipairs(inst:GetDescendants()) do watch(d) end
    end

    -- V6.2: bypass pack (Banana / Jeff / Lava / Seeking Wall / Vacuum). Se llama desde applyAnti.
    S.v62Apply = function(inst)
        local n = inst.Name
        if S.bpBanana and n == "BananaPeel" then
            if inst:IsA("BasePart") then HANTI.disablePart(inst) end
            for _, part in ipairs(inst:GetDescendants()) do HANTI.disablePart(part) end
        elseif S.bpJeff and n == "JeffTheKiller" then
            HANTI.ghostModel(inst, "bpjeff")
        elseif S.bpKill and n == "Lava" then
            if inst:IsA("BasePart") then HANTI.disablePart(inst) end
            for _, part in ipairs(inst:GetDescendants()) do HANTI.disablePart(part) end
        elseif S.bpWall and (n == "ScaryWall" or HANTI.isSeekWall(inst)
            or (inst:IsA("BasePart") and inst.Parent and HANTI.isSeekWall(inst.Parent))) then
            HANTI.ghostModel(inst, "bpwall")
            HANTI.keepWallGhost(inst)
        elseif S.bpVacuum and n == "SideroomSpace" then
            local col = inst:FindFirstChild("Collision")
            if col and col:IsA("BasePart") then
                if HANTI.ghostOrig[col] == nil then HANTI.ghostOrig[col] = { col.CanTouch, col.CanCollide, "bpvac" } end
                col.CanTouch = false
                col.CanCollide = true
            end
        end
    end

    function HANTI.applyAnti(inst)
        if S.bpAny and S.v62Apply then S.v62Apply(inst) end
        local n = inst.Name
        if S.antiSeek and (inst:IsA("Model") or inst:IsA("BasePart")) then
            local ln = n:lower()
            if ln:find("seek", 1, true) and (ln:find("arm", 1, true) or ln:find("hand", 1, true)) then
                HANTI.disablePart(inst)
                for _, part in ipairs(inst:GetDescendants()) do HANTI.disablePart(part) end
            end
        end
        if n == "Hitbox" then
            local pn = inst.Parent and inst.Parent.Name
            if (S.noSnare and pn == "Snare") or (S.antiGiggle and pn == "GiggleCeiling")
                or (S.antiTimothy and pn == "Timothy")
                or (S.antiDrone and pn and pn:lower():find("drone", 1, true)) then
                HANTI.disablePart(inst)
            end
        elseif n == "Collision" then
            if S.objBypass and inst.Parent and inst.Parent.Name == "ChandelierObstruction" then
                HANTI.disablePart(inst)
                inst.CanQuery = false
            end
        elseif n == "DoorFake" then
            if S.antiDupe and inst:IsA("Model") then
                for _, part in ipairs(inst:GetDescendants()) do HANTI.disablePart(part) end
            end
        elseif n == "FigureRig" then
            -- Figure God Mode (experimental): quita el contacto físico del Figure
            if S.figureGod and inst:IsA("Model") then
                for _, part in ipairs(inst:GetDescendants()) do HANTI.disablePart(part) end
            end
        elseif (S.antiDrone or S.antiFMN or S.antiGrumble or S.antiCurrents)
            and (inst:IsA("Model") or (S.antiCurrents and inst:IsA("BasePart"))) and HANTI.ghostTag(inst) then
            local tag = HANTI.ghostTag(inst)
            HANTI.ghostModel(inst, tag)
            if tag == "drone" then HANTI.droneSeen(inst) end
        elseif (S.objBypass or S.antiSeek) and inst:IsA("Model") and inst:GetAttribute("LoadModule") == "AnimatedObstacleKill" then
            for _, part in ipairs(inst:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch then
                    part.CanTouch = false
                    part.CanQuery = false
                    table.insert(HANTI.disabledParts, part)
                end
            end
        end
    end

    function HANTI.fullPass()
        for _, o in ipairs(workspace:GetChildren()) do pcall(HANTI.applyAnti, o) end
        local rooms = getRooms()
        if not rooms then return end
        task.spawn(function()
            local i = 0
            for _, d in ipairs(rooms:GetDescendants()) do
                pcall(HANTI.applyAnti, d)
                i = i + 1
                if i % 400 == 0 then task.wait() end
            end
        end)
    end

    ------------------------------------------------------------------
    -- Prompts + candidatos
    ------------------------------------------------------------------
    HESP.prompts, HESP.lootPrompts = {}, {}
    HESP.couchPrompts, HESP.hidePrompts = {}, {}
    function HESP.applyPrompt(p)
        local d = p:GetAttribute("RH_dist")
        local h = p:GetAttribute("RH_hold")
        if d then p.MaxActivationDistance = d + S.reach end
        if h then p.HoldDuration = S.instant and 0 or h end
    end
    function HESP.refreshPrompts()
        for p in pairs(HESP.prompts) do
            if p.Parent then HESP.applyPrompt(p) end
        end
    end

    ------------------------------------------------------------------
    -- Auto Interact inteligente (sillas / sofás / objetos que se cargan)
    -- - Detecta por texto del prompt ("Sit", "Carry"...) y por nombre del modelo
    -- - No vuelve a sentarte: pausa unos segundos al levantarte
    -- - Aprende solo: si un prompt te sienta o te hace cargar algo, lo ignora
    ------------------------------------------------------------------
    HESP.carryPrompts = {}
    HESP.badNames = {}
    HESP.badPrompts = setmetatable({}, { __mode = "k" })
    HESP.seatNames = { "chair", "silla", "stool", "banco", "bench", "couch", "sofa", "sofá",
        "armchair", "sillón", "sillon", "seat", "throne", "trono" }
    HESP.seatWords = { "%f[%a]sit%f[%A]", "sentar", "%f[%a]seat%f[%A]", "siént", "sient" }
    HESP.carryWords = { "%f[%a]carry", "llevar", "cargar", "%f[%a]drag", "arrastr",
        "%f[%a]lift", "put down", "soltar" }
    HESP.actCache = {}
    function HESP.actKind(txt)
        local k = HESP.actCache[txt]
        if k ~= nil then return k end
        k = false
        for _, w in ipairs(HESP.seatWords) do
            if txt:find(w) then k = "seat" break end
        end
        if not k then
            for _, w in ipairs(HESP.carryWords) do
                if txt:find(w) then k = "carry" break end
            end
        end
        HESP.actCache[txt] = k
        return k
    end

    function HESP.registerPrompt(p)
        if HESP.prompts[p] then return end
        HESP.prompts[p] = true
        p:SetAttribute("RH_dist", p.MaxActivationDistance)
        p:SetAttribute("RH_hold", p.HoldDuration)
        HESP.applyPrompt(p)
        local model = p:FindFirstAncestorOfClass("Model")
        -- Sofás / asientos: Auto Interact los ignora (te sentaba y perdías tiempo)
        do
            local txt = (p.ActionText or ""):lower()
            local kind = HESP.actKind(txt)
            local isCouch = (kind == "seat")
            if kind == "carry" then HESP.carryPrompts[p] = true end
            local cur, depth = p.Parent, 0
            while not isCouch and cur and cur ~= workspace and depth < 4 do
                local n = cur.Name:lower()
                for _, w in ipairs(HESP.seatNames) do
                    if n:find(w, 1, true) then isCouch = true break end
                end
                cur = cur.Parent
                depth = depth + 1
            end
            if isCouch then HESP.couchPrompts[p] = true end
        end
        if model then
            if p.Name == "ModulePrompt" then
                HESP.cand("Item", model, Color3.fromRGB(120, 220, 255), model.Name, true)
            end
            if (p.ActionText or ""):lower():find("hide") then
                HESP.cand("Hide", model, Color3.fromRGB(150, 255, 150), "Hide", true)
                HESP.hidePrompts[p] = model
            end
            if model.Name == "GoldPile" or model.Name == "MoneyBag" then
                HESP.lootPrompts[p] = true
            end
        end
        p.AncestryChanged:Connect(function()
            if not p:IsDescendantOf(workspace) then
                HESP.prompts[p] = nil
                HESP.lootPrompts[p] = nil
                HESP.couchPrompts[p] = nil
                HESP.carryPrompts[p] = nil
                HESP.hidePrompts[p] = nil
            end
        end)
    end

    -- true = Auto Interact / Auto Proxi deben ignorar este prompt
    function HESP.seatLock()
        local now = tick()
        if now - (HESP.seatChk or 0) < 0.1 then return HESP.seatLockV end
        HESP.seatChk = now
        local hum = getHum()
        if hum and hum.Sit then HESP.lastSit = now end
        HESP.seatLockV = (now - (HESP.lastSit or -100)) < 2.5
        return HESP.seatLockV
    end
    function HESP.skipPrompt(p)
        if S.noResit ~= false and HESP.seatLock() then return true end
        if HESP.badPrompts[p] then return true end
        if S.skipCouch and HESP.couchPrompts[p] then return true end
        if S.skipCarry ~= false and HESP.carryPrompts[p] then return true end
        local kind = HESP.actKind((p.ActionText or ""):lower())
        if kind == "seat" and S.skipCouch then return true end
        if kind == "carry" and S.skipCarry ~= false then return true end
        local model = p:FindFirstAncestorOfClass("Model")
        if model and HESP.badNames[model.Name] then return true end
        return false
    end
    -- dispara el prompt y comprueba si te sentó o te hizo cargar algo (entonces lo aprende)
    function HESP.fireSmart(p)
        fireproximityprompt(p)
        if S.learnBad == false then return end
        task.delay(0.7, function()
            if not alive then return end
            local hum, ch = getHum(), getChar()
            if not (hum and ch and p) then return end
            local model = p:FindFirstAncestorOfClass("Model")
            local bad = hum.Sit or (hum.SeatPart ~= nil)
                or (model and model ~= ch and model:IsDescendantOf(ch))
            if not bad then return end
            HESP.badPrompts[p] = true
            local rooms = getRooms()
            if model and model.Parent ~= rooms and not tonumber(model.Name) and not HESP.badNames[model.Name] then
                HESP.badNames[model.Name] = true
                notify("🪑 Auto Interact: ignoraré «%s»", "info", 3, model.Name)
            end
        end)
    end

    ------------------------------------------------------------------
    -- Bridge Saver (Mines: persecución de Seek)
    -- Vigila partes llamadas "bridge/plank/puente" y, cuando se rompen
    -- (se destruyen, pierden colisión o se vuelven invisibles), crea un
    -- bloque verde neón en su lugar para que no te caigas.
    ------------------------------------------------------------------
    HESP.bridgeTracked = setmetatable({}, { __mode = "k" })
    HESP.saverParts = {}
    function HESP.makeSaver(cf, size)
        if not alive then return end
        -- tamaño mínimo para que siempre se pueda pisar
        local sz = Vector3.new(math.max(size.X, 6), math.clamp(size.Y, 0.6, 2), math.max(size.Z, 6))
        local p = new("Part", {
            Name = "RH_BridgeSaver", Anchored = true, CanCollide = true, CanQuery = false,
            CanTouch = false, Material = Enum.Material.Neon, Color = Color3.fromRGB(60, 255, 110),
            Transparency = 0.3, Size = sz, CFrame = cf, CastShadow = false,
        }, workspace)
        table.insert(HESP.saverParts, p)
        Debris:AddItem(p, 40)
        TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Transparency = 0.55 }):Play()
        notify("🌉 Puente roto: bloque verde creado", "ok", 2)
    end
    function HESP.isBridgeName(n)
        n = n:lower()
        return n:find("bridge", 1, true) or n:find("puente", 1, true) or n:find("plank", 1, true)
    end
    function HESP.trackBridgePart(part)
        if HESP.bridgeTracked[part] then return end
        HESP.bridgeTracked[part] = true
        local cf, size = part.CFrame, part.Size
        local fired = false
        local function broke()
            if fired or not S.bridgeSaver then return end
            fired = true
            HESP.makeSaver(cf, size)
        end
        part.AncestryChanged:Connect(function()
            if not part:IsDescendantOf(workspace) then broke() end
        end)
        part:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if not part.CanCollide then broke() end
        end)
        part:GetPropertyChangedSignal("Transparency"):Connect(function()
            if part.Transparency >= 0.95 then broke() end
        end)
        part:GetPropertyChangedSignal("Anchored"):Connect(function()
            -- al romperse el puente suele soltarse y caer
            if not part.Anchored then broke() end
        end)
    end
    function HESP.trackBridge(inst)
        if not HESP.isBridgeName(inst.Name) then return end
        if inst:IsA("BasePart") then
            HESP.trackBridgePart(inst)
        elseif inst:IsA("Model") then
            for _, d in ipairs(inst:GetDescendants()) do
                if d:IsA("BasePart") and d.Size.Magnitude > 3 then HESP.trackBridgePart(d) end
            end
        end
    end
    onCleanup(function()
        for _, p in ipairs(HESP.saverParts) do if p and p.Parent then p:Destroy() end end
        HESP.saverParts = {}
    end)

    HESP.OBJ = {
        KeyObtain = { Color3.fromRGB(255, 255, 0), "🔑 Key" },
        FuseObtain = { Color3.fromRGB(255, 200, 0), "⚡ Fuse" },
        FuseHolder = { Color3.fromRGB(255, 200, 0), "⚡ Fuse" },
        LiveHintBook = { Color3.fromRGB(255, 255, 0), "📖 Book" },
        LeverForGate = { Color3.fromRGB(255, 255, 0), "🔧 Lever" },
        TimerLever = { Color3.fromRGB(255, 255, 0), "⏱ Timer" },
        LiveBreakerPolePickup = { Color3.fromRGB(255, 200, 0), "⚡ Breaker" },
        Valve = { Color3.fromRGB(100, 200, 255), "🔄 Valve" },
        WaterPump = { Color3.fromRGB(100, 200, 255), "🔄 Pump" },
        -- Mines (nombres internos sin confirmar; inofensivo si no existen)
        MinesAnchor = { Color3.fromRGB(120, 255, 200), "⚓ Anchor" },
        MinesGenerator = { Color3.fromRGB(255, 200, 0), "🔋 Generator" },
        GeneratorMain = { Color3.fromRGB(255, 200, 0), "🔋 Generator" },
        MinesGateButton = { Color3.fromRGB(255, 255, 0), "🔘 Button" },
    }

    -- Candy Vault (The Hollow): caramelos, llaves de joyería y calderos (nombres por coincidencia)
    function HESP.candyCheck(inst, n, isModel)
        if #n < 5 then return end
        local ln = n:lower()
        local key
        if ln:find("jewelry", 1, true) then key = "jewelry"
        elseif ln:find("cauldron", 1, true) then key = "cauldron"
        elseif isModel and ln:find("candy", 1, true) then key = "candy" end
        if not key then return end
        if not isModel and inst.Parent and inst.Parent.Name:lower():find(key, 1, true) then return end
        if key == "jewelry" then
            HESP.cand("Candy", inst, Color3.fromRGB(255, 215, 0), "🗝 Jewelry Key")
        elseif key == "cauldron" then
            HESP.cand("Candy", inst, Color3.fromRGB(80, 255, 120), "🧪 Cauldron")
        else
            HESP.cand("Candy", inst, Color3.fromRGB(255, 120, 200), "🍬 Candy")
        end
    end
    function HESP.candyRescan()
        local rooms = getRooms()
        if not rooms then return end
        task.spawn(function()
            local i = 0
            for _, d in ipairs(rooms:GetDescendants()) do
                if not alive then return end
                if d:IsA("Model") or d:IsA("BasePart") then pcall(HESP.candyCheck, d, d.Name, d:IsA("Model")) end
                i = i + 1
                if i % 300 == 0 then task.wait() end
            end
        end)
    end

    -- Mines (piso 2): huevos de Gloombat, vagonetas y estalagmitas (por coincidencia de nombre)
    HESP.MinesESP = {}
    function HESP.MinesESP.check(inst, n, isModel)
        if #n < 5 then return end
        local ln = n:lower()
        if isModel and ln:find("egg", 1, true) and ln:find("gloom", 1, true) then
            HESP.cand("Mines", inst, Color3.fromRGB(255, 90, 90), "🥚 Gloombat Egg")
        elseif ln:find("stalagmite", 1, true) then
            HESP.cand("Mines", inst, Color3.fromRGB(255, 160, 60), "⚠️ Stalagmite", true)
        elseif isModel and ln:find("minecart", 1, true) then
            HESP.cand("Mines", inst, Color3.fromRGB(120, 200, 255), "🛒 Minecart")
        end
    end
    function HESP.MinesESP.rescan()
        local rooms = getRooms()
        if not rooms then return end
        task.spawn(function()
            local i = 0
            for _, d in ipairs(rooms:GetDescendants()) do
                if not alive then return end
                if d:IsA("Model") or d:IsA("BasePart") then pcall(HESP.MinesESP.check, d, d.Name, d:IsA("Model")) end
                i = i + 1
                if i % 300 == 0 then task.wait() end
            end
        end)
    end

    -- Número de la puerta (lee el letrero si existe; si no, sala + 1)
    function HESP.doorLabel(door)
        local room = door.Parent
        local rn = room and tonumber(room.Name)
        local num = rn and (rn + 1) or nil
        pcall(function()
            for _, d in ipairs(door:GetDescendants()) do
                if d:IsA("TextLabel") then
                    local digits = d.Text:match("^%s*(%d+)%s*$")
                    if digits then num = tonumber(digits) break end
                end
            end
        end)
        return num and ("🚪 Door " .. num) or "🚪 Door"
    end

    function HESP.onRoomInstance(inst)
        local n = inst.Name
        if S.debug and n:find("Rig") then print("[Roshan debug] room +", n) end

        if inst:IsA("ProximityPrompt") then
            HESP.registerPrompt(inst)
            return
        end

        local isModel = inst:IsA("Model")
        if isModel then HANTI.onEntity(inst) end

        local o = HESP.OBJ[n]
        if o and (isModel or inst:IsA("BasePart")) then
            HESP.cand("Objective", inst, o[1], o[2])
        elseif n == "GoldPile" or n == "MoneyBag" then
            HESP.cand("Gold", inst, Color3.fromRGB(255, 215, 0), "💰 Gold", true)
        elseif isModel and n:sub(1, 5) == "Chest" then
            HESP.cand("Chest", inst, Color3.fromRGB(190, 110, 50), "📦 Chest", true)
        elseif n == "Door" and isModel then
            local rooms = getRooms()
            if rooms and inst.Parent and inst.Parent.Parent == rooms then
                HESP.cand("Door", inst, Color3.fromRGB(0, 255, 120), HESP.doorLabel(inst))
            end
        elseif n == "DoorFake" and isModel then
            HESP.cand("Door", inst, Color3.fromRGB(255, 60, 60), "❌ Fake")
        end

        if S.candyScanOn and (isModel or inst:IsA("BasePart")) then HESP.candyCheck(inst, n, isModel) end
        if S.minesScanOn and (isModel or inst:IsA("BasePart")) then HESP.MinesESP.check(inst, n, isModel) end
        if S.anyAnti then HANTI.applyAnti(inst) end
        if S.bridgeSaver then HESP.trackBridge(inst) end
    end

    task.spawn(function()
        local rooms = workspace:WaitForChild("CurrentRooms", 15)
        if not rooms or not alive then return end
        local i = 0
        for _, d in ipairs(rooms:GetDescendants()) do
            pcall(HESP.onRoomInstance, d)
            i = i + 1
            if i % 400 == 0 then task.wait() end
        end
        track(rooms.DescendantAdded:Connect(function(d)
            pcall(HESP.onRoomInstance, d)
        end))
    end)

    track(workspace.ChildAdded:Connect(function(o)
        if S.debug then print("[Roshan debug] workspace +", o.ClassName, o.Name) end
        HANTI.onEntity(o)
        if S.anyAnti then pcall(HANTI.applyAnti, o) end
    end))

    function HESP.scanEntities()
        for _, o in ipairs(workspace:GetChildren()) do HANTI.onEntity(o) end
        local rooms = getRooms()
        if rooms then
            -- por tandas: antes recorría todo de golpe y congelaba un instante
            task.spawn(function()
                local i = 0
                for _, o in ipairs(rooms:GetDescendants()) do
                    if not alive then return end
                    if o:IsA("Model") and HANTI.ENT[HANTI.entKey(o.Name)] then pcall(HANTI.onEntity, o) end
                    i = i + 1
                    if i % 300 == 0 then task.wait() end
                end
            end)
        end
    end

    function HESP.espPlayer(plr)
        if plr == LocalPlayer then return end
        local c = plr.Character
        if c then HESP.addESP("Player", c, Color3.fromRGB(80, 200, 255), plr.Name) end
    end
    function HESP.hookPlayer(p)
        track(p.CharacterAdded:Connect(function()
            task.wait(1)
            if HESP.esp.Player then HESP.espPlayer(p) end
        end))
    end
    for _, p in ipairs(Players:GetPlayers()) do HESP.hookPlayer(p) end
    track(Players.PlayerAdded:Connect(HESP.hookPlayer))

    local function setESP(kind, on)
        HESP.esp[kind] = on
        if on then
            if kind == "Entity" then
                HESP.scanEntities()
            elseif kind == "Player" then
                for _, p in ipairs(Players:GetPlayers()) do HESP.espPlayer(p) end
            else
                for obj, d in pairs(HESP.cands[kind]) do
                    HESP.addESP(kind, obj, d[1], d[2], d[3])
                end
            end
        else
            HESP.clearESP(kind)
        end
    end

    function HESP.pruneESP()
        for kind, list in pairs(HESP.espObjs) do
            local keep = {}
            for _, o in ipairs(list) do
                if o and o.Parent then table.insert(keep, o) end
            end
            HESP.espObjs[kind] = keep
        end
        for _, set in pairs(HESP.cands) do
            for obj in pairs(set) do
                if not obj:IsDescendantOf(workspace) then set[obj] = nil end
            end
        end
        for p in pairs(HESP.prompts) do
            if not p:IsDescendantOf(workspace) then
                HESP.prompts[p], HESP.lootPrompts[p], HESP.couchPrompts[p] = nil, nil, nil
                HESP.carryPrompts[p], HESP.hidePrompts[p] = nil, nil
            end
        end
    end
    task.spawn(function()
        while alive do
            task.wait(30)
            pcall(HESP.pruneESP)
        end
    end)

    local function refreshAnti()
        S.anyAnti = S.noSnare or S.objBypass or S.antiGiggle or S.antiDupe or S.antiTimothy or S.figureGod
            or S.antiDrone or S.antiFMN or S.antiSeek or S.antiGrumble or S.antiCurrents or S.bpAny or false
    end

    ------------------------------------------------------------------
    -- Módulo de rendimiento compartido (Anti Lag + FPS Booster)
    -- Antes solo escaneaba una vez: el juego volvía a crear efectos y
    -- "no hacía nada". Ahora engancha DescendantAdded mientras esté activo.
    ------------------------------------------------------------------
    local lag = {
        fx = false, boost = false, gen = 0, conn = nil,
        orig = setmetatable({}, { __mode = "k" }),
        mat = setmetatable({}, { __mode = "k" }),
        post = {}, light = nil, quality = nil,
        lsh = setmetatable({}, { __mode = "k" }),
    }
    HLAG.SKIP_MAT = {
        [Enum.Material.SmoothPlastic] = true, [Enum.Material.Neon] = true,
        [Enum.Material.Glass] = true, [Enum.Material.ForceField] = true,
    }
    function HLAG.lagApply(d)
        if lag.fx and (d:IsA("ParticleEmitter") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles")
            or d:IsA("Trail") or d:IsA("Beam")) then
            if lag.orig[d] == nil then lag.orig[d] = d.Enabled end
            d.Enabled = false
        elseif lag.fx and (d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")) then
            -- las sombras de las luces son lo que más pesa
            if lag.lsh[d] == nil then lag.lsh[d] = d.Shadows end
            d.Shadows = false
        elseif lag.boost and d:IsA("BasePart") then
            local rooms = lag.rooms or getRooms()
            if rooms and not HLAG.SKIP_MAT[d.Material] and lag.mat[d] == nil and d:IsDescendantOf(rooms) then
                lag.mat[d] = { d.Material, d.CastShadow }
                d.Material = Enum.Material.SmoothPlastic
                d.CastShadow = false
            end
        end
    end
    function HLAG.lagScan()
        lag.gen = lag.gen + 1
        local gen = lag.gen
        lag.rooms = getRooms()
        task.spawn(function()
            local i = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                if gen ~= lag.gen or not alive then return end
                pcall(HLAG.lagApply, d)
                i = i + 1
                if i % 250 == 0 then task.wait() end
            end
        end)
    end
    function HLAG.lagSync()
        if (lag.fx or lag.boost) and not lag.conn then
            lag.conn = workspace.DescendantAdded:Connect(function(d)
                if alive then pcall(HLAG.lagApply, d) end
            end)
        elseif not (lag.fx or lag.boost) and lag.conn then
            lag.conn:Disconnect()
            lag.conn = nil
        end
    end
    function HLAG.lagRestoreFx()
        for inst, v in pairs(lag.orig) do
            if inst and inst.Parent then pcall(function() inst.Enabled = v end) end
        end
        lag.orig = setmetatable({}, { __mode = "k" })
        for inst, v in pairs(lag.lsh) do
            if inst and inst.Parent then pcall(function() inst.Shadows = v end) end
        end
        lag.lsh = setmetatable({}, { __mode = "k" })
    end
    function HLAG.lagRestoreBoost()
        for part, v in pairs(lag.mat) do
            if part and part.Parent then
                pcall(function() part.Material = v[1] part.CastShadow = v[2] end)
            end
        end
        lag.mat = setmetatable({}, { __mode = "k" })
        if lag.light then
            pcall(function() Lighting.GlobalShadows = lag.light.shadows end)
            lag.light = nil
        end
        for fx, v in pairs(lag.post) do
            if fx and fx.Parent then pcall(function() fx.Enabled = v end) end
        end
        lag.post = {}
        if lag.quality then
            pcall(function() settings().Rendering.QualityLevel = lag.quality end)
            lag.quality = nil
        end
    end
    function HLAG.setLagFx(on)
        lag.fx = on
        HLAG.lagSync()
        if on then HLAG.lagScan() else HLAG.lagRestoreFx() end
    end
    function HLAG.setBoost(on)
        lag.boost = on
        HLAG.lagSync()
        if on then
            lag.light = { shadows = Lighting.GlobalShadows }
            pcall(function() Lighting.GlobalShadows = false end)
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("BloomEffect") or fx:IsA("SunRaysEffect") or fx:IsA("DepthOfFieldEffect") then
                    lag.post[fx] = fx.Enabled
                    fx.Enabled = false
                end
            end
            pcall(function()
                lag.quality = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            HLAG.lagScan()
        else
            HLAG.lagRestoreBoost()
        end
    end
    onCleanup(function()
        lag.fx, lag.boost, lag.gen = false, false, lag.gen + 1
        HLAG.lagSync()
        HLAG.lagRestoreFx()
        HLAG.lagRestoreBoost()
    end)

    ------------------------------------------------------------------
    -- Auto Hide (experimental): nombres de entidades que lo disparan
    ------------------------------------------------------------------
    S.hideNames = { ["RUSH"] = true, ["AMBUSH"] = true }
    S.onDanger = function(def)
        task.spawn(function()
            local hrp = getHRP()
            if not hrp then return end
            local best, bd = nil, 60
            for p in pairs(HESP.hidePrompts) do
                if p.Parent and p.Enabled then
                    local pos = HESP.promptPos(p)
                    if pos then
                        local d = (hrp.Position - pos).Magnitude
                        if d < bd then best, bd = p, d end
                    end
                end
            end
            if not best then return end
            notify("🫥 Auto Hide: escondiéndote", "info", 2)
            local pos = HESP.promptPos(best)
            if pos and bd > math.max(best.MaxActivationDistance - 1, 3) then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.15)
            end
            pcall(fireproximityprompt, best)
        end)
    end

    ------------------------------------------------------------------
    -- Canje de key VIP / Boost dentro del hub (reconstruye el hub con el nuevo rango)
    ------------------------------------------------------------------
    HNET.KeyUI = {}
    -- (V7) Apagado único (lo usan "Destruir script", el pánico y el canje de key).
    -- Antes solo se soltaban las conexiones "track"; las de cada toggle (workspace.DescendantAdded,
    -- RenderStepped, CharacterAdded...) se quedaban vivas. Ahora se apagan todos los toggles primero.
    function HNET.shutdown()
        if HST.dead then return end
        HST.dead = true
        pcall(function() gui.Enabled = false end) -- se oculta al instante
        for _, set in ipairs(HUI.setters) do pcall(set, false) end -- cada toggle limpia lo suyo
        task.wait(0.25) -- deja correr los callbacks de apagado
        alive = false
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        for _, fn in ipairs(cleanups) do pcall(fn) end
        for k in pairs(S) do
            if type(S[k]) == "boolean" then S[k] = false end
        end
        for kind in pairs(HESP.espObjs) do pcall(HESP.clearESP, kind) end
        for p in pairs(HESP.prompts) do
            if p.Parent then
                local d, h = p:GetAttribute("RH_dist"), p:GetAttribute("RH_hold")
                if d then p.MaxActivationDistance = d end
                if h then p.HoldDuration = h end
            end
        end
        -- soltar referencias para que el GC libere todo
        HESP.prompts, HESP.lootPrompts, HESP.couchPrompts, HESP.hidePrompts, HESP.carryPrompts = {}, {}, {}, {}, {}
        for k in pairs(HESP.cands) do HESP.cands[k] = {} end
        HST.loops = {}
        ANIM_COLLECT = nil
        gui:Destroy()
    end
    HNET.KeyUI.teardown = HNET.shutdown
    function HNET.KeyUI.redeem(text)
        if (text or ""):gsub("%s", "") == "" then return end
        local left = KeyGuard.waitLeft()
        if left > 0 then
            notify("⛔ Demasiados intentos. Espera %ds", "danger", 3, left)
            return
        end
        task.spawn(function()
            local auth, lockSecs = KeyGuard.attempt(text)
            if auth and auth.vip then
                KeyGuard.save(auth)
                notify("✅ ¡Rango activado! Actualizando el hub...", "ok", 3)
                task.wait(0.8)
                HNET.KeyUI.teardown()
                startHub(auth, true)
            elseif lockSecs and lockSecs > 0 then
                notify("⛔ Demasiados intentos. Espera %ds", "danger", 3, lockSecs)
            else
                notify("❌ Esa key no es VIP ni Boost", "danger", 3)
            end
        end)
    end
    function HNET.KeyUI.box(page)
        Section(page, "🔑 Canjear key VIP / Boost")
        local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, page)
        local tb = new("TextBox", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(34, 26, 54),
            TextColor3 = Color3.new(1, 1, 1), PlaceholderColor3 = Color3.fromRGB(130, 120, 150),
            Text = "", ClearTextOnFocus = false, Font = Enum.Font.GothamMedium, TextSize = 13,
        }, row)
        corner(tb, 8)
        HUI.bind(tb, "PlaceholderText", function() return tr("🔑 Escribe tu key VIP o Boost...") end)
        Button(page, "💎 Activar key", function() HNET.KeyUI.redeem(tb.Text) end, Color3.fromRGB(140, 60, 235))
        tb.FocusLost:Connect(function(enter)
            if enter then HNET.KeyUI.redeem(tb.Text) end
        end)
    end

    ------------------------------------------------------------------
    -- ESTADO DEL SCRIPT: usuarios activos y ejecuciones (opcional)
    -- Necesita CONFIG.StatsDB (Firebase Realtime Database). Solo envía un
    -- ID anónimo aleatorio: nada de usuario, ID de Roblox ni ejecutor.
    ------------------------------------------------------------------
    HNET.HttpService = game:GetService("HttpService")
    HNET.httpReq = (syn and syn.request) or request or http_request or (http and http.request)
    HNET.hubStart = os.time()
    local Net = {
        configured = (type(CONFIG.StatsDB) == "string" and CONFIG.StatsDB:match("^https://") ~= nil) and (HNET.httpReq ~= nil), -- (V7) solo https
        state = "off", active = nil, total = nil, unique = nil,
    }
    -- (moved to tables) anonId
    pcall(function()
        if isfile and readfile and isfile(CONFIG.AnonFile) then HNET.anonId = readfile(CONFIG.AnonFile) end
    end)
    if not HNET.anonId or #HNET.anonId < 8 then
        HNET.anonId = HNET.HttpService:GenerateGUID(false):gsub("[^%w]", "")
        pcall(function() if writefile then writefile(CONFIG.AnonFile, HNET.anonId) end end)
    end

    function HNET.dbCall(method, path, body, query)
        if not Net.configured then return nil end
        local base = CONFIG.StatsDB:gsub("/+$", "")
        local ok, res = pcall(HNET.httpReq, {
            Url = base .. "/roshanhub/" .. path .. ".json" .. (query or ""),
            Method = method,
            Headers = { ["Content-Type"] = "application/json" },
            Body = body and HNET.HttpService:JSONEncode(body) or nil,
        })
        if not ok or type(res) ~= "table" then return nil end
        local code = res.StatusCode or 0
        if code < 200 or code >= 300 then return nil end
        local okj, data = pcall(function() return HNET.HttpService:JSONDecode(res.Body) end)
        return { data = okj and data or nil }
    end
    function HNET.refreshStats()
        if not Net.configured then return end
        if not HNET.dbCall("PUT", "active/" .. HNET.anonId, { [".sv"] = "timestamp" }) then
            Net.state = "error"
            return
        end
        local act = HNET.dbCall("GET", "active")
        local tot = HNET.dbCall("GET", "hub/executions")
        local uni = HNET.dbCall("GET", "users", nil, "?shallow=true")
        if act then
            local nowTs, n = 0, 0
            if type(act.data) == "table" then
                for _, ts in pairs(act.data) do
                    if type(ts) == "number" and ts > nowTs then nowTs = ts end
                end
                for _, ts in pairs(act.data) do
                    if type(ts) == "number" and nowTs - ts <= 150000 then n = n + 1 end
                end
            end
            Net.active = n
        end
        if tot then Net.total = tonumber(tot.data) or 0 end
        if uni then
            local c = 0
            if type(uni.data) == "table" then for _ in pairs(uni.data) do c = c + 1 end end
            Net.unique = c
        end
        Net.state = "ok"
    end
    task.spawn(function()
        if not Net.configured then return end
        HNET.dbCall("PATCH", "hub", { executions = { [".sv"] = { increment = 1 } }, lastExec = { [".sv"] = "timestamp" } })
        HNET.dbCall("PATCH", "users/" .. HNET.anonId, { seen = { [".sv"] = "timestamp" } })
        HNET.refreshStats()
        while alive do
            task.wait(60)
            if not alive then break end
            if not HNET.dbCall("PUT", "active/" .. HNET.anonId, { [".sv"] = "timestamp" }) then Net.state = "error" end
        end
    end)
    onCleanup(function()
        if Net.configured then task.spawn(HNET.dbCall, "DELETE", "active/" .. HNET.anonId) end
    end)

    function HNET.latestRoom()
        local rooms = getRooms()
        local best = 0
        if rooms then
            for _, r in ipairs(rooms:GetChildren()) do
                local n = tonumber(r.Name)
                if n and n > best then best = n end
            end
        end
        return best
    end

    -- Tarjeta bonita con título y líneas de texto
    function HUI.Card(page, title, lines, c1, c2)
        local f = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
        }, page)
        corner(f, 10)
        gradient(f, c1, c2, 45)
        stroke(f, lighten(c1, 0.3), 1).Transparency = 0.35
        new("UIPadding", {
            PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        }, f)
        new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, f)
        local t = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBlack,
            TextSize = 16, TextColor3 = Color3.new(1, 1, 1),
        }, f)
        HUI.bind(t, "Text", HUI.textFn(title))
        for _, line in ipairs(lines) do
            local l = new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(245, 240, 255),
            }, f)
            HUI.bind(l, "Text", HUI.textFn(line))
        end
        return f
    end

    -- Botones de Mis Apps (copian el link)
    function HUI.AppsButtons(page)
        Section(page, "Mis Apps")
        for _, s in ipairs(CONFIG.Socials) do
            Button(page, s[1] .. ": " .. s[2], function()
                pcall(function() if setclipboard then setclipboard(s[3]) end end)
                notify("📋 Link copiado: %s", "ok", 2, s[2])
            end, s[4])
        end
    end

    ------------------------------------------------------------------
    -- Pestañas
    ------------------------------------------------------------------
    HPG.pMain = HUI.addTab("Principal", "🏠")
    HPG.pAnti = HUI.addTab("Anti", "🛡")
    HPG.pVis = HUI.addTab("Visual", "👁")
    HPG.pFloor = HUI.addTab("Pisos", "🏨")
    HPG.pProf = HUI.addTab("Perfil", "👤")
    HPG.pStat = HUI.addTab("Estado", "📊")
    HPG.pVip = HUI.addTab("VIP", "💎")
    local hasBoost = (rankName == "Booster") or (rankName == "Staff") -- VIP y Boost son distintos
    HPG.pBoost = HUI.addTab("Boost", "🚀")
    HPG.pDev = isDev and HUI.addTab("Dev", "🛠") or nil
    -- Botones de depuración: solo existen para devs (van a la pestaña Dev)
    function HUI.DevButton(name, cb, color)
        if HPG.pDev then return Button(HPG.pDev, name, cb, color) end
    end
    HPG.pInfo = HUI.addTab("Info", "ℹ️")
    HPG.pCred = HUI.addTab("Créditos", "🌟")
    HPG.pCfg = HUI.addTab("Config", "⚙️")
    S.skipCouch = true

    ------------------------------------------------------------------
    -- PRINCIPAL
    ------------------------------------------------------------------
    do
        Section(HPG.pMain, "Interacción")
        Toggle(HPG.pMain, "Auto Interact", false, function(on)
            S.autoInteract = on
            if on then
                local last = {}
                startLoop("autoInteract", 0.2, function()
                    local hrp = getHRP()
                    if not hrp then return end
                    for p in pairs(HESP.prompts) do
                        if p.Parent and p.Enabled then
                            local pos = HESP.promptPos(p)
                            if pos and (hrp.Position - pos).Magnitude <= p.MaxActivationDistance then
                                local txt = (p.ActionText or ""):lower()
                                if not txt:find("close") and not txt:find("hide")
                                    and not HESP.skipPrompt(p)
                                    and (not last[p] or tick() - last[p] > 0.4) then
                                    last[p] = tick()
                                    HESP.fireSmart(p)
                                end
                            end
                        end
                    end
                end)
            end
        end)

        Toggle(HPG.pMain, "Instant Prompts", false, function(on)
            S.instant = on
            HESP.refreshPrompts()
        end)

        Slider(HPG.pMain, "Prompt Reach", 0, isVip and 24 or 12, 0, function(v)
            S.reach = v
            HESP.refreshPrompts()
        end)

        Section(HPG.pMain, "Movimiento")
        local ncParts, ncWas = {}, {}
        local ncRay = RaycastParams.new()
        ncRay.FilterType = Enum.RaycastFilterType.Exclude
        local function ncRefresh()
            ncParts = {}
            local c = getChar()
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then table.insert(ncParts, part) end
                end
                ncRay.FilterDescendantsInstances = { c }
            end
        end
        local function ncRestore()
            for p in pairs(ncWas) do
                if p.Parent then p.CanCollide = true end
            end
            ncWas = {}
        end
        onCleanup(ncRestore)
        Toggle(HPG.pMain, "Noclip", false, function(on)
            S.noclip = on
            if on then
                if S.ensureAntiSpeed then S.ensureAntiSpeed() end
                ncRefresh()
                startLoop("noclip", 1, ncRefresh) -- por si el personaje cambia o sale un accesorio nuevo
            else
                ncRestore()
            end
        end)
        track(RunService.Stepped:Connect(function()
            if not S.noclip then return end
            for i = 1, #ncParts do
                local p = ncParts[i]
                if p.Parent and p.CanCollide then
                    ncWas[p] = true
                    p.CanCollide = false
                end
            end
            -- piso virtual: sin colisión te hundirías; esto te mantiene a la altura del suelo
            local hrp, hum = getHRP(), getHum()
            if hrp and hum and hum.Health > 0 and not S.fly then
                local v = hrp.AssemblyLinearVelocity
                local res = workspace:Raycast(hrp.Position, Vector3.new(0, -14, 0), ncRay)
                if res then
                    local target = res.Position.Y + hum.HipHeight + hrp.Size.Y / 2
                    if hrp.Position.Y <= target + 0.15 and v.Y <= 0 then
                        hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
                        if hrp.Position.Y < target - 0.2 then
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, math.min(target - hrp.Position.Y, 0.6), 0)
                        end
                    end
                elseif v.Y < 0 then
                    hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z) -- dentro de una pared: flota
                end
            end
        end))

        local flyBV
        local function stopFly()
            if flyBV then flyBV:Destroy() flyBV = nil end
        end
        onCleanup(stopFly)
        Toggle(HPG.pMain, "Fly", false, function(on)
            S.fly = on
            if on and S.ensureAntiSpeed then S.ensureAntiSpeed() end
            if not on then stopFly() end
        end)
        Slider(HPG.pMain, "Fly Speed", 10, isVip and 160 or 100, 40, function(v) S.flySpeed = v end)
        track(RunService.Heartbeat:Connect(function()
            if S.fly then
                local hrp, hum = getHRP(), getHum()
                if not hrp or not hum then return end
                if not flyBV or flyBV.Parent ~= hrp then
                    stopFly()
                    flyBV = new("BodyVelocity", {
                        MaxForce = Vector3.new(1e6, 1e6, 1e6),
                        Velocity = Vector3.zero,
                    }, hrp)
                end
                local md = hum.MoveDirection
                if md.Magnitude > 0 then
                    local look = workspace.CurrentCamera.CFrame.LookVector
                    local flat = Vector3.new(look.X, 0, look.Z)
                    local fwd = flat.Magnitude > 0 and md:Dot(flat.Unit) or 0
                    flyBV.Velocity = (md + Vector3.new(0, look.Y * math.max(fwd, 0), 0)) * S.flySpeed
                else
                    flyBV.Velocity = Vector3.zero
                end
            end
        end))

        local function jumpSpeed(h)
            if h.UseJumpPower then return h.JumpPower end
            return math.sqrt(2 * workspace.Gravity * h.JumpHeight)
        end
        local lastJump = 0
        local function doJump()
            local h, hrp = getHum(), getHRP()
            if not h or not hrp or h.Health <= 0 then return end
            local now = tick()
            if now - lastJump < 0.12 then return end
            lastJump = now
            local sp = math.max(jumpSpeed(h), S.jumpPower or 50)
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, sp, v.Z)
            pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
        Toggle(HPG.pMain, "Infinite Jump", false, function(on)
            S.infJump = on
            if on then
                local c0 = getChar()
                if c0 then pcall(function() c0:SetAttribute("CanJump", true) end) end
                -- mantener pulsado el salto (PC o botón táctil) sigue impulsándote en el aire
                startLoop("infJump", 0.14, function()
                    local h = getHum()
                    if h and (h.Jump or UserInputService:IsKeyDown(Enum.KeyCode.Space))
                        and h.FloorMaterial == Enum.Material.Air then
                        doJump()
                    end
                end)
            end
        end)
        Slider(HPG.pMain, "Potencia de salto", 30, isVip and 150 or 100, 50, function(v) S.jumpPower = v end)
        track(UserInputService.JumpRequest:Connect(function()
            if S.infJump then doJump() end
        end))

        -- Botón de saltar: reactiva el salto y muestra un botón propio (por si el juego lo oculta)
        S.jumpH = 7
        local jumpUI = new("TextButton", {
            Name = "RH_JumpButton",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -22, 1, -190),
            Size = UDim2.new(0, 62, 0, 62),
            BackgroundColor3 = darken(HUI.accent, 0.1),
            Text = "JUMP", TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBlack, TextSize = 14,
            AutoButtonColor = false, Visible = false, ZIndex = 30,
        }, gui)
        corner(jumpUI, 31)
        sheen(jumpUI, 31)
        HUI.onAccent(function(c) jumpUI.BackgroundColor3 = darken(c, 0.1) end)
        stroke(jumpUI, Color3.new(1, 1, 1), 2).Transparency = 0.3
        pressFx(jumpUI)
        jumpUI.Activated:Connect(function()
            if S.infJump then doJump() return end
            local h = getHum()
            if h then
                h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        Toggle(HPG.pMain, "Botón de Saltar", false, function(on)
            S.jumpBtn = on
            jumpUI.Visible = on
            if on then
                startLoop("jumpBtn", 0.3, function()
                    local h = getHum()
                    if h then
                        h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                        h.UseJumpPower = false
                        h.JumpHeight = S.jumpH
                    end
                    pcall(function()
                        local tg = LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
                        local jb = tg and tg.TouchControlFrame and tg.TouchControlFrame:FindFirstChild("JumpButton")
                        if jb then jb.Visible = true end
                    end)
                end)
            end
        end)
        Slider(HPG.pMain, "Altura de salto", 4, isVip and 40 or 20, 7, function(v) S.jumpH = v end)

        local originalPhys
        onCleanup(function()
            local hrp = getHRP()
            if hrp and S.noAccelUsed then hrp.CustomPhysicalProperties = originalPhys end
        end)
        Toggle(HPG.pMain, "No Acceleration", false, function(on)
            S.noAccel = on
            S.noAccelUsed = true
            local hrp = getHRP()
            if on then
                if hrp then originalPhys = hrp.CustomPhysicalProperties end
                startLoop("noAccel", 0.5, function()
                    local h = getHRP()
                    if h then
                        local c = h.CustomPhysicalProperties
                        if not c or c.Density ~= 100 then
                            h.CustomPhysicalProperties = PhysicalProperties.new(100, 0.7, 0, 1, 1)
                        end
                    end
                end)
            elseif hrp then
                hrp.CustomPhysicalProperties = originalPhys
            end
        end)

        Button(HPG.pMain, "📍 TP a la puerta (riesgo anticheat)", function()
            local rooms = getRooms()
            local hrp = getHRP()
            if not rooms or not hrp then return end
            local latest, num = nil, -1
            for _, r in ipairs(rooms:GetChildren()) do
                local nn = tonumber(r.Name)
                if nn and nn > num then latest, num = r, nn end
            end
            local door = latest and latest:FindFirstChild("Door")
            local part = door and (door:FindFirstChild("Door") or door.PrimaryPart
                or door:FindFirstChildWhichIsA("BasePart", true))
            if part then
                if S.ensureAntiSpeed then S.ensureAntiSpeed() end
                local from, target = hrp.Position, part.Position + Vector3.new(0, 3, 0)
                task.spawn(function()
                    local steps = math.max(1, math.ceil((from - target).Magnitude / 12))
                    for i = 1, steps do
                        if not hrp.Parent then break end
                        hrp.CFrame = CFrame.new(from:Lerp(target, i / steps))
                        task.wait(0.04)
                    end
                end)
                notify("📍 Teletransportado a la puerta %d", "info", 2, num)
            else
                notify("❌ No se encontró la puerta", "danger", 2)
            end
        end)

        Toggle(HPG.pMain, "Anti-AFK", true, function(on) S.antiAfk = on end)
        track(LocalPlayer.Idled:Connect(function()
            if S.antiAfk then
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
            end
        end))
    end

    ------------------------------------------------------------------
    -- ANTI
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    -- Guardia de remotes: modifica o descarta lo que TU cliente le manda al servidor,
    -- solo mientras la función esté activa (necesita hookmetamethod en tu ejecutor).
    ------------------------------------------------------------------
    local RG = { rules = {}, hooked = false, ring = {}, lab = false }
    HST.RG_QUIET = {
        Footstep = true, FootstepRemoteThatWeNeed = true, PingRemote = true, Crouch = true, SoundToClient = true,
        SendErrorLog = true, ClutchHeartbeat = true, Statistics = true, ServerLog = true, ToolAnimate = true,
        CharacterAnimator = true, ReplicateAnimation = true, ReplicateAnimationClient = true, LiveClock = true,
        Sprint = true, AnimationEvent = true, ClientAnimationEvent = true, CamShake = true, MotorReplication = true,
    }
    function RG.install()
        if RG.hooked then return true end
        if not (hookmetamethod and getnamecallmethod) then return false end
        local old
        local function handler(self, ...)
            local m = getnamecallmethod()
            if m == "FireServer" then
                local okn, nm = pcall(function() return self.Name end)
                if okn and type(nm) == "string" then
                    if RG.lab and not HST.RG_QUIET[nm] then
                        local a = table.pack(...)
                        local parts = {}
                        for i = 1, math.min(a.n, 3) do
                            local v = a[i]
                            parts[i] = (typeof(v) == "Instance") and v.Name or tostring(v):sub(1, 18)
                        end
                        table.insert(RG.ring, nm .. "(" .. table.concat(parts, ",") .. ")")
                        if #RG.ring > 40 then table.remove(RG.ring, 1) end
                    end
                    local rule = RG.rules[nm]
                    if rule then
                        local args = table.pack(...)
                        local okr, res = pcall(rule, args)
                        if okr then
                            if res == false then return end
                            if type(res) == "table" then
                                if setnamecallmethod then setnamecallmethod(m) end
                                return old(self, table.unpack(res, 1, res.n or #res))
                            end
                        end
                    end
                end
            end
            if setnamecallmethod then setnamecallmethod(m) end
            return old(self, ...)
        end
        local ok = pcall(function()
            old = hookmetamethod(game, "__namecall", newcclosure and newcclosure(handler) or handler)
        end)
        RG.hooked = ok
        return ok
    end
    function RG.rule(name, fn, on)
        if on then
            if not RG.install() then
                notify("❌ Tu ejecutor no soporta hookmetamethod", "danger", 4)
                return false
            end
            RG.rules[name] = fn
        else
            RG.rules[name] = nil
        end
        return true
    end
    onCleanup(function() RG.rules = {} RG.lab = false end)

    -- Anti Lab (solo devs): graba qué te quitó vida, qué entidades había cerca y qué remotes se enviaron
    if HPG.pDev then
        Section(HPG.pDev, "Anti Lab")
        local labLog, hpConn, charConn = {}, nil, nil
        local function curRoom()
            local r = LocalPlayer:GetAttribute("CurrentRoom")
            if r then return r end
            local gd = ReplicatedStorage:FindFirstChild("GameData")
            local lr = gd and gd:FindFirstChild("LatestRoom")
            return lr and lr.Value or "?"
        end
        local function numAttrs()
            local parts = {}
            local function grab(inst, tag)
                for k, v in pairs(inst:GetAttributes()) do
                    if type(v) == "number" or type(v) == "boolean" then
                        table.insert(parts, tag .. k .. "=" .. tostring(v))
                    end
                end
            end
            grab(LocalPlayer, "P.")
            local c = LocalPlayer.Character
            if c then grab(c, "C.") end
            return table.concat(parts, " ")
        end
        local function hookHum(h)
            if hpConn then hpConn:Disconnect() end
            local last = h.Health
            hpConn = h.HealthChanged:Connect(function(hp)
                if RG.lab and hp < last then
                    local hrp = getHRP()
                    local near = {}
                    if hrp then
                        for inst, def in pairs(HANTI.activeEnts) do
                            if inst.Parent then
                                local ok, pos = pcall(function()
                                    return inst:IsA("Model") and inst:GetPivot().Position or inst.Position
                                end)
                                if ok and pos then
                                    table.insert(near, def.n .. "@" .. math.floor((hrp.Position - pos).Magnitude) .. "st")
                                end
                            end
                        end
                    end
                    local rem = {}
                    for i = math.max(1, #RG.ring - 5), #RG.ring do table.insert(rem, RG.ring[i]) end
                    table.insert(labLog, string.format("-%.1f HP (%.0f->%.0f) room=%s floor=%s ents=[%s] remotes=[%s] attrs=%s",
                        last - hp, last, hp, tostring(curRoom()), tostring(HST.currentFloor),
                        table.concat(near, ","), table.concat(rem, " | "), numAttrs()))
                    if #labLog > 100 then table.remove(labLog, 1) end
                end
                last = hp
            end)
        end
        Toggle(HPG.pDev, "🔬 Anti Lab (grabar daño)", false, function(on)
            RG.lab = on
            if on then
                if not RG.install() then
                    notify("❌ Tu ejecutor no soporta hookmetamethod", "danger", 4)
                    RG.lab = false
                end
                local h = getHum()
                if h then hookHum(h) end
                if charConn then charConn:Disconnect() end
                charConn = LocalPlayer.CharacterAdded:Connect(function(c)
                    local hh = c:WaitForChild("Humanoid", 5)
                    if hh and RG.lab then hookHum(hh) end
                end)
                notify("🔬 Anti Lab activo: recibe daño y copia el log", "ok", 3)
            else
                if hpConn then hpConn:Disconnect() hpConn = nil end
                if charConn then charConn:Disconnect() charConn = nil end
            end
        end)
        HUI.DevButton("📋 Copiar Anti Lab", function()
            local txt = (#labLog > 0) and table.concat(labLog, "\n") or "(vacío)"
            pcall(function() if setclipboard then setclipboard(txt) end end)
            print(txt)
            notify("📋 Info copiada al portapapeles", "ok", 2)
        end)
        HUI.DevButton("🧬 Copiar contenedores anti (Entities/Modules)", function()
            local out = {}
            local function dump(label, inst)
                if not inst then table.insert(out, label .. ": (no existe)") return end
                local names = {}
                for _, c in ipairs(inst:GetChildren()) do table.insert(names, c.Name) end
                table.insert(out, label .. " [" .. #names .. "]: " .. table.concat(names, ", "))
            end
            dump("RS.Entities", ReplicatedStorage:FindFirstChild("Entities"))
            local cm = ReplicatedStorage:FindFirstChild("ClientModules")
            dump("RS.ClientModules.EntityModules", cm and cm:FindFirstChild("EntityModules"))
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local mg = pg and pg:FindFirstChild("MainUI") and pg.MainUI:FindFirstChild("Initiator")
            mg = mg and mg:FindFirstChild("Main_Game")
            local rl = mg and mg:FindFirstChild("RemoteListener")
            dump("RemoteListener.Modules", rl and rl:FindFirstChild("Modules"))
            HNET.copyOut(out)
        end)
    end

    do
        Section(HPG.pAnti, "Anti-Entidades")
        Toggle(HPG.pAnti, "Anti Entidades (Spoof Crouch)", false, function(on)
            S.spoofCrouch = on
            if on then
                startLoop("spoofCrouch", 0.32, function()
                    ReplicatedStorage.RemotesFolder.Crouch:FireServer(true, true)
                end)
            end
        end)

        -- Sistema anti por patrones: mueve la plantilla y los módulos de cliente de la
        -- entidad (Entities, ClientModules.EntityModules y RemoteListener.Modules) a una
        -- carpeta apagada. Busca por parte del nombre, así sigue andando aunque el juego
        -- renombre cosas, y un guardián lo re-aplica cada 2 s (el juego recrea carpetas).
        local movedEnts = {} -- instancia -> { container, key }
        local antiOn = {}
        HANTI.antiOn = antiOn
        local ANTI_ALIAS = {
            Screech = { "screech" }, Shade = { "shade", "halt" },
            A60 = { "a60", "a-60", "bash" }, A120 = { "a120", "a-120", "scribble" },
            Gloombat = { "gloombat" }, Rush = { "rush" }, Ambush = { "ambush" },
            Timothy = { "spider", "timothy" }, Grumble = { "grumble" },
        }
        local ANTI_LABEL = {
            Screech = "Anti Screech", Shade = "Anti Halt", A60 = "Anti Bash",
            A120 = "Anti Scribbles", Gloombat = "Anti Gloombat", Rush = "Anti Rush", Ambush = "Anti Ambush",
        }
        local function antiContainers()
            local list = {}
            local ents = ReplicatedStorage:FindFirstChild("Entities")
            if ents then table.insert(list, ents) end
            local cm = ReplicatedStorage:FindFirstChild("ClientModules")
            local em = cm and cm:FindFirstChild("EntityModules")
            if em then table.insert(list, em) end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local main = pg and pg:FindFirstChild("MainUI")
            local init = main and main:FindFirstChild("Initiator")
            local mg = init and init:FindFirstChild("Main_Game")
            local rl = mg and mg:FindFirstChild("RemoteListener")
            local mods = rl and rl:FindFirstChild("Modules")
            if mods then table.insert(list, mods) end
            -- (V7) Rooms / otros modos guardan los módulos en otro sitio: se buscan en todo ReplicatedStorage
            for _, nm in ipairs({ "EntityModules", "Entities" }) do
                local f = ReplicatedStorage:FindFirstChild(nm, true)
                if f and not table.find(list, f) then table.insert(list, f) end
            end
            return list
        end
        local function applyAntiEntity(key)
            local pats = ANTI_ALIAS[key] or { key:lower() }
            local f = ReplicatedStorage:FindFirstChild("RH_Disabled")
                or new("Folder", { Name = "RH_Disabled" }, ReplicatedStorage)
            for _, container in ipairs(antiContainers()) do
                for _, child in ipairs(container:GetChildren()) do
                    if not movedEnts[child] then
                        local ln = child.Name:lower()
                        for _, pat in ipairs(pats) do
                            if ln:find(pat, 1, true) then
                                movedEnts[child] = { container = container, key = key }
                                child.Parent = f
                                break
                            end
                        end
                    end
                end
            end
            local n = 0
            for _, d in pairs(movedEnts) do if d.key == key then n = n + 1 end end
            return n
        end
        local function restoreAntiEntity(key)
            for child, d in pairs(movedEnts) do
                if d.key == key then
                    if child and d.container and d.container.Parent then child.Parent = d.container end
                    movedEnts[child] = nil
                end
            end
        end
        local function setEntityDisabled(name, disable)
            antiOn[name] = disable or nil
            if disable then
                local n = applyAntiEntity(name)
                if n == 0 then
                    notify("⚠️ %s: no encontrado en esta versión del juego", "warn", 4, ANTI_LABEL[name] or name)
                end
                S.antiGuard = true
                startLoop("antiGuard", 2, function()
                    for k in pairs(antiOn) do applyAntiEntity(k) end
                    if HANTI.neutralizeNow then HANTI.neutralizeNow() end
                    if next(antiOn) == nil then S.antiGuard = false end
                end)
            else
                restoreAntiEntity(name)
            end
        end
        onCleanup(function()
            for child, d in pairs(movedEnts) do
                if child and d.container and d.container.Parent then child.Parent = d.container end
            end
            movedEnts = {}
            local f = ReplicatedStorage:FindFirstChild("RH_Disabled")
            if f then f:Destroy() end
            HANTI.restoreParts()
        end)

        -- (V7) A-60 / A-120 son entidades del CLIENTE: aparte de quitar sus módulos, cuando aparece el modelo
        -- en workspace se le apaga el contacto. Así también funciona en Rooms (A-1000) si el juego
        -- los cargó antes de activar el toggle o desde otra carpeta.
        local function neutralizeEntity(e)
            if not e.Parent then return end
            for _, part in ipairs(e:GetDescendants()) do HANTI.disablePart(part) end
            for _, part in ipairs(e:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanQuery = false end) end
            end
        end
        local function entWanted(name) return (name == "A60" and antiOn.A60) or (name == "A120" and antiOn.A120) end
        track(workspace.ChildAdded:Connect(function(ch)
            if entWanted(ch.Name) then
                task.wait(0.05) -- deja que cargue el modelo
                pcall(neutralizeEntity, ch)
                -- los hijos pueden llegar después
                local conn
                conn = ch.DescendantAdded:Connect(function(d)
                    if not ch.Parent then conn:Disconnect() return end
                    pcall(HANTI.disablePart, d)
                end)
                task.delay(6, function() if conn then conn:Disconnect() end end)
            end
        end))
        HANTI.neutralizeNow = function()
            for _, e in ipairs(workspace:GetChildren()) do
                if entWanted(e.Name) then pcall(neutralizeEntity, e) end
            end
        end
        Toggle(HPG.pAnti, "Anti Screech", false, function(on) setEntityDisabled("Screech", on) end)
        Toggle(HPG.pAnti, "Anti Halt", false, function(on) setEntityDisabled("Shade", on) end)
        Label(HPG.pAnti, "Rush, Ambush y Figure matan desde el servidor: no existe un bypass seguro del lado del cliente. Usa alertas, ESP de escondites y escóndete a tiempo.", Color3.fromRGB(255, 190, 120))

        -- Anti Eyes / Lookman: antes disparaba cada 0.2s y el propio cliente del juego
        -- lo pisaba (por eso "andaba una sola vez"). Ahora va por frame mientras haya
        -- una entidad Eyes/Lookman viva, detectada por nombre en workspace y por el
        -- registro de entidades activas, y re-busca el remote cada vez.
        local eyesAcc = 0
        local function eyesPresent()
            if workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("Lookman") then return true end
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent and (def.n == "EYES" or def.n == "LOOKMAN") then return true end
            end
            return false
        end
        track(RunService.Heartbeat:Connect(function(dt)
            if not S.antiEyes then return end
            eyesAcc = eyesAcc + dt
            if eyesAcc < 0.03 then return end
            eyesAcc = 0
            if eyesPresent() then
                pcall(function()
                    local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
                    local mr = rf and rf:FindFirstChild("MotorReplication")
                    if mr then mr:FireServer(-649) end
                end)
            end
        end))
        Toggle(HPG.pAnti, "Anti Eyes", false, function(on)
            S.antiEyes = on
        end)

        Toggle(HPG.pAnti, "Anti Snare", false, function(on)
            S.noSnare = on
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p) return p.Parent and p.Parent.Name == "Snare" end)
            end
        end)

        Toggle(HPG.pAnti, "Anti Giggle", false, function(on)
            S.antiGiggle = on
            refreshAnti()
            RG.rule("Giggle", function() return false end, on)
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p) return p.Parent and p.Parent.Name == "GiggleCeiling" end)
            end
        end)

        Toggle(HPG.pAnti, "Anti Dupe (puertas falsas)", false, function(on)
            S.antiDupe = on
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p) return p:FindFirstAncestor("DoorFake") ~= nil end)
            end
        end)

        Toggle(HPG.pAnti, "Anti Obstáculos (Seek/Chandelier)", false, function(on)
            S.objBypass = on
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p)
                    if p.Name == "Collision" and p.Parent and p.Parent.Name == "ChandelierObstruction" then
                        return true
                    end
                    local m = p:FindFirstAncestorWhichIsA("Model")
                    return m ~= nil and m:GetAttribute("LoadModule") == "AnimatedObstacleKill"
                end)
            end
        end)

        Toggle(HPG.pAnti, "Anti Timothy", false, function(on)
            S.antiTimothy = on
            setEntityDisabled("Timothy", on)
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p) return p.Parent and p.Parent.Name == "Timothy" end)
            end
        end)

        -- ===== V6.2: antis a nivel workspace (Archives / Stairwell) =====
        -- Muchas entidades de Archives (Drones, Alma, Scribbles, Ransom) nacen directo en workspace,
        -- fuera de CurrentRooms, por eso los filtros por sala no las veían. Aquí se enganchan aparte.
        local wsAnti = { conns = {}, droneParents = {}, water = {}, waterConn = nil }
        local function wsHook(key, fn)
            if wsAnti.conns[key] then wsAnti.conns[key]:Disconnect() wsAnti.conns[key] = nil end
            if not fn then return end
            for _, ch in ipairs(workspace:GetChildren()) do
                task.spawn(function() pcall(fn, ch) end)
            end
            wsAnti.conns[key] = workspace.ChildAdded:Connect(function(ch)
                task.spawn(function() pcall(fn, ch) end)
            end)
        end
        local function droneProcess(d)
            if d.Name ~= "Drones" then return end
            local wi = d:FindFirstChild("WalkedInto") or d:WaitForChild("WalkedInto", 3)
            if wi and not wsAnti.droneParents[wi] then
                wsAnti.droneParents[wi] = d
                wi.Parent = ReplicatedStorage
            end
        end
        local function droneProRestore()
            for wi, par in pairs(wsAnti.droneParents) do
                if wi and wi.Parent and par and par.Parent then wi.Parent = par end
            end
            wsAnti.droneParents = {}
        end
        local function setDronePro(on)
            if on then wsHook("drones", droneProcess)
            else wsHook("drones", nil) droneProRestore() end
        end
        local function setAlma(on)
            wsHook("alma", on and function(ch) if ch.Name == "Alma" then ch:Destroy() end end or nil)
        end
        local function setScribblePro(on)
            wsHook("scribbles", on and function(ch)
                if ch.Name == "Scribbles" then
                    local w = ch:FindFirstChild("IfYoureExploitingDeleteThis")
                        or ch:WaitForChild("IfYoureExploitingDeleteThis", 2)
                    if w then w:Destroy() end
                end
            end or nil)
        end
        local function setClosetTrash(on)
            wsHook("closet", on and function(ch)
                local n = ch.Name
                if n:sub(1, 6) == "Binder" or n:sub(1, 4) == "Shoe" or n:sub(1, 5) == "Shelf" then ch:Destroy() end
            end or nil)
        end
        local function setRansomKill(on)
            wsHook("ransomKill", on and function(ch) if ch.Name == "Ransom" then ch:Destroy() end end or nil)
        end

        -- Agua eléctrica: plataforma de ForceField sobre el agua (no se toca el agua)
        local function waterRoom(room)
            if not tonumber(room.Name) then return end
            task.wait(3)
            if not S.antiWater then return end
            local w = room:FindFirstChild("Water")
            if not w or wsAnti.water[w] then return end
            local p = new("Part", {
                Name = "RH_WaterBypass", Anchored = true, CanCollide = true, CanTouch = false,
                CanQuery = false, Transparency = 0.25, Color = Color3.fromRGB(0, 150, 255),
                Material = Enum.Material.ForceField,
            })
            if w:IsA("BasePart") then
                p.Size = w.Size + Vector3.new(0, 0.5, 0)
                p.CFrame = w.CFrame * CFrame.new(0, 0.25, 0)
            elseif w:IsA("Model") then
                local cf, size = w:GetBoundingBox()
                p.Size = size + Vector3.new(0, 0.5, 0)
                p.CFrame = cf * CFrame.new(0, 0.25, 0)
            else
                p.Size = Vector3.new(10, 1.5, 10)
                p.CFrame = w:GetPivot() * CFrame.new(0, 0.25, 0)
            end
            if p.Size.Y > 3 then p:Destroy() return end -- evita softlock
            p.Parent = room
            wsAnti.water[w] = p
        end
        local function setWater(on)
            S.antiWater = on
            if wsAnti.waterConn then wsAnti.waterConn:Disconnect() wsAnti.waterConn = nil end
            if on then
                local rooms = getRooms()
                if not rooms then return end
                for _, r in ipairs(rooms:GetChildren()) do task.spawn(waterRoom, r) end
                wsAnti.waterConn = rooms.ChildAdded:Connect(function(r) task.spawn(waterRoom, r) end)
            else
                for _, p in pairs(wsAnti.water) do if p then p:Destroy() end end
                wsAnti.water = {}
            end
        end

        -- Reloj de Archives: HUD + "Stop Time" (el remote del reloj frena la estampida de drones)
        local clockLbl
        local function clockObj()
            local rooms = getRooms()
            if not rooms then return nil end
            local list = {}
            for _, r in ipairs(rooms:GetChildren()) do
                local n = tonumber(r.Name)
                if n then table.insert(list, { r = r, n = n }) end
            end
            table.sort(list, function(a, b) return a.n > b.n end)
            for i = 1, math.min(6, #list) do
                local assets = list[i].r:FindFirstChild("Assets", true)
                local clock = assets and assets:FindFirstChild("ArchivesClock", true)
                if clock then return clock end
            end
        end
        local function setClockHud(on)
            S.clockHud = on
            if on then
                if not clockLbl then
                    clockLbl = new("TextLabel", {
                        Name = "RH_Clock", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6),
                        Size = UDim2.new(0, 130, 0, 24), BackgroundColor3 = Color3.fromRGB(16, 11, 29),
                        BackgroundTransparency = 0.25, TextColor3 = Color3.fromRGB(230, 220, 255),
                        Font = Enum.Font.GothamBold, TextSize = 14, Text = "🕒 --:--",
                    }, gui)
                    corner(clockLbl, 8)
                    stroke(clockLbl, HUI.accent, 1.2)
                end
                clockLbl.Visible = true
                startLoop("clockHud", 0.25, function()
                    local c = clockObj()
                    local t = c and c:FindFirstChild("Time", true)
                    local tl = t and t:FindFirstChild("TextLabel")
                    clockLbl.Text = "🕒 " .. ((tl and tl:IsA("TextLabel")) and tl.Text or "--:--")
                end)
            elseif clockLbl then
                clockLbl.Visible = false
            end
        end
        local function setStopTime(on)
            S.stopTime = on
            if on then
                startLoop("stopTime", 1, function()
                    local c = clockObj()
                    local rem = c and c:FindFirstChild("LookedAtRemote", true)
                    if rem and rem:IsA("RemoteEvent") then rem:FireServer() end
                end)
            end
        end
        onCleanup(function()
            for _, c in pairs(wsAnti.conns) do c:Disconnect() end
            wsAnti.conns = {}
            droneProRestore()
            setWater(false)
            if clockLbl then clockLbl:Destroy() clockLbl = nil end
        end)
        S.v62 = { clockHud = setClockHud, stopTime = setStopTime, water = setWater, closet = setClosetTrash }

        -- Archives (nombres internos de las entidades: A60 = Bash, A120 = Scribbles; sin confirmar)
        Toggle(HPG.pAnti, "Anti Bash (A-60)", false, function(on) setEntityDisabled("A60", on) end)
        Toggle(HPG.pAnti, "Anti Scribbles (A-120)", false, function(on)
            setEntityDisabled("A120", on)
            RG.rule("ScribbleDamage", function() return false end, on)
            setScribblePro(on)
        end)
        Toggle(HPG.pAnti, "Anti Gloombat", false, function(on) setEntityDisabled("Gloombat", on) end)

        -- Anti Drones (Archives): sin toque/colisión + te aparta solo si uno se acerca + aviso de stampede.
        -- (Los Drones te empujan al chocar: 5 de daño y sueltas lo que llevas. Experimental, del lado del cliente.)
        Toggle(HPG.pAnti, "Anti Drones (Archives)", false, function(on)
            S.antiDrone = on
            refreshAnti()
            setDronePro(on)
            if on then
                HANTI.fullPass()
                local lastWarn = 0
                startLoop("antiDrone", 0.12, function()
                    local hrp = getHRP()
                    if not hrp or hrp.Anchored then return end
                    local pos = hrp.Position
                    for d in pairs(HANTI.drone.set) do
                        if not d.Parent then
                            HANTI.drone.set[d] = nil
                        else
                            local ok, dp = pcall(function() return d:GetPivot().Position end)
                            if ok then
                                local off = Vector3.new(pos.X - dp.X, 0, pos.Z - dp.Z)
                                local dist = off.Magnitude
                                if dist < 6 and math.abs(pos.Y - dp.Y) < 8 then
                                    local dir = dist > 0.05 and off.Unit or (hrp.CFrame.LookVector * -1)
                                    hrp.CFrame = hrp.CFrame + dir * math.min(3, 6.5 - dist)
                                    pos = hrp.Position
                                    if tick() - lastWarn > 4 then
                                        lastWarn = tick()
                                        notify("🛸 Drone muy cerca: me aparté", "warn", 1.5)
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                HANTI.restoreGhost("drone")
                HANTI.restoreParts(function(p) return p.Parent and p.Parent.Name:lower():find("drone", 1, true) ~= nil end)
            end
        end)
        Toggle(HPG.pAnti, "Anti Seek (manos y obstáculos)", false, function(on)
            S.antiSeek = on
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreParts(function(p)
                    local m = p:FindFirstAncestorWhichIsA("Model")
                    return m ~= nil and (m.Name:lower():find("seek", 1, true) ~= nil
                        or m:GetAttribute("LoadModule") == "AnimatedObstacleKill")
                end)
            end
        end)
        Toggle(HPG.pAnti, "Anti Grumble (Mines)", false, function(on)
            S.antiGrumble = on
            refreshAnti()
            setEntityDisabled("Grumble", on)
            if on then HANTI.fullPass() else HANTI.restoreGhost("grumble") end
        end)
        Toggle(HPG.pAnti, "Anti Electricidad (Currents)", false, function(on)
            S.antiCurrents = on
            refreshAnti()
            if on then HANTI.fullPass() else HANTI.restoreGhost("current") end
        end)
        -- Anti Ragdoll / Knockdown: no te deja caer al suelo cuando algo te empuja
        local ragStates = { Enum.HumanoidStateType.Ragdoll, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.PlatformStanding }
        Toggle(HPG.pAnti, "Anti Ragdoll / Knockdown", false, function(on)
            S.antiRagdoll = on
            local hum = getHum()
            if hum then
                for _, st in ipairs(ragStates) do pcall(function() hum:SetStateEnabled(st, not on) end) end
            end
            if on then
                startLoop("antiRagdoll", 0.3, function()
                    local h = getHum()
                    if not h then return end
                    for _, st in ipairs(ragStates) do pcall(function() h:SetStateEnabled(st, false) end) end
                    local cs = h:GetState()
                    if cs == Enum.HumanoidStateType.Ragdoll or cs == Enum.HumanoidStateType.FallingDown
                        or cs == Enum.HumanoidStateType.PlatformStanding then
                        h:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end)
            end
        end)
        -- Anti Forget-Me-Not (Archives): las flores/enredaderas dejan de tocarte
        Toggle(HPG.pAnti, "Anti Forget-Me-Not (Archives)", false, function(on)
            S.antiFMN = on
            refreshAnti()
            if on then HANTI.fullPass() else HANTI.restoreGhost("fmn") end
        end)
        onCleanup(function() HANTI.restoreGhost("drone") HANTI.restoreGhost("fmn") end)

        -- Anti Ransom (Archives): Ransom ahora es una entidad del CLIENTE y te ataca si te MUEVES.
        -- El bypass viejo (remote A90) ya no sirve; este congela tu personaje mientras dura Ransom.
        local ransom = { n = 0, on = false, t = 0, t0 = 0, conns = {} }
        local function ransomRelease()
            if not ransom.on then return end
            ransom.on = false
            local hrp, hum = getHRP(), getHum()
            if hrp then hrp.Anchored = ransom.wasAnch or false end
            if hum and ransom.ws then hum.WalkSpeed = ransom.ws end
            pcall(function() game:GetService("ContextActionService"):UnbindAction("RH_RansomSink") end)
            if alive then notify("✅ Ransom terminó, ya puedes moverte", "ok", 3) end
        end
        local function ransomHold(sec)
            ransom.t = math.max(ransom.t, tick() + sec)
            if ransom.on then return end
            ransom.on = true
            ransom.t0 = tick()
            local hrp, hum = getHRP(), getHum()
            if hum then ransom.ws = hum.WalkSpeed hum.WalkSpeed = 0 end
            if hrp then ransom.wasAnch = hrp.Anchored hrp.Anchored = true end
            pcall(function()
                game:GetService("ContextActionService"):BindActionAtPriority("RH_RansomSink",
                    function() return Enum.ContextActionResult.Sink end, false, 3000,
                    Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
                    Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right,
                    Enum.KeyCode.Space, Enum.KeyCode.Thumbstick1)
            end)
            notify("💣 Ransom: te congelé, no te muevas", "danger", 4)
            task.spawn(function()
                while alive and ransom.on do
                    task.wait(0.25)
                    local expired = tick() >= ransom.t and ransom.n <= 0
                    if expired or tick() - ransom.t0 > 100 then break end
                end
                ransomRelease()
            end)
        end
        onCleanup(function()
            for _, c in ipairs(ransom.conns) do pcall(function() c:Disconnect() end) end
            ransomRelease()
        end)
        local function isRansomName(nm)
            nm = nm:lower()
            return nm:find("ransom", 1, true) ~= nil or nm:find("r4nsom", 1, true) ~= nil
        end
        Toggle(HPG.pAnti, "Anti Ransom (Archives)", false, function(on)
            S.antiRansom = on
            for _, c in ipairs(ransom.conns) do pcall(function() c:Disconnect() end) end
            ransom.conns = {}
            if not on then
                ransom.n = 0
                ransomRelease()
                return
            end
            local function watchGui(inst)
                if (inst:IsA("GuiObject") or inst:IsA("ScreenGui")) and isRansomName(inst.Name) then
                    ransom.n = ransom.n + 1
                    ransomHold(8)
                    inst.AncestryChanged:Connect(function()
                        if not inst:IsDescendantOf(game) then ransom.n = math.max(0, ransom.n - 1) end
                    end)
                end
            end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, d in ipairs(pg:GetDescendants()) do pcall(watchGui, d) end
                table.insert(ransom.conns, pg.DescendantAdded:Connect(function(d)
                    if S.antiRansom then pcall(watchGui, d) end
                end))
            end
            local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
            if rf then
                for _, r in ipairs(rf:GetChildren()) do
                    if r:IsA("RemoteEvent") and isRansomName(r.Name) then
                        table.insert(ransom.conns, r.OnClientEvent:Connect(function()
                            if S.antiRansom then ransomHold(20) end
                        end))
                    end
                end
            end
        end)
        HUI.DevButton("🧪 Copiar diagnóstico Ransom", function()
            local out = { "== Ransom diag ==" }
            local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
            if rf then
                local names = {}
                for _, c in ipairs(rf:GetChildren()) do table.insert(names, c.ClassName .. ":" .. c.Name) end
                table.insert(out, "Remotes: " .. table.concat(names, ", "))
            end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                local names = {}
                for _, c in ipairs(pg:GetChildren()) do table.insert(names, c.Name) end
                table.insert(out, "PlayerGui: " .. table.concat(names, ", "))
                for _, d in ipairs(pg:GetDescendants()) do
                    if isRansomName(d.Name) then table.insert(out, "UI: " .. d:GetFullName()) end
                end
            end
            HNET.copyOut(out)
        end)

        -- ===== V6.2: nuevos antis (Archives / Stairwell) =====
        Section(HPG.pAnti, "Archives / Stairwell (V6.2)")
        Toggle(HPG.pAnti, "Anti Alma (Archives)", false, setAlma)
        Toggle(HPG.pAnti, "Anti Closet Trash (Archives)", false, setClosetTrash)
        Toggle(HPG.pAnti, "Anti Ransom (eliminar modelo)", false, setRansomKill)
        Toggle(HPG.pAnti, "Anti Agua Eléctrica (Archives)", false, setWater)

        Section(HPG.pAnti, "Pack Bypass (V6.2)")
        local function setBp(flag, on)
            S[flag] = on or nil
            S.bpAny = (S.bpBanana or S.bpJeff or S.bpKill or S.bpWall or S.bpVacuum) and true or nil
            refreshAnti()
            if on then
                HANTI.fullPass()
            else
                HANTI.restoreGhost(({ bpJeff = "bpjeff", bpWall = "bpwall", bpVacuum = "bpvac" })[flag] or "bp")
                HANTI.restoreParts(function(p)
                    local n = p.Name
                    return n == "BananaPeel" or n == "Lava" or (p.Parent and p.Parent.Name == "BananaPeel")
                        or (p.Parent and p.Parent.Name == "JeffTheKiller")
                end)
            end
        end
        Toggle(HPG.pAnti, "Bypass Banana", false, function(on) setBp("bpBanana", on) end)
        Toggle(HPG.pAnti, "Bypass Jeff", false, function(on) setBp("bpJeff", on) end)
        Toggle(HPG.pAnti, "Bypass Killbricks (lava)", false, function(on) setBp("bpKill", on) end)
        Toggle(HPG.pAnti, "Bypass Seeking Wall", false, function(on) setBp("bpWall", on) end)
        Toggle(HPG.pAnti, "Bypass Vacuum (Sideroom)", false, function(on) setBp("bpVacuum", on) end)

        -- Anti Lag: apaga efectos pesados (partículas, humo, brillos) sin tocar el juego
        Toggle(HPG.pAnti, "Anti Lag (limpiar efectos)", false, function(on)
            HLAG.setLagFx(on)
            if on then notify("🧹 Anti Lag activado", "ok", 2) end
        end)
        -- Auto Anti Lag: mide tus FPS y activa la limpieza solo cuando bajan
        local fpsNow = 60
        do
            local acc, cnt = 0, 0
            track(RunService.Heartbeat:Connect(function(dt)
                acc = acc + dt
                cnt = cnt + 1
                if acc >= 1 then
                    fpsNow = cnt / acc
                    acc, cnt = 0, 0
                end
            end))
        end
        Toggle(HPG.pAnti, "Auto Anti Lag (si bajan los FPS)", false, function(on)
            S.autoLag = on
            if on then
                local low = 0
                startLoop("autoLag", 2, function()
                    if fpsNow < 30 then low = low + 1 else low = 0 end
                    if low >= 2 and not lag.fx then
                        HLAG.setLagFx(true)
                        notify("🧹 FPS bajos (%s): Anti Lag activado", "warn", 3, tostring(math.floor(fpsNow)))
                    elseif low >= 4 and fpsNow < 20 and not lag.boost then
                        HLAG.setBoost(true)
                        notify("⚡ FPS muy bajos: FPS Booster activado", "warn", 3)
                    end
                end)
            end
        end)
        Button(HPG.pAnti, "🧹 Limpiar memoria de ESP", function()
            pcall(HESP.pruneESP)
            notify("🧹 Limpieza hecha", "ok", 2)
        end)

        Toggle(HPG.pAnti, "Anti Void (rescate)", false, function(on) S.antiVoid = on end)

        Section(HPG.pAnti, "Supervivencia")
        -- (V7) Figure God Mode: ahora vive junto al Godmode (sección Juego), ver "Figure God Mode".
    end

    ------------------------------------------------------------------
    -- VISUAL
    ------------------------------------------------------------------
    do
        Section(HPG.pVis, "ESP")
        Toggle(HPG.pVis, "Doors", false, function(on) setESP("Door", on) end)
        Toggle(HPG.pVis, "Objetivos (llaves, fusibles...)", false, function(on) setESP("Objective", on) end)
        Toggle(HPG.pVis, "Entidades", false, function(on) setESP("Entity", on) end)
        Toggle(HPG.pVis, "Items", false, function(on) setESP("Item", on) end)
        Toggle(HPG.pVis, "Escondites", false, function(on) setESP("Hide", on) end)
        Toggle(HPG.pVis, "Gold", false, function(on) setESP("Gold", on) end)
        Toggle(HPG.pVis, "Cofres", false, function(on) setESP("Chest", on) end)
        Toggle(HPG.pVis, "🍬 Candy Vault ESP (caramelos, llaves, calderos)", false, function(on)
            if on and not S.candyScanOn then
                S.candyScanOn = true
                HESP.candyRescan()
            end
            setESP("Candy", on)
        end)
        Toggle(HPG.pVis, "⛏ Mines ESP (huevos, vagoneta, estalagmitas)", false, function(on)
            if on and not S.minesScanOn then
                S.minesScanOn = true
                HESP.MinesESP.rescan()
            end
            setESP("Mines", on)
        end)
        Toggle(HPG.pVis, "Jugadores", false, function(on) setESP("Player", on) end)

        Section(HPG.pVis, "Alertas")
        Toggle(HPG.pVis, "Notificar entidades + sonido", true, function(on)
            S.notify = on
            if not on then HANTI.seenEnt = setmetatable({}, { __mode = "k" }) end
        end)
        Toggle(HPG.pVis, "Flash de pantalla en peligro", true, function(on) S.flash = on end)

        Section(HPG.pVis, "Pantalla")
        local FB = {
            Brightness = 2, ClockTime = 14, FogEnd = 100000, FogStart = 0,
            GlobalShadows = false,
            Ambient = Color3.fromRGB(178, 178, 178),
            OutdoorAmbient = Color3.fromRGB(178, 178, 178),
        }
        local fbConn, fbOrig, fbAtmo = nil, nil, {}
        local function fbStop()
            if fbConn then fbConn:Disconnect() fbConn = nil end
            if fbOrig then
                for k, v in pairs(fbOrig) do pcall(function() Lighting[k] = v end) end
                fbOrig = nil
            end
            for atm, d in pairs(fbAtmo) do
                if atm and atm.Parent then
                    atm.Density = d[1]
                    atm.Haze = d[2]
                end
            end
            fbAtmo = {}
        end
        onCleanup(fbStop)
        Toggle(HPG.pVis, "Fullbright", false, function(on)
            if on then
                if fbConn then return end
                fbOrig = {}
                for k in pairs(FB) do fbOrig[k] = Lighting[k] end
                local frame = 0
                fbConn = RunService.RenderStepped:Connect(function()
                    for k, v in pairs(FB) do
                        if Lighting[k] ~= v then Lighting[k] = v end
                    end
                    frame = frame + 1
                    if frame % 15 == 0 then
                        for _, atm in ipairs(Lighting:GetChildren()) do
                            if atm:IsA("Atmosphere") then
                                if not fbAtmo[atm] then fbAtmo[atm] = { atm.Density, atm.Haze } end
                                atm.Density = 0
                                atm.Haze = 0
                            end
                        end
                    end
                end)
            else
                fbStop()
            end
        end)
        Slider(HPG.pVis, "Brillo Fullbright", 80, 255, 178, function(v)
            FB.Ambient = Color3.fromRGB(v, v, v)
            FB.OutdoorAmbient = Color3.fromRGB(v, v, v)
        end)

        Slider(HPG.pVis, "FOV", 70, 120, 70, function(v)
            S.fov = (v ~= 70) and v or nil
        end)
        track(RunService.RenderStepped:Connect(function()
            if S.fov then
                local cam = workspace.CurrentCamera
                if cam and cam.FieldOfView ~= S.fov then cam.FieldOfView = S.fov end
            end
        end))
    end

    ------------------------------------------------------------------
    -- PISOS (Hotel / Mines / Outdoors / Backdoor / Archives / Daily Run)
    ------------------------------------------------------------------
    -- (moved to tables) dailyLabel
    do
        Section(HPG.pFloor, "Hotel")
        local antiClone
        local setAntiSpeed
        onCleanup(function()
            if antiClone then pcall(function() antiClone:Destroy() end) end
            local hum = getHum()
            if hum and S.speedUsed then hum.WalkSpeed = S.origSpeed or 16 end
        end)
        local function buildClone()
            local char = getChar()
            local cp = char and char:FindFirstChild("CollisionPart")
            if not cp then return false end
            if antiClone then pcall(function() antiClone:Destroy() end) end
            antiClone = cp:Clone()
            antiClone.Name = "_CollisionClone"
            antiClone.Massless = true
            antiClone.CanCollide = false
            antiClone.CanQuery = false
            antiClone.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.7, 0, 1, 1)
            antiClone.Parent = char
            return true
        end
        local function enableAntiSpeed(silent)
            S.antiSpeed = true
            if not buildClone() then
                S.antiSpeed = false
                if not silent then notify("❌ No se encontró CollisionPart", "danger") end
                return false
            end
            startLoop("antiSpeed", 0.23, function()
                -- si respawneas o el clon se pierde, lo reconstruye solo
                if not antiClone or not antiClone.Parent or antiClone.Parent ~= getChar() then
                    if not buildClone() then return end
                end
                antiClone.Massless = false
                task.wait(0.23)
                local root = getHRP()
                if root and root.Anchored then
                    antiClone.Massless = true
                    task.wait(1)
                end
                if antiClone then antiClone.Massless = true end
            end)
            return true
        end
        setAntiSpeed = Toggle(HPG.pFloor, "AntiSpeed Bypass", false, function(on)
            if on then
                if not enableAntiSpeed(false) then setAntiSpeed(false, true) end
            else
                S.antiSpeed = false
                if antiClone then antiClone:Destroy() antiClone = nil end
            end
        end)
        -- Speed / Fly / Noclip / TP lo llaman para no tener que activarlo a mano
        S.ensureAntiSpeed = function()
            if S.antiSpeed then return true end
            local ok = enableAntiSpeed(true)
            if ok then
                setAntiSpeed(true, true)
                notify("🛡 AntiSpeed activado automáticamente", "ok", 2)
            end
            return ok
        end

        Toggle(HPG.pFloor, "Speed", false, function(on)
            if on and not S.antiSpeed then
                if not (S.ensureAntiSpeed and S.ensureAntiSpeed()) then
                    notify("⚠️ Activa AntiSpeed Bypass primero", "warn")
                    return
                end
            end
            S.speed = on
            local hum = getHum()
            if on then
                S.speedUsed = true
                if hum then S.origSpeed = hum.WalkSpeed end
                startLoop("speed", 0.1, function()
                    local h = getHum()
                    if h then h.WalkSpeed = S.speedValue end
                end)
            elseif hum then
                hum.WalkSpeed = S.origSpeed or 16
            end
        end)
        Slider(HPG.pFloor, "Speed Value", 2, 100, 16, function(v) S.speedValue = v end)
        Label(HPG.pFloor, "Hotel: activa AntiSpeed Bypass antes de usar Speed.")

        ----------------------------------------------------------------
        -- Hotel+ : Puerta 50 (Biblioteca) y Puerta 100 (caja de breakers)
        -- Todo va en pcall y en un closure: si el juego cambia algo, el hub NO se rompe.
        ----------------------------------------------------------------
        Section(HPG.pFloor, "Hotel+ (Puertas 50 y 100)")
        local function setupHotelPlus()
            local function remotesFolder() return ReplicatedStorage:FindFirstChild("RemotesFolder") end

            -- ===== Puerta 50: Biblioteca =====
            local function findPaper()
                local function scan(par)
                    if not par then return nil end
                    local p = par:FindFirstChild("LibraryHintPaper")
                    if p then return p end
                    for _, c in ipairs(par:GetChildren()) do
                        if c:IsA("Tool") and c.Name:lower():find("hint", 1, true) then return c end
                    end
                end
                return scan(getChar()) or scan(LocalPlayer:FindFirstChildOfClass("Backpack"))
            end
            local function hintsGui()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local perm = pg and pg:FindFirstChild("PermUI")
                return perm and perm:FindFirstChild("Hints")
            end
            local function iconKey(im)
                return tostring(im.ImageRectOffset.X) .. "_" .. tostring(im.ImageRectOffset.Y)
            end
            local function libraryCode()
                local paper = findPaper()
                if not paper then return nil, "nopaper" end
                local ui, hints = paper:FindFirstChild("UI"), hintsGui()
                if not (ui and hints) then return nil, "noui" end
                local posIcon, n = {}, 0
                for _, im in ipairs(ui:GetChildren()) do
                    local pos = tonumber(im.Name)
                    if pos and im:IsA("ImageLabel") then
                        posIcon[pos] = iconKey(im)
                        if pos > n then n = pos end
                    end
                end
                if n == 0 then return nil, "noui" end
                local iconDigit = {}
                for _, ic in ipairs(hints:GetChildren()) do
                    if ic.Name == "Icon" and ic:IsA("ImageLabel") then
                        local tl = ic:FindFirstChildOfClass("TextLabel")
                        local d = tl and tonumber(tl.Text)
                        if d then iconDigit[iconKey(ic)] = d end
                    end
                end
                local digits = {}
                for pos = 1, n do
                    local d = posIcon[pos] and iconDigit[posIcon[pos]]
                    if not d then return nil, "missing" end
                    digits[pos] = tostring(d)
                end
                return table.concat(digits)
            end

            local lastLib, lastLibMsg = nil, 0
            Toggle(HPG.pFloor, "Auto Door 50 (código Biblioteca)", false, function(on)
                S.autoDoor50 = on
                if on then
                    lastLib = nil
                    startLoop("autoDoor50", 1, function()
                        local code, why = libraryCode()
                        if code then
                            if code ~= lastLib then
                                lastLib = code
                                notify("🔓 Código de la Biblioteca: %s", "ok", 8, code)
                                pcall(function() if setclipboard then setclipboard(code) end end)
                                local rf = remotesFolder()
                                local pl = rf and rf:FindFirstChild("PL")
                                if pl then pcall(function() pl:FireServer(code) end) end
                            end
                        elseif why == "missing" and tick() - lastLibMsg > 15 then
                            lastLibMsg = tick()
                            notify("📚 Faltan pistas: recoge más libros", "warn", 3)
                        end
                    end)
                end
            end)
            Label(HPG.pFloor, "Door 50: recoge el papel y los libros (Auto Interact ayuda). El código sale solo, se copia y se intenta meter en el candado.")

            -- ===== Puerta 100: caja de breakers del ascensor =====
            -- Estructura real (diagnóstico): ElevatorBreaker.SurfaceGui.Frame.Code = número, Squares = "0/3",
            -- interruptores = MeshPart "BreakerSwitch" con atributo ID (1-10) y botones en XBoxUI.
            local function findBreakerBox()
                local rooms = getRooms()
                if not rooms then return nil end
                local latest, ln = nil, -1
                for _, r in ipairs(rooms:GetChildren()) do
                    local n = tonumber(r.Name)
                    if n and n > ln then latest, ln = r, n end
                end
                if not latest or ln < 90 then return nil end
                local box = latest:FindFirstChild("ElevatorBreaker", true)
                if box then return box end
                for _, d in ipairs(latest:GetDescendants()) do
                    if d:IsA("Model") then
                        local nm = d.Name:lower()
                        if nm:find("breaker", 1, true) and not nm:find("switch", 1, true) and not nm:find("pole", 1, true) then
                            return d
                        end
                    end
                end
            end
            local d100 = { box = nil, t = 0, last = nil, lastT = 0, warned = 0, hooked = nil }
            -- V6.2: el remote EBF resuelve la caja (mismo metodo que usa RushHub). Se dispara al cambiar
            -- el codigo; si algo falla queda el metodo de interruptores como respaldo.
            local d100Conn
            local function fireEBF()
                local rf = remotesFolder()
                local ebf = rf and rf:FindFirstChild("EBF")
                if ebf and ebf:IsA("RemoteEvent") then
                    return pcall(function() ebf:FireServer() end)
                end
                return false
            end
            local function d100Hook(box)
                if d100Conn then d100Conn:Disconnect() d100Conn = nil end
                local sg = box:FindFirstChild("SurfaceGui")
                local code = sg and sg:FindFirstChild("Code", true)
                if code and code:IsA("TextLabel") then
                    d100Conn = code:GetPropertyChangedSignal("Text"):Connect(function()
                        if S.autoDoor100 then task.wait(0.05) fireEBF() end
                    end)
                end
            end
            local function d100Code(box)
                local sg = box:FindFirstChild("SurfaceGui")
                local code = sg and sg:FindFirstChild("Code", true)
                if code and code:IsA("TextLabel") then return tonumber(code.Text), code.Text end
            end
            local function d100Squares(box)
                local sg = box:FindFirstChild("SurfaceGui")
                local sq = sg and sg:FindFirstChild("Squares", true)
                return (sq and sq:IsA("TextLabel")) and sq.Text or ""
            end
            local function d100Switches(box)
                local sw = {}
                for _, c in ipairs(box:GetChildren()) do
                    if c.Name == "BreakerSwitch" then
                        local id = tonumber(c:GetAttribute("ID"))
                        if id then sw[id] = c end
                    end
                end
                return sw
            end
            local function fireButton(btn)
                local ok = false
                for _, sigName in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up" }) do
                    local sig = btn[sigName]
                    if getconnections then
                        local okc, conns = pcall(getconnections, sig)
                        if okc and conns then
                            for _, c in ipairs(conns) do
                                local o1 = pcall(function() c:Fire() end)
                                if not o1 then pcall(function() c.Function() end) end
                                ok = true
                            end
                        end
                    elseif firesignal then
                        pcall(firesignal, sig)
                        ok = true
                    end
                end
                return ok
            end
            local function flipSwitch(box, sw, id)
                local pp = sw:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp and fireproximityprompt then pcall(fireproximityprompt, pp) return "prompt" end
                local cd = sw:FindFirstChildWhichIsA("ClickDetector", true)
                if cd and fireclickdetector then pcall(fireclickdetector, cd) return "click" end
                local ui = box:FindFirstChild("XBoxUI")
                if ui then
                    for _, b in ipairs(ui:GetChildren()) do
                        if b:IsA("TextButton") and tonumber(b:GetAttribute("ID")) == id and fireButton(b) then
                            return "button"
                        end
                    end
                end
                return nil
            end
            local function d100Target(sws, codeNum, codeTxt)
                for id, sw in pairs(sws) do
                    local hint = sw:FindFirstChild("Hint")
                    local tl = hint and hint:FindFirstChildWhichIsA("TextLabel", true)
                    if tl and tl.Text ~= "" and (tl.Text == codeTxt or tonumber(tl.Text) == codeNum) then
                        return id
                    end
                end
                if codeNum and sws[codeNum] then return codeNum end
            end
            local function d100Solve()
                if not d100.box or not d100.box.Parent or tick() - d100.t > 3 then
                    d100.t = tick()
                    d100.box = findBreakerBox()
                end
                local box = d100.box
                if not box then return end
                if d100.hooked ~= box then
                    d100.hooked = box
                    d100Hook(box)
                    fireEBF()
                    notify("🔌 Door 100: interactúa con la caja, se resuelve sola", "info", 4)
                end
                local codeNum, codeTxt = d100Code(box)
                if not codeTxt or codeTxt == "" then return end
                local key = codeTxt .. "|" .. d100Squares(box)
                local sws = d100Switches(box)
                local id = d100Target(sws, codeNum, codeTxt)
                if not id then return end
                local sw = sws[id]
                local stuck = d100.last == key and tick() - d100.lastT > 2.5 and sw:GetAttribute("Enabled") == false
                if d100.last ~= key or stuck then
                    d100.last, d100.lastT = key, tick()
                    fireEBF()
                    local how = flipSwitch(box, sw, id)
                    if how then
                        notify("🔌 Breaker %s (%s)", "info", 1.5, tostring(id), how)
                    elseif tick() - d100.warned > 20 then
                        d100.warned = tick()
                        notify("⚠️ Door 100: no pude pulsar el breaker", "warn", 4)
                    end
                end
            end
            Toggle(HPG.pFloor, "Auto Door 100 (minijuego breakers) BETA", false, function(on)
                S.autoDoor100 = on
                if on then
                    d100.last, d100.t, d100.hooked = nil, 0, nil
                    startLoop("autoDoor100", 0.25, d100Solve)
                else
                    if d100Conn then d100Conn:Disconnect() d100Conn = nil end
                    d100.hooked = nil
                end
            end)
            Label(HPG.pFloor, "Door 100: lee el código de la caja y pulsa el breaker correcto (BETA).", Color3.fromRGB(255, 190, 120))

            -- ===== Espía de remotes (para ajustar Door 100 con datos reales) =====
            local spy = { log = {}, on = false, hooked = false }
            local NOISE = {
                Footstep = true, FootstepRemoteThatWeNeed = true, PingRemote = true, Crouch = true, SoundToClient = true,
                SendErrorLog = true, ClutchHeartbeat = true, Statistics = true, ServerLog = true, ToolAnimate = true,
                CharacterAnimator = true, ReplicateAnimation = true, ReplicateAnimationClient = true, LiveClock = true,
                Sprint = true, AnimationEvent = true, ClientAnimationEvent = true, CamShake = true, Underwater = true,
            }
            local function argStr(v, depth)
                local t = typeof(v)
                if t == "Instance" then
                    return "Instance(" .. v.ClassName .. ":" .. v.Name .. ")"
                elseif t == "table" then
                    if depth >= 2 then return "{...}" end
                    local parts, n = {}, 0
                    for k, x in pairs(v) do
                        n = n + 1
                        if n > 8 then break end
                        table.insert(parts, tostring(k) .. "=" .. argStr(x, depth + 1))
                    end
                    return "{" .. table.concat(parts, ",") .. "}"
                end
                return t .. ":" .. tostring(v)
            end
            local function startSpy()
                spy.on = true
                if spy.hooked then return true end
                if not (hookmetamethod and getnamecallmethod) then
                    spy.on = false
                    return false
                end
                local old
                local ok = pcall(function()
                    old = hookmetamethod(game, "__namecall", function(self, ...)
                        local m = getnamecallmethod()
                        if spy.on and (m == "FireServer" or m == "InvokeServer") then
                            local okn, nm = pcall(function() return self.Name end)
                            if okn and not NOISE[nm] then
                                local args = table.pack(...)
                                local parts = {}
                                for i = 1, args.n do parts[i] = argStr(args[i], 0) end
                                table.insert(spy.log, string.format("%.1f %s:%s(%s)", tick() % 1000, m, tostring(nm), table.concat(parts, ", ")))
                                if #spy.log > 80 then table.remove(spy.log, 1) end
                            end
                        end
                        if setnamecallmethod then setnamecallmethod(m) end
                        return old(self, ...)
                    end)
                end)
                spy.hooked = ok
                if not ok then spy.on = false end
                return ok
            end
            HUI.DevButton("🎯 Espía de remotes (activar)", function()
                if startSpy() then
                    notify("🎯 Espía activo: pulsa un breaker a mano y copia el log", "ok", 4)
                else
                    notify("❌ Tu ejecutor no soporta hookmetamethod", "danger", 4)
                end
            end)
            HUI.DevButton("📋 Copiar log del espía", function()
                local txt = table.concat(spy.log, "\n")
                if txt == "" then txt = "(vacío)" end
                pcall(function() if setclipboard then setclipboard(txt) end end)
                print(txt)
                notify("📋 Info copiada al portapapeles", "ok", 2)
            end)
            onCleanup(function() spy.on = false end)

            -- ===== Diagnóstico =====
            local SKIPCLS = {
                Sound = true, Attachment = true, UIStroke = true, UIPadding = true, UIListLayout = true, UICorner = true,
                UIGradient = true, PrismaticConstraint = true, DistortionSoundEffect = true, FlangeSoundEffect = true,
                TremoloSoundEffect = true, ParticleEmitter = true, PointLight = true, Decal = true, ManualWeld = true,
                HingeConstraint = true, UIGridLayout = true,
            }
            HUI.DevButton("🧪 Copiar diagnóstico Door 50/100", function()
                local out = { "== Roshan Hub diag ==", "Room: " .. HNET.latestRoom() }
                local rf = remotesFolder()
                if rf then
                    local names = {}
                    for _, c in ipairs(rf:GetChildren()) do table.insert(names, c.Name) end
                    table.insert(out, "Remotes: " .. table.concat(names, ","))
                end
                local budget = { n = 300 }
                local function dump(inst, ind)
                    if budget.n <= 0 or SKIPCLS[inst.ClassName] then return end
                    budget.n = budget.n - 1
                    local extra = ""
                    if inst:IsA("TextLabel") or inst:IsA("TextButton") then extra = ' text="' .. inst.Text .. '"' end
                    if inst:IsA("ImageLabel") then extra = " rect=" .. tostring(inst.ImageRectOffset) end
                    local at = {}
                    for k, v in pairs(inst:GetAttributes()) do table.insert(at, k .. "=" .. tostring(v)) end
                    if #at > 0 then extra = extra .. " {" .. table.concat(at, ",") .. "}" end
                    table.insert(out, ind .. inst.ClassName .. " " .. inst.Name .. extra)
                    for _, c in ipairs(inst:GetChildren()) do dump(c, ind .. "  ") end
                end
                local paper = findPaper()
                table.insert(out, "-- Paper: " .. (paper and paper.Name or "no"))
                if paper then pcall(dump, paper, "") end
                local hg = hintsGui()
                table.insert(out, "-- Hints UI: " .. (hg and "si" or "no"))
                if hg then pcall(dump, hg, "") end
                local box = findBreakerBox()
                table.insert(out, "-- Breaker box: " .. (box and box:GetFullName() or "no"))
                if box then
                    local codeNum, codeTxt = d100Code(box)
                    table.insert(out, "Code=" .. tostring(codeTxt) .. " Squares=" .. d100Squares(box))
                    local ids = {}
                    for id, sw in pairs(d100Switches(box)) do
                        local hint = sw:FindFirstChild("Hint")
                        local tl = hint and hint:FindFirstChildWhichIsA("TextLabel", true)
                        table.insert(ids, "ID" .. id .. ":" .. tostring(sw:GetAttribute("Enabled")) .. ":'" .. (tl and tl.Text or "") .. "'")
                    end
                    table.sort(ids)
                    table.insert(out, "Switches: " .. table.concat(ids, " "))
                    pcall(dump, box, "")
                end
                HNET.copyOut(out)
            end)
        end
        setupHotelPlus()

        Section(HPG.pFloor, "Archives (sectores)")
        local sectorLbl = Label(HPG.pFloor, function() return "" end, Color3.fromRGB(255, 220, 120))
        task.spawn(function()
            while alive do
                task.wait(1.5)
                local pg = HUI.pages["Pisos"]
                if pg and pg.Visible and win.Visible then
                    local n = tonumber(HNET.latestRoom())
                    local txt
                    if n and tostring(HST.currentFloor):lower():find("archive", 1, true) then
                        local sector = math.floor((n - 1) / 50) + 1
                        local letter = string.char(64 + ((sector - 1) % 26) + 1)
                        local inSec = (n - 1) % 50 + 1
                        txt = function() return trf("📚 Sector %s • sala %d/50 • faltan %d para el siguiente", letter, inSec, 50 - inSec) end
                    else
                        txt = function() return tr("📚 Solo disponible dentro de The Archives") end
                    end
                    HUI.rebind(sectorLbl, txt)
                end
            end
        end)
        Label(HPG.pFloor, "Archives: Currents (puddles con electricidad) → activa Anti Electricidad en Anti. Drones → Anti Drones. Ransom → Anti Ransom.")

        Section(HPG.pFloor, "Candy Vault (Hollow)")
        Label(HPG.pFloor, "Candy Vault: Sir Abe te sigue; míralo para espantarlo. Activa Candy Vault ESP (pestaña Visual) y Auto Interact para recoger candy y usar los calderos.")
        HUI.DevButton("🧪 Copiar diagnóstico Candy Vault", function()
            local out = { "== Candy Vault diag ==", "Floor: " .. tostring(HST.currentFloor), "Room: " .. tostring(HNET.latestRoom()) }
            local names = {}
            for _, o in ipairs(workspace:GetChildren()) do table.insert(names, o.Name) end
            table.insert(out, "Workspace: " .. table.concat(names, ", "))
            local rooms = getRooms()
            local seen, list = {}, {}
            if rooms then
                local n = 0
                for _, d in ipairs(rooms:GetDescendants()) do
                    n = n + 1
                    if n > 6000 then break end
                    local ln = d.Name:lower()
                    if (ln:find("candy", 1, true) or ln:find("jewelry", 1, true) or ln:find("cauldron", 1, true)
                        or ln:find("socker", 1, true) or ln:find("vault", 1, true) or ln:find("abe", 1, true))
                        and not seen[d.Name] then
                        seen[d.Name] = true
                        table.insert(list, d.ClassName .. ":" .. d.Name)
                    end
                end
            end
            table.insert(out, "Matches: " .. table.concat(list, ", "))
            HNET.copyOut(out)
        end)

        Section(HPG.pFloor, "Mines")
        Label(HPG.pFloor, "Mines (piso 2): Seek corre entre las puertas 140-149 y Grumble espera en la 150. Giggle: no pases debajo. Gloombats: apaga la linterna.")
        Toggle(HPG.pFloor, "Auto optimizar en Mines (menos lag)", false, function(on)
            S.minesOpt = on
            if on then
                local applied = false
                startLoop("minesOpt", 4, function()
                    local f = ""
                    pcall(function()
                        local gd = ReplicatedStorage:FindFirstChild("GameData")
                        local fv = gd and gd:FindFirstChild("Floor")
                        if fv then f = tostring(fv.Value):lower() end
                    end)
                    local inMines = f:find("mine", 1, true) ~= nil
                    if inMines and not applied then
                        applied = true
                        HLAG.setLagFx(true)
                        notify("⛏ Mines detectado: Anti Lag activado", "ok", 3)
                    elseif not inMines then
                        applied = false
                    end
                end)
            end
        end)
        local ladderHL = {}
        local acConns = {}
        onCleanup(function()
            for _, h in ipairs(ladderHL) do if h then h:Destroy() end end
        end)
        Toggle(HPG.pFloor, "Anticheat Bypass (escaleras)", false, function(on)
            S.minesBypass = on
            if on then
                local rooms = getRooms()
                if rooms then
                    for _, room in ipairs(rooms:GetChildren()) do
                        local ladder = room:FindFirstChild("Ladder", true)
                        if ladder then
                            table.insert(ladderHL, new("Highlight", {
                                FillColor = Color3.fromRGB(0, 100, 255),
                                OutlineColor = Color3.fromRGB(0, 150, 255),
                                FillTransparency = 0.5,
                            }, ladder))
                        end
                    end
                end
                S.acOff = false
                startLoop("minesBypass", 0.15, function()
                    local c = getChar()
                    if c and c:GetAttribute("Climbing") == true then
                        if not S.acOff then
                            notify("⚠️ [Bypass] Espera 2s y no te muevas", "warn", 2)
                        end
                        task.wait(0.3)
                        if c:GetAttribute("Climbing") == true then c:SetAttribute("Climbing", false) end
                        if not S.acOff then
                            S.acOff = true
                            notify("🛡 Anticheat desactivado (se reactiva tras cutscene/halt)", "ok", 3)
                        end
                    end
                end)
                -- re-deteccion: tras una cutscene o Void/Glitch el anticheat vuelve; avisamos y rearmamos
                task.spawn(function()
                    local rf = ReplicatedStorage:WaitForChild("RemotesFolder", 10)
                    if not rf or not S.minesBypass then return end
                    local function rearm(why)
                        if S.acOff then
                            S.acOff = false
                            notify("🔁 Anticheat reactivado (" .. why .. "): sube otra escalera para apagarlo", "info", 4)
                        end
                    end
                    local cs = rf:FindFirstChild("Cutscene")
                    if cs and cs:IsA("RemoteEvent") then
                        table.insert(acConns, cs.OnClientEvent:Connect(function(nm)
                            if not tostring(nm):find("SewerSeek") then rearm("cutscene") end
                        end))
                    end
                    local um = rf:FindFirstChild("UseEnemyModule")
                    if um and um:IsA("RemoteEvent") then
                        table.insert(acConns, um.OnClientEvent:Connect(function(nm)
                            if nm == "Void" or nm == "Glitch" then rearm(tostring(nm)) end
                        end))
                    end
                end)
            else
                S.acOff = false
                for _, c in ipairs(acConns) do c:Disconnect() end
                acConns = {}
                for _, h in ipairs(ladderHL) do if h then h:Destroy() end end
                ladderHL = {}
            end
        end)
        Label(HPG.pFloor, "Mines: Anti Giggle y el ESP de entidades cubren a Giggle y Grumble.")

        ----------------------------------------------------------
        -- Mines: Seek chase (puentes) + plataforma segura
        ----------------------------------------------------------
        Toggle(HPG.pFloor, "Bridge Saver (puentes de Seek)", false, function(on)
            S.bridgeSaver = on
            if on then
                local rooms = getRooms()
                if rooms then
                    task.spawn(function()
                        local i = 0
                        for _, d in ipairs(rooms:GetDescendants()) do
                            pcall(HESP.trackBridge, d)
                            i = i + 1
                            if i % 400 == 0 then task.wait() end
                        end
                    end)
                end
            end
        end)

        -- Plataforma verde flotante que te sigue SOLO cuando estás en el aire
        local safePlat
        local lastGround, lastGroundPos = nil, nil
        local function killPlat()
            if safePlat then safePlat:Destroy() safePlat = nil end
        end
        onCleanup(killPlat)
        Toggle(HPG.pFloor, "Plataforma segura (anti caída)", false, function(on)
            S.safePlat = on
            if not on then killPlat() end
        end)
        track(RunService.Heartbeat:Connect(function()
            local hrp, hum = getHRP(), getHum()
            if not hrp or not hum then return end
            local airborne = (hum.FloorMaterial == Enum.Material.Air)
            if not airborne then
                -- altura de los pies cuando estás sobre suelo firme
                lastGround = hrp.Position.Y - (hum.HipHeight + hrp.Size.Y / 2)
                lastGroundPos = hrp.Position
            end
            if S.safePlat and lastGround then
                if not safePlat then
                    safePlat = new("Part", {
                        Name = "RH_SafePlatform", Anchored = true, CanCollide = true, CanQuery = false,
                        CanTouch = false, Material = Enum.Material.Neon, Color = Color3.fromRGB(60, 255, 110),
                        Size = Vector3.new(14, 0.8, 14), Transparency = 1, CastShadow = false,
                    }, workspace)
                end
                -- no sube al jugador: queda a la altura del último suelo (borde de puente)
                safePlat.CFrame = CFrame.new(hrp.Position.X, lastGround - 0.4, hrp.Position.Z)
                local falling = airborne and hrp.Position.Y < lastGround + 1
                safePlat.Transparency = falling and 0.35 or 1
                safePlat.CanCollide = falling or (not airborne)
            end
            -- Anti Void: si caes muy por debajo del último suelo, te devuelve
            if S.antiVoid and lastGroundPos and hrp.Position.Y < (lastGround or 0) - 45 then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(lastGroundPos + Vector3.new(0, 4, 0))
            end
        end))
        Toggle(HPG.pFloor, "ESP Escaleras", false, function(on)
            if on then
                local rooms = getRooms()
                if rooms then
                    for _, room in ipairs(rooms:GetChildren()) do
                        local ladder = room:FindFirstChild("Ladder", true)
                        if ladder then HESP.cand("Objective", ladder, Color3.fromRGB(0, 150, 255), "🪜 Ladder") end
                    end
                end
                setESP("Objective", true)
            end
        end)
        Label(HPG.pFloor, "Mines: Bridge Saver crea un bloque verde donde se rompe un puente en la persecución de Seek. La plataforma segura te sigue por debajo si caes.")

        -- Anti Damage (EXPERIMENTAL, gratis): devuelve la vida cuando baja.
        -- Es del lado del cliente: si el servidor aplica el daño, no lo evita.
        local hpConn, lastHp
        local function hookHealth()
            if hpConn then hpConn:Disconnect() hpConn = nil end
            local h = getHum()
            if not h then return end
            lastHp = h.Health
            hpConn = h.HealthChanged:Connect(function(hp)
                if S.antiDamage and lastHp and hp < lastHp and hp > 0 then
                    if S.debug then print("[Roshan:antiDamage] daño bloqueado", lastHp - hp) end
                    h.Health = lastHp
                else
                    lastHp = hp
                end
            end)
        end
        onCleanup(function() if hpConn then hpConn:Disconnect() end end)
        track(LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if S.antiDamage and alive then hookHealth() end
        end))
        Toggle(HPG.pFloor, "Anti Damage (EXPERIMENTAL)", false, function(on)
            S.antiDamage = on
            if on then hookHealth()
            elseif hpConn then hpConn:Disconnect() hpConn = nil end
        end)
        Label(HPG.pFloor, "Mines: Anti Damage y Figure God Mode son prototipos; el servidor puede ignorarlos. Usa Debug para ver si funcionan.", Color3.fromRGB(255, 190, 120))

        Section(HPG.pFloor, "Stairwell")
        Label(HPG.pFloor, "Stairwell (nueva subfloor, se entra desde Mines): usa Debug para ver nombres internos de sus entidades.")

        Section(HPG.pFloor, "Outdoors")
        Label(HPG.pFloor, "Outdoors: avisamos de Bramble, Caws, Eyestalk, Grampy, Groundskeeper, Mandrake, Monument, Surge y World Lotus. Anti Snare funciona aquí.")

        Section(HPG.pFloor, "Backdoor")
        Label(HPG.pFloor, "Backdoor: alertas de Haste, Blitz y Lookman. Anti Eyes cubre a Lookman.")

        Section(HPG.pFloor, "Archives")
        Label(HPG.pFloor, "Archives: Ransom = quédate quieto. Scribbles = escóndete en un closet. Bash = esquívalo.")
        Label(HPG.pFloor, "Anti Ransom, Anti Drones y Anti Forget-Me-Not están en la pestaña Anti.", Color3.fromRGB(255, 190, 120))

        Section(HPG.pFloor, "Daily Run")
        HUI.dailyLabel = Label(HPG.pFloor, function() return "" end, Color3.fromRGB(255, 220, 120))
        Label(HPG.pFloor, "Daily Run: las entidades vienen de cualquier piso, deja las alertas activadas.")
    end

    ------------------------------------------------------------------
    -- VIP
    ------------------------------------------------------------------
    do
        if not isVip then
            HUI.Card(HPG.pVip, "💎 ZONA VIP & BOOSTER", {
                "¡Desbloquea todo el poder del hub y apoya el proyecto!",
                "✨ Rainbow UI y temas exclusivos (Dorado y Rosa)",
                "📡 Radar de entidades y Auto Hide",
                "💰 Auto Loot Gold y FPS Booster",
                "🚀 Boosters del servidor: ventana Boost (Speed, Fly y Reach Pro, Auto Proxi, Anti AFK, vida baja) + zona VIP",
                "⏱ HUD de run, resumen de sesión, Anti Lag Pro y ESP Arcoíris",
                "Escríbeme por Discord para conseguir tu VIP Key o boostea el servidor 💜",
            }, Color3.fromRGB(150, 70, 255), Color3.fromRGB(70, 30, 130))
            Button(HPG.pVip, function() return "💬 Discord: " .. CONFIG.DiscordUser end, function()
                pcall(function() if setclipboard then setclipboard(CONFIG.DiscordUser) end end)
                notify("📋 Discord copiado", "ok", 2)
            end, Color3.fromRGB(88, 101, 242))
            Button(HPG.pVip, "🔗 Copiar link del Discord", function()
                pcall(function() if setclipboard then setclipboard(CONFIG.Discord) end end)
                notify("📋 Discord copiado", "ok", 2)
            end, Color3.fromRGB(88, 101, 242))
            HNET.KeyUI.box(HPG.pVip)
        else
            HUI.Card(HPG.pVip, "💎 ¡Gracias por ser VIP!", {
                "Tu apoyo mantiene vivo el hub. Disfruta la zona VIP 💜",
            }, Color3.fromRGB(190, 140, 30), Color3.fromRGB(110, 60, 10))
            Section(HPG.pVip, "Zona VIP")
            Toggle(HPG.pVip, "Stop Time / Anti Stampede", false, function(on)
                if S.v62 then S.v62.stopTime(on) end
            end)

            -- Rainbow UI
            local rbConn
            Toggle(HPG.pVip, "Rainbow UI", false, function(on)
                HUI.rainbowOn = on
                if on then
                    if HUI.pulseTween then HUI.pulseTween:Cancel() end
                    local f = 0
                    rbConn = RunService.Heartbeat:Connect(function()
                        f = f + 1
                        if f % 4 == 0 then
                            HUI.setAccent(Color3.fromHSV((tick() * 0.15) % 1, 0.75, 1), true)
                        end
                    end)
                else
                    if rbConn then rbConn:Disconnect() rbConn = nil end
                    HUI.setAccent(S.themeColor or CONFIG.Accent)
                end
            end)
            onCleanup(function() if rbConn then rbConn:Disconnect() end end)

            -- Auto recoger items cercanos
            Toggle(HPG.pVip, "Auto recoger items cercanos", false, function(on)
                S.autoItems = on
                if on then
                    local last = {}
                    startLoop("autoItems", 0.4, function()
                        local hrp = getHRP()
                        if not hrp then return end
                        for p in pairs(HESP.prompts) do
                            if p.Parent and p.Enabled and p.Name == "ModulePrompt" then
                                local pos = HESP.promptPos(p)
                                if pos and (hrp.Position - pos).Magnitude <= p.MaxActivationDistance
                                    and (not last[p] or tick() - last[p] > 0.6) then
                                    last[p] = tick()
                                    fireproximityprompt(p)
                                end
                            end
                        end
                    end)
                end
            end)
            -- Aura de color alrededor de tu personaje
            local auraHL, auraConn
            local function auraApply()
                if auraHL then auraHL:Destroy() auraHL = nil end
                local c = getChar()
                if c then
                    auraHL = new("Highlight", {
                        Name = "RH_Aura", FillTransparency = 0.8, OutlineTransparency = 0,
                        FillColor = HUI.accent, OutlineColor = HUI.accent, DepthMode = Enum.HighlightDepthMode.Occluded,
                    }, c)
                end
            end
            HUI.onAccent(function(col)
                if auraHL then auraHL.FillColor = col auraHL.OutlineColor = col end
            end)
            Toggle(HPG.pVip, "Aura de color", false, function(on)
                if on then
                    auraApply()
                    auraConn = LocalPlayer.CharacterAdded:Connect(function() task.wait(1) auraApply() end)
                else
                    if auraConn then auraConn:Disconnect() auraConn = nil end
                    if auraHL then auraHL:Destroy() auraHL = nil end
                end
            end)
            onCleanup(function()
                if auraConn then auraConn:Disconnect() end
                if auraHL then auraHL:Destroy() end
            end)

            -- Radar
            local radar = new("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 8),
                Size = UDim2.new(0, 200, 0, 24),
                BackgroundColor3 = Color3.fromRGB(16, 12, 26),
                BackgroundTransparency = 0.15,
                TextColor3 = Color3.new(1, 1, 1),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                Visible = false,
                ZIndex = 50,
            }, gui)
            corner(radar, 12)
            local radarStroke = stroke(radar, Color3.new(1, 1, 1), 1.5)
            Toggle(HPG.pVip, "Radar de entidades", false, function(on)
                S.radar = on
                if on then
                    startLoop("radar", 0.4, function()
                        local hrp = getHRP()
                        local best, bd, bdef = nil, 1e9, nil
                        if hrp then
                            for inst, def in pairs(HANTI.activeEnts) do
                                if inst.Parent then
                                    local ok, pos = pcall(function()
                                        return inst:IsA("Model") and inst:GetPivot().Position or inst.Position
                                    end)
                                    if ok and pos then
                                        local d = (hrp.Position - pos).Magnitude
                                        if d < bd then best, bd, bdef = inst, d, def end
                                    end
                                end
                            end
                        end
                        if best then
                            radar.Visible = true
                            radar.Text = trf("📡 %s · %d studs", bdef.n, math.floor(bd))
                            radarStroke.Color = bdef.c
                        else
                            radar.Visible = false
                        end
                    end)
                else
                    radar.Visible = false
                end
            end)

            -- FPS booster
            Toggle(HPG.pVip, "FPS Booster", false, function(on)
                HLAG.setBoost(on)
                if on then notify("🧹 FPS Booster activado", "ok", 2) end
            end)

            -- Auto Hide (experimental)
            Toggle(HPG.pVip, "Auto Hide (entidades peligrosas)", false, function(on) S.autoHide = on end)
            Label(HPG.pVip, "Auto Hide (experimental): al venir Rush/Ambush te mete en el escondite más cercano. Sal con el botón de escondite.", Color3.fromRGB(255, 190, 120))

            -- Auto Loot Gold
            Toggle(HPG.pVip, "Auto Loot Gold", false, function(on)
                S.autoLoot = on
                if on then
                    local last = {}
                    startLoop("autoLoot", 0.3, function()
                        local hrp = getHRP()
                        if not hrp then return end
                        for p in pairs(HESP.lootPrompts) do
                            if p.Parent and p.Enabled then
                                local pos = HESP.promptPos(p)
                                if pos and (hrp.Position - pos).Magnitude <= p.MaxActivationDistance
                                    and (not last[p] or tick() - last[p] > 0.5) then
                                    last[p] = tick()
                                    HANTI.stats.gold = HANTI.stats.gold + 1
                                    fireproximityprompt(p)
                                end
                            end
                        end
                    end)
                end
            end)

            Section(HPG.pVip, "Rendimiento y Visual VIP")
            Toggle(HPG.pVip, "Anti Lag Pro (todo en uno)", false, function(on)
                HLAG.setLagFx(on)
                HLAG.setBoost(on)
                notify(on and "🧹 Anti Lag Pro activado" or "🧹 Anti Lag Pro desactivado", "ok", 2)
            end)
            Toggle(HPG.pVip, "ESP Arcoíris", false, function(on)
                S.espRainbow = on
                if on then
                    startLoop("espRainbow", 0.3, function()
                        local c = Color3.fromHSV((tick() * 0.25) % 1, 0.8, 1)
                        for _, list in pairs(HESP.espObjs) do
                            for _, o in ipairs(list) do
                                if o and o.Parent and o:IsA("Highlight") then
                                    o.FillColor = c
                                    o.OutlineColor = c
                                end
                            end
                        end
                    end)
                else
                    for kind, tbl in pairs(HESP.cands) do
                        for obj, d in pairs(tbl) do
                            local hl = obj and obj:FindFirstChild("RH_HL_" .. kind)
                            if hl then
                                hl.FillColor = d[1]
                                hl.OutlineColor = d[1]
                            end
                        end
                    end
                    for _, kind in ipairs({ "Entity", "Player" }) do
                        if HESP.esp[kind] then
                            HESP.clearESP(kind)
                            setESP(kind, true)
                        end
                    end
                end
            end)

            Section(HPG.pVip, "Extras V6")
            local runHud = new("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8),
                Size = UDim2.new(0, 190, 0, 20), BackgroundColor3 = Color3.fromRGB(16, 12, 26),
                BackgroundTransparency = 0.25, TextColor3 = Color3.fromRGB(255, 215, 90),
                Font = Enum.Font.GothamBold, TextSize = 11, Visible = false, ZIndex = 40, Text = "",
            }, gui)
            corner(runHud, 8)
            Toggle(HPG.pVip, "HUD de run (puerta y tiempo)", false, function(on)
                S.runHud = on
                runHud.Visible = on
                if on then
                    local t0 = os.time()
                    startLoop("runHud", 1, function()
                        local s = os.time() - t0
                        runHud.Text = string.format("🚪 %d  •  ⏱ %02d:%02d", HNET.latestRoom(), s // 60, s % 60)
                    end)
                end
            end)
            Button(HPG.pVip, "📋 Copiar resumen de sesión", function()
                local s = os.time() - HNET.hubStart
                local txt = string.format("Roshan Hub V6 | Piso: %s | Habitación: %s | Entidades: %s | Oro: %s | Sesión: %02d:%02d:%02d",
                    tostring(HST.currentFloor), tostring(HNET.latestRoom()), tostring(HANTI.stats.ents), tostring(HANTI.stats.gold),
                    s // 3600, (s % 3600) // 60, s % 60)
                pcall(function() if setclipboard then setclipboard(txt) end end)
                notify("📋 Info copiada al portapapeles", "ok", 2)
            end)
        end
    end

    ------------------------------------------------------------------
    -- BOOST (ventana exclusiva: Boosters, VIP y staff) con opciones mejoradas
    ------------------------------------------------------------------
    do
        if not hasBoost then
            Label(HPG.pBoost, "🔒 Ventana Boost: exclusiva de Boosters del servidor y staff.", Color3.fromRGB(255, 150, 150))
            Label(HPG.pBoost, "💎 ¿Quieres VIP Key o Boost? Escríbeme al DM:", Color3.fromRGB(255, 215, 120))
            Button(HPG.pBoost, function() return "💬 Discord: " .. CONFIG.DiscordUser end, function()
                pcall(function() if setclipboard then setclipboard(CONFIG.DiscordUser) end end)
                notify("📋 Discord copiado", "ok", 2)
            end, Color3.fromRGB(88, 101, 242))
            HNET.KeyUI.box(HPG.pBoost)
        else
            Label(HPG.pBoost, "🚀 Ventana Boost activa: opciones mejoradas.", rankData.color)
            Section(HPG.pBoost, "Opciones mejoradas")
            Slider(HPG.pBoost, "Speed Pro", 2, 250, 16, function(v) S.speedValue = v end)
            Slider(HPG.pBoost, "Fly Speed Pro", 10, 250, 40, function(v) S.flySpeed = v end)
            Slider(HPG.pBoost, "Prompt Reach Pro", 0, 40, 0, function(v)
                S.reach = v
                HESP.refreshPrompts()
            end)
            Label(HPG.pBoost, "Speed Pro: actívalo con el toggle Speed de Pisos (necesita AntiSpeed Bypass).")

            Section(HPG.pBoost, "Archives Pro (V6.2)")
            Toggle(HPG.pBoost, "Reloj de Archives (HUD)", false, function(on)
                if S.v62 then S.v62.clockHud(on) end
            end)

            Section(HPG.pBoost, "Auto")
            local rHeld = false
            track(UserInputService.InputBegan:Connect(function(i, gp)
                if not gp and i.KeyCode == Enum.KeyCode.R then rHeld = true end
            end))
            track(UserInputService.InputEnded:Connect(function(i)
                if i.KeyCode == Enum.KeyCode.R then rHeld = false end
            end))
            Toggle(HPG.pBoost, "Auto Proxi (mantener R)", false, function(on)
                S.autoProxi = on
                if on then
                    local last = {}
                    startLoop("autoProxi", 0.12, function()
                        if not rHeld then return end
                        local hrp = getHRP()
                        if not hrp then return end
                        for p in pairs(HESP.prompts) do
                            if p.Parent and p.Enabled then
                                local pos = HESP.promptPos(p)
                                if pos and (hrp.Position - pos).Magnitude <= p.MaxActivationDistance then
                                    local txt = (p.ActionText or ""):lower()
                                    if not txt:find("close") and not txt:find("hide")
                                        and not HESP.skipPrompt(p)
                                        and (not last[p] or tick() - last[p] > 0.25) then
                                        last[p] = tick()
                                        local h = p.HoldDuration
                                        p.HoldDuration = 0
                                        HESP.fireSmart(p)
                                        p.HoldDuration = h
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
            Label(HPG.pBoost, "Auto Proxi: mantén R (PC) para interactuar con todo lo cercano. No toca sofás ni escondites.")

            Section(HPG.pBoost, "Supervivencia Boost")
            local oxyPeak = {}
            Toggle(HPG.pBoost, "Anti oxígeno (no morir ahogado)", false, function(on)
                S.antiOxygen = on
                RG.rule("Underwater", function(args)
                    if args[1] ~= false then return { false } end
                end, on)
                if on then
                    startLoop("antiOxygen", 0.5, function()
                        local function fix(inst)
                            for k, v in pairs(inst:GetAttributes()) do
                                if type(v) == "number" and k:lower():find("oxygen", 1, true) then
                                    oxyPeak[k] = math.max(oxyPeak[k] or 0, v)
                                    if v < oxyPeak[k] then inst:SetAttribute(k, oxyPeak[k]) end
                                end
                            end
                        end
                        fix(LocalPlayer)
                        local c = getChar()
                        if c then fix(c) end
                    end)
                end
            end)
            local function findReviveBtn()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if not pg then return nil end
                for _, d in ipairs(pg:GetDescendants()) do
                    if d:IsA("GuiButton") then
                        local t = d:IsA("TextButton") and d.Text:lower() or ""
                        if t:find("revive", 1, true) or d.Name:lower():find("revive", 1, true) then
                            local vis, p = true, d
                            while p and p:IsA("GuiObject") do
                                if not p.Visible then vis = false break end
                                p = p.Parent
                            end
                            if vis then return d end
                        end
                    end
                end
            end
            local function clickBtn(b)
                local fired = false
                pcall(function()
                    if getconnections then
                        for _, c in ipairs(getconnections(b.MouseButton1Click)) do c:Fire() fired = true end
                        for _, c in ipairs(getconnections(b.Activated)) do c:Fire() fired = true end
                    end
                end)
                if not fired then
                    pcall(function()
                        if firesignal then
                            firesignal(b.MouseButton1Click)
                            firesignal(b.Activated)
                            fired = true
                        end
                    end)
                end
                return fired
            end
            local reviving = false
            Toggle(HPG.pBoost, "Auto revivir (usa tus revives)", false, function(on)
                S.autoRevive = on
                if on then
                    startLoop("autoRevive", 0.5, function()
                        local h = getHum()
                        if h and h.Health > 0 then reviving = false end
                        if h and h.Health <= 0 and not reviving then
                            reviving = true
                            task.spawn(function()
                                local btn
                                for _ = 1, 12 do
                                    task.wait(0.5)
                                    btn = findReviveBtn()
                                    if btn or not alive or not S.autoRevive then break end
                                end
                                if btn and clickBtn(btn) then
                                    notify("🔄 Auto revive: pulsando Revive", "ok", 3)
                                else
                                    notify("⚠️ Auto revive: no vi el botón de Revive", "warn", 3)
                                end
                            end)
                        end
                    end)
                end
            end)
            Label(HPG.pBoost, "Anti oxígeno engaña el aviso de 'bajo el agua' al servidor y mantiene tu oxígeno. Auto revive pulsa el botón de Revive si lo tienes.", Color3.fromRGB(190, 180, 225))

            Section(HPG.pBoost, "Extras V6")
            -- (V7) Anti AFK duplicado eliminado: usa el toggle "Anti-AFK" de Principal.
            Toggle(HPG.pBoost, "Alerta de vida baja", false, function(on)
                S.lowHp = on
                if on then
                    local warned = false
                    startLoop("lowHp", 0.5, function()
                        local h = getHum()
                        if h and h.MaxHealth > 0 then
                            local low = h.Health > 0 and (h.Health / h.MaxHealth) <= 0.3
                            if low and not warned then
                                warned = true
                                notify("❤️ ¡Vida baja! (%s HP)", "danger", 3, tostring(math.floor(h.Health)))
                            elseif not low then
                                warned = false
                            end
                        end
                    end)
                end
            end)
        end
    end

    ------------------------------------------------------------------
    -- DEV
    ------------------------------------------------------------------
    if HPG.pDev then
        Section(HPG.pDev, "Herramientas Dev")
        Button(HPG.pDev, "📡 Volcar entidades activas", function()
            local lines = {}
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent then
                    table.insert(lines, def.n .. " -> " .. inst:GetFullName())
                end
            end
            local out = (#lines > 0) and table.concat(lines, "\n") or "(none)"
            print("[Roshan dev] active entities:\n" .. out)
            pcall(function() if setclipboard then setclipboard(out) end end)
            notify("📋 Info copiada al portapapeles", "ok", 2)
        end)
        Button(HPG.pDev, "🗂 Listar workspace (consola)", function()
            local names = {}
            for _, o in ipairs(workspace:GetChildren()) do
                table.insert(names, o.ClassName .. ": " .. o.Name)
            end
            print("[Roshan dev] workspace:\n" .. table.concat(names, "\n"))
        end)
        Button(HPG.pDev, "📋 Copiar info del servidor", function()
            local info = string.format("PlaceId=%s JobId=%s Floor=%s Lang=%s Role=%s Players=%d",
                tostring(game.PlaceId), tostring(game.JobId), HST.currentFloor, Lang, tostring(role), #Players:GetPlayers())
            print("[Roshan dev] " .. info)
            pcall(function() if setclipboard then setclipboard(info) end end)
            notify("📋 Info copiada al portapapeles", "ok", 2)
        end)
        Button(HPG.pDev, "🔔 Probar todas las alertas", function()
            task.spawn(function()
                for _, kind in ipairs({ "danger", "warn", "info", "ok" }) do
                    notify("🔔 Prueba de sonido y alerta", kind, 3)
                    task.wait(0.5)
                end
            end)
        end)
    end

    ------------------------------------------------------------------
    -- PERFIL
    ------------------------------------------------------------------
    do
        local card = new("Frame", {
            Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = Color3.new(1, 1, 1),
            LayoutOrder = -10,
        }, HPG.pProf)
        corner(card, 10)
        gradient(card, rankData.c2, Color3.fromRGB(24, 16, 42), 0)
        stroke(card, rankData.color, 1.5)

        local avBg = new("Frame", {
            Position = UDim2.new(0, 10, 0.5, -32), Size = UDim2.new(0, 64, 0, 64),
            BackgroundColor3 = Color3.fromRGB(30, 24, 48), BorderSizePixel = 0,
        }, card)
        corner(avBg, 32)
        stroke(avBg, rankData.color, 2)
        local av = new("ImageLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "",
        }, avBg)
        corner(av, 32)
        task.spawn(function()
            local ok, img = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and alive and av.Parent then av.Image = img end
        end)

        new("TextLabel", {
            Position = UDim2.new(0, 84, 0, 12), Size = UDim2.new(1, -92, 0, 22),
            BackgroundTransparency = 1, Text = LocalPlayer.DisplayName,
            TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBlack, TextScaled = true,
        }, card)
        -- (V7) Insignia de verificado: SOLO por UserId (el nombre se puede reclamar), solo el owner la ve
        if CONFIG.VerifiedById[LocalPlayer.UserId] == true then
            local safe = LocalPlayer.DisplayName:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
            HST.verifiedBadge = true
            local nameLbl = card:FindFirstChildWhichIsA("TextLabel")
            nameLbl.RichText = true
            nameLbl.Text = safe .. '  <font color="#1d9bf0">✔</font>'
            local vb = new("TextLabel", {
                Position = UDim2.new(0, 186, 0, 56), Size = UDim2.new(0, 86, 0, 18),
                BackgroundColor3 = Color3.fromRGB(29, 155, 240), Text = "✔ Verified",
                TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
            }, card)
            corner(vb, 9)
            stroke(card, Color3.fromRGB(29, 155, 240), 2) -- marco azul en tu tarjeta
        end
        new("TextLabel", {
            Position = UDim2.new(0, 84, 0, 36), Size = UDim2.new(1, -92, 0, 14),
            BackgroundTransparency = 1, Text = "@" .. LocalPlayer.Name,
            TextColor3 = Color3.fromRGB(210, 200, 235), TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 12,
        }, card)
        local badge = new("TextLabel", {
            Position = UDim2.new(0, 84, 0, 56), Size = UDim2.new(0, 96, 0, 18),
            BackgroundColor3 = Color3.new(1, 1, 1), Text = rankData.icon .. " " .. HST.rankLabel,
            TextColor3 = Color3.fromRGB(25, 15, 40), Font = Enum.Font.GothamBold, TextSize = 12,
        }, card)
        corner(badge, 9)
        spin(gradient(badge, rankData.color, rankData.c2, 0), 4)

        local rankDesc = {
            Guest = "Guest: primera vez en el hub. Vuelve y serás Member.",
            Member = "Member: gracias por volver al hub.",
            Veteran = "Veteran: más de 10 ejecuciones, gracias por quedarte.",
            Booster = "Booster: gracias por apoyar el Discord.",
            VIP = "VIP: acceso a la zona VIP.",
            Premium = "Premium: miembro premium del hub.",
            Staff = "Staff: equipo del hub.",
        }
        Label(HPG.pProf, rankDesc[rankName], rankData.color)

        local created = LocalPlayer.AccountAge
        local startT = os.time()
        local exec = "?"
        pcall(function() if identifyexecutor then exec = tostring((identifyexecutor())) end end)
        local device = UserInputService.TouchEnabled and tr("Móvil") or "PC"

        local profLabels = {}
        local function PLabel(fn, color)
            local l = Label(HPG.pProf, fn, color)
            table.insert(profLabels, { l, fn })
            return l
        end
        PLabel(function() return "🏷 " .. tr("Rol") .. ": " .. rankData.icon .. " " .. HST.rankLabel end, rankData.color)
        PLabel(function() return "🔁 " .. tr("Ejecuciones tuyas") .. ": " .. tostring(HST.uses) end)
        PLabel(function() return "🆔 " .. tr("ID") .. ": " .. tostring(LocalPlayer.UserId) end)
        PLabel(function() return "📅 " .. tr("Cuenta") .. ": " .. tostring(created) .. " " .. tr("días") end)
        PLabel(function()
            local s = os.time() - startT
            return string.format("⏱ %s: %02d:%02d:%02d", tr("Sesión"), s // 3600, (s % 3600) // 60, s % 60)
        end, Color3.fromRGB(120, 255, 170))
        PLabel(function() return "📱 " .. tr("Dispositivo") .. ": " .. device end)
        PLabel(function() return "⚙ " .. tr("Ejecutor") .. ": " .. exec end)
        PLabel(function() return "🌐 " .. tr("Idioma") .. ": " .. LANG_NAMES[Lang] end)
        PLabel(function() return trf("📍 Piso: %s", HST.currentFloor) end)

        Section(HPG.pProf, "Estadísticas de sesión")
        PLabel(function()
            local rooms = getRooms()
            local latest = 0
            if rooms then
                for _, r in ipairs(rooms:GetChildren()) do
                    local nn = tonumber(r.Name)
                    if nn and nn > latest then latest = nn end
                end
            end
            return "🚪 " .. tr("Habitación actual") .. ": " .. latest
        end)
        PLabel(function() return "👹 " .. tr("Entidades vistas") .. ": " .. HANTI.stats.ents end)
        PLabel(function() return "💰 " .. tr("Oro recogido") .. ": " .. HANTI.stats.gold end)
        PLabel(function()
            local h = getHum()
            local hp = h and string.format("%d/%d", math.floor(h.Health), math.floor(h.MaxHealth)) or "--"
            return "❤️ " .. tr("Vida") .. ": " .. hp
        end, Color3.fromRGB(255, 140, 150))
        PLabel(function()
            return "👥 " .. tr("Jugadores") .. ": " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        end)
        Button(HPG.pProf, "📋 Copiar mi ID", function()
            pcall(function() if setclipboard then setclipboard(tostring(LocalPlayer.UserId)) end end)
            notify("📋 Info copiada al portapapeles", "ok", 2)
        end)
        Button(HPG.pProf, "📋 Copiar mi usuario", function()
            pcall(function() if setclipboard then setclipboard(LocalPlayer.Name) end end)
            notify("📋 Usuario copiado", "ok", 2)
        end)

        -- solo refresca mientras la pestaña es visible Y la ventana está abierta
        task.spawn(function()
            while alive do
                task.wait(1)
                if win.Visible and HPG.pProf.Visible then
                    for _, pl in ipairs(profLabels) do pl[1].Text = pl[2]() end
                end
            end
        end)
    end

    ------------------------------------------------------------------
    -- ESTADO (usuarios activos, ejecuciones, redes)
    ------------------------------------------------------------------
    do
        local stLabels = {}
        local function SL(fn, color)
            local l = Label(HPG.pStat, fn, color)
            table.insert(stLabels, { l, fn })
            return l
        end
        local function num(v) return v ~= nil and tostring(v) or "—" end
        Section(HPG.pStat, "Estado del script")
        SL(function()
            if not Net.configured then return "🟡 " .. tr("Estadísticas globales sin configurar (CONFIG.StatsDB)") end
            if Net.state == "ok" then return "🟢 " .. tr("En línea") end
            if Net.state == "error" then return "🔴 " .. tr("Sin conexión con el servidor") end
            return "⏳ " .. tr("Conectando...")
        end, Color3.fromRGB(120, 255, 170))
        SL(function() return "👥 " .. tr("Usando ahora") .. ": " .. num(Net.active) end, Color3.fromRGB(255, 215, 90))
        SL(function() return "🚀 " .. tr("Ejecuciones totales") .. ": " .. num(Net.total) end, Color3.fromRGB(255, 215, 90))
        SL(function() return "🧑 " .. tr("Usuarios únicos") .. ": " .. num(Net.unique) end)
        SL(function() return "📦 " .. tr("Versión") .. ": V7" end)
        SL(function() return trf("📍 Piso: %s", HST.currentFloor) end)
        SL(function() return "🚪 " .. tr("Habitación actual") .. ": " .. HNET.latestRoom() end)
        SL(function()
            local s = os.time() - HNET.hubStart
            return string.format("⏱ %s: %02d:%02d:%02d", tr("Sesión"), s // 3600, (s % 3600) // 60, s % 60)
        end, Color3.fromRGB(120, 255, 170))
        Button(HPG.pStat, "🔄 Actualizar ahora", function()
            task.spawn(HNET.refreshStats)
            notify("🔄 Actualizando...", "info", 2)
        end)
        Label(HPG.pStat, "🔒 Solo se envía un ID anónimo aleatorio (sin usuario ni datos personales).", Color3.fromRGB(150, 140, 180))
        HUI.AppsButtons(HPG.pStat)

        task.spawn(function()
            local last = 0
            while alive do
                task.wait(1)
                if win.Visible and HPG.pStat.Visible then
                    for _, pl in ipairs(stLabels) do pl[1].Text = pl[2]() end
                    if Net.configured and os.time() - last >= 20 then
                        last = os.time()
                        task.spawn(HNET.refreshStats)
                    end
                end
            end
        end)
    end

    ------------------------------------------------------------------
    -- INFO
    ------------------------------------------------------------------
    -- (moved to tables) perf
    HUI.hudLabel = new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8),
        Size = UDim2.new(0, 130, 0, 20), BackgroundColor3 = Color3.fromRGB(16, 12, 26),
        BackgroundTransparency = 0.25, TextColor3 = Color3.fromRGB(120, 255, 170),
        Font = Enum.Font.GothamBold, TextSize = 11, Visible = false, ZIndex = 40, Text = "",
    }, gui)
    corner(HUI.hudLabel, 8)
    do
        Label(HPG.pInfo, CONFIG.Name, Color3.new(1, 1, 1))
        Label(HPG.pInfo, function() return trf("📍 Piso: %s", HST.currentFloor) end)
        Label(HPG.pInfo, function() return trf("👤 Tú: %s", LocalPlayer.Name .. (role and ("  [" .. role .. "]") or "")) end,
            role and Color3.fromRGB(255, 215, 90) or nil)
        HUI.perf = Label(HPG.pInfo, function() return "" end, Color3.fromRGB(120, 255, 170))
        Label(HPG.pInfo, "— Equipo —", Color3.new(1, 1, 1))
        local devLabels = {}
        for _, d in ipairs(CONFIG.DevList) do
            devLabels[d[1]] = Label(HPG.pInfo, function() return "" end)
        end
        local function refreshDevs()
            for _, d in ipairs(CONFIG.DevList) do
                local online = findPlayerCI(d[1]) ~= nil
                local lbl = devLabels[d[1]]
                local text = (online and "🟢 " or "⚪ ") .. d[1] .. " — " .. d[2]
                HUI.rebind(lbl, function() return text end)
                lbl.TextColor3 = online and Color3.fromRGB(255, 215, 90) or Color3.fromRGB(150, 140, 175)
            end
        end
        refreshDevs()
        track(Players.PlayerAdded:Connect(function(p)
            refreshDevs()
            local r = CONFIG.DevsById[p.UserId] or CONFIG.DevsByName[p.Name:lower()]
            if r and p ~= LocalPlayer and S.staffAlerts ~= false then
                notify("⭐ %s %s entró al servidor", "info", 5, r, p.Name)
            end
        end))
        track(Players.PlayerRemoving:Connect(function() task.defer(refreshDevs) end))

        local frames = 0
        track(RunService.RenderStepped:Connect(function() frames = frames + 1 end))
        task.spawn(function()
            while alive do
                task.wait(1)
                local ping = "--"
                pcall(function()
                    ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. "ms"
                end)
                local fps = frames
                frames = 0
                if S.hud and HUI.hudLabel then
                    HUI.hudLabel.Text = "⚡ " .. fps .. " FPS  •  " .. ping
                end
                -- los textos de Info solo se calculan si la ventana está abierta
                if win.Visible then
                    HUI.rebind(HUI.perf, function() return trf("⚡ FPS: %d  |  Ping: %s", fps, ping) end)
                    local t = os.time()
                    local reset = t - (t % 86400) + 20 * 3600
                    if t >= reset then reset = reset + 86400 end
                    local rem = reset - t
                    local timeStr = string.format("%02d:%02d:%02d", rem // 3600, (rem % 3600) // 60, rem % 60)
                    HUI.rebind(HUI.dailyLabel, function() return trf("⏳ Reset Daily Run (~20:00 UTC) en %s", timeStr) end)
                end
            end
        end)
    end

    ------------------------------------------------------------------
    -- CRÉDITOS (equipo del hub con avatar y usuario)
    ------------------------------------------------------------------
    do
        Section(HPG.pCred, "Equipo del hub")
        local creditCards = {}
        local roleColors = {
            ["Owner"] = Color3.fromRGB(255, 215, 90), ["Co-Owner"] = Color3.fromRGB(255, 170, 70),
            ["Dev"] = Color3.fromRGB(110, 190, 255), ["Tester"] = Color3.fromRGB(120, 230, 160),
            ["Owner Sister"] = Color3.fromRGB(255, 130, 210),
            ["Collaborator • Premium"] = Color3.fromRGB(120, 235, 255),
        }
        for i, d in ipairs(CONFIG.DevList) do
            local username, devRole = d[1], d[2]
            local rc = roleColors[devRole] or Color3.fromRGB(200, 190, 230)
            local card = new("Frame", {
                Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Color3.fromRGB(30, 24, 48),
                LayoutOrder = i,
            }, HPG.pCred)
            corner(card, 10)
            stroke(card, rc, 1).Transparency = 0.5
            local avBg = new("Frame", {
                Position = UDim2.new(0, 8, 0.5, -22), Size = UDim2.new(0, 44, 0, 44),
                BackgroundColor3 = Color3.fromRGB(20, 16, 34), BorderSizePixel = 0,
            }, card)
            corner(avBg, 22)
            stroke(avBg, rc, 2)
            if devRole == "Owner" then
                local crown = new("TextLabel", {
                    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, 8),
                    Size = UDim2.new(0, 24, 0, 18), BackgroundTransparency = 1, Text = "👑",
                    TextSize = 17, Rotation = -14, ZIndex = 6,
                }, avBg)
                TweenService:Create(crown, TweenInfo.new(1.1, Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut, -1, true), { Position = UDim2.new(0.5, 0, 0, 3) }):Play()
            end
            local av = new("ImageLabel", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "",
            }, avBg)
            corner(av, 22)
            local dot = new("Frame", {
                Position = UDim2.new(0, 40, 0.5, 8), Size = UDim2.new(0, 12, 0, 12),
                BackgroundColor3 = Color3.fromRGB(110, 100, 130), BorderSizePixel = 0, ZIndex = 3,
            }, card)
            corner(dot, 6)
            stroke(dot, Color3.fromRGB(30, 24, 48), 2)
            local nameL = new("TextLabel", {
                Position = UDim2.new(0, 60, 0, 6), Size = UDim2.new(1, -150, 0, 18),
                BackgroundTransparency = 1, Text = (devRole == "Owner" and "👑 " or "") .. username, TextColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold,
                TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
            new("TextLabel", {
                Position = UDim2.new(0, 60, 0, 24), Size = UDim2.new(1, -150, 0, 14),
                BackgroundTransparency = 1, Text = "@" .. username,
                TextColor3 = Color3.fromRGB(170, 160, 200), TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd,
            }, card)
            local chipW = math.max(84, (utf8.len(devRole) or #devRole) * 6 + 16)
            local chip = new("TextLabel", {
                Position = UDim2.new(0, 60, 0, 40), Size = UDim2.new(0, chipW, 0, 16),
                BackgroundColor3 = rc, Text = devRole, TextColor3 = Color3.fromRGB(25, 15, 40),
                Font = Enum.Font.GothamBold, TextSize = 10,
            }, card)
            corner(chip, 8)
            local verified = isVerifiedUser() and CONFIG.VerifiedByName[username:lower()] == true
            if verified then
                local vb = new("TextLabel", {
                    Position = UDim2.new(0, 60 + chipW + 6, 0, 40), Size = UDim2.new(0, 72, 0, 16),
                    BackgroundColor3 = Color3.fromRGB(29, 155, 240), Text = "✔ Verified",
                    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 10,
                }, card)
                corner(vb, 8)
                stroke(vb, Color3.fromRGB(170, 220, 255), 1)
            end
            local copyB = new("TextButton", {
                Position = UDim2.new(1, -78, 0.5, -13), Size = UDim2.new(0, 70, 0, 26),
                BackgroundColor3 = Color3.fromRGB(70, 50, 120), Text = "📋 @",
                TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
                AutoButtonColor = false,
            }, card)
            corner(copyB, 7)
            pressFx(copyB)
            copyB.Activated:Connect(function()
                pcall(function() if setclipboard then setclipboard(username) end end)
                notify("📋 Usuario copiado", "ok", 2)
            end)
            -- avatar: se resuelve el userId por nombre (una sola vez, en segundo plano)
            task.spawn(function()
                local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(username) end)
                if not ok or not uid or not alive then return end
                local ok2, img = pcall(function()
                    return Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if ok2 and alive and av.Parent then av.Image = img end
            end)
            creditCards[username] = { dot = dot, name = nameL, role = devRole, verified = verified }
        end
        local function refreshCredits()
            for username, c in pairs(creditCards) do
                local pl = findPlayerCI(username)
                c.dot.BackgroundColor3 = pl and Color3.fromRGB(90, 230, 130) or Color3.fromRGB(110, 100, 130)
                local base = pl and (pl.DisplayName ~= pl.Name and (pl.DisplayName .. "  🟢") or (pl.Name .. "  🟢")) or username
                c.name.Text = (c.role == "Owner" and "👑 " or "") .. base .. (c.verified and " ✔" or "")
            end
        end
        refreshCredits()
        track(Players.PlayerAdded:Connect(function() task.defer(refreshCredits) end))
        track(Players.PlayerRemoving:Connect(function() task.defer(refreshCredits) end))

        HUI.AppsButtons(HPG.pCred)

        Section(HPG.pCred, "Discord del hub")
        Button(HPG.pCred, function() return "💬 DM: " .. CONFIG.DiscordUser end, function()
            pcall(function() if setclipboard then setclipboard(CONFIG.DiscordUser) end end)
            notify("📋 Discord copiado", "ok", 2)
        end, Color3.fromRGB(88, 101, 242))
        Button(HPG.pCred, "📋 Copiar Discord", function()
            pcall(function() if setclipboard then setclipboard(CONFIG.Discord) end end)
            notify("📋 Discord copiado", "ok", 2)
        end, Color3.fromRGB(88, 101, 242))
        Label(HPG.pCred, "Gracias por usar el hub 💜", Color3.fromRGB(200, 180, 255))
    end

    ------------------------------------------------------------------
    -- CONFIG
    ------------------------------------------------------------------
    do
        Section(HPG.pCfg, "Idioma")
        local langBtn = Button(HPG.pCfg, function() return "🌐 " .. tr("Idioma") .. ": " .. LANG_NAMES[Lang] end, function()
            setLang(nextLang())
            notify("🌐 Idioma: %s", "ok", 2, LANG_NAMES[Lang])
        end)

        -- Temas
        local THEMES = {
            { "Morado", Color3.fromRGB(170, 70, 255) },
            { "Rojo", Color3.fromRGB(235, 60, 70) },
            { "Azul", Color3.fromRGB(70, 140, 255) },
            { "Verde", Color3.fromRGB(70, 210, 120) },
            { "Dorado", Color3.fromRGB(255, 200, 60), true },
            { "Rosa", Color3.fromRGB(255, 100, 190), true },
        }
        local themeIdx = 1
        S.themeColor = THEMES[1][2]
        Section(HPG.pCfg, "Tema")
        Button(HPG.pCfg, function() return "🎨 " .. tr("Tema") .. ": " .. tr(THEMES[themeIdx][1]) end, function()
            local nxt = themeIdx % #THEMES + 1
            if THEMES[nxt][3] and not isVip then
                -- salta los temas VIP si no tiene acceso
                nxt = 1
                notify("🔒 Tema exclusivo VIP", "warn", 2)
            end
            themeIdx = nxt
            S.themeColor = THEMES[themeIdx][2]
            if not HUI.rainbowOn then HUI.setAccent(S.themeColor) end
            notify("🎨 Tema: %s", "ok", 2, tr(THEMES[themeIdx][1]))
        end)

        Section(HPG.pCfg, "Sonido")
        Toggle(HPG.pCfg, "Sonidos", true, function(on) S.sound = on end)
        Slider(HPG.pCfg, "Volumen", 0, 10, 6, function(v) S.volume = v / 10 end)
        Button(HPG.pCfg, "🔔 Probar notificación", function()
            notify("🔔 Prueba de sonido y alerta", "danger", 3)
        end)

        Section(HPG.pCfg, "Interfaz")
        Toggle(HPG.pCfg, "Animaciones de la UI (más bonito, más lag)", not IS_MOBILE, function(on) HUI.setUiAnim(on) end)
        Slider(HPG.pCfg, "Escala de UI", 70, 130, 100, function(v)
            S.uiScalePct = v
            HUI.winScale.Scale = v / 100
        end)
        Slider(HPG.pCfg, "Duración de avisos", 50, 200, 100, function(v) S.toastPct = v end)
        Slider(HPG.pCfg, "Máx. avisos en pantalla", 1, 6, 4, function(v) S.maxToasts = v end)
        Toggle(HPG.pCfg, "FPS/Ping en pantalla", false, function(on)
            S.hud = on
            HUI.hudLabel.Visible = on
        end)
        Toggle(HPG.pCfg, "Sin sofás en Auto Interact", true, function(on) S.skipCouch = on end)
        Toggle(HPG.pCfg, "Sin objetos cargables en Auto Interact", true, function(on) S.skipCarry = on end)
        Toggle(HPG.pCfg, "Anti re-sentarse (pausa tras levantarte)", true, function(on) S.noResit = on end)
        Toggle(HPG.pCfg, "Aprender prompts molestos (auto)", true, function(on) S.learnBad = on end)
        Button(HPG.pCfg, "🧹 Olvidar prompts ignorados", function()
            HESP.badNames = {}
            HESP.badPrompts = setmetatable({}, { __mode = "k" })
            notify("🧹 Lista de prompts ignorados limpiada", "ok", 2)
        end)
        Toggle(HPG.pCfg, "Mostrar avisos de jugadores staff", true, function(on) S.staffAlerts = on end)

        Section(HPG.pCfg, "Sistema")
        Toggle(HPG.pCfg, "Debug (consola)", false, function(on) S.debug = on end)
        Button(HPG.pCfg, "Hide UI", function() HUI.setOpen(false) end)
        Button(HPG.pCfg, "🔄 Rejoin", function()
            pcall(function()
                local TS = game:GetService("TeleportService")
                if #Players:GetPlayers() <= 1 then
                    LocalPlayer:Kick("\nRejoining...")
                    task.wait()
                    TS:Teleport(game.PlaceId, LocalPlayer)
                else
                    TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
        end)
        Button(HPG.pCfg, "📋 Copy JobId", function()
            pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end)
            notify("📋 Info copiada al portapapeles", "ok", 2)
        end)
        Button(HPG.pCfg, "Reset All Settings", function()
            for _, set in ipairs(HUI.setters) do set(false) end
            S.reach, S.speedValue, S.fov = 0, 16, nil
            HESP.refreshPrompts()
            notify("✅ Ajustes reseteados", "ok", 2)
        end)

        Button(HPG.pCfg, "Destruir script", function()
            HNET.shutdown()
            getgenv().RoshanHubLoaded = false
        end, Color3.fromRGB(120, 30, 50))

        Label(HPG.pCfg, "Toca R (botón flotante) para abrir/cerrar. En PC: RightShift.")
    end

    ------------------------------------------------------------------
    -- Arranque
    ------------------------------------------------------------------
    ------------------------------------------------------------------
    -- V6.1: extras de movimiento y cámara (todo con pcall y restauración)
    ------------------------------------------------------------------
    do
        -- ===== Movimiento+ =====
        Section(HPG.pMain, "Movimiento+")

        Toggle(HPG.pMain, "Permitir saltar", false, function(on)
            S.canJump = on
            local c = getChar()
            if c then pcall(function() c:SetAttribute("CanJump", on and true or false) end) end
        end)
        -- (V7) "Salto infinito" y "Anti AFK" duplicados eliminados: ya existen
        -- "Infinite Jump" y "Anti-AFK" arriba. Aquí solo se mantiene el atributo CanJump.
        track(LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.6)
            if alive and (S.canJump or S.infJump) and c.Parent then
                pcall(function() c:SetAttribute("CanJump", true) end)
            end
        end))

        -- ===== Cámara y efectos =====
        Section(HPG.pVis, "Cámara y efectos")

        -- Quitar niebla
        local fogOrigEnd
        local atmoOrig = setmetatable({}, { __mode = "k" })
        local function fogRestore()
            if fogOrigEnd then pcall(function() Lighting.FogEnd = fogOrigEnd end) fogOrigEnd = nil end
            for a, d in pairs(atmoOrig) do
                if a and a.Parent then pcall(function() a.Density = d end) end
            end
            atmoOrig = setmetatable({}, { __mode = "k" })
        end
        onCleanup(fogRestore)
        Toggle(HPG.pVis, "Quitar niebla", false, function(on)
            S.noFog = on
            if on then
                fogOrigEnd = fogOrigEnd or Lighting.FogEnd
                startLoop("noFog", 0.4, function()
                    Lighting.FogEnd = 1e7
                    for _, a in ipairs(Lighting:GetChildren()) do
                        if a:IsA("Atmosphere") then
                            if atmoOrig[a] == nil then atmoOrig[a] = a.Density end
                            a.Density = 0
                        end
                    end
                end)
            else
                fogRestore()
            end
        end)

        -- Tercera persona (EXPERIMENTAL)
        local tp = { x = 2, y = 1, z = 6, wall = true }
        local tpConn
        local tpParts = {}
        local function tpCollect()
            tpParts = {}
            local c = getChar()
            if not c then return end
            for _, o in ipairs(c:GetDescendants()) do
                if o:IsA("Accessory") then
                    local h = o:FindFirstChild("Handle")
                    if h then tpParts[h] = h.Transparency end
                end
            end
            local head = c:FindFirstChild("Head")
            if head then tpParts[head] = head.Transparency end
        end
        local function tpStop()
            if tpConn then tpConn:Disconnect() tpConn = nil end
            for p, t in pairs(tpParts) do
                if p and p.Parent then pcall(function() p.Transparency = t p.LocalTransparencyModifier = t end) end
            end
        end
        onCleanup(tpStop)
        Toggle(HPG.pVis, "Tercera persona (EXP)", false, function(on)
            S.thirdPerson = on
            if on then
                tpCollect()
                if tpConn then tpConn:Disconnect() end
                tpConn = RunService.RenderStepped:Connect(function()
                    local cam = workspace.CurrentCamera
                    if not cam or not S.thirdPerson then return end
                    local target = cam.CFrame * CFrame.new(tp.x, tp.y, tp.z)
                    if tp.wall then
                        local rp = RaycastParams.new()
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        local c = getChar()
                        rp.FilterDescendantsInstances = c and { c } or {}
                        local origin = cam.CFrame.Position
                        local dir = target.Position - origin
                        if dir.Magnitude > 0.1 then
                            local hit = workspace:Raycast(origin, dir, rp)
                            if hit and hit.Instance.CanCollide then
                                target = CFrame.new(hit.Position - dir.Unit * 0.6) * (cam.CFrame - cam.CFrame.Position)
                            end
                        end
                    end
                    cam.CFrame = target
                    for p in pairs(tpParts) do
                        if p.Parent then
                            p.Transparency = 0
                            p.LocalTransparencyModifier = 0
                        end
                    end
                end)
            else
                tpStop()
            end
        end)
        track(LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.8)
            if alive and S.thirdPerson then tpCollect() end
        end))
        Slider(HPG.pVis, "3ª persona X", -10, 10, 2, function(v) tp.x = v end)
        Slider(HPG.pVis, "3ª persona Y", -5, 10, 1, function(v) tp.y = v end)
        Slider(HPG.pVis, "3ª persona Z", 0, 15, 6, function(v) tp.z = v end)
        Toggle(HPG.pVis, "3ª persona: anti-paredes", true, function(on) tp.wall = on end)

        -- Quitar sacudida / balanceo de cámara (necesita require en el ejecutor)
        local mg
        local function getMG()
            if mg then return mg end
            pcall(function()
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                local ui = pg and pg:FindFirstChild("MainUI")
                local init = ui and ui:FindFirstChild("Initiator")
                local mod = init and init:FindFirstChild("Main_Game")
                if mod and require then mg = require(mod) end
            end)
            return mg
        end
        track(RunService.RenderStepped:Connect(function()
            if S.noShake then
                local m = getMG()
                if m then pcall(function() m.csgo = CFrame.new() end) end
            end
        end))
        Toggle(HPG.pVis, "Quitar sacudida de cámara", false, function(on) S.noShake = on end)
        Toggle(HPG.pVis, "Quitar balanceo de cámara", false, function(on)
            local m = getMG()
            if m then pcall(function() m.spring.Speed = on and 9e9 or 8 end) end
        end)

        -- Sin jumpscares (renombra los módulos del cliente; se restauran al apagar)
        local JS = { "Glitch", "Void", "SpiderJumpscare" }
        local function clientMods()
            return ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules")
        end
        local function setJumpscares(on)
            local cm = clientMods()
            if not cm then return end
            for _, n in ipairs(JS) do
                pcall(function()
                    if on then
                        local m = cm:FindFirstChild(n, true)
                        if m and m:IsA("ModuleScript") then m.Name = n .. "_Disabled" end
                    else
                        local m = cm:FindFirstChild(n .. "_Disabled", true)
                        if m then m.Name = n end
                    end
                end)
            end
        end
        onCleanup(function() setJumpscares(false) end)
        Toggle(HPG.pVis, "Sin jumpscares (Glitch/Void/Timothy)", false, function(on) setJumpscares(on) end)
        Label(HPG.pVis, "Extras V6.1: si algo no responde en tu ejecutor, activa Debug en Config.", Color3.fromRGB(255, 190, 120))
    end

    ------------------------------------------------------------------
    -- V7: extras portados de Rush Hub (todo con pcall; no tocan lo demás)
    -- Door Reach, Quitar delay del armario, Escondites transparentes,
    -- Quitar cutscenes y Audio (pasos / interacción / Jammin)
    ------------------------------------------------------------------
    do
        local X = {
            doorReach = false, closetDelay = false, hideSpot = false, hideAlpha = 0.5,
            noSteps = false, noPrompt = false, noJam = false, noCut = false, lastCam = 0,
        }
        local soundOrig = setmetatable({}, { __mode = "k" }) -- Sound -> volumen original
        local muffleOrig = nil

        local function mainGame()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local mu = pg and pg:FindFirstChild("MainUI")
            local ini = mu and mu:FindFirstChild("Initiator")
            return ini and ini:FindFirstChild("Main_Game")
        end

        ---------------- Extras (Principal) ----------------
        Section(HPG.pMain, "Extras (Rush Hub)")

        -- Door Reach: dispara ClientOpen de las puertas a menos de 75 studs (loop solo si está activo)
        local doorTry = setmetatable({}, { __mode = "k" }) -- door -> última vez disparada | true = ya abierta
        local doorN = setmetatable({}, { __mode = "k" })
        Toggle(HPG.pMain, "Door Reach (abrir puertas desde lejos)", false, function(on)
            S.doorReach = on
            if on then
                startLoop("doorReach", 0.1, function()
                    local rooms, hrp = getRooms(), getHRP()
                    if not (rooms and hrp) then return end
                    local now = tick()
                    for _, room in ipairs(rooms:GetChildren()) do
                        local door = room:FindFirstChild("Door")
                        if door and doorTry[door] ~= true then
                            local part = door:FindFirstChild("Door")
                            local remote = door:FindFirstChild("ClientOpen")
                            if part and remote and part:IsA("BasePart") and remote:IsA("RemoteEvent")
                                and (hrp.Position - part.Position).Magnitude < 75
                                and (doorTry[door] == nil or now - doorTry[door] > 0.5) then
                                local snd = part:FindFirstChild("Open")
                                if doorTry[door] == nil and snd and snd:IsA("Sound") then
                                    snd.Played:Once(function() doorTry[door] = true end)
                                end
                                doorTry[door] = now
                                doorN[door] = (doorN[door] or 0) + 1
                                remote:FireServer()
                                if not (snd and snd:IsA("Sound")) and doorN[door] >= 3 then
                                    doorTry[door] = true
                                end
                            end
                        end
                    end
                end)
            end
        end)

        -- Quitar delay del armario: sale del escondite en cuanto te mueves
        Toggle(HPG.pMain, "Quitar delay del armario", false, function(on)
            S.closetDelay = on
            if on then
                startLoop("closetDelay", 0.1, function()
                    local ch, hum = getChar(), getHum()
                    if not (ch and hum) then return end
                    if hum.MoveDirection == Vector3.zero then return end
                    if ch:GetAttribute("Hiding") ~= true or ch:GetAttribute("AnimatingClient") == true then return end
                    local cp = ch:FindFirstChild("CollisionPart") or ch:FindFirstChild("Collision")
                    local root = ch:FindFirstChild("HumanoidRootPart")
                    if not ((cp and cp.Anchored) or (root and root.Anchored)) then return end
                    local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
                    local cam = rf and rf:FindFirstChild("CamLock")
                    if cam then cam:FireServer() end
                end)
            end
        end)

        ---------------- Extras visuales ----------------
        Section(HPG.pVis, "Extras visuales (Rush Hub)")

        -- Escondites transparentes
        local hideOrig = setmetatable({}, { __mode = "k" })
        local function restoreHide()
            local parts = {}
            for part in pairs(hideOrig) do parts[#parts + 1] = part end
            for _, part in ipairs(parts) do
                pcall(function() part.Transparency = hideOrig[part] end)
                hideOrig[part] = nil
            end
        end
        local function applyHide()
            restoreHide()
            if not X.hideSpot then return end
            pcall(function()
                local ch = getChar()
                local rooms = getRooms()
                if not (ch and rooms) or ch:GetAttribute("Hiding") ~= true then return end
                local cur = LocalPlayer:GetAttribute("CurrentRoom")
                local room = cur ~= nil and rooms:FindFirstChild(tostring(cur)) or nil
                if not room then return end
                for _, d in ipairs(room:GetDescendants()) do
                    if d.Name == "HiddenPlayer" and d:IsA("ObjectValue") and d.Value == ch then
                        local model = d:FindFirstAncestorOfClass("Model")
                        if model and model ~= room then
                            for _, p in ipairs(model:GetDescendants()) do
                                if p:IsA("BasePart") and p.Transparency < 1 then
                                    if hideOrig[p] == nil then hideOrig[p] = p.Transparency end
                                    p.Transparency = X.hideAlpha
                                end
                            end
                        end
                        break
                    end
                end
            end)
        end
        onCleanup(restoreHide)
        Toggle(HPG.pVis, "Escondites transparentes", false, function(on)
            X.hideSpot = on
            applyHide()
        end)
        Slider(HPG.pVis, "Transparencia del escondite", 0, 100, 50, function(v)
            X.hideAlpha = v / 100
            if X.hideSpot then applyHide() end
        end)

        -- Quitar cutscenes (renombra los módulos; se restauran al apagar)
        local CUT = {
            "Figure", "FigureEnd", "FigureHotelEnd", "FigureHotelFire",
            "SeekIntroFools", "SeekIntroHotel", "SeekIntroMines", "SeekIntroMines2",
            "SerewSeekDrain", "SewerSeekDrain", "SewerSeekLower", "SerewSeekLower",
            "GrumbleNestEnd", "EyestalkIntro",
        }
        local cutConns = {}
        local function cutRoots()
            local roots = {}
            local mg = mainGame()
            local rl = mg and mg:FindFirstChild("RemoteListener")
            local cs = rl and rl:FindFirstChild("Cutscenes")
            if cs then roots[#roots + 1] = cs end
            local fr = ReplicatedStorage:FindFirstChild("FloorReplicated")
            if fr then roots[#roots + 1] = fr end
            return roots
        end
        local function cutApply(o, on)
            if not o:IsA("ModuleScript") then return end
            if on then
                if table.find(CUT, o.Name) then o.Name = o.Name .. "_Disabled" end
            else
                local base = o.Name:match("^(.+)_Disabled$")
                if base and table.find(CUT, base) then o.Name = base end
            end
        end
        local function setCutscenes(on)
            X.noCut = on
            for _, c in ipairs(cutConns) do pcall(function() c:Disconnect() end) end
            cutConns = {}
            for _, root in ipairs(cutRoots()) do
                pcall(function()
                    for _, o in ipairs(root:GetChildren()) do cutApply(o, on) end
                    if on then
                        table.insert(cutConns, root.ChildAdded:Connect(function(o) cutApply(o, true) end))
                    end
                end)
            end
        end
        onCleanup(function() setCutscenes(false) end)
        Toggle(HPG.pVis, "Quitar cutscenes", false, function(on) setCutscenes(on) end)

        ---------------- Audio ----------------
        Section(HPG.pVis, "Audio")

        local function setVol(s, on)
            if not (s and s:IsA("Sound")) then return end
            if on then
                if soundOrig[s] == nil then soundOrig[s] = s.Volume end
                if s.Volume ~= 0 then s.Volume = 0 end
            elseif soundOrig[s] ~= nil then
                s.Volume = soundOrig[s]
                soundOrig[s] = nil
            end
        end
        local function applyPromptSounds(on)
            pcall(function()
                local mg = mainGame()
                if not mg then return end
                local ps = mg:FindFirstChild("PromptService")
                if ps then
                    for _, n in ipairs({ "Triggered", "Holding", "Notification" }) do
                        setVol(ps:FindFirstChild(n), on)
                    end
                end
                local rem = mg:FindFirstChild("Reminder")
                setVol(rem and rem:FindFirstChild("Caption"), on)
            end)
        end
        local function applyJam(on)
            pcall(function()
                local mg = mainGame()
                local health = mg and mg:FindFirstChild("Health")
                setVol(health and health:FindFirstChild("Jam"), on)
                local main = game:GetService("SoundService"):FindFirstChild("Main")
                local muffle = main and main:FindFirstChild("Jamming")
                if muffle and muffle:IsA("SoundEffect") then
                    if on then
                        if muffleOrig == nil then muffleOrig = muffle.Enabled end
                        muffle.Enabled = false
                    elseif muffleOrig ~= nil then
                        muffle.Enabled = muffleOrig
                        muffleOrig = nil
                    end
                end
            end)
        end

        -- pasos: silencia los Sound nuevos que aparecen en el personaje
        local stepConn
        local hideConn
        local function hookChar(ch)
            if stepConn then stepConn:Disconnect() stepConn = nil end
            if hideConn then hideConn:Disconnect() hideConn = nil end
            if not ch then return end
            stepConn = ch.ChildAdded:Connect(function(o)
                if X.noSteps and o:IsA("Sound") and o.Name == "Sound" then o.Volume = 0 end
            end)
            hideConn = ch:GetAttributeChangedSignal("Hiding"):Connect(function()
                if X.hideSpot then task.delay(0.15, applyHide) end
            end)
        end
        hookChar(LocalPlayer.Character)
        track(LocalPlayer.CharacterAdded:Connect(hookChar))
        onCleanup(function()
            if stepConn then stepConn:Disconnect() stepConn = nil end
            if hideConn then hideConn:Disconnect() hideConn = nil end
            applyPromptSounds(false)
            applyJam(false)
        end)

        Toggle(HPG.pVis, "Quitar sonido de pasos", false, function(on)
            X.noSteps = on
            if on then
                pcall(function()
                    local ch = getChar()
                    if ch then
                        for _, o in ipairs(ch:GetChildren()) do
                            if o:IsA("Sound") and o.Name == "Sound" then o.Volume = 0 end
                        end
                    end
                end)
            end
        end)
        Toggle(HPG.pVis, "Quitar sonidos de interacción", false, function(on)
            X.noPrompt = on
            applyPromptSounds(on)
            S.audioKeep = X.noPrompt or X.noJam
            if S.audioKeep then
                startLoop("audioKeep", 2, function()
                    if X.noPrompt then applyPromptSounds(true) end
                    if X.noJam then applyJam(true) end
                end)
            end
        end)
        Toggle(HPG.pVis, "Quitar música Jammin", false, function(on)
            X.noJam = on
            applyJam(on)
            S.audioKeep = X.noPrompt or X.noJam
            if S.audioKeep then
                startLoop("audioKeep", 2, function()
                    if X.noPrompt then applyPromptSounds(true) end
                    if X.noJam then applyJam(true) end
                end)
            end
        end)
    end

    -- Herramientas de staff (solo existen para el rol Staff/Dev: pestaña Dev)
    -- Todo es del lado del cliente: no necesita (ni toca) nada del servidor
    if HPG.pDev then
        local T = { target = nil }
        Section(HPG.pDev, "Herramientas de staff")
        local function tgtText()
            local t = T.target
            local name = (t and t.Parent) and t.Name or "—"
            return "🎯 " .. tr("Jugador objetivo") .. ": " .. name
        end
        local tgtLbl = Label(HPG.pDev, tgtText)
        local function refreshTgt() tgtLbl.Text = tgtText() end
        local function targetChar()
            local t = T.target
            return (t and t.Parent) and t.Character or nil
        end

        Button(HPG.pDev, "⏭ Siguiente jugador", function()
            local list = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then list[#list + 1] = p end
            end
            table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
            if #list == 0 then
                T.target = nil
                refreshTgt()
                notify("⚠️ No hay otros jugadores", "warn", 2)
                return
            end
            local idx = 0
            for i, p in ipairs(list) do
                if p == T.target then idx = i break end
            end
            T.target = list[(idx % #list) + 1]
            refreshTgt()
        end)
        Button(HPG.pDev, "📍 TP al jugador", function()
            local ch, hrp = targetChar(), getHRP()
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            if not (root and hrp) then
                notify("⚠️ Elige un jugador primero", "warn", 2)
                return
            end
            hrp.CFrame = root.CFrame * CFrame.new(0, 0, 3)
        end)

        local function stopSpec()
            pcall(function()
                local cam, hum = workspace.CurrentCamera, getHum()
                if cam and hum then cam.CameraSubject = hum end
            end)
        end
        onCleanup(stopSpec)
        Toggle(HPG.pDev, "👁 Espectar jugador", false, function(on)
            S.staffSpec = on
            if on then
                startLoop("staffSpec", 0.25, function()
                    local ch = targetChar()
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    local cam = workspace.CurrentCamera
                    if hum and cam and cam.CameraSubject ~= hum then cam.CameraSubject = hum end
                end)
            else
                stopSpec()
            end
        end)

        Button(HPG.pDev, "📋 Copiar ID del jugador", function()
            local t = T.target
            if not (t and t.Parent) then
                notify("⚠️ Elige un jugador primero", "warn", 2)
                return
            end
            pcall(function() if setclipboard then setclipboard(tostring(t.UserId)) end end)
            notify("📋 ID copiado: %s", "ok", 2, tostring(t.UserId))
        end)
        Button(HPG.pDev, "ℹ️ Info del jugador", function()
            local t = T.target
            if not (t and t.Parent) then
                notify("⚠️ Elige un jugador primero", "warn", 2)
                return
            end
            local ch = t.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local root = ch and ch:FindFirstChild("HumanoidRootPart")
            local hrp = getHRP()
            local dist = (root and hrp) and tostring(math.floor((root.Position - hrp.Position).Magnitude)) or "?"
            notify("ℹ️ %s | Vida %s | %s studs | ID %s", "info", 6,
                t.Name, hum and tostring(math.floor(hum.Health)) or "?", dist, tostring(t.UserId))
        end)

        local tags = {}
        local function clearTags()
            for p, g in pairs(tags) do
                pcall(function() g:Destroy() end)
                tags[p] = nil
            end
        end
        onCleanup(clearTags)
        Toggle(HPG.pDev, "🧭 ESP de jugadores (vida / distancia)", false, function(on)
            S.staffEsp = on
            if on then
                startLoop("staffEsp", 0.3, function()
                    local hrp = getHRP()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            local ch = p.Character
                            local head = ch and ch:FindFirstChild("Head")
                            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                            local g = tags[p]
                            if head and hum then
                                if not g or not g.Parent or g.Parent ~= head then
                                    if g then g:Destroy() end
                                    g = new("BillboardGui", {
                                        Name = "RH_StaffTag", AlwaysOnTop = true,
                                        Size = UDim2.new(0, 150, 0, 34), StudsOffset = Vector3.new(0, 2.6, 0),
                                    }, head)
                                    new("TextLabel", {
                                        Name = "L", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                                        TextColor3 = Color3.fromRGB(255, 215, 90), TextStrokeTransparency = 0.4,
                                        Font = Enum.Font.GothamBold, TextSize = 13,
                                    }, g)
                                    tags[p] = g
                                end
                                local d = hrp and math.floor((head.Position - hrp.Position).Magnitude) or 0
                                g.L.Text = p.Name .. "\n❤ " .. math.floor(hum.Health) .. "  •  " .. d .. "m"
                            elseif g then
                                g:Destroy()
                                tags[p] = nil
                            end
                        end
                    end
                    for p, g in pairs(tags) do
                        if not p.Parent then
                            g:Destroy()
                            tags[p] = nil
                        end
                    end
                end)
            else
                clearTags()
            end
        end)

        Button(HPG.pDev, "🌐 Probar StatsDB (servidor de stats)", function()
            if not Net.configured then
                notify("🌐 StatsDB desactivado: pon tu URL en CONFIG.StatsDB", "warn", 4)
                return
            end
            task.spawn(function()
                local t0 = os.clock()
                local r = HNET.dbCall("GET", "hub/executions")
                if r then
                    notify("🌐 StatsDB OK (%s ms)", "ok", 3, tostring(math.floor((os.clock() - t0) * 1000)))
                else
                    notify("🌐 StatsDB no responde", "danger", 4)
                end
            end)
        end)
    end

    -- Verified: aviso al abrir el hub (solo el owner)
    if isVerifiedUser() and not isRebuild then
        notify("✔ Verified Owner: bienvenido, %s", "ok", 5, LocalPlayer.DisplayName)
    end


    ------------------------------------------------------------------
    -- V7: extras nuevos (todo con pcall; no tocan lo demás)
    ------------------------------------------------------------------
    do
        pcall(function()
            local en = {
                ["Config y sesión (V7)"] = "Config & session (V7)",
                ["💾 Guardar config"] = "💾 Save config", ["📂 Cargar config"] = "📂 Load config",
                ["Auto-cargar config al iniciar"] = "Auto-load config on start",
                ["💾 Config guardada"] = "💾 Config saved", ["📂 Config cargada"] = "📂 Config loaded",
                ["⚠ No hay config guardada"] = "⚠ No saved config", ["⚠ Tu ejecutor no soporta archivos"] = "⚠ Your executor has no file support",
                ["Auto reconectar si te expulsan"] = "Auto rejoin if disconnected",
                ["Desbloquear FPS (240)"] = "Unlock FPS (240)", ["⚠ Tu ejecutor no soporta setfpscap"] = "⚠ Your executor doesn't support setfpscap",
                ["🌐 Server Hop (menos jugadores)"] = "🌐 Server Hop (fewer players)",
                ["🌐 Buscando servidor..."] = "🌐 Looking for a server...", ["⚠ No se encontró servidor"] = "⚠ No server found",
                ["🧠 Liberar memoria"] = "🧠 Free memory", ["🧠 Memoria en uso: %d KB"] = "🧠 Memory in use: %d KB",
                ["🚨 Pánico (apagar todo)"] = "🚨 Panic (shut everything down)",
                ["Seguridad: pulsa END dos veces para el modo pánico (PC). En móvil usa el botón."] = "Security: press END twice for panic mode (PC). On mobile use the button.",
                ["⛔ Sesión inválida: apagando hub"] = "⛔ Invalid session: shutting the hub down",
            }
            local pt = {
                ["Config y sesión (V7)"] = "Config e sessão (V7)",
                ["💾 Guardar config"] = "💾 Salvar config", ["📂 Cargar config"] = "📂 Carregar config",
                ["Auto-cargar config al iniciar"] = "Auto-carregar config ao iniciar",
                ["💾 Config guardada"] = "💾 Config salva", ["📂 Config cargada"] = "📂 Config carregada",
                ["⚠ No hay config guardada"] = "⚠ Sem config salva", ["⚠ Tu ejecutor no soporta archivos"] = "⚠ Seu executor não suporta arquivos",
                ["Auto reconectar si te expulsan"] = "Auto reconectar se for expulso",
                ["Desbloquear FPS (240)"] = "Desbloquear FPS (240)", ["⚠ Tu ejecutor no soporta setfpscap"] = "⚠ Seu executor não suporta setfpscap",
                ["🌐 Server Hop (menos jugadores)"] = "🌐 Server Hop (menos jogadores)",
                ["🌐 Buscando servidor..."] = "🌐 Procurando servidor...", ["⚠ No se encontró servidor"] = "⚠ Nenhum servidor encontrado",
                ["🧠 Liberar memoria"] = "🧠 Liberar memória", ["🧠 Memoria en uso: %d KB"] = "🧠 Memória em uso: %d KB",
                ["🚨 Pánico (apagar todo)"] = "🚨 Pânico (desligar tudo)",
                ["Seguridad: pulsa END dos veces para el modo pánico (PC). En móvil usa el botón."] = "Segurança: aperte END duas vezes para o modo pânico (PC). No celular use o botão.",
                ["⛔ Sesión inválida: apagando hub"] = "⛔ Sessão inválida: desligando o hub",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        local HttpService = HNET.HttpService
        local CFG_FILE = "RoshanHub_Config.json"
        local SKIP = { "Hide UI", "Auto-cargar config", "Freecam", "Revive" }            -- nunca se restauran solos
        local RISKY = { "EXPERIMENTAL", "riesgo", "BETA", "SOON" }  -- tampoco las funciones arriesgadas
        local function has(name, list)
            for _, t in ipairs(list) do if name:find(t, 1, true) then return true end end
            return false
        end
        local function keyed()
            local seen, out = {}, {}
            for _, e in ipairs(HUI.named or {}) do
                seen[e.name] = (seen[e.name] or 0) + 1
                out[#out + 1] = { key = seen[e.name] > 1 and (e.name .. "#" .. seen[e.name]) or e.name, e = e }
            end
            return out
        end

        Section(HPG.pCfg, "Config y sesión (V7)")

        local function keyedSliders()
            local seen, out = {}, {}
            for _, e in ipairs(HUI.sliders or {}) do
                seen[e.name] = (seen[e.name] or 0) + 1
                out[#out + 1] = { key = seen[e.name] > 1 and (e.name .. "#" .. seen[e.name]) or e.name, e = e }
            end
            return out
        end
        local function readCfg()
            local ok, data = pcall(function()
                if isfile and readfile and isfile(CFG_FILE) then
                    return HttpService:JSONDecode(readfile(CFG_FILE))
                end
            end)
            if ok and type(data) == "table" and type(data.on) == "table" then return data end
        end
        local function saveCfg()
            if not writefile then notify("⚠ Tu ejecutor no soporta archivos", "warn", 3) return end
            local on = {}
            for _, it in ipairs(keyed()) do
                if not has(it.e.name, SKIP) and it.e.get() then on[#on + 1] = it.key end
            end
            local sl = {}
            for _, it in ipairs(keyedSliders()) do sl[it.key] = it.e.get() end
            local ok = pcall(function()
                writefile(CFG_FILE, HttpService:JSONEncode({ v = "7", auto = HST.cfgAuto == true, on = on, sl = sl }))
            end)
            if ok then notify("💾 Config guardada", "ok", 2) end
        end
        local function applyCfg(data, silent)
            if not data then
                if not silent then notify("⚠ No hay config guardada", "warn", 3) end
                return
            end
            local want = {}
            for _, k in ipairs(data.on) do if type(k) == "string" then want[k] = true end end
            task.spawn(function()
                if type(data.sl) == "table" then -- valores de sliders primero
                    for _, it in ipairs(keyedSliders()) do
                        local v = data.sl[it.key]
                        if type(v) == "number" then pcall(it.e.set, v) end
                    end
                end
                for _, it in ipairs(keyed()) do
                    if not alive then return end
                    if want[it.key] and not has(it.e.name, SKIP) and not has(it.e.name, RISKY) and not it.e.get() then
                        pcall(it.e.set, true)
                        task.wait(0.04)
                    end
                end
                if not silent then notify("📂 Config cargada", "ok", 2) end
            end)
        end
        Button(HPG.pCfg, "💾 Guardar config", saveCfg)
        Button(HPG.pCfg, "📂 Cargar config", function() applyCfg(readCfg(), false) end)
        local setAuto = Toggle(HPG.pCfg, "Auto-cargar config al iniciar", false, function(on) HST.cfgAuto = on end)
        do
            local data = readCfg()
            if data and data.auto == true then
                HST.cfgAuto = true
                setAuto(true, true)
                task.delay(1.5, function() if alive then applyCfg(data, true) end end)
            end
        end

        -- Auto reconectar (solo una vez por sesión, para no entrar en bucle)
        Toggle(HPG.pCfg, "Auto reconectar si te expulsan", false, function(on)
            S.autoRejoin = on
            if on and not HST.arConn then
                HST.arConn = game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
                    if S.autoRejoin and not HST.arFired and type(msg) == "string" and msg ~= "" then
                        HST.arFired = true
                        task.wait(2)
                        pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
                    end
                end)
            elseif not on and HST.arConn then
                HST.arConn:Disconnect()
                HST.arConn = nil
            end
        end)
        onCleanup(function() if HST.arConn then HST.arConn:Disconnect() HST.arConn = nil end end)

        -- Desbloquear FPS: prueba varios métodos y MIDE los FPS reales para decirte si funcionó
        pcall(function()
            local en = {
                ["Desbloquear FPS"] = "Unlock FPS", ["Tope de FPS"] = "FPS cap", ["🎞 Medir FPS"] = "🎞 Measure FPS",
                ["🎞 Tope %d → FPS medidos: %d"] = "🎞 Cap %d → measured FPS: %d",
                ["⚠ Siguen ~60 FPS: lo limita tu monitor, VSync, el cliente o el celular"] = "⚠ Still ~60 FPS: your monitor, VSync, the client or the phone limits it",
                ["⚠ Tu ejecutor no soporta cambiar el tope de FPS"] = "⚠ Your executor can't change the FPS cap",
                ["Los celulares casi siempre se quedan en 60 o 120 FPS aunque subas el tope."] = "Phones almost always stay at 60 or 120 FPS even if you raise the cap.",
            }
            local pt = {
                ["Desbloquear FPS"] = "Desbloquear FPS", ["Tope de FPS"] = "Limite de FPS", ["🎞 Medir FPS"] = "🎞 Medir FPS",
                ["🎞 Tope %d → FPS medidos: %d"] = "🎞 Limite %d → FPS medidos: %d",
                ["⚠ Siguen ~60 FPS: lo limita tu monitor, VSync, el cliente o el celular"] = "⚠ Ainda ~60 FPS: limitado pelo monitor, VSync, cliente ou celular",
                ["⚠ Tu ejecutor no soporta cambiar el tope de FPS"] = "⚠ Seu executor não consegue mudar o limite de FPS",
                ["Los celulares casi siempre se quedan en 60 o 120 FPS aunque subas el tope."] = "Celulares quase sempre ficam em 60 ou 120 FPS mesmo subindo o limite.",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)
        S.fpsTarget = 240
        local function setCap(n)
            local fn = setfpscap or set_fps_cap or (syn and syn.set_fps_cap)
            local ok = fn ~= nil and pcall(fn, n)
            if not ok and setfflag then ok = pcall(setfflag, "DFIntTaskSchedulerTargetFps", tostring(n)) end
            return ok == true
        end
        local function measureFps(sec, cb)
            task.spawn(function()
                local frames, t0 = 0, os.clock()
                local conn = RunService.RenderStepped:Connect(function() frames = frames + 1 end)
                task.wait(sec)
                conn:Disconnect()
                cb(math.floor(frames / math.max(os.clock() - t0, 0.001) + 0.5))
            end)
        end
        local function applyFps(n)
            if not setCap(n) then
                notify("⚠ Tu ejecutor no soporta cambiar el tope de FPS", "warn", 4)
                return false
            end
            measureFps(2, function(fps)
                if not alive then return end
                notify("🎞 Tope %d → FPS medidos: %d", "info", 4, n, fps)
                if n > 70 and fps <= 62 then notify("⚠ Siguen ~60 FPS: lo limita tu monitor, VSync, el cliente o el celular", "warn", 5) end
            end)
            return true
        end
        Toggle(HPG.pCfg, "Desbloquear FPS", false, function(on)
            S.fpsUnlock = on
            if on then
                if not applyFps(S.fpsTarget) then S.fpsUnlock = false end
            else
                setCap(60)
            end
        end)
        local fpsDebounce = 0
        Slider(HPG.pCfg, "Tope de FPS", 60, 360, 240, function(v)
            S.fpsTarget = v
            if S.fpsUnlock then
                fpsDebounce = fpsDebounce + 1
                local mine = fpsDebounce
                task.delay(0.6, function() if alive and mine == fpsDebounce and S.fpsUnlock then setCap(v) end end)
            end
        end)
        Button(HPG.pCfg, "🎞 Medir FPS", function()
            measureFps(2, function(fps) notify("🎞 Tope %d → FPS medidos: %d", "info", 4, S.fpsUnlock and S.fpsTarget or 60, fps) end)
        end)
        Label(HPG.pCfg, "Los celulares casi siempre se quedan en 60 o 120 FPS aunque subas el tope.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() if S.fpsUnlock then setCap(60) end end)

        -- Server Hop (útil sobre todo en el lobby: las runs de Doors son servidores privados)
        local hopping = false
        Button(HPG.pCfg, "🌐 Server Hop (menos jugadores)", function()
            if hopping then return end
            hopping = true
            notify("🌐 Buscando servidor...", "info", 2)
            task.spawn(function()
                local ok, body = pcall(function()
                    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)
                    local req = request or http_request or (syn and syn.request)
                    if req then return req({ Url = url, Method = "GET" }).Body end
                    return game:HttpGet(url)
                end)
                local list = {}
                if ok and type(body) == "string" then
                    local okj, data = pcall(function() return HttpService:JSONDecode(body) end)
                    if okj and type(data) == "table" and type(data.data) == "table" then
                        for _, sv in ipairs(data.data) do
                            if type(sv) == "table" and sv.id ~= game.JobId and tonumber(sv.playing) and tonumber(sv.maxPlayers)
                                and sv.playing < sv.maxPlayers - 1 then
                                list[#list + 1] = sv.id
                            end
                        end
                    end
                end
                if #list > 0 then
                    local pick = list[math.random(1, math.min(#list, 5))]
                    pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, pick, LocalPlayer) end)
                else
                    notify("⚠ No se encontró servidor", "warn", 3)
                end
                task.wait(4)
                hopping = false
            end)
        end)

        Button(HPG.pCfg, "🧠 Liberar memoria", function()
            pcall(HESP.pruneESP)
            pcall(collectgarbage, "collect")
            local kb = 0
            pcall(function() kb = math.floor(collectgarbage("count")) end)
            notify("🧠 Memoria en uso: %d KB", "ok", 3, kb)
        end)

        -- Pánico: apaga y borra todo de golpe (botón, o END dos veces en PC)
        local function panic()
            HNET.shutdown()
            getgenv().RoshanHubLoaded = false
        end
        Button(HPG.pCfg, "🚨 Pánico (apagar todo)", function() task.spawn(panic) end, Color3.fromRGB(150, 30, 30))
        Label(HPG.pCfg, "Seguridad: pulsa END dos veces para el modo pánico (PC). En móvil usa el botón.")
        local lastEnd = 0
        track(UserInputService.InputBegan:Connect(function(input, gp)
            if input.KeyCode == Enum.KeyCode.End then
                local now = os.clock()
                if now - lastEnd < 1 then task.spawn(panic) end
                lastEnd = now
            end
        end))

        -- Vigilante: revalida la sesión cada 25 s; si alguien la manipula en caliente, se castiga y se apaga.
        -- Señuelos: nadie legítimo toca estas banderas; quien parchea "a ciegas" las activa.
        getgenv().RoshanKeyValid, getgenv().RoshanVIP = false, false
        local function serverOk(auth)
            if auth.owner or type(CONFIG.KeyServer) ~= "string" or not CONFIG.KeyServer:match("^https://") or not HNET.httpReq then
                return true
            end
            local ok, res = pcall(HNET.httpReq, {
                Url = CONFIG.KeyServer .. "?h=" .. auth.h .. "&u=" .. tostring(LocalPlayer.UserId) .. "&j=" .. tostring(game.JobId),
                Method = "GET",
            })
            if not ok or type(res) ~= "table" or (res.StatusCode or 0) ~= 200 then return not CONFIG.KeyServerStrict end
            local okj, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if not okj or type(data) ~= "table" then return not CONFIG.KeyServerStrict end
            return data.valid == true
        end
        local function tamper()
            pcall(KeyGuard.punish)
            notify("⛔ Sesión inválida: apagando hub", "danger", 3)
            task.wait(1.5)
            panic()
        end
        task.spawn(function()
            local tick25 = 0
            task.wait(3)
            if alive and not serverOk(HST.auth) then tamper() return end
            while alive do
                task.wait(25)
                tick25 = tick25 + 1
                if not alive then return end
                if getgenv().RoshanKeyValid == true or getgenv().RoshanVIP == true
                    or not KeyGuard.revalidate(HST.auth) then
                    tamper()
                    return
                end
                if tick25 % 12 == 0 and not serverOk(HST.auth) then tamper() return end -- cada ~5 min
            end
        end)
    end


    ------------------------------------------------------------------
    -- V7: ideas tomadas de Nova Hub, reescritas (todo con pcall y limpieza al apagar)
    ------------------------------------------------------------------
    do
        pcall(function()
            local en = {
                ["Juego (V7)"] = "Game (V7)", ["Ir a modo (solo en el lobby)"] = "Go to mode (lobby only)",
                ["⚠ Pulsa otra vez para confirmar"] = "⚠ Press again to confirm",
                ["⚠ Remote no encontrado (¿estás en el lobby?)"] = "⚠ Remote not found (are you in the lobby?)",
                ["Auto Heartbeat (minijuego)"] = "Auto Heartbeat (minigame)",
                ["⚠ Tu ejecutor no soporta hookmetamethod"] = "⚠ Your executor doesn't support hookmetamethod",
                ["Revive infinito (solo modos con revives gratis)"] = "Infinite Revive (free-revive modes only)",
                ["Crucifijo infinito (riesgo)"] = "Infinite Crucifix (risky)",
                ["Funciona con A-60, A-120, Rush y Ambush. Puede fallar."] = "Works on A-60, A-120, Rush and Ambush. It can fail.",
                ["Anti Seek Flood (Mines)"] = "Anti Seek Flood (Mines)", ["Anti Dread"] = "Anti Dread",
                ["Freecam (PC: clic derecho para mirar | móvil: arrastra)"] = "Freecam (PC: right-click to look | mobile: drag)",
            }
            local pt = {
                ["Juego (V7)"] = "Jogo (V7)", ["Ir a modo (solo en el lobby)"] = "Ir para modo (só no lobby)",
                ["⚠ Pulsa otra vez para confirmar"] = "⚠ Toque de novo para confirmar",
                ["⚠ Remote no encontrado (¿estás en el lobby?)"] = "⚠ Remote não encontrado (você está no lobby?)",
                ["Auto Heartbeat (minijuego)"] = "Auto Heartbeat (minijogo)",
                ["⚠ Tu ejecutor no soporta hookmetamethod"] = "⚠ Seu executor não suporta hookmetamethod",
                ["Revive infinito (solo modos con revives gratis)"] = "Revive infinito (só modos com revives grátis)",
                ["Crucifijo infinito (riesgo)"] = "Crucifixo infinito (risco)",
                ["Funciona con A-60, A-120, Rush y Ambush. Puede fallar."] = "Funciona com A-60, A-120, Rush e Ambush. Pode falhar.",
                ["Anti Seek Flood (Mines)"] = "Anti Seek Flood (Mines)", ["Anti Dread"] = "Anti Dread",
                ["Freecam (PC: clic derecho para mirar | móvil: arrastra)"] = "Freecam (PC: botão direito para olhar | celular: arraste)",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        local function RF() return ReplicatedStorage:FindFirstChild("RemotesFolder") end
        local function fire(name, ...)
            local rf = RF()
            local r = rf and rf:FindFirstChild(name)
            if r and r:IsA("RemoteEvent") then
                return pcall(r.FireServer, r, ...)
            end
            return false
        end
        -- acciones que cambian la partida piden pulsar dos veces
        local armed = {}
        local function confirm(key, fn)
            return function()
                if armed[key] and os.clock() - armed[key] < 2 then
                    armed[key] = nil
                    fn()
                    return
                end
                armed[key] = os.clock()
                notify("⚠ Pulsa otra vez para confirmar", "warn", 2)
            end
        end

        -- ===== Botones de partida =====
        Section(HPG.pMain, "Juego (V7)")
        Button(HPG.pMain, "♻ Revive", confirm("rv", function()
            if not fire("Revive") then notify("⚠ Remote no encontrado (¿estás en el lobby?)", "warn", 3) end
        end))
        Button(HPG.pMain, "▶ Play Again", confirm("pa", function()
            if not fire("PlayAgain") then notify("⚠ Remote no encontrado (¿estás en el lobby?)", "warn", 3) end
        end))
        Button(HPG.pMain, "🏠 Lobby", confirm("lb", function()
            if not fire("Lobby") then notify("⚠ Remote no encontrado (¿estás en el lobby?)", "warn", 3) end
        end))

        Toggle(HPG.pMain, "Revive infinito (solo modos con revives gratis)", false, function(on)
            S.infRevive = on
            if on then
                startLoop("infRevive", 0.5, function()
                    if LocalPlayer:GetAttribute("Alive") == false then fire("Revive") end
                end)
            end
        end)

        -- ===== Hook único (Auto Heartbeat + Crouch del Godmode) =====
        -- Vive en getgenv: al reconstruir el hub se reutiliza (no se apilan hooks) y, apagado, solo reenvía.
        local function ensureHook()
            local st = getgenv().RH_HookState
            if st then return st end
            if not (hookmetamethod and getnamecallmethod) then return nil end
            st = { hb = false, crouch = false }
            getgenv().RH_HookState = st
            local ok = pcall(function()
                local old
                local wrap = newcclosure or function(f) return f end
                old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
                    if (st.hb or st.crouch) and getnamecallmethod() == "FireServer" and typeof(self) == "Instance" then
                        local n = self.Name
                        if st.hb and n == "ClutchHeartbeat" then return old(self, true) end
                        if st.crouch and n == "Crouch" then return old(self, true, true) end
                    end
                    return old(self, ...)
                end))
            end)
            if not ok then getgenv().RH_HookState = nil return nil end
            return st
        end
        Toggle(HPG.pMain, "Auto Heartbeat (minijuego)", false, function(on)
            S.autoHeartbeat = on
            local st = ensureHook()
            if on and not st then
                notify("⚠ Tu ejecutor no soporta hookmetamethod", "warn", 3)
                S.autoHeartbeat = false
                return
            end
            if st then st.hb = on end
        end)
        onCleanup(function()
            local st = getgenv().RH_HookState
            if st then st.hb, st.crouch = false, false end
        end)

        -- ===== Ir a modo (CreateElevator, solo funciona en el lobby) =====
        Section(HPG.pFloor, "Ir a modo (solo en el lobby)")
        local MODES = {
            { "🏨 Hotel", "Hotel" }, { "⛏ Mines", "Mines" }, { "🚪 Rooms", "Rooms" },
            { "🔙 Backdoors", "Backdoor" }, { "🌳 Outdoors", "Garden" }, { "📼 Retro", "Retro" },
            { "💀 Super Hard", "SuperHardMode" }, { "♾ Endless", "Endless" }, { "📅 Daily Run", "Daily" },
        }
        for _, m in ipairs(MODES) do
            Button(HPG.pFloor, "→ " .. m[1], confirm("tp" .. m[2], function()
                local ok = fire("CreateElevator", {
                    Mods = {}, Settings = {}, Destination = m[2], FriendsOnly = false, MaxPlayers = "1",
                })
                if not ok then notify("⚠ Remote no encontrado (¿estás en el lobby?)", "warn", 3) end
            end))
        end

        -- ===== Anti extra =====
        local floodConn
        local function floodApply(v, val)
            if v.Name == "SeekFloodline" and v:IsA("BasePart") then v.CanCollide = val end
        end
        Toggle(HPG.pAnti, "Anti Seek Flood (Mines)", false, function(on)
            S.antiFlood = on
            if floodConn then floodConn:Disconnect() floodConn = nil end
            local rooms = getRooms()
            if rooms then
                for _, v in ipairs(rooms:GetDescendants()) do pcall(floodApply, v, on) end
                if on then floodConn = rooms.DescendantAdded:Connect(function(v) pcall(floodApply, v, true) end) end
            end
        end)
        onCleanup(function() if floodConn then floodConn:Disconnect() floodConn = nil end end)

        Toggle(HPG.pAnti, "Anti Dread", false, function(on)
            S.antiDread = on
            if on then
                startLoop("antiDread", 2, function()
                    local d = LocalPlayer:FindFirstChild("Dread", true)
                    if d then d.Name = "_Dread" end
                end)
            else
                local d = LocalPlayer:FindFirstChild("_Dread", true)
                if d then d.Name = "Dread" end
            end
        end)

        local CRUC = { RushMoving = 90, AmbushMoving = 160, A60 = 140, A120 = 99, GlitchRush = 150, GlitchAmbush = 110 }
        local crucBusy = false
        Toggle(HPG.pAnti, "Crucifijo infinito (riesgo)", false, function(on)
            S.infCruc = on
            if on then
                startLoop("infCruc", 0.12, function()
                    if crucBusy then return end
                    local char, hrp = getChar(), getHRP()
                    local tool = char and char:FindFirstChild("Crucifix")
                    local drop = RF() and RF():FindFirstChild("DropItem")
                    if not (tool and hrp and drop) then return end
                    for _, e in ipairs(workspace:GetChildren()) do
                        local range = CRUC[e.Name]
                        if range and e:IsA("Model") and e.PrimaryPart then
                            local tp = e.PrimaryPart.Position
                            if (hrp.Position - tp).Magnitude < range + 40 then
                                local params = RaycastParams.new()
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                params.FilterDescendantsInstances = { char, e }
                                if not workspace:Raycast(hrp.Position, tp - hrp.Position, params) then
                                    crucBusy = true
                                    task.spawn(function()
                                        pcall(drop.FireServer, drop, tool)
                                        local t0 = tick()
                                        repeat
                                            task.wait(0.01)
                                            local ds = workspace:FindFirstChild("Drops")
                                            local dc = ds and ds:FindFirstChild("Crucifix")
                                            local pr = dc and dc:FindFirstChildOfClass("ProximityPrompt")
                                            if pr and fireproximityprompt then pcall(fireproximityprompt, pr) end
                                            local c2 = getChar()
                                        until (c2 and c2:FindFirstChild("Crucifix")) or tick() - t0 > 1.2 or not alive
                                        crucBusy = false
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end)
        Label(HPG.pAnti, "Funciona con A-60, A-120, Rush y Ambush. Puede fallar.", Color3.fromRGB(190, 180, 225))

        -- ================= V7: más funciones (Godmode de Nova, Delete Seek/Figure, Infinite Items...) =================
        pcall(function()
            local en = {
                ["Godmode (Nova) (riesgo)"] = "Godmode (Nova) (risky)",
                ["Puede hacerte retroceder o no funcionar según la versión del juego. Actívalo en una zona segura."] = "It can lag you back or not work depending on the game version. Enable it somewhere safe.",
                ["Borrar Seek (FE)"] = "Delete Seek (FE)", ["Borrando Seek..."] = "Deleting Seek...",
                ["✅ Seek eliminado"] = "✅ Seek deleted", ["⚠ No se pudo quitar Seek"] = "⚠ Failed to remove Seek",
                ["⚠ Tu ejecutor no soporta firetouchinterest"] = "⚠ Your executor doesn't support firetouchinterest",
                ["Borrar Figure (FE, Mines)"] = "Delete Figure (FE, Mines)", ["⚠ Tu ejecutor no soporta isnetworkowner"] = "⚠ Your executor doesn't support isnetworkowner",
                ["✅ Figure eliminado"] = "✅ Figure deleted",
                ["Items infinitos (ganzúa / llave / tijeras)"] = "Infinite Items (lockpick / key / shears)",
                ["Si no responde con Auto Interact, usa la tecla normal del juego (E) y toca varias veces."] = "If it doesn't work with Auto Interact, use the game's normal key (E) and keep tapping.",
                ["Prompt Clip (interactuar a través de paredes)"] = "Prompt Clip (interact through walls)",
                ["Velocidad al escalar"] = "Climbing speed", ["Velocidad de escalada"] = "Climb speed",
            }
            local pt = {
                ["Godmode (Nova) (riesgo)"] = "Godmode (Nova) (risco)",
                ["Puede hacerte retroceder o no funcionar según la versión del juego. Actívalo en una zona segura."] = "Pode te puxar de volta ou não funcionar conforme a versão do jogo. Ative em um local seguro.",
                ["Borrar Seek (FE)"] = "Apagar Seek (FE)", ["Borrando Seek..."] = "Apagando Seek...",
                ["✅ Seek eliminado"] = "✅ Seek eliminado", ["⚠ No se pudo quitar Seek"] = "⚠ Não foi possível remover o Seek",
                ["⚠ Tu ejecutor no soporta firetouchinterest"] = "⚠ Seu executor não suporta firetouchinterest",
                ["Borrar Figure (FE, Mines)"] = "Apagar Figure (FE, Mines)", ["⚠ Tu ejecutor no soporta isnetworkowner"] = "⚠ Seu executor não suporta isnetworkowner",
                ["✅ Figure eliminado"] = "✅ Figure eliminado",
                ["Items infinitos (ganzúa / llave / tijeras)"] = "Itens infinitos (gazua / chave / tesoura)",
                ["Si no responde con Auto Interact, usa la tecla normal del juego (E) y toca varias veces."] = "Se não responder com Auto Interact, use a tecla normal do jogo (E) e toque várias vezes.",
                ["Prompt Clip (interactuar a través de paredes)"] = "Prompt Clip (interagir através de paredes)",
                ["Velocidad al escalar"] = "Velocidade ao escalar", ["Velocidad de escalada"] = "Velocidade de escalada",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        -- ===== GODMODE (método de Nova: hitbox mínima + cuerpo bajo + Crouch falso) =====
        local god = { sizeOn = Vector3.new(1, 1, 4), sizeOff = Vector3.new(5.5, 3, 3) }
        local function godPart(c, n) return c and c:FindFirstChild(n) end
        local function godEnter()
            local c = getChar()
            if not c then return end
            if RF() then
                local cp = godPart(c, "CollisionPart")
                if cp then pcall(function() c:PivotTo(cp.CFrame * CFrame.new(0, -2, 0)) end) end
            else
                local col = godPart(c, "Collision")
                if col then pcall(function() col.Position = col.Position - Vector3.new(0, 4, 0) end) end
            end
        end
        local function godStep(dt)
            local c, h = getChar(), getHum()
            if not (c and h) then return end
            if RF() then
                local lt = godPart(c, "LowerTorso")
                local root = lt and lt:FindFirstChild("Root")
                if root and root.C1 ~= CFrame.new(0, -2.3, 0) then root.C1 = CFrame.new(0, -2.3, 0) end
                if h.HipHeight ~= 0.22 then h.HipHeight = 0.22 end
                local col = godPart(c, "Collision")
                if col then
                    if col.Size ~= god.sizeOn then col.Size = god.sizeOn end
                    local cc = col:FindFirstChild("CollisionCrouch")
                    if cc and cc.Size ~= god.sizeOn then cc.Size = god.sizeOn end
                end
            end
            if not c:FindFirstChild("CollisionClone") then
                local cp = godPart(c, "CollisionPart")
                if cp then
                    local cl = cp:Clone()
                    cl.Name, cl.RootPriority, cl.Anchored, cl.CanCollide = "CollisionClone", 127, false, false
                    local cr = cl:FindFirstChild("CollisionCrouch")
                    if cr then cr:Destroy() end
                    cl.Parent = c
                end
            end
            if not god.hook then -- sin hook: Crouch falso a mano
                god.t = (god.t or 0) + dt
                if god.t > 0.1 then god.t = 0 fire("Crouch", true, true) end
            end
        end
        local function godExit()
            local c, h = getChar(), getHum()
            if not c then return end
            local cl = c:FindFirstChild("CollisionClone")
            if cl then cl:Destroy() end
            if RF() then
                if h then h.HipHeight = 2.4 end
                local col = godPart(c, "Collision")
                if col then
                    col.Size = god.sizeOff
                    local cc = col:FindFirstChild("CollisionCrouch")
                    if cc then cc.Size = god.sizeOff end
                end
                local lt = godPart(c, "LowerTorso")
                local root = lt and lt:FindFirstChild("Root")
                if root then root.C1 = CFrame.new() end
                local cp = godPart(c, "CollisionPart")
                if cp then pcall(function() c:PivotTo(cp.CFrame * CFrame.new(0, 2, 0)) end) end
            else
                local col, hrp = godPart(c, "Collision"), getHRP()
                if col and hrp then col.Position = hrp.Position end
            end
        end
        local setGod = Toggle(HPG.pMain, "Godmode (Nova) (riesgo)", false, function(on)
            S.god = on
            -- si el cambio lo hizo el usuario (no el Auto Godmode), el auto deja de "poseerlo"
            if god.autoPending then god.autoPending = false else god.autoOwns = false end
            if god.step then god.step:Disconnect() god.step = nil end
            if god.char then god.char:Disconnect() god.char = nil end
            local st = ensureHook()
            if on then
                god.hook = st ~= nil
                if st then st.crouch = true end
                godEnter()
                god.step = RunService.Heartbeat:Connect(function(dt) pcall(godStep, dt) end)
                god.char = LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(1)
                    if alive and S.god then godEnter() end
                end)
            else
                if st then st.crouch = false end
                pcall(godExit)
            end
        end)
        Label(HPG.pMain, "Puede hacerte retroceder o no funcionar según la versión del juego. Actívalo en una zona segura.", Color3.fromRGB(190, 180, 225))
        onCleanup(function()
            if god.step then god.step:Disconnect() god.step = nil end
            if god.char then god.char:Disconnect() god.char = nil end
        end)

        -- ===== AUTO GODMODE: se activa solo cuando una entidad peligrosa se acerca =====
        pcall(function()
            local en = {
                ["Auto Godmode (entidades cerca)"] = "Auto Godmode (nearby entities)",
                ["Distancia del Auto Godmode"] = "Auto Godmode distance",
                ["🛡 Godmode automático: %s cerca"] = "🛡 Auto Godmode: %s nearby",
                ["Se activa solo con Rush, Ambush, A-60, A-120 y Glitch cuando están cerca, y se apaga al pasar el peligro. No actúa si estás escondido."] = "It turns on by itself when Rush, Ambush, A-60, A-120 or Glitch get close, and turns off once the danger passes. It does nothing while you're hiding.",
            }
            local pt = {
                ["Auto Godmode (entidades cerca)"] = "Auto Godmode (entidades perto)",
                ["Distancia del Auto Godmode"] = "Distância do Auto Godmode",
                ["🛡 Godmode automático: %s cerca"] = "🛡 Godmode automático: %s perto",
                ["Se activa solo con Rush, Ambush, A-60, A-120 y Glitch cuando están cerca, y se apaga al pasar el peligro. No actúa si estás escondido."] = "Ativa sozinho com Rush, Ambush, A-60, A-120 e Glitch quando estão perto, e desliga quando o perigo passa. Não age se você estiver escondido.",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)
        -- nombre en workspace -> nombre para el aviso
        local AUTOGOD = {
            RushMoving = "Rush", AmbushMoving = "Ambush", A60 = "A-60", A120 = "A-120",
            GlitchRush = "Glitch Rush", GlitchAmbush = "Glitch Ambush", BackdoorRush = "Blitz",
            Glitch = "Glitch", Lookman = "Lookman", -- (V8)
        }
        S.autoGodDist = 120
        local lastDanger = 0
        -- V8: nombres que cuentan cuando el aviso de entidades (HANTI.activeEnts) los ve con otro nombre interno
        local AUTOGOD_N = { RUSH = true, AMBUSH = true, BLITZ = true, ["A-60"] = true, ["A-120"] = true, GLITCH = true, BASH = true }
        local function dangerNear()
            local hrp = getHRP()
            if not hrp then return nil end
            local c = getChar()
            if c and c:GetAttribute("Hiding") then return nil end -- escondido: no hace falta
            local function check(e, label)
                local ok, pos = pcall(function() return (e.PrimaryPart and e.PrimaryPart.Position) or e:GetPivot().Position end)
                -- V8 FIX: antes exigia Y > -4 absoluto y en pisos profundos (Stairwell, etc.) nunca detectaba nada.
                -- Ahora cuenta si la entidad no esta muy por debajo de TU altura (A-60/A-120 esperan bajo el suelo).
                if ok and pos.Y > hrp.Position.Y - 12 and (pos - hrp.Position).Magnitude <= S.autoGodDist then return label end
            end
            for _, e in ipairs(workspace:GetChildren()) do
                local label = AUTOGOD[e.Name]
                if label and e:IsA("Model") then
                    local r = check(e, label)
                    if r then return r end
                end
            end
            -- respaldo: entidades que el sistema de avisos ya detecto (nombres nuevos / renombrados)
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent and inst:IsA("Model") and AUTOGOD_N[def.n] then
                    local r = check(inst, def.n)
                    if r then return r end
                end
            end
            return nil
        end
        local function engage(label)
            lastDanger = os.clock()
            if not S.god then
                god.autoPending, god.autoOwns = true, true
                setGod(true)
                notify("🛡 Godmode automático: %s cerca", "info", 2, label)
            end
        end
        local function releaseCheck()
            -- solo apaga el que encendió el auto; el manual se respeta
            if god.autoOwns and S.god and os.clock() - lastDanger > 2.5 then
                god.autoPending = true
                setGod(false)
                god.autoOwns = false
            end
        end
        local function releaseNow()
            if god.autoOwns and S.god then
                god.autoPending = true
                setGod(false)
                god.autoOwns = false
            end
        end
        local setAutoGod
        setAutoGod = Toggle(HPG.pMain, "Auto Godmode (entidades cerca)", false, function(on)
            S.autoGod = on
            if on then
                startLoop("autoGod", 0.1, function()
                    local label = dangerNear()
                    if label then engage(label) else releaseCheck() end
                end)
            else
                releaseNow()
            end
        end)
        Slider(HPG.pMain, "Distancia del Auto Godmode", 40, 250, 120, function(v) S.autoGodDist = v end)
        Label(HPG.pMain, "Se activa solo con Rush, Ambush, A-60, A-120 y Glitch cuando están cerca, y se apaga al pasar el peligro. No actúa si estás escondido.", Color3.fromRGB(190, 180, 225))
        task.defer(function() if alive then setAutoGod(true) end end) -- activado desde el inicio

        -- ===== FIGURE GOD MODE: Crouch falso + hitbox mínima mientras el Figure está cerca =====
        -- Antes mandaba el Crouch cada 0.5 s y dependía del detector de entidades; ahora sigue al Figure
        -- por su cuenta y reutiliza el Godmode (hook de Crouch, sin spam si tu ejecutor lo soporta).
        pcall(function()
            local en = {
                ["Figure God Mode"] = "Figure God Mode", ["Alcance del Figure God Mode"] = "Figure God Mode range",
                ["Se activa solo cuando el Figure (Library / Mines) está a menos del alcance, y se apaga al alejarte."] = "It turns on by itself when the Figure (Library / Mines) is within range and turns off when you move away.",
            }
            local pt = {
                ["Figure God Mode"] = "Figure God Mode", ["Alcance del Figure God Mode"] = "Alcance do Figure God Mode",
                ["Se activa solo cuando el Figure (Library / Mines) está a menos del alcance, y se apaga al alejarte."] = "Ativa sozinho quando o Figure (Library / Mines) está dentro do alcance e desliga quando você se afasta.",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)
        S.figRange = 70
        local figs, figGodConn = {}, nil
        local function figTrack(v)
            if v.Name == "FigureRig" and v:IsA("Model") and not table.find(figs, v) then table.insert(figs, v) end
        end
        Toggle(HPG.pAnti, "Figure God Mode", false, function(on)
            S.figureGod = on
            refreshAnti()
            if figGodConn then figGodConn:Disconnect() figGodConn = nil end
            table.clear(figs)
            if on then
                pcall(HANTI.fullPass)
                local rooms = getRooms()
                if rooms then
                    for _, v in ipairs(rooms:GetDescendants()) do figTrack(v) end
                    figGodConn = rooms.DescendantAdded:Connect(function(v) pcall(figTrack, v) end)
                end
                startLoop("figureGod", 0.1, function()
                    local hrp = getHRP()
                    if not hrp then return end
                    for i = #figs, 1, -1 do
                        local f = figs[i]
                        if not f.Parent then
                            table.remove(figs, i)
                        elseif (f:GetPivot().Position - hrp.Position).Magnitude <= S.figRange then
                            engage("Figure")
                            return
                        end
                    end
                    releaseCheck()
                end)
            else
                pcall(HANTI.restoreParts, function(p) return p:FindFirstAncestor("FigureRig") ~= nil end)
                releaseNow()
            end
        end)
        Slider(HPG.pAnti, "Alcance del Figure God Mode", 20, 150, 70, function(v) S.figRange = v end)
        Label(HPG.pAnti, "Se activa solo cuando el Figure (Library / Mines) está a menos del alcance, y se apaga al alejarte.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() if figGodConn then figGodConn:Disconnect() figGodConn = nil end end)

        -- ===== Borrar Seek (FE): toca el trigger de la persecución =====
        Button(HPG.pFloor, "Borrar Seek (FE)", function()
            if not firetouchinterest then notify("⚠ Tu ejecutor no soporta firetouchinterest", "warn", 3) return end
            local hrp, rooms = getHRP(), getRooms()
            if not (hrp and rooms) then return end
            notify("Borrando Seek...", "info", 2)
            local found = false
            for _, v in ipairs(rooms:GetDescendants()) do
                if v.Name == "TriggerEventCollision" then
                    found = true
                    for _, i in ipairs(v:GetChildren()) do
                        if i.Name == "Collision" then pcall(firetouchinterest, hrp, i, 0) end
                    end
                    task.wait(0.5)
                    if v:FindFirstChild("Collision") then
                        notify("⚠ No se pudo quitar Seek", "warn", 3)
                    else
                        notify("✅ Seek eliminado", "ok", 3)
                    end
                end
            end
            if not found then notify("⚠ No se pudo quitar Seek", "warn", 3) end
        end)

        -- ===== Borrar Figure (FE, Mines): necesita ser dueño de red del Figure =====
        local figures, figConn = {}, nil
        local function figAdd(v)
            if (v.Name == "FigureRig" or v.Name == "FigureRagdoll") and not table.find(figures, v) then
                table.insert(figures, v)
            end
        end
        Toggle(HPG.pFloor, "Borrar Figure (FE, Mines)", false, function(on)
            S.delFigure = on
            if figConn then figConn:Disconnect() figConn = nil end
            table.clear(figures)
            if not on then return end
            if not isnetworkowner then
                notify("⚠ Tu ejecutor no soporta isnetworkowner", "warn", 3)
                S.delFigure = false
                return
            end
            local rooms = getRooms()
            if rooms then
                for _, v in ipairs(rooms:GetDescendants()) do figAdd(v) end
                figConn = rooms.DescendantAdded:Connect(function(v) pcall(figAdd, v) end)
            end
            startLoop("delFigure", 0.1, function()
                for i = #figures, 1, -1 do
                    local v = figures[i]
                    if not v.Parent then
                        table.remove(figures, i)
                    else
                        local root = v:FindFirstChild("Root")
                        if root and isnetworkowner(root) then
                            local bf = root:FindFirstChild("BodyForce")
                            if bf then bf.Force = Vector3.new(0, -50000, 0) else root:PivotTo(CFrame.new(0, -50000, 0)) end
                            for _, part in ipairs(v:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then part.CanCollide, part.Anchored = false, false end
                            end
                            if root.Position.Y < -1000 and not v:GetAttribute("RH_Deleted") then
                                v:SetAttribute("RH_Deleted", true)
                                notify("✅ Figure eliminado", "ok", 3)
                            end
                        end
                    end
                end
            end)
        end)
        onCleanup(function() if figConn then figConn:Disconnect() figConn = nil end end)

        -- ===== Items infinitos: suelta y recoge la herramienta para reutilizarla =====
        local IT_NAMES = { Lock = true, ChestBoxLocked = true, Cellar = true, Chest_Vine = true, CuttableVines = true,
            SkullLock = true, Toolbox_Locked = true, Lock1 = true, Lock2 = true }
        local itStored, itConn = {}, nil
        local function itTarget(p)
            if not (p and p:IsA("ProximityPrompt")) then return false end
            if p.Name == "FusesPrompt" then return true end
            local par = p.Parent
            if not par then return false end
            local gp = par.Parent and par.Parent.Name
            return IT_NAMES[par.Name] == true or (gp ~= nil and IT_NAMES[gp] == true) or gp == "Locker_Small_Locked"
        end
        local function itRestore(p)
            if not p then return end
            if p.Parent then
                local ex = p.Parent:FindFirstChild("InfPrompt")
                if ex then ex:Destroy() end
            end
            p:SetAttribute("RH_Inf", nil) p:SetAttribute("RH_Tool", nil) p:SetAttribute("RH_Time", nil)
            p.Enabled, p.ClickablePrompt = true, true
        end
        local function itStep(p)
            local char, hrp = getChar(), getHRP()
            if not (char and hrp and p.Parent) then return end
            local tool = char:FindFirstChild("Lockpick") or char:FindFirstChild("SkeletonKey") or char:FindFirstChild("Shears")
            local name = tool and tool.Name
            local tp = p.Parent:IsA("BasePart") and p.Parent or p.Parent:FindFirstChildWhichIsA("BasePart")
            local dist = tp and (tp.Position - hrp.Position).Magnitude or 999
            if not (tool and dist <= p.MaxActivationDistance + 5) then
                if p:GetAttribute("RH_Inf") then itRestore(p) end
                return
            end
            if p:GetAttribute("RH_Inf") then
                if p:GetAttribute("RH_Tool") ~= name or tick() - (p:GetAttribute("RH_Time") or 0) > 8
                    or dist > p.MaxActivationDistance + 7 then itRestore(p) end
                return
            end
            p.Enabled, p.ClickablePrompt = false, false
            p:SetAttribute("RH_Inf", true) p:SetAttribute("RH_Tool", name) p:SetAttribute("RH_Time", tick())
            local clone = p:Clone()
            clone.Name, clone.MaxActivationDistance = "InfPrompt", p.MaxActivationDistance
            clone.Parent = p.Parent
            clone.Enabled, clone.ClickablePrompt = true, true
            local con, conEnd
            conEnd = clone.PromptButtonHoldEnded:Connect(function()
                task.delay(0.15, function()
                    if clone.Parent then
                        if con then con:Disconnect() end
                        if conEnd then conEnd:Disconnect() end
                        itRestore(p)
                    end
                end)
            end)
            con = clone.Triggered:Connect(function()
                if conEnd then conEnd:Disconnect() end
                if con then con:Disconnect() end
                if clone.Parent then clone:Destroy() end
                if not char:FindFirstChild(name) then itRestore(p) return end
                task.spawn(function()
                    local drop, t0 = nil, tick()
                    repeat
                        fire("DropItem", tool)
                        task.wait(0.01)
                        local best, bd = nil, 15
                        local ds = workspace:FindFirstChild("Drops")
                        if ds then
                            for _, v in ipairs(ds:GetChildren()) do
                                if v.Name == name then
                                    local d = (v:GetPivot().Position - hrp.Position).Magnitude
                                    if d < bd then bd, best = d, v end
                                end
                            end
                        end
                        drop = best
                    until drop or not char:FindFirstChild(name) or tick() - t0 > 2.5 or not alive
                    local fp = fireproximityprompt
                    local dp = drop and drop:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if fp then
                        if name == "Shears" then
                            pcall(fp, p)
                            if dp then pcall(fp, dp) end
                        else
                            if dp then pcall(fp, dp) end
                            pcall(fp, p)
                        end
                    end
                    itRestore(p)
                end)
            end)
        end
        Toggle(HPG.pAnti, "Items infinitos (ganzúa / llave / tijeras)", false, function(on)
            S.infItems = on
            if itConn then itConn:Disconnect() itConn = nil end
            local rooms = getRooms()
            if on then
                if rooms then
                    for _, v in ipairs(rooms:GetDescendants()) do
                        if itTarget(v) then table.insert(itStored, v) end
                    end
                    itConn = rooms.DescendantAdded:Connect(function(v)
                        task.wait(0.1)
                        if itTarget(v) then table.insert(itStored, v) end
                    end)
                end
                startLoop("infItems", 0.15, function()
                    for i = #itStored, 1, -1 do
                        local p = itStored[i]
                        if p.Parent then itStep(p) else table.remove(itStored, i) end
                    end
                end)
            else
                for _, p in ipairs(itStored) do pcall(itRestore, p) end
                table.clear(itStored)
            end
        end)
        Label(HPG.pAnti, "Si no responde con Auto Interact, usa la tecla normal del juego (E) y toca varias veces.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() if itConn then itConn:Disconnect() itConn = nil end end)

        -- ===== Prompt Clip: interactuar a través de paredes =====
        local clipConn
        local function clipApply(v)
            if v:IsA("ProximityPrompt") then
                if v:GetAttribute("RH_Clip") == nil then v:SetAttribute("RH_Clip", v.RequiresLineOfSight) end
                v.RequiresLineOfSight = false
            end
        end
        Toggle(HPG.pMain, "Prompt Clip (interactuar a través de paredes)", false, function(on)
            S.promptClip = on
            if clipConn then clipConn:Disconnect() clipConn = nil end
            if on then
                for _, v in ipairs(workspace:GetDescendants()) do clipApply(v) end
                clipConn = workspace.DescendantAdded:Connect(function(v) pcall(clipApply, v) end)
            else
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") then
                        local orig = v:GetAttribute("RH_Clip")
                        if orig ~= nil then v.RequiresLineOfSight = orig v:SetAttribute("RH_Clip", nil) end
                    end
                end
            end
        end)
        onCleanup(function() if clipConn then clipConn:Disconnect() clipConn = nil end end)

        -- ===== Velocidad al escalar =====
        S.climbVal = 30
        Toggle(HPG.pMain, "Velocidad al escalar", false, function(on)
            S.climbSpeed = on
            if on then
                startLoop("climbSpeed", 0.1, function()
                    local c, h = getChar(), getHum()
                    if c and h and c:GetAttribute("Climbing") and h.WalkSpeed ~= S.climbVal then h.WalkSpeed = S.climbVal end
                end)
            end
        end)
        Slider(HPG.pMain, "Velocidad de escalada", 10, isVip and 60 or 40, 30, function(v) S.climbVal = v end)

        -- ================= V7 INSANO: A-90, ESP optimizado, Auto Minecart, Auto A-1000 =================
        pcall(function()
            local en = {
                ["Anti A-90 (remote falso)"] = "Anti A-90 (fake remote)",
                ["⚠ Remote A90 no encontrado (se reintenta solo)"] = "⚠ A90 remote not found (retrying automatically)",
                ["Cambia el remote real de A-90 por uno falso: el daño nunca llega al servidor. Sirve en Hotel+, Rooms y Archives."] = "Swaps the real A-90 remote for a fake one: the damage never reaches the server. Works in Hotel+, Rooms and Archives.",
                ["Máx. resaltados del ESP (rendimiento)"] = "Max ESP highlights (performance)",
                ["El ESP solo resalta los objetos más cercanos (Roblox no dibuja más de ~31 a la vez). Menos = más FPS."] = "ESP only highlights the nearest objects (Roblox doesn't draw more than ~31 at once). Lower = more FPS.",
                ["Auto Minecart (Mines) BETA (riesgo)"] = "Auto Minecart (Mines) BETA (risky)",
                ["[Auto Minecart] NO TE MUEVAS"] = "[Auto Minecart] DON'T MOVE", ["[Auto Minecart] YA PUEDES MOVERTE"] = "[Auto Minecart] YOU CAN MOVE NOW",
                ["⚠ Tu ejecutor no soporta require()"] = "⚠ Your executor doesn't support require()",
                ["Auto A-1000 (Rooms) BETA (riesgo)"] = "Auto A-1000 (Rooms) BETA (risky)",
                ["Camina solo hasta la siguiente puerta de Rooms y se esconde cuando viene A-60 / A-120 / Glitch."] = "Walks to the next Rooms door by itself and hides when A-60 / A-120 / Glitch come.",
                ["🤖 Auto A-1000: escondiéndome"] = "🤖 Auto A-1000: hiding",
            }
            local pt = {
                ["Anti A-90 (remote falso)"] = "Anti A-90 (remote falso)",
                ["⚠ Remote A90 no encontrado (se reintenta solo)"] = "⚠ Remote A90 não encontrado (tenta de novo sozinho)",
                ["Cambia el remote real de A-90 por uno falso: el daño nunca llega al servidor. Sirve en Hotel+, Rooms y Archives."] = "Troca o remote real do A-90 por um falso: o dano nunca chega ao servidor. Funciona em Hotel+, Rooms e Archives.",
                ["Máx. resaltados del ESP (rendimiento)"] = "Máx. destaques do ESP (desempenho)",
                ["El ESP solo resalta los objetos más cercanos (Roblox no dibuja más de ~31 a la vez). Menos = más FPS."] = "O ESP só destaca os objetos mais próximos (o Roblox não desenha mais de ~31 ao mesmo tempo). Menos = mais FPS.",
                ["Auto Minecart (Mines) BETA (riesgo)"] = "Auto Minecart (Mines) BETA (risco)",
                ["[Auto Minecart] NO TE MUEVAS"] = "[Auto Minecart] NÃO SE MEXA", ["[Auto Minecart] YA PUEDES MOVERTE"] = "[Auto Minecart] JÁ PODE SE MOVER",
                ["⚠ Tu ejecutor no soporta require()"] = "⚠ Seu executor não suporta require()",
                ["Auto A-1000 (Rooms) BETA (riesgo)"] = "Auto A-1000 (Rooms) BETA (risco)",
                ["Camina solo hasta la siguiente puerta de Rooms y se esconde cuando viene A-60 / A-120 / Glitch."] = "Anda sozinho até a próxima porta do Rooms e se esconde quando vem A-60 / A-120 / Glitch.",
                ["🤖 Auto A-1000: escondiéndome"] = "🤖 Auto A-1000: escondendo",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        -- ===== Anti A-90: remote falso (el método viejo "didnt" ya no sirve en Rooms / Archives) =====
        local swapped = {}
        local function findRemote(name)
            local rf = RF()
            local r = rf and rf:FindFirstChild(name)
            if r and r:IsA("RemoteEvent") then return r end
            r = ReplicatedStorage:FindFirstChild(name, true)
            if r and r:IsA("RemoteEvent") then return r end
        end
        local function swapOn(name)
            local cur = swapped[name]
            if cur and cur.real.Parent and cur.fake.Parent then return true end
            if cur then pcall(function() cur.fake:Destroy() end) swapped[name] = nil end
            local real = findRemote(name)
            if not real then return false end
            local parent = real.Parent
            local fake = Instance.new("RemoteEvent")
            real.Name = name .. "_"
            fake.Name = name
            fake.Parent = parent
            swapped[name] = { real = real, fake = fake }
            return true
        end
        local function swapOff(name)
            local cur = swapped[name]
            if not cur then return end
            pcall(function() cur.fake:Destroy() end)
            pcall(function() if cur.real.Parent then cur.real.Name = name end end)
            swapped[name] = nil
        end
        Toggle(HPG.pFloor, "Anti A-90 (remote falso)", false, function(on)
            S.a90 = on
            if on then
                if not swapOn("A90") then notify("⚠ Remote A90 no encontrado (se reintenta solo)", "warn", 3) end
                startLoop("a90", 1.5, function() swapOn("A90") end) -- si el juego recrea la carpeta, se vuelve a aplicar
            else
                swapOff("A90")
            end
        end)
        Label(HPG.pFloor, "Cambia el remote real de A-90 por uno falso: el daño nunca llega al servidor. Sirve en Hotel+, Rooms y Archives.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() for name in pairs(swapped) do swapOff(name) end end)

        -- ===== ESP optimizado: solo se dibujan los resaltados más cercanos (límite real de Roblox ≈ 31) =====
        S.espBudget = 26
        task.spawn(function()
            local list = {}
            while alive do
                task.wait(0.6)
                pcall(function()
                    local hrp = getHRP()
                    if not hrp then return end
                    table.clear(list)
                    for kind, objs in pairs(HESP.espObjs) do
                        if HESP.esp[kind] then
                            for _, o in ipairs(objs) do
                                if o.Parent and o:IsA("Highlight") then
                                    local par, pos = o.Parent, nil
                                    if par:IsA("BasePart") then pos = par.Position
                                    elseif par:IsA("Model") then pos = par:GetPivot().Position end
                                    if pos then list[#list + 1] = { o, (pos - hrp.Position).Magnitude } end
                                end
                            end
                        end
                    end
                    if #list == 0 then return end
                    table.sort(list, function(a, b) return a[2] < b[2] end)
                    for i, e in ipairs(list) do
                        local want = i <= S.espBudget
                        if e[1].Enabled ~= want then e[1].Enabled = want end
                    end
                end)
            end
        end)
        Slider(HPG.pVis, "Máx. resaltados del ESP (rendimiento)", 8, 31, 26, function(v) S.espBudget = v end)
        Label(HPG.pVis, "El ESP solo resalta los objetos más cercanos (Roblox no dibuja más de ~31 a la vez). Menos = más FPS.", Color3.fromRGB(190, 180, 225))

        -- ===== Auto Minecart (Mines): sigue los nodos del carrito y se agacha en los DuckBoards =====
        local mc = { nodes = {}, ducks = {}, vec = Vector3.new(0, 0, -1), t = 0 }
        local function mcControls()
            local ok, c = pcall(function() return require(LocalPlayer.PlayerScripts.PlayerModule):GetControls() end)
            return ok and c or nil
        end
        local function mcGather()
            table.clear(mc.nodes) table.clear(mc.ducks)
            local rooms = getRooms()
            if not rooms then return end
            for _, v in ipairs(rooms:GetDescendants()) do
                if v.Name == "DuckBoard" then table.insert(mc.ducks, v)
                elseif v.Name:find("MinecartNode", 1, true) then table.insert(mc.nodes, v) end
            end
        end
        local function mcRestore()
            local c = mcControls()
            if c and mc.orig then c.GetMoveVector = mc.orig end
            mc.orig = nil
        end
        local setMc
        setMc = Toggle(HPG.pFloor, "Auto Minecart (Mines) BETA (riesgo)", false, function(on)
            S.autoMinecart = on
            if not on then mcRestore() return end
            local ctrl = mcControls()
            if not ctrl then
                notify("⚠ Tu ejecutor no soporta require()", "warn", 3)
                S.autoMinecart = false
                return
            end
            mc.orig = ctrl.GetMoveVector
            ctrl.GetMoveVector = function() return mc.vec end
            mcGather()
            local notified = false
            startLoop("autoMinecart", 0.08, function()
                local cam = workspace.CurrentCamera
                if not (cam and cam:FindFirstChild("MinecartRig")) then return end
                local latest = ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("LatestRoom")
                if latest and tonumber(latest.Value) and latest.Value >= 50 then
                    notify("[Auto Minecart] YA PUEDES MOVERTE", "ok", 4)
                    setMc(false)
                    return
                end
                if not notified then notified = true notify("[Auto Minecart] NO TE MUEVAS", "warn", 4) end
                local hrp = getHRP()
                if not hrp then return end
                if os.clock() - mc.t > 2 then mc.t = os.clock() mcGather() end -- las salas se regeneran
                -- agacharse cerca de las tablas
                local nearestDuck = math.huge
                for _, v in ipairs(mc.ducks) do
                    if v.Parent then nearestDuck = math.min(nearestDuck, (v:GetPivot().Position - hrp.Position).Magnitude) end
                end
                pcall(function()
                    local init = LocalPlayer.PlayerGui.MainUI.Initiator
                    local game_ = require(init.Main_Game)
                    local want = nearestDuck < 30
                    if game_.crouching ~= want then game_.crouching = want end
                end)
                -- nodo más cercano marcado ForceConnect y el que va 3 más adelante
                local cur, best = nil, math.huge
                for _, n in ipairs(mc.nodes) do
                    if n.Parent and n:GetAttribute("ForceConnect") then
                        local d = (hrp.Position - n.Position).Magnitude
                        if d < best then best, cur = d, n end
                    end
                end
                if not cur then return end
                local num = tonumber(cur.Name:match("%d+"))
                local nxt
                if num then
                    for _, n in ipairs(mc.nodes) do
                        if n.Name == "MinecartNode" .. (num + 3) then nxt = n break end
                    end
                end
                if not nxt then return end
                if best > 30 then
                    mc.vec = Vector3.new(0, 0, -1)
                else
                    local dot = (cur.Position - nxt.Position).Unit:Dot(cur.CFrame.RightVector)
                    -- (igual que Nova: tanto >0.15 como <-0.15 empujan a la derecha)
                    mc.vec = (math.abs(dot) > 0.15) and Vector3.new(1, 0, 0) or Vector3.new(0, 0, -1)
                end
            end)
        end)
        onCleanup(mcRestore)

        -- ===== Auto A-1000 (Rooms): camina a la siguiente puerta y se esconde ante A-60 / A-120 / Glitch =====
        local PathfindingService = game:GetService("PathfindingService")
        local ar = { gen = 0 }
        local AR_HIDE = { Wardrobe = true, Rooms_Locker = true, Rooms_Locker_Fridge = true, Locker_Large = true,
            Backdoor_Wardrobe = true, Bed = true, Double_Bed = true, Toolshed = true, RetroWardrobe = true }
        local AR_DANGER = { A60 = true, A120 = true, Bash = true, Scribbles = true, GlitchRush = true, GlitchAmbush = true }
        -- V8: Archives renombro A-60 / A-120 (Bash / Scribbles): se detecta por nombre, sin depender de la lista fija
        local function arDangerName(nm)
            local l = nm:lower()
            return l:find("bash", 1, true) ~= nil or l:find("scribbles", 1, true) ~= nil
                or l:find("glitchrush", 1, true) ~= nil or l:find("glitchambush", 1, true) ~= nil
                or l == "a60" or l == "a120" or l == "a-60" or l == "a-120"
        end
        local function arPath(pos, gen)
            local h, hrp = getHum(), getHRP()
            if not (h and hrp) then return false end
            local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true,
                WaypointSpacing = 4, AgentMaxSlope = 45 })
            local ok = pcall(function() path:ComputeAsync(hrp.Position, pos) end)
            if not ok or path.Status ~= Enum.PathStatus.Success then
                -- V8: sin ruta calculable, camina directo (antes se quedaba parado)
                h:MoveTo(pos)
                local t1 = tick()
                repeat task.wait() until (hrp.Position - pos).Magnitude < 4 or tick() - t1 > 2 or gen ~= ar.gen
                return false
            end
            for _, wp in ipairs(path:GetWaypoints()) do
                if gen ~= ar.gen or not alive then return false end
                if (hrp.Position - wp.Position).Magnitude >= 2 then
                    h:MoveTo(wp.Position)
                    local t0 = tick()
                    repeat task.wait() until (hrp.Position - wp.Position).Magnitude < 3 or tick() - t0 > 1.5 or gen ~= ar.gen
                    if (hrp.Position - wp.Position).Magnitude >= 3 then h.Jump = true end -- V8: salta si se atasca
                end
            end
            return true
        end
        local function arDanger()
            local myHrp = getHRP()
            local baseY = myHrp and myHrp.Position.Y or 0
            for _, e in ipairs(workspace:GetChildren()) do
                if (AR_DANGER[e.Name] or arDangerName(e.Name)) and e:IsA("Model") then
                    local pos = (e.PrimaryPart and e.PrimaryPart.Position) or e:GetPivot().Position
                    -- V8: relativo a tu altura (antes Y > -4 absoluto, fallaba en pisos profundos)
                    if pos.Y > baseY - 12 then return true end
                end
            end
            return false
        end
        local function arNearestHide(hrp, latest)
            local rooms = getRooms()
            if not rooms then return nil end
            local best, bd = nil, math.huge
            for _, idx in ipairs({ latest, latest - 1 }) do
                local room = rooms:FindFirstChild(tostring(idx))
                if room then
                    for _, m in ipairs(room:GetDescendants()) do
                        if m:IsA("Model") and (AR_HIDE[m.Name] or m:FindFirstChild("HidePrompt", true)) then
                            local pr = m:FindFirstChild("HidePrompt", true)
                            local base = m:FindFirstChild("Base") or m.PrimaryPart
                            if pr and base then
                                local d = (base.Position - hrp.Position).Magnitude
                                if d < bd then bd, best = d, { prompt = pr, base = base } end
                            end
                        end
                    end
                end
            end
            return best
        end
        Toggle(HPG.pFloor, "Auto A-1000 (Rooms) BETA (riesgo)", false, function(on)
            S.autoRooms = on
            ar.gen = ar.gen + 1
            local gen = ar.gen
            if not on then
                local h, hrp = getHum(), getHRP()
                if h and hrp then h:MoveTo(hrp.Position) end
                return
            end
            task.spawn(function()
                while alive and S.autoRooms and gen == ar.gen do
                    pcall(function()
                        local c, hrp = getChar(), getHRP()
                        if not (c and hrp) or LocalPlayer:GetAttribute("Alive") == false then task.wait(0.5) return end
                        local gd = ReplicatedStorage:FindFirstChild("GameData")
                        local latest = gd and gd:FindFirstChild("LatestRoom") and tonumber(gd.LatestRoom.Value) or 0
                        if arDanger() then
                            if not c:GetAttribute("Hiding") then
                                local spot = arNearestHide(hrp, latest)
                                if spot then
                                    notify("🤖 Auto A-1000: escondiéndome", "info", 2)
                                    spot.base.CanCollide = false
                                    arPath(spot.base.Position, gen)
                                    if fireproximityprompt and not c:GetAttribute("Hiding") then pcall(fireproximityprompt, spot.prompt) end
                                end
                            end
                            task.wait(0.2)
                        else
                            if c:GetAttribute("Hiding") then pcall(function() c:SetAttribute("Hiding", false) end) end
                            local rooms = getRooms()
                            local room = rooms and rooms:FindFirstChild(tostring(latest))
                            local door = room and room:FindFirstChild("Door")
                            local dpart = door and door:FindFirstChild("Door")
                            if dpart then
                                arPath(dpart.Position, gen)
                                if (hrp.Position - dpart.Position).Magnitude < 14 then
                                    local co = door:FindFirstChild("ClientOpen")
                                    if co then pcall(co.FireServer, co) end
                                end
                            end
                            task.wait(0.1)
                        end
                    end)
                    task.wait()
                end
            end)
        end)
        Label(HPG.pFloor, "Camina solo hasta la siguiente puerta de Rooms y se esconde cuando viene A-60 / A-120 / Glitch.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() ar.gen = ar.gen + 1 end)

        -- ================= V7.1: Candy Vault, Archives / Stairwell, pisos nuevos =================
        pcall(function()
            local en = {
                ["Auto Candy (recoger dulces y llaves cerca)"] = "Auto Candy (collect nearby candy and keys)",
                ["Auto mirar a Sir Abe (espantarlo) BETA"] = "Auto look at Sir Abe (scare him) BETA",
                ["Recoge solo los dulces y las llaves de joyería a menos de 14 studs. Activa también el Candy Vault ESP para verlos."] = "Collects candy and jewelry keys within 14 studs by itself. Also enable Candy Vault ESP to see them.",
                ["Detector de entidades nuevas (pisos nuevos)"] = "New entity detector (new floors)",
                ["🔎 Entidad nueva: %s"] = "🔎 New entity: %s",
                ["📋 Copiar entidades nuevas vistas"] = "📋 Copy new entities seen",
                ["⚠ Aún no se vio ninguna entidad nueva"] = "⚠ No new entity seen yet",
                ["Avisa (y marca con ESP si está activo) cualquier modelo desconocido que aparezca: útil en pisos nuevos como Stairwell."] = "Warns (and marks with ESP if enabled) any unknown model that shows up: useful on new floors like Stairwell.",
                ["Auto optimizar en Archives / Stairwell (menos lag)"] = "Auto optimize in Archives / Stairwell (less lag)",
                ["📚 Archives / Stairwell detectado: Anti Lag activado"] = "📚 Archives / Stairwell detected: Anti Lag enabled",
            }
            local pt = {
                ["Auto Candy (recoger dulces y llaves cerca)"] = "Auto Candy (pegar doces e chaves perto)",
                ["Auto mirar a Sir Abe (espantarlo) BETA"] = "Auto olhar o Sir Abe (espantá-lo) BETA",
                ["Recoge solo los dulces y las llaves de joyería a menos de 14 studs. Activa también el Candy Vault ESP para verlos."] = "Pega sozinho os doces e as chaves de joalheria a menos de 14 studs. Ative também o Candy Vault ESP para vê-los.",
                ["Detector de entidades nuevas (pisos nuevos)"] = "Detector de entidades novas (andares novos)",
                ["🔎 Entidad nueva: %s"] = "🔎 Entidade nova: %s",
                ["📋 Copiar entidades nuevas vistas"] = "📋 Copiar entidades novas vistas",
                ["⚠ Aún no se vio ninguna entidad nueva"] = "⚠ Nenhuma entidade nova vista ainda",
                ["Avisa (y marca con ESP si está activo) cualquier modelo desconocido que aparezca: útil en pisos nuevos como Stairwell."] = "Avisa (e marca com ESP se estiver ativo) qualquer modelo desconhecido que apareça: útil em andares novos como o Stairwell.",
                ["Auto optimizar en Archives / Stairwell (menos lag)"] = "Auto otimizar em Archives / Stairwell (menos lag)",
                ["📚 Archives / Stairwell detectado: Anti Lag activado"] = "📚 Archives / Stairwell detectado: Anti Lag ativado",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        -- ===== Candy Vault: recoger dulces y llaves solo =====
        Toggle(HPG.pFloor, "Auto Candy (recoger dulces y llaves cerca)", false, function(on)
            S.autoCandy = on
            if not on then return end
            if not S.candyScanOn then
                S.candyScanOn = true
                HESP.candyRescan()
            end
            startLoop("autoCandy", 0.35, function()
                local hrp = getHRP()
                if not (hrp and fireproximityprompt) then return end
                for obj, d in pairs(HESP.cands.Candy) do
                    if obj.Parent and d[2] ~= "🧪 Cauldron" then
                        local okp, pos = pcall(function() return obj:GetPivot().Position end)
                        if okp and (pos - hrp.Position).Magnitude <= 14 then
                            local pr = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pr and pr.Enabled and os.clock() - (obj:GetAttribute("RH_candyT") or 0) > 1.5 then
                                obj:SetAttribute("RH_candyT", os.clock())
                                pcall(fireproximityprompt, pr)
                                -- (V8) contador de dulces de la sesion (se ve en Pisos y en los avisos)
                                HST.candyN = (HST.candyN or 0) + 1
                                if HST.candyN % 10 == 0 then notify("🍬 %d dulces recogidos", "ok", 3, HST.candyN) end
                            end
                        end
                    end
                end
            end)
        end)

        -- ===== Candy Vault: mirar a Sir Abe para espantarlo =====
        local abeBound, abeCache, abeT = false, nil, 0
        local function abeUnbind()
            if abeBound then
                pcall(function() RunService:UnbindFromRenderStep("RH_AbeLook") end)
                abeBound = false
            end
        end
        Toggle(HPG.pFloor, "Auto mirar a Sir Abe (espantarlo) BETA", false, function(on)
            S.abeLook = on
            abeUnbind()
            if not on then return end
            abeBound = true
            RunService:BindToRenderStep("RH_AbeLook", Enum.RenderPriority.Camera.Value + 1, function()
                local cam = workspace.CurrentCamera
                if not cam then return end
                local now = os.clock()
                if now - abeT > 0.25 then
                    abeT, abeCache = now, nil
                    for inst, def in pairs(HANTI.activeEnts) do
                        if def.n == "SIR ABE C. II" and inst.Parent then abeCache = inst break end
                    end
                end
                if not (abeCache and abeCache.Parent) then return end
                local ok, pos = pcall(function() return abeCache:GetPivot().Position end)
                if not ok then return end
                if (pos - cam.CFrame.Position).Magnitude > 70 then return end
                local want = CFrame.lookAt(cam.CFrame.Position, pos)
                if cam.CFrame.LookVector:Dot(want.LookVector) < 0.985 then
                    cam.CFrame = cam.CFrame:Lerp(want, 0.2)
                end
            end)
        end)
        onCleanup(abeUnbind)
        Label(HPG.pFloor, "Recoge solo los dulces y las llaves de joyería a menos de 14 studs. Activa también el Candy Vault ESP para verlos.", Color3.fromRGB(190, 180, 225))

        -- ===== Detector de entidades nuevas (pisos nuevos: Stairwell y lo que venga) =====
        local newSeen, newList, newT, newConn = {}, {}, 0, nil
        local NEW_IGN = { CurrentRooms = true, Drops = true, Camera = true, Terrain = true, PathFolder = true }
        local function newEnt(ch)
            if not ch:IsA("Model") or NEW_IGN[ch.Name] or newSeen[ch.Name] then return end
            if Players:GetPlayerFromCharacter(ch) then return end
            if HANTI.ENT[HANTI.entKey(ch.Name)] then return end -- ya conocida
            if not (ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart", true)) then return end
            newSeen[ch.Name] = true
            table.insert(newList, ch.Name)
            if HESP.esp.Entity then HESP.addESP("Entity", ch, Color3.fromRGB(255, 170, 60), "❓ " .. ch.Name) end
            if os.clock() - newT > 3 then
                newT = os.clock()
                notify("🔎 Entidad nueva: %s", "info", 5, ch.Name)
            end
        end
        Toggle(HPG.pFloor, "Detector de entidades nuevas (pisos nuevos)", false, function(on)
            S.newEntDetect = on
            if newConn then newConn:Disconnect() newConn = nil end
            if not on then return end
            for _, ch in ipairs(workspace:GetChildren()) do newSeen[ch.Name] = true end -- lo que ya está no cuenta
            newConn = workspace.ChildAdded:Connect(function(ch)
                task.wait(0.1) -- que cargue el modelo
                if S.newEntDetect then pcall(newEnt, ch) end
            end)
        end)
        onCleanup(function() if newConn then newConn:Disconnect() newConn = nil end end)
        Button(HPG.pFloor, "📋 Copiar entidades nuevas vistas", function()
            if #newList == 0 then notify("⚠ Aún no se vio ninguna entidad nueva", "warn", 3) return end
            HNET.copyOut(newList)
        end)
        Label(HPG.pFloor, "Avisa (y marca con ESP si está activo) cualquier modelo desconocido que aparezca: útil en pisos nuevos como Stairwell.", Color3.fromRGB(190, 180, 225))

        -- ===== Auto optimizar en Archives / Stairwell (igual que el de Mines) =====
        Toggle(HPG.pFloor, "Auto optimizar en Archives / Stairwell (menos lag)", false, function(on)
            S.archOpt = on
            if not on then return end
            local applied = false
            startLoop("archOpt", 4, function()
                local f = ""
                pcall(function()
                    local gd = ReplicatedStorage:FindFirstChild("GameData")
                    local fv = gd and gd:FindFirstChild("Floor")
                    if fv then f = tostring(fv.Value):lower() end
                end)
                local inArch = f:find("archive", 1, true) ~= nil or f:find("stair", 1, true) ~= nil
                if inArch and not applied then
                    applied = true
                    HLAG.setLagFx(true)
                    notify("📚 Archives / Stairwell detectado: Anti Lag activado", "ok", 3)
                elseif not inArch then
                    applied = false
                end
            end)
        end)

        -- ===== Freecam =====
        local fc = {}
        local function fcStop()
            if fc.conn then fc.conn:Disconnect() fc.conn = nil end
            if fc.inp then fc.inp:Disconnect() fc.inp = nil end
            local hrp = getHRP()
            if hrp then pcall(function() hrp.Anchored = false end) end
            local cam, hum = workspace.CurrentCamera, getHum()
            if cam then
                pcall(function()
                    cam.CameraType = Enum.CameraType.Custom
                    if hum then cam.CameraSubject = hum end
                end)
            end
        end
        Toggle(HPG.pVis, "Freecam (PC: clic derecho para mirar | móvil: arrastra)", false, function(on)
            S.freecam = on
            if not on then fcStop() return end
            local cam = workspace.CurrentCamera
            if not cam then S.freecam = false return end
            local hrp = getHRP()
            if hrp then hrp.Anchored = true end
            cam.CameraType = Enum.CameraType.Scriptable
            fc.pos = cam.CFrame.Position
            local rx, ry = cam.CFrame:ToOrientation()
            fc.pitch, fc.yaw = math.deg(rx), math.deg(ry)
            fc.inp = UserInputService.InputChanged:Connect(function(input, gp)
                local t = input.UserInputType
                if (t == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
                    or (t == Enum.UserInputType.Touch and not gp) then
                    fc.yaw = fc.yaw - input.Delta.X * 0.3
                    fc.pitch = math.clamp(fc.pitch - input.Delta.Y * 0.3, -80, 80)
                end
            end)
            fc.conn = RunService.RenderStepped:Connect(function(dt)
                local c, h = workspace.CurrentCamera, getHum()
                if not c then return end
                c.CameraType = Enum.CameraType.Scriptable
                local rot = CFrame.fromOrientation(math.rad(fc.pitch), math.rad(fc.yaw), 0)
                if h and h.MoveDirection.Magnitude > 0 then
                    local lm = rot:VectorToObjectSpace(h.MoveDirection)
                    fc.pos = fc.pos + (rot.RightVector * lm.X + rot.LookVector * -lm.Z) * 75 * dt
                end
                c.CFrame = CFrame.new(fc.pos) * rot
            end)
        end)
        onCleanup(function() if S.freecam then fcStop() end end)

        -- ================= V8: Noise / Glitch / Lookman / Seek God Mode / Candy+ / Stairwell+ =================
        pcall(function()
            local en = {
                ["Anti Noise (modo silencio) BETA"] = "Anti Noise (quiet mode) BETA",
                ["Velocidad en modo silencio"] = "Quiet mode speed",
                ["🔊 Noise cerca: modo silencio activado"] = "🔊 Noise nearby: quiet mode on",
                ["✅ Noise se fue, ya puedes hacer ruido"] = "✅ Noise left, you can make noise again",
                ["Mientras Noise está cerca te agacha, bloquea el salto y baja tu velocidad para no hacer ruido. Se desactiva solo cuando se va."] = "While Noise is nearby it crouches you, blocks jumping and lowers your speed so you stay quiet. It turns off by itself when it leaves.",
                ["Anti Glitch (Rooms / Backdoor)"] = "Anti Glitch (Rooms / Backdoor)",
                ["Neutraliza el modelo de Glitch (sin contacto) y activa el Godmode automático si se acerca."] = "Neutralizes the Glitch model (no contact) and turns on Auto Godmode if it gets close.",
                ["Anti Lookman (Backdoor)"] = "Anti Lookman (Backdoor)",
                ["Además del método de Anti Eyes, gira la cámara lejos del Lookman para que no te pille mirándolo."] = "Besides the Anti Eyes method, it turns the camera away from Lookman so it doesn't catch you looking.",
                ["Seek God Mode (persecuciones)"] = "Seek God Mode (chases)",
                ["Alcance del Seek God Mode"] = "Seek God Mode range",
                ["🛡 Seek God Mode: persecución de Seek activa"] = "🛡 Seek God Mode: Seek chase active",
                ["Activa el Godmode (Nova) solo durante las persecuciones de Seek y lo apaga al terminar. No actúa si estás escondido."] = "Turns on the (Nova) Godmode only during Seek chases and turns it off when they end. It does nothing while you're hiding.",
                ["Auto Calderos (usar calderos cerca)"] = "Auto Cauldrons (use nearby cauldrons)",
                ["Usa los calderos del Candy Vault solos cuando pasas cerca. Necesita el Candy Vault ESP para marcarlos."] = "Uses the Candy Vault cauldrons by itself when you walk past them. Needs Candy Vault ESP to mark them.",
                ["📍 TP a la candy más cercana"] = "📍 TP to the nearest candy",
                ["❌ No hay candy marcada todavía"] = "❌ No candy marked yet",
                ["📍 Teleportado a la candy más cercana"] = "📍 Teleported to the nearest candy",
                ["🍬 Dulces recogidos esta sesión: %d"] = "🍬 Candy collected this session: %d",
                ["🍬 %d dulces recogidos"] = "🍬 %d candy collected",
                ["Stairwell Guard (anti lag + anti void)"] = "Stairwell Guard (anti lag + anti void)",
                ["🪜 Stairwell detectado: Anti Lag + Anti Void activados"] = "🪜 Stairwell detected: Anti Lag + Anti Void enabled",
                ["En Stairwell activa solo el Anti Lag y el Anti Void (rescate de caídas)."] = "In Stairwell it turns on Anti Lag and Anti Void (fall rescue) by itself.",
                ["ESP Camino (escaleras y agujeros) BETA"] = "Path ESP (stairs and holes) BETA",
                ["Marca escaleras, agujeros y escalas como objetivos para no perderte. Nombres internos sin confirmar (BETA)."] = "Marks stairs, holes and ladders as objectives so you don't get lost. Internal names unconfirmed (BETA).",
                ["📋 Copiar registro de entidades"] = "📋 Copy entity log",
                ["⚠ Aún no se registró ninguna entidad"] = "⚠ No entity registered yet",
                ["Copia la lista de entidades vistas con hora, piso y sala."] = "Copies the list of entities seen with time, floor and room.",
                ["HUD de entidades activas"] = "Active entities HUD",
                ["👁 Entidades activas: %d"] = "👁 Active entities: %d",
                ["Zoom máximo de cámara"] = "Max camera zoom",
                ["Novedades V8"] = "What's new in V8",
                ["Pro V8 (Noise / Glitch / Lookman)"] = "Pro V8 (Noise / Glitch / Lookman)",
                ["Candy Vault+ (V8)"] = "Candy Vault+ (V8)",
                ["Stairwell+ (V8)"] = "Stairwell+ (V8)",
                ["Extras V8"] = "V8 extras",
                ["🌟 V8 — Lo nuevo"] = "🌟 V8 — What's new",
                ["🛡 Anti Noise (modo silencio), Anti Glitch y Anti Lookman"] = "🛡 Anti Noise (quiet mode), Anti Glitch and Anti Lookman",
                ["⚫ Seek God Mode: Godmode automático en las persecuciones de Seek"] = "⚫ Seek God Mode: automatic Godmode during Seek chases",
                ["🍬 Candy Vault+: Auto Calderos, contador de dulces y TP a la candy más cercana"] = "🍬 Candy Vault+: Auto Cauldrons, candy counter and TP to the nearest candy",
                ["🪜 Stairwell+: Stairwell Guard y ESP Camino (escaleras y agujeros)"] = "🪜 Stairwell+: Stairwell Guard and Path ESP (stairs and holes)",
                ["📋 Registro de entidades con hora, piso y sala"] = "📋 Entity log with time, floor and room",
                ["👁 HUD de entidades activas y zoom de cámara libre"] = "👁 Active entities HUD and free camera zoom",
                ["⚡ Optimización: caché de traducciones (UI más fluida)"] = "⚡ Optimization: translation cache (smoother UI)",
                ["🌀 GLITCH: avanza a la siguiente sala o escóndete"] = "🌀 GLITCH: move on to the next room or hide",
                ["✅ Glitch se fue"] = "✅ Glitch left",
                ["💥 Glitch Rush se fue"] = "💥 Glitch Rush left",
                ["💥 Glitch Ambush se fue"] = "💥 Glitch Ambush left",
                ["😈 SCREECH: escucha el shhh y míralo rápido"] = "😈 SCREECH: hear the shhh and look at it fast",
            }
            local pt = {
                ["Anti Noise (modo silencio) BETA"] = "Anti Noise (modo silencioso) BETA",
                ["Velocidad en modo silencio"] = "Velocidade no modo silencioso",
                ["🔊 Noise cerca: modo silencio activado"] = "🔊 Noise por perto: modo silencioso ativado",
                ["✅ Noise se fue, ya puedes hacer ruido"] = "✅ Noise foi embora, já pode fazer barulho",
                ["Mientras Noise está cerca te agacha, bloquea el salto y baja tu velocidad para no hacer ruido. Se desactiva solo cuando se va."] = "Enquanto o Noise está perto, ele te agacha, bloqueia o pulo e reduz sua velocidade para você ficar em silêncio. Desliga sozinho quando ele vai embora.",
                ["Anti Glitch (Rooms / Backdoor)"] = "Anti Glitch (Rooms / Backdoor)",
                ["Neutraliza el modelo de Glitch (sin contacto) y activa el Godmode automático si se acerca."] = "Neutraliza o modelo do Glitch (sem contato) e ativa o Godmode automático se ele chegar.",
                ["Anti Lookman (Backdoor)"] = "Anti Lookman (Backdoor)",
                ["Además del método de Anti Eyes, gira la cámara lejos del Lookman para que no te pille mirándolo."] = "Além do método do Anti Eyes, gira a câmera para longe do Lookman para ele não te pegar olhando.",
                ["Seek God Mode (persecuciones)"] = "Seek God Mode (perseguições)",
                ["Alcance del Seek God Mode"] = "Alcance do Seek God Mode",
                ["🛡 Seek God Mode: persecución de Seek activa"] = "🛡 Seek God Mode: perseguição do Seek ativa",
                ["Activa el Godmode (Nova) solo durante las persecuciones de Seek y lo apaga al terminar. No actúa si estás escondido."] = "Ativa o Godmode (Nova) só durante as perseguições do Seek e desliga quando terminam. Não age se você estiver escondido.",
                ["Auto Calderos (usar calderos cerca)"] = "Auto Caldeirões (usar caldeirões perto)",
                ["Usa los calderos del Candy Vault solos cuando pasas cerca. Necesita el Candy Vault ESP para marcarlos."] = "Usa os caldeirões do Candy Vault sozinho quando você passa perto. Precisa do Candy Vault ESP para marcá-los.",
                ["📍 TP a la candy más cercana"] = "📍 TP para o doce mais próximo",
                ["❌ No hay candy marcada todavía"] = "❌ Nenhum doce marcado ainda",
                ["📍 Teleportado a la candy más cercana"] = "📍 Teleportado para o doce mais próximo",
                ["🍬 Dulces recogidos esta sesión: %d"] = "🍬 Doces coletados nesta sessão: %d",
                ["🍬 %d dulces recogidos"] = "🍬 %d doces coletados",
                ["Stairwell Guard (anti lag + anti void)"] = "Stairwell Guard (anti lag + anti void)",
                ["🪜 Stairwell detectado: Anti Lag + Anti Void activados"] = "🪜 Stairwell detectado: Anti Lag + Anti Void ativados",
                ["En Stairwell activa solo el Anti Lag y el Anti Void (rescate de caídas)."] = "No Stairwell ativa sozinho o Anti Lag e o Anti Void (resgate de quedas).",
                ["ESP Camino (escaleras y agujeros) BETA"] = "ESP Caminho (escadas e buracos) BETA",
                ["Marca escaleras, agujeros y escalas como objetivos para no perderte. Nombres internos sin confirmar (BETA)."] = "Marca escadas, buracos e escadas como objetivos para você não se perder. Nomes internos não confirmados (BETA).",
                ["📋 Copiar registro de entidades"] = "📋 Copiar registro de entidades",
                ["⚠ Aún no se registró ninguna entidad"] = "⚠ Nenhuma entidade registrada ainda",
                ["Copia la lista de entidades vistas con hora, piso y sala."] = "Copia a lista de entidades vistas com hora, andar e sala.",
                ["HUD de entidades activas"] = "HUD de entidades ativas",
                ["👁 Entidades activas: %d"] = "👁 Entidades ativas: %d",
                ["Zoom máximo de cámara"] = "Zoom máximo da câmera",
                ["Novedades V8"] = "Novidades V8",
                ["Pro V8 (Noise / Glitch / Lookman)"] = "Pro V8 (Noise / Glitch / Lookman)",
                ["Candy Vault+ (V8)"] = "Candy Vault+ (V8)",
                ["Stairwell+ (V8)"] = "Stairwell+ (V8)",
                ["Extras V8"] = "Extras V8",
                ["🌟 V8 — Lo nuevo"] = "🌟 V8 — O que há de novo",
                ["🛡 Anti Noise (modo silencio), Anti Glitch y Anti Lookman"] = "🛡 Anti Noise (modo silencioso), Anti Glitch e Anti Lookman",
                ["⚫ Seek God Mode: Godmode automático en las persecuciones de Seek"] = "⚫ Seek God Mode: Godmode automático nas perseguições do Seek",
                ["🍬 Candy Vault+: Auto Calderos, contador de dulces y TP a la candy más cercana"] = "🍬 Candy Vault+: Auto Caldeirões, contador de doces e TP para o doce mais próximo",
                ["🪜 Stairwell+: Stairwell Guard y ESP Camino (escaleras y agujeros)"] = "🪜 Stairwell+: Stairwell Guard e ESP Caminho (escadas e buracos)",
                ["📋 Registro de entidades con hora, piso y sala"] = "📋 Registro de entidades com hora, andar e sala",
                ["👁 HUD de entidades activas y zoom de cámara libre"] = "👁 HUD de entidades ativas e zoom livre da câmera",
                ["⚡ Optimización: caché de traducciones (UI más fluida)"] = "⚡ Otimização: cache de traduções (UI mais fluida)",
                ["🌀 GLITCH: avanza a la siguiente sala o escóndete"] = "🌀 GLITCH: vá para a próxima sala ou se esconda",
                ["✅ Glitch se fue"] = "✅ Glitch foi embora",
                ["💥 Glitch Rush se fue"] = "💥 Glitch Rush foi embora",
                ["💥 Glitch Ambush se fue"] = "💥 Glitch Ambush foi embora",
                ["😈 SCREECH: escucha el shhh y míralo rápido"] = "😈 SCREECH: ouça o shhh e olhe rápido",
            }
            for k, v in pairs(en) do TR.en[k] = v end
            for k, v in pairs(pt) do TR.pt[k] = v end
            trFlush()
        end)

        -- helper (V8): activa por nombre un toggle ya creado (busca en el registro del hub)
        local function setNamedToggle(name, v)
            for _, t in ipairs(HUI.named or {}) do
                if t.name == name then
                    t.set(v)
                    return true
                end
            end
            return false
        end

        -- ===== ANTI NOISE (Stairwell / Archives): modo silencio mientras Noise está cerca =====
        -- Noise castiga el ruido: mientras está activo te agachamos (Crouch falso), bloqueamos
        -- el salto y bajamos la velocidad. Cuando se va, todo vuelve como estaba.
        local noise = { on = false, ws = nil, lastCrouch = 0 }
        local function noisePresent()
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent and def.n == "NOISE" then return true end
            end
            local w = workspace:FindFirstChild("Noise")
            return w ~= nil and w:IsA("Model")
        end
        local function noiseRelease()
            if not noise.on then return end
            noise.on = false
            pcall(function() game:GetService("ContextActionService"):UnbindAction("RH_NoiseJump") end)
            local hum = getHum()
            if hum and noise.ws then hum.WalkSpeed = noise.ws end
            if alive then notify("✅ Noise se fue, ya puedes hacer ruido", "ok", 3) end
        end
        Section(HPG.pAnti, "Pro V8 (Noise / Glitch / Lookman)")
        Toggle(HPG.pAnti, "Anti Noise (modo silencio) BETA", false, function(on)
            S.antiNoise = on
            if not on then noiseRelease() return end
            startLoop("antiNoise", 0.15, function()
                if noisePresent() then
                    if not noise.on then
                        noise.on = true
                        local hum = getHum()
                        if hum then noise.ws = hum.WalkSpeed end
                        pcall(function()
                            game:GetService("ContextActionService"):BindActionAtPriority("RH_NoiseJump",
                                function() return Enum.ContextActionResult.Sink end, false, 3000,
                                Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
                        end)
                        notify("🔊 Noise cerca: modo silencio activado", "danger", 4)
                    end
                    local hum = getHum()
                    if hum then hum.WalkSpeed = math.min(hum.WalkSpeed, S.noiseQuiet or 6) end
                    if os.clock() - noise.lastCrouch > 0.3 then
                        noise.lastCrouch = os.clock()
                        fire("Crouch", true, true)
                    end
                else
                    noiseRelease()
                end
            end)
        end)
        S.noiseQuiet = 6
        Slider(HPG.pAnti, "Velocidad en modo silencio", 0, 16, 6, function(v) S.noiseQuiet = v end)
        Label(HPG.pAnti, "Mientras Noise está cerca te agacha, bloquea el salto y baja tu velocidad para no hacer ruido. Se desactiva solo cuando se va.", Color3.fromRGB(190, 180, 225))
        onCleanup(noiseRelease)

        -- ===== ANTI GLITCH (Rooms / Backdoor): neutraliza el modelo + Godmode automático =====
        local function isGlitchName(nm) return nm == "Glitch" or nm == "GlitchRush" or nm == "GlitchAmbush" end
        local function glitchNeutralize(e)
            if not e.Parent then return end
            if e:IsA("BasePart") then HANTI.disablePart(e) end
            for _, part in ipairs(e:GetDescendants()) do HANTI.disablePart(part) end
            for _, part in ipairs(e:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanQuery = false end) end
            end
        end
        track(workspace.ChildAdded:Connect(function(ch)
            if not S.antiGlitch then return end
            if isGlitchName(ch.Name) and ch:IsA("Model") then
                task.wait(0.05) -- deja que cargue el modelo
                pcall(glitchNeutralize, ch)
                local conn
                conn = ch.DescendantAdded:Connect(function(d)
                    if not ch.Parent then conn:Disconnect() return end
                    pcall(HANTI.disablePart, d)
                end)
                task.delay(6, function() if conn then conn:Disconnect() end end)
            end
        end))
        Toggle(HPG.pAnti, "Anti Glitch (Rooms / Backdoor)", false, function(on)
            S.antiGlitch = on
            if not on then
                HANTI.restoreParts(function(p)
                    local m = p:FindFirstAncestorWhichIsA("Model")
                    return m ~= nil and isGlitchName(m.Name)
                end)
                return
            end
            for _, e in ipairs(workspace:GetChildren()) do
                if isGlitchName(e.Name) then pcall(glitchNeutralize, e) end
            end
            startLoop("antiGlitch", 0.2, function()
                local hrp = getHRP()
                if not hrp then return end
                for _, e in ipairs(workspace:GetChildren()) do
                    if isGlitchName(e.Name) and e:IsA("Model") then
                        local ok, pos = pcall(function() return e:GetPivot().Position end)
                        if ok and (pos - hrp.Position).Magnitude <= 200 then
                            engage("Glitch")
                            return
                        end
                    end
                end
                releaseCheck()
            end)
        end)
        Label(HPG.pAnti, "Neutraliza el modelo de Glitch (sin contacto) y activa el Godmode automático si se acerca.", Color3.fromRGB(190, 180, 225))

        -- ===== ANTI LOOKMAN (Backdoor): remote + cámara lejos del Lookman =====
        local lookAcc = 0
        local function lookmanPresent()
            if workspace:FindFirstChild("Lookman") then return true end
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent and def.n == "LOOKMAN" then return true end
            end
            return false
        end
        track(RunService.Heartbeat:Connect(function(dt)
            if not S.antiLookman then return end
            lookAcc = lookAcc + dt
            if lookAcc < 0.03 then return end
            lookAcc = 0
            if lookmanPresent() then
                pcall(function()
                    local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
                    local mr = rf and rf:FindFirstChild("MotorReplication")
                    if mr then mr:FireServer(-649) end
                end)
            end
        end))
        Toggle(HPG.pAnti, "Anti Lookman (Backdoor)", false, function(on)
            S.antiLookman = on
            pcall(function() RunService:UnbindFromRenderStep("RH_LookAway") end)
            if not on then return end
            RunService:BindToRenderStep("RH_LookAway", Enum.RenderPriority.Camera.Value + 1, function()
                if not S.antiLookman then return end
                local cam = workspace.CurrentCamera
                if not cam then return end
                local target
                for inst, def in pairs(HANTI.activeEnts) do
                    if inst.Parent and def.n == "LOOKMAN" then target = inst break end
                end
                if not (target and target.Parent) then return end
                local ok, pos = pcall(function() return target:GetPivot().Position end)
                if not ok then return end
                local eye = cam.CFrame.Position
                if (pos - eye).Magnitude > 80 then return end
                -- si lo estamos mirando, giramos la cámara suavemente hacia el lado contrario
                local toIt = (pos - eye)
                if toIt.Magnitude > 0.1 and cam.CFrame.LookVector:Dot(toIt.Unit) > 0.4 then
                    local away = CFrame.lookAt(eye, eye - toIt.Unit)
                    cam.CFrame = cam.CFrame:Lerp(away, 0.25)
                end
            end)
        end)
        Label(HPG.pAnti, "Además del método de Anti Eyes, gira la cámara lejos del Lookman para que no te pille mirándolo.", Color3.fromRGB(190, 180, 225))
        onCleanup(function() pcall(function() RunService:UnbindFromRenderStep("RH_LookAway") end) end)

        -- ===== SEEK GOD MODE: Godmode (Nova) solo durante las persecuciones de Seek =====
        S.seekRange = 250
        local function seekChaseNear()
            local hrp = getHRP()
            if not hrp then return false end
            local c = getChar()
            if c and c:GetAttribute("Hiding") then return false end -- escondido: no hace falta
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent and def.n == "SEEK" then
                    local ok, pos = pcall(function() return inst:GetPivot().Position end)
                    if ok and (pos - hrp.Position).Magnitude <= S.seekRange then return true end
                end
            end
            -- el rig de Seek a veces vive directo en workspace (SeekMoving / SeekRig...)
            for _, e in ipairs(workspace:GetChildren()) do
                if e:IsA("Model") and e.Name:sub(1, 4) == "Seek" then
                    local ok, pos = pcall(function() return e:GetPivot().Position end)
                    if ok and (pos - hrp.Position).Magnitude <= S.seekRange then return true end
                end
            end
            return false
        end
        local seekNotified = false
        Toggle(HPG.pAnti, "Seek God Mode (persecuciones)", false, function(on)
            S.seekGod = on
            seekNotified = false
            if not on then
                releaseNow()
                return
            end
            startLoop("seekGod", 0.15, function()
                if seekChaseNear() then
                    if not seekNotified then
                        seekNotified = true
                        notify("🛡 Seek God Mode: persecución de Seek activa", "info", 2)
                    end
                    engage("Seek")
                else
                    seekNotified = false
                    releaseCheck()
                end
            end)
        end)
        Slider(HPG.pAnti, "Alcance del Seek God Mode", 50, 400, 250, function(v) S.seekRange = v end)
        Label(HPG.pAnti, "Activa el Godmode (Nova) solo durante las persecuciones de Seek y lo apaga al terminar. No actúa si estás escondido.", Color3.fromRGB(190, 180, 225))

        -- ===== Registro de entidades (V8) =====
        Button(HPG.pAnti, "📋 Copiar registro de entidades", function()
            local log = HST.entLog or {}
            if #log == 0 then notify("⚠ Aún no se registró ninguna entidad", "warn", 3) return end
            local out = { "== Entity log (V8) ==" }
            for _, e in ipairs(log) do table.insert(out, e) end
            HNET.copyOut(out)
        end)
        Label(HPG.pAnti, "Copia la lista de entidades vistas con hora, piso y sala.", Color3.fromRGB(190, 180, 225))

        -- ===== CANDY VAULT+ (V8) =====
        Section(HPG.pFloor, "Candy Vault+ (V8)")
        Toggle(HPG.pFloor, "Auto Calderos (usar calderos cerca)", false, function(on)
            S.autoCauldron = on
            if not on then return end
            if not S.candyScanOn then
                S.candyScanOn = true
                HESP.candyRescan()
            end
            startLoop("autoCauldron", 0.4, function()
                local hrp = getHRP()
                if not (hrp and fireproximityprompt) then return end
                for obj, d in pairs(HESP.cands.Candy) do
                    if obj.Parent and d[2] == "🧪 Cauldron" then
                        local okp, pos = pcall(function() return obj:GetPivot().Position end)
                        if okp and (pos - hrp.Position).Magnitude <= 12 then
                            local pr = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pr and pr.Enabled and os.clock() - (obj:GetAttribute("RH_caldT") or 0) > 2 then
                                obj:SetAttribute("RH_caldT", os.clock())
                                pcall(fireproximityprompt, pr)
                            end
                        end
                    end
                end
            end)
        end)
        Button(HPG.pFloor, "📍 TP a la candy más cercana", function()
            local hrp = getHRP()
            if not hrp then return end
            if not S.candyScanOn then
                S.candyScanOn = true
                HESP.candyRescan()
                task.wait(0.2)
            end
            local best, bd = nil, math.huge
            for obj, d in pairs(HESP.cands.Candy) do
                if obj.Parent and d[2] ~= "🧪 Cauldron" then
                    local ok, pos = pcall(function() return obj:GetPivot().Position end)
                    if ok then
                        local dist = (pos - hrp.Position).Magnitude
                        if dist < bd then bd, best = dist, pos end
                    end
                end
            end
            if not best then notify("❌ No hay candy marcada todavía", "warn", 3) return end
            hrp.CFrame = CFrame.new(best + Vector3.new(0, 3, 0))
            notify("📍 Teleportado a la candy más cercana", "ok", 3)
        end)
        Label(HPG.pFloor, "Usa los calderos del Candy Vault solos cuando pasas cerca. Necesita el Candy Vault ESP para marcarlos.", Color3.fromRGB(190, 180, 225))
        do
            local candyLbl = Label(HPG.pFloor, function() return trf("🍬 Dulces recogidos esta sesión: %d", HST.candyN or 0) end, Color3.fromRGB(255, 200, 235))
            task.spawn(function()
                while alive do
                    task.wait(1)
                    local pg = HUI.pages["Pisos"]
                    if pg and pg.Visible and win.Visible then
                        HUI.rebind(candyLbl, function()
                            return trf("🍬 Dulces recogidos esta sesión: %d", HST.candyN or 0)
                        end)
                    end
                end
            end)
        end

        -- ===== STAIRWELL+ (V8) =====
        Section(HPG.pFloor, "Stairwell+ (V8)")
        Toggle(HPG.pFloor, "Stairwell Guard (anti lag + anti void)", false, function(on)
            S.stairGuard = on
            if not on then return end
            local applied = false
            startLoop("stairGuard", 3, function()
                local f = ""
                pcall(function()
                    local gd = ReplicatedStorage:FindFirstChild("GameData")
                    local fv = gd and gd:FindFirstChild("Floor")
                    if fv then f = tostring(fv.Value):lower() end
                end)
                local inStair = f:find("stair", 1, true) ~= nil
                if inStair and not applied then
                    applied = true
                    HLAG.setLagFx(true)
                    setNamedToggle("Anti Void (rescate)", true)
                    notify("🪜 Stairwell detectado: Anti Lag + Anti Void activados", "ok", 3)
                elseif not inStair then
                    applied = false
                end
            end)
        end)
        Toggle(HPG.pFloor, "ESP Camino (escaleras y agujeros) BETA", false, function(on)
            if not on then return end
            local rooms = getRooms()
            if not rooms then return end
            task.spawn(function()
                local i = 0
                for _, d in ipairs(rooms:GetDescendants()) do
                    if not alive then return end
                    if d:IsA("Model") then
                        local ln = d.Name:lower()
                        if ln:find("stair", 1, true) or ln:find("hole", 1, true) or ln:find("ladder", 1, true) then
                            HESP.cand("Objective", d, Color3.fromRGB(0, 190, 255), "🪜 Camino")
                        end
                    end
                    i = i + 1
                    if i % 300 == 0 then task.wait() end
                end
            end)
            setESP("Objective", true)
        end)
        Label(HPG.pFloor, "Marca escaleras, agujeros y escalas como objetivos para no perderte. Nombres internos sin confirmar (BETA).", Color3.fromRGB(190, 180, 225))
        Label(HPG.pFloor, "En Stairwell activa solo el Anti Lag y el Anti Void (rescate de caídas).", Color3.fromRGB(190, 180, 225))

        -- ===== VISUAL: HUD de entidades + zoom de cámara (V8) =====
        Section(HPG.pVis, "Extras V8")
        local entHud = new("TextLabel", {
            Name = "RH_EntHud", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 34),
            Size = UDim2.new(0, 170, 0, 24), BackgroundColor3 = Color3.fromRGB(16, 11, 29),
            BackgroundTransparency = 0.25, TextColor3 = Color3.fromRGB(230, 220, 255),
            Font = Enum.Font.GothamBold, TextSize = 13, Text = "👁 0", Visible = false,
        }, gui)
        corner(entHud, 8)
        stroke(entHud, HUI.accent, 1.2)
        HUI.onAccent(function(c) entHud.TextColor3 = lighten(c, 0.35) end)
        Toggle(HPG.pVis, "HUD de entidades activas", false, function(on)
            S.entHud = on
            entHud.Visible = on
            if on then
                startLoop("entHud", 0.5, function()
                    local n = 0
                    for inst in pairs(HANTI.activeEnts) do
                        if inst.Parent then n = n + 1 end
                    end
                    entHud.Text = trf("👁 Entidades activas: %d", n)
                end)
            end
        end)
        Slider(HPG.pVis, "Zoom máximo de cámara", 10, 240, 128, function(v)
            pcall(function() LocalPlayer.CameraMaxZoomDistance = v end)
        end)

        -- ===== Info: novedades V8 =====
        Section(HPG.pInfo, "Novedades V8")
        HUI.Card(HPG.pInfo, "🌟 V8 — Lo nuevo", {
            "🛡 Anti Noise (modo silencio), Anti Glitch y Anti Lookman",
            "⚫ Seek God Mode: Godmode automático en las persecuciones de Seek",
            "🍬 Candy Vault+: Auto Calderos, contador de dulces y TP a la candy más cercana",
            "🪜 Stairwell+: Stairwell Guard y ESP Camino (escaleras y agujeros)",
            "📋 Registro de entidades con hora, piso y sala",
            "👁 HUD de entidades activas y zoom de cámara libre",
            "⚡ Optimización: caché de traducciones (UI más fluida)",
        }, Color3.fromRGB(150, 70, 255), Color3.fromRGB(70, 30, 130))

    end

    ------------------------------------------------------------------
    -- ================= V8 =================
    -- Módulo aislado: corre dentro de su propio pcall/función, así que si algo falla
    -- aquí NO se rompe el resto del hub (y no gasta locales del hub principal).
    ------------------------------------------------------------------
    do
    local okV8, errV8 = pcall(function()
        local Stats = game:GetService("Stats")

        -- traducciones (es -> en / pt)
        local function addTR(es, en, pt)
            TR.en[es] = en
            TR.pt[es] = pt
            pcall(trFlush)
        end
        addTR("Anti Noise / Hijack (eliminar entidad) BETA", "Anti Noise / Hijack (eliminar entidad) BETA", "Anti Noise / Hijack (eliminar entidad) BETA")
        addTR("Anti Glitch", "Anti Glitch", "Anti Glitch")
        addTR("Anti Lookman (Backdoor)", "Anti Lookman (Backdoor)", "Anti Lookman (Backdoor)")
        addTR("Anti Haste + Auto Palanca de tiempo (Backdoor)", "Anti Haste + Auto Timer Lever (Backdoor)", "Anti Haste + Auto Alavanca de tempo (Backdoor)")
        addTR("Anti Vacuum + rescate del vacío", "Anti Vacuum + void rescue", "Anti Vacuum + resgate do vazio")
        addTR("Anti Socker (Candy Vault)", "Anti Socker (Candy Vault)", "Anti Socker (Candy Vault)")
        addTR("Auto Scrap (Stairwell)", "Auto Scrap (Stairwell)", "Auto Scrap (Stairwell)")
        addTR("HUD (FPS / Ping / Sala / Candy Vault)", "HUD (FPS / Ping / Room / Candy Vault)", "HUD (FPS / Ping / Sala / Candy Vault)")
        addTR("📋 Copiar candidatos V8 (Seek Wall, Noise, Vacuum...)", "📋 Copy V8 candidates (Seek Wall, Noise, Vacuum...)", "📋 Copiar candidatos V8 (Seek Wall, Noise, Vacuum...)")
        addTR("⚠ No hay candidatos para copiar", "⚠ No candidates to copy", "⚠ Nenhum candidato para copiar")
        addTR("🛟 Anti Vacuum: te devolví al último suelo seguro", "🛟 Anti Vacuum: sent you back to the last safe floor", "🛟 Anti Vacuum: te devolvi ao último chão seguro")
        addTR("⏱ Haste: jalando la palanca de tiempo", "⏱ Haste: pulling the timer lever", "⏱ Haste: puxando a alavanca de tempo")
        addTR("Anti Noise/Hijack, Glitch, Lookman, Haste, Vacuum y Socker quitan el contacto de la entidad (cliente). Si alguno no responde, usa el botón de candidatos y mándame el texto.", "Anti Noise/Hijack, Glitch, Lookman, Haste, Vacuum and Socker remove the entity's contact (client side). If one doesn't respond, use the candidates button and send me the text.", "Anti Noise/Hijack, Glitch, Lookman, Haste, Vacuum e Socker tiram o contato da entidade (cliente). Se algum não responder, use o botão de candidatos e me mande o texto.")
        addTR("Candy Vault: %s restantes", "Candy Vault: %s left", "Candy Vault: %s restantes")
        addTR("Anti Lookman: mira al suelo cuando lo tienes de frente y bloquea su mirada.", "Anti Lookman: looks at the floor when it is in front of you and blocks its gaze.", "Anti Lookman: olha para o chão quando ele está à frente e bloqueia o olhar.")

        ----------------------------------------------------------------
        -- Reglas de "fantasma": quitan el contacto del modelo (cliente)
        ----------------------------------------------------------------
        local RULES = {
            v8Noise  = { tag = "v8noise",  names = { "noise", "hijack", "sadako" }, destroy = true },
            v8Glitch = { tag = "v8glitch", names = { "glitch" } },
            v8Look   = { tag = "v8look",   names = { "lookman" } },
            v8Haste  = { tag = "v8haste",  names = { "haste" } },
            v8Vacuum = { tag = "v8vac",    names = { "vacuum", "sideroomspace" } },
            v8Socker = { tag = "v8socker", names = { "socker" } },
        }
        local rescue = { cf = nil, y = 0, last = 0, vacT = 0 }

        local function ruleFor(inst)
            local ln = inst.Name:lower()
            for flag, r in pairs(RULES) do
                if S[flag] then
                    for _, key in ipairs(r.names) do
                        if ln:find(key, 1, true) then return r, ln end
                    end
                end
            end
        end
        local function ghostNow(inst, r, ln)
            if not inst.Parent then return end
            -- entidades del cliente que nacen directo en workspace (como Ransom): se eliminan
            if r.destroy and inst.Parent == workspace and inst:IsA("Model") then
                pcall(function() inst:Destroy() end)
                return
            end
            if r.tag == "v8vac" then rescue.vacT = os.clock() end
            if ln == "sideroomspace" then
                -- el espacio de Vacuum: solo se apaga el contacto, la colisión queda (si no te caes)
                local col = inst:FindFirstChild("Collision")
                if col and col:IsA("BasePart") then
                    if HANTI.ghostOrig[col] == nil then HANTI.ghostOrig[col] = { col.CanTouch, col.CanCollide, r.tag } end
                    col.CanTouch = false
                end
                return
            end
            HANTI.ghostModel(inst, r.tag)
        end
        local function anyRule()
            for flag in pairs(RULES) do if S[flag] then return true end end
            return false
        end
        local hookConn
        local function v8Apply(inst)
            if not (inst:IsA("Model") or (inst:IsA("BasePart") and inst.Parent == workspace)) then return end
            local r, ln = ruleFor(inst)
            if not r then return end
            pcall(ghostNow, inst, r, ln)
            -- los hijos suelen replicarse un poco después: segunda pasada
            task.delay(0.4, function() if anyRule() then pcall(ghostNow, inst, r, ln) end end)
        end

        local function scan()
            task.spawn(function()
                for _, o in ipairs(workspace:GetChildren()) do pcall(v8Apply, o) end
                local rooms = getRooms()
                if rooms then
                    local i = 0
                    for _, d in ipairs(rooms:GetDescendants()) do
                        if not alive then return end
                        if d:IsA("Model") then pcall(v8Apply, d) end
                        i = i + 1
                        if i % 400 == 0 then task.wait() end
                    end
                end
            end)
        end
        local function syncHook()
            if anyRule() then
                if not hookConn then
                    hookConn = workspace.DescendantAdded:Connect(function(d)
                        if d:IsA("Model") or (d:IsA("BasePart") and d.Parent == workspace) then
                            if ruleFor(d) then task.delay(0.1, v8Apply, d) end
                        end
                    end)
                end
            elseif hookConn then
                hookConn:Disconnect()
                hookConn = nil
            end
        end
        local function setRule(flag, on)
            S[flag] = on or nil
            syncHook()
            if on then scan() else HANTI.restoreGhost(RULES[flag].tag) end
        end
        onCleanup(function()
            if hookConn then hookConn:Disconnect() hookConn = nil end
            for _, r in pairs(RULES) do pcall(HANTI.restoreGhost, r.tag) end
        end)

        ----------------------------------------------------------------
        -- Antis nuevos
        ----------------------------------------------------------------
        Section(HPG.pAnti, "V8: Stairwell / Candy Vault / Backdoor")
        Toggle(HPG.pAnti, "Anti Noise / Hijack (eliminar entidad) BETA", false, function(on) setRule("v8Noise", on) end)
        Toggle(HPG.pAnti, "Anti Socker (Candy Vault)", false, function(on) setRule("v8Socker", on) end)

        -- Anti Haste: contacto fuera + jala sola la palanca de tiempo (lo que de verdad lo frena)
        Toggle(HPG.pAnti, "Anti Haste + Auto Palanca de tiempo (Backdoor)", false, function(on)
            setRule("v8Haste", on)
            if not on then return end
            startLoop("v8Haste", 1, function()
                local hrp = getHRP()
                local rooms = getRooms()
                if not (hrp and rooms and fireproximityprompt) then return end
                local gd = ReplicatedStorage:FindFirstChild("GameData")
                local latest = gd and gd:FindFirstChild("LatestRoom") and tonumber(gd.LatestRoom.Value) or nil
                for _, room in ipairs(rooms:GetChildren()) do
                    local idx = tonumber(room.Name)
                    if not latest or (idx and math.abs(idx - latest) <= 2) then
                        for _, d in ipairs(room:GetDescendants()) do
                            if d:IsA("Model") and d.Name == "TimerLever" then
                                local pr = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                                local okp, pos = pcall(function() return d:GetPivot().Position end)
                                if pr and pr.Enabled and okp and (pos - hrp.Position).Magnitude <= 28
                                    and os.clock() - (d:GetAttribute("RH_v8t") or 0) > 3 then
                                    d:SetAttribute("RH_v8t", os.clock())
                                    notify("⏱ Haste: jalando la palanca de tiempo", "info", 2)
                                    pcall(fireproximityprompt, pr)
                                end
                            end
                        end
                    end
                end
            end)
        end)

        -- Anti Vacuum: contacto fuera + rescate si te lanza al vacío
        Toggle(HPG.pAnti, "Anti Vacuum + rescate del vacío", false, function(on)
            setRule("v8Vacuum", on)
            rescue.cf = nil
            if not on then return end
            startLoop("v8Vacuum", 0.2, function()
                local hrp, hum, c = getHRP(), getHum(), getChar()
                if not (hrp and hum) or hum.Health <= 0 or S.freecam then return end
                if hum.FloorMaterial ~= Enum.Material.Air and not (c and c:GetAttribute("Hiding")) then
                    -- no guardes el sitio si acabas de ser arrastrado lejos con Vacuum cerca
                    local far = rescue.cf and (hrp.Position - rescue.cf.Position).Magnitude > 120
                    if not (far and os.clock() - rescue.vacT < 10) then
                        rescue.cf, rescue.y = hrp.CFrame, hrp.Position.Y
                    end
                end
                if not rescue.cf then return end
                local fell = hrp.Position.Y < rescue.y - 70
                local yanked = os.clock() - rescue.vacT < 10 and (hrp.Position - rescue.cf.Position).Magnitude > 120
                if fell or yanked then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.CFrame = rescue.cf + Vector3.new(0, 3, 0)
                    if os.clock() - rescue.last > 3 then
                        rescue.last = os.clock()
                        notify("🛟 Anti Vacuum: te devolví al último suelo seguro", "ok", 3)
                    end
                end
            end)
        end)
        Label(HPG.pAnti, "Anti Noise/Hijack, Glitch, Lookman, Haste, Vacuum y Socker quitan el contacto de la entidad (cliente). Si alguno no responde, usa el botón de candidatos y mándame el texto.", Color3.fromRGB(255, 190, 120))

        -- Botón de diagnóstico: lista los nombres reales del juego (para afinar los antis)
        Button(HPG.pAnti, "📋 Copiar candidatos V8 (Seek Wall, Noise, Vacuum...)", function()
            local keys = { "scarywall", "seekwall", "seek", "noise", "hijack", "vacuum", "haste", "lookman", "glitch", "socker", "sideroom", "scrap", "candy", "disc", "television" }
            local out, n = {}, 0
            local function check(inst)
                if n >= 150 then return end
                if not (inst:IsA("Model") or inst:IsA("BasePart")) then return end
                local ln = inst.Name:lower()
                for _, k in ipairs(keys) do
                    if ln:find(k, 1, true) then
                        n = n + 1
                        table.insert(out, inst.ClassName .. " | " .. inst:GetFullName())
                        return
                    end
                end
            end
            for _, o in ipairs(workspace:GetChildren()) do check(o) end
            local rooms = getRooms()
            if rooms then
                for _, d in ipairs(rooms:GetDescendants()) do check(d) end
            end
            if #out == 0 then notify("⚠ No hay candidatos para copiar", "warn", 3) return end
            HNET.copyOut(out)
        end)

        ----------------------------------------------------------------
        -- V8.1: autos por cercanía (Scrap / Candy / Gold), speedrun y diagnóstico
        ----------------------------------------------------------------
        addTR("Auto Candy + Jewelry (Candy Vault)", "Auto Candy + Jewelry (Candy Vault)", "Auto Candy + Jewelry (Candy Vault)")
        addTR("Auto Gold (farmeo de oro)", "Auto Gold (gold farming)", "Auto Gold (farm de ouro)")
        addTR("Auto Puertas / Speedrun (BETA)", "Auto Doors / Speedrun (BETA)", "Auto Portas / Speedrun (BETA)")
        addTR("🧪 Grabar entidades y remotes 40s (diagnóstico)", "🧪 Record entities and remotes 40s (diagnostic)", "🧪 Gravar entidades e remotes 40s (diagnóstico)")
        addTR("🧪 Grabando 40s: acércate a la entidad. Toca otra vez para copiar ya.", "🧪 Recording 40s: get close to the entity. Tap again to copy now.", "🧪 Gravando 40s: aproxime-se da entidade. Toque de novo para copiar já.")
        addTR("🚪 No encontré la puerta de esta sala", "🚪 Couldn't find this room's door", "🚪 Não achei a porta desta sala")

        -- recoge por cercanía: busca modelos cuyo nombre contenga alguna palabra y dispara su prompt
        local function nearLoop(flag, words, radius, interval, exclude)
            startLoop(flag, interval, function()
                local hrp = getHRP()
                if not (hrp and fireproximityprompt) then return end
                local parts = workspace:GetPartBoundsInRadius(hrp.Position, radius, OverlapParams.new())
                local done = {}
                for _, p in ipairs(parts) do
                    local m, hops = p, 0
                    while m and m ~= workspace and hops < 4 do
                        local ln = m.Name:lower()
                        local hit = false
                        for _, w in ipairs(words) do
                            if ln:find(w, 1, true) then hit = true break end
                        end
                        if hit and exclude then
                            for _, w in ipairs(exclude) do
                                if ln:find(w, 1, true) then hit = false break end
                            end
                        end
                        if hit then
                            if not done[m] and os.clock() - (m:GetAttribute("RH_v8n") or 0) > 1.2 then
                                done[m] = true
                                local pr = m:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pr and pr.Enabled then
                                    m:SetAttribute("RH_v8n", os.clock())
                                    pcall(fireproximityprompt, pr)
                                end
                            end
                            break
                        end
                        m, hops = m.Parent, hops + 1
                    end
                end
            end)
        end
        Toggle(HPG.pFloor, "Auto Scrap (Stairwell)", false, function(on)
            S.v8Scrap = on
            if on then nearLoop("v8Scrap", { "scrap" }, 18, 0.4) end
        end)
        Toggle(HPG.pFloor, "Auto Candy + Jewelry (Candy Vault)", false, function(on)
            S.v8Candy = on
            if on then nearLoop("v8Candy", { "candy", "jewelry", "sweet", "treat" }, 20, 0.35, { "cauldron", "machine" }) end
        end)
        Toggle(HPG.pFloor, "Auto Gold (farmeo de oro)", false, function(on)
            S.v8Gold = on
            if on then nearLoop("v8Gold", { "gold" }, 20, 0.35, { "key", "door" }) end
        end)

        -- Auto Puertas: camina a la puerta de la sala actual y la abre (sirve para Candy Vault / pisos lineales)
        local PathS = game:GetService("PathfindingService")
        local walk = { gen = 0, warnT = 0 }
        local function walkTo(pos, gen)
            local h, hrp = getHum(), getHRP()
            if not (h and hrp) then return end
            local path = PathS:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 4, AgentMaxSlope = 45 })
            local ok = pcall(function() path:ComputeAsync(hrp.Position, pos) end)
            if not ok or path.Status ~= Enum.PathStatus.Success then
                h:MoveTo(pos)
                local t1 = tick()
                repeat task.wait() until (hrp.Position - pos).Magnitude < 4 or tick() - t1 > 2 or gen ~= walk.gen
                return
            end
            for _, wp in ipairs(path:GetWaypoints()) do
                if gen ~= walk.gen or not alive then return end
                if wp.Action == Enum.PathWaypointAction.Jump then h.Jump = true end
                h:MoveTo(wp.Position)
                local t0 = tick()
                repeat task.wait() until (hrp.Position - wp.Position).Magnitude < 3 or tick() - t0 > 1.5 or gen ~= walk.gen
                if (hrp.Position - wp.Position).Magnitude >= 3 then h.Jump = true end
            end
        end
        Toggle(HPG.pFloor, "Auto Puertas / Speedrun (BETA)", false, function(on)
            S.v8Walk = on
            walk.gen = walk.gen + 1
            local gen = walk.gen
            if not on then
                local h, hrp = getHum(), getHRP()
                if h and hrp then h:MoveTo(hrp.Position) end
                return
            end
            task.spawn(function()
                while alive and S.v8Walk and gen == walk.gen do
                    pcall(function()
                        local c, hrp = getChar(), getHRP()
                        if not (c and hrp) or LocalPlayer:GetAttribute("Alive") == false or c:GetAttribute("Hiding") then
                            task.wait(0.5)
                            return
                        end
                        local gd = ReplicatedStorage:FindFirstChild("GameData")
                        local latest = gd and gd:FindFirstChild("LatestRoom") and tonumber(gd.LatestRoom.Value) or 0
                        local rooms = getRooms()
                        local room = rooms and rooms:FindFirstChild(tostring(latest))
                        local door = room and room:FindFirstChild("Door")
                        local dpart = door and (door:FindFirstChild("Door") or door.PrimaryPart)
                        if not dpart then
                            if os.clock() - walk.warnT > 8 then
                                walk.warnT = os.clock()
                                notify("🚪 No encontré la puerta de esta sala", "warn", 3)
                            end
                            task.wait(1)
                            return
                        end
                        walkTo(dpart.Position, gen)
                        if (hrp.Position - dpart.Position).Magnitude < 14 then
                            local co = door:FindFirstChild("ClientOpen")
                            if co then pcall(co.FireServer, co) end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end)
        onCleanup(function() walk.gen = walk.gen + 1 end)

        -- Diagnóstico: graba entidades nuevas, remotes que llegan y cambios de vida (para afinar Noise, etc.)
        local rec = { on = false, log = {}, conns = {} }
        local function recStop(copy)
            rec.on = false
            for _, c in ipairs(rec.conns) do pcall(function() c:Disconnect() end) end
            rec.conns = {}
            if copy then
                if #rec.log == 0 then notify("⚠ No hay candidatos para copiar", "warn", 3) else HNET.copyOut(rec.log) end
            end
        end
        onCleanup(function() recStop(false) end)
        Button(HPG.pAnti, "🧪 Grabar entidades y remotes 40s (diagnóstico)", function()
            if rec.on then recStop(true) return end
            rec.on, rec.log = true, {}
            local t0 = os.clock()
            local function add(s)
                if #rec.log < 400 then table.insert(rec.log, string.format("[%.1f] %s", os.clock() - t0, s)) end
            end
            local function describe(inst)
                local attrs, kids = {}, {}
                for k, v in pairs(inst:GetAttributes()) do table.insert(attrs, tostring(k) .. "=" .. tostring(v)) end
                for _, ch in ipairs(inst:GetChildren()) do
                    if #kids < 14 then table.insert(kids, ch.ClassName .. ":" .. ch.Name) end
                end
                return inst.ClassName .. " " .. inst:GetFullName() .. " attrs{" .. table.concat(attrs, ",") .. "} kids[" .. table.concat(kids, ",") .. "]"
            end
            table.insert(rec.conns, workspace.ChildAdded:Connect(function(ch) add("WS+ " .. describe(ch)) end))
            local rooms = getRooms()
            if rooms then
                table.insert(rec.conns, rooms.DescendantAdded:Connect(function(d)
                    if d:IsA("Model") then
                        local ln = d.Name:lower()
                        if ln:find("noise", 1, true) or ln:find("hijack", 1, true) or ln:find("disc", 1, true)
                            or ln:find("television", 1, true) or ln:find("sadako", 1, true) or ln:find("vacuum", 1, true) then
                            task.delay(0.2, function() add("ROOM+ " .. describe(d)) end)
                        end
                    end
                end))
            end
            local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
            if rf then
                for _, r in ipairs(rf:GetChildren()) do
                    if r:IsA("RemoteEvent") then
                        table.insert(rec.conns, r.OnClientEvent:Connect(function(...)
                            local a = {}
                            for i, v in ipairs({ ... }) do if i <= 3 then table.insert(a, tostring(v)) end end
                            add("REMOTE " .. r.Name .. " (" .. table.concat(a, ",") .. ")")
                        end))
                    end
                end
            end
            local hum = getHum()
            if hum then
                local last = hum.Health
                table.insert(rec.conns, hum.HealthChanged:Connect(function(hp)
                    add(string.format("HP %d -> %d", last, hp))
                    last = hp
                end))
            end
            notify("🧪 Grabando 40s: acércate a la entidad. Toca otra vez para copiar ya.", "info", 5)
            task.delay(40, function() if rec.on and rec.log then recStop(true) end end)
        end)

        -- Diagnóstico del Auto Godmode: dice qué entidades ve y por qué cuentan o no
        addTR("🛡 Diagnóstico Auto Godmode (copiar)", "🛡 Auto Godmode diagnostic (copy)", "🛡 Diagnóstico Auto Godmode (copiar)")
        Button(HPG.pMain, "🛡 Diagnóstico Auto Godmode (copiar)", function()
            local hrp = getHRP()
            if not hrp then return end
            local out = { string.format("Mi Y = %.1f | distancia Auto Godmode = %s", hrp.Position.Y, tostring(S.autoGodDist)) }
            for _, e in ipairs(workspace:GetChildren()) do
                if e:IsA("Model") then
                    local ln = e.Name:lower()
                    if ln:find("rush", 1, true) or ln:find("ambush", 1, true) or ln:find("blitz", 1, true) or ln:find("a60", 1, true)
                        or ln:find("a120", 1, true) or ln:find("glitch", 1, true) or ln:find("bash", 1, true) or ln:find("seek", 1, true) then
                        local ok, pos = pcall(function() return e:GetPivot().Position end)
                        if ok then
                            table.insert(out, string.format("%s | dist %.0f | dY %.0f", e.Name, (pos - hrp.Position).Magnitude, pos.Y - hrp.Position.Y))
                        end
                    end
                end
            end
            for inst, def in pairs(HANTI.activeEnts) do
                if inst.Parent then table.insert(out, "activeEnts: " .. tostring(def.n) .. " <- " .. inst.Name) end
            end
            if #out == 1 then table.insert(out, "(no hay entidades peligrosas en workspace ahora)") end
            HNET.copyOut(out)
        end)

        ----------------------------------------------------------------
        -- HUD: FPS / Ping / Sala + cuenta atrás del Candy Vault (20 min)
        ----------------------------------------------------------------
        local hud = { gui = nil, conn = nil }
        local function hudStop()
            if hud.conn then hud.conn:Disconnect() hud.conn = nil end
            if hud.gui then hud.gui:Destroy() hud.gui = nil end
        end
        Toggle(HPG.pMain, "HUD (FPS / Ping / Sala / Candy Vault)", false, function(on)
            S.v8Hud = on
            hudStop()
            if not on then return end
            local g = new("ScreenGui", { Name = rndName(), ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 40 })
            parentGui(g)
            local lbl = new("TextLabel", {
                Size = UDim2.new(0, 210, 0, 40), Position = UDim2.new(0, 8, 0, 48),
                BackgroundColor3 = Color3.fromRGB(20, 14, 34), BackgroundTransparency = 0.25,
                TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamMedium, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, Text = "...",
            }, g)
            corner(lbl, 8)
            stroke(lbl, CONFIG.Accent, 1).Transparency = 0.4
            new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, lbl)
            hud.gui = g
            local frames, acc, fps, candyT0 = 0, 0, 60, nil
            hud.conn = RunService.RenderStepped:Connect(function(dt)
                frames = frames + 1
                acc = acc + dt
                if acc < 0.5 then return end
                fps = math.floor(frames / acc + 0.5)
                frames, acc = 0, 0
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                local room, floor = "?", ""
                pcall(function()
                    local gd = ReplicatedStorage:FindFirstChild("GameData")
                    if gd then
                        if gd:FindFirstChild("LatestRoom") then room = tostring(gd.LatestRoom.Value) end
                        if gd:FindFirstChild("Floor") then floor = tostring(gd.Floor.Value):lower() end
                    end
                end)
                local line2 = ""
                if floor:find("candy", 1, true) or floor:find("vault", 1, true) or floor:find("hollow", 1, true) then
                    candyT0 = candyT0 or os.clock()
                    local left = math.max(0, 1200 - (os.clock() - candyT0))
                    line2 = "\n" .. trf("Candy Vault: %s restantes", string.format("%d:%02d", math.floor(left / 60), math.floor(left % 60)))
                else
                    candyT0 = nil
                end
                lbl.Text = string.format("FPS %d  |  Ping %dms  |  Sala %s", fps, ping, room) .. line2
            end)
        end)
        onCleanup(hudStop)

    end)
    if not okV8 then warn("[Roshan V8] módulo V8 no cargó: " .. tostring(errV8)) end
    end

    HUI.setUiAnim(not IS_MOBILE)
    HUI.selectTab("Principal")
    if role then
        notify("⭐ Bienvenido %s %s", "ok", 5, role, LocalPlayer.Name)
    else
        notify("✅ %s cargado", "ok", 4, CONFIG.Name)
    end
end

----------------------------------------------------------------------
-- ENTRADA
----------------------------------------------------------------------
-- (V7) Arranque protegido: si algo falla al construir el hub, se avisa y se libera el
-- "ya está ejecutándose" (antes había que reiniciar el juego para volver a ejecutarlo).
do
    local startHubCore = startHub
    startHub = function(auth, isRebuild)
        local ok, err = xpcall(startHubCore, function(e) return tostring(e) end, auth, isRebuild)
        if not ok then
            warn("[Roshan] Error al iniciar el hub: " .. tostring(err))
            getgenv().RoshanHubLoaded = false
        end
    end
end

local ownerAuth = KeyGuard.owner()
local savedAuth = (not ownerAuth) and KeyGuard.load() or nil
if ownerAuth then
    markMember()
    startHub(ownerAuth) -- owner: entra directo, sin key
elseif savedAuth then
    markMember() -- tenía key guardada (versión anterior) = ya es Member
    startHub(savedAuth)
else
    -- primera vez: pantalla de carga corta y luego la ventana de la key
    pcall(showLoading, "Guest", RANKS.Guest, LocalPlayer.DisplayName, true)
    showKeyUI()
end
