#!/bin/bash
# =============================================================================
# Smart-YTDLP.sh
# 智慧 YouTube 下載器 - macOS Bash 版本
# 功能：
# - 自動偵測最佳 client
# - 依頻道名稱分類資料夾
# - 各頻道個別下載紀錄
# - 自動下載字幕、縮圖並內嵌
# - 支援 cookies（Premium 登入）
# =============================================================================

# ------------------------
# ⚙️ 設定區
# ------------------------
CLIENTS=("android_embedded" "tv_embedded" "android" "web_embedded" "web")
MERGE_FORMAT="mp4"
SUBTITLE_LANGS="zh-Hant,zh-Hans,en"
COOKIES_FILE="$(pwd)/cookies.txt"
AUTO_UPDATE=true

# ------------------------
# 🔧 函式
# ------------------------
write_section() {
    echo -e "\n==== $1 ===="
}

update_ytdlp() {
    if [ "$AUTO_UPDATE" = true ]; then
        write_section "檢查 yt-dlp 是否為最新版本..."
        if ! command -v yt-dlp >/dev/null 2>&1; then
            echo "⚠️ 找不到 yt-dlp，請先安裝。" 
            return 1
        fi
        yt-dlp -U
    fi
    return 0
}

detect_video_type() {
    if [[ "$VIDEO_URL" =~ "playlist" ]]; then
        echo "playlist"
    elif [[ "$VIDEO_URL" =~ "shorts" ]]; then
        echo "shorts"
    else
        echo "video"
    fi
}

# ------------------------
# 🚀 主程式
# ------------------------
if [ -z "$1" ]; then
    echo "請提供影片或播放清單網址"
    exit 1
fi

VIDEO_URL="$1"

write_section "智慧 YouTube 下載器啟動"
update_ytdlp || exit 1

TYPE=$(detect_video_type)
echo "📺 偵測影片類型：$TYPE"

# ------------------------
# 📡 取得頻道名稱
# ------------------------
write_section "取得頻道資訊..."
CHANNEL_NAME=$(yt-dlp --get-filename -o "%(channel)s" "$VIDEO_URL" 2>/dev/null | head -n1)

if [ -z "$CHANNEL_NAME" ]; then
    CHANNEL_NAME="未知頻道"
fi

# 清理非法字元
CHANNEL_NAME=$(echo "$CHANNEL_NAME" | sed 's/[\\\/:*?"<>|]/_/g')
CHANNEL_DIR="$(pwd)/$CHANNEL_NAME"

if [ ! -d "$CHANNEL_DIR" ]; then
    echo "📁 建立資料夾：$CHANNEL_DIR"
    mkdir -p "$CHANNEL_DIR"
fi

# 頻道專屬下載紀錄
ARCHIVE_FILE="$CHANNEL_NAME.txt"

# ------------------------
# 🧠 自動偵測最佳 client
# ------------------------
write_section "測試可用 client..."
BEST_CLIENT=""
BEST_RES=0

for C in "${CLIENTS[@]}"; do
    echo -e "\n🧩 測試 client：$C"
    EXTRA_ARGS="youtube:player_client=$C"

    FORMATS_JSON=$(yt-dlp -j --extractor-args "$EXTRA_ARGS" "$VIDEO_URL" 2>/dev/null)
    if [ -n "$FORMATS_JSON" ]; then
        RES_LIST=$(echo "$FORMATS_JSON" | jq '.formats[] | select(.height != null) | .height' 2>/dev/null)
        if [ -n "$RES_LIST" ]; then
            MAX_RES=$(echo "$RES_LIST" | sort -n | tail -n1)
            echo "✅ $C 可用最高畫質：${MAX_RES}p"
            if [ "$MAX_RES" -gt "$BEST_RES" ]; then
                BEST_RES=$MAX_RES
                BEST_CLIENT=$C
            fi
        else
            echo "⚠️ $C 無可用格式"
        fi
    else
        echo "⚠️ $C 無可用格式"
    fi
done

if [ -z "$BEST_CLIENT" ]; then
    echo "❌ 找不到可下載格式，請稍後再試。"
    exit 1
fi

write_section "選擇最佳 client：$BEST_CLIENT（${BEST_RES}p）"

# ------------------------
# 🗂️ 輸出檔案格式
# ------------------------
OUTPUT_PATTERN="$CHANNEL_DIR/%(title)s [%(id)s].%(ext)s"

# ------------------------
# 🎬 下載影片
# ------------------------
write_section "開始下載（$BEST_CLIENT，${BEST_RES}p）"

ARGS=(
    "-f" "bestvideo+bestaudio/best"
    "--merge-output-format" "$MERGE_FORMAT"
    "--extractor-args" "youtube:player_client=$BEST_CLIENT"
    "--output" "$OUTPUT_PATTERN"
    "--download-archive" "$ARCHIVE_FILE"
    "--write-thumbnail" "--embed-thumbnail"
    "--write-subs" "--write-auto-subs" "--embed-subs"
    "--sub-langs" "$SUBTITLE_LANGS"
    "--embed-metadata" "--no-mtime"
)

if [ -f "$COOKIES_FILE" ]; then
    ARGS+=("--cookies" "$COOKIES_FILE")
fi

ARGS+=("$VIDEO_URL")

yt-dlp "${ARGS[@]}"

write_section "✅ 下載完成！"
echo "📂 儲存位置：$CHANNEL_DIR"
