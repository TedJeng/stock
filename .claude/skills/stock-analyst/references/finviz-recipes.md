# Finviz 抓取配方（AI/晶片/機器人/記憶體宇宙）

所有 URL 用 WebFetch 抓，prompt 請它把表格內容（ticker、公司名、產業、關鍵欄位數值）完整列出。Finviz 免費版可直接抓取（2026-07 實測）。免費版**產業濾鏡一次只能選一個**，所以宇宙覆蓋要靠多條 URL 合併去重。

## 宇宙對應的產業濾鏡

| 主題 | Finviz 濾鏡 | 備註 |
|---|---|---|
| 晶片—設計/製造 | `ind_semiconductors` | 必跑 |
| 晶片—設備/材料 | `ind_semiconductorequipmentmaterials` | 必跑；隱蔽卡點常在這 |
| AI 基建—光通訊 | `ind_communicationequipment` | 光模組/光學股（AAOI、COHR 類）多在此 |
| AI 基建—零組件 | `ind_electroniccomponents` | 連接器、被動元件 |
| AI 基建—硬體 | `ind_computerhardware` | 伺服器/儲存（含部分記憶體儲存股） |
| 機器人/自動化 | `ind_specialtyindustrialmachinery` | 工業自動化居多，機器人純度靠逐檔判斷 |

執行策略：`ind_semiconductors` 與 `ind_semiconductorequipmentmaterials` 每次必跑；其餘 2–4 條視當期主題與時間預算加跑。**serenity 名單標的直接走 quote 頁，不必經過 screener**（它們常因市值太小或產業歸類不同而漏網）。

## Screener URL 配方

基底：`https://finviz.com/screener.ashx`

### 1. 高風險高報酬（每條產業濾鏡換 `ind_` 代碼重複使用）

```
https://finviz.com/screener.ashx?v=111&f=ind_semiconductors,cap_midunder,fa_salesqoq_o20,ta_beta_o1&ft=4&o=-perf13w
https://finviz.com/screener.ashx?v=111&f=ind_semiconductorequipmentmaterials,cap_midunder,fa_salesqoq_o20,ta_beta_o1&ft=4&o=-perf13w
```

| 參數 | 意義 |
|---|---|
| `cap_midunder` | 市值 < $10B（含微型股，抓回後剔除 < $300M） |
| `fa_salesqoq_o20` | 營收 QoQ 成長 > 20% |
| `ta_beta_o1` | Beta > 1（產業限定後放寬，>1.5 會漏掉太多卡點股） |
| `o=-perf13w` | 依近一季表現排序 |

產業限定後結果變少是正常的；若某條 URL 結果 < 5 檔，可拿掉 `fa_salesqoq_o20` 再跑一次。合併各條結果後**去重**，加上 serenity 名單標的形成候選池。

### 2. 穩定投資（產業龍頭型）

```
https://finviz.com/screener.ashx?v=111&f=ind_semiconductors,cap_largeover,fa_netmargin_pos&ft=4&o=-marketcap
https://finviz.com/screener.ashx?v=111&f=ind_semiconductorequipmentmaterials,cap_largeover,fa_netmargin_pos&ft=4&o=-marketcap
```

| 參數 | 意義 |
|---|---|
| `cap_largeover` | 市值 > $10B（抓回後手動保留 ≥ $50B） |
| `fa_netmargin_pos` | 淨利率為正 |
| `o=-marketcap` | 依市值排序，龍頭排前面 |

龍頭名單相對穩定（TSM、AVGO、ASML、AMAT、TXN、QCOM、MU、LRCX、KLAC 這一輪），screener 主要用來確認沒漏新面孔與抓當前市值排序。

### 3. ETF（產業主題型）

主題 ETF 名單固定，直接逐檔抓 quote 頁確認價格與近期表現即可：

| 層 | Ticker | 說明 |
|---|---|---|
| 核心 | SMH、SOXX | 半導體大盤型 |
| 衛星—機器人 | BOTZ、ROBO、ARKQ | 機器人/自動化/AI |
| 衛星—記憶體代理 | EWY | 南韓 ETF（Samsung/SK Hynix 代理，serenity 慣例） |
| 避險 | SGOV | 0–3 月國庫券現金層 |

需要比較同類表現時可用：`https://finviz.com/screener.ashx?v=141&f=ind_exchangetradedfund&ft=4&o=-averagevolume`（Performance 檢視）。

## 常用濾鏡代碼速查

| 類別 | 代碼 | 意義 |
|---|---|---|
| 市值 | `cap_mega` / `cap_large` / `cap_mid` / `cap_small` / `cap_micro` | >200B / 10–200B / 2–10B / 300M–2B / 50–300M |
| 市值（累計） | `cap_largeover` / `cap_smallover` / `cap_midunder` | >10B / >300M / <10B |
| 營收成長 | `fa_salesqoq_o20` / `fa_sales5years_o10` | QoQ >20% / 5 年年化 >10% |
| EPS 成長 | `fa_epsyoy_o20` / `fa_epsqoq_o20` | 本年 YoY >20% / QoQ >20% |
| 獲利 | `fa_netmargin_pos` / `fa_pe_profitable` | 淨利率正 / 有獲利 |
| Beta | `ta_beta_o1` / `ta_beta_o1.5` / `ta_beta_u1` | >1 / >1.5 / <1 |
| 表現 | `ta_perf_13wup` / `ta_perf_4wup` | 季為正 / 月為正 |
| 股息 | `fa_div_o2` | 股息率 >2%（龍頭組加分項用） |

排序（`o=` 前綴 `-` 為降冪）：`-perf13w`、`-marketcap`、`-dividendyield`、`-averagevolume`、`-change`。
檢視：`v=111` Overview、`v=141` Performance、`v=161` Financial。翻頁：`&r=21`。

## Quote 頁（個股快照）

```
https://finviz.com/quote.ashx?t=<TICKER>
```

WebFetch prompt 請它列出以下重點欄位：

| 欄位 | 解讀 |
|---|---|
| Price / Target Price | 目標價空間 > 20% 且評級 Buy 是正向訊號；**卡點股常見目標價落後，配合卡點加分規則判讀** |
| Analyst Recom | 1.0–5.0 越低越看多；≤ 2.0 視為看多。小型卡點股可能無覆蓋（顯示 —），此時分析師訊號記「中性」而非反向 |
| Beta | 波動性驗證 |
| SMA20 / SMA50 / SMA200 | 三條皆正 = 多頭排列；跌破 SMA200 是趨勢警訊 |
| Insider Trans | 大額賣出要在風險欄註明 |
| Sales Q/Q、EPS Q/Q | 成長是否仍在加速 |
| Short Float | > 15% 空頭擁擠，雙向波動放大 |
| Shs Outstand / Float | 對照 serenity 的股本結構檢查：注意 ATM 增資、SBC 稀釋跡象（theses.md $IREN 案例） |
| News 區塊 | 新聞情緒訊號的第一手來源 |

SPY 基準價：`quote.ashx?t=SPY`。

**美股抓不到的名單標的**（SIVE 斯德哥爾摩、IQE 倫敦、台鏈如穩懋/波若威）：不進 Top 5，列入報告的「延伸觀察」段落即可，不需強行找報價。

## Fallback（抓取失敗時）

1. 同 URL 等 1–2 分鐘重試一次（偶發限流）
2. 個股改抓 Yahoo Finance：`https://finance.yahoo.com/quote/<TICKER>`
3. Screener 抓不到時改用 WebSearch 取得候選名單，再逐檔走 quote 頁
4. 報告中註明數據來源已切換，維持透明
