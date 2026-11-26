pico-8 cartridge // http://pico-8.com
version 42
__lua__
-- =========================================================
-- proyecto: counter games xtree [v0.11]
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
  app_ver = "v0.11"
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

  txt_ext_raw = {
    "efecto ui:|mascota:|mem. 8x:|ampliar 12->20?|costo: 12 monedas|formatear lista?",
    "fx ui:|pet:|mem 8x:|expand 12->20?|cost: 12 coins|format list?",
    "efekt ui:|zwierzak:|pamiec 8x:|rozsz. 12->20?|koszt: 12 monet|formatuj liste?",
    "effekt ui:|pitomec:|pamyat 8x:|rassh. 12->20?|cena: 12 monet|ochistit spisok?",
    "efeito ui:|mascote:|mem. 8x:|ampliar 12->20?|custo: 12 moedas|formatar lista?",
    "effetto ui:|mascotte:|mem. 8x:|espandi 12->20?|costo: 12 monete|formatta lista?",
    "effet ui:|animal:|mem. 8x:|etendre 12->20?|cout: 12 pieces|formater liste?",
    "kouka ui:|petto:|memori 8x:|kakuchou 12->20?|hiyou: 12 koin|risuto shokika?",
    "dongxiao:|chongwu:|neicun 8x:|kuozhan 12->20?|huafei: 12 jinbi|geshihua liebiao?",
    "hyogwa ui:|paet:|memori 8x:|hwakjang 12->20?|biyong: 12 koin|mokrok chogihwa?",
    "efekt ui:|evcil:|bellek 8x:|genislet 12->20?|bedel: 12 jeton|listeyi sil?",
    "effekt ui:|haustier:|speicher 8x:|erweit. 12->20?|kosten: 12 munzen|liste loschen?",
    "tathir ui:|hayawan:|dhakira 8x:|tawsi 12->20?|taklifa: 12 umla|tahiya qaima?",
    "prabhav:|paltu:|memori 8x:|badhaye 12->20?|mulya: 12 sikke|suchi mitaye?",
    "effect ui:|huisdier:|geheug. 8x:|uitbr. 12->20?|kosten: 12 munten|lijst wissen?",
    "effekt ui:|husdjur:|minne 8x:|utoka 12->20?|kostnad: 12 mynt|formatera lista?",
    "efek ui:|peliharaan:|memori 8x:|perluas 12->20?|biaya: 12 koin|format daftar?",
    "hieu ung:|thu cung:|bo nho 8x:|mo rong 12->20?|gia: 12 xu|dinh dang ds?"
  }
  txt_ext = {}
  for l = 1, 18 do
    txt_ext[l] = dividir_pipe(txt_ext_raw[l])
  end

  function tr_ext(idx)
    local fila = txt_ext[idioma]
    if fila and fila[idx] then return fila[idx] end
    return ""
  end
 
  shop_lang_raw = {
    "tienda:|gorra|gafas|ojos oro|ranita oro|+3 emoc.|+20 logros|equipado!|comprado!|falta $:|elige juego|a:ok b:volver|sin memoria!",
    "shop:|cap|shades|gold eyes|gold frog|+3 emotes|+20 slots|equipped!|purchased!|need $:|select game|a:buy b:back|low mem!",
    "sklep:|czapka|okulary|zlote oczy|zlota zaba|+3 emocje|+20 slotow|zalozone!|kupiono!|brak $:|wybierz gre|a:ok b:wroc|brak pam.!",
    "magazin:|kepka|ochki|zol. glaza|zol. zhaba|+3 emocii|+20 slotov|nadeto!|kupleno!|nuzhno $:|vybor igry|a:ok b:nazad|net pam.!",
    "loja:|bone|oculos|olhos ouro|sapo ouro|+3 emocoes|+20 slots|equipado!|comprado!|falta $:|escolher jogo|a:ok b:voltar|sem mem.!",
    "negozio:|cappello|occhiali|occhi oro|rana oro|+3 emozioni|+20 slot|equipagg.!|comprato!|serve $:|scegli gioco|a:ok b:ind.|mem. piena!",
    "boutique:|casquette|lunettes|yeux or|gren. or|+3 emotes|+20 slots|equipe!|achete!|manque $:|choisir jeu|a:ok b:retour|mem. pleine!",
    "shoppu:|boushi|megane|kin no me|kin kaeru|+3 kanjou|+20 waku|soubi!|kounyuu!|tarinai $:|geemu sentaku|a:ok b:modoru|memori fusoku!",
    "shangdian:|maozi|yanjing|jin yan|jin wa|+3 biaoqing|+20 cao|yi zhuangbei!|yi goumai!|xuyao $:|xuanze youxi|a:ok b:fanhui|neicun man!",
    "sangjeom:|moja|angyeong|geum nun|geum gaeguri|+3 gamjeong|+20 seullot|jangchak!|gumae!|bujok $:|geim seontaek|a:ok b:dwiro|memori bujok!",
    "magaza:|sapka|gozluk|altin goz|altin kurb.|+3 duygu|+20 slot|takildi!|alindi!|gerek $:|oyun sec|a:ok b:geri|bellek dolu!",
    "laden:|mutze|brille|goldaugen|goldfrosch|+3 gefuhle|+20 platze|ausgerustet!|gekauft!|fehlt $:|spiel wahlen|a:ok b:zuruck|speicher voll!",
    "matjar:|qubaa|nazzara|uyun dhahab|difda dhahab|+3 mashair|+20 khana|mujahhaz!|mushtara!|yahtaj $:|ikhtar luba|a:ok b:ruju|dhakira mum.!",
    "dukan:|topi|chashma|sunehri aankh|sunehri mendhak|+3 bhav|+20 jagah|lagaya!|kharida!|chahiye $:|khel chune|a:ok b:wapas|memori bhari!",
    "winkel:|pet|bril|goudogen|goudkikker|+3 emoties|+20 vakken|uitgerust!|gekocht!|nodig $:|kies spel|a:ok b:terug|geheug. vol!",
    "butik:|keps|glasogon|guldgon|guldgroda|+3 kanslor|+20 platser|utrustad!|kopt!|behover $:|valj spel|a:ok b:tillbaka|minne fullt!",
    "toko:|topi|kacamata|mata emas|katak emas|+3 emosi|+20 slot|dipakai!|dibeli!|kurang $:|pilih game|a:ok b:kembali|memori penuh!",
    "cua hang:|mu|kinh|mat vang|ech vang|+3 cam xuc|+20 o|da trang bi!|da mua!|thieu $:|chon game|a:ok b:quay lai|day bo nho!"
  }
  shop_lang = {}
  for l = 1, 18 do
    shop_lang[l] = dividir_pipe(shop_lang_raw[l])
  end

  function tr_shop(idx)
    local fila = shop_lang[idioma]
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
  local dj7 = "super mario bros 1|super mario bros 2|super mario sunshine|super mario galaxy 1|super mario galaxy 2|super mario 3d world|super mario wonder|new super mario ds|new super mario wii|mario kart 64|mario kart double|mario kart 7|mario party 2|mario party 6|mario tennis|mario strikers|luigis mansion 2|luigis mansion 3|yoshis crafted|yoshis wooly|donkey kong returns|dk tropical freeze|wario land 4|warioware inc|kirby air ride|kirby return dream|kirby planet robobot|kirby star allies|zelda skyward sword|zelda phantom hour|zelda spirit tracks|zelda oracle ages|zelda oracle seasons|zelda four swords|zelda echoes wisdom|metroid zero mission|metroid samus returns|metroid prime 2|metroid prime 3|castlevania rondo|castlevania dawn|castlevania portrait|castlevania order|castlevania circle|castlevania harmony|mega man 3|mega man x2|mega man x3|mega man zero 1|mega man zero 3"
  local dj8 = "sonic 1|sonic 2|sonic 3 knuckles|sonic cd|sonic adventure 2|sonic heroes|sonic unleashed|sonic generations|sonic colors|shadow generations|crash 2 cortex|crash 3 warped|crash 4 its time|spyro 1|spyro 2 riptos|spyro 3 year|rayman 1|rayman origins|klonoa 2|psychonauts 2|sly 2 band|sly 3 honor|jak 2|jak 3|ratchet going commando|ratchet up arsenal|ratchet rift apart|little big planet 1|little big planet 2|tearaway|astro bot|it takes two|a way out|unravel 1|unravel 2|ori blind|shantae pirate|shantae half genie|guacamelee 1|guacamelee 2|axiom verge 1|axiom verge 2|ender lilies|bloodstained ritual|messenger|sea of stars|chained echoes|crosscode|eastward|dave diver"
  local dj9 = "pokemon heartgold|pokemon soulsilver|pokemon black 2|pokemon white 2|pokemon omega ruby|pokemon alpha sapphire|pokemon ultra sun|pokemon ultra moon|pokemon lets go|pokemon shield|pokemon violet|pokemon mystery dx|pokemon stadium 1|pokemon stadium 2|pokemon colosseum|pokemon xd gale|final fantasy 1|final fantasy 2|final fantasy 3|final fantasy 4|final fantasy 5|final fantasy 10 2|final fantasy 13|final fantasy 15|ff7 crisis core|ff tactics|dragon quest 1|dragon quest 3|dragon quest 4|dragon quest 5|dragon quest 6|dragon quest 7|dragon quest 9|persona 1|persona 2|persona 3 reload|persona 4 golden|metaphor refantazio|shin megami 3|shin megami 4|tales of symphonia|tales of vesperia|tales of berseria|tales of arise|ni no kuni 1|ni no kuni 2|bravely default|live a live|suikoden 2|legend of dragoon"
  local dj10 = "xenogears|xenosaga 1|grandia 1|grandia 2|lunar silver star|breath of fire 3|breath of fire 4|golden sun 1|golden sun 2|mother 3|mario luigi superstar|mario luigi bowsers|paper mario thousand|super paper mario|fire emblem blazing|fire emblem sacred|fire emblem awakening|fire emblem fates|fire emblem engage|disgaea 1|disgaea 5|tactics ogre|unicorn overlord|triangle strategy|valkyria chronicles|monster hunter 4u|monster hunter gu|monster hunter world|monster hunter rise|god eater 3|toukiden 2|dragons dogma 2|dark souls remaster|demon souls ps5|armored core 6|nioh complete|wo long fallen|black myth wukong|stellar blade|lies of p overture|remnant 1|remnant 2|grim dawn ashes|last epoch|diablo 2 resurrected|titan quest 2|torchlight infinite|v rising 1|enshrouded 1|palworld sakurajima"
  local dj11 = "resident evil 0|resident evil cv|resident evil 5|resident evil 6|re2 remake|re3 remake|re4 remake|silent hill 4|silent hill f|silent hill 2 remake|dino crisis 1|dino crisis 2|parasite eve 1|parasite eve 2|fatal frame 1|fatal frame 3|clock tower 3|haunting ground|rule of rose|kuon|siren 1|signalis|tormented souls|crow country|alan wake remaster|control|quantum break|max payne 3|manhunt 1|manhunt 2|bully|la noire|mafia 1|mafia 2|sleeping dogs|yakuza 0|yakuza kiwami 1|yakuza kiwami 2|yakuza like dragon|like dragon infinite|judgment|lost judgment|shenmue 1|shenmue 2|metal gear solid 2|metal gear solid 4|metal gear solid 5|metal gear rising|splinter cell chaos|hitman world"
  local dj12 = "devil may cry 1|devil may cry 4|bayonetta 1|bayonetta 2|bayonetta 3|ninja gaiden black|ninja gaiden 2|god of war 3|god of war chains|god of war ghost|dantes inferno|onimusha warlords|okami|shadow of colossus|ico|last guardian|prince of persia sands|prince of persia lost|assassins creed 2|assassins creed 4|ac odyssey|ac valhalla|far cry 3|far cry 4|far cry 5|crysis 1|metro 2033|metro exodus|stalker shadow|fallout 3|fallout new vegas|fallout 4|oblivion remaster|dishonored 1|dishonored 2|prey 2017|doom 3|doom 64|wolfenstein new|titanfall 2|apex|left 4 dead 2|payday 2|deep rock galactic|helldivers 2|street fighter 3|street fighter 4|street fighter 5|king of fighters 98|king of fighters 15"

  juegos_db = {}
  local bloques_j = {dj1, dj2, dj3, dj4, dj5, dj6, dj7, dj8, dj9, dj10, dj11, dj12}
  for b = 1, 12 do
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
  pet_tipo = 0
  monedas = 20
  uso_frames = 0
  juegos_exp = {false, false, false, false}
  ultimo_cat_inc = {0, 0, 0, 0}
  ultimo_hora_inc = {"", "", "", ""}
  confirm_exp_abierta = false
  confirm_exp_cursor = 2
  pendiente_cid = 0
  mem_ext = 0
  juego_scroll = 0
  confirm_mem_abierta = false
  confirm_mem_cursor = 2
  shop_cursor = 1
  shop_scroll = 0
  shop_own = {false, false, false, false, false}
  shop_eq = {false, false, false, false}
  shop_sel_juego = false
  shop_j_cursor = 1
  ui_fx = 1
  menu_anim = 0
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

function obtener_cats_juego(id_j, nom)
  local n = nom or ""
  local reglas = {
    {"pokemon", {38, 36, 1, 5, 3, 46, 55}},
    {"zelda", {27, 49, 22, 10, 7, 15, 21}},
    {"mario", {11, 12, 28, 3, 7, 21, 35}},
    {"sonic", {11, 12, 28, 3, 7, 21, 35}},
    {"kirby", {11, 12, 28, 3, 7, 21, 35}},
    {"crash", {11, 12, 28, 3, 7, 21, 35}},
    {"kart", {6, 1, 36, 34, 35, 51, 52}},
    {"turismo", {6, 1, 36, 34, 35, 51, 52}},
    {"forza", {6, 1, 36, 34, 35, 51, 52}},
    {"speed", {6, 1, 36, 34, 35, 51, 52}},
    {"fighter", {1, 32, 33, 30, 31, 52, 34}},
    {"tekken", {1, 32, 33, 30, 31, 52, 34}},
    {"kombat", {1, 32, 33, 30, 31, 52, 34}},
    {"smash", {1, 32, 33, 30, 31, 52, 34}},
    {"fifa", {1, 32, 33, 31, 29, 36, 34}},
    {"nba", {1, 32, 33, 31, 29, 36, 34}},
    {"balatro", {31, 1, 2, 37, 5, 18, 51}},
    {"spire", {31, 1, 2, 37, 5, 18, 51}},
    {"isaac", {31, 1, 2, 5, 18, 21, 51}},
    {"resident", {2, 22, 5, 15, 23, 35, 54}},
    {"silent", {2, 22, 5, 15, 23, 35, 54}},
    {"empires", {1, 32, 4, 40, 52, 53, 55}},
    {"starcraft", {1, 32, 4, 40, 52, 53, 55}},
    {"gta", {4, 12, 15, 39, 46, 20, 55}},
    {"witcher", {4, 12, 15, 39, 46, 20, 55}},
    {"skyrim", {4, 12, 15, 39, 46, 20, 55}}
  }
  for r = 1, #reglas do
    if contiene_subcadena(n, reglas[r][1]) then
      local res = {}
      for k = 1, 7 do add(res, reglas[r][2][k]) end
      return res
    end
  end
  local base = {1, 2, 3, 4, 5, 6, 7}
  if id_j and id_j > 0 then
    if id_j <= 45 then base = {2, 7, 25, 15, 16, 14, 21}
    elseif id_j <= 85 then base = {40, 41, 43, 42, 44, 10, 55}
    elseif id_j <= 145 then base = {11, 12, 27, 22, 7, 21, 3}
    elseif id_j <= 191 then base = {3, 4, 17, 38, 5, 7, 53}
    elseif id_j <= 252 then base = {4, 2, 15, 22, 35, 34, 54}
    else base = {1, 32, 30, 6, 36, 34, 52} end
  end
  local res = {}
  for k = 1, 7 do add(res, base[k]) end
  return res
end

function crear_objeto_juego(id_j, nom_custom)
  local nom = nom_custom or "juego"
  if id_j and id_j > 0 and juegos_db[id_j] then
    nom = juegos_db[id_j]
  end
  return {
    id_juego = id_j or 0,
    nombre = nom,
    cats = obtener_cats_juego(id_j, nom),
    vals = {0, 0, 0, 0, 0, 0, 0}
  }
end

function aplicar_cambio_memoria(nuevo_modo)
  mem_ext = nuevo_modo
  mis_juegos = {}
  juego_sel = 1
  juego_scroll = 0
  juego_activo = 1
  juegos_exp = {false, false, false, false, false, false, false, false}
  ultimo_cat_inc = {0, 0, 0, 0, 0, 0, 0, 0}
  ultimo_hora_inc = {"", "", "", "", "", "", "", ""}
  guardar_datos()
  mostrar_aviso(mem_ext == 1 and "8-game mem on!" or "std 4-game mem!", 55)
end

function guardar_datos()
  local cfg0 = 1000 + idioma + (tema_idx * 32) + (ui_estilo * 1024) + (modo_animo * 8192)
  local sub0 = emocion_fija + (tema_auto_juego * 32) + (ranita_oculta * 64) + (ui_zoom * 128)
  dset(0, cfg0 + (sub0 / 256))

  local b_pack = 0
  local b_mult = 1
  for i = 1, 5 do
    b_pack = b_pack + ((btn_cfg[i] or 0) * b_mult)
    b_mult = b_mult * 8
  end

  local nu = nombre_usuario or "gamer"
  dset(2, empaquetar_4ch(sub(nu, 1, 4)))
  dset(3, empaquetar_4ch(sub(nu, 5, 8)))
  dset(4, empaquetar_4ch(sub(nu, 9, 12)))

  if mem_ext == 1 then
    dset(1, b_pack + (ui_fx / 8))
    local slot = 13
    for j = 1, 8 do
      local g = mis_juegos[j]
      if g then
        local n_cats = min(#g.cats, 20)
        if g.id_juego and g.id_juego > 0 then
          dset(4 + j, g.id_juego + (n_cats / 32))
        else
          dset(4 + j, -empaquetar_4ch(sub(g.nombre, 1, 4)))
        end
        if (not g.id_juego or g.id_juego == 0) and slot <= 59 then
          dset(slot, n_cats)
          slot = slot + 1
          dset(slot, empaquetar_4ch(sub(g.nombre, 5, 8)))
          slot = slot + 1
        end
        local c = 1
        while c <= n_cats and slot <= 60 do
          local cid1 = min(max(g.cats[c] or 1, 1), 60)
          local val1 = min(max(flr(g.vals[c] or 0), 0), 255)
          local ent_p = cid1 + (val1 * 64)

          local dec_p = 0
          if c + 1 <= n_cats then
            local cid2 = min(max(g.cats[c + 1] or 1, 1), 60)
            local val2 = min(max(flr(g.vals[c + 1] or 0), 0), 255)
            dec_p = (cid2 + (val2 * 64)) / 16384
          end

          dset(slot, ent_p + dec_p)
          slot = slot + 1
          c = c + 2
        end
      else
        dset(4 + j, 0)
      end
    end
    while slot <= 60 do
      dset(slot, 0)
      slot = slot + 1
    end
  else
    dset(1, b_pack + ((#mis_juegos + (ui_fx * 5)) / 32))
    for j = 1, 4 do
      local g = mis_juegos[j]
      if g then
        local n_cats = min(#g.cats, 20)
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
        local n_cats = min(#g.cats, 20)
        if (not g.id_juego or g.id_juego == 0) and slot <= 59 then
          dset(slot, n_cats)
          slot = slot + 1
          dset(slot, empaquetar_4ch(sub(g.nombre, 5, 8)))
          slot = slot + 1
        end
        for c = 1, n_cats do
          if slot <= 60 then
            local cid = min(max(g.cats[c] or 1, 1), 60)
            local cval = min(max(flr(g.vals[c] or 0), 0), 32760)
            dset(slot, cval + (cid / 64))
            slot = slot + 1
          end
        end
      end
    end
    while slot <= 60 do
      dset(slot, 0)
      slot = slot + 1
    end
  end

  local mask_exp = 0
  local mult = 1
  for j = 1, 8 do
    if juegos_exp[j] then mask_exp = mask_exp + mult end
    mult = mult * 2
  end
  local dec61 = (mem_ext * 4) + (pet_tipo * 16)
  local s61 = 0
  local m61 = 2048
  for k = 1, 2 do
    if shop_own[k] then s61 = s61 + m61 end
    m61 = m61 * 2
    if shop_eq[k] then s61 = s61 + m61 end
    m61 = m61 * 2
  end
  dset(61, 1000 + min(max(flr(monedas), 0), 999) + s61 + (dec61 / 64))
  dset(62, flr(uso_frames) + (mask_exp / 256))

  local u_ent = 0
  local u_mult = 1
  for j = 1, 3 do
    local uv = (ultimo_cat_inc[j] or 0) % 24
    u_ent = u_ent + (uv * u_mult)
    u_mult = u_mult * 24
  end
  local u4 = (ultimo_cat_inc[#ultimo_cat_inc] or 0) % 24
  local s63 = 0
  local m63 = 32
  for k = 3, 4 do
    if shop_own[k] then s63 = s63 + m63 end
    m63 = m63 * 2
    if shop_eq[k] then s63 = s63 + m63 end
    m63 = m63 * 2
  end
  if shop_own[#shop_own] then s63 = s63 + 512 end
  dset(63, u_ent + ((u4 + s63) / 16384))
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
    if emocion_fija > 20 then emocion_fija = 0 end
    tema_auto_juego = flr(dec0 / 32) % 2
    ranita_oculta = flr(dec0 / 64) % 2
    ui_zoom = flr(dec0 / 128) % 2

    local v1 = dget(1) or 0
    local ent1 = flr(v1)
    if ent1 > 0 then
      local tmp1 = ent1
      for i = 1, 5 do
        local bv = tmp1 % 8
        if bv < 0 or bv > 5 then bv = 4 end
        btn_cfg[i] = bv
        tmp1 = flr(tmp1 / 8)
      end
    end

    shop_own = {false, false, false, false, false}
    shop_eq = {false, false, false, false}

    local v61 = dget(61) or 0
    local ent61 = flr(v61)
    local v62 = dget(62) or 0
    uso_frames = max(0, flr(v62))
    local mask_exp = 0
    if ent61 >= 1000 then
      local b61 = ent61 - 1000
      monedas = min(max(b61 % 2048, 0), 999)
      local tmp61 = flr(b61 / 2048)
      for k = 1, 2 do
        shop_own[k] = (tmp61 % 2) == 1
        tmp61 = flr(tmp61 / 2)
        shop_eq[k] = (tmp61 % 2) == 1
        tmp61 = flr(tmp61 / 2)
      end
      local dec61 = flr((v61 - ent61) * 64 + 0.5)
      mem_ext = flr(dec61 / 4) % 2
      pet_tipo = flr(dec61 / 16) % 4
      mask_exp = flr((v62 - uso_frames) * 256 + 0.5)
      if mask_exp == 0 then mask_exp = dec61 % 4 end
    else
      monedas = 20
      pet_tipo = 0
      mem_ext = 0
    end

    juegos_exp = {}
    local m_tmp = mask_exp
    for j = 1, 8 do
      juegos_exp[j] = (m_tmp % 2) == 1
      m_tmp = flr(m_tmp / 2)
    end

    local nu = desempaquetar_4ch(dget(2)) .. desempaquetar_4ch(dget(3)) .. desempaquetar_4ch(dget(4))
    nu = limpiar_espacios_der(nu)
    nombre_usuario = (#nu > 0) and nu or "gamer"

    mis_juegos = {}
    if mem_ext == 1 then
      ui_fx = min(flr((v1 - ent1) * 8 + 0.5), 4)
      local slot = 13
      for j = 1, 8 do
        local vj = dget(4 + j) or 0
        if vj != 0 then
          local g = nil
          local n_cats = 7
          if vj > 0 then
            local id_j = flr(vj)
            n_cats = min(flr((vj - id_j) * 32 + 0.5), 20)
            if n_cats < 1 then n_cats = 7 end
            g = crear_objeto_juego(id_j, nil)
          else
            local p1 = limpiar_espacios_der(desempaquetar_4ch(-vj))
            local p2 = ""
            if slot <= 59 then
              n_cats = min(max(flr(dget(slot) or 7), 1), 20)
              slot = slot + 1
              p2 = limpiar_espacios_der(desempaquetar_4ch(dget(slot) or 0))
              slot = slot + 1
            end
            g = crear_objeto_juego(0, p1 .. p2)
          end
          g.cats = {}
          g.vals = {}
          local c = 1
          while c <= n_cats and slot <= 60 do
            local sc = dget(slot) or 0
            slot = slot + 1
            local ent_p = flr(sc)
            local dec_p = flr((sc - ent_p) * 16384 + 0.5)

            local cid1 = ent_p % 64
            local val1 = flr(ent_p / 64)
            if cid1 < 1 or cid1 > 60 then cid1 = c end
            add(g.cats, cid1)
            add(g.vals, max(0, val1))

            if c + 1 <= n_cats then
              local cid2 = dec_p % 64
              local val2 = flr(dec_p / 64)
              if cid2 < 1 or cid2 > 60 then cid2 = c + 1 end
              add(g.cats, cid2)
              add(g.vals, max(0, val2))
            end
            c = c + 2
          end
          add(mis_juegos, g)
        end
      end
    else
      local dec1 = flr((v1 - ent1) * 32 + 0.5)
      local tot_juegos = min(dec1 % 5, 4)
      ui_fx = min(flr(dec1 / 5), 4)
      local slot = 9
      for j = 1, tot_juegos do
        local vj = dget(4 + j) or 0
        if vj > 0 then
          local id_j = flr(vj)
          local n_cats = min(flr((vj - id_j) * 32 + 0.5), 20)
          if n_cats < 1 then n_cats = 7 end
          local g = crear_objeto_juego(id_j, nil)
          g.cats = {}
          g.vals = {}
          for c = 1, n_cats do
            if slot <= 60 then
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
          if slot <= 59 then
            n_cats = min(max(flr(dget(slot) or 7), 1), 20)
            slot = slot + 1
            p2 = limpiar_espacios_der(desempaquetar_4ch(dget(slot) or 0))
            slot = slot + 1
          end
          local g = crear_objeto_juego(0, p1 .. p2)
          g.cats = {}
          g.vals = {}
          for c = 1, n_cats do
            if slot <= 60 then
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
    end

    local v63 = dget(63) or 0
    local ent63 = flr(v63)
    local dec63 = flr((v63 - ent63) * 16384 + 0.5)
    local u4 = dec63 % 24
    local tmp63 = flr(dec63 / 32)
    for k = 3, 4 do
      shop_own[k] = (tmp63 % 2) == 1
      tmp63 = flr(tmp63 / 2)
      shop_eq[k] = (tmp63 % 2) == 1
      tmp63 = flr(tmp63 / 2)
    end
    shop_own[#shop_own] = (tmp63 % 2) == 1
    ultimo_cat_inc = {
      ent63 % 24,
      flr(ent63 / 24) % 24,
      flr(ent63 / 576) % 24,
      u4,
      0, 0, 0, 0
    }
    estado = 2
  else
    monedas = 20
    pet_tipo = 0
    uso_frames = 0
    mem_ext = 0
    shop_own = {false, false, false, false, false}
    shop_eq = {false, false, false, false}
    juegos_exp = {false, false, false, false, false, false, false, false}
    ultimo_cat_inc = {0, 0, 0, 0, 0, 0, 0, 0}
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
  pet_tipo = 0
  monedas = 20
  uso_frames = 0
  juegos_exp = {false, false, false, false, false, false, false, false}
  ultimo_cat_inc = {0, 0, 0, 0, 0, 0, 0, 0}
  ultimo_hora_inc = {"", "", "", "", "", "", "", ""}
  mem_ext = 0
  juego_scroll = 0
  shop_own = {false, false, false, false, false}
  shop_eq = {false, false, false, false}
  ui_fx = 1
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
  if abs(menu_anim) > 0.2 then menu_anim = menu_anim * 0.7 else menu_anim = 0 end

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

  local tope_em = (shop_own and shop_own[#shop_own]) and 20 or 17
  if emocion_fija >= 1 and emocion_fija <= tope_em then
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
        local nueva_e = 1 + flr(rnd(tope_em))
        if nueva_e == 6 then nueva_e = 1 + flr(rnd(5)) end
        emocion_actual = nueva_e
      end
    end
  end

  if boot_ok and ranita_oculta == 0 then
    uso_frames = uso_frames + 1
    if uso_frames % 1800 == 0 then
      local dec62 = (dget(62) or 0) - flr(dget(62) or 0)
      dset(62, flr(uso_frames) + dec62)
    end
    if uso_frames >= 9000 then
      uso_frames = 0
      local premio = (pet_tipo == 0) and (2 + flr(rnd(3))) or (1 + flr(rnd(2)))
      monedas = min(monedas + premio, 999)
      guardar_datos()
      mostrar_aviso("+" .. premio .. " coins!", 65)
    end
  end

  if btn(5) and btnp(0) and estado >= 2 and estado != 7 and estado != 8 then
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
  elseif estado == 2 then
    actualizar_menu_principal()
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
  elseif estado == 8 then
    actualizar_tienda()
  end
end

-- =========================================================
-- parte 3b: menu principal y teclado virtual
-- =========================================================

function calc_mem_libre()
  local slots_tot = (mem_ext == 1) and 48 or 52
  local slots_usados = 0
  for j = 1, #mis_juegos do
    local g = mis_juegos[j]
    if not g.id_juego or g.id_juego == 0 then
      slots_usados = slots_usados + 2
    end
    local nc = #g.cats
    slots_usados = slots_usados + ((mem_ext == 1) and flr((nc + 1) / 2) or nc)
  end
  local slots_libres = max(0, slots_tot - slots_usados)
  local cats_libres = (mem_ext == 1) and (slots_libres * 2) or slots_libres
  local max_j = (mem_ext == 1) and 8 or 4
  local j_por_mem = flr(cats_libres / 12)
  local juegos_disp = min(max_j - #mis_juegos, j_por_mem)
  return cats_libres, max(0, juegos_disp), max_j
end

function actualizar_menu_principal()
  local k3 = 3
  local total_g = #mis_juegos
  local max_fila = total_g + 1
  local max_j = (mem_ext == 1) and 8 or 4

  if btn(5) then
    if btnp(3) and juego_sel >= 2 and juego_sel <= max_fila then
      deli(mis_juegos, juego_sel - 1)
      guardar_datos()
      if #mis_juegos == 0 then
        juego_sel = 1
        juego_scroll = 0
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
    menu_anim = -10
  elseif btnp(3) then
    juego_sel = juego_sel + 1
    if juego_sel > max_fila then juego_sel = 0 end
    menu_anim = 10
  end

  if juego_sel >= 2 then
    local g_pos = juego_sel - 1
    if g_pos <= juego_scroll then
      juego_scroll = g_pos - 1
    elseif g_pos > juego_scroll + 4 then
      juego_scroll = g_pos - 4
    end
  else
    juego_scroll = 0
  end

  if juego_sel == 0 and btnp(4) then
    opt_cursor = 1
    opt_scroll = 0
    sub_btn_abierta = false
    confirm_reset_abierta = false
    confirm_mem_abierta = false
    modal_anim = 6
    cambiar_estado(6)
    return
  end

  if juego_sel == 1 and btnp(4) then
    if total_g >= max_j then
      mostrar_aviso("max " .. max_j .. " games!", 45)
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

  if confirm_exp_abierta then
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      confirm_exp_cursor = (confirm_exp_cursor == 1) and 2 or 1
    elseif btnp(4) then
      if confirm_exp_cursor == 1 then
        if monedas >= 12 then
          monedas = monedas - 12
          juegos_exp[juego_activo] = true
          if pendiente_cid > 0 then
            add(g.cats, pendiente_cid)
            add(g.vals, 0)
          end
          guardar_datos()
          mostrar_aviso("slots: 20! (-12c)", 50)
        else
          mostrar_aviso("need 12 coins!", 45)
        end
      end
      confirm_exp_abierta = false
      pendiente_cid = 0
    elseif btnp(5) then
      confirm_exp_abierta = false
      pendiente_cid = 0
    end
    return
  end

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
            local cats_lib, _, _ = calc_mem_libre()
            local lim_c = juegos_exp[juego_activo] and 20 or 12
            if cats_lib <= 0 then
              mostrar_aviso("mem full!", 40)
            elseif #g.cats >= lim_c then
              if not juegos_exp[juego_activo] then
                if cats_lib < 8 then
                  mostrar_aviso("low mem (" .. cats_lib .. "c)!", 45)
                else
                  pendiente_cid = cid
                  confirm_exp_abierta = true
                  confirm_exp_cursor = 1
                end
              else
                mostrar_aviso("max 20 cats!", 35)
              end
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
      local tope_v = (mem_ext == 1) and 255 or 32760
      g.vals[cat_cursor] = min((g.vals[cat_cursor] or 0) + 1, tope_v)
      ultimo_cat_inc[juego_activo] = cat_cursor
      ultimo_hora_inc[juego_activo] = sub(reloj_str, 1, 5)
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
  if confirm_mem_abierta then
    if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
      confirm_mem_cursor = (confirm_mem_cursor == 1) and 2 or 1
    elseif btnp(4) then
      if confirm_mem_cursor == 1 then
        aplicar_cambio_memoria((mem_ext == 0) and 1 or 0)
      end
      confirm_mem_abierta = false
    elseif btnp(5) then
      confirm_mem_abierta = false
    end
    return
  end

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

  local max_opt = 15
  if btnp(2) then
    opt_cursor = opt_cursor - 1
    if opt_cursor < 1 then opt_cursor = max_opt end
    menu_anim = -10
  elseif btnp(3) then
    opt_cursor = opt_cursor + 1
    if opt_cursor > max_opt then opt_cursor = 1 end
    menu_anim = 10
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
  local mod_em = (shop_own and shop_own[#shop_own]) and 21 or 18

  if opt_cursor == 1 then
    if izq then idioma = (idioma - 2) % 18 + 1 end
    if der or acc then idioma = (idioma % 18) + 1 end
  elseif opt_cursor == 2 then
    if izq then ui_estilo = (ui_estilo - 2) % 7 + 1 end
    if der or acc then ui_estilo = (ui_estilo % 7) + 1 end
  elseif opt_cursor == 3 then
    if izq then ui_fx = (ui_fx - 1) % 5 menu_anim = -10 end
    if der or acc then ui_fx = (ui_fx + 1) % 5 menu_anim = 10 end
  elseif opt_cursor == 4 then
    if izq then tema_idx = (tema_idx - 2) % 24 + 1 end
    if der or acc then tema_idx = (tema_idx % 24) + 1 end
  elseif opt_cursor == 5 then
    if izq or der or acc then tema_auto_juego = (tema_auto_juego == 0) and 1 or 0 end
  elseif opt_cursor == 6 then
    if izq or der or acc then ui_zoom = (ui_zoom == 0) and 1 or 0 end
  elseif opt_cursor == 7 then
    if izq or der or acc then
      modo_animo = (modo_animo == 0) and 1 or 0
      if modo_animo == 1 then animo_timer = 290 end
    end
  elseif opt_cursor == 8 then
    if izq then emocion_fija = (emocion_fija - 1) % mod_em end
    if der or acc then emocion_fija = (emocion_fija + 1) % mod_em end
  elseif opt_cursor == 9 then
    if izq or der or acc then ranita_oculta = (ranita_oculta == 0) and 1 or 0 end
  elseif opt_cursor == 10 then
    if izq then pet_tipo = (pet_tipo - 1) % 4 end
    if der or acc then pet_tipo = (pet_tipo + 1) % 4 end
  elseif opt_cursor == 11 then
    if acc or der then
      shop_cursor = 1
      shop_scroll = 0
      shop_sel_juego = false
      cambiar_estado(8)
    end
  elseif opt_cursor == 12 then
    if izq or der or acc then
      confirm_mem_abierta = true
      confirm_mem_cursor = 2
    end
  elseif opt_cursor == 13 then
    if acc or der then
      sub_btn_abierta = true
      sub_btn_cursor = 1
      modal_anim = 6
    end
  elseif opt_cursor == 14 then
    if acc or der then
      creditos_y = 128
      cambiar_estado(7)
    end
  elseif opt_cursor == 15 then
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

function genero_de_juego(g)
  if not g then return 6 end
  local id = g.id_juego or 0
  if id > 0 then
    if id <= 45 or (id >= 502 and id <= 526) then return 1
    elseif id <= 85 or id == 426 then return 2
    elseif id <= 145 or (id >= 327 and id <= 425) then return 3
    elseif id <= 191 or (id >= 427 and id <= 501) then return 4
    elseif id <= 252 or (id >= 527 and id <= 604) then return 5
    else return 6 end
  end
  local n = g.nombre or ""
  if contiene_subcadena(n, "souls") or contiene_subcadena(n, "diablo") or contiene_subcadena(n, "witcher") then return 1
  elseif contiene_subcadena(n, "craft") or contiene_subcadena(n, "stardew") or contiene_subcadena(n, "farm") then return 2
  elseif contiene_subcadena(n, "mario") or contiene_subcadena(n, "zelda") or contiene_subcadena(n, "sonic") then return 3
  elseif contiene_subcadena(n, "pokemon") or contiene_subcadena(n, "fantasy") or contiene_subcadena(n, "persona") then return 4
  elseif contiene_subcadena(n, "resident") or contiene_subcadena(n, "silent") or contiene_subcadena(n, "gta") then return 5
  end
  return 6
end

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

  if g then
    genero = genero_de_juego(g)
    local temas_gen = {3, 2, 4, 10, 8, 9}
    if (g.id_juego and g.id_juego > 0) or genero != 6 then
      idx_p = temas_gen[genero] or tema_idx
    end
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
  print("@" .. sub(nombre_usuario, 1, 7), 22, 9, 11)
  print("$" .. monedas, 62, 9, 10)
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
  elseif estado == 8 then
    dibujar_tienda(c_bg, c_pan, c_txt, c_acc, c_atxt)
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
  print("counter games xtree v0.11", 12, 7, 7)

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

function calc_fx(sel, idx)
  if ui_fx == 0 then return 0, 0, 0 end
  if ui_fx == 1 then
    return sel and flr(abs(menu_anim) * 0.8) or 0, 0, 0
  elseif ui_fx == 2 then
    return sel and flr(sin(menu_anim / 10) * 5) or 0, 0, 0
  elseif ui_fx == 3 then
    return 0, 0, sel and flr(sin(ranita_anim / 30) * 1.2) or 0
  else
    local wv = flr(sin((marquee_t + idx * 8) / 24) * 2)
    return sel and (wv + flr(menu_anim * 0.4)) or 0, 0, 0
  end
end


function dibujar_menu_principal(c_bg, c_pan, c_txt, c_acc, c_atxt, idx_t_act, gen)
  cls(c_bg)
  dibujar_cabecera_hud(c_pan, c_txt, c_acc, idx_t_act)

  local dx0, _, p0 = calc_fx(juego_sel == 0, 0)
  if juego_sel == 0 then
    rectfill(4 + dx0 - p0, 18, 86 + dx0 + p0, 27, c_acc)
    print("> [" .. tr(6) .. "]", 7 + dx0, 20, c_atxt)
  else
    rect(4, 18, 86, 27, c_pan)
    print("  [" .. tr(6) .. "]", 7, 20, c_txt)
  end

  local cats_lib, j_disp, max_j = calc_mem_libre()
  local dx1, _, p1 = calc_fx(juego_sel == 1, 1)
  local lbl_add = "[+] " .. sub(tr(3), 1, 10) .. " (" .. #mis_juegos .. "/" .. max_j .. " +" .. j_disp .. ")"
  if juego_sel == 1 then
    rectfill(4 + dx1 - p1, 30, 123 + dx1 + p1, 40, c_acc)
    print("> " .. lbl_add, 7 + dx1, 32, c_atxt)
  else
    rect(4, 30, 123, 40, c_acc)
    print("  " .. lbl_add, 7, 32, 11)
  end

  if #mis_juegos == 0 then
    rect(6, 45, 121, 108, c_pan)
    print("< " .. tr(4) .. " >", 38, 74, 6)
  else
    if ui_estilo == 1 then
      for slot = 1, 4 do
        local i = juego_scroll + slot
        if i <= #mis_juegos then
          local ly = 44 + (slot - 1) * 16
          local sel = (juego_sel == i + 1)
          local dx, _, pd = calc_fx(sel, i + 1)
          local nom = mis_juegos[i].nombre
          if ui_zoom == 1 then nom = sub(nom, 1, 11) else nom = sub(nom, 1, 17) end
          if sel then
            rectfill(4 + dx - pd, ly, 123 + dx + pd, ly + 13, c_acc)
            print((ui_zoom == 1 and "\^w>" or "> ") .. nom .. " >", 7 + dx, ly + 4, c_atxt)
          else
            rectfill(4, ly, 123, ly + 13, c_pan)
            print((ui_zoom == 1 and "\^w " or "  ") .. nom, 7, ly + 4, c_txt)
          end
        end
      end

    elseif ui_estilo == 2 then
      local pag_g = flr(max(0, juego_sel - 2) / 4) * 4
      for slot = 1, 4 do
        local i = pag_g + slot
        if i <= #mis_juegos then
          local col = (slot - 1) % 2
          local fil = flr((slot - 1) / 2)
          local sel = (juego_sel == i + 1)
          local dx, _, pd = calc_fx(sel, i + 1)
          local cx = 4 + col * 61 + flr(dx * 0.5)
          local cy = 44 + fil * 33
          local gen_i = genero_de_juego(mis_juegos[i])
          rectfill(cx - pd, cy, cx + 58 + pd, cy + 30, sel and c_acc or c_pan)
          rect(cx - pd, cy, cx + 58 + pd, cy + 30, sel and 7 or c_acc)
          dibujar_portada_aislada(cx + 3, cy + 3, gen_i, c_acc, c_txt)
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
      end

    elseif ui_estilo == 3 then
      local paso_x = (#mis_juegos > 4) and 14 or 29
      local ini_x = (#mis_juegos > 4) and 14 or 20
      for i = 1, #mis_juegos do
        local sel = (juego_sel == i + 1)
        local dx, _, pd = calc_fx(sel, i + 1)
        local mx = ini_x + (i - 1) * paso_x
        local my = 62 - flr(abs(dx) * 0.4)
        local rad = ((#mis_juegos > 4) and (sel and 9 or 6) or ((ui_zoom == 1) and (sel and 14 or 12) or (sel and 13 or 11))) + pd
        circfill(mx, my, rad, sel and c_acc or c_pan)
        circ(mx, my, rad, sel and 7 or c_acc)
        if #mis_juegos <= 4 then
          if ui_zoom == 1 then
            print("\^w" .. sub(mis_juegos[i].nombre, 1, 2), mx - 8, my - 2, sel and c_atxt or c_txt)
          else
            print(sub(mis_juegos[i].nombre, 1, 3), mx - 5, my - 2, sel and c_atxt or c_txt)
          end
        elseif sel then
          print(tostr(i), mx - 1, my - 2, c_atxt)
        end
      end
      local idx_g = max(1, juego_sel - 1)
      if mis_juegos[idx_g] then
        local dx, _, _ = calc_fx(juego_sel >= 2, idx_g)
        rectfill(6 + dx, 82, 121 + dx, 108, c_pan)
        rect(6 + dx, 82, 121 + dx, 108, c_acc)
        dibujar_portada_aislada(9 + dx, 86, gen, c_acc, c_txt)
        if ui_zoom == 1 then
          print("\^w" .. sub(mis_juegos[idx_g].nombre, 1, 10), 30 + dx, 88, 7)
          print(sub(tr(20), 1, 21), 30 + dx, 99, 11)
        else
          print(sub(mis_juegos[idx_g].nombre, 1, 18), 30 + dx, 88, 7)
          print(sub(tr(20), 1, 21), 30 + dx, 99, 11)
        end
      end

    elseif ui_estilo == 5 then
      local idx_g = max(1, juego_sel - 1)
      local g_act = mis_juegos[idx_g]
      local sel = (juego_sel >= 2)
      local dx, _, pd = calc_fx(sel, idx_g)
      if g_act then
        rectfill(6 + dx - pd, 44, 121 + dx + pd, 108, sel and c_acc or c_pan)
        rect(6 + dx - pd, 44, 121 + dx + pd, 108, sel and 7 or c_acc)
        rectfill(10 + dx, 48, 46 + dx, 84, 0)
        rect(10 + dx, 48, 46 + dx, 84, sel and 7 or c_acc)
        dibujar_portada_aislada(19 + dx, 57, gen, c_acc, c_txt)
        local cat_txt = #g_act.cats .. " " .. sub(tr(5), 1, 11)
        if ui_zoom == 1 then
          local nom_m = texto_marquee(g_act.nombre, 8, sel)
          print("\^w" .. nom_m, 51 + dx, 52, sel and c_atxt or 7)
          print(cat_txt, 51 + dx, 66, sel and c_atxt or 10)
        else
          local nom_m = texto_marquee(g_act.nombre, 16, sel)
          print(nom_m, 51 + dx, 52, sel and c_atxt or 7)
          print(cat_txt, 51 + dx, 64, sel and c_atxt or 10)
          print(sub(tr(20), 1, 16), 51 + dx, 75, sel and c_atxt or 11)
        end
        line(10 + dx, 89, 117 + dx, 89, sel and c_atxt or c_acc)
        for d = 1, #mis_juegos do
          local px = 28 + (d - 1) * 8 + dx
          circfill(px, 98, (d == idx_g) and 3 or 1, (d == idx_g) and 7 or 5)
        end
        print(idx_g .. "/" .. #mis_juegos, 96 + dx, 95, sel and c_atxt or 6)
      end

    elseif ui_estilo == 6 then
      for slot = 1, 4 do
        local i = juego_scroll + slot
        if i <= #mis_juegos then
          local ly = 44 + (slot - 1) * 16
          local sel = (juego_sel == i + 1)
          local dx, _, pd = calc_fx(sel, i + 1)
          local nc = #mis_juegos[i].cats
          rectfill(4 + dx - pd, ly, 123 + dx + pd, ly + 13, sel and c_acc or c_pan)
          rectfill(4 + dx - pd, ly, 7 + dx - pd, ly + 13, sel and 7 or 11)
          local bar_w = min(24, nc * 2)
          rectfill(96 + dx, ly + 4, 96 + bar_w + dx, ly + 9, sel and c_atxt or 11)
          rect(96 + dx, ly + 4, 120 + dx, ly + 9, sel and c_atxt or c_acc)
          if ui_zoom == 1 then
            local nom_m = texto_marquee(mis_juegos[i].nombre, 10, sel)
            print("\^w" .. nom_m, 11 + dx, ly + 4, sel and c_atxt or c_txt)
          else
            local nom_m = texto_marquee(mis_juegos[i].nombre, 19, sel)
            print(nom_m, 11 + dx, ly + 4, sel and c_atxt or c_txt)
          end
        end
      end

    elseif ui_estilo == 7 then
      for slot = 1, 4 do
        local i = juego_scroll + slot
        if i <= #mis_juegos then
          local ly = 44 + (slot - 1) * 16
          local sel = (juego_sel == i + 1)
          local dx, _, pd = calc_fx(sel, i + 1)
          local tot_pts = 0
          for v = 1, #mis_juegos[i].vals do tot_pts = tot_pts + mis_juegos[i].vals[v] end
          rectfill(4 + dx - pd, ly, 123 + dx + pd, ly + 13, sel and c_pan or 0)
          rect(4 + dx - pd, ly, 123 + dx + pd, ly + 13, sel and 7 or c_acc)
          rect(6 + dx, ly + 2, 121 + dx, ly + 11, sel and c_acc or c_pan)
          if ui_zoom == 1 then
            local nom_m = texto_marquee(mis_juegos[i].nombre, 8, sel)
            print("\^w" .. nom_m, 9 + dx, ly + 4, sel and 7 or c_txt)
            print("\^w" .. tot_pts, 118 + dx - (#tostr(tot_pts) * 8), ly + 4, 10)
          else
            local nom_m = texto_marquee(mis_juegos[i].nombre, 11, sel)
            print("p" .. i .. ":" .. nom_m, 9 + dx, ly + 4, sel and 7 or c_txt)
            print(tostr(tot_pts), 118 + dx - (#tostr(tot_pts) * 4), ly + 4, 10)
          end
        end
      end

    else
      for slot = 1, 4 do
        local i = juego_scroll + slot
        if i <= #mis_juegos then
          local ly = 44 + (slot - 1) * 16
          local sel = (juego_sel == i + 1)
          local dx, _, pd = calc_fx(sel, i + 1)
          local tot_pts = 0
          for v = 1, #mis_juegos[i].vals do tot_pts = tot_pts + mis_juegos[i].vals[v] end
          rectfill(4 + dx - pd, ly, 123 + dx + pd, ly + 13, sel and c_acc or 0)
          rect(4 + dx - pd, ly, 123 + dx + pd, ly + 13, c_acc)
          if ui_zoom == 1 then
            local nom_m = texto_marquee(mis_juegos[i].nombre, 8, sel)
            print("\^w" .. nom_m, 7 + dx, ly + 4, sel and c_atxt or c_txt)
            print("\^w" .. tot_pts, 120 + dx - (#tostr(tot_pts) * 8), ly + 4, sel and c_atxt or 10)
          else
            local nom_m = texto_marquee(mis_juegos[i].nombre, 12, sel)
            print("#" .. i .. " " .. nom_m, 7 + dx, ly + 4, sel and c_atxt or c_txt)
            print("[" .. tot_pts .. "]", 92 + dx, ly + 4, sel and c_atxt or 10)
          end
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
    local lim_c = juegos_exp[juego_activo] and 20 or 12
    print(#g.cats .. "/" .. lim_c .. " $" .. monedas, 82, 7, 10)
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
  if es_cat and confirm_exp_abierta then
    rectfill(10, 34, 117, 94, 0)
    rect(10, 34, 117, 94, 10)
    rectfill(12, 36, 115, 45, 10)
    print("+20 (" .. monedas .. "$)", 42, 38, 0)
    print(sub(tr_ext(4), 1, 23), 15, 51, 7)
    print(sub(tr_ext(5), 1, 23), 15, 61, 10)
    local s_si = (confirm_exp_cursor == 1)
    local s_no = (confirm_exp_cursor == 2)
    rectfill(20, 75, 56, 86, s_si and 11 or 1)
    print(tr(8), 32, 78, s_si and 0 or 5)
    rectfill(70, 75, 106, 86, s_no and 8 or 1)
    print(tr(9), 82, 78, s_no and 7 or 5)
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
  local lim_c = juegos_exp[juego_activo] and 20 or 12
  local ult_i = ultimo_cat_inc[juego_activo] or 0

  rectfill(0, 0, 127, 22, c_pan)
  line(0, 22, 127, 22, c_acc)
  dibujar_portada_aislada(3, 2, gen, c_acc, c_txt)
  print(sub(g.nombre, 1, 18), 24, 3, 7)
  print(tr(5) .. " (" .. #g.cats .. "/" .. lim_c .. ")", 24, 12, c_txt)
  if juegos_exp[juego_activo] and ult_i > 0 and g.cats[ult_i] then
    local hr = ultimo_hora_inc[juego_activo]
    local tag_u = "*" .. sub(cat_tr(g.cats[ult_i]), 1, 5) .. (hr != "" and (" " .. hr) or "")
    print(tag_u, 78, 12, 10)
  else
    print("$" .. monedas, 104, 12, 10)
  end

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
  local fx_nom = {"off", "slide", "spring", "pulse", "wave"}
  local pets_nom = {"frog", "cat", "dog", "turtle"}

  local opt_lbl = {
    tr(1),
    tr(12),
    tr_ext(1),
    tr(13),
    tr(14),
    tr(15),
    tr(16),
    tr(17),
    "pet " .. tr(17),
    tr_ext(2),
    tr_shop(1) .. " ($" .. monedas .. ")",
    tr_ext(3),
    tr(18),
    tr(11),
    lbl_reset[idioma] or "reset all:"
  }

  local opt_val = {
    "<" .. cod_lang[idioma] .. ">",
    estilos_nom[ui_estilo] or "#1",
    fx_nom[(ui_fx or 0) + 1] or "off",
    nombres_temas[tema_idx] or "cyber",
    tema_auto_juego == 1 and "on" or "off",
    ui_zoom == 1 and "on" or "off",
    modo_animo == 1 and "on" or "off",
    emocion_fija == 0 and "auto" or ("#" .. emocion_fija),
    ranita_oculta == 0 and "on" or "off",
    pets_nom[(pet_tipo or 0) + 1] or "frog",
    "[>]",
    mem_ext == 1 and "on" or "off",
    "[cfg]",
    "[>]",
    "[!]"
  }

  for slot = 1, 5 do
    local idx = opt_scroll + slot
    if idx <= #opt_lbl then
      local ly = 20 + (slot - 1) * 17
      local sel = (opt_cursor == idx)
      local dx, _, pd = calc_fx(sel, idx)
      local bg_col = sel and (idx == 15 and 8 or c_acc) or c_pan
      rectfill(5 + dx - pd, ly, 122 + dx + pd, ly + 13, bg_col)
      local lbl_s = opt_lbl[idx] or ""
      local val_s = opt_val[idx] or ""
      print((sel and "> " or "  ") .. lbl_s, 8 + dx, ly + 4, sel and 7 or (idx == 15 and 8 or c_txt))
      print(val_s, 119 + dx - #val_s * 4, ly + 4, sel and 7 or (idx == 15 and 8 or 11))
    end
  end

  rectfill(0, 112, 127, 127, 0)
  line(0, 112, 127, 112, c_acc)
  print(tr(19), 6, 117, 6)
  dibujar_ranita(112, 114)

  if sub_btn_abierta then
    dibujar_subventana_botones(c_pan, c_txt, c_acc, c_atxt)
  end

  if confirm_mem_abierta then
    rectfill(10, 34, 117, 94, 0)
    rect(10, 34, 117, 94, 11)
    rectfill(12, 36, 115, 45, 11)
    print(sub(tr_ext(3), 1, 14), 38, 38, 0)
    print(sub(tr_ext(6), 1, 23), 15, 51, 7)
    print(sub(tr(19), 4, 23), 15, 61, 10)
    local s_si = (confirm_mem_cursor == 1)
    local s_no = (confirm_mem_cursor == 2)
    rectfill(20, 75, 56, 86, s_si and 11 or 1)
    print(tr(8), 32, 78, s_si and 0 or 5)
    rectfill(70, 75, 106, 86, s_no and 8 or 1)
    print(tr(9), 82, 78, s_no and 7 or 5)
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
    print(tr(9), 82, 78, s_no and 7 or 5)
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
    "version: v0.11",
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

function actualizar_tienda()
  if shop_sel_juego then
    if btnp(5) then
      shop_sel_juego = false
      return
    end
    if #mis_juegos == 0 then
      shop_sel_juego = false
      return
    end
    if btnp(2) then
      shop_j_cursor = shop_j_cursor - 1
      if shop_j_cursor < 1 then shop_j_cursor = #mis_juegos end
      menu_anim = -10
    elseif btnp(3) then
      shop_j_cursor = shop_j_cursor + 1
      if shop_j_cursor > #mis_juegos then shop_j_cursor = 1 end
      menu_anim = 10
    elseif btnp(4) then
      if juegos_exp[shop_j_cursor] then
        mostrar_aviso("ok (+20)!", 30)
      elseif monedas < 12 then
        mostrar_aviso(tr_shop(10) .. "12$", 35)
      else
        local cats_lib, _, _ = calc_mem_libre()
        if cats_lib < 8 then
          mostrar_aviso(tr_shop(13), 35)
        else
          monedas = monedas - 12
          juegos_exp[shop_j_cursor] = true
          guardar_datos()
          mostrar_aviso("#" .. shop_j_cursor .. " +20!", 45)
          shop_sel_juego = false
        end
      end
    end
    return
  end

  if btnp(5) then
    guardar_datos()
    cambiar_estado(6)
    return
  end

  if btnp(2) then
    shop_cursor = shop_cursor - 1
    if shop_cursor < 1 then shop_cursor = 6 end
    menu_anim = -10
  elseif btnp(3) then
    shop_cursor = shop_cursor + 1
    if shop_cursor > 6 then shop_cursor = 1 end
    menu_anim = 10
  end

  if shop_cursor <= shop_scroll then
    shop_scroll = shop_cursor - 1
  elseif shop_cursor > shop_scroll + 4 then
    shop_scroll = shop_cursor - 4
  end

  if btnp(4) then
    local precios = {8, 10, 6, 15, 12, 12}
    if shop_cursor <= 4 then
      if shop_own[shop_cursor] then
        shop_eq[shop_cursor] = not shop_eq[shop_cursor]
        guardar_datos()
        mostrar_aviso(shop_eq[shop_cursor] and tr_shop(8) or "off", 30)
      elseif monedas >= precios[shop_cursor] then
        monedas = monedas - precios[shop_cursor]
        shop_own[shop_cursor] = true
        shop_eq[shop_cursor] = true
        guardar_datos()
        mostrar_aviso(tr_shop(9), 35)
      else
        mostrar_aviso(tr_shop(10) .. precios[shop_cursor] .. "$", 35)
      end
    elseif shop_cursor == 5 then
      if shop_own[#shop_own] then
        mostrar_aviso("ok (#18-20)!", 30)
      elseif monedas >= 12 then
        monedas = monedas - 12
        shop_own[#shop_own] = true
        guardar_datos()
        mostrar_aviso(tr_shop(9), 40)
      else
        mostrar_aviso(tr_shop(10) .. "12$", 35)
      end
    else
      if #mis_juegos == 0 then
        mostrar_aviso(tr(4), 35)
      else
        shop_sel_juego = true
        shop_j_cursor = 1
      end
    end
  end
end


function dibujar_tienda(c_bg, c_pan, c_txt, c_acc, c_atxt)
  cls(c_bg)
  rectfill(0, 0, 127, 14, c_pan)
  line(0, 14, 127, 14, c_acc)
  print(sub(tr_shop(1), 1, 14), 6, 4, 7)
  print("$" .. monedas, 96, 4, 10)

  local shop_nom = {
    tr_shop(2),
    tr_shop(3),
    tr_shop(4),
    tr_shop(5),
    tr_shop(6),
    tr_shop(7)
  }
  local shop_prc = {8, 10, 6, 15, 12, 12}

  for slot = 1, 4 do
    local idx = shop_scroll + slot
    if idx <= 6 then
      local ly = 20 + (slot - 1) * 19
      local sel = (not shop_sel_juego) and (shop_cursor == idx)
      local dx, _, pd = calc_fx(sel, idx)
      local x1 = 5 + dx - pd
      local x2 = 122 + dx + pd
      local owned = (idx <= 4 and shop_own[idx]) or (idx == 5 and shop_own[#shop_own])

      if ui_estilo == 2 then
        rectfill(x1, ly, x2, ly + 15, sel and c_acc or c_pan)
        rect(x1, ly, x2, ly + 15, sel and 7 or c_acc)
      elseif ui_estilo == 3 then
        rectfill(x1 + 2, ly, x2 - 2, ly + 15, sel and c_acc or c_pan)
        rect(x1 + 1, ly, x2 - 1, ly + 15, sel and 7 or c_acc)
      elseif ui_estilo == 4 then
        rectfill(x1, ly, x2, ly + 15, sel and c_acc or 0)
        rect(x1, ly, x2, ly + 15, c_acc)
      elseif ui_estilo == 5 or ui_estilo == 6 then
        rectfill(x1, ly, x2, ly + 15, sel and c_acc or c_pan)
        rectfill(x1, ly, x1 + 2, ly + 15, sel and 7 or (owned and 11 or c_acc))
      elseif ui_estilo == 7 then
        rectfill(x1, ly, x2, ly + 15, sel and c_pan or 0)
        rect(x1, ly, x2, ly + 15, sel and 7 or c_acc)
        rect(x1 + 2, ly + 2, x2 - 2, ly + 13, sel and c_acc or c_pan)
      else
        rectfill(x1, ly, x2, ly + 15, sel and c_acc or c_pan)
      end

      local col_t = sel and ((ui_estilo == 7) and 7 or c_atxt) or c_txt
      local est_s = (shop_prc[idx] or 0) .. "$"
      if idx <= 4 and shop_own[idx] then
        est_s = shop_eq[idx] and "[on]" or "[off]"
      elseif idx == 5 and shop_own[#shop_own] then
        est_s = "[ok]"
      end

      if ui_zoom == 1 then
        local nom_m = texto_marquee(shop_nom[idx] or "", 8, sel)
        print("\^w" .. nom_m, 9 + dx, ly + 5, col_t)
        print(est_s, 119 + dx - #est_s * 4, ly + 5, sel and col_t or (owned and 11 or 10))
      else
        local pref = (ui_estilo == 4) and ("#" .. idx .. " ") or (sel and "> " or "  ")
        local nom_m = texto_marquee(shop_nom[idx] or "", 14, sel)
        print(pref .. nom_m, 8 + dx, ly + 5, col_t)
        print(est_s, 119 + dx - #est_s * 4, ly + 5, sel and col_t or (owned and 11 or 10))
      end
    end
  end

  rectfill(0, 102, 127, 127, 0)
  line(0, 102, 127, 102, c_acc)
  print(sub(tr_shop(12), 1, 21), 6, 114, 6)

  local prev_pet = pet_tipo
  local prev_vis = ranita_oculta
  pet_tipo = 0
  ranita_oculta = 0
  dibujar_ranita(110, 108)
  pet_tipo = prev_pet
  ranita_oculta = prev_vis

  if shop_sel_juego then
    rectfill(10, 22, 117, 99, 0)
    rect(10, 22, 117, 99, c_acc)
    rectfill(12, 24, 115, 34, c_acc)
    print(sub(tr_shop(11), 1, 18), 16, 26, c_atxt)
    local j_off = max(0, shop_j_cursor - 4)
    for slot = 1, 4 do
      local j = j_off + slot
      if j <= #mis_juegos then
        local jy = 38 + (slot - 1) * 14
        local sel_j = (shop_j_cursor == j)
        local dx, _, pd = calc_fx(sel_j, j)
        rectfill(14 + dx - pd, jy, 113 + dx + pd, jy + 12, sel_j and c_acc or c_pan)
        if ui_estilo == 2 or ui_estilo == 4 or ui_estilo == 7 then
          rect(14 + dx - pd, jy, 113 + dx + pd, jy + 12, sel_j and 7 or c_acc)
        end
        local tag_e = juegos_exp[j] and "[+20]" or "[12$]"
        if ui_zoom == 1 then
          local nom_j = texto_marquee(mis_juegos[j].nombre, 7, sel_j)
          print("\^w" .. nom_j, 17 + dx, jy + 3, sel_j and c_atxt or c_txt)
        else
          local nom_j = texto_marquee(mis_juegos[j].nombre, 12, sel_j)
          print(nom_j, 17 + dx, jy + 3, sel_j and c_atxt or c_txt)
        end
        print(tag_e, 111 + dx - #tag_e * 4, jy + 3, sel_j and c_atxt or (juegos_exp[j] and 11 or 10))
      end
    end
  end
end

function dibujar_ranita(x, y)
  if ranita_oculta == 1 then return end
  local off_y = flr(sin(ranita_anim / 60) * 1.5)
  local ry = y + off_y

  if pet_tipo == 1 then
    local sent_lame = (emocion_actual == 2 or emocion_actual == 11 or emocion_actual == 17)
    local sent_miau = (emocion_actual >= 13 and emocion_actual <= 16)
    if sent_lame or sent_miau then
      local lame = sent_lame and ((ranita_anim % 36) < 16)
      local miau = sent_miau and ((ranita_anim % 40) < 14)
      local cola_m = flr(sin(ranita_anim / 30) * 1.5)

      rectfill(x + 2, ry + 5, x + 8, ry + 10, 6)
      line(x + 8, ry + 9, x + 10, ry + 7 + cola_m, 6)
      pset(x + 10, ry + 6 + cola_m, 6)

      pset(x + 3, ry + 10, 7)
      if lame then
        line(x + 6, ry + 8, x + 5, ry + 6, 7)
      else
        pset(x + 7, ry + 10, 7)
      end

      local oreja_y = miau and (ry + 1) or ry
      rectfill(x + 2, ry + 1, x + 8, ry + 5, 6)
      pset(x + 2, oreja_y - 1, 6) pset(x + 2, ry, 6) pset(x + 3, ry, 14)
      pset(x + 8, oreja_y - 1, 6) pset(x + 8, ry, 6) pset(x + 7, ry, 14)

      pset(x + 1, ry + 3, 7) pset(x + 1, ry + 4, 7)
      pset(x + 9, ry + 3, 7) pset(x + 9, ry + 4, 7)

      local parp = (not lame) and ((ranita_anim % 55) < 4)
      if lame or parp then
        line(x + 3, ry + 3, x + 4, ry + 3, 4)
        line(x + 6, ry + 3, x + 7, ry + 3, 4)
      else
        pset(x + 4, ry + 3, 9) pset(x + 6, ry + 3, 9)
      end

      pset(x + 5, ry + 4, 14)
      if lame then
        pset(x + 5, ry + 5, 8)
      elseif miau then
        rectfill(x + 4, ry + 5, x + 6, ry + 5, 8)
      end
      return
    end

    local dormido = (emocion_actual == 6)
    local dir = (cos(ranita_anim / 60) >= 0) and 1 or -1
    local cx = x + (dormido and 0 or flr(sin(ranita_anim / 60) * 3))
    local paso = dormido and 0 or (flr(ranita_anim / 7) % 2)
    local hx = (dir == 1) and (cx + 4) or cx
    local bx = (dir == 1) and cx or (cx + 3)

    local tx = (dir == 1) and bx or (bx + 7)
    line(tx, ry + 6, tx - dir * 2, ry + 3, 6)
    pset(tx - dir, ry + 2 + paso, 6)

    rectfill(bx, ry + 6, bx + 7, ry + 8, 6)
    pset(bx + 1, ry + 9 + paso, 6)
    pset(bx + 3, ry + 10 - paso, 5)
    pset(bx + 5, ry + 9 + paso, 6)
    pset(bx + 7, ry + 10 - paso, 5)

    rectfill(hx, ry + 2, hx + 6, ry + 6, 6)
    pset(hx, ry, 6) pset(hx, ry + 1, 6) pset(hx + 1, ry + 1, 14)
    pset(hx + 6, ry, 6) pset(hx + 6, ry + 1, 6) pset(hx + 5, ry + 1, 14)

    pset(hx - 1, ry + 4, 7) pset(hx - 1, ry + 5, 7)
    pset(hx + 7, ry + 4, 7) pset(hx + 7, ry + 5, 7)

    if emocion_actual == 7 or emocion_actual == 12 then
      line(hx + 2, ry + 1, hx + 4, ry + 1, 10)
      pset(hx + 2, ry, 10) pset(hx + 4, ry, 10)
    end

    if dormido then
      line(hx + 1, ry + 4, hx + 2, ry + 4, 4)
      line(hx + 4, ry + 4, hx + 5, ry + 4, 4)
      if ranita_anim < 30 then print("z", hx + 7, ry - 3, 7) end
    elseif emocion_actual == 5 or emocion_actual == 8 then
      rectfill(hx + 1, ry + 3, hx + 5, ry + 4, 0)
    elseif emocion_actual == 4 or emocion_actual == 9 then
      pset(hx + 1, ry + 4, 4) pset(hx + 2, ry + 3, 4)
      pset(hx + 4, ry + 3, 4) pset(hx + 5, ry + 4, 4)
      pset(hx + 1, ry + 5, 14) pset(hx + 5, ry + 5, 14)
      if ranita_anim < 35 then pset(hx + 3, ry - 2, 14) pset(hx + 2, ry - 3, 8) pset(hx + 4, ry - 3, 8) end
    else
      pset(hx + 2, ry + 4, 9) pset(hx + 4, ry + 4, 9)
    end

    pset(hx + 3, ry + 5, 14)
    if not dormido and (ranita_anim % 28) < 10 then
      pset(hx + 3, ry + 6, 8)
      pset(hx + 3 + dir, ry + 6, 14)
    end

    if emocion_actual == 3 or emocion_actual == 10 then
      local ox = (dir == 1) and (hx + 7) or (hx - 3)
      circfill(ox, ry + 9 - paso, 1, 12)
      pset(ox - dir, ry + 10, 12)
    end
    return

  elseif pet_tipo == 2 then
    rectfill(x + 1, ry + 2, x + 9, ry + 10, 4)
    rectfill(x, ry + 3, x + 1, ry + 7, 9)
    rectfill(x + 9, ry + 3, x + 10, ry + 7, 9)
    rectfill(x + 3, ry + 6, x + 7, ry + 9, 15)
    pset(x + 5, ry + 6, 0)
    if emocion_actual == 6 then
      line(x + 2, ry + 4, x + 4, ry + 4, 0) line(x + 6, ry + 4, x + 8, ry + 4, 0)
      if ranita_anim < 30 then print("z", x + 11, ry - 4, 7) end
    elseif emocion_actual == 5 or emocion_actual == 8 then
      rectfill(x + 1, ry + 3, x + 9, ry + 5, 0)
    else
      pset(x + 3, ry + 4, 0) pset(x + 7, ry + 4, 0)
    end
    if emocion_actual == 4 then pset(x + 5, ry + 9, 8) end
    return

  elseif pet_tipo == 3 then
    local dormido = (emocion_actual == 6)
    if dormido then
      rectfill(x + 1, ry + 5, x + 9, ry + 9, 3)
      rect(x + 2, ry + 6, x + 8, ry + 8, 11)
      line(x + 1, ry + 9, x + 9, ry + 9, 4)
      if ranita_anim < 30 then print("z", x + 10, ry - 1, 7) end
      return
    end

    local dir = (cos(ranita_anim / 60) >= 0) and 1 or -1
    local tx = x + flr(sin(ranita_anim / 60) * 2)
    local paso = flr(ranita_anim / 15) % 2
    local estira = ((ranita_anim % 45) < 28) and 1 or 0

    rectfill(tx + 2, ry + 8 + paso, tx + 3, ry + 10, 11)
    rectfill(tx + 7, ry + 8 + (1 - paso), tx + 8, ry + 10, 11)
    local cola_x = (dir == 1) and tx or (tx + 10)
    pset(cola_x, ry + 7, 11)

    rectfill(tx + 1, ry + 3, tx + 9, ry + 8, 3)
    rect(tx + 2, ry + 4, tx + 8, ry + 7, 11)
    line(tx + 1, ry + 8, tx + 9, ry + 8, 4)

    local hx = (dir == 1) and (tx + 9 + estira) or (tx - 1 - estira)
    rectfill(hx, ry + 5, hx + dir, ry + 7, 11)
    if emocion_actual == 5 or emocion_actual == 8 then
      pset(hx + dir, ry + 5, 0)
    else
      pset(hx + dir, ry + 5, 7)
      pset(hx, ry + 5, 0)
    end
    if emocion_actual == 4 then pset(hx + dir, ry + 7, 8) end
    return
  end
  local eq_ojos = false
  local eq_skin = false
  if shop_eq then
    for k = 1, 4 do
      if k == 3 and shop_eq[k] then eq_ojos = true end
      if k == 4 and shop_eq[k] then eq_skin = true end
    end
  end

  local col_c1 = eq_skin and 9 or 3
  local col_c2 = eq_skin and 10 or 11
  local col_ojo = eq_ojos and 10 or 0

  rectfill(x, ry + 2, x + 10, ry + 10, col_c1)
  rectfill(x + 1, ry + 3, x + 9, ry + 10, col_c2)

  if emocion_actual == 6 then
    line(x, ry + 2, x + 2, ry + 2, 0)
    line(x + 8, ry + 2, x + 10, ry + 2, 0)
    pset(x + 5, ry + 7, 8)
    if ranita_anim < 30 then print("z", x + 11, ry - 4, 7) end
  else
    rectfill(x, ry, x + 2, ry + 2, col_c1)
    rectfill(x + 8, ry, x + 10, ry + 2, col_c1)
    rectfill(x + 1, ry + 1, x + 2, ry + 2, 7)
    rectfill(x + 8, ry + 1, x + 9, ry + 2, 7)
    pset(x + 1, ry + 2, col_ojo)
    pset(x + 9, ry + 2, col_ojo)

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
    elseif emocion_actual == 18 then
      circ(x + 5, ry + 5, 7, 12)
      rectfill(x + 4, ry + 7, x + 6, ry + 8, 8)
    elseif emocion_actual == 19 then
      local c_rgb = (ranita_anim < 20) and 8 or ((ranita_anim < 40) and 11 or 12)
      line(x + 1, ry - 1, x + 9, ry - 1, c_rgb)
      rectfill(x - 1, ry + 2, x, ry + 5, c_rgb)
      rectfill(x + 10, ry + 2, x + 11, ry + 5, c_rgb)
      rectfill(x + 4, ry + 8, x + 6, ry + 8, 8)
    elseif emocion_actual == 20 then
      line(x + 2, ry - 1, x + 3, ry - 3, 10)
      line(x + 5, ry - 1, x + 5, ry - 4, 9)
      line(x + 8, ry - 1, x + 7, ry - 3, 10)
      rectfill(x + 3, ry + 7, x + 7, ry + 8, 8)
    else
      line(x + 3, ry - 2, x + 7, ry - 2, 10)
      pset(x + 3, ry + 7, 8) rectfill(x + 4, ry + 8, x + 6, ry + 8, 8) pset(x + 7, ry + 7, 8)
    end
  end

  if shop_eq then
    for k = 1, 2 do
      if shop_eq[k] then
        if k == 1 then
          rectfill(x + 1, ry - 2, x + 9, ry, 8)
          line(x + 1, ry, x + 11, ry, 7)
        else
          rectfill(x, ry + 1, x + 10, ry + 3, 1)
          line(x + 1, ry + 2, x + 9, ry + 2, 12)
        end
      end
    end
  end
end
