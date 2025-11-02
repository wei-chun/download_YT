<#
.SYNOPSIS
智慧 YouTube 下載器 - PowerShell 版本
- 自動偵測最佳 client
- 依頻道名稱分類資料夾
- 各頻道個別下載紀錄
- 自動下載字幕、縮圖並內嵌
- 支援 cookies（Premium 登入）
- 相容 PowerShell 5.1
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$VideoURL
)

# ========================
# ⚙️ 設定區
# ========================
$Clients = @("android_embedded","tv_embedded","android","web_embedded","web")
$AutoUpdate = $true
$MergeFormat = "mp4"
$SubtitleLangs = "zh-Hant,zh-Hans,en"
$CookiesFile = Join-Path $PSScriptRoot "cookies.txt"

# ========================
# 🔧 常用函式
# ========================
function Write-Section($text, $color="Cyan") {
    Write-Host "`n==== $text ====" -ForegroundColor $color
}

function Update-YTDLP {
    if ($AutoUpdate) {
        Write-Section "檢查 yt-dlp 是否為最新版本..."
        try {
            yt-dlp -U | Out-Host
        } catch {
            Write-Host "⚠️ 找不到 yt-dlp，請先安裝。" -ForegroundColor Yellow
            return $false
        }
    }
    return $true
}

function Detect-VideoType {
    if ($VideoURL -match "playlist") { return "playlist" }
    elseif ($VideoURL -match "shorts") { return "shorts" }
    else { return "video" }
}

# ========================
# 🚀 主程式
# ========================
Write-Section "智慧 YouTube 下載器啟動"
if (-not (Update-YTDLP)) { exit }

$type = Detect-VideoType
Write-Host "📺 偵測影片類型：$type" -ForegroundColor Cyan

# -----------------------
# 📡 取得頻道名稱
# -----------------------
Write-Section "取得頻道資訊..."
$channelName = yt-dlp --get-filename -o "%(channel)s" $VideoURL 2>$null
$channelName = ($channelName | Select-Object -First 1).ToString()  # 取第一行並轉字串
if (-not $channelName -or $channelName.Trim() -eq "") { $channelName = "未知頻道" }

# 清理非法字元
$channelName = ($channelName -replace '[\\\/:\*\?"<>\|]', "_").Trim()
$ChannelDir = Join-Path $PSScriptRoot $channelName
if (-not (Test-Path $ChannelDir)) {
    Write-Host "📁 建立資料夾：$ChannelDir"
    New-Item -ItemType Directory -Path $ChannelDir | Out-Null
}

# 頻道專屬下載紀錄
$ArchiveFile = Join-Path $ChannelDir "$channelName.txt"

# -----------------------
# 🧠 自動偵測最佳 client
# -----------------------
Write-Section "測試可用 client..."
$bestClient = ""; $bestRes = 0

foreach ($c in $Clients) {
    Write-Host "`n🧩 測試 client：$c"
    $extraArgs = "youtube:player_client=$c"
    try {
        $formats = yt-dlp -j --extractor-args $extraArgs $VideoURL 2>$null | ConvertFrom-Json
    } catch { continue }

    if ($formats -and $formats.formats) {
        $resList = $formats.formats | Where-Object { $_.height } | ForEach-Object { $_.height }
        if ($resList) {
            $maxRes = ($resList | Sort-Object | Select-Object -Last 1)
            Write-Host "✅ $c 可用最高畫質：${maxRes}p"
            if ($maxRes -gt $bestRes) { $bestRes = $maxRes; $bestClient = $c }
        } else {
            Write-Host "⚠️ $c 無可用格式"
        }
    } else {
        Write-Host "⚠️ $c 無可用格式"
    }
}

if (-not $bestClient) {
    Write-Host "❌ 找不到可下載格式，請稍後再試。" -ForegroundColor Red
    exit
}

Write-Section "選擇最佳 client：$bestClient（${bestRes}p）"

# -----------------------
# 🗂️ 輸出檔案格式
# -----------------------
$OutputPattern = Join-Path $ChannelDir "%(title)s [%(id)s].%(ext)s"

# -----------------------
# 🎬 下載影片
# -----------------------
Write-Section "開始下載（$bestClient，${bestRes}p）" "Green"

$Args = @(
    "-f","bestvideo+bestaudio/best",
    "--merge-output-format",$MergeFormat,
    "--extractor-args","youtube:player_client=$bestClient",
    "--output",$OutputPattern,
    "--download-archive",$ArchiveFile,
    "--write-thumbnail","--embed-thumbnail",
    "--write-subs","--write-auto-subs","--embed-subs",
    "--sub-langs",$SubtitleLangs,
    "--embed-metadata","--no-mtime"
)

if (Test-Path $CookiesFile) { $Args += @("--cookies",$CookiesFile) }
$Args += $VideoURL

yt-dlp @Args

Write-Section "✅ 下載完成！"
Write-Host "📂 儲存位置：" (Resolve-Path $ChannelDir)
