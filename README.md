Smart-YTDLP

智慧 YouTube 下載器（PowerShell & macOS Bash 版本）

---

功能特色

- 自動偵測最佳 YouTube client（android_embedded / tv_embedded / android / web_embedded / web）
- 自動下載影片、字幕、縮圖，並內嵌字幕與縮圖
- 依頻道名稱自動建立資料夾整理影片
- 自動下載播放清單內所有影片到頻道資料夾
- 支援 cookies 登入（Premium / 受限影片）
- 自動維護頻道專屬下載紀錄，避免重複下載
- 自動更新 yt-dlp（macOS 使用 Homebrew，PowerShell 使用 -U）
- 相容 PowerShell 5.1 與 macOS Bash

---

使用說明

1️⃣ 單影片下載

PowerShell:
.\Smart-YTDLP.ps1 "https://www.youtube.com/watch?v=影片ID"

macOS Bash:
./Smart-YTDLP.sh "https://www.youtube.com/watch?v=影片ID"

---

2️⃣ 播放清單下載

PowerShell:
.\Smart-YTDLP.ps1 "https://www.youtube.com/playlist?list=播放清單ID"

macOS Bash:
./Smart-YTDLP.sh "https://www.youtube.com/playlist?list=播放清單ID"

> 下載後影片會依頻道名稱分類資料夾，並自動更新頻道專屬下載紀錄，避免重複下載。

---

進階功能

- Cookies 登入
  若影片為受限影片或 Premium 內容，可透過 cookies.txt 登入：
  - 將 YouTube cookies 另存為 cookies.txt，與腳本放在同一資料夾
  - 腳本會自動偵測並使用 cookies

- 字幕與縮圖
  - 自動下載影片字幕（繁體、簡體、英文）並內嵌
  - 自動下載影片縮圖並內嵌

- 影片合併與格式
  - 影片與音訊分軌下載後自動合併為 MP4（可修改 MergeFormat 參數）

- 更新 yt-dlp
  - PowerShell 版本：使用 yt-dlp -U
  - macOS 版本：使用 Homebrew brew upgrade yt-dlp

---

注意事項

- PowerShell 版本請使用 PowerShell 5.1
- macOS 版本請確保已安裝 Homebrew 與 yt-dlp
- 頻道名稱資料夾會自動清理非法檔名字元（如 / \ : * ? " < > |）
- 建議放置腳本與 cookies.txt 在同一資料夾

---
