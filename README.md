# Smart-YTDLP

智慧 YouTube 下載器（PowerShell & macOS Bash 版本）

---

## 功能特色

- 自動偵測最佳 YouTube client（android_embedded / tv_embedded / android / web_embedded / web）  
- 自動下載影片、字幕、縮圖，並內嵌字幕與縮圖  
- 依 **頻道名稱** 自動建立資料夾整理影片  
- 自動下載播放清單內所有影片到頻道資料夾  
- 支援 cookies 登入（Premium / 受限影片）  
- 自動維護頻道專屬下載紀錄，避免重複下載  
- 自動更新 yt-dlp（macOS 使用 Homebrew，PowerShell 使用 -U）  
- 相容 PowerShell 5.1 與 macOS Bash  

---

## 使用說明

### 1️⃣ 單影片下載

#### PowerShell
```
.\Smart-YTDLP.ps1 "https://www.youtube.com/watch?v=影片ID"
```
#### macOS Bash
```
./Smart-YTDLP.sh "https://www.youtube.com/watch?v=影片ID"
```
### 2️⃣ 播放清單下載

#### PowerShell
```
.\Smart-YTDLP.ps1 "https://www.youtube.com/playlist?list=播放清單ID"
```
#### macOS Bash
```
./Smart-YTDLP.sh "https://www.youtube.com/playlist?list=播放清單ID"
```
---

## cookies.txt 使用說明

若要下載受限影片或 Premium 會員影片，需要提供 cookies：

1. 使用 Chrome / Edge 登入 YouTube 帳號  
2. 安裝擴充工具「Get cookies.txt」或其他相容工具  
3. 匯出 cookies 到 Smart-YTDLP 目錄下，檔名為 cookies.txt  
4. 腳本會自動使用 cookies.txt  

> 注意：請不要分享 cookies.txt，裡面包含帳號資訊。

---

##檔案結構示意
```
Smart-YTDLP/
├─ Smart-YTDLP.ps1
├─ Smart-YTDLP.sh
├─ README.md
├─ cookies.txt
├─ [頻道名稱].txt
└─ [頻道名稱]/
    ├─ 影片1.mp4
    ├─ 影片2.mp4
    └─ 影片1.jpg
```
---

## 注意事項

- 確保已安裝 yt-dlp  
  - PowerShell 可直接使用 yt-dlp -U 更新  
  - macOS 建議使用 Homebrew 安裝：rew install yt-dlp  
- Windows PowerShell 需版本 5.1 以上  
- macOS Bash 需 macOS 10.12+ 並允許執行腳本  
- 下載影片將依頻道名稱建立資料夾存放  
- 若 yt-dlp 無法抓到影片資訊，請確認影片是否受限或被移除  

---

## 錯誤排除提示

1. 無法取得頻道名稱
2. 下載失敗或中斷
3. 影片重複下載

---

## 建議操作順序

1. 安裝 yt-dlp  
2. 準備 cookies.txt（如有需要）  
3. 執行腳本下載影片或播放清單  
4. 影片會依頻道建立資料夾，自動整理  
5. 定期更新 yt-dlp 以支援最新 YouTube 變更



