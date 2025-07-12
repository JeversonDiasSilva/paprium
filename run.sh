#!/bin/bash

# Curitiba 12 de Julho de 2025.
# Editor: Jeverson D. Silva ///@JCGAMESCLASSICOS...

# --- Funções auxiliares ---

spinner_loop() {
  local msgs=(
    "Se inscreva no canal para não perder nenhum conteúdo"
    "Whatsapp (41)998205080"
    "@JCGAMESCLASSICOS"
  )
  local i=0
  while true; do
    printf "\r\033[K%s" "${msgs[i]}"  # Limpa a linha antes de imprimir
    i=$(( (i+1) % ${#msgs[@]} ))
    sleep 1
  done
}

type_effect() {
    text="$1"
    delay="${2:-0.05}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# --- Variáveis ---

url="https://github.com/JeversonDiasSilva/paprium/releases/download/v1.0/DEP"
squash=$(basename "$url")
dir_work="/userdata/extractions"
tmp_dir="$dir_work/tmp"
roms_dir="/userdata/roms/megadrive"
core_dir="/usr/lib/libretro"
cfg_default="/usr/share/emulationstation/es_systems.cfg"
cfg_custom="/userdata/system/configs/emulationstation/es_systems.cfg"

gamelist="$roms_dir/gamelist.xml"
images_dir="$roms_dir/images"
videos_dir="$roms_dir/videos"

mkdir -p "$tmp_dir" "$roms_dir" "$core_dir" "$images_dir" "$videos_dir" >/dev/null 2>&1

paprium_entry='
  <game id="493037">
    <path>./Paprium.bin</path>
    <name>Paprium</name>
    <desc>Year 8A2, somewhere at equidistant point between Shanghai, Tokyo and Pyongyang, a Megapolis rose from ashes of the shortest but most devastating nuclear war in history, its name is PAPRIUM. BRUTAL, MASSIVE. You will fight your way through the city with Tug, Alex and Dice. Redefine the word justice, deal with the BLU drug temptation, and more importantly: STAY ALIVE!</desc>
    <image>./images/Paprium-image.png</image>
    <video>./videos/Paprium-video.mp4</video>
    <marquee>./images/Paprium-marquee.png</marquee>
    <thumbnail>./images/Paprium-thumb.png</thumbnail>
    <rating>0.9</rating>
    <releasedate>20201216T000000</releasedate>
    <developer>Watermelon</developer>
    <publisher>Watermelon</publisher>
    <genre>Luta</genre>
    <players>1-2</players>
    <playcount>2</playcount>
    <lastplayed>20250712T184813</lastplayed>
    <md5>91ccdc0b20af85a16bfe0b1a698c19d0</md5>
    <gametime>165</gametime>
    <lang>en</lang>
    <scrap name="ScreenScraper" date="20250712T191503" />
  </game>
'

base_url="https://raw.githubusercontent.com/JeversonDiasSilva/paprium/main/resources"

# --- Início do script ---

clear
type_effect "@JCGAMESCLASSICOS SOLUÇÕES..."
sleep 0.5
type_effect "Iniciando instalação do Paprium..."

spinner_loop &
SPINNER_PID=$!

# Baixar arquivo DEP se não existir
if [ ! -f "$dir_work/$squash" ]; then
    curl -sL "$url" -o "$dir_work/$squash" || {
        kill "$SPINNER_PID"
        echo -e "\nErro ao baixar o arquivo."
        exit 1
    }
fi

# Extrair
unsquashfs -d "$tmp_dir" "$dir_work/$squash" >/dev/null 2>&1
rm -f "$dir_work/$squash" >/dev/null 2>&1

# Mover arquivos extraídos
mv -f "$tmp_dir/paprium" "$roms_dir/" 2>/dev/null || true
mv -f "$tmp_dir/Paprium.bin" "$roms_dir/" 2>/dev/null || true
mv -f "$tmp_dir/genesis_plus_gx_libretro.so" "$core_dir/" 2>/dev/null || true

# Limpar temporários
rm -rf "$tmp_dir" >/dev/null 2>&1

# Atualizar ou criar arquivo es_systems.cfg
if [ ! -f "$cfg_custom" ]; then
    cp "$cfg_default" "$cfg_custom" >/dev/null 2>&1
fi

if grep -q "<name>megadrive</name>" "$cfg_custom"; then
    if ! grep -q "genesis_plus_gx" "$cfg_custom"; then
        sed -i '/<name>megadrive<\/name>/,/<\/system>/ {
            /<cores>/ a\
                    <core>genesis_plus_gx</core>
        }' "$cfg_custom" >/dev/null 2>&1
    fi
else
    cat << EOF >> "$cfg_custom" 2>/dev/null

  <system>
        <fullname>Mega Drive</fullname>
        <name>megadrive</name>
        <manufacturer>Sega</manufacturer>
        <release>1988</release>
        <hardware>console</hardware>
        <path>/userdata/roms/megadrive</path>
        <extension>.bin .gen .md .sg .smd .zip .7z</extension>
        <command>emulatorlauncher %CONTROLLERSCONFIG% -system %SYSTEM% -rom %ROM% -gameinfoxml %GAMEINFOXML% -systemname %SYSTEMNAME%</command>
        <platform>genesis, megadrive</platform>
        <theme>megadrive</theme>
        <group>megadrive</group>
        <emulators>
            <emulator name="libretro">
                <cores>
                    <core>blastem</core>
                    <core default="true">genesisplusgx</core>
                    <core>genesis_plus_gx</core>
                    <core>genesisplusgx-wide</core>
                    <core>picodrive</core>
                </cores>
            </emulator>
        </emulators>
  </system>
EOF
fi

# Atualizar gamelist.xml
if [ ! -f "$gamelist" ]; then
  cat > "$gamelist" <<EOF
<?xml version="1.0"?>
<gameList>
$paprium_entry
</gameList>
EOF
else
  # Remove última linha </gameList>
  sed -i '$d' "$gamelist"
  echo "$paprium_entry" >> "$gamelist"
  echo "</gameList>" >> "$gamelist"
fi

# Baixar imagens e vídeos
curl -s -L "$base_url/images/Paprium-image.png" -o "$images_dir/Paprium-image.png"
curl -s -L "$base_url/images/Paprium-marquee.png" -o "$images_dir/Paprium-marquee.png"
curl -s -L "$base_url/images/Paprium-thumb.png" -o "$images_dir/Paprium-thumb.png"
curl -s -L "$base_url/videos/Paprium-video.mp4" -o "$videos_dir/Paprium-video.mp4"

batocera-save-overlay >/dev/null 2>&1

# Finalizar animação
kill "$SPINNER_PID" >/dev/null 2>&1
printf "\r\033[K"  # Limpa a linha da animação

type_effect "✅ Paprium instalado com sucesso!"
