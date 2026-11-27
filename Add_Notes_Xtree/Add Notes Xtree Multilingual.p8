pico-8 cartridge // http://pico-8.com
version 43
__lua__
-- =========================================================
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.07]
-- PARTE 1 DE 4: NÚCLEO DE INICIALIZACIÓN Y CONTROL DE FLUX
-- =========================================================

function _init()
  id_nombre = "ADD NOTES XTREE"
  id_version = "V0.07"
  
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

  config_exp_modo = 0        -- 0 = off, 1 = cstore 12kb, 2 = printh txt, 3 = ambos
  exp_abierta = false        -- ventana emergente de funciones experimentales
  exp_cursor = 1             -- 1=test, 2=cstore 12kb, 3=export txt, 4=guardar, 5=cancelar
  exp_temp_modo = 0          -- copia temporal antes de guardar/cancelar
  exp_test_hecho = false     -- cerrojo: bloquea opciones hasta correr el test
  exp_disp_cstore = false    -- resultado del test para cstore/reload
  exp_disp_printh = false    -- resultado del test para printh

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
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.07]
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
-- PROYECTO: ADD NOTES XTREE ULTRA-COMPATIBLE [v0.07]
-- PARTE 3 DE 4: MENÚ DE NOTAS Y MASCOTA CON EXPRESIONES
-- =========================================================

function actualizar_menu_principal_notas()
  -- Escudo antirrebote al volver del teclado o de opciones (funciona igual en off y on)
  if cooldown_teclado and cooldown_teclado > 0 then
    if not btn(4) and not btnp(4) and stat(30) != 13 then
      cooldown_teclado = cooldown_teclado - 1
    end
    bloqueo_a = true
    return
  end

  local total_actual = #lista_notas
  local max_opciones = total_actual + 1
  
  -- Solo libera bloqueo_a cuando el botón A está físicamente suelto y sin flanco activo
  if not btn(4) and not btnp(4) and stat(30) != 13 then
    bloqueo_a = false
  end
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
  
  print("ADD NOTES XTREE V0.07", 4, 3, c_txt_dis)
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
      
      -- 1. Guarda en el sistema interno activo (Clásico o Almacenamiento Plus)
      guardar_todo_en_sd()
      -- 2. Añade progresivamente la nota al archivo .txt si la opción está activa
      agregar_nota_a_txt_progresivo(texto_nota_buffer)

      local mat_sys = textos_sistema[idioma_actual]
      local idx_gdr = 13
      aviso_texto = mat_sys[idx_gdr] .. "!"
      aviso_timer = 45
      estado_emocional = 7
      cronometro_emocion = 0
    end
    
    modo_actual = 2
    cursor_menu = 1
    nota_seleccionada_idx = nil
    bloqueo_a = true
    cooldown_teclado = 10
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
    t_ver .. " v0.07",
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


function guardar_notas_cstore_12kb()
  if (config_exp_modo != 1 and config_exp_modo != 3) or type(cstore) != "function" then return end
  pcall(function()
    local addr = 0x1000
    poke(addr, #lista_notas)
    addr = addr + 1
    for i = 1, #lista_notas do
      local s = lista_notas[i]
      poke(addr, #s)
      addr = addr + 1
      for c = 1, #s do
        local ch = sub(s, c, c)
        local id_c = 1
        for k = 1, #comp_dict do
          if comp_dict[k] == ch then id_c = k break end
        end
        poke(addr, id_c)
        addr = addr + 1
      end
    end
    cstore(0x1000, 0x1000, addr - 0x1000)
  end)
end


function cargar_notas_cstore_12kb()
  if (config_exp_modo != 1 and config_exp_modo != 3) or type(reload) != "function" then return end
  pcall(function()
    reload(0x1000, 0x1000, 1400)
    local tot = peek(0x1000)
    if tot >= 1 and tot <= total_notas_permitidas then
      lista_notas = {}
      local addr = 0x1001
      for i = 1, tot do
        local l = peek(addr)
        addr = addr + 1
        if l < 0 or l > 120 then l = 0 end
        local txt = ""
        for c = 1, l do
          local id_c = peek(addr)
          addr = addr + 1
          txt = txt .. (comp_dict[id_c] or " ")
        end
        add(lista_notas, txt)
      end
    end
  end)
end


function exportar_notas_printh_txt()
  if (config_exp_modo != 2 and config_exp_modo != 3) or type(printh) != "function" then return end
  pcall(function()
    printh("=== add notes xtree ===", "xtree_notas.txt", true)
    for i = 1, #lista_notas do
      printh(i .. ": " .. lista_notas[i], "xtree_notas.txt", false)
    end
  end)
end


-- Empaqueta 2 IDs de carácter (0..61) en un entero puro de PICO-8 (máx 3965, cero decimales)
function empaquetar_2_chars(c1, c2)
  return (c1 or 0) + ((c2 or 0) * 64)
end

-- Extrae los 2 IDs de carácter desde un entero puro
function desempaquetar_2_chars(val)
  local v = flr(val or 0)
  if v < 0 then v = 0 end
  local c1 = v % 64
  local c2 = flr(v / 64) % 64
  return c1, c2
end


-- Agrega progresivamente una nota al final de xtree_notas.txt sin borrar las anteriores
function agregar_nota_a_txt_progresivo(texto_nota)
  if (config_exp_modo != 2 and config_exp_modo != 3) or type(printh) != "function" then return end
  if not texto_nota or #texto_nota == 0 then return end
  pcall(function()
    local anio = stat(90) or 2026
    local mes = stat(91) or 1
    local dia = stat(92) or 1
    local marca = "[" .. anio .. "-" .. mes .. "-" .. dia .. " " .. (str_reloj or "00:00") .. "]"
    printh(marca .. " " .. texto_nota, "xtree_notas.txt", false)
  end)
end


function guardar_todo_en_sd()
  pcall(function()
    dset(0, idioma_actual)
    dset(1, perfil_sexo)
    dset(2, idx_tema)
    dset(3, #lista_notas)
    
    -- Empaquetado 100% entero en Slot 4 (valor máximo = 499)
    local empaquetado_config = config_zoom + (config_motivacion * 2) + (btn_teclado_modo * 4) + (config_autocomp * 32) + (config_alm_plus * 64) + (config_exp_modo * 128)
    dset(4, empaquetado_config)
    
    if config_alm_plus == 1 then
      -- MOTOR PLUS ENTERO (2 caracteres enteros por slot desde el Slot 5 hasta el 125)
      local puntero_slot = 5
      for i = 1, total_notas_permitidas do
        if puntero_slot > 125 then break end
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

          for b = 1, largo, 2 do
            if puntero_slot > 125 then break end
            local v1 = ids[b] or 0
            local v2 = ids[b + 1] or 0
            dset(puntero_slot, empaquetar_2_chars(v1, v2))
            puntero_slot = puntero_slot + 1
          end
        else
          dset(puntero_slot, 0)
          puntero_slot = puntero_slot + 1
        end
      end
    else
      -- MOTOR CLÁSICO ORIGINAL (1 carácter por slot desde el Slot 10 hasta el 125)
      for i = 1, total_notas_permitidas do
        local slot_base = 10 + (i - 1) * 130
        if slot_base > 125 then break end
        if i <= #lista_notas then
          local nota_str = lista_notas[i]
          dset(slot_base, #nota_str)
          for c = 1, #nota_str do
            if (slot_base + c) > 125 then break end
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

    -- Respaldo experimental cstore (solo si el usuario lo activó y el hardware lo soporta)
    guardar_notas_cstore_12kb()
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
    
    -- Desempaquetado 100% entero del Slot 4
    local empaquetado_config = flr(dget(4) or 0)
    config_zoom = empaquetado_config % 2
    config_motivacion = flr(empaquetado_config / 2) % 2
    btn_teclado_modo = flr(empaquetado_config / 4) % 8
    config_autocomp = flr(empaquetado_config / 32) % 2
    config_alm_plus = flr(empaquetado_config / 64) % 2
    config_exp_modo = flr(empaquetado_config / 128) % 4
    
    if config_zoom < 0 or config_zoom > 1 then config_zoom = 0 end
    if config_motivacion < 0 or config_motivacion > 1 then config_motivacion = 0 end
    if btn_teclado_modo < 0 or btn_teclado_modo > 4 then btn_teclado_modo = 0 end
    if config_autocomp < 0 or config_autocomp > 1 then config_autocomp = 0 end
    if config_alm_plus < 0 or config_alm_plus > 1 then config_alm_plus = 0 end
    if config_exp_modo < 0 or config_exp_modo > 3 then config_exp_modo = 0 end
    
    if config_alm_plus == 1 then
      -- LECTURA MOTOR PLUS ENTERO (Slot 5..125)
      local puntero_slot = 5
      for i = 1, total_g do
        if puntero_slot > 125 then break end
        local largo = flr(dget(puntero_slot) or 0)
        puntero_slot = puntero_slot + 1
        if largo < 0 or largo > 120 then largo = 0 end

        local texto_reconstruido = ""
        local bloques = flr((largo + 1) / 2)
        for b = 1, bloques do
          if puntero_slot > 125 then break end
          local c1, c2 = desempaquetar_2_chars(dget(puntero_slot))
          puntero_slot = puntero_slot + 1
          
          if #texto_reconstruido < largo then
            texto_reconstruido = texto_reconstruido .. (comp_dict[c1] or " ")
          end
          if #texto_reconstruido < largo then
            texto_reconstruido = texto_reconstruido .. (comp_dict[c2] or " ")
          end
        end
        add(lista_notas, texto_reconstruido)
      end
    else
      -- LECTURA MOTOR CLÁSICO ORIGINAL (Slot 10..125)
      for i = 1, total_g do
        local slot_base = 10 + (i - 1) * 130
        if slot_base > 125 then break end
        local longitud_texto = flr(dget(slot_base) or 0)
        if longitud_texto < 0 or longitud_texto > 120 then longitud_texto = 0 end
        
        local texto_reconstruido = ""
        for c = 1, longitud_texto do
          if (slot_base + c) > 125 then break end
          local id_char = flr(dget(slot_base + c) or 1)
          if id_char >= 1 and id_char <= #comp_dict then
            texto_reconstruido = texto_reconstruido .. comp_dict[id_char]
          else
            texto_reconstruido = texto_reconstruido .. " "
          end
        end
        add(lista_notas, texto_reconstruido)
      end
    end

    cargar_notas_cstore_12kb()
    
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

  if exp_abierta then
    actualizar_ventana_experimentales()
    return
  end

  -- Navegación vertical sobre 8 opciones con scroll automático (ventana de 5 visibles)
  if btnp(2) then
    config_cursor = config_cursor - 1
    if config_cursor < 1 then config_cursor = 8 end
  end
  if btnp(3) then
    config_cursor = config_cursor + 1
    if config_cursor > 8 then config_cursor = 1 end
  end

  -- Ajuste automático de ventana deslizante (config_scroll)
  config_scroll = config_scroll or 0
  if config_cursor <= config_scroll then
    config_scroll = config_cursor - 1
  elseif config_cursor > config_scroll + 5 then
    config_scroll = config_cursor - 5
  end

  if btnp(5) or stat(30) == 14 then
    config_abierta = false
    config_scroll = 0
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
        for slot = 0, 125 do dset(slot, 0) end 
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
      config_exp_modo = 0
      config_abierta = false
      config_scroll = 0
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
    if btnp(0) or btnp(1) or btnp(4) or stat(30) == 13 then
      aviso_plus_abierto = true
      aviso_plus_cursor = 2
      bloqueo_a = true
      return
    end

  elseif config_cursor == 8 then
    if btnp(4) or stat(30) == 13 then
      exp_abierta = true
      exp_cursor = 1
      exp_temp_modo = config_exp_modo
      if config_exp_modo > 0 then
        exp_test_hecho = true
        exp_disp_cstore = (config_exp_modo == 1 or config_exp_modo == 3)
        exp_disp_printh = (config_exp_modo == 2 or config_exp_modo == 3)
      else
        exp_test_hecho = false
        exp_disp_cstore = false
        exp_disp_printh = false
      end
      bloqueo_a = true
      return
    end
  end
end



function actualizar_aviso_alm_plus()
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
        lista_notas = {}
        config_alm_plus = (config_alm_plus == 0) and 1 or 0
        pcall(function()
          for s = 5, 125 do dset(s, 0) end
        end)
        guardar_todo_en_sd()
        aviso_texto = "ok!"
        aviso_timer = 35
        aviso_plus_abierto = false
        config_abierta = false
        config_scroll = 0
        cursor_menu = 1
        cooldown_teclado = 10
      else
        aviso_plus_abierto = false
      end
    end
  else
    bloqueo_a = false
  end
end


function actualizar_ventana_experimentales()
  if btnp(5) or stat(30) == 14 then
    exp_abierta = false
    bloqueo_a = false
    return
  end

  if btnp(2) then
    exp_cursor = exp_cursor - 1
    if exp_cursor < 1 then exp_cursor = 5 end
  end
  if btnp(3) then
    exp_cursor = exp_cursor + 1
    if exp_cursor > 5 then exp_cursor = 1 end
  end

  if exp_cursor == 4 and btnp(1) then exp_cursor = 5 end
  if exp_cursor == 5 and btnp(0) then exp_cursor = 4 end

  if exp_test_hecho then
    if exp_cursor == 2 and exp_disp_cstore and (btnp(0) or btnp(1)) then
      local c_on = (exp_temp_modo == 1 or exp_temp_modo == 3)
      local p_on = (exp_temp_modo == 2 or exp_temp_modo == 3)
      c_on = not c_on
      exp_temp_modo = (c_on and 1 or 0) + (p_on and 2 or 0)
    elseif exp_cursor == 3 and exp_disp_printh and (btnp(0) or btnp(1)) then
      local c_on = (exp_temp_modo == 1 or exp_temp_modo == 3)
      local p_on = (exp_temp_modo == 2 or exp_temp_modo == 3)
      p_on = not p_on
      exp_temp_modo = (c_on and 1 or 0) + (p_on and 2 or 0)
    end
  end

  if btn(4) or stat(30) == 13 then
    if not bloqueo_a then
      bloqueo_a = true
      if exp_cursor == 1 then
        exp_disp_cstore = false
        exp_disp_printh = false
        if type(cstore) == "function" and type(reload) == "function" then
          pcall(function()
            poke(0x2000, 170)
            cstore(0x2000, 0x2000, 1)
            poke(0x2000, 0)
            reload(0x2000, 0x2000, 1)
            if peek(0x2000) == 170 then exp_disp_cstore = true end
            poke(0x2000, 0)
          end)
        end
        if type(printh) == "function" then
          local ok_p = pcall(function()
            printh("test", "xtree_test.tmp", true)
          end)
          if ok_p then exp_disp_printh = true end
        end
        exp_test_hecho = true

      elseif exp_cursor == 4 then
        if not exp_disp_cstore and (exp_temp_modo == 1 or exp_temp_modo == 3) then
          exp_temp_modo = exp_temp_modo - 1
        end
        if not exp_disp_printh and (exp_temp_modo == 2 or exp_temp_modo == 3) then
          exp_temp_modo = exp_temp_modo - 2
        end
        
        config_exp_modo = exp_temp_modo
        pcall(function() cartdata("xtree_notes_pro") end)
        guardar_todo_en_sd()

        if config_exp_modo == 2 or config_exp_modo == 3 then
          pcall(function()
            printh("=== add notes xtree ===", "xtree_notas.txt", true)
            for i = 1, #lista_notas do
              agregar_nota_a_txt_progresivo(lista_notas[i])
            end
          end)
        end

        aviso_texto = "ok!"
        aviso_timer = 35
        exp_abierta = false

      elseif exp_cursor == 5 then
        exp_abierta = false
      end
    end
  else
    bloqueo_a = false
  end
end


function render_ventana_opciones_adicionales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  local t_config = {
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacion", "formatear", "si", "no", "b: salir/grv", "map/test btn", "autocomplet.", "alm. plus",     "func. experim."},
    {"extra cfgs",   "text zoom",  "lang/idioma", "motivation", "wipe clear", "yes","no", "b: exit/save", "btn map/test", "autocomplete", "storage plus", "exp. features"},
    {"cfg. dodatk",  "zoom tekstu", "jezyk/lang", "motywacja",  "czyszczenie", "tak","nie","b: wyjdz/zap", "map/test btn", "autouzupeln.", "pamiec plus",  "funkcje eksp."},
    {"dop. nastr",   "masshtab",   "yazik/lang",  "motivaciya", "ochistka",   "da", "net","b: vyhod/shran","test knopok",  "avtodopoln.",  "pamyat plus",  "eksp. funkcii"},
    {"cfg. extras",  "zoom letra", "idioma/lang", "motivacao",  "formatar",   "sim","nao","b: sair/salv", "map/test btn", "autocomplet.", "armaz. plus",  "func. experim."},
    {"cfg. extra",   "zoom testo", "lingua/lang", "motivazione","formatta",   "si", "no", "b: esci/salv", "map/test btn", "autocomplet.", "memoria plus", "funz. sperim."},
    {"cfg. extras",  "zoom texte", "langue/lang", "motivation", "effacer to", "oui","non","b: sortir/grd", "map/test btn", "autocomplet.", "stock. plus",  "fonct. exper."},
    {"sono hoka",    "moji zoom",  "gengo/lang",  "douki zuke", "shokika",    "hai","iie","b: modoru/hoz", "btn map/test", "jidou hokan",  "hozon plus",   "jikken kinou"},
    {"geng duo she", "zi ti da xiao","yu yan/lang","ji li",       "qing chu",   "shi","fou","b: tui chu/bao","anjian ceshi", "zidong buquan","cunchu plus",  "shiyan gongn."},
    {"gita seolt",   "geulja zoom","eoneo/lang",  "donggi buyeo","gongjang ch","ye", "ani","b: nagagi/jeo", "beoteun teseu","jadong wanseo","jeojang plus", "silheom gineu"},
    {"ek ayarlar",   "metin zoomu", "dil/lang",    "motivasyon", "sifirla",    "evet","hayir","b: cikis/kayd","tus test/ayar","otomatik tam.","depolama plus","deneysel oz."}
  }

  local m_data = t_config[idioma_actual]
  local k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11, k12 = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
  local vx, vy, vw, vh = 10, 12, 108, 104
  local scr = config_scroll or 0
  
  rectfill(vx, vy, vx + vw, vy + vh, 0)         
  rect(vx, vy, vx + vw, vy + vh, c_btn_bse)     
  rectfill(vx + 2, vy + 2, vx + vw - 2, vy + 12, c_display) 
  print(m_data[k1], vx + 6, vy + 4, c_txt_dis)

  -- Indicadores visuales discretos de desplazamiento (arriba / abajo)
  if scr > 0 then print("^", vx + vw - 9, vy + 4, 11) end
  if scr < 3 then print("v", vx + vw - 9, vy + vh - 10, 11) end

  -- Renderizado deslizante de exactamente 5 filas cómodas a la vez (15 px por fila)
  for slot_vis = 1, 5 do
    local idx_op = scr + slot_vis
    local ly = vy + 18 + (slot_vis - 1) * 15
    local sel = (config_cursor == idx_op)

    if sel then
      rectfill(vx + 4, ly - 2, vx + vw - 6, ly + 7, c_btn_bse)
    end

    if idx_op == 1 then
      print(m_data[k2] .. ":", vx + 6, ly, sel and c_btn_txt or c_txt_dis)
      print(config_zoom == 1 and "on" or "off", vx + 80, ly, config_zoom == 1 and 10 or 8)

    elseif idx_op == 2 then
      print(m_data[k3] .. ":", vx + 6, ly, sel and c_btn_txt or c_txt_dis)
      print("<" .. codigos_idioma[idioma_actual] .. ">", vx + 74, ly, 11)

    elseif idx_op == 3 then
      print(m_data[k4] .. ":", vx + 6, ly, sel and c_btn_txt or c_txt_dis)
      print(config_motivacion == 1 and "on" or "off", vx + 80, ly, config_motivacion == 1 and 10 or 8)

    elseif idx_op == 4 then
      print(m_data[k5], vx + 6, ly, sel and c_btn_txt or 8)
      if confirma_borrado then
        rectfill(vx + 76, ly - 1, vx + 98, ly + 6, 8)
        print(m_data[k6], vx + 78, ly, 7)
      else
        rectfill(vx + 76, ly - 1, vx + 98, ly + 6, 12)
        print(m_data[k7], vx + 78, ly, 7)
      end

    elseif idx_op == 5 then
      print(m_data[k9], vx + 6, ly, sel and c_btn_txt or 11)
      print("[>]", vx + 84, ly, sel and c_btn_txt or 10)

    elseif idx_op == 6 then
      print(m_data[k10] .. ":", vx + 6, ly, sel and c_btn_txt or c_txt_dis)
      print(config_autocomp == 1 and "on" or "off", vx + 80, ly, config_autocomp == 1 and 10 or 8)

    elseif idx_op == 7 then
      print(m_data[k11] .. ":", vx + 6, ly, sel and c_btn_txt or 10)
      print(config_alm_plus == 1 and "on" or "off", vx + 80, ly, config_alm_plus == 1 and 10 or 8)

    elseif idx_op == 8 then
      print(m_data[k12], vx + 6, ly, sel and c_btn_txt or 14)
      print("[>]", vx + 84, ly, sel and c_btn_txt or 14)
    end
  end
  
  print(m_data[k8], vx + 14, vy + 94, 6)

  if sub_btn_abierta then
    render_subventana_botones(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  end

  if aviso_plus_abierto then
    render_aviso_alm_plus()
  end

  if exp_abierta then
    render_ventana_experimentales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  end
end


function render_ventana_experimentales(c_display, c_btn_bse, c_btn_txt, c_txt_dis)
  local t_exp = {
    {"func. experim.", "ejecutar test",  "alm. 12kb cart", "exportar .txt", "guardar",  "cancelar", "bloq", "no disp."}, -- 1. es
    {"exp. features",  "run hardware test","12kb cart save","export .txt",   "save",     "cancel",   "lock", "unavail."}, -- 2. en
    {"funkcje eksp.",  "uruchom test",   "pamiec 12kb",    "eksport .txt",  "zapisz",   "anuluj",   "blok", "niedost."}, -- 3. pl
    {"eksp. funkcii",  "zapustit test",  "pamyat 12kb",    "eksport .txt",  "sohranit", "otmena",   "blok", "nedost."},  -- 4. ru
    {"func. experim.", "executar test",  "armaz. 12kb",    "exportar .txt", "salvar",   "cancelar", "bloq", "indisp."},  -- 5. pt
    {"funz. sperim.",  "esegui test",    "memoria 12kb",   "esporta .txt",  "salva",    "annulla",  "bloc", "non disp."},-- 6. it
    {"fonct. exper.",  "lancer le test", "stock. 12kb",    "exporter .txt", "garder",   "annuler",  "bloq", "indisp."},  -- 7. fr
    {"jikken kinou",   "tesuto jikkou",  "12kb hozon",     ".txt shutsury.", "hozon",    "chuushi",  "lock", "fuka"},     -- 8. jp
    {"shiyan gongn.",  "yunxing ceshi",  "12kb cunchu",    "daochu .txt",   "baocun",   "quxiao",   "suo",  "bukeyong"}, -- 9. cn
    {"silheom gineu",  "teseuteu silh.", "12kb jeojang",   ".txt naebon.",  "jeojang",  "chwiso",   "jamg", "bulga"},    -- 10. kr
    {"deneysel oz.",   "testi calistir", "12kb depolama",  ".txt aktar",    "kaydet",   "iptal",    "kilit","yok"}       -- 11. tr
  }

  local e_data = t_exp[idioma_actual]
  local j1, j2, j3, j4, j5, j6, j7, j8 = 1, 2, 3, 4, 5, 6, 7, 8
  local ex, ey, ew, eh = 6, 14, 116, 100

  rectfill(ex, ey, ex + ew, ey + eh, 0)
  rect(ex, ey, ex + ew, ey + eh, 14)
  rectfill(ex + 2, ey + 2, ex + ew - 2, ey + 11, c_display)
  print(e_data[j1], ex + 6, ey + 4, 7)

  -- Fila 1: Botón obligatorio [Ejecutar Test]
  local y1 = ey + 16
  if exp_cursor == 1 then
    rectfill(ex + 4, y1 - 2, ex + ew - 4, y1 + 8, 11)
    print("[ " .. e_data[j2] .. " ]", ex + 10, y1, 0)
  else
    rect(ex + 4, y1 - 2, ex + ew - 4, y1 + 8, 3)
    print("[ " .. e_data[j2] .. " ]", ex + 10, y1, 11)
  end

  -- Fila 2: Almacenamiento Extra 12KB (cstore/reload)
  local y2 = ey + 34
  local c_act = (exp_temp_modo == 1 or exp_temp_modo == 3)
  if exp_cursor == 2 then rectfill(ex + 4, y2 - 2, ex + ew - 4, y2 + 7, c_btn_bse) end
  print(e_data[j3] .. ":", ex + 6, y2, exp_cursor == 2 and c_btn_txt or (exp_test_hecho and 7 or 5))
  if not exp_test_hecho then
    print("[" .. e_data[j7] .. "]", ex + 82, y2, 8)
  elseif not exp_disp_cstore then
    print(e_data[j8], ex + 78, y2, 8)
  else
    print(c_act and "on" or "off", ex + 92, y2, c_act and 10 or 8)
  end

  -- Fila 3: Exportación a archivo .txt externo (printh)
  local y3 = ey + 49
  local p_act = (exp_temp_modo == 2 or exp_temp_modo == 3)
  if exp_cursor == 3 then rectfill(ex + 4, y3 - 2, ex + ew - 4, y3 + 7, c_btn_bse) end
  print(e_data[j4] .. ":", ex + 6, y3, exp_cursor == 3 and c_btn_txt or (exp_test_hecho and 7 or 5))
  if not exp_test_hecho then
    print("[" .. e_data[j7] .. "]", ex + 82, y3, 8)
  elseif not exp_disp_printh then
    print(e_data[j8], ex + 78, y3, 8)
  else
    print(p_act and "on" or "off", ex + 92, y3, p_act and 10 or 8)
  end

  -- Línea separadora y botones inferiores: [Guardar] (4) | [Cancelar] (5)
  line(ex + 4, ey + 64, ex + ew - 4, ey + 64, 5)
  local y_btn = ey + 71

  -- Botón GUARDAR (4)
  local gx = ex + 31 - (#e_data[j5] * 2)
  if exp_cursor == 4 then
    rectfill(ex + 8, y_btn, ex + 54, y_btn + 11, 11)
    print(e_data[j5], gx, y_btn + 3, 0)
  else
    rect(ex + 8, y_btn, ex + 54, y_btn + 11, 3)
    print(e_data[j5], gx, y_btn + 3, 11)
  end

  -- Botón CANCELAR (5)
  local cx = ex + 85 - (#e_data[j6] * 2)
  if exp_cursor == 5 then
    rectfill(ex + 62, y_btn, ex + 108, y_btn + 11, 8)
    print(e_data[j6], cx, y_btn + 3, 7)
  else
    rect(ex + 62, y_btn, ex + 108, y_btn + 11, 2)
    print(e_data[j6], cx, y_btn + 3, 8)
  end

  -- Pie de estado informativo adaptado a los 11 idiomas
  local t_pie_ok = {
    "test ok - a: sel",  -- 1. es
    "test ok - a: sel",  -- 2. en
    "test ok - a: wyb",  -- 3. pl
    "test ok - a: vyb",  -- 4. ru
    "test ok - a: sel",  -- 5. pt
    "test ok - a: sel",  -- 6. it
    "test ok - a: sel",  -- 7. fr
    "test ok - a: sen",  -- 8. jp
    "ceshi ok - a: xuan",-- 9. cn
    "teseu ok - a: seon",-- 10. kr
    "test ok - a: sec"   -- 11. tr
  }
  local t_pie_no = {
    "ejecuta test antes",-- 1. es
    "run test first",    -- 2. en
    "najpierw test",     -- 3. pl
    "snachala test",     -- 4. ru
    "execute o test",    -- 5. pt
    "esegui il test",    -- 6. it
    "lancer le test",    -- 7. fr
    "saki ni tesuto",    -- 8. jp
    "xian yunxing ceshi",-- 9. cn
    "meonjeo teseuteu",  -- 10. kr
    "once testi yap"     -- 11. tr
  }
  local est_txt = exp_test_hecho and t_pie_ok[idioma_actual] or t_pie_no[idioma_actual]
  local px_est = ex + flr((ew - (#est_txt * 4)) / 2)
  print(est_txt, px_est, ey + 88, exp_test_hecho and 11 or 6)
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
