#!/bin/bash
# Curitiba 12 de Julho de 2025.
# Editor: Jeverson D. Silva   ///@JCGAMESCLASSICOS...

url="https://github.com/JeversonDiasSilva/paprium/releases/download/v1.0/DEP"
squash=$(basename "$url")
dir_work="/userdata/extractions"
tmp_dir="$dir_work/tmp"
roms_dir="/userdata/roms/megadrive"
core_dir="/usr/lib/libretro"
cfg_default="/usr/share/emulationstation/es_systems.cfg"
cfg_custom="/userdata/system/configs/emulationstation/es_systems_firefox.cfg"

mkdir -p "$tmp_dir" "$roms_dir" "$core_dir"

if [ ! -f "$dir_work/$squash" ]; then
    echo "⏬ Baixando arquivo $squash..."
    curl -L "$url" -o "$dir_work/$squash"
    [ $? -ne 0 ] && echo "❌ Erro no download." && exit 1
else
    echo "✅ Arquivo $squash já existe. Pulando download."
fi

echo "📦 Extraindo $squash..."
unsquashfs -d "$tmp_dir" "$dir_work/$squash" || { echo "❌ Erro ao extrair."; exit 1; }

rm "$dir_work/$squash"

echo "📂 Movendo arquivos..."
mv -f "$tmp_dir/paprium" "$roms_dir/"
mv -f "$tmp_dir/Paprium.bin" "$roms_dir/"
mv -f "$tmp_dir/genesis_plus_gx_libretro.so" "$core_dir/"

# 🧹 Limpa a pasta temporária
echo "🧹 Limpando arquivos temporários..."
rm -rf "$tmp_dir"

if [ ! -f "$cfg_custom" ]; then
    echo "📁 Criando $cfg_custom a partir do padrão..."
    cp "$cfg_default" "$cfg_custom"
fi

if grep -q "<name>megadrive</name>" "$cfg_custom"; then
    if ! grep -q "genesis_plus_gx" "$cfg_custom"; then
        echo "🔧 Adicionando core genesis_plus_gx à entrada existente..."
        sed -i '/<name>megadrive<\/name>/,/<\/system>/ {
            /<cores>/ {
                a\                    <core>genesis_plus_gx</core>
            }
        }' "$cfg_custom"
    else
        echo "✅ Core genesis_plus_gx já está presente."
    fi
else
    echo "➕ Adicionando entrada completa do Mega Drive..."
    cat << EOF >> "$cfg_custom"

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

echo "💾 Salvando alterações na overlay..."
batocera-save-overlay

echo "🎮 Paprium instalado e configurado com sucesso!"