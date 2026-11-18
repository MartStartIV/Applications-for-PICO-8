pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.06]
-- PARTE 1 DE 4: NÚCLEO DE INICIALIZACIÓN Y CONTROL DE FLUX
-- =========================================================

function _init()
  id_nombre = "ADD NOTES XTREE"
  id_version = "V0.06"
  
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

  -- =========================================================
  -- EXTENSIÓN MAPEO Y TESTEO DE BOTONES [SEGURA PARA PICANTE8]
  -- =========================================================
  sub_btn_abierta = false      -- controla si la subventana de botones está activa
  sub_btn_cursor = 1         -- 1 = selector tecla abc/123, 2 = aplicar, 3 = rechazar
  btn_teclado_modo = 0       -- 0 = L1/R1 (default), 1 = L1 (p2_b4), 2 = R1 (p2_b5), 3 = Select (p2_b2)
  btn_teclado_temp = 0       -- copia temporal mientras se edita antes de aplicar/rechazar
  ultimo_btn_reg = "ninguno" -- reporte técnico del último botón presionado
  ultimo_btn_col = 5         -- color dinámico del indicador técnico
  
  -- =========================================================
  -- EXTENSIÓN AUTOCOMPLETADO LIGERO POR IDIOMA [BAJO CONSUMO]
  -- =========================================================
  config_autocomp = 0        -- 0 = off (default), 1 = on
  sugerencia_actual = ""     -- fragmento restante sugerido
  config_alm_plus = 0        -- 0 = clásico (default), 1 = almacenamiento extra plus (5x)
  aviso_plus_abierto = false -- controla la ventana emergente de confirmación
  aviso_plus_cursor = 2      -- 1 = aceptar, 2 = cancelar (por seguridad empieza en cancelar)

  -- Mini-diccionario extendido (85 palabras clave por idioma = solo 11 tokens en total)
  dict_autocomp = {
    -- 1. Español (es)
    "hola como estas bien gracias hoy manana ayer dia noche semana mes ano nota lista tarea idea cita clave codigo cuenta banco pago dinero precio compra venta casa cuarto cocina bano calle ciudad viaje coche tren avion trabajo oficina escuela clase libro proyecto amigo familia madre padre hermano hijo perro gato juego consola bateria pantalla boton tarjeta archivo musica foto video tiempo hora minuto bueno malo nuevo viejo grande pequeno todo nada siempre nunca aqui alli hacer decir ir ver dar saber querer poder poner tener llamar pagar recordar buscar guardar borrar abrir cerrar feliz listo",
    -- 2. English (en)
    "hello how are you good thanks today tomorrow yesterday day night week month year note list task idea meeting password code account bank payment money price buy sell home room kitchen bath street city trip car train plane work office school class book project friend family mother father brother son dog cat game console battery screen button card file music photo video time hour minute nice bad new old big small all nothing always never here there make say go see give know want can put have call pay remember search save delete open close happy ready",
    -- 3. Polski (pl)
    "czesc jak sie masz dobrze dzieki dzisiaj jutro wczoraj dzien noc tydzien miesiac rok notatka lista zadanie pomysl spotkanie haslo kod konto bank platnosc pieniadze cena zakup sprzedaz dom pokoj kuchnia lazienka ulica miasto podroz auto pociag samolot praca biuro szkola lekcja ksiazka projekt przyjaciel rodzina matka ojciec brat syn pies kot gra konsola bateria ekran przycisk karta plik muzyka zdjecie wideo czas godzina minuta dobry zly nowy stary duzy maly wszystko nic zawsze nigdy tutaj tam zrobic powiedziec isc widziec dac wiedziec chciec moc polozyc miec zadzwonic zaplacic pamietac szukac zapisac usunac otworzyc zamknac szczesliwy gotowy",
    -- 4. Russian (ru)
    "privet kak dela horosho spasibo segodnya zavtra vchera den noch nedelya mesyac god zametka spisok zadacha ideya vstrecha parol kod schet bank platezh dengi cena pokupka prodazha dom komnata kuhnya vannaya ulica gorod poezdka mashina poezd samolet rabota ofis shkola urok kniga proekt drug semya mama papa brat syn sobaka koshka igra konsol batareya ekran knopka karta fajl muzyka foto video vremya chas minuta ploho novyj staryj bolshoj malenkij vse nichego vsegda nikogda zdes tam sdelat skazat idti videt dat znat hotet moch polozhit imet pozvonit zaplatit pomnit iskat sohranit udalit otkryt zakryt schastlivyj gotov",
    -- 5. Português (pt)
    "ola como esta bem obrigado hoje amanha ontem dia noite semana mes ano nota lista tarefa ideia encontro senha codigo conta banco pagamento dinheiro preco compra venda casa quarto cozinha banheiro rua cidade viagem carro trem aviao trabalho escritorio escola aula livro projeto amigo familia mae pai irmao filho cachorro gato jogo console bateria tela botao cartao arquivo musica foto video tempo hora minuto bom ruim novo velho grande pequeno tudo nada sempre nunca aqui ali fazer dizer ir ver dar saber querer poder por ter ligar pagar lembrar buscar salvar apagar abrir fechar feliz pronto",
    -- 6. Italiano (it)
    "ciao come stai bene grazie oggi domani ieri giorno notte settimana mese anno nota lista compito idea appuntamento password codice conto banca pagamento soldi prezzo acquisto vendita casa stanza cucina bagno strada citta viaggio auto treno aereo lavoro ufficio scuola lezione libro progetto amico famiglia madre padre fratello figlio cane gatto gioco console batteria schermo tasto scheda file musica foto video tempo ora minuto bello brutto nuovo vecchio grande piccolo tutto niente sempre mai qui li fare dire andare vedere dare sapere volere potere mettere avere chiamare pagare ricordare cercare salvare eliminare aprire chiudere felice pronto",
    -- 7. Français (fr)
    "salut comment vas bien merci aujourd demain hier jour nuit semaine mois annee note liste tache idee rendez motdepasse code compte banque paiement argent prix achat vente maison chambre cuisine bain rue ville voyage voiture train avion travail bureau ecole cours livre projet ami famille mere pere frere fils chien chat jeu console batterie ecran bouton carte fichier musique photo video temps heure minute bon mauvais nouveau vieux grand petit tout rien toujours jamais ici la faire dire aller voir donner savoir vouloir pouvoir mettre avoir appeler payer rappeler chercher garder effacer ouvrir fermer heureux pret",
    -- 8. Nihongo (jp)
    "konnichiwa genki arigatou kyou ashita kinou hi yoru shuu tsuki toshi memo risuto shukudai aidea yotei pasuwaado koodo kouza ginkou shiharai okane nedan kaimono hanbai ie heya daidokoro ofuro michi machi ryokou kuruma densha hikouki shigoto jimusho gakkou jugyou hon purojekuto tomodachi kazoku haha chichi ani musuko inu neko geemu konsoru denchi gamen botan kaado fairu ongaku shashin douga jikan jikanmai fun ii warui atarashii furui ookii chiisai subete nanimo itsumo kesshite koko soko suru iu iku miru ageru shiru hoshii dekiru oku motsu denwa harau oboeru sagasu hozon sakujo akeru shimeru ureshii junbi",
    -- 9. Zhongwen (cn)
    "nihao zenme hao xiexie jintian mingtian zuotian tian wanshang xingqi yue nian biji qingdan renwu xiangfa yuehui mima daima zhanghu yinhang fukuan qian jiage goumai chushou jia fangjian chufang yushi jiedao chengshi luxing qiche huoche feiji gongzuo bangongshi xuexiao kecheng shu xiangmu pengyou jiaren mama baba xiongdi erzi gou mao youxi zhuji dianchi pingmu anjian kapian wenjian yinyue zhaopian shipin shijian xiaoshi fenzhong bucuo huai xin jiu da xiao quanbu meiyou zongshi conglai zheli nali zuo shuo qu kan gei zhidao xiang neng fang you dadianhua fuqian jizhu xunzhao baocun shanchu dakai guanbi kaixin zhunbei",
    -- 10. Hangugeo (kr)
    "annyeong eotteohge johayo gamsa oneul naeil eoje nal bam ju dal nyeon memo mogrog gwaje aidea yaksok bimilbeonho kodeu gyejwa eunhaeng gyeolje don gagyeok gumae panmae jip bang bueok hwadangsil geori dosi yeohaeng jadongcha gicha bihaenggi il samusil hakgyo sueop chaek peurojekteu chingu gajok eomma appa hyeongje adeul gae goyangi geim konsol baeteori hwamyeon beoteun kadeu pail eumak sajin bideo sigan siganmae bun joheun nappeun sae oraedoen keun jageun modeun amugeotdo hangsang jeoldae yeogi jeogi hada malhada gada boda juda alda wonhada halnohda gajida jeonhwa naeda gieok chatda jeojang sakje yeolda datda haengbok junbi",
    -- 11. Turkce (tr)
    "merhaba nasilsin iyiyim tesekkur bugun yarin dun gun gece hafta ay yil not liste gorev fikir randevu sifre kod hesap banka odeme para fiyat alis satis ev oda mutfak banyo sokak sehir gezi araba tren ucak is ofis okul ders kitap proje arkadas aile anne baba kardes ogul kopek kedi oyun konsol pil ekran tus kart dosya muzik fotograf video zaman saat dakika guzel kotu yeni eski buyuk kucuk hersey hicbir herzaman asla burada orada yapmak soylemek gitmek gormek vermek bilmek istemek edebilmek koymak sahip aramak odemek hatirla aramak kaydet silmek acmak kapatmak mutlu hazir"
  }  
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
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.06]
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
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.06]
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
  
  print("ADD NOTES XTREE V0.06", 4, 3, c_txt_dis)
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

function obtener_sugerencia_palabra()
  if config_autocomp != 1 then return "" end
  local txt = sub(texto_nota_buffer or "", 1, cursor_texto_pos - 1)
  if #txt == 0 then return "" end

  local palabra = ""
  for i = #txt, 1, -1 do
    local ch = sub(txt, i, i)
    if ch == " " then break end
    palabra = ch .. palabra
  end
  if #palabra < 1 then return "" end

  local dic = dict_autocomp[idioma_actual] or ""
  local actual = ""
  for i = 1, #dic + 1 do
    local ch = (i <= #dic) and sub(dic, i, i) or " "
    if ch == " " then
      if #actual > #palabra and sub(actual, 1, #palabra) == palabra then
        return sub(actual, #palabra + 1)
      end
      actual = ""
    else
      actual = actual .. ch
    end
  end
  return ""
end


function actualizar_teclado_virtual()
  -- 1. Evaluar salida o combos B + Dirección
  if btn_teclado_modo == 0 then
    if btnp(5) or stat(30) == 14 then
      modo_actual = 2
      cursor_menu = 1
      bloqueo_a = false
      cooldown_teclado = 10
      return
    end
  else
    local b_presionado = btn(5) or stat(30) == 14
    local gatillo_capa = false

    if btn_teclado_modo == 1 and b_presionado and btnp(2) then
      gatillo_capa = true
      combo_b_usado = true
    elseif btn_teclado_modo == 2 and b_presionado and btnp(3) then
      gatillo_capa = true
      combo_b_usado = true
    elseif btn_teclado_modo == 3 and b_presionado and btnp(0) then
      gatillo_capa = true
      combo_b_usado = true
    elseif btn_teclado_modo == 4 and b_presionado and btnp(1) then
      gatillo_capa = true
      combo_b_usado = true
    end

    if gatillo_capa then
      if teclado_mapa == teclado_mapa_letras then
        teclado_mapa = teclado_mapa_simbolos
      else
        teclado_mapa = teclado_mapa_letras
      end
      return
    end

    if b_presionado then
      b_estaba_activo = true
      return
    elseif b_estaba_activo then
      b_estaba_activo = false
      if not combo_b_usado then
        modo_actual = 2
        cursor_menu = 1
        bloqueo_a = false
        cooldown_teclado = 10
        return
      end
      combo_b_usado = false
    end
  end

  -- 2. Movimiento por cuadrícula (6 filas normal, 7 filas si autocompletado está ON)
  local max_filas = (config_autocomp == 1) and 7 or 6
  if btnp(0) and teclado_cy < 6 then teclado_cx = (teclado_cx - 1) % teclado_max_cx end
  if btnp(1) and teclado_cy < 6 then teclado_cx = (teclado_cx + 1) % teclado_max_cx end
  if btnp(2) then teclado_cy = (teclado_cy - 1) % max_filas end
  if btnp(3) then teclado_cy = (teclado_cy + 1) % max_filas end

  -- 3. Selección con botón A
  if (btn(4) or stat(30) == 13) and not (btn(5) or stat(30) == 14) then
    if not bloqueo_a then
      bloqueo_a = true 
      
      if config_autocomp == 1 and teclado_cy == 6 then
        if #sugerencia_actual > 0 then
          local comp = sugerencia_actual .. " "
          for j = 1, #comp do
            procesar_caracter_seguro(sub(comp, j, j))
          end
        end
      else
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
    end
  else
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
    cooldown_teclado = 10 -- Escudo de 10 frames contra rebote tras escribir en SD
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
  
  sugerencia_actual = obtener_sugerencia_palabra()
  local preview_sug = (config_autocomp == 1 and #sugerencia_actual > 0) and ("[" .. sugerencia_actual .. "]") or ""
  
  if #texto_imprimir + #preview_sug > 28 then
    texto_imprimir = sub(texto_imprimir, max(1, #texto_imprimir + #preview_sug - 28))
  end
  
  print(texto_imprimir, 6, 6, c_txt_dis)
  if #preview_sug > 0 then
    print(preview_sug, 6 + (#texto_imprimir * 4), 6, 6)
  end
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

  if config_autocomp == 1 then
    local auto_lbls = {
      "autocomp", -- 1. es
      "autocomp", -- 2. en
      "uzupeln.", -- 3. pl
      "avtodop.", -- 4. ru
      "autocomp", -- 5. pt
      "autocomp", -- 6. it
      "autocomp", -- 7. fr
      "hokan",    -- 8. jp
      "buquan",   -- 9. cn
      "wanseong", -- 10. kr
      "tamamla"   -- 11. tr
    }
    local pref_auto = auto_lbls[idioma_actual] or "autocomp"
    local ty_extra = 103
    local lbl_auto = (#sugerencia_actual > 0) and (pref_auto .. ": +" .. sugerencia_actual) or (pref_auto .. ": ---")
    
    if teclado_cy == 6 then
      rectfill(8, ty_extra, 119, ty_extra + 9, c_btn_txt)
      print(lbl_auto, 12, ty_extra + 2, c_btn_bse)
    else
      rectfill(8, ty_extra, 119, ty_extra + 9, c_btn_bse)
      rect(8, ty_extra, 119, ty_extra + 9, c_display)
      print(lbl_auto, 12, ty_extra + 2, (#sugerencia_actual > 0) and 10 or c_txt_dis)
    end
  end
  
  local mat_lang = textos_sistema[idioma_actual]
  local i13, i14 = 13, 14
  local txt_salir = mat_lang[i14]
  local txt_gdr = mat_lang[i13]
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
    t_ver .. " v0.06",
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

-- Convierte 5 IDs de carácter (0..61) en un único número de 32 bits de PICO-8
function empaquetar_5_chars(c1, c2, c3, c4, c5)
  -- Los 16 bits altos (enteros, 0..32767) guardan c1 (6 bits), c2 (6 bits) y 3 bits de c3
  local c3_alto = flr(c3 / 8)
  local c3_bajo = c3 % 8
  local parte_entera = c1 + (c2 * 64) + (c3_alto * 4096)
  -- Los 16 bits bajos (fraccionarios / 65536) guardan 3 bits de c3, c4 (6 bits) y c5 (6 bits)
  local parte_frac = (c3_bajo + (c4 * 8) + (c5 * 512)) / 65536
  return parte_entera + parte_frac
end

-- Extrae los 5 IDs de carácter (0..61) desde un número de 32 bits de PICO-8
function desempaquetar_5_chars(val)
  local v = val or 0
  if v < 0 then v = 0 end
  local parte_entera = flr(v)
  local parte_frac = flr((v - parte_entera) * 65536 + 0.5)

  local c1 = parte_entera % 64
  local c2 = flr(parte_entera / 64) % 64
  local c3_alto = flr(parte_entera / 4096) % 8

  local c3_bajo = parte_frac % 8
  local c4 = flr(parte_frac / 8) % 64
  local c5 = flr(parte_frac / 512) % 64

  local c3 = (c3_alto * 8) + c3_bajo
  return c1, c2, c3, c4, c5
end


function guardar_todo_en_sd()
  pcall(function()
    dset(0, idioma_actual)
    dset(1, perfil_sexo)
    dset(2, idx_tema)
    dset(3, #lista_notas)
    
    local empaquetado_config = config_zoom + (config_motivacion * 10) + (btn_teclado_modo * 100) + (config_autocomp * 1000) + (config_alm_plus * 10000)
    dset(4, empaquetado_config)
    
    if config_alm_plus == 1 then
      -- MOTOR PLUS COMPRIMIDO (5 caracteres por slot desde el Slot 5)
      local puntero_slot = 5
      for i = 1, total_notas_permitidas do
        if i <= #lista_notas then
          local nota_str = lista_notas[i]
          local largo = #nota_str
          dset(puntero_slot, largo)
          puntero_slot = puntero_slot + 1

          local ids = {}
          for c = 1, largo do
            local letra = sub(nota_str, c, c)
            local id_char = 1
            for k = 1, #comp_dict do
              if comp_dict[k] == letra then
                id_char = k
                break
              end
            end
            add(ids, id_char)
          end

          for b = 1, largo, 5 do
            local v1 = ids[b] or 0
            local v2 = ids[b + 1] or 0
            local v3 = ids[b + 2] or 0
            local v4 = ids[b + 3] or 0
            local v5 = ids[b + 4] or 0
            dset(puntero_slot, empaquetar_5_chars(v1, v2, v3, v4, v5))
            puntero_slot = puntero_slot + 1
          end
        else
          dset(puntero_slot, 0)
          puntero_slot = puntero_slot + 1
        end
      end
    else
      -- MOTOR CLÁSICO ORIGINAL (1 carácter por slot desde el Slot 10)
      for i = 1, total_notas_permitidas do
        local slot_base = 10 + (i - 1) * 130
        if i <= #lista_notas then
          local nota_str = lista_notas[i]
          dset(slot_base, #nota_str)
          for c = 1, #nota_str do
            local letra = sub(nota_str, c, c)
            local id_char = 1
            for k = 1, #comp_dict do
              if comp_dict[k] == letra then 
                id_char = k 
                break 
              end
            end
            dset(slot_base + c, id_char)
          end
        else
          dset(slot_base, 0)
        end
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
    local total_g = dget(3) or 0
    if total_g < 0 or total_g > total_notas_permitidas then total_g = 0 end
    
    local empaquetado_config = dget(4) or 0
    config_zoom = empaquetado_config % 10
    config_motivacion = flr((empaquetado_config % 100) / 10)
    btn_teclado_modo = flr((empaquetado_config % 1000) / 100)
    config_autocomp = flr((empaquetado_config % 10000) / 1000)
    config_alm_plus = flr(empaquetado_config / 10000)
    
    if config_zoom < 0 or config_zoom > 1 then config_zoom = 0 end
    if config_motivacion < 0 or config_motivacion > 1 then config_motivacion = 0 end
    if btn_teclado_modo < 0 or btn_teclado_modo > 4 then btn_teclado_modo = 0 end
    if config_autocomp < 0 or config_autocomp > 1 then config_autocomp = 0 end
    if config_alm_plus < 0 or config_alm_plus > 1 then config_alm_plus = 0 end
    
    if config_alm_plus == 1 then
      -- LECTURA MOTOR PLUS COMPRIMIDO (Slot 5+)
      local puntero_slot = 5
      for i = 1, total_g do
        local largo = dget(puntero_slot) or 0
        puntero_slot = puntero_slot + 1
        if largo < 0 or largo > 120 then largo = 0 end

        local texto_reconstruido = ""
        local bloques = flr((largo + 4) / 5)
        for b = 1, bloques do
          local c1, c2, c3, c4, c5 = desempaquetar_5_chars(dget(puntero_slot))
          puntero_slot = puntero_slot + 1
          local grupo = {c1, c2, c3, c4, c5}
          for g = 1, 5 do
            if #texto_reconstruido < largo then
              local id_c = grupo[g]
              if id_c >= 1 and id_c <= #comp_dict then
                texto_reconstruido = texto_reconstruido .. comp_dict[id_c]
              else
                texto_reconstruido = texto_reconstruido .. " "
              end
            end
          end
        end
        add(lista_notas, texto_reconstruido)
      end
    else
      -- LECTURA MOTOR CLÁSICO ORIGINAL (Slot 10+)
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
        add(lista_notas, texto_reconstruido)
      end
    end
    
    modo_actual = 2 
  else
    modo_actual = 0 
  end
end

function actualizar_opciones_adicionales()
  if sub_btn_abierta then
    actualizar_subventana_botones()
    return
  end

  if aviso_plus_abierto then
    actualizar_aviso_alm_plus()
    return
  end

  if btnp(2) then config_cursor = config_cursor - 1 if config_cursor < 1 then config_cursor = 7 end end
  if btnp(3) then config_cursor = config_cursor + 1 if config_cursor > 7 then config_cursor = 1 end end

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
      btn_teclado_modo = 0
      config_autocomp = 0
      config_alm_plus = 0
      config_abierta = false
      modo_actual = 0 
      return
    end

  elseif config_cursor == 5 then
    if btnp(4) or stat(30) == 13 then
      sub_btn_abierta = true
      sub_btn_cursor = 1
      btn_teclado_temp = btn_teclado_modo
      ultimo_btn_reg = "esperando..."
      ultimo_btn_col = 5
      bloqueo_a = true
      return
    end

  elseif config_cursor == 6 then
    if btnp(0) or btnp(1) then
      config_autocomp = (config_autocomp == 0) and 1 or 0
    end

  elseif config_cursor == 7 then
    -- Abre confirmación antes de cambiar entre Clásico y Alm. Plus
    if btnp(0) or btnp(1) or btnp(4) or stat(30) == 13 then
      aviso_plus_abierto = true
      aviso_plus_cursor = 2 -- Por seguridad inicia seleccionado en "cancelar"
      bloqueo_a = true
      return
    end
  end
end


function actualizar_aviso_alm_plus()
  -- Si pulsa B, cancela y vuelve a la ventana de configuraciones adicionales
  if btnp(5) or stat(30) == 14 then
    aviso_plus_abierto = false
    bloqueo_a = false
    return
  end

  if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
    aviso_plus_cursor = (aviso_plus_cursor == 1) and 2 or 1
  end

  if btn(4) or stat(30) == 13 then
    if not bloqueo_a then
      bloqueo_a = true
      if aviso_plus_cursor == 1 then
        -- ACEPTAR: Limpia notas incompatibles, guarda el cambio y vuelve al menú principal
        lista_notas = {}
        config_alm_plus = (config_alm_plus == 0) and 1 or 0
        pcall(function()
          for s = 5, 1310 do dset(s, 0) end
        end)
        guardar_todo_en_sd()
        aviso_texto = "ok!"
        aviso_timer = 35
        aviso_plus_abierto = false
        config_abierta = false
        cursor_menu = 1
        cooldown_teclado = 10
      else
        -- CANCELAR: Cierra solo el aviso y regresa a configuraciones adicionales
        aviso_plus_abierto = false
      end
    end
  else
    bloqueo_a = false
  end
end

function render_ventana_opciones_adicionales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  local t_config = {
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacion", "formatear", "si", "no", "b: salir/grv", "map/test btn", "autocomplet.", "alm. plus"},
    {"extra cfgs",   "text zoom",  "lang/idioma", "motivation", "wipe clear", "yes","no", "b: exit/save", "btn map/test", "autocomplete", "storage plus"},
    {"cfg. dodatk",  "zoom tekstu", "jezyk/lang", "motywacja",  "czyszczenie", "tak","nie","b: wyjdz/zap", "map/test btn", "autouzupeln.", "pamiec plus"},
    {"dop. nastr",   "masshtab",   "yazik/lang",  "motivaciya", "ochistka",   "da", "net","b: vyhod/shran","test knopok",  "avtodopoln.",  "pamyat plus"},
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacao",  "formatar",   "sim","nao","b: sair/salv", "map/test btn", "autocomplet.", "armaz. plus"},
    {"cfg. extra",   "zoom testo", "lingua/lang", "motivazione","formatta",   "si", "no", "b: esci/salv", "map/test btn", "autocomplet.", "memoria plus"},
    {"cfg. extras",  "zoom texte", "langue/lang", "motivation", "effacer to", "oui","non","b: sortir/grd", "map/test btn", "autocomplet.", "stock. plus"},
    {"sono hoka",    "moji zoom",  "gengo/lang",  "douki zuke", "shokika",    "hai","iie","b: modoru/hoz", "btn map/test", "jidou hokan",  "hozon plus"},
    {"geng duo she", "zi ti da xiao","yu yan/lang","ji li",       "qing chu",   "shi","fou","b: tui chu/bao","anjian ceshi", "zidong buquan","cunchu plus"},
    {"gita seolt",   "geulja zoom","eoneo/lang",  "donggi buyeo","gongjang ch","ye", "ani","b: nagagi/jeo", "beoteun teseu","jadong wanseo","jeojang plus"},
    {"ek ayarlar",   "metin zoomu", "dil/lang",    "motivasyon", "sifirla",    "evet","hayir","b: cikis/kayd","tus test/ayar","otomatik tam.","depolama plus"}
  }

  local m_data = t_config[idioma_actual]
  local k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11 = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
  local vx, vy, vw, vh = 12, 4, 104, 120
  
  rectfill(vx, vy, vx + vw, vy + vh, 0)         
  rect(vx, vy, vx + vw, vy + vh, c_btn_bse)     
  rectfill(vx + 2, vy + 2, vx + vw - 2, vy + 10, c_display) 
  print(m_data[k1], vx + 6, vy + 3, c_txt_dis)   
  
  -- Fila 1: Zoom de letra
  local ly1 = vy + 14
  if config_cursor == 1 then rectfill(vx + 4, ly1 - 1, vx + vw - 4, ly1 + 6, c_btn_bse) end
  print(m_data[k2] .. ":", vx + 6, ly1, config_cursor == 1 and c_btn_txt or c_txt_dis)
  print(config_zoom == 1 and "on" or "off", vx + 80, ly1, config_zoom == 1 and 10 or 8)
  
  -- Fila 2: Idioma rápido
  local ly2 = vy + 26
  if config_cursor == 2 then rectfill(vx + 4, ly2 - 1, vx + vw - 4, ly2 + 6, c_btn_bse) end
  print(m_data[k3] .. ":", vx + 6, ly2, config_cursor == 2 and c_btn_txt or c_txt_dis)
  print("<" .. codigos_idioma[idioma_actual] .. ">", vx + 74, ly2, 11)
  
  -- Fila 3: Motivación
  local ly3 = vy + 38
  if config_cursor == 3 then rectfill(vx + 4, ly3 - 1, vx + vw - 4, ly3 + 6, c_btn_bse) end
  print(m_data[k4] .. ":", vx + 6, ly3, config_cursor == 3 and c_btn_txt or c_txt_dis)
  print(config_motivacion == 1 and "on" or "off", vx + 80, ly3, config_motivacion == 1 and 10 or 8)
  
  -- Fila 4: Formateo de Fábrica
  local ly4 = vy + 50
  if config_cursor == 4 then rectfill(vx + 4, ly4 - 1, vx + vw - 4, ly4 + 6, c_btn_bse) end
  print(m_data[k5], vx + 6, ly4, config_cursor == 4 and c_btn_txt or 8)
  if confirma_borrado then
    rectfill(vx + 76, ly4 - 1, vx + 98, ly4 + 5, 8) 
    print(m_data[k6], vx + 78, ly4, 7)
  else
    rectfill(vx + 76, ly4 - 1, vx + 98, ly4 + 5, 12) 
    print(m_data[k7], vx + 78, ly4, 7)
  end

  -- Fila 5: Mapeo y Testeo Técnico de Botones
  local ly5 = vy + 62
  if config_cursor == 5 then rectfill(vx + 4, ly5 - 1, vx + vw - 4, ly5 + 6, c_btn_bse) end
  print(m_data[k9], vx + 6, ly5, config_cursor == 5 and c_btn_txt or 11)
  print("[>]", vx + 84, ly5, config_cursor == 5 and c_btn_txt or 10)

  -- Fila 6: Autocompletado
  local ly6 = vy + 74
  if config_cursor == 6 then rectfill(vx + 4, ly6 - 1, vx + vw - 4, ly6 + 6, c_btn_bse) end
  print(m_data[k10] .. ":", vx + 6, ly6, config_cursor == 6 and c_btn_txt or c_txt_dis)
  print(config_autocomp == 1 and "on" or "off", vx + 80, ly6, config_autocomp == 1 and 10 or 8)

  -- Fila 7: Almacenamiento Extra Plus
  local ly7 = vy + 86
  if config_cursor == 7 then rectfill(vx + 4, ly7 - 1, vx + vw - 4, ly7 + 6, c_btn_bse) end
  print(m_data[k11] .. ":", vx + 6, ly7, config_cursor == 7 and c_btn_txt or 10)
  print(config_alm_plus == 1 and "on" or "off", vx + 80, ly7, config_alm_plus == 1 and 10 or 8)
  
  print(m_data[k8], vx + 14, vy + 106, 6)

  if sub_btn_abierta then
    render_subventana_botones(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  end

  if aviso_plus_abierto then
    render_aviso_alm_plus()
  end
end


function render_aviso_alm_plus()
  local t_aviso = {
    {"atencion!", "las notas previas", "dejaran de verse", "y se borraran.", "aceptar", "cancelar"},   -- 1. es
    {"warning!",  "previous notes",    "will no longer be", "visible & erased.", "accept", "cancel"},    -- 2. en
    {"uwaga!",    "poprzednie notatki","przestana byc",     "widoczne/usuniete.","akceptuj","anuluj"},    -- 3. pl
    {"vnimanie!", "starye zametki",    "budut nedostupny",  "i udalyatsya.",    "prinyat", "otmena"},    -- 4. ru
    {"atencao!",  "as notas antigas",  "deixarao de ser",   "vistas e apagadas.","aceitar", "cancelar"},  -- 5. pt
    {"attenz.!",  "le note precedenti","non saranno piu",   "visibili/cancell.","accetta", "annulla"},   -- 6. it
    {"attention!","les notes actuelles","ne seront plus",    "visibles/effacees.","accepter","annuler"},   -- 7. fr
    {"chuui!",    "ima made no memo",  "wa mienaku nari",   "sakujo saremasu.", "doui",    "chuushi"},   -- 8. jp
    {"jinggao!",  "zhiqian de biji",   "jiang wufa xianshi","bing bei shanchu.","queding", "quxiao"},    -- 9. cn
    {"juui!",     "ijeon memoneun",    "boiji anhge doemyeo","sakje doemnida.",  "surok",   "chwiso"},    -- 10. kr
    {"dikkat!",   "onceki notlar",     "gorunmeyecek ve",   "silinecektir.",    "kabul",   "iptal"}      -- 11. tr
  }

  local a_data = t_aviso[idioma_actual]
  local p1, p2, p3, p4, p5, p6 = 1, 2, 3, 4, 5, 6
  local ax, ay, aw, ah = 10, 26, 108, 76

  rectfill(ax, ay, ax + aw, ay + ah, 0)
  rect(ax, ay, ax + aw, ay + ah, 8)
  rectfill(ax + 2, ay + 2, ax + aw - 2, ay + 11, 8)
  print(a_data[p1], ax + 6, ay + 4, 7)

  print(a_data[p2], ax + 6, ay + 18, 7)
  print(a_data[p3], ax + 6, ay + 27, 7)
  print(a_data[p4], ax + 6, ay + 36, 10)

  local y_btn = ay + 53
  -- Botón ACEPTAR (1)
  local c1_x = ax + 29 - (#a_data[p5] * 2)
  if aviso_plus_cursor == 1 then
    rectfill(ax + 6, y_btn, ax + 52, y_btn + 11, 8)
    print(a_data[p5], c1_x, y_btn + 3, 7)
  else
    rect(ax + 6, y_btn, ax + 52, y_btn + 11, 8)
    print(a_data[p5], c1_x, y_btn + 3, 8)
  end

  -- Botón CANCELAR (2)
  local c2_x = ax + 79 - (#a_data[p6] * 2)
  if aviso_plus_cursor == 2 then
    rectfill(ax + 56, y_btn, ax + 102, y_btn + 11, 11)
    print(a_data[p6], c2_x, y_btn + 3, 0)
  else
    rect(ax + 56, y_btn, ax + 102, y_btn + 11, 3)
    print(a_data[p6], c2_x, y_btn + 3, 11)
  end
end



-- =========================================================
-- LÓGICA DE SUBVENTANA: MAPEO Y TESTEO TÉCNICO DE BOTONES
-- =========================================================
function actualizar_subventana_botones()
  -- 1. Botón de retroceso por defecto (B) garantiza salida limpia sin guardar cambios
  if btnp(5) or stat(30) == 14 then
    sub_btn_abierta = false
    bloqueo_a = false
    return
  end

  -- 2. Detector técnico en tiempo real de pulsaciones para reporte visual
  if btn(0) then ultimo_btn_reg = "p1:izq (id:0)" ultimo_btn_col = 12 end
  if btn(1) then ultimo_btn_reg = "p1:der (id:1)" ultimo_btn_col = 12 end
  if btn(2) then ultimo_btn_reg = "p1:arr (id:2)" ultimo_btn_col = 12 end
  if btn(3) then ultimo_btn_reg = "p1:aba (id:3)" ultimo_btn_col = 12 end
  if btn(4) then ultimo_btn_reg = "p1:btn a (id:4)" ultimo_btn_col = 11 end
  if btn(0, 1) then ultimo_btn_reg = "p2:izq (id:0,1)" ultimo_btn_col = 10 end
  if btn(1, 1) then ultimo_btn_reg = "p2:der (id:1,1)" ultimo_btn_col = 10 end
  if btn(2, 1) then ultimo_btn_reg = "p2:sel/u (id:2,1)" ultimo_btn_col = 9 end
  if btn(3, 1) then ultimo_btn_reg = "p2:str/d (id:3,1)" ultimo_btn_col = 9 end
  if btn(4, 1) then ultimo_btn_reg = "p2:l1/x (id:4,1)" ultimo_btn_col = 14 end
  if btn(5, 1) then ultimo_btn_reg = "p2:r1/y (id:5,1)" ultimo_btn_col = 14 end

  -- 3. Navegación vertical: 1 = selector combo, 2 = fila de botones [aplicar / default / rechazar]
  if btnp(2) or btnp(3) then
    if sub_btn_cursor == 1 then
      sub_btn_cursor = 2
    else
      sub_btn_cursor = 1
    end
  end

  -- Cambiar asignación de botón con Izquierda / Derecha en la fila 1 (0 = default, 1..4 = combos)
  if sub_btn_cursor == 1 then
    if btnp(0) then
      btn_teclado_temp = btn_teclado_temp - 1
      if btn_teclado_temp < 0 then btn_teclado_temp = 4 end
    end
    if btnp(1) then
      btn_teclado_temp = btn_teclado_temp + 1
      if btn_teclado_temp > 4 then btn_teclado_temp = 0 end
    end
  else
    -- Navegación horizontal entre [aplicar] (2), [default] (3) y [rechazar] (4)
    if btnp(0) then
      sub_btn_cursor = sub_btn_cursor - 1
      if sub_btn_cursor < 2 then sub_btn_cursor = 4 end
    end
    if btnp(1) then
      sub_btn_cursor = sub_btn_cursor + 1
      if sub_btn_cursor > 4 then sub_btn_cursor = 2 end
    end
  end

  -- 4. Confirmación con botón A (respetando bloqueo_a de entrada)
  if btn(4) or stat(30) == 13 then
    if not bloqueo_a then
      bloqueo_a = true
      if sub_btn_cursor == 2 then
        -- APLICAR: Guarda la selección en RAM y en Slot 4 de SD
        btn_teclado_modo = btn_teclado_temp
        guardar_todo_en_sd()
        aviso_texto = textos_sistema[idioma_actual][13] .. "!"
        aviso_timer = 35
        sub_btn_abierta = false
      elseif sub_btn_cursor == 3 then
        -- DEFAULT: Restaura el teclado a modo fábrica (0) y lo guarda sin borrar nada más
        btn_teclado_temp = 0
        btn_teclado_modo = 0
        guardar_todo_en_sd()
        aviso_texto = "default ok!"
        aviso_timer = 35
        sub_btn_abierta = false
      elseif sub_btn_cursor == 4 then
        -- RECHAZAR: Descarta cambios temporales y vuelve sin alterar lo guardado
        sub_btn_abierta = false
      end
    end
  else
    bloqueo_a = false
  end
end

function render_subventana_botones(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  local t_sub_btn = {
    {"test & map btn", "tecla abc/123:", "monitor pulsac.:", "aplicar",  "rechazar", "b: volver sin grv"}, -- 1. es
    {"btn map & test", "abc/123 key:",   "input monitor:",   "apply",    "reject",   "b: exit no save"},   -- 2. en
    {"map/test przy.", "klaw. abc/123:", "monitor przyc.:",  "zastosuj", "odrzuc",   "b: wyjdz bez zap"},  -- 3. pl
    {"test i karta",   "knopka abc/123:","monitor nazhat.:", "primenit", "otmenit",  "b: vyhod bez shr"},  -- 4. ru
    {"map/test botoes","tecla abc/123:", "monitor teclas:",  "aplicar",  "rejeitar", "b: sair sem salv"},  -- 5. pt
    {"map/test tasti", "tasto abc/123:", "monitor tasti:",   "applica",  "rifiuta",  "b: esci senza slv"}, -- 6. it
    {"map/test bout.", "touche abc/123:","moniteur touch.:", "appliquer","rejeter",  "b: sortir ss grd"},  -- 7. fr
    {"btn map & test", "abc/123 key:",   "nyuuryoku test:",  "tekiyou",  "kyohi",    "b: hozon sezu mod"}, -- 8. jp
    {"anjian ceshi",   "abc/123 jian:",  "anjian jiankong:", "yingyong", "jujue",    "b: bu baocun tui"},  -- 9. cn
    {"beoteun teseu",  "abc/123 ki:",    "ipryeok moniteo:", "jeokyong", "geobu",    "b: jeojang anham"},  -- 10. kr
    {"tus test/ayar",  "abc/123 tusu:",  "tus monitoru:",    "uygula",   "reddet",   "b: kaydetsiz cik"}   -- 11. tr
  }

  local t_nombres_map = {
    {"defecto", "b+arr",   "b+aba",   "b+izq",    "b+der"},    -- 1. es
    {"default", "b+up",    "b+down",  "b+left",   "b+right"},  -- 2. en
    {"domysl.", "b+gora",  "b+dol",   "b+lewo",   "b+prawo"},  -- 3. pl
    {"umolch.", "b+vverh", "b+vniz",  "b+levo",   "b+pravo"},  -- 4. ru
    {"padrao",  "b+cima",  "b+baixo", "b+esq",    "b+dir"},    -- 5. pt
    {"default", "b+su",    "b+giu",   "b+sin",    "b+des"},    -- 6. it
    {"defaut",  "b+haut",  "b+bas",   "b+gauche", "b+droite"}, -- 7. fr
    {"kihon",   "b+ue",    "b+shita", "b+hidari", "b+migi"},   -- 8. jp
    {"moren",   "b+shang", "b+xia",   "b+zuo",    "b+you"},    -- 9. cn
    {"gibon",   "b+wi",    "b+arae",  "b+oen",    "b+oreun"},  -- 10. kr
    {"varsay.", "b+ust",   "b+alt",   "b+sol",    "b+sag"}     -- 11. tr
  }

  local s_data = t_sub_btn[idioma_actual]
  local nombres_map = t_nombres_map[idioma_actual]
  local j1, j2, j3, j4, j5, j6 = 1, 2, 3, 4, 5, 6
  local sx, sy, sw, sh = 6, 10, 116, 108

  rectfill(sx, sy, sx + sw, sy + sh, 0)
  rect(sx, sy, sx + sw, sy + sh, 11)
  rectfill(sx + 2, sy + 2, sx + sw - 2, sy + 11, c_display)
  print(s_data[j1], sx + 6, sy + 4, 7)

  local y_map = sy + 16
  if sub_btn_cursor == 1 then
    rectfill(sx + 4, y_map - 2, sx + sw - 4, y_map + 13, c_btn_bse)
  else
    rect(sx + 4, y_map - 2, sx + sw - 4, y_map + 13, 5)
  end
  print(s_data[j2], sx + 7, y_map, sub_btn_cursor == 1 and c_btn_txt or 6)

  local idx_map = btn_teclado_temp + 1
  local txt_combo = "< " .. nombres_map[idx_map] .. " >"
  local cx_combo = (sx + sw - 6) - (#txt_combo * 4)
  print(txt_combo, cx_combo, y_map + 6, 10)

  local y_tst = sy + 34
  rect(sx + 4, y_tst, sx + sw - 4, y_tst + 46, 5)
  print(s_data[j3], sx + 7, y_tst + 3, 7)

  local function caja_btn(bx, by, txt, activo, col_on)
    rectfill(bx, by, bx + 15, by + 8, activo and col_on or 1)
    print(txt, bx + 2, by + 2, activo and 0 or 5)
  end

  caja_btn(sx + 7,  y_tst + 12, "izq", btn(0), 12)
  caja_btn(sx + 25, y_tst + 12, "der", btn(1), 12)
  caja_btn(sx + 43, y_tst + 12, "arr", btn(2), 12)
  caja_btn(sx + 61, y_tst + 12, "aba", btn(3), 12)
  caja_btn(sx + 79, y_tst + 12, " a ", btn(4), 11)
  caja_btn(sx + 97, y_tst + 12, "b:x", false, 8)

  caja_btn(sx + 7,  y_tst + 23, "l1 ", btn(4, 1), 14)
  caja_btn(sx + 25, y_tst + 23, "r1 ", btn(5, 1), 14)
  caja_btn(sx + 43, y_tst + 23, "sel", btn(2, 1), 9)
  caja_btn(sx + 61, y_tst + 23, "str", btn(3, 1), 9)
  caja_btn(sx + 79, y_tst + 23, "p2l", btn(0, 1), 10)
  caja_btn(sx + 97, y_tst + 23, "p2r", btn(1, 1), 10)

  print("reg: " .. ultimo_btn_reg, sx + 7, y_tst + 36, ultimo_btn_col)

  local y_acc = sy + 85

  local lbl_apl = sub(s_data[j4], 1, 7)
  local ax1 = sx + 22 - (#lbl_apl * 2)
  if sub_btn_cursor == 2 then
    rectfill(sx + 4, y_acc, sx + 39, y_acc + 10, 11)
    print(lbl_apl, ax1, y_acc + 2, 0)
  else
    rect(sx + 4, y_acc, sx + 39, y_acc + 10, 3)
    print(lbl_apl, ax1, y_acc + 2, 11)
  end

  local lbl_def = sub(nombres_map[j1], 1, 7)
  local dx1 = sx + 58 - (#lbl_def * 2)
  if sub_btn_cursor == 3 then
    rectfill(sx + 41, y_acc, sx + 75, y_acc + 10, 10)
    print(lbl_def, dx1, y_acc + 2, 0)
  else
    rect(sx + 41, y_acc, sx + 75, y_acc + 10, 9)
    print(lbl_def, dx1, y_acc + 2, 10)
  end

  local lbl_rec = sub(s_data[j5], 1, 7)
  local rx1 = sx + 94 - (#lbl_rec * 2)
  if sub_btn_cursor == 4 then
    rectfill(sx + 77, y_acc, sx + 112, y_acc + 10, 8)
    print(lbl_rec, rx1, y_acc + 2, 7)
  else
    rect(sx + 77, y_acc, sx + 112, y_acc + 10, 2)
    print(lbl_rec, rx1, y_acc + 2, 8)
  end

  local px = 64 - (#s_data[j6] * 2)
  print(s_data[j6], px, sy + 99, 6)
end
