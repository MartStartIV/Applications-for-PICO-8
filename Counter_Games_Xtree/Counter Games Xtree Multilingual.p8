pico-8 cartridge // http://pico-8.com
version 42
__lua__
-- =========================================================
-- proyecto: counter games xtree [v0.05]
-- nucleo: picante8 libretro (mips ultra-compatible)
-- parte 1a: utilidades base, 18 idiomas y paletas
-- =========================================================

function dividir_pipe(s)
  local res = {}
  local ini = 1
  for i = 1, #s do
    if sub(s, i, i) == "|" then
      add(res, sub(s, ini, i - 1))
      ini = i + 1
    end
  end
  if ini <= #s then add(res, sub(s, ini, #s)) end
  return res
end

function limpiar_espacios_der(s)
  while #s > 0 and sub(s, #s, #s) == " " do
    s = sub(s, 1, #s - 1)
  end
  return s
end

function _init()
  app_nombre = "counter games xtree"
  app_ver = "v0.05"
  estado = 0
  estado_prev = 2
  trans_t = 0
  modal_anim = 0
  led_anim = 0
  led_col = 11
  comp_dict = " abcdefghijklmnopqrstuvwxyz0123456789.-_:+!?/()[]@#*=&%$<>;"

  lista_idiomas = {
    "1. espanol", "2. english", "3. polski", "4. russian", "5. portugues",
    "6. italiano", "7. francais", "8. nihongo (jp)", "9. zhongwen (cn)",
    "10. hangugeo (kr)", "11. turkce (tr)", "12. deutsch (de)", "13. al-arabiyya (ar)",
    "14. hindi (hi)", "15. nederlands (nl)", "16. svenska (sv)",
    "17. bahasa (id)", "18. tieng viet (vi)"
  }
  cod_lang = {
    "es","en","pl","ru","pt","it","fr","jp","cn",
    "kr","tr","de","ar","hi","nl","sv","id","vi"
  }

  txt_ui = {
    -- 1. es (espanol)
    {"idioma:", "tu nombre:", "selec. juego", "sin juegos", "categorias", "opciones", "habilitar resta -1?", "si", "no", "buscar", "acerca de",
     "interfaz:", "tema:", "auto-tema:", "zoom ui:", "motivacion:", "ranita:", "botones:", "b: guardar y salir",
     "der:entrar b+aba:quitar", "a:+1 b:-1 izq:salir", "todas las categorias", "atencion!",
     "controles / botones", "sumar +1:", "restar -1:", "entrar juego:", "salir juego:", "buscar cat.:", "restaurar default",
     "max 4 juegos!", "juego quitado", "juego guardado!", "ya agregado!", "sin coincidencias", "ok: crear custom",
     "desarrollador:", "gracias por usar!"},
    -- 2. en (english)
    {"language:", "your name:", "select game", "no games", "categories", "options", "enable -1 minus?", "yes", "no", "search", "about",
     "layout:", "theme:", "auto-theme:", "ui zoom:", "motivate:", "froggy:", "buttons:", "b: save & exit",
     "rgt:open b+dn:del", "a:+1 b:-1 lft:exit", "all categories", "warning!",
     "controls / buttons", "add +1:", "sub -1:", "open game:", "exit game:", "search cat.:", "reset default",
     "max 4 games!", "game removed", "game saved!", "already added!", "no matches", "ok: create custom",
     "developer:", "thanks for using!"},
    -- 3. pl (polski)
    {"jezyk:", "twoje imie:", "wybierz gre", "brak gier", "kategorie", "opcje", "wlaczyc minus -1?", "tak", "nie", "szukaj", "o programie",
     "interfejs:", "motyw:", "auto-motyw:", "zoom ui:", "motywacja:", "zabka:", "przyciski:", "b: zapisz i wyjdz",
     "pr:wejdz b+dol:usun", "a:+1 b:-1 lew:wyjdz", "wszystkie kategorie", "uwaga!",
     "sterowanie / przyciski", "dodaj +1:", "odejmij -1:", "otworz gre:", "wyjdz z gry:", "szukaj kat.:", "domyslne",
     "maks 4 gry!", "gra usunieta", "gra zapisana!", "juz dodano!", "brak wynikow", "ok: wlasna nazwa",
     "autor:", "dziekujemy!"},
    -- 4. ru (russian)
    {"yazik:", "vashe imya:", "vybor igry", "net igr", "kategorii", "opcii", "vklyuchit -1?", "da", "net", "poisk", "o programme",
     "vid:", "tema:", "avto-tema:", "zoom ui:", "motivaciya:", "lyagushka:", "knopki:", "b: sohranit i vyyti",
     "vpr:vhod b+vniz:udal", "a:+1 b:-1 vl:vyhod", "vse kategorii", "vnimanie!",
     "upravlenie / knopki", "plyus +1:", "minus -1:", "otkryt igru:", "vyyti iz igry:", "poisk kat.:", "sbros nastroek",
     "maks 4 igry!", "igra udalena", "igra sohranena!", "uzhe dobavleno!", "net sovpadeniy", "ok: svoya igra",
     "razrabotchik:", "spasibo za igru!"},
    -- 5. pt (portugues)
    {"idioma:", "seu nome:", "selec. jogo", "sem jogos", "categorias", "opcoes", "ativar menos -1?", "sim", "nao", "buscar", "sobre",
     "interface:", "tema:", "auto-tema:", "zoom ui:", "motivacao:", "sapinho:", "botoes:", "b: salvar e sair",
     "dir:abrir b+bx:apagar", "a:+1 b:-1 esq:sair", "todas as categorias", "atencao!",
     "controles / botoes", "somar +1:", "subtrair -1:", "abrir jogo:", "sair jogo:", "buscar cat.:", "restaurar padrao",
     "max 4 jogos!", "jogo removido", "jogo salvo!", "ja adicionado!", "sem resultados", "ok: criar custom",
     "desenvolvedor:", "obrigado por usar!"},
    -- 6. it (italiano)
    {"lingua:", "tuo nome:", "selez. gioco", "nessun gioco", "categorie", "opzioni", "abilita meno -1?", "si", "no", "cerca", "info",
     "interfaccia:", "tema:", "auto-tema:", "zoom ui:", "motivaz.:", "ranocchia:", "pulsanti:", "b: salva ed esci",
     "des:apri b+giu:elim", "a:+1 b:-1 sin:esci", "tutte le categorie", "attenzione!",
     "controlli / pulsanti", "aggiungi +1:", "togli -1:", "apri gioco:", "esci gioco:", "cerca cat.:", "ripristina default",
     "max 4 giochi!", "gioco rimosso", "gioco salvato!", "gia aggiunto!", "nessun risultato", "ok: crea custom",
     "sviluppatore:", "grazie per l'uso!"},
    -- 7. fr (francais)
    {"langue:", "ton nom:", "choisir jeu", "aucun jeu", "categories", "options", "activer moins -1?", "oui", "non", "chercher", "a propos",
     "interface:", "theme:", "auto-theme:", "zoom ui:", "motivation:", "grenouille:", "boutons:", "b: sauver & quitter",
     "dr:ouvrir b+bas:suppr", "a:+1 b:-1 ga:quitter", "toutes categories", "attention!",
     "controles / boutons", "ajouter +1:", "retirer -1:", "ouvrir jeu:", "quitter jeu:", "chercher cat.:", "par defaut",
     "max 4 jeux!", "jeu supprime", "jeu sauvegarde!", "deja ajoute!", "aucun resultat", "ok: creer perso",
     "developpeur:", "merci d'utiliser!"},
    -- 8. jp (nihongo)
    {"gengo:", "namae:", "geemu sentaku", "geemu nashi", "kategori", "opushon", "mainasu -1 yuukou?", "hai", "iie", "kensaku", "jouhou",
     "hyouji:", "teema:", "jido teema:", "zoom ui:", "ouen:", "kaeru:", "botan:", "b: hozon & modoru",
     "migi:hiraku b+shita:kesu", "a:+1 b:-1 hidari:modoru", "subete no kategori", "chuui!",
     "sousa / botan", "purasu +1:", "mainasu -1:", "geemu hiraku:", "geemu modoru:", "kat kensaku:", "shoki settei",
     "saidai 4 geemu!", "sakujo shimashita", "hozon shimashita!", "tsuika zumi!", "icchi nashi", "ok: shinki sakusei",
     "kaihatsusha:", "arigatou!"},
    -- 9. cn (zhongwen)
    {"yuyan:", "nide mingzi:", "xuanze youxi", "wu youxi", "fenlei", "xuanxiang", "qiyong jian -1?", "shi", "fou", "sousuo", "guanyu",
     "jiemian:", "zhuti:", "zidong zhuti:", "suofang:", "guli:", "qingwa:", "anjian:", "b: baocun tuichu",
     "you:dak b+xia:shanchu", "a:+1 b:-1 zuo:tuichu", "suoyou fenlei", "zhuyi!",
     "kongzhi / anjian", "jia +1:", "jian -1:", "dak youxi:", "tuichu youxi:", "sousuo fenlei:", "huifu moren",
     "zuiduo 4 ge!", "yi shanchu", "yi baocun!", "yi tianjia!", "wu jieguo", "ok: zidingyi",
     "kaifazhe:", "ganxie shiyong!"},
    -- 10. kr (hangugeo)
    {"eoneo:", "ireum:", "geim seontaek", "geim eopseum", "kategori", "opsyeon", "maineoseu -1?", "ye", "ani", "geomsaek", "jeongbo",
     "hwamyeon:", "tema:", "jadong tema:", "zoom ui:", "eungwon:", "gaeguri:", "beoteun:", "b: jeojang & nagagi",
     "u:yeolgi b+ha:sakje", "a:+1 b:-1 jwa:nagagi", "modeun kategori", "juui!",
     "jojak / beoteun", "deohagi +1:", "ppaegi -1:", "geim yeolgi:", "geim nagagi:", "kat geomsaek:", "gibon bokwon",
     "choedae 4gae!", "geim sakjedoem", "jeojangdoem!", "imi chugadoem!", "gyeolgwa eopseum", "ok: saero mandeulgi",
     "gaebalja:", "gamsahamnida!"},
    -- 11. tr (turkce)
    {"dil:", "adiniz:", "oyun sec", "oyun yok", "kategoriler", "ayarlar", "eksi -1 acilsin mi?", "evet", "hayir", "ara", "hakkinda",
     "arayuz:", "tema:", "oto-tema:", "zoom ui:", "motivasyon:", "kurbaga:", "tuslar:", "b: kaydet ve cik",
     "sag:ac b+alt:sil", "a:+1 b:-1 sol:cik", "tum kategoriler", "dikkat!",
     "kontroller / tuslar", "ekle +1:", "cikar -1:", "oyun ac:", "oyundan cik:", "kat. ara:", "varsayilan",
     "maks 4 oyun!", "oyun silindi", "oyun kaydedildi!", "zaten eklendi!", "sonuc yok", "ok: ozel olustur",
     "gelistirici:", "tesekkurler!"},
    -- 12. de (deutsch)
    {"sprache:", "dein name:", "spiel wahlen", "keine spiele", "kategorien", "optionen", "minus -1 aktivieren?", "ja", "nein", "suche", "uber",
     "design:", "thema:", "auto-thema:", "ui-zoom:", "motivation:", "frosch:", "tasten:", "b: speichern & zuruck",
     "re:offnen b+ab:losch", "a:+1 b:-1 li:zuruck", "alle kategorien", "achtung!",
     "steuerung / tasten", "plus +1:", "minus -1:", "spiel offnen:", "spiel verlassen:", "kat. suchen:", "standard",
     "max 4 spiele!", "spiel entfernt", "gespeichert!", "schon da!", "keine treffer", "ok: eigenes spiel",
     "entwickler:", "danke furs nutzen!"},
    -- 13. ar (al-arabiyya)
    {"allugha:", "ismuka:", "ikhtar luba", "la al-ab", "alfiat", "khiyarat", "tafil naqis -1?", "naam", "la", "bahth", "hawl",
     "alwajiha:", "alsima:", "sima tilqai:", "takbir:", "tahfiz:", "difda:", "azrar:", "b: hifz wa khuruj",
     "yamin:fath b+asfal:hadhf", "a:+1 b:-1 yasar:khuruj", "kull alfiat", "tanbih!",
     "tahakkum / azrar", "jam +1:", "tarh -1:", "fath luba:", "khuruj luba:", "bahth fia:", "iftiradi",
     "aqsa 4 al-ab!", "tamma alhadhf", "tamma alhifz!", "mudaf musbaqan!", "la nataij", "ok: insha khass",
     "almutawwir:", "shukran lak!"},
    -- 14. hi (hindi)
    {"bhasha:", "aapka naam:", "khel chune", "koi khel nahi", "shreniyan", "vikalp", "minus -1 chalu kare?", "haan", "nahi", "khojen", "jaankari",
     "roop:", "theme:", "auto-theme:", "zoom ui:", "prerna:", "mendhak:", "button:", "b: save & bahar",
     "dayen:khole b+niche:hataye", "a:+1 b:-1 bayen:bahar", "sabhi shreniyan", "saavdhan!",
     "niyantran / button", "jode +1:", "ghataye -1:", "khel khole:", "khel bahar:", "shreni khoje:", "default kare",
     "adhiktam 4 khel!", "khel hataya", "save ho gaya!", "pehle se hai!", "koi natija nahi", "ok: naya banaye",
     "vikasak:", "dhanyavaad!"},
    -- 15. nl (nederlands)
    {"taal:", "jouw naam:", "kies spel", "geen spellen", "categorieen", "opties", "min -1 inschakelen?", "ja", "nee", "zoeken", "over",
     "weergave:", "thema:", "auto-thema:", "ui-zoom:", "motivatie:", "kikker:", "knoppen:", "b: opslaan & terug",
     "re:open b+neer:wis", "a:+1 b:-1 li:terug", "alle categorieen", "let op!",
     "besturing / knoppen", "plus +1:", "min -1:", "open spel:", "sluit spel:", "zoek cat.:", "standaard",
     "max 4 spellen!", "spel verwijderd", "opgeslagen!", "al toegevoegd!", "geen resultaten", "ok: nieuw spel",
     "ontwikkelaar:", "bedankt!"},
    -- 16. sv (svenska)
    {"sprak:", "ditt namn:", "valj spel", "inga spel", "kategorier", "installn.", "aktivera minus -1?", "ja", "nej", "sok", "om",
     "granssnitt:", "tema:", "auto-tema:", "ui-zoom:", "motivation:", "groda:", "knappar:", "b: spara & tillbaka",
     "ho:oppna b+ner:ta bort", "a:+1 b:-1 va:tillbaka", "alla kategorier", "varning!",
     "kontroller / knappar", "lagg till +1:", "dra av -1:", "oppna spel:", "lamna spel:", "sok kat.:", "aterstall",
     "max 4 spel!", "spel borttaget", "sparat!", "redan tillagd!", "inga traffar", "ok: skapa eget",
     "utvecklare:", "tack for att du anvander!"},
    -- 17. id (bahasa)
    {"bahasa:", "nama anda:", "pilih game", "kosong", "kategori", "opsi", "aktifkan minus -1?", "ya", "tidak", "cari", "tentang",
     "tampilan:", "tema:", "auto-tema:", "zoom ui:", "motivasi:", "katak:", "tombol:", "b: simpan & keluar",
     "kanan:buka b+bwh:hapus", "a:+1 b:-1 kiri:keluar", "semua kategori", "perhatian!",
     "kontrol / tombol", "tambah +1:", "kurang -1:", "buka game:", "keluar game:", "cari kat.:", "reset default",
     "maks 4 game!", "game dihapus", "tersimpan!", "sudah ada!", "tidak cocok", "ok: buat baru",
     "pengembang:", "terima kasih!"},
    -- 18. vi (tieng viet)
    {"ngon ngu:", "ten ban:", "chon game", "chua co game", "danh muc", "tuy chon", "bat tru -1?", "co", "khong", "tim kiem", "gioi thieu",
     "giao dien:", "chu de:", "tu dong cd:", "thu phong:", "dong luc:", "ech con:", "nut bam:", "b: luu & thoat",
     "phai:mo b+xuong:xoa", "a:+1 b:-1 trai:thoat", "tat ca danh muc", "chu y!",
     "dieu khien / nut", "cong +1:", "tru -1:", "mo game:", "thoat game:", "tim dm:", "mac dinh",
     "toi da 4 game!", "da xoa game", "da luu!", "da them roi!", "khong tim thay", "ok: tao moi",
     "phat trien:", "cam on ban!"}
  }

  function tr(idx)
  local fila = txt_ui[idioma]
  if fila and fila[idx] then return fila[idx] end
  return ""
  end
  
  function cat_tr(cid)
  local fila = cats_lang[idioma]
  if fila and fila[cid] then return fila[cid] end
  return cats_db[cid] or "cat"
  end

  nombres_temas = {
    "cyber", "matrix", "blood", "gold", "ocean",
    "magma", "retro", "arctic", "toxic", "royal",
    "sunset", "neon", "forest", "sakura", "storm",
    "amber", "mint", "void", "copper", "plasma",
    "cobalt", "jade", "crimson", "ivory"
  }
  paletas_temas = {
    {0, 1, 12, 14, 7, 12},
    {0, 3, 11, 11, 0, 11},
    {0, 2, 8, 8, 7, 8},
    {0, 4, 10, 9, 0, 10},
    {1, 12, 7, 11, 0, 12},
    {0, 2, 9, 8, 7, 9},
    {5, 13, 7, 10, 0, 10},
    {1, 6, 7, 12, 0, 7},
    {0, 5, 11, 3, 7, 11},
    {1, 2, 15, 14, 0, 14},
    {2, 4, 10, 9, 7, 10},
    {0, 1, 14, 11, 0, 14},
    {0, 3, 7, 11, 0, 11},
    {2, 13, 7, 14, 0, 14},
    {1, 5, 7, 12, 0, 12},
    {0, 4, 9, 10, 0, 10},
    {1, 3, 7, 11, 0, 11},
    {0, 5, 7, 13, 0, 13},
    {4, 2, 15, 9, 0, 15},
    {1, 2, 12, 8, 7, 14},
    {0, 1, 7, 12, 0, 12},
    {3, 1, 11, 10, 0, 11},
    {2, 0, 7, 8, 7, 8},
    {5, 1, 7, 15, 0, 15}
  }
  -- parte 1b: diccionarios de juegos, categorias y variables
  dict_categorias_str = "victorias|muertes|niveles|misiones|objetos|vueltas|jefes|cafe|libros|cofres|estrellas|monedas|gemas|pociones|armas|armaduras|hechizos|habilidades|logros|trofeos|secretos|llaves|mapas|cristales|almas|runas|corazones|vidas|puntos|combos|partidas|derrotas|empates|records|tiempos|medallas|cartas|mascotas|monturas|construcc.|cultivos|peces|minerales|recetas|pociones+|encuentros|portales|torres|mazmorras|dragones|desafios|rangos|capitulos|finales|horas"
  local dj1 = "diablo 1|diablo 2|diablo 3|diablo 4|diablo immortal|bloodborne|dark souls 1|dark souls 2|dark souls 3|demon souls|elden ring|sekiro|lies of p|nioh 1|nioh 2|lords of fallen|blasphemous 1|blasphemous 2|hollow knight|silksong|salt sanctuary|dead cells|hades 1|hades 2|castlevania sotn|castlevania aria|path of exile|path of exile 2|grim dawn|torchlight 1|torchlight 2|titan quest|sacred 1|sacred 2|baldurs gate 1|baldurs gate 2|baldurs gate 3|witcher 1|witcher 2|witcher 3|skyrim|oblivion|morrowind|dragons dogma|monster hunter"
  local dj2 = "minecraft|terraria|tibia|starbound|stardew valley|valheim|subnautica|dont starve|rust|ark survival|the forest|sons of forest|project zomboid|rimworld|factorio|satisfactory|dyson sphere|no mans sky|core keeper|necesse|forager|slime rancher|animal crossing|harvest moon|story of seasons|dragon quest b2|lego fortnite|palworld|enshrouded|v rising|conan exiles|grounded|raft|green hell|stray|cult of lamb|graveyard keeper|moonlighter|dave the diver|spiritfarer"
  local dj3 = "zelda oot|zelda majora|zelda breath wild|zelda tears king|zelda link past|zelda links awak|zelda twilight|zelda wind waker|zelda minish cap|super mario 64|super mario world|super mario bros 3|mario odyssey|mario kart 8|mario kart ds|mario kart wii|paper mario|mario rpg|luigi mansion|metroid prime|super metroid|metroid dread|metroid fusion|kirby forgotten|kirby super star|donkey kong 64|dk country 1|dk country 2|yoshi island|banjo kazooie|crash bandicoot|crash team racing|spyro trilogy|rayman legends|celeste|cuphead|ori blind forest|ori will wisps|shovel knight|sonic mania|sonic adventure|sonic frontiers|mega man x|mega man x4|mega man 2|klonoa|psychonauts|little nightmares|limbo|inside|gris|journey|outer wilds|tunic|deaths door|hyper light drifter|fez|braid|super meat boy|pizza tower"
  local dj4 = "pokemon rojo|pokemon azul|pokemon amarillo|pokemon oro|pokemon plata|pokemon cristal|pokemon rubi|pokemon zafiro|pokemon esmeralda|pokemon rojo fuego|pokemon diamante|pokemon perla|pokemon platino|pokemon negro|pokemon blanco|pokemon x|pokemon y|pokemon sol|pokemon luna|pokemon espada|pokemon escarlata|pokemon arceus|final fantasy 6|final fantasy 7|final fantasy 8|final fantasy 9|final fantasy 10|final fantasy 12|final fantasy 16|ff7 rebirth|chrono trigger|chrono cross|persona 3|persona 4|persona 5 royal|shin megami 5|dragon quest 8|dragon quest 11|octopath 1|octopath 2|xenoblade 1|xenoblade 2|xenoblade 3|earthbound|kingdom hearts 1|kingdom hearts 2"
  local dj5 = "resident evil 1|resident evil 2|resident evil 3|resident evil 4|resident evil 7|resident evil 8|silent hill 1|silent hill 2|silent hill 3|dead space 1|dead space 2|alan wake 1|alan wake 2|outlast 1|outlast 2|amnesia bunker|alien isolation|fatal frame 2|doom 1993|doom 2|doom 2016|doom eternal|quake 1|quake 2|half life 1|half life 2|portal 1|portal 2|bioshock 1|bioshock infinite|halo ce|halo 2|halo 3|halo reach|call of duty mw|cod black ops|cod zombies|battlefield 1|counter strike 2|valorant|overwatch 2|apex legends|fortnite|pubg|warframe|destiny 2|borderlands 2|borderlands 3|cyberpunk 2077|gta san andreas|gta vice city|gta 4|gta 5|red dead 1|red dead 2|max payne 1|max payne 2|metal gear solid|mgs 3 snake eater|devil may cry 3|devil may cry 5"
  local dj6 = "street fighter 2|street fighter 6|tekken 3|tekken 7|tekken 8|mortal kombat 2|mortal kombat 11|mortal kombat 1|king of fighters|guilty gear strive|smash bros melee|smash ultimate|dragon ball fz|sparking zero|gran turismo 2|gran turismo 4|gran turismo 7|need for speed mw|forza horizon 5|burnout 3|wipeout pure|f zero gx|rocket league|fifa 23|ea fc 24|pes 6|nba 2k24|tony hawk pro 2|age of empires 2|age of empires 4|starcraft 1|starcraft 2|warcraft 3|civilization 6|heroes might 3|xcom 2|fire emblem 3h|advance wars|into the breach|balatro|slay the spire|vampire survivors|binding of isaac|enter gungeon|risk of rain 2|tetris|pac man|galaga|space invaders|contra|metal slug 1|metal slug 3|metal slug x|streets of rage 2|streets of rage 4|tmnt shredder|sunset riders|cadillacs dino|final fight|bomberman|worms armageddon|rayman 2|ape escape|jak and daxter|ratchet clank|sly cooper|god of war 1|god of war 2|god of war 2018|gow ragnarok|last of us 1|last of us 2|uncharted 2|uncharted 4|ghost of tsushima|horizon zero dawn"

  juegos_db = {}
  local bloques_j = {dj1, dj2, dj3, dj4, dj5, dj6}
  for b = 1, 6 do
    local tmp = dividir_pipe(bloques_j[b])
    for k = 1, #tmp do add(juegos_db, tmp[k]) end
  end
  cats_db = dividir_pipe(dict_categorias_str)

  cats_lang_raw = {
    -- 1. es (espanol)
    "victorias|muertes|niveles|misiones|objetos|vueltas|jefes|cafe|libros|cofres|estrellas|monedas|gemas|pociones|armas|armaduras|hechizos|habilidades|logros|trofeos|secretos|llaves|mapas|cristales|almas|runas|corazones|vidas|puntos|combos|partidas|derrotas|empates|records|tiempos|medallas|cartas|mascotas|monturas|construcc.|cultivos|peces|minerales|recetas|pociones+|encuentros|portales|torres|mazmorras|dragones|desafios|rangos|capitulos|finales|horas",
    -- 2. en (english)
    "wins|deaths|levels|quests|items|laps|bosses|coffee|books|chests|stars|coins|gems|potions|weapons|armor|spells|skills|achievem.|trophies|secrets|keys|maps|crystals|souls|runes|hearts|lives|points|combos|matches|losses|draws|records|times|medals|cards|pets|mounts|buildings|crops|fish|minerals|recipes|potions+|encounters|portals|towers|dungeons|dragons|challenges|ranks|chapters|endings|hours",
    -- 3. pl (polski)
    "wygrane|zgony|poziomy|misje|przedmioty|okrazenia|bossowie|kawa|ksiazki|skrzynie|gwiazdy|monety|klejnoty|mikstury|bronie|zbroje|zaklecia|umiejetn.|osiagn.|trofea|sekrety|klucze|mapy|krysztaly|dusze|runy|serca|zycia|punkty|kombo|mecze|porazki|remisy|rekordy|czasy|medale|karty|zwierzaki|wierzch.|budynki|plony|ryby|mineraly|przepisy|mikstury+|spotkania|portale|wieze|lochy|smoki|wyzwania|rangi|rozdzialy|zakoncz.|godziny",
    -- 4. ru (russian)
    "pobedy|smerti|urovni|kvesty|predmety|krugi|bossy|kofe|knigi|sunduki|zvezdy|monety|samocvety|zelya|oruzhie|bronya|zaklinan.|navyki|dostizh.|trofei|sekrety|klyuchi|karty|kristally|dushi|runy|serdca|zhizni|ochki|kombo|matchi|porazhen.|nichyi|rekordy|vremya|medali|kartochki|pitomcy|skakuny|postroyki|urozhay|ryba|mineraly|recepty|zelya+|vstrechi|portaly|bashni|podzemel.|drakony|ispytan.|rangi|glavy|koncovki|chasy",
    -- 5. pt (portugues)
    "vitorias|mortes|niveis|missoes|itens|voltas|chefes|cafe|livros|baus|estrelas|moedas|gemas|pocoes|armas|armaduras|feiticos|habilid.|conquistas|trofeus|segredos|chaves|mapas|cristais|almas|runas|coracoes|vidas|pontos|combos|partidas|derrotas|empates|recordes|tempos|medalhas|cartas|mascotes|montarias|construc.|cultivos|peixes|minerais|receitas|pocoes+|encontros|portais|torres|masmorras|dragoes|desafios|ranques|capitulos|finais|horas",
    -- 6. it (italiano)
    "vittorie|morti|livelli|missioni|oggetti|giri|boss|caffe|libri|forzieri|stelle|monete|gemme|pozioni|armi|armature|incantes.|abilita|obiettivi|trofei|segreti|chiavi|mappe|cristalli|anime|rune|cuori|vite|punti|combo|partite|sconfitte|pareggi|record|tempi|medaglie|carte|cuccioli|cavalcat.|costruz.|colture|pesci|minerali|ricette|pozioni+|incontri|portali|torri|segrete|draghi|sfide|ranghi|capitoli|finali|ore",
    -- 7. fr (francais)
    "victoires|morts|niveaux|quetes|objets|tours|boss|cafe|livres|coffres|etoiles|pieces|gemmes|potions|armes|armures|sorts|compet.|succes|trophees|secrets|cles|cartes|cristaux|ames|runes|coeurs|vies|points|combos|matchs|defaites|egalites|records|temps|medailles|cartes+|familiers|montures|batiments|recoltes|poissons|minerais|recettes|potions+|rencontres|portails|tours+|donjons|dragons|defis|rangs|chapitres|fins|heures",
    -- 8. jp (nihongo)
    "shouri|shibou|reberu|kuesuto|aitemu|shuu|bosu|koohii|hon|takarabako|hoshi|koin|houseki|pooshon|buki|bougu|mahou|sukiru|jisseki|torofii|himitsu|kagi|chizu|suishou|tamashii|ruun|haato|zanki|pointo|konbo|shiai|haiboku|hikiwake|kiroku|taimu|medaru|kaado|petto|norimono|kenchiku|sakumotsu|sakana|kouseki|reshipi|pooshon+|souguu|pootaru|tou|danjon|doragon|chousen|ranku|shou|endingu|jikan",
    -- 9. cn (zhongwen)
    "shengli|siwang|dengji|renwu|wupin|quanshu|shouling|kafei|shuji|baoxiang|xingxing|jinbi|baoshi|yaoshui|wuqi|hujia|fashu|jineng|chengjiu|jiangbei|mimi|yaoshi|ditu|shuijing|linghun|fuwen|xin|shengming|fenshu|lianji|bisai|shibai|pingju|jilu|shijian|jiangpai|kapai|chongwu|zuoqi|jianzhu|zuowu|yulei|kuangshi|peifang|yaoshui+|zaoyu|chuansong|gaota|dixia|julong|tiaozhan|duanwei|zhangjie|jieju|xiaoshi",
    -- 10. kr (hangugeo)
    "seungri|samang|rebel|kweseuteu|aitem|bakhwi|boseu|keopi|chaek|sangja|byeol|koin|boseok|posyeon|mugi|bangeogu|mabeop|seukil|eopjeok|teuropi|bimil|yeolsoe|jido|sujeong|yeonghon|run|hateu|saengmyeong|jeomsu|kombo|gyeonggi|paebae|mugim|girok|sigan|medal|kadeu|paet|talseung|geonchuk|jakmul|mulgogi|gwangseok|resipi|posyeon+|jou|potal|tap|deonjeon|deuraegon|dojeon|raengkeu|jang|ending|sigan+",
    -- 11. tr (turkce)
    "zaferler|olumler|seviyeler|gorevler|esyalar|turlar|patronlar|kahve|kitaplar|sandiklar|yildizlar|paralar|taslar|iksirler|silahlar|zirhlar|buyuler|beceriler|basarilar|kupalar|sirlar|anahtarlar|haritalar|kristaller|ruhlar|runler|kalpler|canlar|puanlar|kombolar|maclar|yenilgiler|berabere|rekorlar|sureler|madalyalar|kartlar|evcil|binekler|yapilar|ekinler|baliklar|madenler|tarifler|iksirler+|karsilasma|portallar|kuleler|zindanlar|ejderhalar|meydan|rutbeler|bolumler|sonlar|saatler",
    -- 12. de (deutsch)
    "siege|tode|level|quests|objekte|runden|bosse|kaffee|bucher|truhen|sterne|munzen|edelst.|tranke|waffen|rustung|zauber|fahigk.|erfolge|trophaen|geheimn.|schlussel|karten|kristalle|seelen|runen|herzen|leben|punkte|kombos|spiele|niederl.|unentsch.|rekorde|zeiten|medaillen|karten+|haustiere|reittiere|gebaude|ernte|fische|erze|rezepte|tranke+|begegn.|portale|turme|verliese|drachen|herausf.|range|kapitel|enden|stunden",
    -- 13. ar (al-arabiyya)
    "intisar|wafayat|mustawayat|maham|ashya|dawrat|zuama|qahwa|kutub|sanadiq|nujum|umlat|jawahir|jurat|asliha|duru|sihr|maharat|injazat|kuus|asrar|mafatih|kharait|ballurat|arwah|rumuz|qulub|hayat|niqat|kombo|mubariyat|hazaim|taadul|arqam|awqat|midaliyat|bitaqat|hayawanat|marakib|mabani|mahasil|asmak|maadin|wasafat|jurat+|muwajahat|bawwabat|abraj|zanazin|tinnin|tahaddiyat|rutab|fusul|nihayat|saat",
    -- 14. hi (hindi)
    "jeet|maut|star|mission|vastuen|chakkar|boss|coffee|kitaben|sandook|tare|sikke|ratna|dava|hathiyar|kavach|jadoo|kaushal|uplabdhi|trophy|rahasya|chabi|nakshe|crystal|aatma|rune|dil|jeevan|ank|combo|match|haar|barabari|record|samay|padak|card|paltu|sawari|imarat|fasal|machli|khanij|vidhi|dava+|muqabla|dwar|minar|tehkhaana|dragon|chunauti|pad|adhyay|ant|ghante",
    -- 15. nl (nederlands)
    "zeges|doden|levels|missies|items|rondes|bazen|koffie|boeken|kisten|sterren|munten|stenen|drankjes|wapens|harnassen|spreuken|vaardigh.|prestaties|trofeeen|geheimen|sleutels|kaarten|kristallen|zielen|runen|harten|levens|punten|combos|wedstrijd|verlies|gelijk|records|tijden|medailles|kaarten+|huisdier|rijdier|gebouwen|gewassen|vissen|mineralen|recepten|drankjes+|ontmoet.|portalen|torens|kerkers|draken|uitdag.|rangen|hoofdst.|eindes|uren",
    -- 16. sv (svenska)
    "vinster|dodsfall|nivaer|uppdrag|foremal|varv|bossar|kaffe|bocker|kistor|stjarnor|mynt|adelst.|drycker|vapen|rustning|besvarj.|fardigh.|framsteg|trofeer|hemligh.|nycklar|kartor|kristaller|sjalar|runor|hjartan|liv|poang|kombos|matcher|forluster|oavgjort|rekord|tider|medaljer|kort|husdjur|riddjur|byggnad.|skordar|fiskar|mineraler|recept|drycker+|moten|portaler|torn|fangelser|drakar|utmaning|ranker|kapitel|slut|timmar",
    -- 17. id (bahasa)
    "menang|mati|level|misi|item|putaran|bos|kopi|buku|peti|bintang|koin|permata|ramuan|senjata|zirah|sihir|keahlian|prestasi|trofi|rahasia|kunci|peta|kristal|jiwa|rune|hati|nyawa|poin|kombo|laga|kalah|seri|rekor|waktu|medali|kartu|peliharaan|tunggang|bangunan|panen|ikan|mineral|resep|ramuan+|pertemuan|portal|menara|penjara|naga|tantangan|peringkat|bab|akhir|jam",
    -- 18. vi (tieng viet)
    "thang|chet|cap do|nhiem vu|vat pham|vong|trum|ca phe|sach|ruong|ngoi sao|xu|da quy|thuoc|vu khi|giap|phep|ky nang|thanh tuu|cup|bi mat|chia khoa|ban do|pha le|linh hon|co ngu|trai tim|mang|diem|combo|tran dau|thua|hoa|ky luc|thoi gian|huy chuong|the bai|thu cung|thu cuoi|cong trinh|nong san|ca|khoang san|cong thuc|thuoc+|cham tran|cong|thap|ham nguc|rong|thu thach|hang|chuong|ket thuc|gio"
  }

  cats_lang = {}
  for l = 1, 18 do
    cats_lang[l] = dividir_pipe(cats_lang_raw[l])
  end


  idioma = 1
  nombre_usuario = "gamer"
  tema_idx = 1
  ui_estilo = 1
  ui_zoom = 0
  modo_animo = 0
  emocion_fija = 0
  tema_auto_juego = 1

  btn_cfg = {4, 5, 1, 0, 2}

  mis_juegos = {}
  juego_sel = 1
  juego_activo = 1

  cat_cursor = 1
  cat_scroll = 0
  negativo_habilitado = false
  confirm_neg_abierta = false
  confirm_neg_cursor = 2

  busq_texto = ""
  busq_resultados = {}
  busq_cursor = 1
  busq_foco = 1
  tk_x = 1
  tk_y = 1
  tk_pag = 1

  opt_cursor = 1
  opt_scroll = 0
  sub_btn_abierta = false
  sub_btn_cursor = 1
  creditos_y = 128
  bloqueo_input = 0
  confirm_reset_abierta = false
  confirm_reset_cursor = 2

  ranita_anim = 0
  emocion_actual = 1
  crono_emocion = 0
  aviso_msg = ""
  aviso_t = 0
  reloj_str = "00:00:00"

  frases_animo = {
    "gran partida!", "nice play!", "dobra gra!", "otlichno!", "boa jogada!",
    "ottimo gioco!", "bien joue!", "ii ne!", "hen bang!", "jalhaesseo!",
    "harika oyun!", "sehr gut!", "mumtaz!", "bahut badhiya!", "goed bezig!",
    "bra spelat!", "keren!", "tuyet voi!"
  }
  frases_animo2 = {
    "sigue asi!", "keep going!", "tak trzymaj!", "tak derzhat!", "continue assim!",
    "continua cosi!", "continue!", "ganbatte!", "jiayou!", "hwaiting!",
    "devam et!", "weiter so!", "istamir!", "lage raho!", "ga zo door!",
    "fortsatt sa!", "lanjutkan!", "co len!"
  }
  ranita_oculta = 0
  inactivo_t = 0
  animo_timer = 0
  boot_ok = false
  cat_anim_y = 0
  cat_anim_x = 0
  marquee_t = 0
end
-- =========================================================
-- parte 2a: motor de guardado instantaneo (sin pcall)
-- =========================================================

function ch_a_num(ch)
  for i = 1, #comp_dict do
    if sub(comp_dict, i, i) == ch then return i end
  end
  return 1
end

function num_a_ch(n)
  if n >= 1 and n <= #comp_dict then return sub(comp_dict, n, n) end
  return " "
end

function empaquetar_4ch(str)
  local c1 = ch_a_num(sub(str, 1, 1))
  local c2 = ch_a_num(sub(str, 2, 2))
  local c3 = ch_a_num(sub(str, 3, 3))
  local c4 = ch_a_num(sub(str, 4, 4))
  local alto = c1 + (c2 * 64)
  local bajo = c3 + (c4 * 64)
  return alto + (bajo / 16384)
end

function desempaquetar_4ch(val)
  local v = val or 0
  if v < 0 then v = 0 end
  local alto = flr(v)
  local bajo = flr((v - alto) * 16384 + 0.5)
  local c1 = alto % 64
  local c2 = flr(alto / 64) % 64
  local c3 = bajo % 64
  local c4 = flr(bajo / 64) % 64
  return num_a_ch(c1) .. num_a_ch(c2) .. num_a_ch(c3) .. num_a_ch(c4)
end

function crear_objeto_juego(id_j, nom_custom)
  local nom = nom_custom or "juego"
  if id_j and id_j > 0 and juegos_db[id_j] then
    nom = juegos_db[id_j]
  end
  return {
    id_juego = id_j or 0,
    nombre = nom,
    cats = {1, 2, 3, 4, 5, 6, 7},
    vals = {0, 0, 0, 0, 0, 0, 0}
  }
end

function guardar_datos()
  local cfg0 = 1000 + idioma + (tema_idx * 32) + (ui_estilo * 1024) + (modo_animo * 8192)
  local sub0 = emocion_fija + (tema_auto_juego * 32) + (ranita_oculta * 64) + (ui_zoom * 128)
  dset(0, cfg0 + (sub0 / 256))

  local b_pack = btn_cfg[1] + (btn_cfg[2] * 8) + (btn_cfg[3] * 64) + (btn_cfg[4] * 512) + (btn_cfg[5] * 4096)
  dset(1, b_pack + (#mis_juegos / 16))

  local nu = nombre_usuario or "gamer"
  dset(2, empaquetar_4ch(sub(nu, 1, 4)))
  dset(3, empaquetar_4ch(sub(nu, 5, 8)))
  dset(4, empaquetar_4ch(sub(nu, 9, 12)))

  for j = 1, 4 do
    local g = mis_juegos[j]
    if g then
      local n_cats = min(#g.cats, 12)
      if g.id_juego and g.id_juego > 0 then
        dset(4 + j, g.id_juego + (n_cats / 32))
      else
        dset(4 + j, -empaquetar_4ch(sub(g.nombre, 1, 4)))
      end
    else
      dset(4 + j, 0)
    end
  end

  local slot = 9
  for j = 1, 4 do
    local g = mis_juegos[j]
    if g then
      local n_cats = min(#g.cats, 12)
      if (not g.id_juego or g.id_juego == 0) and slot <= 62 then
        dset(slot, n_cats)
        slot = slot + 1
        dset(slot, empaquetar_4ch(sub(g.nombre, 5, 8)))
        slot = slot + 1
      end
      for c = 1, n_cats do
        if slot <= 63 then
          local cid = min(max(g.cats[c] or 1, 1), 60)
          local cval = min(max(flr(g.vals[c] or 0), 0), 32760)
          dset(slot, cval + (cid / 64))
          slot = slot + 1
        end
      end
    end
  end
  while slot <= 63 do
    dset(slot, 0)
    slot = slot + 1
  end
end
-- =========================================================
-- parte 2b: lectura de datos guardados (64 slots)
-- =========================================================

function cargar_datos()
  local v0 = dget(0) or 0
  local ent0 = flr(v0)

  if ent0 >= 1000 and ent0 < 20000 then
    local base0 = ent0 - 1000
    idioma = base0 % 32
    if idioma < 1 or idioma > 18 then idioma = 1 end
    tema_idx = flr(base0 / 32) % 32
    if tema_idx < 1 or tema_idx > 24 then tema_idx = 1 end
    ui_estilo = flr(base0 / 1024) % 8
    if ui_estilo < 1 or ui_estilo > 7 then ui_estilo = 1 end
    modo_animo = flr(base0 / 8192) % 2

    local dec0 = flr((v0 - ent0) * 256 + 0.5)
    emocion_fija = dec0 % 32
    if emocion_fija > 17 then emocion_fija = 0 end
    tema_auto_juego = flr(dec0 / 32) % 2
    ranita_oculta = flr(dec0 / 64) % 2
    ui_zoom = flr(dec0 / 128) % 2

    local v1 = dget(1) or 0
    local ent1 = flr(v1)
    if ent1 > 0 then
      btn_cfg[1] = ent1 % 8
      btn_cfg[2] = flr(ent1 / 8) % 8
      btn_cfg[3] = flr(ent1 / 64) % 8
      btn_cfg[4] = flr(ent1 / 512) % 8
      btn_cfg[5] = flr(ent1 / 4096) % 8
      for i = 1, 5 do
        if btn_cfg[i] < 0 or btn_cfg[i] > 5 then btn_cfg[i] = 4 end
      end
    end
    local tot_juegos = min(flr((v1 - ent1) * 16 + 0.5), 4)

    local nu = desempaquetar_4ch(dget(2)) .. desempaquetar_4ch(dget(3)) .. desempaquetar_4ch(dget(4))
    nu = limpiar_espacios_der(nu)
    nombre_usuario = (#nu > 0) and nu or "gamer"

    mis_juegos = {}
    local slot = 9
    for j = 1, tot_juegos do
      local vj = dget(4 + j) or 0
      if vj > 0 then
        local id_j = flr(vj)
        local n_cats = min(flr((vj - id_j) * 32 + 0.5), 12)
        if n_cats < 1 then n_cats = 7 end
        local g = crear_objeto_juego(id_j, nil)
        g.cats = {}
        g.vals = {}
        for c = 1, n_cats do
          if slot <= 63 then
            local sc = dget(slot) or 0
            slot = slot + 1
            local cval = flr(sc)
            local cid = flr((sc - cval) * 64 + 0.5)
            if cid < 1 or cid > 60 then cid = c end
            add(g.cats, cid)
            add(g.vals, max(0, cval))
          end
        end
        add(mis_juegos, g)
      elseif vj < 0 then
        local p1 = limpiar_espacios_der(desempaquetar_4ch(-vj))
        local n_cats = 7
        local p2 = ""
        if slot <= 62 then
          n_cats = min(max(flr(dget(slot) or 7), 1), 12)
          slot = slot + 1
          p2 = limpiar_espacios_der(desempaquetar_4ch(dget(slot) or 0))
          slot = slot + 1
        end
        local g = crear_objeto_juego(0, p1 .. p2)
        g.cats = {}
        g.vals = {}
        for c = 1, n_cats do
          if slot <= 63 then
            local sc = dget(slot) or 0
            slot = slot + 1
            local cval = flr(sc)
            local cid = flr((sc - cval) * 64 + 0.5)
            if cid < 1 or cid > 60 then cid = c end
            add(g.cats, cid)
            add(g.vals, max(0, cval))
          end
        end
        add(mis_juegos, g)
      end
    end
    estado = 2
  else
    estado = 0
  end
end

function borrar_todo_guardado()
  for i = 0, 63 do
    dset(i, 0)
  end
  mis_juegos = {}
  juego_sel = 1
  juego_activo = 1
  idioma = 1
  nombre_usuario = "gamer"
  tema_idx = 1
  ui_estilo = 1
  ui_zoom = 0
  modo_animo = 0
  emocion_fija = 0
  ranita_oculta = 0
  tema_auto_juego = 1
  btn_cfg = {4, 5, 1, 0, 2}
  sub_btn_abierta = false
  confirm_reset_abierta = false
  mostrar_aviso("reset ok!", 45)
  cambiar_estado(0)
end

-- =========================================================
-- parte 3a: bucle principal (_update) y reloj seguro
-- =========================================================

function cambiar_estado(nuevo_est)
  estado_prev = estado
  estado = nuevo_est
  trans_t = 6
  bloqueo_input = 8
end

function mostrar_aviso(txt, dur)
  aviso_msg = txt
  aviso_t = dur or 45
end

function _update()
  if not boot_ok then
    boot_ok = true
    cartdata("counter_games_xtree")
    cargar_datos()
  end

  local h = flr(tonum(stat(93)) or 0)
  local m = flr(tonum(stat(94)) or 0)
  local s = flr(tonum(stat(95)) or 0)
  local sh = tostr(h) if #sh < 2 then sh = "0" .. sh end
  local sm = tostr(m) if #sm < 2 then sm = "0" .. sm end
  local ss = tostr(s) if #ss < 2 then ss = "0" .. ss end
  reloj_str = sh .. ":" .. sm .. ":" .. ss

  marquee_t = (marquee_t + 1) % 30000
  if aviso_t > 0 then aviso_t = aviso_t - 1 end
  if trans_t > 0 then trans_t = trans_t - 1 end
  if modal_anim > 0 then modal_anim = modal_anim - 1 end
  if bloqueo_input > 0 then bloqueo_input = bloqueo_input - 1 end
  if abs(cat_anim_y) > 0.5 then cat_anim_y = cat_anim_y * 0.65 else cat_anim_y = 0 end
  if abs(cat_anim_x) > 0.5 then cat_anim_x = cat_anim_x * 0.65 else cat_anim_x = 0 end

  if led_anim > 0 then
    led_anim = led_anim + 2
    if led_anim > 48 then led_anim = 0 end
  end

  ranita_anim = (ranita_anim + 1) % 60
  local hay_input = btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5)
  if hay_input then
    inactivo_t = 0
  else
    inactivo_t = min(inactivo_t + 1, 1000)
  end

  if emocion_fija >= 1 and emocion_fija <= 17 then
    emocion_actual = emocion_fija
  else
    if inactivo_t >= 390 then
      emocion_actual = 6
    else
      if hay_input and emocion_actual == 6 then
        emocion_actual = 4
        crono_emocion = 0
      end
      crono_emocion = crono_emocion + 1
      if crono_emocion >= 450 then
        crono_emocion = 0
        local nueva_e = 1 + flr(rnd(17))
        if nueva_e == 6 then nueva_e = 1 + flr(rnd(5)) end
        emocion_actual = nueva_e
      end
    end
  end

  local h = flr(tonum(stat(93)) or 0)
  local m = flr(tonum(stat(94)) or 0)
  local s = flr(tonum(stat(95)) or 0)
  local sh = tostr(h) if #sh < 2 then sh = "0" .. sh end
  local sm = tostr(m) if #sm < 2 then sm = "0" .. sm end
  local ss = tostr(s) if #ss < 2 then ss = "0" .. ss end
  reloj_str = sh .. ":" .. sm .. ":" .. ss

  if btn(5) and btnp(0) and estado >= 2 and estado != 7 then
    creditos_y = 128
    cambiar_estado(7)
    return
  end

  if bloqueo_input > 0 then return end

  if estado == 0 then
    if btnp(2) then
      idioma = idioma - 1
      if idioma < 1 then idioma = 18 end
    elseif btnp(3) then
      idioma = idioma + 1
      if idioma > 18 then idioma = 1 end
    elseif btnp(4) then
      nombre_usuario = ""
      tk_x = 1
      tk_y = 1
      tk_pag = 1
      cambiar_estado(1)
    end
  elseif estado == 1 then
    actualizar_teclado_nombre()
    if modo_animo == 1 then
      animo_timer = animo_timer + 1
      if animo_timer > 320 then
        animo_timer = 0
        local f_tbl = (rnd(2) < 1) and frases_animo or frases_animo2
        mostrar_aviso(f_tbl[idioma] or "nice!", 75)
        if emocion_fija == 0 and inactivo_t < 390 then
          local em_pos = {4, 7, 8, 12, 15}
          emocion_actual = em_pos[1 + flr(rnd(#em_pos))]
          crono_emocion = 0
        end
      end
    end
  elseif estado == 2 then
    actualizar_menu_principal()
    if modo_animo == 1 then
      animo_timer = animo_timer + 1
      if animo_timer > 320 then
        animo_timer = 0
        mostrar_aviso(frases_animo[idioma] or "nice!", 75)
        if emocion_fija == 0 then emocion_actual = 4 crono_emocion = 0 end
      end
    end
  elseif estado == 3 then
    actualizar_buscador_juegos()
  elseif estado == 4 then
    actualizar_categorias_juego()
  elseif estado == 5 then
    actualizar_buscador_categorias()
  elseif estado == 6 then
    actualizar_opciones()
  elseif estado == 7 then
    creditos_y = creditos_y - 0.55
    if btn(2) then creditos_y = creditos_y + 1.2 end
    if btn(3) then creditos_y = creditos_y - 1.2 end
    if creditos_y < -230 or btnp(4) or btnp(5) then
      cambiar_estado(estado_prev or 2)
    end
  end
end
-- =========================================================
-- parte 3b: menu principal y teclado virtual
-- =========================================================

function actualizar_menu_principal()
  local k3 = 3
  local total_g = #mis_juegos
  local max_fila = total_g + 1

  if btn(5) then
    if btnp(3) and juego_sel >= 2 and juego_sel <= max_fila then
      deli(mis_juegos, juego_sel - 1)
      guardar_datos()
      if #mis_juegos == 0 then
        juego_sel = 1
      elseif juego_sel > #mis_juegos + 1 then
        juego_sel = #mis_juegos + 1
      end
      bloqueo_input = 6
      mostrar_aviso(tr(32), 40)
    end
    return
  end

  if btnp(2) then
    juego_sel = juego_sel - 1
    if juego_sel < 0 then juego_sel = max_fila end
  elseif btnp(3) then
    juego_sel = juego_sel + 1
    if juego_sel > max_fila then juego_sel = 0 end
  end

  if juego_sel == 0 and btnp(4) then
    opt_cursor = 1
    opt_scroll = 0
    sub_btn_abierta = false
    confirm_reset_abierta = false
    modal_anim = 6
    cambiar_estado(6)
    return
  end

  if juego_sel == 1 and btnp(4) then
    if total_g >= 4 then
      mostrar_aviso(tr(31), 45)
    else
      busq_texto = ""
      busq_cursor = 1
      busq_foco = 1
      tk_x = 1
      tk_y = 1
      tk_pag = 1
      filtrar_juegos_db()
      modal_anim = 6
      cambiar_estado(3)
    end
    return
  end

  if juego_sel >= 2 and juego_sel <= max_fila then
    local b_entrar = btn_cfg[k3] or 1
    if btnp(b_entrar) or btnp(4) then
      juego_activo = juego_sel - 1
      cat_cursor = 1
      cat_scroll = 0
      negativo_habilitado = false
      confirm_neg_abierta = false
      cambiar_estado(4)
      return
    end
  end
end


teclado_letras = {
  {"q","w","e","r","t","y","u","i","o","p"},
  {"a","s","d","f","g","h","j","k","l","-"},
  {"z","x","c","v","b","n","m","1","2","3"},
  {"esp","bor","123","ok"}
}

teclado_nums = {
  {"1","2","3","4","5","6","7","8","9","0"},
  {"+","-","*","/","=",".","_",":","!","?"},
  {"(",")","[","]","@","#","&","%","$","<"},
  {"esp","bor","abc","ok"}
}

function mover_cursor_teclado()
  local mat = (tk_pag == 1) and teclado_letras or teclado_nums
  local cols = #mat[tk_y]
  if btnp(0) then
    tk_x = tk_x - 1
    if tk_x < 1 then tk_x = cols end
  elseif btnp(1) then
    tk_x = tk_x + 1
    if tk_x > cols then tk_x = 1 end
  elseif btnp(2) then
    tk_y = tk_y - 1
    if tk_y < 1 then tk_y = 4 end
    tk_x = min(tk_x, #mat[tk_y])
  elseif btnp(3) then
    tk_y = tk_y + 1
    if tk_y > 4 then tk_y = 1 end
    tk_x = min(tk_x, #mat[tk_y])
  end
  return mat[tk_y][tk_x]
end

function actualizar_teclado_nombre()
  local tecla = mover_cursor_teclado()
  if btnp(4) then
    if tecla == "esp" then
      if #nombre_usuario < 12 then nombre_usuario = nombre_usuario .. " " end
    elseif tecla == "bor" then
      if #nombre_usuario > 0 then nombre_usuario = sub(nombre_usuario, 1, #nombre_usuario - 1) end
    elseif tecla == "123" or tecla == "abc" then
      tk_pag = (tk_pag == 1) and 2 or 1
      tk_x = 1
    elseif tecla == "ok" then
      nombre_usuario = limpiar_espacios_der(nombre_usuario)
      if #nombre_usuario == 0 then nombre_usuario = "gamer" end
      guardar_datos()
      cambiar_estado(2)
    else
      if #nombre_usuario < 12 then nombre_usuario = nombre_usuario .. tecla end
    end
  elseif btnp(5) then
    if #nombre_usuario > 0 then
      nombre_usuario = sub(nombre_usuario, 1, #nombre_usuario - 1)
    else
      cambiar_estado(0)
    end
  end
end
-- =========================================================
-- parte 4a: buscadores en vivo de juegos y categorias
-- =========================================================

function contiene_subcadena(texto, patron)
  if #patron == 0 then return true end
  if #patron > #texto then return false end
  for i = 1, #texto - #patron + 1 do
    if sub(texto, i, i + #patron - 1) == patron then return true end
  end
  return false
end

function filtrar_juegos_db()
  busq_resultados = {}
  local q = limpiar_espacios_der(busq_texto)
  for i = 1, #juegos_db do
    if contiene_subcadena(juegos_db[i], q) then
      add(busq_resultados, i)
      if #busq_resultados >= 45 then break end
    end
  end
  busq_cursor = (#busq_resultados > 0) and 1 or 0
end

function actualizar_buscador_juegos()
  if btnp(5) then
    if busq_foco == 2 then
      busq_foco = 1
    elseif #busq_texto > 0 then
      busq_texto = sub(busq_texto, 1, #busq_texto - 1)
      filtrar_juegos_db()
    else
      cambiar_estado(2)
    end
    return
  end

  if busq_foco == 1 then
    local tecla = mover_cursor_teclado()
    if btnp(4) then
      if tecla == "esp" then
        if #busq_texto < 16 then busq_texto = busq_texto .. " " end
        filtrar_juegos_db()
      elseif tecla == "bor" then
        if #busq_texto > 0 then
          busq_texto = sub(busq_texto, 1, #busq_texto - 1)
          filtrar_juegos_db()
        end
      elseif tecla == "123" or tecla == "abc" then
        tk_pag = (tk_pag == 1) and 2 or 1
        tk_x = 1
      elseif tecla == "ok" then
        busq_foco = 2
        busq_cursor = (#busq_resultados > 0) and 1 or 0
      else
        if #busq_texto < 16 then
          busq_texto = busq_texto .. tecla
          filtrar_juegos_db()
        end
      end
    end
  else
    local tot_r = #busq_resultados
    local tiene_custom = (#limpiar_espacios_der(busq_texto) > 0)
    local max_c = tot_r + (tiene_custom and 1 or 0)

    if btnp(2) then
      busq_cursor = busq_cursor - 1
      if busq_cursor < 0 then busq_cursor = max_c end
    elseif btnp(3) then
      busq_cursor = busq_cursor + 1
      if busq_cursor > max_c then busq_cursor = 0 end
    elseif btnp(4) then
      if busq_cursor == 0 then
        busq_foco = 1
      elseif busq_cursor <= tot_r then
        local id_elegido = busq_resultados[busq_cursor]
        if id_elegido then
          local ya_esta = false
          for j = 1, #mis_juegos do
            if mis_juegos[j].id_juego == id_elegido then ya_esta = true break end
          end
          if ya_esta then
            mostrar_aviso(tr(34), 40)
          else
            local nuevo_g = crear_objeto_juego(id_elegido, nil)
            add(mis_juegos, nuevo_g)
            guardar_datos()
            juego_sel = #mis_juegos + 1
            mostrar_aviso(tr(33), 45)
            cambiar_estado(2)
          end
        end
      elseif tiene_custom then
        local nuevo_g = crear_objeto_juego(0, limpiar_espacios_der(busq_texto))
        add(mis_juegos, nuevo_g)
        guardar_datos()
        juego_sel = #mis_juegos + 1
        mostrar_aviso(tr(33), 45)
        cambiar_estado(2)
      end
    end
  end
end


function cat_esta_activa(g, cid)
  for c = 1, #g.cats do
    if g.cats[c] == cid then return c end
  end
  return 0
end

function filtrar_cats_db()
  busq_resultados = {}
  local q = limpiar_espacios_der(busq_texto)
  for i = 1, #cats_db do
    if contiene_subcadena(cat_tr(i), q) or contiene_subcadena(cats_db[i], q) then
      add(busq_resultados, i)
    end
  end
  busq_cursor = (#busq_resultados > 0) and 1 or 0
end

function actualizar_buscador_categorias()
  local g = mis_juegos[juego_activo]
  if not g then cambiar_estado(2) return end

  if btnp(5) then
    if busq_foco == 2 then
      busq_foco = 1
    elseif #busq_texto > 0 then
      busq_texto = sub(busq_texto, 1, #busq_texto - 1)
      filtrar_cats_db()
    else
      cat_cursor = 1
      cat_scroll = 0
      cambiar_estado(4)
    end
    return
  end

  if busq_foco == 1 then
    local tecla = mover_cursor_teclado()
    if btnp(4) then
      if tecla == "esp" then
        if #busq_texto < 12 then busq_texto = busq_texto .. " " end
        filtrar_cats_db()
      elseif tecla == "bor" then
        if #busq_texto > 0 then
          busq_texto = sub(busq_texto, 1, #busq_texto - 1)
          filtrar_cats_db()
        end
      elseif tecla == "123" or tecla == "abc" then
        tk_pag = (tk_pag == 1) and 2 or 1
        tk_x = 1
      elseif tecla == "ok" then
        busq_foco = 2
        busq_cursor = (#busq_resultados > 0) and 1 or 0
      else
        if #busq_texto < 12 then
          busq_texto = busq_texto .. tecla
          filtrar_cats_db()
        end
      end
    end
  else
    local tot_r = #busq_resultados
    if btnp(2) then
      busq_cursor = busq_cursor - 1
      if busq_cursor < 0 then busq_cursor = tot_r end
    elseif btnp(3) then
      busq_cursor = busq_cursor + 1
      if busq_cursor > tot_r then busq_cursor = 0 end
    elseif btnp(4) then
      if busq_cursor == 0 then
        busq_foco = 1
      else
        local cid = busq_resultados[busq_cursor]
        if cid then
          local pos = cat_esta_activa(g, cid)
          if pos > 0 then
            if #g.cats <= 1 then
              mostrar_aviso("min 1 cat!", 35)
            else
              deli(g.cats, pos)
              deli(g.vals, pos)
              guardar_datos()
              mostrar_aviso("- " .. cat_tr(cid), 30)
            end
          else
            if #g.cats >= 12 then
              mostrar_aviso("max 12 cats!", 35)
            else
              add(g.cats, cid)
              add(g.vals, 0)
              guardar_datos()
              mostrar_aviso("+ " .. cat_tr(cid), 30)
            end
          end
        end
      end
    end
  end
end

-- =========================================================
-- parte 4b: contadores en tiempo real y menu de opciones
-- =========================================================

function actualizar_categorias_juego()
  local k1, k2, k4 = 1, 2, 4
  local g = mis_juegos[juego_activo]
  if not g then cambiar_estado(2) return end

  if confirm_neg_abierta then
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      confirm_neg_cursor = (confirm_neg_cursor == 1) and 2 or 1
    elseif btnp(4) then
      if confirm_neg_cursor == 1 then
        negativo_habilitado = true
        if g.vals[cat_cursor] > 0 then
          g.vals[cat_cursor] = g.vals[cat_cursor] - 1
          guardar_datos()
        end
        mostrar_aviso("-1 activo!", 35)
      end
      confirm_neg_abierta = false
    elseif btnp(5) then
      confirm_neg_abierta = false
    end
    return
  end

  local tot_c = #g.cats
  local prev_c = cat_cursor
  local es_moderno = (ui_estilo == 2 or ui_estilo == 3 or ui_estilo >= 5)
  local btn_prev = (ui_estilo == 3) and btnp(0) or btnp(2)
  local btn_next = (ui_estilo == 3) and btnp(1) or btnp(3)

  if es_moderno and ui_estilo == 3 then
    if btnp(2) then cat_cursor = 0 end
    if btnp(3) and cat_cursor == 0 and tot_c > 0 then cat_cursor = 1 end
  end

  if btn_prev then
    cat_cursor = cat_cursor - 1
    if cat_cursor < 0 then cat_cursor = tot_c end
    if cat_cursor != prev_c then
      cat_anim_y = -28
      cat_anim_x = -48
    end
  elseif btn_next then
    cat_cursor = cat_cursor + 1
    if cat_cursor > tot_c then cat_cursor = 0 end
    if cat_cursor != prev_c then
      cat_anim_y = 28
      cat_anim_x = 48
    end
  end

  local vis = 5
  if es_moderno then
    vis = (ui_zoom == 1) and 1 or 2
  end

  if cat_cursor <= cat_scroll and cat_cursor > 0 then
    cat_scroll = cat_cursor - 1
  elseif cat_cursor > cat_scroll + vis then
    cat_scroll = cat_cursor - vis
  elseif cat_cursor == 0 then
    cat_scroll = 0
  end

  local b_salir = btn_cfg[k4] or 0
  if btnp(b_salir) then
    negativo_habilitado = false
    cambiar_estado(2)
    return
  end

  if cat_cursor == 0 and btnp(4) then
    busq_texto = ""
    busq_cursor = 1
    busq_foco = 1
    tk_x = 1
    tk_y = 1
    tk_pag = 1
    filtrar_cats_db()
    modal_anim = 6
    cambiar_estado(5)
    return
  end

  if cat_cursor >= 1 and cat_cursor <= tot_c then
    local b_sumar = btn_cfg[k1] or 4
    local b_restar = btn_cfg[k2] or 5

    if btnp(b_sumar) then
      g.vals[cat_cursor] = min((g.vals[cat_cursor] or 0) + 1, 32760)
      guardar_datos()
      led_anim = 1
      if emocion_fija == 0 then emocion_actual = 4 crono_emocion = 0 end
      return
    end

    if btnp(b_restar) then
      if not negativo_habilitado then
        confirm_neg_abierta = true
        confirm_neg_cursor = 2
        modal_anim = 6
      else
        if (g.vals[cat_cursor] or 0) > 0 then
          g.vals[cat_cursor] = g.vals[cat_cursor] - 1
          guardar_datos()
        end
      end
      return
    end
  end
end


function actualizar_opciones()
  -- 1. Si esta abierta la confirmacion de Borrar Todo
  if confirm_reset_abierta then
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      confirm_reset_cursor = (confirm_reset_cursor == 1) and 2 or 1
    elseif btnp(4) then
      if confirm_reset_cursor == 1 then
        borrar_todo_guardado()
      else
        confirm_reset_abierta = false
      end
    elseif btnp(5) then
      confirm_reset_abierta = false
    end
    return
  end

  -- 2. Si esta abierta la subventana de Botones
  if sub_btn_abierta then
    if btnp(5) then
      sub_btn_abierta = false
      guardar_datos()
      return
    end
    if btnp(2) then
      sub_btn_cursor = sub_btn_cursor - 1
      if sub_btn_cursor < 1 then sub_btn_cursor = 6 end
    elseif btnp(3) then
      sub_btn_cursor = sub_btn_cursor + 1
      if sub_btn_cursor > 6 then sub_btn_cursor = 1 end
    end

    if sub_btn_cursor <= 5 then
      if btnp(0) then
        btn_cfg[sub_btn_cursor] = (btn_cfg[sub_btn_cursor] - 1) % 6
      elseif btnp(1) or btnp(4) then
        btn_cfg[sub_btn_cursor] = (btn_cfg[sub_btn_cursor] + 1) % 6
      end
    else
      if btnp(4) then
        btn_cfg = {4, 5, 1, 0, 2}
        mostrar_aviso("controles default!", 35)
      end
    end
    return
  end

  -- 3. Navegacion principal de Opciones (ahora 10 opciones)
  local max_opt = 11
  if btnp(2) then
    opt_cursor = opt_cursor - 1
    if opt_cursor < 1 then opt_cursor = max_opt end
  elseif btnp(3) then
    opt_cursor = opt_cursor + 1
    if opt_cursor > max_opt then opt_cursor = 1 end
  end

  if opt_cursor <= opt_scroll then
    opt_scroll = opt_cursor - 1
  elseif opt_cursor > opt_scroll + 5 then
    opt_scroll = opt_cursor - 5
  end

  if btnp(5) then
    guardar_datos()
    cambiar_estado(2)
    return
  end

  local izq = btnp(0)
  local der = btnp(1)
  local acc = btnp(4)

  if opt_cursor == 1 then
    if izq then idioma = (idioma - 2) % 18 + 1 end
    if der or acc then idioma = (idioma % 18) + 1 end
  elseif opt_cursor == 2 then
    if izq then ui_estilo = (ui_estilo - 2) % 7 + 1 end
    if der or acc then ui_estilo = (ui_estilo % 7) + 1 end
  elseif opt_cursor == 3 then
    if izq then tema_idx = (tema_idx - 2) % 24 + 1 end
    if der or acc then tema_idx = (tema_idx % 24) + 1 end
  elseif opt_cursor == 4 then
    if izq or der or acc then tema_auto_juego = (tema_auto_juego == 0) and 1 or 0 end
  elseif opt_cursor == 5 then
    if izq or der or acc then ui_zoom = (ui_zoom == 0) and 1 or 0 end
  elseif opt_cursor == 6 then
    if izq or der or acc then
      modo_animo = (modo_animo == 0) and 1 or 0
      if modo_animo == 1 then animo_timer = 290 end
    end
  elseif opt_cursor == 7 then
    if izq then emocion_fija = (emocion_fija - 1) % 18 end
    if der or acc then emocion_fija = (emocion_fija + 1) % 18 end
  elseif opt_cursor == 8 then
    if izq or der or acc then ranita_oculta = (ranita_oculta == 0) and 1 or 0 end
  elseif opt_cursor == 9 then
    if acc or der then
      sub_btn_abierta = true
      sub_btn_cursor = 1
      modal_anim = 6
    end
  elseif opt_cursor == 10 then
    if acc or der then
      creditos_y = 128
      cambiar_estado(7)
    end
  elseif opt_cursor == 11 then
    if acc or der then
      confirm_reset_abierta = true
      confirm_reset_cursor = 2
      modal_anim = 6
    end
  end
end

-- =========================================================
-- parte 5a: motor grafico (_draw), led perimetral y portadas
-- =========================================================

function obtener_paleta_activa()
  local k1, k2, k3, k4, k5, k6 = 1, 2, 3, 4, 5, 6
  local idx_p = tema_idx
  local genero = 0

  local g = nil
  if estado == 4 or estado == 5 then
    g = mis_juegos[juego_activo]
  elseif estado == 2 and juego_sel >= 2 then
    g = mis_juegos[juego_sel - 1]
  end

  if g and g.id_juego and g.id_juego > 0 then
    local id = g.id_juego
    if id <= 45 then genero = 1 idx_p = 3
    elseif id <= 85 then genero = 2 idx_p = 2
    elseif id <= 145 then genero = 3 idx_p = 4
    elseif id <= 190 then genero = 4 idx_p = 10
    elseif id <= 250 then genero = 5 idx_p = 8
    else genero = 6 idx_p = 9 end
  end

  if tema_auto_juego == 0 then idx_p = tema_idx end
  local p = paletas_temas[idx_p] or paletas_temas[k1]
  return p[k1], p[k2], p[k3], p[k4], p[k5], p[k6], idx_p, genero
end

function dibujar_borde_led()
  if led_anim <= 0 then return end
  local cols_led = {11, 10, 9, 8, 14, 12, 7}
  local c1 = cols_led[(flr(led_anim / 4) % #cols_led) + 1]
  local c2 = cols_led[((flr(led_anim / 4) + 1) % #cols_led) + 1]

  local prog = min(127, flr((led_anim / 48) * 140))
  line(0, 0, prog, 0, c1)
  line(0, 1, max(0, prog - 6), 1, c2)
  line(127, 127, 127 - prog, 127, c1)
  line(127, 126, min(127, 127 - prog + 6), 126, c2)
  line(127, 0, 127, prog, c1)
  line(126, 0, 126, max(0, prog - 6), c2)
  line(0, 127, 0, 127 - prog, c1)
  line(1, 127, 1, min(127, 127 - prog + 6), c2)
end

function dibujar_portada_aislada(x, y, genero, c_acc, c_txt)
  rectfill(x, y, x + 17, y + 17, 0)
  rect(x, y, x + 17, y + 17, c_acc)
  if genero == 1 then
    line(x + 4, y + 13, x + 13, y + 4, 7)
    line(x + 6, y + 9, x + 10, y + 13, 9)
    pset(x + 13, y + 4, 8)
  elseif genero == 2 then
    rectfill(x + 4, y + 4, x + 13, y + 7, 11)
    rectfill(x + 4, y + 8, x + 13, y + 13, 4)
  elseif genero == 3 then
    circfill(x + 8, y + 9, 4, 10)
    pset(x + 8, y + 4, 7) pset(x + 8, y + 14, 7)
  elseif genero == 4 then
    circfill(x + 8, y + 8, 5, 8)
    rectfill(x + 4, y + 9, x + 13, y + 13, 7)
    circfill(x + 8, y + 8, 2, 0)
    pset(x + 8, y + 8, 7)
  elseif genero == 5 then
    circ(x + 8, y + 8, 5, 12)
    line(x + 8, y + 2, x + 8, y + 14, 8)
    line(x + 2, y + 8, x + 14, y + 8, 8)
  else
    rectfill(x + 5, y + 4, x + 12, y + 9, 10)
    line(x + 8, y + 10, x + 8, y + 13, 10)
    line(x + 5, y + 14, x + 12, y + 14, 10)
  end
end

function dibujar_cabecera_hud(c_pan, c_txt, c_acc, idx_tema_act)
  rectfill(0, 0, 127, 15, c_pan)
  line(0, 15, 127, 15, c_acc)
  print("c.games xtree", 3, 2, c_txt)
  print(reloj_str, 93, 2, 7)
  local tag_id = "[" .. (cod_lang[idioma] or "es") .. "]"
  print(tag_id, 3, 9, c_acc)
  print("@" .. sub(nombre_usuario, 1, 8), 22, 9, 11)
  local t_abrev = "t:" .. sub(nombres_temas[idx_tema_act] or "cyb", 1, 4)
  print(t_abrev, 96, 9, 6)
end

function _draw()
  local c_bg, c_pan, c_txt, c_acc, c_atxt, c_led, idx_t_act, gen = obtener_paleta_activa()

  if estado == 0 then
    dibujar_selector_idioma()
  elseif estado == 1 then
    dibujar_registro_nombre(c_bg, c_pan, c_txt, c_acc, c_atxt)
  elseif estado == 2 then
    dibujar_menu_principal(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act, gen)
  elseif estado == 3 then
    dibujar_buscador_modal(c_bg, c_pan, c_txt, c_acc, c_atxt, false)
  elseif estado == 4 then
    dibujar_categorias_juego(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act, gen)
  elseif estado == 5 then
    dibujar_buscador_modal(c_bg, c_pan, c_txt, c_acc, c_atxt, true)
  elseif estado == 6 then
    dibujar_opciones(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act)
  elseif estado == 7 then
    dibujar_acercade()
  end

  dibujar_borde_led()

  if trans_t > 0 then
    local h_bar = trans_t * 10
    rectfill(0, 0, 127, h_bar, 0)
    rectfill(0, 127 - h_bar, 127, 127, 0)
  end

  if aviso_t > 0 then
    local aw = #aviso_msg * 4 + 10
    local ax = 64 - flr(aw / 2)
    rectfill(ax, 56, ax + aw, 68, 0)
    rect(ax, 56, ax + aw, 68, 11)
    print(aviso_msg, ax + 5, 60, 7)
  end
end
-- =========================================================
-- parte 5b: pantallas iniciales y 4 estilos de menu
-- =========================================================

function dibujar_selector_idioma()
  cls(0)
  rect(2, 2, 125, 125, 12)
  rectfill(4, 4, 123, 14, 1)
  print("counter games xtree v0.05", 12, 7, 7)

  local ini = max(1, min(idioma - 5, 18 - 10))
  for i = ini, min(18, ini + 10) do
    local ly = 20 + (i - ini) * 8
    local sel = (i == idioma)
    if sel then
      rectfill(6, ly - 1, 121, ly + 6, 14)
      print("> " .. lista_idiomas[i], 10, ly, 7)
    else
      print("  " .. lista_idiomas[i], 10, ly, 6)
    end
  end

  line(4, 112, 123, 112, 5)
  print("[" .. cod_lang[idioma] .. "] (a): ok", 34, 116, 11)
end

function dibujar_registro_nombre(c_bg, c_pan, c_txt, c_acc, c_atxt)
  local k2 = 2
  cls(c_bg)
  rect(2, 2, 125, 125, c_acc)
  rectfill(4, 4, 123, 15, c_pan)
  local lbl_nom = txt_ui[idioma][k2] or "tu nombre:"
  print(lbl_nom, 8, 7, c_txt)
  print("[" .. cod_lang[idioma] .. "]", 104, 7, 11)

  rectfill(8, 20, 119, 34, 0)
  rect(8, 20, 119, 34, 11)
  local cur = ((ranita_anim % 20) < 10) and "_" or ""
  print(nombre_usuario .. cur, 13, 25, 7)
  print(#nombre_usuario .. "/12", 98, 25, 5)

  dibujar_teclado_moderno(42, c_pan, c_txt, c_acc, c_atxt)
  dibujar_ranita(110, 112)
end

function texto_marquee(txt, max_ch, sel)
  if not sel or #txt <= max_ch then
    return sub(txt, 1, max_ch)
  end
  local exceso = #txt - max_ch
  local ciclo = 24 + (exceso * 12) + 24
  local t = marquee_t % ciclo
  local off = 0
  if t > 24 then
    off = min(exceso, flr((t - 24) / 12) + 1)
  end
  return sub(txt, 1 + off, max_ch + off)
end


function dibujar_menu_principal(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act, gen)
  cls(c_bg)
  dibujar_cabecera_hud(c_pan, c_txt, c_acc, idx_t_act)

  if juego_sel == 0 then
    rectfill(4, 18, 86, 27, c_acc)
    print("> [" .. tr(6) .. "]", 7, 20, c_atxt)
  else
    rect(4, 18, 86, 27, c_pan)
    print("  [" .. tr(6) .. "]", 7, 20, c_txt)
  end

  if juego_sel == 1 then
    rectfill(4, 30, 123, 40, c_acc)
    print("> [+] " .. tr(3), 8, 32, c_atxt)
  else
    rect(4, 30, 123, 40, c_acc)
    print("  [+] " .. tr(3), 8, 32, 11)
  end

  if #mis_juegos == 0 then
    rect(6, 45, 121, 108, c_pan)
    print("< " .. tr(4) .. " >", 38, 74, 6)
  else
    if ui_estilo == 1 then
      for i = 1, #mis_juegos do
        local ly = 44 + (i - 1) * 16
        local sel = (juego_sel == i + 1)
        local nom = mis_juegos[i].nombre
        if ui_zoom == 1 then nom = sub(nom, 1, 11) else nom = sub(nom, 1, 17) end
        if sel then
          rectfill(4, ly, 123, ly + 13, c_acc)
          print((ui_zoom == 1 and "\^w>" or "> ") .. nom .. " >", 7, ly + 4, c_atxt)
        else
          rectfill(4, ly, 123, ly + 13, c_pan)
          print((ui_zoom == 1 and "\^w " or "  ") .. nom, 7, ly + 4, c_txt)
        end
      end

    elseif ui_estilo == 2 then
      for i = 1, #mis_juegos do
        local col = (i - 1) % 2
        local fil = flr((i - 1) / 2)
        local cx = 4 + col * 61
        local cy = 44 + fil * 33
        local sel = (juego_sel == i + 1)
        rectfill(cx, cy, cx + 58, cy + 30, sel and c_acc or c_pan)
        rect(cx, cy, cx + 58, cy + 30, sel and 7 or c_acc)
        dibujar_portada_aislada(cx + 3, cy + 3, gen, c_acc, c_txt)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(mis_juegos[i].nombre, 4, sel)
          print("\^w" .. nom_m, cx + 23, cy + 8, sel and c_atxt or c_txt)
          local lbl_c = #mis_juegos[i].cats .. " " .. sub(tr(5), 1, 8)
          print(lbl_c, cx + 4, cy + 23, sel and c_atxt or 11)
        else
          local nom_m = texto_marquee(mis_juegos[i].nombre, 8, sel)
          print(nom_m, cx + 23, cy + 6, sel and c_atxt or c_txt)
          local lbl_c = #mis_juegos[i].cats .. " " .. sub(tr(5), 1, 5)
          print(lbl_c, cx + 23, cy + 16, sel and c_atxt or 11)
        end
      end

     elseif ui_estilo == 3 then
      for i = 1, #mis_juegos do
        local mx = 20 + (i - 1) * 29
        local my = 62
        local sel = (juego_sel == i + 1)
        local rad = (ui_zoom == 1) and (sel and 14 or 12) or (sel and 13 or 11)
        circfill(mx, my, rad, sel and c_acc or c_pan)
        circ(mx, my, rad, sel and 7 or c_acc)
        if ui_zoom == 1 then
          print("\^w" .. sub(mis_juegos[i].nombre, 1, 2), mx - 8, my - 2, sel and c_atxt or c_txt)
        else
          print(sub(mis_juegos[i].nombre, 1, 3), mx - 5, my - 2, sel and c_atxt or c_txt)
        end
      end
      local idx_g = max(1, juego_sel - 1)
      if mis_juegos[idx_g] then
        rectfill(6, 82, 121, 108, c_pan)
        rect(6, 82, 121, 108, c_acc)
        dibujar_portada_aislada(9, 86, gen, c_acc, c_txt)
        if ui_zoom == 1 then
          print("\^w" .. sub(mis_juegos[idx_g].nombre, 1, 10), 30, 88, 7)
          print(sub(tr(20), 1, 21), 30, 99, 11)
        else
          print(sub(mis_juegos[idx_g].nombre, 1, 18), 30, 88, 7)
          print(sub(tr(20), 1, 21), 30, 99, 11)
        end
      end

    elseif ui_estilo == 5 then
      local idx_g = max(1, juego_sel - 1)
      local g_act = mis_juegos[idx_g]
      local sel = (juego_sel >= 2)
      if g_act then
        rectfill(6, 44, 121, 108, sel and c_acc or c_pan)
        rect(6, 44, 121, 108, sel and 7 or c_acc)
        rectfill(10, 48, 46, 84, 0)
        rect(10, 48, 46, 84, sel and 7 or c_acc)
        dibujar_portada_aislada(19, 57, gen, c_acc, c_txt)
        local cat_txt = #g_act.cats .. " " .. sub(tr(5), 1, 11)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(g_act.nombre, 8, sel)
          print("\^w" .. nom_m, 51, 52, sel and c_atxt or 7)
          print(cat_txt, 51, 66, sel and c_atxt or 10)
        else
          local nom_m = texto_marquee(g_act.nombre, 16, sel)
          print(nom_m, 51, 52, sel and c_atxt or 7)
          print(cat_txt, 51, 64, sel and c_atxt or 10)
          print(sub(tr(20), 1, 16), 51, 75, sel and c_atxt or 11)
        end
        line(10, 89, 117, 89, sel and c_atxt or c_acc)
        for d = 1, #mis_juegos do
          local dx = 48 + (d - 1) * 9
          circfill(dx, 98, (d == idx_g) and 3 or 1, (d == idx_g) and 7 or 5)
        end
        print(idx_g .. "/" .. #mis_juegos, 96, 95, sel and c_atxt or 6)
      end

    elseif ui_estilo == 6 then
      for i = 1, #mis_juegos do
        local ly = 44 + (i - 1) * 16
        local sel = (juego_sel == i + 1)
        local nc = #mis_juegos[i].cats
        rectfill(4, ly, 123, ly + 13, sel and c_acc or c_pan)
        rectfill(4, ly, 7, ly + 13, sel and 7 or 11)
        local bar_w = min(24, nc * 2)
        rectfill(96, ly + 4, 96 + bar_w, ly + 9, sel and c_atxt or 11)
        rect(96, ly + 4, 120, ly + 9, sel and c_atxt or c_acc)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(mis_juegos[i].nombre, 10, sel)
          print("\^w" .. nom_m, 11, ly + 4, sel and c_atxt or c_txt)
        else
          local nom_m = texto_marquee(mis_juegos[i].nombre, 19, sel)
          print(nom_m, 11, ly + 4, sel and c_atxt or c_txt)
        end
      end

    elseif ui_estilo == 7 then
      for i = 1, #mis_juegos do
        local ly = 44 + (i - 1) * 16
        local sel = (juego_sel == i + 1)
        local tot_pts = 0
        for v = 1, #mis_juegos[i].vals do tot_pts = tot_pts + mis_juegos[i].vals[v] end
        rectfill(4, ly, 123, ly + 13, sel and c_pan or 0)
        rect(4, ly, 123, ly + 13, sel and 7 or c_acc)
        rect(6, ly + 2, 121, ly + 11, sel and c_acc or c_pan)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(mis_juegos[i].nombre, 8, sel)
          print("\^w" .. nom_m, 9, ly + 4, sel and 7 or c_txt)
          print("\^w" .. tot_pts, 118 - (#tostr(tot_pts) * 8), ly + 4, 10)
        else
          local nom_m = texto_marquee(mis_juegos[i].nombre, 11, sel)
          print("p" .. i .. ":" .. nom_m, 9, ly + 4, sel and 7 or c_txt)
          print(tostr(tot_pts), 118 - (#tostr(tot_pts) * 4), ly + 4, 10)
        end
      end

    else
      for i = 1, #mis_juegos do
        local ly = 44 + (i - 1) * 16
        local sel = (juego_sel == i + 1)
        local tot_pts = 0
        for v = 1, #mis_juegos[i].vals do tot_pts = tot_pts + mis_juegos[i].vals[v] end
        rectfill(4, ly, 123, ly + 13, sel and c_acc or 0)
        rect(4, ly, 123, ly + 13, c_acc)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(mis_juegos[i].nombre, 8, sel)
          print("\^w" .. nom_m, 7, ly + 4, sel and c_atxt or c_txt)
          print("\^w" .. tot_pts, 120 - (#tostr(tot_pts) * 8), ly + 4, sel and c_atxt or 10)
        else
          local nom_m = texto_marquee(mis_juegos[i].nombre, 12, sel)
          print("#" .. i .. " " .. nom_m, 7, ly + 4, sel and c_atxt or c_txt)
          print("[" .. tot_pts .. "]", 92, ly + 4, sel and c_atxt or 10)
        end
      end
    end
  end

  rectfill(0, 113, 127, 127, 0)
  line(0, 113, 127, 113, c_acc)
  print(tr(20), 3, 118, 6)
  dibujar_ranita(112, 114)
end

-- =========================================================
-- parte 6a: teclado moderno, buscador y pantalla de categorias
-- =========================================================

function dibujar_teclado_moderno(y_ini, c_pan, c_txt, c_acc, c_atxt)
  local mat = (tk_pag == 1) and teclado_letras or teclado_nums
  for r = 1, 4 do
    local cols = #mat[r]
    local w = flr(120 / cols)
    for c = 1, cols do
      local x = 4 + (c - 1) * w
      local y = y_ini + (r - 1) * 14
      local sel = (busq_foco == 1 and r == tk_y and c == tk_x)
      rectfill(x + 1, y, x + w - 2, y + 11, sel and c_acc or c_pan)
      if sel then rect(x, y - 1, x + w - 1, y + 12, 7) end
      local lbl = mat[r][c]
      local tx = x + flr((w - #lbl * 4) / 2)
      print(lbl, tx, y + 3, sel and c_atxt or c_txt)
    end
  end
end

function dibujar_fila_busq(x, y, w, h, txt, sel, marcado, es_cat, idx_n, c_pan, c_txt, c_acc, c_atxt)
  if ui_estilo == 2 then
    rectfill(x, y, x + w, y + h, sel and c_acc or c_pan)
    rect(x, y, x + w, y + h, sel and 7 or c_acc)
  elseif ui_estilo == 3 then
    rectfill(x + 2, y, x + w - 2, y + h, sel and c_acc or c_pan)
    rect(x + 1, y, x + w - 1, y + h, sel and 7 or c_acc)
  elseif ui_estilo == 4 then
    rectfill(x, y, x + w, y + h, sel and c_acc or 0)
    rect(x, y, x + w, y + h, c_acc)
  elseif ui_estilo == 5 or ui_estilo == 6 then
    rectfill(x, y, x + w, y + h, sel and c_acc or c_pan)
    rectfill(x, y, x + 2, y + h, sel and 7 or (marcado and 11 or c_acc))
  elseif ui_estilo == 7 then
    rectfill(x, y, x + w, y + h, sel and c_pan or 0)
    rect(x, y, x + w, y + h, sel and 7 or c_acc)
  else
    if sel then rectfill(x, y, x + w, y + h, c_acc) end
  end

  local col_t = sel and ((ui_estilo == 7) and 7 or c_atxt) or c_txt
  local pref = ""
  if es_cat then
    pref = marcado and "[x]" or "[ ]"
  elseif ui_estilo == 4 then
    pref = "#" .. idx_n .. " "
  else
    pref = sel and "> " or "  "
  end

  local ty = y + flr((h - 5) / 2) + 1
  if ui_zoom == 1 then
    local max_c = es_cat and 9 or 11
    local nom_m = texto_marquee(txt, max_c, sel)
    if es_cat then
      print(pref, x + 4, ty, sel and col_t or (marcado and 11 or 6))
      print("\^w" .. nom_m, x + 18, ty, col_t)
    else
      print("\^w" .. nom_m, x + 5, ty, col_t)
    end
  else
    local nom_m = texto_marquee(txt, 19, sel)
    if es_cat then
      print(pref, x + 4, ty, sel and col_t or (marcado and 11 or 6))
      print(nom_m, x + 18, ty, col_t)
    else
      print(pref .. nom_m, x + 4, ty, col_t)
    end
  end
end

function dibujar_buscador_modal(c_bg, c_pan, c_txt, c_acc, c_atxt, es_cat)
  cls(c_bg)
  local off = modal_anim * 6
  rectfill(3, 3 + off, 124, 124, 0)
  rect(3, 3 + off, 124, 124, c_acc)
  if modal_anim > 0 then return end

  local g = es_cat and mis_juegos[juego_activo] or nil
  rectfill(5, 5, 122, 14, c_pan)
  local tit = (es_cat and tr(5) or tr(3)) .. " (" .. tr(10) .. ")"
  print(sub(tit, 1, 21), 8, 7, 7)
  if es_cat and g then
    print(#g.cats .. "/12", 102, 7, 11)
  end

  local bar_sel = (busq_foco == 2 and busq_cursor == 0)
  rectfill(6, 17, 121, 28, bar_sel and c_acc or 0)
  rect(6, 17, 121, 28, (busq_foco == 1 or bar_sel) and 11 or c_acc)
  local cur_s = (busq_foco == 1) and "_" or ""
  print("> " .. busq_texto .. cur_s, 9, 20, bar_sel and c_atxt or 11)
  print(#busq_resultados, 108, 20, bar_sel and c_atxt or 6)

  local tec_on = (busq_foco == 1)
  local y_list = 30
  local h_list = tec_on and 31 or 89
  rectfill(6, y_list, 121, y_list + h_list, (ui_estilo == 4 or ui_estilo == 7) and 0 or c_pan)
  if not tec_on then rect(6, y_list, 121, y_list + h_list, c_acc) end

  local tot_r = #busq_resultados
  local tiene_custom = (not es_cat) and (#limpiar_espacios_der(busq_texto) > 0)
  local tot_items = tot_r + (tiene_custom and 1 or 0)

  if tot_items == 0 then
    print(es_cat and tr(35) or tr(36), 14, y_list + 12, 10)
  else
    local row_h = tec_on and 8 or ((ui_zoom == 1) and 13 or 11)
    local gap = tec_on and 1 or 1
    local vis = flr((h_list - 2) / (row_h + gap))
    local cur_pos = max(1, busq_cursor)
    local ini = max(1, min(cur_pos - flr(vis / 2), tot_items - vis + 1))

    for i = ini, min(tot_items, ini + vis - 1) do
      local ly = y_list + 2 + (i - ini) * (row_h + gap)
      local sel = (busq_foco == 2 and i == busq_cursor)
      if i <= tot_r then
        local id_item = busq_resultados[i]
        local nom_item = es_cat and cat_tr(id_item) or juegos_db[id_item]
        local marc = (es_cat and g) and (cat_esta_activa(g, id_item) > 0) or false
        dibujar_fila_busq(8, ly, 111, row_h, nom_item or "", sel, marc, es_cat, i, c_pan, c_txt, c_acc, c_atxt)
      else
        local nom_c = "[+] " .. limpiar_espacios_der(busq_texto)
        dibujar_fila_busq(8, ly, 111, row_h, nom_c, sel, false, false, i, c_pan, c_txt, c_acc, c_atxt)
      end
    end
  end

  if tec_on then
    dibujar_teclado_moderno(65, c_pan, c_txt, c_acc, c_atxt)
  else
    print("a:ok  ^:kb  b:back", 24, 120, 6)
  end
end


function dibujar_num_grande(txt, x, y, col, esc)
  local dig = {
    ["0"]={31,17,31}, ["1"]={0,31,0}, ["2"]={29,21,23}, ["3"]={21,21,31}, ["4"]={7,4,31},
    ["5"]={23,21,29}, ["6"]={31,21,29}, ["7"]={1,1,31}, ["8"]={31,21,31}, ["9"]={23,21,31}
  }
  local paso = esc * 4
  for i = 1, #txt do
    local ch = sub(txt, i, i)
    local m = dig[ch]
    local dx = x + (i - 1) * paso
    if m then
      for c = 1, 3 do
        local bits = m[c]
        for r = 0, 4 do
          if flr(bits / (2 ^ r)) % 2 == 1 then
            rectfill(dx + (c - 1) * esc, y + r * esc, dx + c * esc - 1, y + (r + 1) * esc - 1, col)
          end
        end
      end
    end
  end
end

function dibujar_categorias_juego(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act, gen)
  cls(c_bg)
  local g = mis_juegos[juego_activo]
  if not g then return end

  rectfill(0, 0, 127, 22, c_pan)
  line(0, 22, 127, 22, c_acc)
  dibujar_portada_aislada(3, 2, gen, c_acc, c_txt)
  print(sub(g.nombre, 1, 18), 24, 3, 7)
  print(tr(5) .. " (" .. #g.cats .. "/12)", 24, 12, c_txt)
  print("t:" .. sub(nombres_temas[idx_t_act], 1, 3), 102, 12, 11)

  if cat_cursor == 0 then
    rectfill(4, 25, 123, 34, c_acc)
    print("> [+] " .. tr(10) .. " cat.", 8, 27, c_atxt)
  else
    rect(4, 25, 123, 34, c_pan)
    print("  [+] " .. tr(10) .. " cat.", 8, 27, 11)
  end

  if ui_estilo == 2 then
    clip(0, 36, 127, 74)
    local off_y = flr(cat_anim_y)
    if ui_zoom == 1 then
      local idx = max(1, cat_cursor)
      if idx <= #g.cats then
        local cy = 38 + off_y
        local sel = (cat_cursor == idx)
        local cid = g.cats[idx]
        local cnom = sub(cat_tr(cid), 1, 13)
        local cval = tostr(g.vals[idx] or 0)
        rectfill(6, cy, 121, cy + 68, sel and c_acc or c_pan)
        rect(6, cy, 121, cy + 68, sel and 7 or c_acc)
        print("\^w" .. cnom, 12, cy + 8, sel and c_atxt or c_txt)
        line(12, cy + 20, 115, cy + 20, sel and c_atxt or c_acc)
        local esc = (#cval >= 5) and 2 or 3
        local nw = #cval * (esc * 4)
        dibujar_num_grande(cval, 64 - flr(nw / 2), cy + 32, sel and c_atxt or 10, esc)
      end
    else
      for slot = 0, 3 do
        local idx = cat_scroll + slot
        if idx >= 1 and idx <= #g.cats then
          local cy = 38 + (slot - 1) * 35 + off_y
          local sel = (cat_cursor == idx)
          local cid = g.cats[idx]
          local cnom = sub(cat_tr(cid), 1, 11)
          local cval = tostr(g.vals[idx] or 0)
          rectfill(6, cy, 121, cy + 32, sel and c_acc or c_pan)
          rect(6, cy, 121, cy + 32, sel and 7 or c_acc)
          print((sel and "> " or "  ") .. cnom, 10, cy + 5, sel and c_atxt or c_txt)
          print("#" .. idx, 10, cy + 20, sel and c_atxt or 6)
          local nw = #cval * 8
          dibujar_num_grande(cval, 116 - nw, cy + 11, sel and c_atxt or 10, 2)
        end
      end
    end
    clip()

  elseif ui_estilo == 3 then
    clip(0, 36, 127, 74)
    local off_x = flr(cat_anim_x)
    if ui_zoom == 1 then
      local idx = max(1, cat_cursor)
      if idx <= #g.cats then
        local mx = 64 + off_x
        local my = 72
        local sel = (cat_cursor == idx)
        local cid = g.cats[idx]
        local cnom = sub(cat_tr(cid), 1, 13)
        local cval = tostr(g.vals[idx] or 0)
        circfill(mx, my, 33, sel and c_acc or c_pan)
        circ(mx, my, 33, sel and 7 or c_acc)
        circ(mx, my, 31, sel and c_atxt or c_bg)
        print("\^w" .. cnom, mx - (#cnom * 4), my - 18, sel and c_atxt or c_txt)
        local esc = (#cval >= 4) and 2 or 3
        local nw = #cval * (esc * 4)
        dibujar_num_grande(cval, mx - flr(nw / 2), my - 2, sel and c_atxt or 10, esc)
      end
    else
      for slot = 0, 3 do
        local idx = cat_scroll + slot
        if idx >= 1 and idx <= #g.cats then
          local mx = 34 + (slot - 1) * 60 + off_x
          local my = 72
          local sel = (cat_cursor == idx)
          local cid = g.cats[idx]
          local cnom = sub(cat_tr(cid), 1, 10)
          local cval = tostr(g.vals[idx] or 0)
          circfill(mx, my, 27, sel and c_acc or c_pan)
          circ(mx, my, 27, sel and 7 or c_acc)
          print(cnom, mx - (#cnom * 2), my - 14, sel and c_atxt or c_txt)
          local nw = #cval * 8
          dibujar_num_grande(cval, mx - flr(nw / 2), my - 2, sel and c_atxt or 10, 2)
        end
      end
    end
    clip()

  elseif ui_estilo == 5 then
    clip(0, 36, 127, 74)
    local off_y = flr(cat_anim_y)
    if ui_zoom == 1 then
      local idx = max(1, cat_cursor)
      if idx <= #g.cats then
        local cy = 38 + off_y
        local sel = (cat_cursor == idx)
        local cnom = sub(cat_tr(g.cats[idx]), 1, 13)
        local val_n = g.vals[idx] or 0
        local cval = tostr(val_n)
        rectfill(6, cy, 121, cy + 68, sel and c_acc or c_pan)
        rect(6, cy, 121, cy + 68, sel and 7 or c_acc)
        print("\^w" .. cnom, 12, cy + 7, sel and c_atxt or c_txt)
        local bw = min(100, (val_n % 25) * 4)
        rect(12, cy + 20, 114, cy + 25, sel and c_atxt or c_acc)
        if bw > 0 then rectfill(13, cy + 21, 13 + bw, cy + 24, sel and 7 or 11) end
        local esc = (#cval >= 5) and 2 or 3
        dibujar_num_grande(cval, 64 - flr((#cval * esc * 4) / 2), cy + 33, sel and c_atxt or 10, esc)
      end
    else
      for slot = 0, 3 do
        local idx = cat_scroll + slot
        if idx >= 1 and idx <= #g.cats then
          local cy = 38 + (slot - 1) * 35 + off_y
          local sel = (cat_cursor == idx)
          local cnom = sub(cat_tr(g.cats[idx]), 1, 11)
          local val_n = g.vals[idx] or 0
          local cval = tostr(val_n)
          rectfill(6, cy, 121, cy + 32, sel and c_acc or c_pan)
          rect(6, cy, 121, cy + 32, sel and 7 or c_acc)
          print(cnom, 11, cy + 5, sel and c_atxt or c_txt)
          local bw = min(56, (val_n % 15) * 4)
          rect(11, cy + 19, 69, cy + 24, sel and c_atxt or c_acc)
          if bw > 0 then rectfill(12, cy + 20, 12 + bw, cy + 23, sel and 7 or 11) end
          dibujar_num_grande(cval, 116 - (#cval * 8), cy + 10, sel and c_atxt or 10, 2)
        end
      end
    end
    clip()

  elseif ui_estilo == 6 then
    clip(0, 36, 127, 74)
    local off_y = flr(cat_anim_y)
    if ui_zoom == 1 then
      local idx = max(1, cat_cursor)
      if idx <= #g.cats then
        local cy = 38 + off_y
        local sel = (cat_cursor == idx)
        local cnom = sub(cat_tr(g.cats[idx]), 1, 13)
        local cval = tostr(g.vals[idx] or 0)
        rectfill(6, cy, 121, cy + 68, sel and c_acc or c_pan)
        rectfill(6, cy, 11, cy + 68, sel and 7 or 11)
        print("\^w" .. cnom, 16, cy + 8, sel and c_atxt or c_txt)
        local esc = (#cval >= 5) and 2 or 3
        dibujar_num_grande(cval, 68 - flr((#cval * esc * 4) / 2), cy + 31, sel and c_atxt or 10, esc)
      end
    else
      for slot = 0, 3 do
        local idx = cat_scroll + slot
        if idx >= 1 and idx <= #g.cats then
          local cy = 38 + (slot - 1) * 35 + off_y
          local sel = (cat_cursor == idx)
          local cnom = sub(cat_tr(g.cats[idx]), 1, 11)
          local cval = tostr(g.vals[idx] or 0)
          rectfill(6, cy, 121, cy + 32, sel and c_acc or c_pan)
          rectfill(6, cy, 10, cy + 32, sel and 7 or 11)
          print(cnom, 14, cy + 6, sel and c_atxt or c_txt)
          print(idx .. "/" .. #g.cats, 14, cy + 20, sel and c_atxt or 6)
          dibujar_num_grande(cval, 116 - (#cval * 8), cy + 10, sel and c_atxt or 10, 2)
        end
      end
    end
    clip()

  elseif ui_estilo == 7 then
    clip(0, 36, 127, 74)
    local off_y = flr(cat_anim_y)
    if ui_zoom == 1 then
      local idx = max(1, cat_cursor)
      if idx <= #g.cats then
        local cy = 38 + off_y
        local sel = (cat_cursor == idx)
        local cnom = sub(cat_tr(g.cats[idx]), 1, 12)
        local cval = tostr(g.vals[idx] or 0)
        rectfill(6, cy, 121, cy + 68, sel and c_pan or 0)
        rect(6, cy, 121, cy + 68, sel and 7 or c_acc)
        rect(9, cy + 3, 118, cy + 65, sel and c_acc or c_pan)
        print("\^w" .. cnom, 64 - (#cnom * 4), cy + 9, sel and 7 or c_txt)
        local esc = (#cval >= 5) and 2 or 3
        dibujar_num_grande(cval, 64 - flr((#cval * esc * 4) / 2), cy + 31, 10, esc)
      end
    else
      for slot = 0, 3 do
        local idx = cat_scroll + slot
        if idx >= 1 and idx <= #g.cats then
          local cy = 38 + (slot - 1) * 35 + off_y
          local sel = (cat_cursor == idx)
          local cnom = sub(cat_tr(g.cats[idx]), 1, 10)
          local cval = tostr(g.vals[idx] or 0)
          rectfill(6, cy, 121, cy + 32, sel and c_pan or 0)
          rect(6, cy, 121, cy + 32, sel and 7 or c_acc)
          rect(8, cy + 2, 119, cy + 30, sel and c_acc or c_pan)
          print("[" .. cnom .. "]", 12, cy + 6, sel and 7 or c_txt)
          print("lvl " .. idx, 12, cy + 19, 11)
          dibujar_num_grande(cval, 115 - (#cval * 8), cy + 10, 10, 2)
        end
      end
    end
    clip()

  else
    for slot = 1, 5 do
      local idx = cat_scroll + slot
      if idx <= #g.cats then
        local ly = 37 + (slot - 1) * 14
        local sel = (cat_cursor == idx)
        local cid = g.cats[idx]
        local cnom = cat_tr(cid)
        local cval = tostr(g.vals[idx] or 0)

        if sel then
          rectfill(4, ly, 123, ly + 12, c_acc)
          print((ui_zoom == 1 and "\^w>" or "> ") .. sub(cnom, 1, 12), 7, ly + 3, c_atxt)
          print("[" .. cval .. "]", 120 - (#cval + 2) * 4, ly + 3, c_atxt)
        else
          rectfill(4, ly, 123, ly + 12, c_pan)
          print((ui_zoom == 1 and "\^w " or "  ") .. sub(cnom, 1, 12), 7, ly + 3, c_txt)
          print(cval, 120 - #cval * 4, ly + 3, 10)
        end
      end
    end
  end

  rectfill(0, 111, 127, 127, 0)
  line(0, 111, 127, 111, c_acc)
  local neg_tag = negativo_habilitado and "[-1:on]" or "[-1:off]"
  print(tr(21), 3, 115, 7)
  print(neg_tag, 3, 121, negativo_habilitado and 8 or 5)
  dibujar_ranita(112, 113)

  if confirm_neg_abierta then
    rectfill(12, 36, 115, 92, 0)
    rect(12, 36, 115, 92, 8)
    rectfill(14, 38, 113, 47, 8)
    print("! " .. tr(23) .. " !", 34, 40, 7)
    print(sub(tr(7), 1, 22), 18, 53, 7)
    print(sub(tr(22), 1, 22), 18, 62, 6)

    local s_si = (confirm_neg_cursor == 1)
    local s_no = (confirm_neg_cursor == 2)
    rectfill(20, 74, 56, 85, s_si and 8 or 1)
    print(tr(8), 32, 77, s_si and 7 or 5)
    rectfill(70, 74, 106, 85, s_no and 11 or 1)
    print(tr(9), 82, 77, s_no and 0 or 5)
  end
end


-- =========================================================
-- parte 6b: opciones, controles, creditos y mascota ranita
-- =========================================================

function dibujar_opciones(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act)
  cls(c_bg)
  rectfill(0, 0, 127, 13, c_pan)
  line(0, 13, 127, 13, c_acc)
  print(tr(6) .. " [" .. cod_lang[idioma] .. "]", 6, 4, 7)
  print(reloj_str, 92, 4, 11)

  local lbl_reset = {
    "borrar todo:", "reset all:", "usun dane:", "sbros vsego:", "apagar tudo:",
    "cancella tutto:", "tout effacer:", "zenbu kesu:", "quanbu qingchu:", "jeonbu sakje:",
    "hepsini sil:", "alles loschen:", "hadhf alkull:", "sab mitaye:", "alles wissen:",
    "radera allt:", "hapus semua:", "xoa tat ca:"
  }
  local q_reset = {
    "borrar todos los datos?", "erase all saved data?", "usunac wszystkie dane?",
    "udalit vse dannye?", "apagar todos os dados?", "cancellare tutti i dati?",
    "effacer toutes donnees?", "subete no deta wo kesu?", "shanchu suoyou shuju?",
    "modeun deiteo sakje?", "tum veriler silinsin mi?", "alle daten loschen?",
    "hadhf jami albayanat?", "sabhi data mitaye?", "alle gegevens wissen?",
    "radera all sparad data?", "hapus semua data?", "xoa tat ca du lieu?"
  }

  local estilos_nom = {"#1", "#2", "#3", "#4", "#5", "#6", "#7"}
  local items = {
    {tr(1), "<" .. cod_lang[idioma] .. ">"},
    {tr(12), estilos_nom[ui_estilo]},
    {tr(13), nombres_temas[tema_idx]},
    {tr(14), tema_auto_juego == 1 and "on" or "off"},
    {tr(15), ui_zoom == 1 and "on" or "off"},
    {tr(16), modo_animo == 1 and "on" or "off"},
    {tr(17), emocion_fija == 0 and "auto" or ("#" .. emocion_fija)},
    {"pet " .. tr(17), ranita_oculta == 0 and "on" or "off"},
    {tr(18), "[cfg]"},
    {tr(11), "[>]"},
    {lbl_reset[idioma] or "reset all:", "[!]"}
  }

  for slot = 1, 5 do
    local idx = opt_scroll + slot
    if idx <= #items then
      local ly = 20 + (slot - 1) * 17
      local sel = (opt_cursor == idx)
      local bg_col = sel and (idx == 11 and 8 or c_acc) or c_pan
      rectfill(5, ly, 122, ly + 13, bg_col)
      print((sel and "> " or "  ") .. items[idx][1], 8, ly + 4, sel and 7 or (idx == 11 and 8 or c_txt))
      local val_s = items[idx][2]
      print(val_s, 119 - #val_s * 4, ly + 4, sel and 7 or (idx == 11 and 8 or 11))
    end
  end

  rectfill(0, 112, 127, 127, 0)
  line(0, 112, 127, 112, c_acc)
  print(tr(19), 6, 117, 6)
  dibujar_ranita(112, 114)

  if sub_btn_abierta then
    dibujar_subventana_botones(c_pan, c_txt, c_acc, c_atxt)
  end

  if confirm_reset_abierta then
    rectfill(10, 34, 117, 94, 0)
    rect(10, 34, 117, 94, 8)
    rectfill(12, 36, 115, 45, 8)
    print("! " .. tr(23) .. " !", 34, 38, 7)
    print(sub(q_reset[idioma] or "erase all saved data?", 1, 24), 14, 52, 7)
    print("cartdata [0..63]", 32, 62, 6)

    local s_si = (confirm_reset_cursor == 1)
    local s_no = (confirm_reset_cursor == 2)
    rectfill(20, 75, 56, 86, s_si and 8 or 1)
    print(tr(8), 32, 78, s_si and 7 or 5)
    rectfill(70, 75, 106, 86, s_no and 11 or 1)
    print(tr(9), 82, 78, s_no and 0 or 5)
  end
end

function dibujar_subventana_botones(c_pan, c_txt, c_acc, c_atxt)
  rectfill(8, 12, 119, 115, 0)
  rect(8, 12, 119, 115, 11)
  rectfill(10, 14, 117, 23, c_pan)
  print(sub(tr(24), 1, 24), 14, 16, 7)

  local nom_btns = {"<", ">", "^", "v", "a", "b"}
  local filas_b = {
    {sub(tr(25), 1, 14), nom_btns[btn_cfg[1] + 1]},
    {sub(tr(26), 1, 14), nom_btns[btn_cfg[2] + 1]},
    {sub(tr(27), 1, 14), nom_btns[btn_cfg[3] + 1]},
    {sub(tr(28), 1, 14), nom_btns[btn_cfg[4] + 1]},
    {sub(tr(29), 1, 14), nom_btns[btn_cfg[5] + 1]},
    {"[" .. sub(tr(30), 1, 20) .. "]", ""}
  }

  for i = 1, 6 do
    local ly = 27 + (i - 1) * 12
    local sel = (sub_btn_cursor == i)
    if sel then rectfill(11, ly - 1, 116, ly + 8, c_acc) end
    print((sel and ">" or " ") .. filas_b[i][1], 13, ly, sel and c_atxt or c_txt)
    if filas_b[i][2] != "" then
      print("<" .. filas_b[i][2] .. ">", 94, ly, sel and c_atxt or 10)
    end
  end

  line(11, 100, 116, 100, 5)
  print("b+< : " .. tr(11), 14, 104, 6)
end

function dibujar_acercade()
  cls(0)
  rect(2, 2, 125, 125, 12)
  local lineas = {
    "=== " .. tr(11) .. " ===",
    "",
    "counter games xtree",
    "version: v0.05",
    "",
    tr(37),
    "martstartiv",
    "ai assistant",
    "",
    "engine: pico-8 libretro",
    "core: picante8 v-safe",
    "system: mips / treefrogui",
    "",
    "--- shortcuts ---",
    "b + < : " .. tr(11),
    "b + v : " .. tr(32),
    "a : " .. tr(25),
    "b : " .. tr(26),
    "",
    tr(38),
    "[a / b] : exit"
  }

  clip(4, 4, 120, 120)
  for i = 1, #lineas do
    local ly = flr(creditos_y + (i - 1) * 11)
    if ly >= -8 and ly <= 130 then
      local col = 7
      if i == 1 or i == 14 or i == 20 then col = 10
      elseif i == 7 or i == 8 then col = 11 end
      local lx = 64 - (#lineas[i] * 2)
      print(lineas[i], lx, ly, col)
    end
  end
  clip()
  dibujar_ranita(112, 112)
end

function dibujar_ranita(x, y)
  if ranita_oculta == 1 then return end
  local off_y = flr(sin(ranita_anim / 60) * 1.5)
  local ry = y + off_y
  rectfill(x, ry + 2, x + 10, ry + 10, 3)
  rectfill(x + 1, ry + 3, x + 9, ry + 10, 11)

  if emocion_actual == 6 then
    line(x, ry + 2, x + 2, ry + 2, 0)
    line(x + 8, ry + 2, x + 10, ry + 2, 0)
    pset(x + 5, ry + 7, 8)
    if ranita_anim < 30 then print("z", x + 11, ry - 4, 7) end
  else
    rectfill(x, ry, x + 2, ry + 2, 3)
    rectfill(x + 8, ry, x + 10, ry + 2, 3)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, 0)
    pset(x + 9, ry + 2, 0)

    if emocion_actual == 1 then
      rectfill(x + 3, ry + 7, x + 7, ry + 7, 8)
    elseif emocion_actual == 2 then
      pset(x + 5, ry + 7, 8)
    elseif emocion_actual == 3 then
      rectfill(x + 4, ry + 6, x + 6, ry + 8, 8)
    elseif emocion_actual == 4 then
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8) pset(x + 7, ry + 7, 8)
    elseif emocion_actual == 5 then
      rectfill(x, ry + 1, x + 10, ry + 3, 0)
      pset(x + 1, ry + 1, 7) pset(x + 8, ry + 1, 7)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 7 then
      line(x + 3, ry + 1, x + 7, ry + 1, 10)
      pset(x + 3, ry, 10) pset(x + 5, ry - 1, 10) pset(x + 7, ry, 10)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 8 then
      rectfill(x, ry + 1, x + 3, ry + 3, 1)
      rectfill(x + 7, ry + 1, x + 10, ry + 3, 1)
      line(x + 4, ry + 1, x + 6, ry + 1, 12)
      pset(x + 1, ry + 1, 12) pset(x + 8, ry + 1, 12)
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 9 then
      line(x + 8, ry + 2, x + 10, ry + 2, 0)
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 10 then
      line(x + 1, ry - 1, x + 9, ry - 1, 12)
      rectfill(x - 1, ry + 2, x, ry + 5, 12)
      rectfill(x + 10, ry + 2, x + 11, ry + 5, 12)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 11 then
      line(x, ry + 3, x + 10, ry + 3, 8)
      pset(x + 11, ry + 2, 8) pset(x + 11, ry + 4, 8)
      line(x + 4, ry + 7, x + 6, ry + 7, 0)
    elseif emocion_actual == 12 then
      rectfill(x, ry + 1, x + 3, ry + 3, 10)
      rectfill(x + 7, ry + 1, x + 10, ry + 3, 10)
      line(x + 4, ry + 2, x + 6, ry + 2, 10)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 13 then
      line(x + 2, ry + 1, x + 8, ry + 1, 2)
      rectfill(x + 3, ry - 1, x + 7, ry, 2)
      rectfill(x + 4, ry - 3, x + 6, ry - 2, 2)
      pset(x + 5, ry - 1, 10)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 14 then
      line(x, ry + 1, x + 10, ry + 1, 8)
      rectfill(x + 7, ry + 1, x + 10, ry + 3, 0)
      line(x + 4, ry + 7, x + 7, ry + 7, 8)
    elseif emocion_actual == 15 then
      rectfill(x, ry + 1, x + 10, ry + 3, 12)
      line(x + 1, ry + 2, x + 9, ry + 2, 7)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 12)
    elseif emocion_actual == 16 then
      rectfill(x + 2, ry - 1, x + 8, ry + 1, 7)
      rectfill(x + 1, ry - 3, x + 9, ry - 1, 7)
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8) pset(x + 7, ry + 7, 8)
    else
      line(x + 3, ry - 2, x + 7, ry - 2, 10)
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8) pset(x + 7, ry + 7, 8)
    end
  end
end
