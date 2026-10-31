# E:\Stock — AI/晶片/機器人/記憶體 美股追蹤

本目錄存放 `stock-analyst` skill（`.claude/skills/stock-analyst/`）產出的每期美股分析報告。追蹤宇宙固定為 AI 基礎設施／晶片／機器人／記憶體四大主題，方法論、四訊號交叉驗證規則、卡點層級定義、信心等級規則，全部依 skill 本體定義，此檔只規範**本目錄的執行與存放慣例**。

此目錄同步為 GitHub repo（`https://github.com/TedJeng/stock.git`），`.claude/skills/` 底下附了 `stock-analyst` 與 `serenity-chokepoint-analyst` 兩個 skill 的完整副本（含 references/data），讓本機與雲端排程 routine 都能用同一套規則執行。**路徑一律用 repo 相對路徑**（本機對應 `E:\Stock\...`，雲端對應 repo checkout 根目錄），不要寫死絕對路徑。

## 固定流程規則

**每次在此目錄產生新一期分析前，必須先讀最新一份既有分析**：

1. 找出 `analysis/` 底下日期最新的資料夾（資料夾名為 `yyyy-MM-dd`），讀其中的 `.md` 報告
2. 以該報告的追蹤名單與上期結論作為本期起點——這是「例行更新」（重新過四訊號、更新信心等級），**不是從零開始篩選**
3. 只有在使用者明確要求全新篩選，或某標的四訊號兩個以上反向而需剔除換人時，才重新跑 Finviz screener 找新候選
4. 無既有分析（本目錄尚無任何資料夾）時，才視為首次執行，走完整篩選流程

**輸出位置與命名**：

- 新一期分析輸出到 `analysis/{yyyy-MM-dd}/`，`yyyy-MM-dd` 為**分析對應的收盤日期**（例如週五盤後分析用當週五日期），不是執行當天的日期
- 檔名慣例：`stock-report-{yyyy-MM-dd}.md`（純文字版）+ `stock-report-{yyyy-MM-dd}.html`（本地留底）＋ 透過 Artifact 工具發布網頁版，發布連結附在對話摘要

## 報告內容規則（依 stock-analyst skill 定義）

- 章節結構、卡點層級標籤、四訊號驗證列、信心等級規則（強/中/弱/剔除）、核心卡點加分規則：見 `.claude/skills/stock-analyst/references/report-template.md`
- Finviz 抓取配方：見 `.claude/skills/stock-analyst/references/finviz-recipes.md`
- 卡點框架、覆蓋名單、輪動相位判讀：見 `.claude/skills/serenity-chokepoint-analyst/references/`（methodology.md / tickers.md / theses.md）
- **歷史推薦績效追蹤**：每次執行第一步讀、最後一步寫 `.claude/skills/stock-analyst/data/recommendations.json`——只能 **append**，不可覆寫既有紀錄；本期產出的每檔標的（含 `price_at_rec` 與當日 `spy_at_rec`）都要寫入
- 每份報告（.md 與 .html 皆同）**必附免責聲明**：非投資建議、卡點框架轉述自 Serenity 未經驗證、單一產業無分散效果、Finviz 免費版數據可能延遲

## 雲端排程 routine 的額外規則

當本流程由雲端 cloud routine（`/schedule` 建立）執行時：

1. 執行完整分析流程後，`git add` 新增的 `analysis/{yyyy-MM-dd}/` 報告檔與更新過的 `.claude/skills/stock-analyst/data/recommendations.json`，`git commit` 並 `git push` 回 `https://github.com/TedJeng/stock.git`（repo 已設定好 remote，直接 push 即可，不需詢問）
2. 同時用 Artifact 工具發布一份 HTML 報告，將連結附在 routine 執行結果中，方便使用者直接點開查看，不需要額外 pull repo
3. 雲端環境沒有本機 `C:\Users\gn020\...` 路徑，所有 skill/reference 存取一律走 repo 內的 `.claude/skills/...` 相對路徑

## 資料夾結構範例

```
E:\Stock\
├── CLAUDE.md
├── .claude\skills\
│   ├── stock-analyst\（SKILL.md + references + data/recommendations.json）
│   └── serenity-chokepoint-analyst\（SKILL.md + references）
├── scripts\run-daily-analysis.ps1
└── analysis\
    ├── 2026-08-08\
    │   ├── stock-report-2026-08-08.md
    │   └── stock-report-2026-08-08.html
    └── 2026-10-31\
        ├── stock-report-2026-10-31.md
        └── stock-report-2026-10-31.html
```
