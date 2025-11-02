#!/bin/bash
# =============================================================================
# Smart-YTDLP.sh
# 智慧 YouTube 下載器 - macOS Bash 版本
# 功能：
# - 自動偵測最佳 client
# - 依頻道名稱分類資料夾
# - 各頻道個別下載紀錄
# - 自動下載字幕、縮圖並內嵌
# =============================================================================

set -e
shopt -s extglob

# -----------------------
# ⚙️ 設定區
# -----------------------
VideoURL="$1"
if [[ -z "$VideoURL" ]]; then
    echo "用法: $0 <YouTube影片或播放清單URL>"
    exit 1
fi

Clients=("android_embedded" "tv_embedded" "android" "web_embedded" "web")
MergeFormat="mp4"
SubtitleLangs="zh-Hant,zh-Hans,en"
CookiesFile="cookies.txt"

# -----------------------
# 🧠 取得頻道名稱（只取第一個影片）
# -----------------------
echo "==== 取得頻道資訊 ===="

channelName=$(yt-dlp -j --playlist-items 1 --cookies-from-browser firefox "$VideoURL" 2>/dev/null | jq -r '.channel // empty')

if [[ -z "$channelName" ]]; then
    echo "⚠️ JSON 取得頻道名稱失敗，改用 get-filename 備援..."
    channelName=$(yt-dlp --playlist-items 1 --get-filename -o "%(channel)s" --cookies-from-browser firefox "$VideoURL")
fi

if [[ -z "$channelName" ]]; then
    channelName="未知頻道"
fi

# 清理非法檔名字元
channelName="${channelName//[\/\\\:\*\?\"<>\|]/_}"
ChannelDir="./$channelName"
mkdir -p "$ChannelDir"

ArchiveFile="$channelName.txt"

echo "📺 頻道名稱: $channelName"

# -----------------------
# 🧩 測試可用 client（只解析第一個影片）
# -----------------------
echo "==== 測試可用 client ===="
bestClient=""
bestRes=0

for c in "${Clients[@]}"; do
    echo "🧩 測試 client: $c"
    formatsJson=$(yt-dlp -j --extractor-args "youtube:player_client=$c" --playlist-items 1 --cookies-from-browser firefox "$VideoURL" 2>/dev/null || true)
    if [[ -n "$formatsJson" ]]; then
        maxRes=$(echo "$formatsJson" | jq '[.formats[] | select(.height != null) | .height] | max')
        if [[ -n "$maxRes" ]]; then
            echo "✅ $c 可用最高畫質: ${maxRes}p"
            if (( maxRes > bestRes )); then
                bestRes=$maxRes
                bestClient=$c
            fi
        else
            echo "⚠️ $c 無可用格式"
        fi
    else
        echo "⚠️ $c 無可用格式"
    fi
done

if [[ -z "$bestClient" ]]; then
    echo "❌ 找不到可下載格式，請稍後再試。"
    exit 1
fi

echo "==== 選擇最佳 client: $bestClient (${bestRes}p) ===="

# -----------------------
# 🗂️ 輸出檔案格式
# -----------------------
OutputPattern="$ChannelDir/%(title)s [%(id)s].%(ext)s"

# -----------------------
# 🎬 下載影片（支援播放清單多影片）
# -----------------------
echo "==== 開始下載 ===="

videoList=$(yt-dlp -j --flat-playlist --cookies-from-browser firefox "$VideoURL" 2>/dev/null)
videoURLs=()

if [[ $(echo "$videoList" | jq type) == "\"array\"" ]]; then
    videoURLs=($(echo "$videoList" | jq -r '.[]?.url'))
else
    videoURLs=("$VideoURL")
fi

for vid in "${videoURLs[@]}"; do
    if [[ $vid != http* ]]; then
        vid="https://www.youtube.com/watch?v=$vid"
    fi
    echo "🎬 開始下載影片: $vid"
    
    yt-dlp -f "bestvideo+bestaudio/best" \
        --merge-output-format "$MergeFormat" \
        --extractor-args "youtube:player_client=$bestClient" \
        -o "$OutputPattern" \
        --download-archive "$ArchiveFile" \
        --write-thumbnail --embed-thumbnail \
        --write-subs --write-auto-subs --embed-subs \
        --sub-langs "$SubtitleLangs" \
        --embed-metadata \
        --no-mtime \
        --cookies-from-browser firefox \
        --newline \
        "$vid"
done

echo "==== 全部下載完成 ===="
echo "📂 儲存位置: $(realpath "$ChannelDir")"
