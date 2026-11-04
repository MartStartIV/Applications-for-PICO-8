pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 1: CORE DE INICIALIZACIÓN Y CONFIGURACIÓN DE GRIDS
-- =========================================================

function _init()
  -- Información del Sistema
  id_nombre = "XTREE FORCE"
  id_version = "V0.04"
  
  -- Modos de Ejecución (0: Estándar, 1: Científico, 2: Acerca de, 3: Historial)
  modo_actual = 0 
  
  -- Gestión de Valores y Registros (Memoria Operacional)
  v_pantalla = "0"     
  v_historial = ""    
  memoria = 0         
  
  -- Variables de control de flujo matemático
  n1 = 0 n2 = 0 op = ""
  limpiar_pantalla = false
  tiene_punto = false
  bloqueo_a = false       -- Antirrepetidor para el botón A
  bloqueo_b = false       -- Seguro de frame inicial para evitar ráfagas del botón B
  delay_historial = 0     
  
  -- Cadena de texto para el reloj limpio
  str_reloj = "00:00:00"
  
  -- SISTEMA DE TEMAS DE COLOR MODERNOS (10 Temas)
  temas = {
    {1, 0, 11, 2, 7},   -- 1: Neon Midnight
    {0, 5, 14, 1, 7},   -- 2: Cyber Punk
    {4, 15, 0, 13, 7},  -- 3: Chocolate Mint
    {13, 1, 10, 12, 7}, -- 4: Forest Mist
    {15, 7, 2, 14, 0},  -- 5: Light Mode Retro
    {0, 1, 8, 2, 7},    -- 6: Blood Vapor
    {5, 0, 9, 1, 10},   -- 7: Toxic Waste
    {0, 2, 12, 4, 7},   -- 8: Deep Ocean
    {15, 14, 8, 9, 7},  -- 9: Sunset Peach
    {0, 4, 10, 5, 7}    -- 10: Matrix Terminal
  }
  idx_tema = 1
  
  -- SISTEMA DE PERSISTENCIA EXTENDIDO
  cartdata("xtree_force_calc")
  
  -- Carga del Tema Seguro
  local tema_guardado = dget(0)
  if tema_guardado and tema_guardado >= 1 and tema_guardado <= #temas then
    idx_tema = tema_guardado
  end
  
  -- Carga de Estadísticas de la Ranita y Estructura del Historial
  ops_totales = dget(1) or 0 
  hist_total = dget(2) or 0  
  hist_lista = {}            
  hist_idx = 1               
  
  -- Validación estricta para evitar bucles corruptos en el arranque
  if hist_total == nil or hist_total < 0 or hist_total > 5 then
    hist_total = 0
    dset(2, 0)
  end
  
  -- Reconstruir historial guardado en la RAM de manera segura
  if hist_total > 0 then
    for i=1, hist_total do
      local val_ram = dget(9 + i)
      if val_ram and val_ram != 0 then
        local s_val = tostr(val_ram)
        if #s_val > 10 then s_val = sub(s_val, 1, 10) end
        add(hist_lista, s_val)
      end
    end
    hist_total = #hist_lista
    dset(2, hist_total)
  end
  
  -- ESTRUCTURA DEL TECLADO DINÁMICO (Grid Adaptativo 4x5 Pulido)
  pad_estandar = {
    {"C",2},   {"DEL",2}, {"M+",2},  {"/",1},
    {"7",0},   {"8",0},   {"9",0},   {"*",1},
    {"4",0},   {"5",0},   {"6",0},   {"-",1},
    {"1",0},   {"2",0},   {"3",0},   {"+",1},
    {"+/-",2}, {"0",0},   {".",2},   {"=",2}
  }
  
  pad_cientifico = {
    {"SIN",3},  {"COS",3},  {"TAN",3},  {"^",3},    
    {"ASN",3},  {"ACS",3},  {"ATN",3},  {"SQRT",3}, 
    {"LN",3},   {"LOG",3},  {"EXP",3},  {"ABS",3},
    {"PI",0},   {"E",0},    {"MOD",3},  {"1/X",3},  
    {"PI2",3},  {"RND",3},  {"FACT",3}, {"RET",2}   
  }
  
  -- Coordenadas del Cursor de las Botoneras
  cx = 0 cy = 0
  max_cx = 4 max_cy = 5 
  
  -- Mascota Oficial (Ranita Xtree)
  ranita_x = 114 ranita_y = 114 ranita_anim = 0 
  
  -- CONFIGURACIÓN DEL SCROLL "ACERCA DE"
  textos_acercade = {
    "calculator xtree force",
    "version: "..id_version,
    "------------------------",
    "developer:",
    "MARTSTARTIV",
    "in conjunction with:",
    "artificial intelligence",
    "------------------------",
    "about the application:",
    "mathematical console of",
    "high-precision bignum",
    "designed to break the",
    "native limitations",
    "PICO-8 graphics.",
    "------------------------",
    "pro features:",
    "- multilevel bignum (+-*/)",
    "- advanced algebra (^, mod)",
    "- native trigonometry",
    "- 5 cyberpunk themes",
    "- bignum logs y exp",
    "------------------------",
    "button shortcuts:",
    "b + arriba : mode sci",
    "b + der    : change of the themes",
    "b + izq    : about",
    "b + abajo  : history",
    "a + der    : clear total",
    "------------------------",
    "thanks for using",
    "xtree force software!"
  }
  
  -- Variables de posición del Scroll
  scroll_y_inicio = 120 
  scroll_y = scroll_y_inicio
  scroll_velocidad = 0.4 
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 2: LÓGICA DE ACTUALIZACIÓN, COMBOS Y REFRESH DE HORA
-- =========================================================

function _update60()
  ranita_anim = (ranita_anim + 1) % 60
  
  if delay_historial > 0 then delay_historial = delay_historial - 1 end
  
  -- LECTURA HORARIA EXTRAÍDA DE LA APP DE UTILERÍA
  local hrs = stat(93) or 0
  local mnts = stat(94) or 0
  local segs = stat(95) or 0
  
  local sh = tostr(hrs) if #sh < 2 then sh = "0"..sh end
  local sm = tostr(mnts) if #sm < 2 then sm = "0"..sm end
  local ss = tostr(segs) if #ss < 2 then ss = "0"..ss end
  str_reloj = sh..":"..sm..":"..ss
  
  -- COMBO 1: B (5) + FLECHA ARRIBA (2) -> Alternar modo Científico / Estándar
  if btn(5) and btnp(2) then
    if modo_actual != 2 and modo_actual != 3 then
      modo_actual = (modo_actual == 0) and 1 or 0
      cx = 0 cy = 0 limpiar_pantalla = true
      sfx(0)
    end
    return
  end

  -- COMBO 2: B (5) + FLECHA DERECHA (1) -> Cambiar Tema de Color y Auto-guardar
  if btn(5) and btnp(1) then
    if modo_actual != 2 and modo_actual != 3 then
      idx_tema = idx_tema + 1
      if idx_tema > #temas then idx_tema = 1 end
      dset(0, idx_tema)
      sfx(1)
    end
    return
  end

  -- COMBO 3: A (4) + FLECHA DERECHA (1) -> Clear All Rápido
  if btn(4) and btnp(1) and not btn(5) then
    if modo_actual != 2 and modo_actual != 3 then
      v_pantalla = "0" v_historial = "" n1 = 0 n2 = 0 op = ""
      tiene_punto = false limpiar_pantalla = false
      sfx(2)
    end
    return
  end

  -- COMBO 4: B (5) + FLECHA IZQUIERDA (0) -> Activar/Desactivar Acerca De con Scroll
  if btn(5) and btnp(0) then
    if modo_actual != 3 then
      if modo_actual != 2 then
        modo_actual = 2
        scroll_y = scroll_y_inicio 
      else
        modo_actual = 0
      end
      sfx(0)
    end
    return
  end

  -- COMBO 5: B (5) + FLECHA ABAJO (3) -> Abrir Gestor de Historial (Activa bloqueo temporal de B)
  if btn(5) and btnp(3) then
    if modo_actual == 0 or modo_actual == 1 then
      modo_actual = 3
      hist_idx = 1
      bloqueo_b = true -- Fuerza al sistema a esperar que sueltes B antes de procesar cancelaciones
      delay_historial = 10
      sfx(0)
    end
    return
  end

  -- CONTROL DEL MODO ACERCA DE (SCROLL AUTOMÁTICO)
  if modo_actual == 2 then
    scroll_y = scroll_y - scroll_velocidad
    local limite_final = 10 - (#textos_acercade * 9)
    if scroll_y < limite_final then modo_actual = 0 sfx(1) end
    if btnp(4) then modo_actual = 0 sfx(1) end
    return 
  end

  -- GESTIÓN DE ACTUALIZACIÓN DE LA INTERFAZ DE HISTORIAL
  if modo_actual == 3 then
    actualizar_interfaz_historial()
    return
  end

  -- NAVEGACIÓN ESTÁNDAR POR LAS TECLAS MATEMÁTICAS
  if btnp(0) then cx = (cx - 1) % max_cx end 
  if btnp(1) then cx = (cx + 1) % max_cx end 
  if btnp(2) then cy = (cy - 1) % max_cy end 
  if btnp(3) then cy = (cy + 1) % max_cy end 
  
  -- SELECCIÓN CON BOTÓN A (4) - CONTROL DE PRESIÓN ÚNICA ESTRICTA
  if btn(4) then
    if not bloqueo_a and not btn(5) then
      bloqueo_a = true 
      local idx = cy * max_cx + cx + 1
      if modo_actual == 0 then
        if pad_estandar[idx] then procesar_entrada(pad_estandar[idx]) end
      elseif modo_actual == 1 then
        if pad_cientifico[idx] then procesar_entrada(pad_cientifico[idx]) end
      end
    end
  else
    bloqueo_a = false 
  end
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 3: LÓGICA DE NAVEGACIÓN Y PROCESAMIENTO DEL HISTORIAL
-- =========================================================

function actualizar_interfaz_historial()
  -- Liberar el cerrojo del botón B únicamente cuando el usuario suelta el botón físicamente
  if bloqueo_b then
    if not btn(5) then bloqueo_b = false end
    return -- Omite lecturas este frame para proteger la interfaz
  end

  -- SALIDA CONFIGURADA CON BOTÓN B (5) SOLO: Regresa a la calculadora de forma segura
  if btnp(5) and not btn(1) then
    modo_actual = 0
    sfx(0)
    return
  end

  -- Navegación Vertical entre los elementos
  if #hist_lista > 0 then
    if btnp(2) then -- Flecha Arriba
      hist_idx = hist_idx - 1
      if hist_idx < 1 then hist_idx = #hist_lista end
      sfx(3)
      return
    end
    if btnp(3) then -- Flecha Abajo
      hist_idx = hist_idx + 1
      if hist_idx > #hist_lista then hist_idx = 1 end
      sfx(3)
      return
    end

    -- CARGA DE DATOS COMPLETA REPARADA: Ejecución directa con Botón A (4) solo
    if btnp(4) and not btn(5) then
      v_pantalla = hist_lista[hist_idx]
      
      -- Escaneo estricto de punto decimal para evitar bugs operacionales
      tiene_punto = false
      for i=1, #v_pantalla do
        if sub(v_pantalla, i, i) == "." then tiene_punto = true end
      end
      
      limpiar_pantalla = false
      modo_actual = 0 -- Inyecta el valor completo y reactiva la botonera
      sfx(2)
      return
    end
  end

  -- COMBO DE BORRADO SEGURO BASADO EN B: MANTENER B (5) + PULSAR FLECHA DERECHA (1)
  if btn(5) and btnp(1) then
    hist_lista = {}
    hist_total = 0
    dset(2, 0) 
    for i=1, 5 do dset(9 + i, 0) end 
    hist_idx = 1
    bloqueo_b = true -- Evita salir de golpe al soltar el borrado
    sfx(2)
    return
  end
end

function registrar_en_historial(str_resultado)
  local n_val = tonum(str_resultado) or 0
  extrude_historial(str_resultado, n_val)
  ops_totales = ops_totales + 1
  dset(1, ops_totales) 
end

function extrude_historial(s_val, n_val)
  add(hist_lista, s_val, 1)
  if #hist_lista > 5 then
    del(hist_lista, hist_lista[#hist_lista])
  end
  hist_total = #hist_lista
  dset(2, hist_total)
  for i=1, hist_total do
    dset(9 + i, tonum(hist_lista[i]) or 0)
  end
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 4: MOTOR GRÁFICO AISLADO Y MÓDULO RENDER
-- =========================================================

function _draw()
  clip()
  
  local c_fondo   = temas[idx_tema][1]
  local c_display = temas[idx_tema][2]
  local c_txt_dis = temas[idx_tema][3]
  local c_btn_bse = temas[idx_tema][4]
  local c_btn_txt = temas[idx_tema][5]
  
  -- AISLAMIENTO TOTAL 1: Modo Acerca de
  if modo_actual == 2 then
    cls(0) rect(0, 0, 127, 127, 7) clip(4, 12, 120, 96)
    for idx, linea in ipairs(textos_acercade) do
      local linea_y = flr(scroll_y + (idx - 1) * 9)
      if linea_y >= 0 and linea_y <= 120 then
        local col_linea = 7
        if sub(linea, 1, 1) == "-" then col_linea = 5
        elseif idx == 1 or idx == 4 or idx == 6 or idx == 9 or idx == 16 or idx == 23 then col_linea = 10
        elseif idx == 5 or idx == 7 then col_linea = 11
        end
        local lx = 64 - (#linea * 4) / 2
        print(linea, lx, linea_y, col_linea)
      end
    end
    clip()
    rectfill(1, 114, 126, 126, 0) line(1, 113, 126, 113, 6)
    local c_sal = (ranita_anim < 30) and 5 or 7
    print("press (a) to jump", 16, 117, c_sal)
    render_ranita_xtree(ranita_x, ranita_y)
    return 
  end

  -- AISLAMIENTO TOTAL 2: Pantalla de Historial Adaptativa al Tema (¡Ranita reincorporada!)
  if modo_actual == 3 then
    cls(c_fondo)
    
    rectfill(0, 0, 127, 13, c_display)
    line(0, 13, 127, 13, c_btn_txt)
    print("calculation history", 18, 4, c_txt_dis)
    
    rectfill(4, 18, 123, 98, c_display)
    rect(4, 18, 123, 98, c_btn_bse)
    
    if #hist_lista == 0 then
      print("empty history", 32, 54, c_btn_txt)
    else
      for i=1, #hist_lista do
        local ly = 22 + (i - 1) * 15
        if i == hist_idx then
          rectfill(6, ly - 2, 121, ly + 8, c_btn_bse)
          print("-> "..hist_lista[i], 10, ly, c_btn_txt)
        else
          print("   "..hist_lista[i], 10, ly, c_txt_dis)
        end
      end
    end
    
    rectfill(0, 102, 127, 127, 0)
    line(0, 102, 127, 102, 6)
    print("\x8b\x91:select (a): load value", 4, 106, 7)
    print("press (b): exit | maint. (b)+right:delete", 4, 115, 5)
    print("ops:"..ops_totales, 94, 106, 10)
    
    -- Forzar renderizado de la ranita en las coordenadas correctas del marco inferior
    render_ranita_xtree(ranita_x, ranita_y)
    return
  end

  -- RENDERIZADO NORMAL DE LA CALCULADORA (Modos 0 y 1)
  cls(c_fondo)
  
  -- Header Superior
  rectfill(0, 0, 127, 7, 0)
  print(id_nombre.." "..id_version, 4, 1, 7)
  print(str_reloj, 94, 1, 5)
  line(0, 7, 127, 7, 6)
  
  -- Display Numérico Principal
  rectfill(4, 11, 123, 31, c_display)
  rect(3, 10, 124, 32, 7)
  
  if v_historial != "" then
    local x_hist = 120 - (#v_historial * 4)
    if x_hist < 8 then x_hist = 8 end
    print(v_historial, x_hist, 13, 5)
  end
  
  local x_dis = 120 - (#v_pantalla * 4)
  if x_dis < 8 then x_dis = 8 end
  
  poke(0x5f58, 0x11) 
  print(v_pantalla, x_dis, 20, c_txt_dis)
  poke(0x5f58, 0x00) 
  
  local txt_modo = "MODE: STANDARD"
  if modo_actual == 1 then txt_modo = "MODE: SCIENTIFIC" end
  print(txt_modo, 5, 35, 6)
  
  -- Renderizado de Botoneras Base
  local botonera_activa = (modo_actual == 1) and pad_cientifico or pad_estandar
  local inicio_x, inicio_y = 4, 43
  local b_ancho, b_alto, espacio = 22, 12, 2
  
  for i, btn_data in ipairs(botonera_activa) do
    local txt = btn_data[1]
    local tipo = btn_data[2]
    local grid_x = (i - 1) % max_cx
    local grid_y = flr((i - 1) / max_cx)
    local bx = inicio_x + grid_x * (b_ancho + espacio)
    local by = inicio_y + grid_y * (b_alto + espacio)
    
    if grid_x == cx and grid_y == cy then
      rectfill(bx, by, bx + b_ancho, by + b_alto, 10) 
      rect(bx, by, bx + b_ancho, by + b_alto, 7)
      local tx = bx + (b_ancho - (#txt * 4)) / 2 + 1
      print(txt, tx, by + 4, 0)
    else
      local color_cuerpo = c_btn_bse
      if tipo == 1 then color_cuerpo = 4   
      elseif tipo == 2 then color_cuerpo = 8 
      elseif tipo == 3 then color_cuerpo = 3 
      end
      rectfill(bx, by, bx + b_ancho, by + b_alto, color_cuerpo)
      rect(bx, by, bx + b_ancho, by + b_alto, 5)
      local tx = bx + (b_ancho - (#txt * 4)) / 2 + 1
      print(txt, tx, by + 4, c_btn_txt)
    end
  end
  
  render_ranita_xtree(ranita_x, ranita_y)
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 5: CONTROL EMOCIONAL Y DIBUJO DE LA MASCOTA
-- =========================================================

function render_ranita_xtree(x, y)
  local offset_y = (ranita_anim < 30) and 0 or 1
  local ry = y + offset_y
  
  local color_cuerpo = 11 
  local color_borde = 3   
  local color_boca = 8    
  
  local color_adaptativo = temas[idx_tema][3]
  
  -- DETECCIÓN EVOLUTIVA DE EMOCIONES
  if ops_totales >= 150 then
    color_cuerpo = color_adaptativo
    color_borde = temas[idx_tema][4] 
  end
  
  -- DIBUJO DEL CUERPO
  rectfill(x, ry + 2, x + 10, ry + 10, color_borde)    
  rectfill(x + 1, ry + 3, x + 9, ry + 10, color_cuerpo) 
  
  -- DIBUJO DE LOS OJOS
  rectfill(x, ry, x + 2, ry + 2, color_borde)
  rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
  rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)  
  rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
  pset(x + 1, ry + 2, 0) pset(x + 9, ry + 2, 0)
  
  -- GESTIÓN DINÁMICA DE LA BOCA (Expresión Emocional)
  if ops_totales >= 30 then
    pset(x + 3, ry + 7, color_boca)
    rectfill(x + 4, ry + 8, x + 6, ry + 8, color_boca)
    pset(x + 7, ry + 7, color_boca)
  else
    rectfill(x + 3, ry + 6, x + 7, ry + 7, 8)
  end
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.04]
-- PARTE 6: PROCESADOR MATEMÁTICO Y PARSEO DE ENTRADA
-- =========================================================

function procesar_entrada(btn_data)
  local txt = btn_data[1]  
  local tipo = btn_data[2] 
  sfx(3)

  if txt == "C" then
    v_pantalla = "0" v_historial = "" n1 = 0 n2 = 0 op = ""
    tiene_punto = false limpiar_pantalla = false
    return
  -----------
  elseif txt == "DEL" then
    if #v_pantalla > 1 then
      if sub(v_pantalla, #v_pantalla) == "." then tiene_punto = false end
      v_pantalla = sub(v_pantalla, 1, #v_pantalla - 1)
    else
      v_pantalla = "0"
    end
    return
  -----------
  elseif txt == "RET" then
    modo_actual = 0 cx = 0 cy = 0
    return
  -----------
  elseif txt == "+/-" then
    if v_pantalla != "0" and v_pantalla != "error" then
      if sub(v_pantalla, 1, 1) == "-" then v_pantalla = sub(v_pantalla, 2) else v_pantalla = "-"..v_pantalla end
    end
    return
  -----------
  elseif txt == "." then
    if not tiene_punto then v_pantalla = v_pantalla.."."; tiene_punto = true end
    return
  -----------
  elseif txt == "M+" then
    memoria = memoria + (tonum(v_pantalla) or 0)
    return
  end

  -- GESTIÓN DE NÚMEROS
  if tipo == 0 then
    local digito = txt
    if txt == "PI" then digito = tostr(3.1416)
    elseif txt == "E" then digito = tostr(2.7182) end
    
    if limpiar_pantalla or v_pantalla == "0" or v_pantalla == "error" then
      v_pantalla = digito
      limpiar_pantalla = false 
    else
      if #v_pantalla < 10 then v_pantalla = v_pantalla..digito end
    end
    return
  end

  -- OPERADORES BINARIOS BÁSICOS
  if tipo == 1 then
    n1 = tonum(v_pantalla) or 0
    op = txt
    v_historial = tostr(n1).." "..op
    limpiar_pantalla = true
    tiene_punto = false
    return
  end

  -- PROCESAMIENTO DEL BOTÓN IGUAL
  if txt == "=" then
    if op == "" then return end
    n2 = tonum(v_pantalla) or 0
    local res = 0
    
    if op == "+" then res = n1 + n2
    elseif op == "-" then res = n1 - n2
    elseif op == "*" then res = n1 * n2
    elseif op == "/" then 
      if n2 == 0 then v_pantalla = "error" op = "" return else res = n1 / n2 end
    elseif op == "^" then res = n1 ^ n2
    elseif op == "MOD" then res = n1 % n2 end
    
    v_historial = tostr(n1)..op..tostr(n2).."="
    v_pantalla = ajustar_resultado(res)
    
    if v_pantalla != "error" then
      registrar_en_historial(v_pantalla)
    end
    
    op = ""
    n1 = res
    limpiar_pantalla = true
    return
  end

  -- OPERACIONES CIENTÍFICAS
  if tipo == 3 then
    local val = tonum(v_pantalla) or 0
    local res = 0
    v_historial = txt.."("..tostr(val)..")"
    
    if txt == "^" or txt == "MOD" then
      n1 = tonum(v_pantalla) or 0
      op = txt
      v_historial = tostr(n1).." "..op
      limpiar_pantalla = true
      tiene_punto = false
      modo_actual = 0 
      return
    end

    if txt == "SIN" then res = sin(val / 360) 
    elseif txt == "COS" then res = cos(val / 360)
    elseif txt == "TAN" then 
      local c = cos(val / 360)
      if c == 0 then v_pantalla = "error" return else res = sin(val / 360) / c end
    elseif txt == "ASN" then res = asin(val) * 360
    elseif txt == "ACS" then res = acos(val) * 360
    elseif txt == "ATN" then res = atan2(1, val) * 360
    elseif txt == "PI2" then res = 3.1416 * 3.1416
    elseif txt == "RND" then res = rnd(flr(val) > 0 and flr(val) or 100)
    elseif txt == "SQRT" then 
      if val < 0 then v_pantalla = "error" return else res = sqrt(val) end
    elseif txt == "LN" then 
      if val <= 0 then v_pantalla = "error" return else res = log(val) end
    elseif txt == "LOG" then 
      if val <= 0 then v_pantalla = "error" return else res = log10(val) end
    -----------------------------------------------------
    elseif txt == "EXP" then res = exp(val)
    elseif txt == "ABS" then res = abs(val)
    elseif txt == "1/X" then 
      if val == 0 then v_pantalla = "error" return else res = 1 / val end
    elseif txt == "FACT" then
      if val < 0 or val > 12 then v_pantalla = "error" return end
      res = 1
      for i = 1, flr(val) do res = res * i end
    end
    
    v_pantalla = ajustar_resultado(res)
    
    if v_pantalla != "error" then
      registrar_en_historial(v_pantalla)
    end
    
    limpiar_pantalla = true
    return
  end
end

function ajustar_resultado(valor)
  local s = tostr(valor)
  if #s > 10 then s = sub(s, 1, 10) end
  tiene_punto = false
  for i=1,#s do if sub(s,i,i) == "." then tiene_punto = true end end
  return s
end
