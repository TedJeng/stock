# 美股收盤後自動執行 stock-analyst skill
# 由 Windows 工作排程器每日（週二~週六 Taipei 時間，對應美股週一~週五收盤後）觸發
# 遵循 E:\Stock\CLAUDE.md 的執行慣例：讀最新既有分析為起點、四訊號交叉驗證、
# Artifact HTML+MD 雙輸出、append 歷史推薦紀錄、不可省略免責聲明

$ErrorActionPreference = "Continue"
$logDir = "E:\Stock\scripts\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir ("run-{0}.log" -f (Get-Date -Format "yyyy-MM-dd_HHmmss"))

$prompt = @'
請執行 stock-analyst skill：依照 E:\Stock\CLAUDE.md 的固定流程規則，先讀 E:\Stock\analysis\ 底下日期最新的既有分析報告作為本期起點（例行更新，非從零篩選），更新最新 Finviz 數據與 serenity 卡點參考資料，對現有追蹤名單重新跑四訊號交叉驗證，產出今日美股盤後的 AI/晶片/機器人/記憶體供應鏈分析與投資建議。輸出到 E:\Stock\analysis\{今天對應的收盤日期 yyyy-MM-dd}\，產出 stock-report-{yyyy-MM-dd}.md 與 .html 雙版本並發布 Artifact，append 寫入 recommendations.json 歷史推薦紀錄（只能新增不可覆寫），每份報告務必附免責聲明。
'@

Set-Location "E:\Stock"

& "C:\Users\gn020\.local\bin\claude.exe" -p $prompt --dangerously-skip-permissions *>&1 | Tee-Object -FilePath $logFile
