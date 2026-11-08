pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 1: CORE DE INICIALIZACIÓN Y CONFIGURACIÓN DE GRIDS
-- =========================================================

function _init()
  -- Información del Sistema
  id_nombre = "XTREE FORCE"
  id_version = "V0.08"
  
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
    {0, 4, 10, 5, 7},   -- 10: Matrix Terminal
    {3, 11, 3, 1, 11},  -- 11: Classic GameBoy (Muted Greens)
    {0, 12, 7, 13, 12}, -- 12: Synthwave Dream (Purple & Cyan)
    {0, 8, 14, 2, 8},   -- 13: Magma Chamber (Dark Red & Gold)
    {15, 4, 14, 0, 7},  -- 14: Blueprint Tech (Industrial Blue)
    {1, 5, 6, 2, 14},   -- 15: Frozen Tundra (Arctic Chill)
    {0, 9, 10, 4, 9},   -- 16: Radioactive (Lime & Carbon)
    {2, 13, 7, 14, 2}   -- 17: Pastel Sorbet (Soft Violet)
  }
  idx_tema = 1

  -- Nombres de los temas (Mantener el mismo orden que la lista de temas)
  nombres_temas = {
    "neon midnight", "cyber punk", "choco mint", "forest mist", 
    "light retro", "blood vapor", "toxic waste", "deep ocean", 
    "sunset peach", "matrix term", "classic gb", "synthwave", 
    "magma chamb", "blueprint", "frozen tund", "radioactive", "pastel sorb"
  }

  -- control de tiempo para los besos de la ranita (60 fps = 1 segundo)
  cronometro_beso = 0
  tiempo_proximo_beso = 5400 -- 5400 frames = 1 minuto y medio (primer beso)
  estado_beso = 0            -- 0: normal, >0: animando el beso y corazón
  
  -- SISTEMA DE PERSISTENCIA EXTENDIDO NATIVO
  cartdata("xtree_force_calc")
  
  -- Diccionario de compresión de 4 bits para ahorrar espacio físico (Máx 15 símbolos)
  -- Permite meter 8 caracteres por cada ranura de PICO-8
  comp_dict = {"0","1","2","3","4","5","6","7","8","9",".","-","+","*","/",
               "=","^","M","O","D","S","I","N","C","A","T","G","L","E","X","P","R","V","(",")"}
  
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
            
  
  -- Validación de seguridad adaptada al límite físico real comprimido (Máximo 30)
  if hist_total == nil or hist_total < 0 or hist_total > 30 then
    hist_total = 0
    dset(2, 0)
  end
  
  -- Descompresión y reconstrucción del historial desde las 64 ranuras físicas
  if hist_total > 0 then
    for i=1, min(hist_total, 30) do
      local base_registro = 3 + (i - 1) * 2
      local r1 = dget(base_registro) or 0
      local r2 = dget(base_registro + 1) or 0
      
      local string_reconstruido = ""
      
      -- Desempaquetamos r1 (Primeros 8 caracteres de 4 bits)
      local temp1 = r1
      for j=1, 8 do
        local nibble = temp1 % 16
        if nibble > 0 and comp_dict[nibble] then string_reconstruido = string_reconstruido..comp_dict[nibble] end
        temp1 = flr(temp1 / 16)
      end
      
      -- Desempaquetamos r2 (Siguientes 8 caracteres de 4 bits)
      local temp2 = r2
      for j=1, 8 do
        local nibble = temp2 % 16
        if nibble > 0 and comp_dict[nibble] then string_reconstruido = string_reconstruido..comp_dict[nibble] end
        temp2 = flr(temp2 / 16)
      end
      
      if #string_reconstruido > 0 then
        add(hist_lista, string_reconstruido)
      end
    end
    hist_total = #hist_lista
    dset(2, hist_total)
  end

  reg_desde_borrado = 10 
  borrados_seguidos = 0
  -- Nueva variable para controlar el desplazamiento visual de la lista
  hist_scroll = 0

  
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

  -- [MEJORA GATO] - VARIABLES DE CONTROL DE EVENTO Y MINIJUEGO
  ani_gato_frames = 0   -- Contador de tiempo para la cinemática en el centro
  gato_tablero = {}     -- Matriz de 3x3 (0: Vacío, 1: Usuario "X", 2: Ranita "O")
  gato_cx = 0           -- Cursor X en el tablero del gato (0 a 2)
  gato_cy = 0           -- Cursor Y en el tablero del gato (0 a 2)
  gato_turno = 1        -- 1: Usuario, 2: Ranita IA
  gato_estado = ""      -- "", "juzgando", "gana_user", "gana_ranita", "empate"
  gato_cooldown_ia = 0  -- Retardo de frames para que la IA "piense" y no juegue instantáneo
  
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

  -- [MEJORA AUDIO DEFINITIVA] - CONTROL DE SONIDO DE INTERFAZ (Default: Apagado)
  sonido_activo = false
  
  function tocar_sfx(id)
    if sonido_activo then sfx(id) end
  end

end
-- =========================================================
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 2: LÓGICA DE ACTUALIZACIÓN, COMBOS Y REFRESH DE HORA
-- =========================================================

function _update60()
  ranita_anim = (ranita_anim + 1) % 60

  -- [MEJORA GATO] - CAPTURA DE MODOS DE JUEGO AISLADOS
  if modo_actual == 4 then
    actualizar_cinematica_beso()
    return
  elseif modo_actual == 5 then
    actualizar_logica_gato()
    return
  end
  
  -- actualizar tiempos de la ranita (añadir al inicio de _update60)
  cronometro_beso = cronometro_beso + 1
  if cronometro_beso >= tiempo_proximo_beso then
    cronometro_beso = 0
    estado_beso = 90 -- el beso y el corazón durarán 90 frames en pantalla (1.5 segundos)
    -- calcular aleatorio para el próximo beso (entre 2 y 3 minutos: 7200 a 10800 frames)
    tiempo_proximo_beso = 7200 + flr(rnd(3600))
  end
  if estado_beso > 0 then estado_beso = estado_beso - 1 end

  
  if delay_historial > 0 then 
    delay_historial = delay_historial - 1 
    -- El escudo SOLO detiene el código si YA salimos a la calculadora (modo 0 o 1)
    -- Si estamos dentro del historial (modo 3), no se activa y nos deja salir libremente
    if modo_actual == 0 or modo_actual == 1 then
      return
    end
  end
  
  -- LECTURA HORARIA EXTRAÍDA DE LA APP DE UTILERÍA
  local hrs = stat(93) or 0
  local mnts = stat(94) or 0
  local segs = stat(95) or 0
  
  local sh = tostr(hrs) if #sh < 2 then sh = "0"..sh end
  local sm = tostr(mnts) if #sm < 2 then sm = "0"..sm end
  local ss = tostr(segs) if #ss < 2 then ss = "0"..ss end
  str_reloj = sh..":"..sm..":"..ss
  
  -- COMBO AUDIO: A (4) + FLECHA ARRIBA (2) -> Activar/Desactivar Sonido Global
  if btn(4) and btnp(2) and modo_actual != 2 and modo_actual != 3 and modo_actual != 4 and modo_actual != 5 then
    sonido_activo = not sonido_activo
    if sonido_activo then sfx(2) end -- Llama al nativo directo solo para este aviso
    return
  end
  
  -- COMBO 1: B (5) + FLECHA ARRIBA (2) -> Alternar modo Científico / Estándar (Filtrado)
  if btn(5) and btnp(2) and modo_actual != 2 and modo_actual != 3 then
    modo_actual = (modo_actual == 0) and 1 or 0
    cx = 0 cy = 0 limpiar_pantalla = true
    sfx(0)
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
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 3: LÓGICA DE NAVEGACIÓN Y PROCESAMIENTO DEL HISTORIAL
-- =========================================================

function actualizar_interfaz_historial()
  -- 1. PRIORIDAD ABSOLUTA DE SALIDA CON FLECHA DERECHA (1)
  -- Se evalúa antes que cualquier otra cosa para garantizar que NUNCA te quedes atrapado
  if btnp(1) then
    modo_actual = 0
    delay_historial = 12 -- Activa el escudo protector en la calculadora
    bloqueo_b = false    -- Resetea cualquier cerrojo de B
    sfx(0)
    return
  end

  -- 2. DETECCIÓN PRIORITARIA DEL COMBO DE BORRADO (B + Arriba)
  if btn(5) and btn(2) then
    hist_lista = {}
    hist_total = 0
    
    -- evaluar penalización por borrado rápido
    if reg_desde_borrado < 10 then
      borrados_seguidos = borrados_seguidos + 1
    else
      borrados_seguidos = 1
    end
    
    -- si se borra 3 veces seguidas sin superar 10 registros
    if borrados_seguidos >= 3 then
      ops_totales = -10 -- <-- cambiamos de -1 a -10
      borrados_seguidos = 0
    else
      ops_totales = 0
    end
    
    reg_desde_borrado = 0 -- resetea el contador para el próximo ciclo
    
    dset(1, ops_totales) -- Guarda el estado de la ranita en el archivo
    dset(2, 0)           -- Guarda el total de historial en cero
    
    -- Limpia las 60 ranuras de registros con ceros para vaciar el archivo físico
    for i=3, 63 do
      dset(i, 0)
    end
    
    -- Conserva la configuración de tu tema intacta en la ranura 0
    dset(0, idx_tema)
    
    hist_idx = 1
    hist_scroll = 0
    bloqueo_b = true 
    delay_historial = 5
    sfx(2)
    return
  end

  -- 3. Liberar el cerrojo del botón B únicamente cuando el usuario suelta el botón físicamente
  if bloqueo_b then
    if not btn(5) then bloqueo_b = false end
    return -- Omite lecturas de navegación/carga este frame para proteger la interfaz
  end

  -- 4. Navegación Vertical entre los elementos con cálculo de scroll automático
  if #hist_lista > 0 then
    if btnp(2) and not btn(5) then -- Flecha Arriba (Solo si no mantienes B)
      hist_idx = hist_idx - 1
      if hist_idx < 1 then 
        hist_idx = #hist_lista 
        hist_scroll = max(0, #hist_lista - 5)
      elseif hist_idx < hist_scroll + 1 then
        hist_scroll = hist_idx - 1
      end
      sfx(3)
      return
    end
    if btnp(3) then -- Flecha Abajo
      hist_idx = hist_idx + 1
      if hist_idx > #hist_lista then 
        hist_idx = 1 
        hist_scroll = 0
      elseif hist_idx > hist_scroll + 5 then
        hist_scroll = hist_idx - 5
      end
      sfx(3)
      return
    end

    -- CONFIRMAR OPERACIÓN: Ejecución directa con Botón A (4) solo (Carga Segura)
    if btnp(4) and not btn(5) then
      v_pantalla = hist_lista[hist_idx]
      v_historial = "" 
      
      tiene_punto = false
      for i=1, #v_pantalla do
        if sub(v_pantalla, i, i) == "." then tiene_punto = true end
      end
      
      limpiar_pantalla = true 
      modo_actual = 0
      delay_historial = 12 -- Activa el escudo protector en la calculadora
      sfx(2)
      return
    end
  end
end

function registrar_en_historial(str_resultado)
  local n_val = tonum(str_resultado) or 0
  extrude_historial(str_resultado, n_val)
  
  -- subida aritmética real y progresiva paso a paso
  ops_totales = ops_totales + 1

  -- [MEJORA GATO] - INTERCEPTOR DE OPERACIÓN 400
  if ops_totales == 400 then
    modo_actual = 4       -- Activamos Modo Cinemática del Beso Gigante
    ani_gato_frames = 0   -- Reseteamos el reloj de la animación
    estado_beso = 120     -- Forzamos la animación de la boca de beso por 2 segundos
  end
  
  -- condición de liberación: si logró subir del -1 al 0
  if ops_totales == 0 and borrados_seguidos >= 2 then
    borrados_seguidos = 0 -- limpia los castigos anteriores de raíz
  end
  
  -- sumamos al contador de registros entre borrados normales
  reg_desde_borrado = reg_desde_borrado + 1
  
  dset(1, ops_totales) 
end


function extrude_historial(s_val, n_val)
  add(hist_lista, s_val, 1)
  if #hist_lista > 30 then
    del(hist_lista, hist_lista[#hist_lista])
  end
  hist_total = #hist_lista
  guardar_memoria_fisica() 
end

function guardar_memoria_fisica()
  dset(0, idx_tema)
  dset(1, ops_totales)
  dset(2, hist_total)
  
  -- Guardamos hasta 30 elementos usando únicamente 2 ranuras por registro
  for i=1, min(#hist_lista, 30) do
    local str = hist_lista[i]
    local base_registro = 3 + (i - 1) * 2
    
    local r1 = 0
    local r2 = 0
    
    -- Empaquetamos los primeros 8 caracteres en r1
    for j=1, min(#str, 8) do
      local char = sub(str, j, j)
      local idx_char = 0
      for k=1, #comp_dict do
        if comp_dict[k] == char then idx_char = k break end
      end
      r1 = r1 + idx_char * (16 ^ (j - 1))
    end
    
    -- Empaquetamos los siguientes caracteres en r2
    if #str > 8 then
      for j=9, min(#str, 16) do
        local char = sub(str, j, j)
        local idx_char = 0
        for k=1, #comp_dict do
          if comp_dict[k] == char then idx_char = k break end
        end
        r2 = r2 + idx_char * (16 ^ (j - 9))
      end
    end
    
    dset(base_registro, r1)
    dset(base_registro + 1, r2)
  end
end

-- =========================================================
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 4: MOTOR GRÁFICO AISLADO Y MÓDULO RENDER
-- =========================================================

function _draw()
  clip()
  
  local c_fondo   = temas[idx_tema][1]
  local c_display = temas[idx_tema][2]
  local c_txt_dis = temas[idx_tema][3]
  local c_btn_bse = temas[idx_tema][4]
  local c_btn_txt = temas[idx_tema][5]

  -- [MEJORA GATO] - INTERCEPTOR GRÁFICO PARA EL MINIJUEGO
  if modo_actual == 4 then
    render_cinematica_beso_central(c_fondo)
    return
  elseif modo_actual == 5 then
    render_pantalla_gato(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
    return
  end
  
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

  -- AISLAMIENTO TOTAL 2: Pantalla de Historial Adaptativa al Tema (Con Scroll Dinámico)
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
      -- Renderiza solo los elementos visibles basados en la ventana de scroll (máximo 5)
      for i = hist_scroll + 1, min(#hist_lista, hist_scroll + 5) do
        local renglon = i - hist_scroll
        local ly = 22 + (renglon - 1) * 15
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
    print("\x8b\x91:choose (\x94):return", 4, 106, 7)
    print("press A: load | Press B + Up:delete", 4, 115, 5)
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

  -- [MEJORA AUDIO] Indica visualmente si el sonido está activo en el Top Bar
  if sonido_activo then
    print("\xbe", 84, 1, 11) -- Nota musical verde si está encendido
  else
    print("\xbe", 84, 1, 5)  -- Nota musical gris oscuro si está apagado
  end
  
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
  
  -- nombre del tema en la esquina inferior izquierda (con color de alto contraste)
  if nombres_temas[idx_tema] then
    -- si el color de fondo es blanco o muy claro (como el tema 5), usamos texto negro (0), si no, blanco (7)
    local col_nombre_tema = (c_fondo == 15 or c_fondo == 7) and 0 or 7
    print("theme: "..nombres_temas[idx_tema], 4, 118, col_nombre_tema)
  end
  
  
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
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 5: CONTROL EMOCIONAL Y DIBUJO DE LA MASCOTA
-- =========================================================

function render_ranita_xtree(x, y)
  -- FPS mejorados: oscilación senoidal suave (renderizado orgánico de alta fluidez)
  local offset_y = flr(sin(ranita_anim / 60) * 1.8)
  local ry = y + offset_y
  
  local color_cuerpo = 11 
  local color_borde = 3   
  local color_boca = 8    
  
  -- adaptaciones de color basadas en tus temas anteriores
  local color_adaptativo = temas[idx_tema][3]
  if ops_totales >= 150 then
    color_cuerpo = color_adaptativo
    color_borde = temas[idx_tema][4] 
  end
  
  -- 1. DIBUJO BASE DEL CUERPO
  rectfill(x, ry + 2, x + 10, ry + 10, color_borde)    
  rectfill(x + 1, ry + 3, x + 9, ry + 10, color_cuerpo) 
  
  -- 2. MOTOR DINÁMICO DE EMOCIONES (DIBUJO DE OJOS Y ACCESORIOS)
  if ops_totales < 0 then
    -- ESTADO: TRISTE (Ojos caídos llorosos y sin brillo)
    rectfill(x, ry + 1, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry + 1, x + 10, ry + 2, color_borde)
    pset(x + 1, ry + 2, 12) pset(x + 9, ry + 2, 12) -- Lágrima/Brillo tenue azulado
    
  elseif estado_beso > 0 then
    -- ESTADO: TIRADOR DE BESOS (Ojos felices cerrados en arco de amor "^ ^")
    pset(x, ry + 2, color_borde) pset(x + 2, ry + 2, color_borde) pset(x + 1, ry + 1, color_borde)
    pset(x + 8, ry + 2, color_borde) pset(x + 10, ry + 2, color_borde) pset(x + 9, ry + 1, color_borde)
    
    -- Efecto de corazón flotante (Se eleva con el tiempo de la animación)
    local cor_x = x - 6 - flr(estado_beso / 15) % 4
    local cor_y = ry - 4 + flr(estado_beso / 8)
    if cor_y > ry - 14 then
      -- Mini corazón de 3x3 píxeles (Rojo escarlata)
      pset(cor_x + 1, cor_y, 8) pset(cor_x, cor_y + 1, 8) 
      pset(cor_x + 2, cor_y + 1, 8) pset(cor_x + 1, cor_y + 2, 8)
    end
    
  elseif ops_totales >= 250 then
    -- ESTADO: LENTES DE SOL (Estilo Hacker Cyberpunk / Pro)
    rectfill(x - 1, ry + 1, x + 4, ry + 3, 0) -- Lente izquierdo
    rectfill(x + 6, ry + 1, x + 11, ry + 3, 0) -- Lente derecho
    line(x + 3, ry + 1, x + 7, ry + 1, 0)      -- Puente de las gafas
    pset(x, ry + 2, 7) pset(x + 7, ry + 2, 7)  -- Reflejo blanco en las gafas
    
  elseif ops_totales >= 100 and ops_totales < 150 then
    -- ESTADO: GUIÑO DE OJO (Ojo izquierdo normal, derecho guiñando "-")
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7) pset(x + 1, ry + 2, 0) -- Izquierdo normal
    line(x + 8, ry + 2, x + 10, ry + 2, color_borde)                 -- Derecho cerrado
    
  else
    -- ESTADO: NORMAL / ANIMADO / ENÉRGICO (Ojos estándar abiertos)
    rectfill(x, ry, x + 2, ry + 2, color_borde)
    rectfill(x + 8, ry, x + 10, ry + 2, color_borde)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)  
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, 0) pset(x + 9, ry + 2, 0)
  end
  
    -- 3. GESTIÓN DINÁMICA DE LA BOCA Y EXPRESIÓN COMPLEMENTARIA
  if ops_totales < 0 then
    -- Boca triste (Arco invertido hacia abajo)
    pset(x + 3, ry + 8, color_boca)
    rectfill(x + 4, ry + 7, x + 6, ry + 7, color_boca)
    pset(x + 7, ry + 8, color_boca)
    
  elseif estado_beso > 0 then
    -- Boca de beso ("Chu" / Corazón pequeño pegado a la boca)
    rectfill(x + 4, ry + 7, x + 5, ry + 7, 8)
    pset(x + 3, ry + 7, 7) -- Brillo del beso
    
  elseif ops_totales >= 150 then
    -- Estado Enérgico: Sonrisa gigante abierta mostrando felicidad extrema
    rectfill(x + 3, ry + 6, x + 7, ry + 8, color_borde)
    rectfill(x + 4, ry + 7, x + 6, ry + 8, 7) -- Dientes / Interior de la boca
    
  elseif ops_totales >= 30 and ops_totales < 150 then
    -- Estado Animado: Sonrisa estándar alegre
    pset(x + 3, ry + 7, color_boca)
    rectfill(x + 4, ry + 8, x + 6, ry + 8, color_boca)
    pset(x + 7, ry + 7, color_boca)
    
  else
    -- Estado Base: Línea de expresión neutral
    rectfill(x + 3, ry + 6, x + 7, ry + 7, 8)
  end
end


-- =========================================================
-- CALCULATOR XTREE FORCE [v0.08]
-- PARTE 6: PROCESADOR MATEMÁTICO Y PARSEO DE ENTRADA (REPARADO)
-- =========================================================

function procesar_entrada(btn_data)
  local txt = btn_data[1]  
  local tipo = btn_data[2] 
  tocar_sfx(3) -- [CAMBIO SEGURO] Reemplaza el viejo sfx(3) por la función puente

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
    -- PARSEO SEGURO DE FUNCIONES AUSENTES EN API PICO-8 NATIVA
    elseif txt == "ASN" then 
      if val < -1 or val > 1 then v_pantalla = "error" return end
      res = atan2(sqrt(1 - val * val), val) * 360
    elseif txt == "ACS" then 
      if val < -1 or val > 1 then v_pantalla = "error" return end
      res = atan2(val, sqrt(1 - val * val)) * 360
    elseif txt == "ATN" then res = atan2(1, val) * 360
    elseif txt == "PI2" then res = 3.1416 * 3.1416
    elseif txt == "RND" then res = rnd(flr(val) > 0 and flr(val) or 100)
    elseif txt == "SQRT" then 
      if val < 0 then v_pantalla = "error" return else res = sqrt(val) end
    elseif txt == "LN" then 
      if val <= 0 then v_pantalla = "error" return else res = log(val) end
    elseif txt == "LOG" then 
      if val <= 0 then v_pantalla = "error" return else res = log(val) / log(10) end
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
    
    -- REGISTRO CIENTÍFICO EXTENDIDO: Guarda la fórmula + el resultado de forma visible
    if v_pantalla != "error" then
      local operacion_completa = v_historial.."="..v_pantalla
      -- Si el texto es muy largo para el display, lo acortamos de forma segura a 14 caracteres
      if #operacion_completa > 14 then 
        operacion_completa = v_historial.."="..sub(v_pantalla, 1, 5)
      end
      registrar_en_historial(operacion_completa)
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

-- [MEJORA GATO] - FUNCIÓN AISLADA PARA INICIAR EL MINIJUEGO
function iniciar_gato_ranita()
  gato_tablero = {
    {0, 0, 0},
    {0, 0, 0},
    {0, 0, 0}
  }
  gato_cx = 1 gato_cy = 1 -- El cursor empieza en el centro
  gato_turno = 1          -- Inicia el jugador humano
  gato_estado = ""
  gato_cooldown_ia = 0
  modo_actual = 5         -- Saltamos al Estado 5: Pantalla Completa del Gato
end

-- [MEJORA GATO] - LOGICA DE LA CINEMATICA DEL BESO INTERMEDIO
function actualizar_cinematica_beso()
  ani_gato_frames = ani_gato_frames + 1
  estado_beso = 90 -- Mantiene la ranita lanzando besos en el centro
  
  -- La animación central dura 120 frames (2 segundos a 60fps)
  if ani_gato_frames >= 120 then
    ops_totales = 401 -- FIJACIÓN SEGURA EN 401 PARA ROMPER EL BUCLE INFINITO
    dset(1, ops_totales)
    estado_beso = 0
    iniciar_gato_ranita() -- Lanza el minijuego de forma directa
  end
end

-- [MEJORA GATO] - CONTROL DE JUEGO Y MOVIMIENTO EN EL TABLERO DEL GATO
function actualizar_logica_gato()
  -- BOTÓN B: Permite salir del minijuego en cualquier momento y volver a la calculadora
  if btnp(5) then
    modo_actual = 0
    sfx(0)
    return
  end

  -- Si el juego ya terminó (ganó alguien o empate), cualquier pulsación de A reinicia una nueva partida
  if gato_estado != "" and gato_estado != "juzgando" then
    if btnp(4) then iniciar_gato_ranita() end
    return
  end

  -- TURNO DEL USUARIO (gato_turno == 1)
  if gato_turno == 1 then
    if btnp(0) then gato_cx = (gato_cx - 1) % 3 sfx(3) end -- Izquierda
    if btnp(1) then gato_cx = (gato_cx + 1) % 3 sfx(3) end -- Derecha
    if btnp(2) then gato_cy = (gato_cy - 1) % 3 sfx(3) end -- Arriba
    if btnp(3) then gato_cy = (gato_cy + 1) % 3 sfx(3) end -- Abajo

    -- BOTÓN A: Confirmar jugada en casilla vacía
    if btnp(4) then
      if gato_tablero[gato_cy + 1][gato_cx + 1] == 0 then
        gato_tablero[gato_cy + 1][gato_cx + 1] = 1 -- Registra la equis "X"
        sfx(2)
        gato_estado = "juzgando"
        gato_turno = 2
        gato_cooldown_ia = 30 -- La ranita esperará medio segundo antes de tirar para parecer natural
      else
        sfx(1) -- Sonido de error si intenta pulsar una casilla ocupada
      end
    end
  
  -- TURNO DE LA RANITA IA (gato_turno == 2)
  elseif gato_turno == 2 then
    if gato_estado == "juzgando" then
      evaluar_estado_gato()
      if gato_estado != "" then return end -- Si el usuario ganó con su tiro, se detiene
      gato_estado = ""
    end

    if gato_cooldown_ia > 0 then
      gato_cooldown_ia = gato_cooldown_ia - 1
    else
      ejecutar_movimiento_ia()
      gato_estado = "juzgando"
      gato_turno = 1
    end
  end
  
  -- Evaluación constante de fin de turno
  if gato_estado == "juzgando" then
    evaluar_estado_gato()
    if gato_estado == "juzgando" then gato_estado = "" end
  end
end

-- [MEJORA GATO] - INTELIGENCIA ARTIFICIAL MATEMÁTICA DE LA RANITA
function ejecutar_movimiento_ia()
  -- 1. Intentar ganar: Busca si a la ranita le falta una casilla para hacer 3 en línea
  if procesar_bloqueo_o_ataque(2) then sfx(3) return end
  
  -- 2. Intentar bloquear: Busca si al usuario le falta una casilla para ganar y lo tapa
  if procesar_bloqueo_o_ataque(1) then sfx(3) return end

  -- 3. Prioridad estratégica: Tomar el centro si está libre
  if gato_tablero[2][2] == 0 then
    gato_tablero[2][2] = 2
    sfx(3)
    return
  end

  -- 4. Movimiento de respaldo: Buscar la primera casilla vacía disponible de forma secuencial
  for y = 1, 3 do
    for x = 1, 3 do
      if gato_tablero[y][x] == 0 then
        gato_tablero[y][x] = 2
        sfx(3)
        return
      end
    end
  end
end

-- [MEJORA GATO] - REVISIÓN LOGICA DE CASILLAS PARA ATAQUE/DEFENSA DE LA IA
function procesar_bloqueo_o_ataque(id_linea)
  -- Comprobación de líneas horizontales
  for y = 1, 3 do
    local cuenta, vacio_x = 0, 0
    for x = 1, 3 do
      if gato_tablero[y][x] == id_linea then cuenta = cuenta + 1
      elseif gato_tablero[y][x] == 0 then vacio_x = x end
    end
    if cuenta == 2 and vacio_x > 0 then gato_tablero[y][vacio_x] = 2 return true end
  end

  -- Comprobación de líneas verticales
  for x = 1, 3 do
    local cuenta, vacio_y = 0, 0
    for y = 1, 3 do
      if gato_tablero[y][x] == id_linea then cuenta = cuenta + 1
      elseif gato_tablero[y][x] == 0 then vacio_y = y end
    end
    if cuenta == 2 and vacio_y > 0 then gato_tablero[vacio_y][x] = 2 return true end
  end

  -- Diagonal principal (\)
  local c_d1, v_d1 = 0, 0
  for i = 1, 3 do
    if gato_tablero[i][i] == id_linea then c_d1 = c_d1 + 1
    elseif gato_tablero[i][i] == 0 then v_d1 = i end
  end
  if c_d1 == 2 and v_d1 > 0 then gato_tablero[v_d1][v_d1] = 2 return true end

  -- Diagonal inversa (/)
  local c_d2, v_d2 = 0, 0
  for i = 1, 3 do
    if gato_tablero[i][4 - i] == id_linea then c_d2 = c_d2 + 1
    elseif gato_tablero[i][4 - i] == 0 then v_d2 = i end
  end
  if c_d2 == 2 and v_d2 > 0 then gato_tablero[v_d2][4 - v_d2] = 2 return true end

  return false
end

-- [MEJORA GATO] - ARBITRO DEL JUEGO: DETECTA VICTORIAS O EMPATES
function evaluar_estado_gato()
  -- Verificar filas y columnas simultáneamente
  for i = 1, 3 do
    if gato_tablero[i][1] != 0 and gato_tablero[i][1] == gato_tablero[i][2] and gato_tablero[i][1] == gato_tablero[i][3] then
      gato_estado = (gato_tablero[i][1] == 1) and "gana_user" or "gana_ranita"
      return
    end
    if gato_tablero[1][i] != 0 and gato_tablero[1][i] == gato_tablero[2][i] and gato_tablero[1][i] == gato_tablero[3][i] then
      gato_estado = (gato_tablero[1][i] == 1) and "gana_user" or "gana_ranita"
      return
    end
  end

  -- Verificar diagonales
  if gato_tablero[1][1] != 0 and gato_tablero[1][1] == gato_tablero[2][2] and gato_tablero[1][1] == gato_tablero[3][3] then
    gato_estado = (gato_tablero[1][1] == 1) and "gana_user" or "gana_ranita"
    return
  end
  if gato_tablero[1][3] != 0 and gato_tablero[1][3] == gato_tablero[2][2] and gato_tablero[1][3] == gato_tablero[3][1] then
    gato_estado = (gato_tablero[1][3] == 1) and "gana_user" or "gana_ranita"
    return
  end

  -- Si no hay ganador, verificar si el tablero se llenó por completo (Empate)
  local llenas = 0
  for y = 1, 3 do
    for x = 1, 3 do
      if gato_tablero[y][x] != 0 then llenas = llenas + 1 end
    end
  end
  if llenas == 9 then gato_estado = "empate" end
end

-- [MEJORA GATO] - DIBUJO DE LA RANITA GIGANTE LANZANDO UN BESO (CENTRO DE PANTALLA)
function render_cinematica_beso_central(c_fondo)
  cls(c_fondo)
  
  -- Dibujamos un marco decorativo de felicitaciones
  rect(2, 2, 125, 125, 10)
  rectfill(4, 4, 123, 14, 0)
  print("Xtree reward!", 32, 7, 7)
  
  -- Escalamos la posición de la ranita a casi la mitad de la resolución (Centro)
  local rx = 58
  local ry = 54 + flr(sin(ranita_anim / 30) * 2) -- Oscilación un poco más rápida para denotar emoción
  
  -- Renderizamos la ranita usando el motor emocional que ya programaste en la Parte 5
  -- Al estar en un frame intermedio, estado_beso > 0 pintará los ojos felices y la boca de beso
  render_ranita_xtree(rx, ry)
  
  -- Mensaje emergente para el usuario
  print("thanks for using", 32, 94, 7)
  print("the calculator! <3", 28, 103, 11)
end

-- [MEJORA GATO] - DIBUJO DE LA INTERFAZ COMPLETA DEL GATO ADAPTADA AL TEMA
function render_pantalla_gato(c_fondo, c_display, c_txt_dis, c_btn_bse, c_btn_txt)
  cls(c_fondo)
  
  -- 1. Encabezado del Minijuego
  rectfill(0, 0, 127, 13, c_display)
  line(0, 13, 127, 13, c_btn_txt)
  print("AI frog cat", 38, 4, c_txt_dis)
  
  -- Indicador de Turno o Estado de Fin de Juego
  if gato_estado == "gana_user" then
    print("You won!", 40, 18, 11)
  elseif gato_estado == "gana_ranita" then
    print("the little frog won", 36, 18, 8)
  elseif gato_estado == "empate" then
    print("draw!", 48, 18, 5)
  else
    if gato_turno == 1 then
      print("your turn (x)", 42, 18, c_btn_txt)
    else
      print("thinking...", 44, 18, 6)
    end
  end

  -- 2. Renderizado de las Líneas del Tablero ($3\times3$)
  local ox, oy = 34, 32  -- Coordenadas de origen del tablero
  local cs = 20          -- Tamaño de cada casilla (20x20 píxeles)
  
  -- Líneas de la cuadrícula usando el color de base del botón
  line(ox + cs, oy, ox + cs, oy + cs * 3, c_btn_bse)
  line(ox + cs * 2, oy, ox + cs * 2, oy + cs * 3, c_btn_bse)
  line(ox, oy + cs, ox + cs * 3, oy + cs, c_btn_bse)
  line(ox, oy + cs * 2, ox + cs * 3, oy + cs * 2, c_btn_bse)

  -- 3. Dibujo de las Jugadas (X y O) y el Cursor de Selección
  for y = 0, 2 do
    for x = 0, 2 do
      local bx = ox + x * cs
      local by = oy + y * cs
      local casilla = gato_tablero[y + 1][x + 1]
      
      -- Dibujar cursor parpadeante si es el turno del usuario sobre esa casilla
      if x == gato_cx and y == gato_cy and gato_turno == 1 and gato_estado == "" then
        if ranita_anim % 20 < 10 then
          rect(bx + 2, by + 2, bx + cs - 2, by + cs - 2, 10)
        end
      end
      
      -- Renderizar las figuras
      if casilla == 1 then
        -- Dibujar Equis (X) en color de texto del display
        line(bx + 5, by + 5, bx + cs - 5, by + cs - 5, c_txt_dis)
        line(bx + cs - 5, by + 5, bx + 5, by + cs - 5, c_txt_dis)
      elseif casilla == 2 then
        -- Dibujar Círculo (O) en color adaptativo de la ranita (Color 11)
        rect(bx + 5, by + 5, bx + cs - 5, by + cs - 5, 11)
      end
    end
  end

  -- 4. Barra de Estado Inferior y Controles
  rectfill(0, 100, 127, 127, 0)
  line(0, 100, 127, 100, 6)
  
  if gato_estado != "" and gato_estado != "juzgando" then
    local c_p = (ranita_anim < 30) and 11 or 7
    print("press A: play again", 16, 105, c_p)
    print("press b: return to calc", 14, 115, 5)
  else
    print("\x8b\x91\x94\x83:move to A: confirm", 4, 105, 7)
    print("Press b: exit to the calculator", 14, 115, 5)
  end

  -- Pintamos a la ranita en la esquina del menú inferior manteniendo su estado emocional actual
  render_ranita_xtree(114, 114)
end
