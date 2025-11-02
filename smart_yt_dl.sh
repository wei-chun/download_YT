#!/bin/bash
# ==========================================
# Smart-YTDLP.sh
# 智慧 YouTube 下載器 for macOS
# - 自動偵測最佳 client
# - 依頻道名稱分類資料夾
# - 頻道專屬下載紀錄
# - 自動下載字幕與縮圖（含內嵌）
# - 支援 cookies（Premium）
# ==========================================

VIDEO_URL="$1"
if [ -z "$VIDEO_URL" ]; then
  echo "❌ 請輸入 YouTube 影片或播放清單網址"
  echo "👉 用法： ./Smart-YTDLP.sh <URL>"
  exit 1
fi

# =======================
# ⚙️ 設定區
# =======================
CLIENTS=("android_embedded" "tv_embedded" "android" "web_embedded" "web")
AUTO_UPDATE=true
MERGE_FORMAT="mp4"
SUB_LANGS="zh-Hant,zh-Hans,en"
COOKIES_FILE="$(dirname "$0")/cookies.txt"

# =======================
# 🧩 常用函式
# =======================
section() {
  echo
  echo "==== $1 ===="
}

update_ytdlp() {
  if $AUTO_UPDATE; then
    section "檢查 yt-dlp 是否為最新版本..."
    if command -v brew >/dev/null 2>&1; then
      echo "📦 使用 Homebrew 更新 yt-dlp..."
      brew update >/dev/null 2>&1
      brew upgrade yt-dlp || echo "⚠️ Homebrew 更新 yt-dlp 時發生問題。"
    else
      echo "⚠️ 系統未安裝 Homebrew，請手動更新 yt-dlp。"
    fi
  fi
}

# =======================
# 🚀 主程式
# =======================
section "智慧 YouTube 下載器啟動"
update_ytdlp

TYPE="video"
[[ "$VIDEO_URL" =~ playlist ]] && TYPE="playlist"
[[ "$VIDEO_URL" =~ shorts ]] && TYPE="shorts"
echo "📺 偵測影片類型：$TYPE"

# -----------------------
# 📡 取得頻道名稱
# -----------------------
section "取得頻道資訊..."
CHANNEL_NAME=$(yt-dlp --get-filename -o "%(channel)s" "$VIDEO_URL" 2>/dev/null)
[ -z "$CHANNEL_NAME" ] && CHANNEL_NAME="未知頻道"
CHANNEL_NAME=$(echo "$CHANNEL_NAME" | sed 's#[\\/:\*\?"<>\|]#_#g')

CHANNEL_DIR="$(dirname "$0")/$CHANNEL_NAME"
mkdir -p "$CHANNEL_DIR"
ARCHIVE_FILE="${CHANNEL_NAME}.txt"

# -----------------------
# 🧠 偵測最佳 client
# -----------------------
section "測試可用 client..."
BEST_CLIENT=""
BEST_RES=0

for c in "${CLIENTS[@]}"; do
  echo
  echo "🧩 測試 client：$c"
  FORMATS_JSON=$(yt-dlp -j --extractor-args "youtube:player_client=$c" "$VIDEO_URL" 2>/dev/null)
  if [ -z "$FORMATS_JSON" ]; then
    echo "⚠️ $c 無可用格式"
    continue
  fi
  RES=$(echo "$FORMATS_JSON" | jq -r '.formats | map(select(.height!=null)) | sort_by(.height) | last | .height')
  if [ -n "$RES" ] && [ "$RES" != "null" ]; then
    echo "✅ $c 可用最高畫質：${RES}p"
    if [ "$RES" -gt "$BEST_RES" ]; then
      BEST_RES=$RES
      BEST_CLIENT=$c
    fi
  else
    echo "⚠️ $c 無可用格式"
  fi
done

if [ -z "$BEST_CLIENT" ]; then
  echo "❌ 找不到可下載格式，請稍後再試。"
  exit 1
fi

section "選擇最佳 client：$BEST_CLIENT（${BEST_RES}p）"

# -----------------------
# 🗂️ 輸出檔案格式
# -----------------------
OUTPUT_PATTERN="$CHANNEL_DIR/%(title)s [%(id)s].%(ext)s"

# -----------------------
# 🎬 下載影片
# -----------------------
section "開始下載（$BEST_CLIENT，${BEST_RES}p）"

ARGS=(
  -f "bestvideo+bestaudio/best"
  --merge-output-format "$MERGE_FORMAT"
  --extractor-args "youtube:player_client=$BEST_CLIENT"
  --output "$OUTPUT_PATTERN"
  --download-archive "$ARCHIVE_FILE"
  --write-thumbnail
  --embed-thumbnail
  --write-subs
  --write-auto-subs
  --embed-subs
  --sub-langs "$SUB_LANGS"
  --embed-metadata
  --no-mtime
)

[ -f "$COOKIES_FILE" ] && ARGS+=(--cookies "$COOKIES_FILE")
ARGS+=("$VIDEO_URL")

yt-dlp "${ARGS[@]}"

section "✅ 下載完成！"
echo "📂 儲存位置：$CHANNEL_DIR"
