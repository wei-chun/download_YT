Smart-YTDLP

智慧 YouTube 下載器（PowerShell & macOS Bash 版本）

---

功能特色

- 自動偵測最佳 YouTube client（android_embedded / tv_embedded / android / web_embedded / web）  
- 自動下載影片、字幕、縮圖，並內嵌字幕與縮圖  
- 依 頻道名稱 自動建立資料夾整理影片  
- 自動下載播放清單內所有影片到頻道資料夾  
- 支援 cookies 登入（Premium / 受限影片）  
- 自動維護頻道專屬下載紀錄，避免重複下載  
- 自動更新 yt-dlp（macOS 使用 Homebrew，PowerShell 使用 -U）  
- 相容 PowerShell 5.1 與 macOS Bash  

---

使用說明

1️⃣ 單影片下載

PowerShell：
.\Smart-YTDLP.ps1 "https://www.youtube.com/watch?v=影片ID"

macOS Bash：
./Smart-YTDLP.sh "https://www.youtube.com/watch?v=影片ID"

影片會自動下載至以頻道名稱命名的資料夾中。

---

2️⃣ 播放清單下載

PowerShell：
.\Smart-YTDLP.ps1 "https://www.youtube.com/playlist?list=播放清單ID"

macOS Bash：
./Smart-YTDLP.sh "https://www.youtube.com/playlist?list=播放清單ID"

播放清單內所有影片會自動下載到該頻道資料夾中，並且不會重複下載已完成的影片。

---

3️⃣ 高級設定

- 字幕語言  
  在程式內可修改 $SubtitleLangs（PowerShell）或 SUBTITLE_LANGS（macOS Bash）  
  範例：zh-Hant,zh-Hans,en

- 影片格式與合併  
  預設下載最佳畫質影片與音訊並合併為 mp4，可修改 $MergeFormat 或 MERGE_FORMAT。

- Cookies 登入  
  將 cookies.txt 放在程式同一資料夾，即可下載受限影片或 Premium 影片。

- 下載紀錄  
  每個頻道會在資料夾中建立 頻道名稱.txt，避免重複下載。

---

4️⃣ 注意事項

- PowerShell 版本需相容 PowerShell 5.1  
- macOS 版本需安裝 yt-dlp 與 jq  
  安裝指令：brew install yt-dlp jq  
- 確保程式有執行權限：chmod +x Smart-YTDLP.sh

---

5️⃣ 範例結構

下載完成後，資料夾結構示意：

./頻道名稱/
├─ 影片標題1 [影片ID].mp4
├─ 影片標題1 [影片ID].jpg
├─ 影片標題1 [影片ID].vtt
├─ 影片標題2 [影片ID].mp4
├─ 頻道名稱.txt  # 下載紀錄

---

6️⃣ 更新 yt-dlp

PowerShell：yt-dlp -U

macOS Bash：brew upgrade yt-dlp

---

7️⃣ 常見問題

1. 找不到 yt-dlp  
   → 請先安裝 yt-dlp（PowerShell 建議放在 PATH，macOS 建議使用 Homebrew）。

2. 下載受限影片失敗  
   → 請使用 cookies.txt 登入後再下載。

3. 影片或播放清單下載失敗  
   → 嘗試更新 yt-dlp 或檢查影片 URL 是否正確。
"""

