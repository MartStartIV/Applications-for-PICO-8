pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.04]
-- PARTE 1 DE 4: NÚCLEO DE INICIALIZACIÓN Y CONTROL DE FLUX
-- =========================================================

function _init()
  id_nombre = "ADD NOTES XTREE"
  id_version = "V0.04"
  
  -- MÁQUINA DE ESTADOS COMPATIBLE CON MIPS
  -- 0 = selector de idioma
  -- 1 = selector de perfil de sexo
  -- 2 = menú principal de notas
  -- 3 = teclado virtual completo
  -- 4 = visor de notas multilínea
  -- 5 = pantalla "acerca de" con créditos
  modo_actual = 0 
  
  -- Diccionario de caracteres básico para evitar sobrecarga en memoria
  comp_dict = {
    " ","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
    "p","q","r","s","t","u","v","w","x","y","z",".",",","\xf1","-","?",
    "!","1","2","3","4","5","6","7","8","9","0","+","*","/","=","%",
    "[","]","(",")","{","}","@",":","#","$","&","_",";"
  }
  
  lista_idiomas = {"1. espanol", "2. english", "3. polski", "4. russian", "5. portugues", "6. italiano", "7. francais", "8. nihongo (jp)", "9. zhongwen (cn)", "10. hangugeo (kr)", "11. turkce (tr)"}
  nombres_temas_notas = {"matrix", "neon mid", "cyber", "ocean", "magma", "forest", "steel"}
  
  textos_sistema = {
    {"elije idioma:", "perfil sexo:", "hombre", "mujer", "no aplica", "notas creadas:", "crear nota?", "ver", "editar", "borrar", "vacio", "caracteres:", "guardar", "salir", "acerca de"},
    {"select lang:", "gender profile:", "male", "female", "n/a", "notes created:", "create note?", "view", "edit", "delete", "empty", "chars:", "save", "exit", "about"},
    {"wybierz jezyk:", "profil plci:", "mezczyzna", "kobieta", "n/a", "notatki:", "utworzyc?", "pokaz", "edytuj", "usun", "pusty", "znaki:", "zapisz", "wyjdz", "o programie"},
    {"vibor yazika:", "profil pola:", "muzhchina", "zhenshina", "n/a", "zametki:", "sozdat?", "smotret", "pravka", "udalit", "pusto", "simvoli:", "shranit", "vihod", "o prg"},
    {"escolha idioma:", "perfil sexo:", "homem", "mulher", "n/a", "notas:", "criar nota?", "ver", "editar", "excluir", "vazio", "caracteres:", "salvar", "sair", "sobre"},
    {"scegli lingua:", "profilo sesso:", "uomo", "donna", "n/a", "note:", "crea nota?", "vedi", "modifica", "elimina", "vuoto", "caratteri:", "salva", "esci", "info"},
    {"choisir langue:", "profil sexe:", "homme", "femme", "n/a", "notes:", "creer note?", "voir", "modifier", "effacer", "vide", "caracteres:", "garder", "sortir", "a propos"},
    {"gengo sentaku:", "seibetsu:", "dansei", "josei", "sonota", "memo suu:", "sakusei?", "miru", "henshuu", "sakujo", "kara", "moji suu:", "hozon", "modoru", "jouhou"},
    {"xuanze yuyan:", "xingbie:", "nanxing", "nvxing", "wuxiao", "biji shu:", "xinjian?", "chakan", "bianji", "shanchu", "kong", "zifu shu:", "baocun", "tuichu", "guanyu"},
    {"eoneo seontaek:", "seongbyeol:", "namseong", "yeoseong", "gita", "memo su:", "saengseong?", "bogi", "pyeonjip", "sakje", "bieo isseum", "geulja su:", "jeojang", "nagagi", "jeongbo"},
    {"dil secin:", "cinsiyet:", "erkek", "kadin", "yok", "notlar:", "not olustur?", "gor", "duzenle", "sil", "bos", "karakter:", "kaydet", "cikis", "hakkinda"}
  }

  -- Configuración de usuario por defecto
  idioma_actual = 1
  perfil_sexo = 3 -- 1=hombre, 2=mujer, 3=no aplica
  idx_tema = 1
  
  -- Controladores de listas y menús
  cursor_idioma = 1
  cursor_perfil = 1
  cursor_menu = 1
  visor_scroll_y = 0
  
  -- Memoria dinámica de notas
  lista_notas = {}      
  total_notas_permitidas = 10
  nota_seleccionada_idx = nil
  texto_nota_buffer = ""
  cursor_texto_pos = 1

  -- Variables para el scroll automático de créditos
  creditos_y = 128
  creditos_velocidad = 0.4
  creditos_max_scroll = 0

  -- Paletas de color optimizadas por perfil (Fondo, Display, Texto, Botón, Texto Botón)
  temas_hombre = { {0, 1, 10, 5, 7}, {1, 0, 11, 2, 7}, {0, 5, 14, 1, 7}, {0, 2, 12, 4, 7}, {0, 8, 14, 2, 8}, {13, 1, 10, 12, 7}, {1, 2, 7, 8, 15} }
  temas_mujer = { {2, 14, 8, 9, 7}, {4, 15, 14, 13, 7}, {15, 14, 8, 9, 7}, {2, 13, 7, 14, 2}, {0, 4, 15, 14, 7}, {1, 5, 6, 2, 14}, {15, 7, 2, 14, 0} }
  temas_naplica = { {0, 4, 5, 6, 7}, {3, 11, 3, 1, 11}, {0, 12, 7, 13, 12}, {0, 9, 10, 4, 9}, {15, 4, 14, 0, 7}, {5, 0, 9, 1, 10}, {1, 0, 7, 2, 15} }

  -- Variables de la mascota virtual animada
  ranita_x = 114
  ranita_y = 114
  ranita_anim = 0
  cronometro_emocion = 0
  estado_emocional = 1 
  aviso_texto = ""
  aviso_timer = 0
  codigos_idioma = {"es", "en", "pl", "ru", "pt", "it", "fr", "jp", "cn", "kr", "tr"}
  
  str_reloj = "00:00:00"
  
  -- Cerrojo de seguridad asíncrono para el hardware
  boot_cargado = false

  -- =========================================================
  -- EXTENSIÓN CONFIGURACIONES ADICIONALES [PARTE 1]
  -- =========================================================
  config_abierta = false   -- controla si la ventana flotante está activa
  config_cursor = 1        -- 1=zoom, 2=cambio idioma, 3=motivación, 4=borrado total
  config_zoom = 0          -- 0 = letra normal, 1 = letra ampliada
  config_motivacion = 0    -- 0 = desactivado, 1 = activado
  confirma_borrado = false -- escudo preventivo si/no por defecto en no

  -- banco de frases motivacionales ordenadas por idioma activo
  frases_motivacion = {
    "eres el mejor!",       -- 1. es
    "you are the best!",    -- 2. en
    "jestes najlepszy!",    -- 3. pl
    "ty luchshiy!",         -- 4. ru
    "voce e o melhor!",     -- 5. pt
    "sei il migliore!",     -- 6. it
    "tu es le meilleur!",   -- 7. fr
    "anata wa saikou!",     -- 8. jp
    "ni shi zui bang de!",  -- 9. cn
    "dangsin-i 최고!",     -- 10. kr
    "sen en iyisisin!"      -- 11. tr
  }
  frase_actual_idx = 1
  frase_timer = 0
  -- control de columna para la opcion 0 (1 = idioma, 2 = herramienta)
  columna_menu_cero = 1
end

function _update()
  -- 1. Activación de almacenamiento diferido en el Frame 1
  if not boot_cargado then
    boot_cargado = true
    local ok = pcall(function() cartdata("xtree_notes_pro") end)
    if ok then cargar_configuracion_inicial() end
  end

  if aviso_timer > 0 then aviso_timer = aviso_timer - 1 end

  -- 2. Animación base e inteligencia emocional dinámica de la mascota
  ranita_anim = (ranita_anim + 1) % 60
  cronometro_emocion = cronometro_emocion + 1
  -- Si el usuario presiona botones activos, la ranita reacciona y reinicia sueño
  if btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) then
    if estado_emocional == 6 then estado_emocional = 4 cronometro_emocion = 0 end
  end
  if cronometro_emocion >= 900 then 
    cronometro_emocion = 0
    -- Si hay notas creadas habilita los 7 estilos (incluyendo corona y lentes)
    local max_est = (#lista_notas > 0) and 7 or 6
    estado_emocional = 1 + flr(rnd(max_est))
  end

  -- 3. Actualizador del reloj del sistema a prueba de nulos
  local hrs = stat(93) or 0
  local mnts = stat(94) or 0
  local segs = stat(95) or 0
  local sh = tostr(hrs) if #sh < 2 then sh = "0"..sh end
  local sm = tostr(mnts) if #sm < 2 then sm = "0"..sm end
  local ss = tostr(segs) if #ss < 2 then ss = "0"..ss end
  str_reloj = sh..":"..sm..":"..ss

  -- 4. En la sección de atajos de tu _update(), sustituye este bloque específico:
  if btn(5) and btnp(0) and modo_actual >= 2 then
    if modo_actual != 5 then
      modo_previo_acercade = modo_actual
      modo_actual = 5
      creditos_y = 128 -- Reinicia el scroll abajo
      -- Ajustamos la velocidad aquí a 0.8 para que corra más rápido y fluido
      creditos_velocidad = 0.8 
      bloqueo_acercade = true -- Cierra el cerrojo de entrada
    end
    return
  end

  if btn(5) and btnp(1) and modo_actual >= 2 and modo_actual != 3 and modo_actual != 5 then
    idx_tema = idx_tema + 1
    if idx_tema > 7 then idx_tema = 1 end
    pcall(function() dset(2, idx_tema) end)
    return
  end

  -- 5. Procesador nativo de la máquina de estados con flancos discretos (btnp)
  if modo_actual == 0 then
    if btnp(2) then cursor_idioma = cursor_idioma - 1 if cursor_idioma < 1 then cursor_idioma = 11 end end
    if btnp(3) then cursor_idioma = cursor_idioma + 1 if cursor_idioma > 11 then cursor_idioma = 1 end end
    if btnp(4) then
      idioma_actual = cursor_idioma
      pcall(function() dset(0, idioma_actual) end)
      modo_actual = 1
    end
    
  elseif modo_actual == 1 then
    if btnp(2) then cursor_perfil = cursor_perfil - 1 if cursor_perfil < 1 then cursor_perfil = 3 end end
    if btnp(3) then cursor_perfil = cursor_perfil + 1 if cursor_perfil > 3 then cursor_perfil = 1 end end
    if btnp(4) then
      perfil_sexo = cursor_perfil
      pcall(function() dset(1, perfil_sexo) dset(3, 0) end)
      modo_actual = 2
      cursor_menu = 1
    end
    
  elseif modo_actual == 2 then
    if config_abierta then
      actualizar_opciones_adicionales()
    else
      actualizar_menu_principal_notas()
      
      -- despachador de frases motivacionales si está encendido
      if config_motivacion == 1 then
        frase_timer = frase_timer + 1
        if frase_timer > 300 then -- cambia de frase aproximadamente cada 10 segundos
          frase_timer = 0
          aviso_texto = frases_motivacion[idioma_actual]
          aviso_timer = 90
          estado_emocional = 4 -- la ranita se pone alegre automáticamente
          cronometro_emocion = 0
        end
      end
    end
  elseif modo_actual == 3 then
    actualizar_teclado_virtual()
  elseif modo_actual == 4 then
    actualizar_visor_nota()
  elseif modo_actual == 5 then
    if btnp(4) or btnp(5) then modo_actual = 2 end
  end
end
-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.04]
-- PARTE 2 DE 4: DESPACHADOR DE COLOR Y SELECTORES INICIALES
-- =========================================================

function _draw()
  -- 1. Buscamos la matriz de color base según el perfil de sexo seleccionado
  local c_base = temas_naplica[idx_tema]
  if perfil_sexo == 1 then c_base = temas_hombre[idx_tema]
  elseif perfil_sexo == 2 then c_base = temas_mujer[idx_tema] end
  
  -- [REPARACIÓN CRÍTICA] Indexación de enteros individuales para evitar pasar tablas a las funciones nativas
  local c_fondo   = c_base[1]
  local c_display = c_base[2]
  local c_txt_dis = c_base[3]
  local c_btn_bse = c_base[4]
  local c_btn_txt = c_base[5]

  -- 2. Despachador de renderizado por estados de la aplicación
  if modo_actual == 0 then
    render_selector_idioma()
  elseif modo_actual == 1 then
    render_selector_perfil()
  elseif modo_actual == 2 then
    render_pantalla_menu_notas(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  elseif modo_actual == 3 then
    render_pantalla_teclado_virtual(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  elseif modo_actual == 4 then
    render_pantalla_visor_nota(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  elseif modo_actual == 5 then
    render_pantalla_acercade()
  end
end


function render_selector_idioma()
  cls(0)
  rect(2, 2, 125, 125, 5)
  rectfill(4, 4, 123, 14, 1)
  print("add notes xtree", 32, 7, 7)
  print("elije tu idioma / select:", 14, 19, 6)
  
  -- Renderizado lineal directo para 11 idiomas
  for i=1, 11 do
    local ly = 29 + (i - 1) * 7
    local texto_menu = lista_idiomas[i]
    
    if i == cursor_idioma then
      rectfill(6, ly - 1, 121, ly + 5, 5)
      print("-> " .. texto_menu, 10, ly, 7)
    else
      print("   " .. texto_menu, 10, ly, 13)
    end
  end
  print("press (a) to confirm", 24, 117, 11)
end


function render_selector_perfil()
  cls(0)
  rect(2, 2, 125, 125, 14)
  rectfill(4, 4, 123, 14, 4)
  
  -- Extracción dinámica basada en el idioma confirmado
  local t_header = textos_sistema[idioma_actual][2] -- "perfil sexo:"
  local hx = 64 - (#t_header * 4) / 2
  print(t_header, hx, 7, 7)
  
  for i=1, 3 do
    local ly = 48 + (i - 1) * 16
    local texto_opcion = textos_sistema[idioma_actual][2 + i]
    
    if i == cursor_perfil then
      rectfill(12, ly - 3, 115, ly + 9, 4)
      print("-> " .. texto_opcion, 18, ly, 15)
    else
      print("   " .. texto_opcion, 18, ly, 5)
    end
  end
  print("(a): ok", 48, 112, 10)
end
-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.04]
-- PARTE 3 DE 4: MENÚ DE NOTAS Y MASCOTA CON EXPRESIONES
-- =========================================================

function actualizar_menu_principal_notas()
  local total_actual = #lista_notas
  local max_opciones = total_actual + 1
  
  if btn(4) or stat(30) == 13 then bloqueo_a = true else bloqueo_a = false end
  local b_oprimido = btn(5) or stat(30) == 14
  
  if not b_oprimido then
    if btnp(2) then cursor_menu = cursor_menu - 1 if cursor_menu < 0 then cursor_menu = max_opciones end end 
    if btnp(3) then cursor_menu = cursor_menu + 1 if cursor_menu > max_opciones then cursor_menu = 0 end end 
    
    -- [MOVIMIENTO HORIZONTAL EN LA FILA ZERO]
    if cursor_menu == 0 then
      if btnp(0) then columna_menu_cero = 1 end -- Izquierda: va a Idioma
      if btnp(1) then columna_menu_cero = 2 end -- Derecha: va a Herramientas
    end
    
    if not bloqueo_a then
      if cursor_menu == 0 then
        -- COLUMNA 1: Selector antiguo de pantalla completa de fábrica
        if columna_menu_cero == 1 and btnp(4) then
          cursor_idioma = idioma_actual
          cursor_perfil = perfil_sexo
          modo_actual = 0
          return
        end
        
        -- COLUMNA 2: Abre la nueva ventana flotante compacta adicional
        if columna_menu_cero == 2 and btnp(4) then
          config_abierta = true
          config_cursor = 1
          confirma_borrado = false 
          return
        end
        
      elseif btnp(4) and cursor_menu == 1 then
        if total_actual < total_notas_permitidas then
          texto_nota_buffer = ""
          cursor_texto_pos = 1
          modo_actual = 3 
          inicializar_teclado_config_segura()
        end
      elseif btnp(4) then
        nota_seleccionada_idx = cursor_menu - 1
        visor_scroll_y = 0
        modo_actual = 4 
      end
    end
  end

  local presiona_abajo = btn(3) or stat(30) == 6
  if b_oprimido and presiona_abajo and cursor_menu > 1 then
    if not bloqueo_borrar_combo then
      bloqueo_borrar_combo = true 
      local idx_a_borrar = cursor_menu - 1
      eliminar_nota_seleccionada(idx_a_borrar)
    end
  else
    bloqueo_borrar_combo = false 
  end
end


function render_pantalla_menu_notas(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  cls(c_fondo)
  
  rectfill(0, 0, 127, 11, c_display)
  line(0, 11, 127, 11, c_btn_txt)
  
  print("ADD NOTES XTREE V0.04", 4, 3, c_txt_dis)
  print(str_reloj, 94, 3, 5)

  local t_lang = textos_sistema[idioma_actual][6]  -- "notas creadas:"
  local t_crear = textos_sistema[idioma_actual][7] -- "crear nota?"
  local t_vacio = textos_sistema[idioma_actual][11] -- "vacio"
  local total_actual = #lista_notas
  
  print(t_lang .. " " .. total_actual .. "/" .. total_notas_permitidas, 6, 16, c_btn_txt)

  -- [REPARACIÓN CRÍTICA]: Separación visual real de columnas en la opción 0
  local tag_lang = "[" .. (codigos_idioma[idioma_actual] or "es") .. "]"
  
  if cursor_menu == 0 then
    if columna_menu_cero == 1 then
      -- Resalta ÚNICAMENTE el indicador de idioma
      rectfill(84, 14, 103, 22, c_btn_bse)
      print(tag_lang, 86, 16, c_btn_txt)
      rect(107, 14, 123, 22, c_btn_bse)
      print("[*]", 109, 16, c_btn_txt)
    else
      -- Resalta ÚNICAMENTE el icono de herramientas
      rect(84, 14, 103, 22, c_btn_bse)
      print(tag_lang, 86, 16, c_btn_txt)
      rectfill(107, 14, 123, 22, c_btn_bse)
      print("[*]", 109, 16, c_btn_txt)
    end
  else
    -- Comportamiento normal cuando no estás en la opción 0
    rect(84, 14, 103, 22, c_btn_bse)
    print(tag_lang, 86, 16, c_btn_txt)
    rect(107, 14, 123, 22, c_btn_bse)
    print("[*]", 109, 16, c_btn_txt)
  end
  
  rectfill(4, 25, 123, 108, c_display)
  rect(4, 25, 123, 108, c_btn_bse)
  
  if cursor_menu == 1 then
    rectfill(6, 27, 121, 37, c_btn_bse)
    print("-> [+] " .. t_crear, 10, 29, c_btn_txt)
  else
    print("   [+] " .. t_crear, 10, 29, c_txt_dis)
  end
  
  if total_actual == 0 then
    print("< " .. t_vacio .. " >", 40, 64, c_btn_bse)
  else
    for i=1, total_actual do
      local ly = 26 + (i * 11)
      local titulo_nota = sub(lista_notas[i], 1, 14) .. "..."
      
      if cursor_menu == (i + 1) then
        rectfill(6, ly - 1, 121, ly + 7, c_btn_bse)
        -- [ZOOM REPARADO]: Eliminamos upper() y aplicamos espaciado ancho nativo seguro (\x06)
        if config_zoom == 1 then
          print("\x06->" .. i .. "." .. sub(titulo_nota, 1, 8), 10, ly, c_btn_txt)
        else
          print("-> " .. i .. ". " .. titulo_nota, 10, ly, c_btn_txt)
        end
      else
        if config_zoom == 1 then
          print("\x06  " .. i .. "." .. sub(titulo_nota, 1, 8), 10, ly, c_txt_dis)
        else
          print("   " .. i .. ". " .. titulo_nota, 10, ly, c_txt_dis)
        end
      end
    end
  end
  
  rectfill(0, 112, 127, 127, 0)
  line(0, 112, 127, 112, 6)
  
  local col_nombre_tema = (c_fondo == 15 or c_fondo == 7) and 0 or 5
  print("t:" .. nombres_temas_notas[idx_tema], 4, 119, col_nombre_tema)
  print("b+down:" .. textos_sistema[idioma_actual][10], 76, 119, 6)

  if aviso_timer > 0 then
    local aw = #aviso_texto * 4 + 10
    local ax = 64 - flr(aw / 2)
    rectfill(ax, 56, ax + aw, 68, 0)
    rect(ax, 56, ax + aw, 68, 11)
    print(aviso_texto, ax + 5, 60, 7)
  end
  
  render_ranita_completa(59, 114)

  if config_abierta then
    render_ventana_opciones_adicionales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  end
end


function inicializar_teclado_config_segura()
  teclado_cx = 0 
  teclado_cy = 0
  teclado_max_cx = 6 
  teclado_max_cy = 6
  
  -- Bandera para saber qué página del teclado mostrar (false = letras, true = números)
  teclado_pag_simbolos = false
  
  -- Mapa de letras original
  teclado_mapa_letras = {
    "a","b","c","d","e","f",
    "g","h","i","j","k","l",
    "m","n","o","p","q","r",
    "s","t","u","v","w","x",
    "y","z",".",",","-","?",
    " ","<",">","del","ok","123"
  }
  
  -- Nueva capa con números y caracteres especiales sin alterar el tamaño de la cuadrícula
  teclado_mapa_simbolos = {
    "1","2","3","4","5","6",
    "7","8","9","0","+","-",
    "*","/","=","%","[","]",
    "(",")","{","}","@",":"
    ,"#","$","&","_",";","!",
    " ","<",">","del","ok","abc"
  }
  
  -- El mapa activo apunta inicialmente a las letras
  teclado_mapa = teclado_mapa_letras
end


function render_ranita_completa(x, y)
  local offset_y = flr(sin(ranita_anim / 60) * 1.5)
  local ry = y + offset_y
  local color_cuerpo = 11 
  local color_borde = 3   
  local color_boca = 8    
  
  -- Cuerpo base simétrico
  rectfill(x, ry + 2, x + 10, ry + 10, color_borde)
  rectfill(x + 1, ry + 3, x + 9, ry + 10, color_cuerpo)
  
  if estado_emocional == 1 then
    -- 1. NORMAL: Ojos completos perfectamente alineados
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, 0) 
    pset(x + 9, ry + 2, 0)
    rectfill(x + 3, ry + 7, x + 7, ry + 7, color_boca)

  elseif estado_emocional == 2 then
    -- 2. PENSATIVA / CURIOSA: Mirando hacia arriba
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 2, ry + 1, 0) 
    pset(x + 9, ry + 1, 0)
    pset(x + 5, ry + 7, color_boca)

  elseif estado_emocional == 3 then
    -- 3. SORPRENDIDA: Ojos abiertos y boca abierta
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 1, 0)
    pset(x + 9, ry + 1, 0)
    rectfill(x + 3, ry + 6, x + 7, ry + 8, color_borde)
    rectfill(x + 4, ry + 7, x + 6, ry + 8, 7)

  elseif estado_emocional == 4 then
    -- 4. SONRIENTE (CORREGIDA): Ambos ojos simétricos + sonrisa feliz
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, 0)
    pset(x + 9, ry + 2, 0)
    pset(x + 3, ry + 7, color_boca)
    rectfill(x + 4, ry + 8, x + 6, ry + 8, color_boca)
    pset(x + 7, ry + 7, color_boca)

  elseif estado_emocional == 5 then
    -- 5. ESTILO COOL (Lentes oscuros + sonrisa)
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x, ry + 1, x + 10, ry + 3, 0)
    pset(x + 1, ry + 1, 7)
    pset(x + 8, ry + 1, 7)
    pset(x + 3, ry + 7, color_boca)
    rectfill(x + 4, ry + 8, x + 6, ry + 8, color_boca)
    pset(x + 7, ry + 7, color_boca)

  elseif estado_emocional == 6 then
    -- 6. DORMIDA: Ojos cerrados y "z" animada
    rectfill(x, ry + 1, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry + 1, x + 10, ry + 2, color_borde)
    line(x, ry + 2, x + 2, ry + 2, 0)
    line(x + 8, ry + 2, x + 10, ry + 2, 0)
    pset(x + 5, ry + 7, color_boca)
    if ranita_anim < 30 then
      pset(x + 11, ry - 1, 7)
      pset(x + 12, ry - 1, 7)
      pset(x + 11, ry, 7)
      pset(x + 12, ry, 7)
    end

  else
    -- 7. ESTILO PRO / CORONA DORADA: Ojos simétricos + corona arriba
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, 0)
    pset(x + 9, ry + 2, 0)
    -- Corona dorada (color 10) centrada sobre la cabeza
    line(x + 3, ry + 1, x + 7, ry + 1, 10)
    pset(x + 3, ry, 10)
    pset(x + 5, ry - 1, 10)
    pset(x + 7, ry, 10)
    pset(x + 5, ry, 8)
    -- Sonrisa
    pset(x + 3, ry + 7, color_boca)
    rectfill(x + 4, ry + 8, x + 6, ry + 8, color_boca)
    pset(x + 7, ry + 7, color_boca)
  end
end


-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.04]
-- PARTE 4 DE 4: TECLADO, VISOR, ACERCA DE Y PERSISTENCIA
-- =========================================================

function actualizar_teclado_virtual()
  -- Movimiento seguro por la cuadrícula
  if btnp(0) then teclado_cx = (teclado_cx - 1) % teclado_max_cx end
  if btnp(1) then teclado_cx = (teclado_cx + 1) % teclado_max_cx end
  if btnp(2) then teclado_cy = (teclado_cy - 1) % teclado_max_cy end
  if btnp(3) then teclado_cy = (teclado_cy + 1) % teclado_max_cy end

  -- [CORTAFUEGOS]: El botón B (5 o 14) sirve exclusivamente para salir sin gatillar el botón A
  if btnp(5) or stat(30) == 14 then
    modo_actual = 2
    cursor_menu = 1
    bloqueo_a = false
    return
  end

  -- Cambio rápido de capa abc/123 con botones L1 o R1 del mando
  if btnp(4, 1) or btnp(5, 1) then
    if teclado_mapa == teclado_mapa_letras then
      teclado_mapa = teclado_mapa_simbolos
    else
      teclado_mapa = teclado_mapa_letras
    end
  end

  -- Selección estricta con el Botón A físico (Evita interferencias con el botón B)
  if (btn(4) or stat(30) == 13) and not (btn(5) or stat(30) == 14) then
    if not bloqueo_a then
      bloqueo_a = true 
      
      local idx = teclado_cy * teclado_max_cx + teclado_cx + 1
      local car = teclado_mapa[idx]
      
      if car == "123" then
        teclado_mapa = teclado_mapa_simbolos
      elseif car == "abc" then
        teclado_mapa = teclado_mapa_letras
      elseif car then
        procesar_caracter_seguro(car)
      end
    end
  else
    -- Solo libera el botón A si las teclas principales no están oprimidas
    if not btn(4) and stat(30) != 13 then
      bloqueo_a = false 
    end
  end
end


function procesar_caracter_seguro(car)
  texto_nota_buffer = texto_nota_buffer or ""

  if car == "ok" then
    if #texto_nota_buffer > 0 then
      pcall(function() cartdata("xtree_notes_pro") end)
      
      if nota_seleccionada_idx then
        lista_notas[nota_seleccionada_idx] = texto_nota_buffer
      else
        add(lista_notas, texto_nota_buffer, 1)
      end
      
      -- Llamamos al nuevo motor unificado de escritura física
      guardar_todo_en_sd()
      aviso_texto = textos_sistema[idioma_actual][13] .. "!"
      aviso_timer = 45
      estado_emocional = 7
      cronometro_emocion = 0
    end
    
    modo_actual = 2
    cursor_menu = 1
    nota_seleccionada_idx = nil
    bloqueo_a = true -- Evita el reingreso molesto
    return
    
  elseif car == "del" then
    if #texto_nota_buffer > 0 and cursor_texto_pos > 1 then
      local parte1 = sub(texto_nota_buffer, 1, cursor_texto_pos - 2)
      local parte2 = sub(texto_nota_buffer, cursor_texto_pos)
      texto_nota_buffer = parte1 .. parte2
      cursor_texto_pos = cursor_texto_pos - 1
    end
    return
    
  elseif car == "clr" then
    texto_nota_buffer = ""
    cursor_texto_pos = 1
    return
    
  elseif car == "<" then
    if cursor_texto_pos > 1 then cursor_texto_pos = cursor_texto_pos - 1 end
    return
    
  elseif car == ">" then
    if cursor_texto_pos <= #texto_nota_buffer then cursor_texto_pos = cursor_texto_pos + 1 end
    return
  end

  if #texto_nota_buffer < 120 then
    local parte1 = sub(texto_nota_buffer, 1, cursor_texto_pos - 1)
    local parte2 = sub(texto_nota_buffer, cursor_texto_pos)
    texto_nota_buffer = parte1 .. car .. parte2
    cursor_texto_pos = cursor_texto_pos + 1
  end
end

function render_pantalla_teclado_virtual(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  cls(c_fondo)
  
  rectfill(2, 2, 125, 24, c_display)
  rect(2, 2, 125, 24, c_btn_bse)
  
  local texto_imprimir = texto_nota_buffer or ""
  if ranita_anim % 30 < 15 then
    local p1 = sub(texto_imprimir, 1, cursor_texto_pos - 1)
    local p2 = sub(texto_imprimir, cursor_texto_pos)
    texto_imprimir = p1 .. "|" .. p2
  end
  
  if #texto_imprimir > 28 then
    texto_imprimir = sub(texto_imprimir, max(1, #texto_imprimir - 28))
  end
  print(texto_imprimir, 6, 6, c_txt_dis)
  print(#texto_nota_buffer .. "/120", 94, 16, c_btn_txt)

  local k_ancho = 16
  local k_alto = 10
  local k_espacio_x = 3
  local k_espacio_y = 2
  local k_inicio_x = 8
  local k_inicio_y = 30
  
  for cy = 0, 5 do
    for cx = 0, 5 do
      local idx = cy * 6 + cx + 1
      local tecla = teclado_mapa[idx] or ""
      local tx = k_inicio_x + cx * (k_ancho + k_espacio_x)
      local ty = k_inicio_y + cy * (k_alto + k_espacio_y)
      
      if cx == teclado_cx and cy == teclado_cy then
        rectfill(tx, ty, tx + k_ancho, ty + k_alto, c_btn_txt)
        print(tecla, tx + 2, ty + 2, c_btn_bse)
      else
        rectfill(tx, ty, tx + k_ancho, ty + k_alto, c_btn_bse)
        rect(tx, ty, tx + k_ancho, ty + k_alto, c_display)
        print(tecla, tx + 2, ty + 2, c_btn_txt)
      end
    end
  end
  
  -- [TRADUCCIÓN DINÁMICA]: Extraemos salir ("exit") y guardar ("save") de la matriz de idiomas
  local txt_salir = textos_sistema[idioma_actual][14]
  local txt_gdr = textos_sistema[idioma_actual][13]
  print("b: " .. txt_salir .. "  (a): ok / " .. txt_gdr, 6, 118, (c_fondo == 15 or c_fondo == 7) and 0 or 7)
end


function actualizar_visor_nota()
  if btnp(2) then visor_scroll_y = max(0, visor_scroll_y - 8) end 
  if btnp(3) then visor_scroll_y = visor_scroll_y + 8 end         

  if btnp(5) then
    modo_actual = 2
    nota_seleccionada_idx = nil
    return
  end

  if btnp(4) then
    texto_nota_buffer = lista_notas[nota_seleccionada_idx] or ""
    cursor_texto_pos = #texto_nota_buffer + 1
    modo_actual = 3 
    inicializar_teclado_config_segura()
  end
end

function render_pantalla_visor_nota(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  cls(c_fondo)
  
  local texto_completo = lista_notas[nota_seleccionada_idx] or ""
  
  rectfill(0, 0, 127, 13, c_display)
  line(0, 13, 127, 13, c_btn_txt)
  print(textos_sistema[idioma_actual][8] .. " #" .. nota_seleccionada_idx, 4, 4, c_txt_dis)
  print(#texto_completo .. "/120", 96, 4, c_btn_txt)
  
  rectfill(4, 18, 123, 102, c_display)
  rect(4, 18, 123, 102, c_btn_bse)
  
  clip(6, 20, 112, 80)
  
  local renglon = 0
  for i = 1, #texto_completo, 24 do
    local fragmento = sub(texto_completo, i, i + 23)
    local ly = 22 + (renglon * 10) - visor_scroll_y
    if ly >= 10 and ly <= 110 then
      print(fragmento, 8, ly, c_txt_dis)
    end
    renglon = renglon + 1
  end
  clip() 
  
  -- Barra de desplazamiento (scrollbar) discreta en el borde derecho
  local max_scroll = max(0, (renglon * 10) - 76)
  if visor_scroll_y > max_scroll then visor_scroll_y = max_scroll end
  if max_scroll > 0 then
    line(120, 21, 120, 99, c_fondo)
    local bar_h = max(10, flr(78 * (78 / (renglon * 10))))
    local bar_y = 21 + flr((visor_scroll_y / max_scroll) * (78 - bar_h))
    rectfill(119, bar_y, 121, bar_y + bar_h, c_btn_bse)
  end
  
  rectfill(0, 106, 127, 127, 0)
  line(0, 106, 127, 106, 6)
  print("\x8b\x91:scroll  (a):" .. textos_sistema[idioma_actual][9], 4, 110, 7)
  print("(b):" .. textos_sistema[idioma_actual][14], 4, 118, 5)
  render_ranita_completa(ranita_x, ranita_y)
end


function render_pantalla_acercade()
  cls(0)
  rect(2, 2, 125, 125, 7)
  
  -- 1. ETIQUETAS TRADUCIDAS DINÁMICAMENTE POR MATRIZ
  local t_tit = textos_sistema[idioma_actual][15] -- "acerca de" / "about"
  local t_ver = "version:"
  local t_dev = "dev:"
  local t_ia  = "colab:"
  local t_mot = "motor:"
  local t_nuc = "core:"
  local t_sys = "sistema:"
  local t_est = "status: compatible"
  local t_atj = "--- atajos ---"
  local t_at1 = "b + up: info"
  local t_at2 = "b + down: borrar nota"
  local t_at3 = "b + left: creditos"
  local t_at4 = "b + right: tema visual"
  local t_at5 = "l1: alternar abc/123"
  local t_fin = "--- gracias por usar ---"
  
  if idioma_actual == 1 then -- Español
    t_ver = "version:" t_dev = "desarrollador:" t_ia = "ia colab:" t_mot = "motor:" t_nuc = "nucleo:" t_sys = "sistema:" t_est = "estado: compatible" t_atj = "--- atajos ---" t_at1 = "b + up: info" t_at2 = "b + abajo: borrar nota" t_at3 = "b + izq: creditos" t_at4 = "b + der: tema visual" t_at5 = "l1: alternar abc/123" t_fin = "--- gracias por usar ---"
  elseif idioma_actual == 2 then -- English
    t_ver = "version:" t_dev = "developer:" t_ia = "ai colab:" t_mot = "engine:" t_nuc = "core:" t_sys = "system:" t_est = "status: compatible" t_atj = "--- shortcuts ---" t_at1 = "b + up: info" t_at2 = "b + down: delete note" t_at3 = "b + left: credits" t_at4 = "b + right: change theme" t_at5 = "l1: toggle abc/123" t_fin = "--- thanks for using ---"
  elseif idioma_actual == 3 then -- Polski
    t_ver = "wersja:" t_dev = "programista:" t_ia = "wspolpraca ia:" t_mot = "silnik:" t_nuc = "rdzen:" t_sys = "system:" t_est = "status: zgodny" t_atj = "--- skroty ---" t_at1 = "b + gora: info" t_at2 = "b + dol: usun notatke" t_at3 = "b + lewo: napisy" t_at4 = "b + prawo: zmien motyw" t_at5 = "l1: przelacz abc/123" t_fin = "--- dziekujemy ---"
  elseif idioma_actual == 4 then -- Russian
    t_ver = "versiya:" t_dev = "razrabotchik:" t_ia = "ii pomoshch:" t_mot = "dvizhok:" t_nuc = "yadro:" t_sys = "sistema:" t_est = "status: sovmestim" t_atj = "--- knopki ---" t_at1 = "b + vverh: info" t_at2 = "b + vniz: udalit" t_at3 = "b + levo: titry" t_at4 = "b + pravo: smena temy" t_at5 = "l1: pereklyuchit abc/123" t_fin = "--- spasibo vam ---"
  elseif idioma_actual == 5 then -- Português
    t_ver = "versao:" t_dev = "desenvolvedor:" t_ia = "ia colab:" t_mot = "motor:" t_nuc = "nucleo:" t_sys = "sistema:" t_est = "estado: compativel" t_atj = "--- atalhos ---" t_at1 = "b + up: info" t_at2 = "b + baixo: apagar nota" t_at3 = "b + esq: creditos" t_at4 = "b + dir: mudar tema" t_at5 = "l1: alternar abc/123" t_fin = "--- obrigado por usar ---"
  elseif idioma_actual == 6 then -- Italiano
    t_ver = "versione:" t_dev = "sviluppatore:" t_ia = "ia colab:" t_mot = "motore:" t_nuc = "core:" t_sys = "sistema:" t_est = "stato: compatibile" t_atj = "--- scorciatoie ---" t_at1 = "b + su: info" t_at2 = "b + giu: elimina nota" t_at3 = "b + sin: crediti" t_at4 = "b + des: cambia tema" t_at5 = "l1: alterna abc/123" t_fin = "--- grazie per l'uso ---"
  elseif idioma_actual == 7 then -- Français
    t_ver = "version:" t_dev = "developpeur:" t_ia = "ia colab:" t_mot = "moteur:" t_nuc = "noyau:" t_sys = "systeme:" t_est = "statut: compatible" t_atj = "--- raccourcis ---" t_at1 = "b + haut: info" t_at2 = "b + bas: effacer note" t_at3 = "b + gauche: credits" t_at4 = "b + droite: changer theme" t_at5 = "l1: basculer abc/123" t_fin = "--- merci d'utiliser ---"
  elseif idioma_actual == 8 then -- Nihongo (Romaji)
    t_ver = "baajon:" t_dev = "kaihatsusha:" t_ia = "ai kyouryoku:" t_mot = "enjin:" t_nuc = "koa:" t_sys = "shisutemu:" t_est = "joutai: taiou" t_atj = "--- shoutokatto ---" t_at1 = "b + ue: jouhou" t_at2 = "b + shita: sakujo" t_at3 = "b + hidari: kurejitto" t_at4 = "b + migi: teema henkou" t_at5 = "l1: abc/123 kirikae" t_fin = "--- arigatou gozaimasu ---"
  elseif idioma_actual == 9 then -- Zhongwen (Pinyin)
    t_ver = "banben:" t_dev = "kaifazhe:" t_ia = "ai xiezuo:" t_mot = "yinqing:" t_nuc = "hexin:" t_sys = "xitong:" t_est = "zhuangtai: jianrong" t_atj = "--- kuaijiejian ---" t_at1 = "b + shang: xinxi" t_at2 = "b + xia: shanchu" t_at3 = "b + zuo: mingdan" t_at4 = "b + you: huan zhuti" t_at5 = "l1: qiehuan abc/123" t_fin = "--- ganxie shiyong ---"
  elseif idioma_actual == 10 then -- Hangugeo (Coreano)
    t_ver = "beojeon:" t_dev = "gaebalja:" t_ia = "ai hyeobeop:" t_mot = "enjin:" t_nuc = "koeo:" t_sys = "siseutem:" t_est = "sangtae: hohwan" t_atj = "--- danchukki ---" t_at1 = "b + wi: jeongbo" t_at2 = "b + arae: sakje" t_at3 = "b + oenjjok: keuredit" t_at4 = "b + oreunjjok: tema" t_at5 = "l1: abc/123 jeonhwan" t_fin = "--- gamsahamnida ---"
  elseif idioma_actual == 11 then -- Turkce (Turco)
    t_ver = "surum:" t_dev = "gelistirici:" t_ia = "yz isbirligi:" t_mot = "motor:" t_nuc = "cekirdek:" t_sys = "sistem:" t_est = "durum: uyumlu" t_atj = "--- kisayollar ---" t_at1 = "b + ust: bilgi" t_at2 = "b + alt: notu sil" t_at3 = "b + sol: emegi gecenler" t_at4 = "b + sag: tema degistir" t_at5 = "l1: abc/123 gecis" t_fin = "--- tesekkurler ---"
  end

  -- Matriz lineal con los créditos extendidos ordenados secuencialmente
  local lineas_creditos = {
    "--- " .. t_tit .. " ---",
    "",
    "app: add notes xtree",
    t_ver .. " v0.04",
    t_dev .. " martstartiv",
    t_ia .. " collaborative ai",
    "",
    t_mot .. " pico-8 (libretro)",
    t_nuc .. " picante8 v-safe",
    t_sys .. " r36hd treefroui",
    t_est,
    "",
    t_atj,
    t_at1,
    t_at2,
    t_at3,
    t_at4,
    t_at5,
    "",
    t_fin
  }

  -- 2. VENTANA GRÁFICA DE RECORTE (Clip para ocultar texto fuera del marco)
  clip(4, 4, 120, 120)
  
  for idx = 1, #lineas_creditos do
    local linea = lineas_creditos[idx]
    -- Separación vertical de 11 píxeles por línea de texto
    local ly = flr(creditos_y + (idx - 1) * 11)
    
    -- Sólo dibuja si está visible en la pantalla para ahorrar ciclos de CPU MIPS
    if ly >= -8 and ly <= 130 then
      local col_txt = 7 -- Blanco por defecto
      if idx == 1 or idx == 13 or idx == 20 then col_txt = 10 -- Verde/Resaltado para títulos
      elseif idx == 5 or idx == 6 then col_txt = 11 -- Color especial para creadores
      elseif idx >= 14 and idx <= 18 then col_txt = 6 -- Color para la sección de atajos
      end
      
      -- Centrado horizontal matemático exacto por texto
      local lx = 64 - (#linea * 4) / 2
      print(linea, lx, ly, col_txt)
    end
  end
  clip() -- Libera el canvas de dibujo

  -- 3. MOTOR DE AVANCE BASADO EN COORDENADAS DE FOTOGRAMAS
  creditos_y = creditos_y - creditos_velocidad
  
  -- Cálculo de altura total: (número de líneas * 11 píxeles) de desplazamiento
  creditos_max_scroll = -(#lineas_creditos * 11)

  -- 4. ESCUDO DE CONTROL SEPARADO PARA EVITAR CIERRES AUTOMÁTICOS
  if bloqueo_acercade then
    -- Obliga al hardware a detectar que soltaste el D-Pad izquierdo antes de escuchar la salida
    if not btnp(0) and not btn(0) then 
      bloqueo_acercade = false 
    end
  else
    -- Si el texto termina de subir por completo, regresa automáticamente al menú
    if creditos_y < creditos_max_scroll then
      modo_actual = modo_previo_acercade or 2
    end
    
    -- Un solo clic limpio en A o B (virtual o keymap físico de TreeFrogUI) cierra la pantalla voluntariamente
    if btnp(4) or btnp(5) or stat(30) == 13 or stat(30) == 14 then
      modo_actual = modo_previo_acercade or 2
    end
  end

  -- Dibujamos la ranita animada fija abajo a la derecha acompañando los créditos
  render_ranita_completa(112, 112)
end

function eliminar_nota_seleccionada(idx)
  if idx >= 1 and idx <= #lista_notas then
    -- 1. Elimina la nota de la memoria RAM de PICO-8
    del(lista_notas, lista_notas[idx])
    
    -- 2. Forzamos el enlace con el archivo físico
    pcall(function() cartdata("xtree_notes_pro") end)
    
    -- 3. Volcamos la lista actualizada de forma limpia a la SD
    guardar_todo_en_sd()
    aviso_texto = textos_sistema[idioma_actual][10] .. "!"
    aviso_timer = 45
    estado_emocional = 3
    cronometro_emocion = 0
    
    -- 4. Reseteamos los cursores de forma segura para evitar desbordamientos visuales
    cursor_menu = 1
  end
end

-- [NUEVA FUNCIÓN CRÍTICA]: Motor único de serialización por bloques para TreeFrogUI
function guardar_todo_en_sd()
  pcall(function()
    -- 1. Guardamos configuraciones básicas nativas de fábrica
    dset(0, idioma_actual)
    dset(1, perfil_sexo)
    dset(2, idx_tema)
    dset(3, #lista_notas) -- El Slot 3 vuelve a ser exclusivamente el total de notas como antes
    
    -- 2. Guardamos las nuevas configuraciones en el Slot 4 de forma aislada
    local empaquetado_config = config_zoom + (config_motivacion * 10)
    dset(4, empaquetado_config)
    
    -- 3. Tu motor original exacto de volcado de caracteres por bloques a la SD
    for i = 1, total_notas_permitidas do
      local slot_base = 10 + (i - 1) * 130
      
      if i <= #lista_notas then
        local nota_str = lista_notas[i]
        dset(slot_base, #nota_str)
        
        for c = 1, #nota_str do
          local letra = sub(nota_str, c, c)
          local id_char = 1 -- Espacio por defecto si falla
          
          for k = 1, #comp_dict do
            if comp_dict[k] == letra then 
              id_char = k 
              break 
            end
          end
          dset(slot_base + c, id_char)
        end
      else
        -- Borramos el sector sobrante en la SD tal cual como lo programaste
        dset(slot_base, 0)
      end
    end
  end)
end

function cargar_configuracion_inicial()
  local lang, sex, tema = 0, 0, 0
  
  pcall(function()
    lang = dget(0) or 0
    sex = dget(1) or 0
    tema = dget(2) or 0
  end)
  
  if lang >= 1 and lang <= 11 then
    idioma_actual = lang
    perfil_sexo = (sex >= 1 and sex <= 3) and sex or 3
    idx_tema = (tema >= 1 and tema <= 7) and tema or 1
    
    lista_notas = {}
    -- Recuperamos el total de notas real de tu Slot 3 original
    local total_g = dget(3) or 0
    if total_g < 0 or total_g > total_notas_permitidas then total_g = 0 end
    
    -- Recuperamos las opciones adicionales del Slot 4 sin interferir con las notas
    local empaquetado_config = dget(4) or 0
    config_zoom = empaquetado_config % 10
    config_motivacion = flr(empaquetado_config / 10)
    
    -- Escudos protectores por rango
    if config_zoom < 0 or config_zoom > 1 then config_zoom = 0 end
    if config_motivacion < 0 or config_motivacion > 1 then config_motivacion = 0 end
    
    -- [RECONSTRUCCIÓN REAL COMPATIBLE FIJA]: Recupera tus strings tal cual como antes
    for i = 1, total_g do
      local slot_base = 10 + (i - 1) * 130
      local longitud_texto = dget(slot_base) or 0
      
      if longitud_texto < 0 or longitud_texto > 120 then longitud_texto = 0 end
      
      local texto_reconstruido = ""
      for c = 1, longitud_texto do
        local id_char = dget(slot_base + c) or 1
        if id_char >= 1 and id_char <= #comp_dict then
          texto_reconstruido = texto_reconstruido .. comp_dict[id_char]
        else
          texto_reconstruido = texto_reconstruido .. " "
        end
      end
      
      -- Inserta el texto real completo del usuario en la memoria RAM
      add(lista_notas, texto_reconstructed or texto_reconstruido)
    end
    
    modo_actual = 2 
  else
    modo_actual = 0 
  end
end


function actualizar_opciones_adicionales()
  if btnp(2) then config_cursor = config_cursor - 1 if config_cursor < 1 then config_cursor = 4 end end
  if btnp(3) then config_cursor = config_cursor + 1 if config_cursor > 4 then config_cursor = 1 end end

  if btnp(5) or stat(30) == 14 then
    config_abierta = false
    guardar_todo_en_sd()
    return
  end

  if config_cursor == 1 then
    if btnp(0) or btnp(1) then config_zoom = (config_zoom == 0) and 1 or 0 end
    
  elseif config_cursor == 2 then
    if btnp(0) then idioma_actual = idioma_actual - 1 if idioma_actual < 1 then idioma_actual = 11 end end
    if btnp(1) then idioma_actual = idioma_actual + 1 if idioma_actual > 11 then idioma_actual = 1 end end
    
  elseif config_cursor == 3 then
    if btnp(0) or btnp(1) then
      config_motivacion = (config_motivacion == 0) and 1 or 0
      -- [CORRECCIÓN CRÍTICA]: Enlace correcto al cronómetro real del sistema de expresiones
      if config_motivacion == 1 then estado_emocional = 4 cronometro_emocion = 0 end 
    end
    
  elseif config_cursor == 4 then
    if btnp(0) or btnp(1) then confirma_borrado = not confirma_borrado end
    
    if (btnp(4) or stat(30) == 13) and confirma_borrado then
      pcall(function()
        cartdata("xtree_notes_pro")
        for slot = 0, 1500 do dset(slot, 0) end 
      end)
      lista_notas = {}
      idioma_actual = 1
      perfil_sexo = 3
      idx_tema = 1
      config_zoom = 0
      config_motivacion = 0
      config_abierta = false
      modo_actual = 0 
      return
    end
  end
end

function render_ventana_opciones_adicionales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  local t_config = {
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacion", "formatear", "si", "no", "b: salir/grv"},
    {"extra cfgs",   "text zoom",  "lang/idioma", "motivation", "wipe clear", "yes","no", "b: exit/save"},
    {"cfg. dodatk",  "zoom tekstu", "jezyk/lang", "motywacja",  "czyszczenie", "tak","nie","b: wyjdz/zap"},
    {"dop. nastr",   "masshtab",   "yazik/lang",  "motivaciya", "ochistka",   "da", "net","b: vyhod/shran"},
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacao",  "formatar",   "sim","nao","b: sair/salv"},
    {"cfg. extra",   "zoom testo", "lingua/lang", "motivazione","formatta",   "si", "no", "b: esci/salv"},
    {"cfg. extras",  "zoom texte", "langue/lang", "motivation", "effacer to", "oui","non","b: sortir/grd"},
    {"sono hoka",    "moji zoom",  "gengo/lang",  "douki zuke", "shokika",    "hai","iie","b: modoru/hoz"},
    {"geng duo she", "zi ti da xiao","yu yan/lang","ji li",       "qing chu",   "shi","fou","b: tui chu/bao"},
    {"gita seolt",   "geulja zoom","eoneo/lang",  "donggi buyeo","gongjang ch","ye", "ani","b: nagagi/jeo"},
    {"ek ayarlar",   "metin zoomu", "dil/lang",    "motivasyon", "sifirla",    "evet","hayir","b: cikis/kayd"}
  }

  local m_data = t_config[idioma_actual]
  local vx, vy, vw, vh = 12, 18, 104, 92
  
  rectfill(vx, vy, vx + vw, vy + vh, 0)         
  rect(vx, vy, vx + vw, vy + vh, c_btn_bse)     
  rectfill(vx + 2, vy + 2, vx + vw - 2, vy + 12, c_display) 
  print(m_data[1], vx + 6, vy + 4, c_txt_dis)   
  
  -- Fila 1: Zoom de letra
  local ly1 = vy + 18
  if config_cursor == 1 then rectfill(vx + 4, ly1 - 2, vx + vw - 4, ly1 + 6, c_btn_bse) end
  print(m_data[2] .. ":", vx + 6, ly1, config_cursor == 1 and c_btn_txt or c_txt_dis)
  print(config_zoom == 1 and "on" or "off", vx + 80, ly1, config_zoom == 1 and 10 or 8)
  
  -- Fila 2: Idioma rápido
  local ly2 = vy + 34
  if config_cursor == 2 then rectfill(vx + 4, ly2 - 2, vx + vw - 4, ly2 + 6, c_btn_bse) end
  print(m_data[3] .. ":", vx + 6, ly2, config_cursor == 2 and c_btn_txt or c_txt_dis)
  print("<" .. codigos_idioma[idioma_actual] .. ">", vx + 74, ly2, 11)
  
  -- Fila 3: Motivación
  local ly3 = vy + 50
  if config_cursor == 3 then rectfill(vx + 4, ly3 - 2, vx + vw - 4, ly3 + 6, c_btn_bse) end
  print(m_data[4] .. ":", vx + 6, ly3, config_cursor == 3 and c_btn_txt or c_txt_dis)
  print(config_motivacion == 1 and "on" or "off", vx + 80, ly3, config_motivacion == 1 and 10 or 8)
  
  -- Fila 4: Formateo de Fábrica
  local ly4 = vy + 66
  if config_cursor == 4 then rectfill(vx + 4, ly4 - 2, vx + vw - 4, ly4 + 6, c_btn_bse) end
  print(m_data[5], vx + 6, ly4, config_cursor == 4 and c_btn_txt or 8)
  
  if confirma_borrado then
    rectfill(vx + 76, ly4 - 1, vx + 98, ly4 + 5, 8) 
    print(m_data[6], vx + 78, ly4, 7)
  else
    rectfill(vx + 76, ly4 - 1, vx + 98, ly4 + 5, 12) 
    print(m_data[7], vx + 78, ly4, 7)
  end
  
  print(m_data[8], vx + 14, vy + 82, 6)
end
