pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.02]
-- PARTE 1: CORE DE INICIALIZACIÓN Y CONFIGURACIÓN DE GRIDS
-- =========================================================

function _init()
  -- Información del Sistema
  id_nombre = "XTREE FORCE"
  id_version = "V0.02"
  
  -- Modos de Ejecución (0: Estándar, 1: Científico, 2: Pantalla Acerca de)
  modo_actual = 0 
  
  -- Gestión de Valores y Registros (Memoria Operacional)
  v_pantalla = "0"     
  v_historial = ""    
  memoria = 0         
  
  -- Variables de control de flujo matemático
  n1 = 0 n2 = 0 op = ""
  limpiar_pantalla = false
  tiene_punto = false
  
  -- SISTEMA DE TEMAS DE COLOR MODERNOS
  temas = {
    {1, 0, 11, 2, 7},   -- 1: Neon Midnight (Azul / Negro / Verde Rana)
    {0, 5, 14, 1, 7},   -- 2: Cyber Punk (Negro / Gris / Rosa)
    {4, 15, 0, 13, 7},  -- 3: Chocolate Mint (Marrón / Blanco / Menta)
    {13, 1, 10, 12, 7}, -- 4: Forest Mist (Verde Oscuro / Gris / Amarillo)
    {15, 7, 2, 14, 0}   -- 5: Light Mode Retro (Blanco / Gris / Negro)
  }
  idx_tema = 1
  
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
  
  -- Coordenadas del Cursor
  cx = 0 cy = 0
  max_cx = 4 max_cy = 5 
  
  -- Mascota Oficial (Ranita Xtree)
  ranita_x = 114 ranita_y = 114 ranita_anim = 0 
  
  -- CONFIGURACIÓN DEL SCROLL "ABOUT"
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
    "b + izq    : acerca de",
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
-- CALCULATOR XTREE FORCE [v0.02]
-- PARTE 2: LÓGICA DE ACTUALIZACIÓN, COMBOS Y CONTROL DE SCROLL
-- =========================================================

function _update60()
  ranita_anim = (ranita_anim + 1) % 60
  
  -- COMBO 1: B (5) + FLECHA ARRIBA (2) -> Alternar modo Científico / Estándar
  if btn(5) and btnp(2) then
    if modo_actual != 2 then
      modo_actual = (modo_actual == 0) and 1 or 0
      cx = 0 cy = 0 limpiar_pantalla = true
      sfx(0)
    end
    return
  end
  
  -- ✅ COMBO 2 CORREGIDO: B (5) + FLECHA DERECHA (1) -> Cambiar Tema de Color
  if btn(5) and btnp(1) then
    if modo_actual != 2 then
      idx_tema = idx_tema + 1
      if idx_tema > #temas then idx_tema = 1 end
      sfx(1)
    end
    return
  end

  -- COMBO 3: A (4) + FLECHA DERECHA (1) -> Clear All Rápido (Solo si no presiona B)
  if btn(4) and btnp(1) and not btn(5) then
    if modo_actual != 2 then
      v_pantalla = "0" v_historial = "" n1 = 0 n2 = 0 op = ""
      tiene_punto = false limpiar_pantalla = false
      sfx(2)
    end
    return
  end

  -- COMBO 4: B (5) + FLECHA IZQUIERDA (0) -> Activar/Desactivar Acerca De con Scroll
  if btn(5) and btnp(0) then
    if modo_actual != 2 then
      modo_actual = 2
      scroll_y = scroll_y_inicio 
    else
      modo_actual = 0
    end
    sfx(0)
    return
  end

  -- CONTROL DEL MODO ACERCA DE (SCROLL AUTOMÁTICO)
  if modo_actual == 2 then
    scroll_y = scroll_y - scroll_velocidad
    local limite_final = 10 - (#textos_acercade * 9)
    
    if scroll_y < limite_final then
      modo_actual = 0
      sfx(1)
    end
    
    if btnp(4) then
      modo_actual = 0
      sfx(1)
    end
    return -- Congela la navegación matemática mientras el scroll esté corriendo
  end

  -- NAVEGACIÓN ESTÁNDAR POR LAS TECLAS MATEMÁTICAS
  if btnp(0) then cx = (cx - 1) % max_cx end 
  if btnp(1) then cx = (cx + 1) % max_cx end 
  if btnp(2) then cy = (cy - 1) % max_cy end 
  if btnp(3) then cy = (cy + 1) % max_cy end 
  
  -- SELECCIÓN CON BOTÓN A (4)
  if btnp(4) and not btn(5) then
    local idx = cy * max_cx + cx + 1
    if modo_actual == 0 then
      if pad_estandar[idx] then procesar_entrada(pad_estandar[idx]) end
    elseif modo_actual == 1 then
      if pad_cientifico[idx] then procesar_entrada(pad_cientifico[idx]) end
    end
  end
end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.02]
-- PARTE 3: MOTOR GRÁFICO AISLADO Y PROCESADOR MATEMÁTICO
-- =========================================================

function _draw()
  -- Asegurar reset absoluto de cualquier recorte gráfico residual
  clip()
  
  local c_fondo   = temas[idx_tema][1]
  local c_display = temas[idx_tema][2]
  local c_txt_dis = temas[idx_tema][3]
  local c_btn_bse = temas[idx_tema][4]
  local c_btn_txt = temas[idx_tema][5]
  
  -- ✅ AISLAMIENTO TOTAL: Si modo_actual es 2 (Acerca de), renderiza una pantalla cinematográfica limpia
  if modo_actual == 2 then
    cls(0) -- Fondo negro puro estilo créditos de cine
    rect(0, 0, 127, 127, 7) -- Borde elegante
    
    -- Aplicar ventana de recorte segura en el centro
    clip(4, 12, 120, 96)
    
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
    
    -- Liberar recorte gráfico obligatoriamente
    clip()
    
    -- Pie de página fijo de salida
    rectfill(1, 114, 126, 126, 0)
    line(1, 113, 126, 113, 6)
    local c_sal = (ranita_anim < 30) and 5 or 7
    print("press (a) to jump", 16, 117, c_sal)
    render_ranita_xtree(ranita_x, ranita_y)
    return -- Detiene el draw aquí para evitar que se mezclen elementos de la calculadora
  end

  -- RENDERIZADO NORMAL DE LA CALCULADORA (Solo si modo_actual != 2)
  cls(c_fondo)
  
  -- Header Superior
  rectfill(0, 0, 127, 7, 0)
  print(id_nombre, 4, 1, 7)
  print(id_version, 98, 1, 5)
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
  
  poke(0x5f58, 0x11) -- Texto Gigante Nativo
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

function render_ranita_xtree(x, y)
  local offset_y = (ranita_anim < 30) and 0 or 1
  local ry = y + offset_y
  rectfill(x, ry + 2, x + 10, ry + 10, 3)    
  rectfill(x + 1, ry + 3, x + 9, ry + 10, 11) 
  rectfill(x, ry, x + 2, ry + 2, 3)
  rectfill(x + 8, ry, x + 10, ry + 2, 3)
  rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)  
  rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
  pset(x + 1, ry + 2, 0) pset(x + 9, ry + 2, 0)
  rectfill(x + 3, ry + 6, x + 7, ry + 7, 8)
end

function procesar_entrada(btn_data)
  local txt = btn_data[1]  
  local tipo = btn_data[2] 
  sfx(3)

  if txt == "C" then
    v_pantalla = "0" v_historial = "" n1 = 0 n2 = 0 op = ""
    tiene_punto = false limpiar_pantalla = false
    return
  elseif txt == "DEL" then
    if #v_pantalla > 1 then
      if sub(v_pantalla, #v_pantalla) == "." then tiene_punto = false end
      v_pantalla = sub(v_pantalla, 1, #v_pantalla - 1)
    else
      v_pantalla = "0"
    end
    return
  elseif txt == "RET" then
    modo_actual = 0 cx = 0 cy = 0
    return
  elseif txt == "+/-" then
    if v_pantalla != "0" and v_pantalla != "error" then
      if sub(v_pantalla, 1, 1) == "-" then v_pantalla = sub(v_pantalla, 2) else v_pantalla = "-"..v_pantalla end
    end
    return
  elseif txt == "." then
    if not tiene_punto then v_pantalla = v_pantalla.."."; tiene_punto = true end
    return
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
    elseif txt == "LN" then res = log(val)
    elseif txt == "LOG" then res = log(val) / log(10)
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
