#!/bin/bash


# Command-line options
BG_COLOR="black"
SOURCE="source.png"
ROUND_OFFSET_X=0
ROUND_OFFSET_Y=0
ROUND_SCALE=0
FORMED_OFFSET_X=0
FORMED_OFFSET_Y=0
FORMED_SCALE=0
DISABLE_ANDROID="no"
DISABLE_GENERAL="no"
DISABLE_MACOS="no"
DISABLE_NOTIFY="no"
DISABLE_WINDOWS="no"

usage() {
  echo "Usage: $0 [--bg-color color] [--source file] [--round_offset_x offset] [--round_offset_y offset] [--round_scale scale] [--formed_offset_x offset] [--formed_offset_y offset] [--formed_scale scale] [--disable_android] [--disable_general] [--disable_macos] [--disable_notify] [--disable_windows]"
  echo "  --bg-color color"
  echo "  --source file"
  echo "  --round_offset_x offset"
  echo "  --round_offset_y offset"
  echo "  --round_scale scale"
  echo "  --formed_offset_x offset"
  echo "  --formed_offset_y offset"
  echo "  --formed_scale scale"
  echo "  --disable_android"
  echo "  --disable_general"
  echo "  --disable_general"
  echo "  --disable_notify"
  echo "  --disable_general"
  exit 1
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --bg-color) BG_COLOR="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    --round_offset_x) ROUND_OFFSET_X=$2; shift 2 ;;
    --round_offset_y) ROUND_OFFSET_Y=$2; shift 2 ;;
    --round_scale) ROUND_SCALE=$2; shift 2 ;;
    --formed_offset_x) FORMED_OFFSET_X=$2; shift 2 ;;
    --formed_offset_y) FORMED_OFFSET_Y=$2; shift 2 ;;
    --formed_scale) FORMED_SCALE=$2; shift 2 ;;
    --disable_android) DISABLE_ANDROID="yes"; shift ;;
    --disable_general) DISABLE_GENERAL="yes"; shift ;;
    --disable_macos) DISABLE_MACOS="yes"; shift ;;
    --disable_notify) DISABLE_NOTIFY="yes"; shift ;;
    --disable_windows) DISABLE_WINDOWS="yes"; shift ;;
    *) usage ;;
  esac
done


# Prepare - Round
SOURCE_WIDTH=$(identify -format "%w" "$SOURCE")
SOURCE_HEIGHT=$(identify -format "%h" "$SOURCE")

CENTER_X=$((SOURCE_WIDTH / 2))
CENTER_Y=$((SOURCE_HEIGHT / 2))

CROP_WIDTH=920
CROP_HEIGHT=$((SOURCE_HEIGHT * CROP_WIDTH / SOURCE_WIDTH))
CROP_X=$((CENTER_X - CROP_WIDTH / 2))
CROP_Y=$((CENTER_Y - CROP_HEIGHT / 2))
convert "$SOURCE" -crop "${CROP_WIDTH}x${CROP_HEIGHT}+${CROP_X}+${CROP_Y}" +repage "tmp_round_fg.png"
if [ $ROUND_SCALE -ne 0 ]; then
  convert "tmp_round_fg.png" -resize ${ROUND_SCALE}x "tmp_round_fg.png"
fi

width=1024
height=1024
circle_radius=920/2
convert -size ${width}x${height} xc:transparent -fill ${BG_COLOR} -stroke ${BG_COLOR} -strokewidth 0 -draw "circle $((width / 2)),$((height / 2)) $((width / 2)),$((height / 2 - circle_radius))" "tmp_round_bg.png"

convert "tmp_round_bg.png" "tmp_round_fg.png" -gravity center -geometry +${ROUND_OFFSET_X}+${ROUND_OFFSET_Y} -composite "tmp_round.png"
convert "tmp_round.png" -trim +repage "tmp_round_trim.png"


# Prepare - Formed
convert "$SOURCE" -trim +repage "tmp_formed_fg.png"
FORMED_SCALE=$((FORMED_SCALE += 650))
convert "tmp_formed_fg.png" -resize ${FORMED_SCALE}x${FORMED_SCALE}\> "tmp_formed_fg.png"

width=1024
height=1024
square_size=820
corner_radius=190
x_offset=$(( (width - square_size) / 2 ))
y_offset=$(( (height - square_size) / 2 ))
convert -size ${width}x${height} xc:transparent -fill ${BG_COLOR} -stroke ${BG_COLOR} -strokewidth 0 -draw "roundrectangle $x_offset,$y_offset $((x_offset + square_size)),$((y_offset + square_size)) $corner_radius,$corner_radius" "tmp_formed_bg.png"

convert "tmp_formed_bg.png" "tmp_formed_fg.png" -gravity center -geometry +${FORMED_OFFSET_X}+${FORMED_OFFSET_Y} -composite "tmp_formed.png"


# Android
if [ "$DISABLE_ANDROID" == "no" ]; then
  mkdir -p "drawable-mdpi"
  mkdir -p "drawable-hdpi"
  mkdir -p "drawable-xhdpi"
  mkdir -p "drawable-xxhdpi"
  mkdir -p "drawable-xxxhdpi"

  convert "tmp_round.png" -resize 48x48 "drawable-mdpi/ic_launcher_round.png"
  convert "tmp_round.png" -resize 72x72 "drawable-hdpi/ic_launcher_round.png"
  convert "tmp_round.png" -resize 96x96 "drawable-xhdpi/ic_launcher_round.png"
  convert "tmp_round.png" -resize 144x144 "drawable-xxhdpi/ic_launcher_round.png"
  convert "tmp_round.png" -resize 192x192 "drawable-xxxhdpi/ic_launcher_round.png"

  convert "tmp_formed.png" -resize 48x48 "drawable-mdpi/ic_launcher.png"
  convert "tmp_formed.png" -resize 72x72 "drawable-hdpi/ic_launcher.png"
  convert "tmp_formed.png" -resize 96x96 "drawable-xhdpi/ic_launcher.png"
  convert "tmp_formed.png" -resize 144x144 "drawable-xxhdpi/ic_launcher.png"
  convert "tmp_formed.png" -resize 192x192 "drawable-xxxhdpi/ic_launcher.png"

  convert "tmp_round_trim.png" -resize 512x512 "presplash.png"

  convert "tmp_round_trim.png" -resize 115x115 "tmp_presplash_fg.png"
  convert -size 512x512 xc:transparent "tmp_presplash_small_bg.png"
  convert "tmp_presplash_small_bg.png" "tmp_presplash_fg.png" -gravity center -composite "presplash_small.png"

  if [ "$DISABLE_NOTIFY" == "no" ]; then
    convert "$SOURCE" -trim +repage "tmp_notify.png"
    convert "tmp_notify.png" -fuzz 10% -fill white -opaque black -resize 256x256 "notify.png"
    convert "tmp_notify.png" -fuzz 90% -transparent black "notify.png"
    convert "tmp_notify.png" -fuzz 10% -fill black -opaque white -resize 256x256 "notify_black.png"
    convert "notify_black.png" -fuzz 90% -transparent white "notify_black.png"

    convert "notify.png" -resize 48x48 "drawable-mdpi/ic_tile_icon.png"
    convert "notify.png" -resize 72x72 "drawable-hdpi/ic_tile_icon.png"
    convert "notify.png" -resize 96x96 "drawable-xhdpi/ic_tile_icon.png"
    convert "notify.png" -resize 144x144 "drawable-xxhdpi/ic_tile_icon.png"
    convert "notify.png" -resize 192x192 "drawable-xxxhdpi/ic_tile_icon.png"
  fi
fi


# General
if [ "$DISABLE_GENERAL" == "no" ]; then
  convert "tmp_round_trim.png" -resize 512x512 "icon.png"
  convert "tmp_round_trim.png" -resize 256x256 "256.png"
fi


# MacOS
if [ "$DISABLE_MACOS" == "no" ]; then
  rm icon.icns
  rm -r icon.iconset
  python3 icons_macos.py tmp_round.png --out ./ --use-sips
  mv icon_macos.icns icon.icns
  mv icon_macos.iconset icon.iconset
fi


# Windows
if [ "$DISABLE_WINDOWS" == "no" ]; then
  convert "tmp_round_trim.png" -define icon:auto-resize=16,32,48 -compress zip "icon.ico"
fi


# Cleanup
rm tmp_*.png
