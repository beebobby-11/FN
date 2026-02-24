# 🧠 Neural Network Analysis: Complete Settings & Workflow
# Strategy: ableSignals & Overlays Private™ 7.9-X

---

## 📸 SETTINGS INTERFACE (TradingView)

### ตามรูปที่แนบมา มี Settings Groups ดังนี้:

```
┌─────────────────────────────────────────────────────────────┐
│  📋 INPUTS PANEL                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🎯 MAIN SETTINGS                                          │
│  ├─ What TPS should be taken:           [Trailing ▼]      │
│  ├─ What Trading Setup should be taken: [Open/Close ▼]    │
│  ├─ Show coloured Bars:                 [✓]               │
│  └─ Enable Ribbon:                      [✓]               │
│                                                             │
│  ⚙️  STRATEGY OPTIONS                                      │
│  └─ Sideways Filtering Input:           [No Filtering ▼]  │
│                                                             │
│  📊 RSI FILTERING                                          │
│  ├─ RSI Length:                         [7]               │
│  ├─ TOP Limit:                          [45]              │
│  └─ BOT Limit:                          [10]              │
│                                                             │
│  📐 RENKO SETTINGS                                         │
│  ├─ EMA1_length:                        [2]               │
│  └─ EMA2_length:                        [10]              │
│                                                             │
│  💰 RISK MANAGEMENT                                        │
│  ├─ Qty TP1:                            [50%]             │
│  ├─ Qty TP2:                            [30%]             │
│  └─ Qty TP3:                            [20%]             │
│                                                             │
│  📈 DASHBOARDS                                             │
│  ├─ Strategy Performance:               [  ]              │
│  ├─ Weekly Performance:                 [  ]              │
│  └─ Monthly Performance:                [  ]              │
│                                                             │
│  📉 EMA & ATR                                              │
│  ├─ Plot EMA?:                          [  ]              │
│  ├─ Use Higher Time Frame?:             [✓]               │
│  └─ Plot Dema?:                         [  ]              │
│                                                             │
│  🔷 ZIGZAG CONFIG                                          │
│  ├─ Depth:                              [12]              │
│  ├─ Deviation:                          [5]               │
│  └─ Backstep:                           [2]               │
│                                                             │
│  🎨 LINES                                                  │
│  └─ Line Thickness:                     [2]               │
│                                                             │
│  🏷️  LABELS                                                │
│  └─ Label Size:                         [3]               │
│                                                             │
│  📍 MARKET STRUCTURE (MS)                                  │
│  ├─ Window:                             [✓] [5000]        │
│  ├─ Swing:                              [✓] [100]         │
│  ├─ Mapping Structure:                  [  ]              │
│  ├─ Color Candles:                      [  ]              │
│  ├─ Algorithmic Logic:                  [Adjusted Points]│
│  ├─ Node Length:                        [5]               │
│  ├─ Build Sweep (x):                    [✓]               │
│  └─ Bubbles:                            [✓]               │
│                                                             │
│  📦 ORDER BLOCKS & VOLUME                                  │
│  ├─ Show Last:                          [✓] [5]           │
│  ├─ Show Buy/Sell Activity:             [✓]               │
│  ├─ Show Breakers:                      [  ]              │
│  ├─ Construction:                       [Length] [5]      │
│  ├─ Mitigation Method:                  [Close]           │
│  ├─ Metric Size:                        [Normal]          │
│  ├─ Show Metrics:                       [✓]               │
│  ├─ Show Mid-Line:                      [✓]               │
│  └─ Hide Overlap:                       [✓] [Recent]      │
│                                                             │
│  🎯 FAIR VALUE GAP (FVG)                                   │
│  ├─ Enable FVG:                         [  ] [FVG]        │
│  ├─ Show Last:                          [5]               │
│  ├─ Mitigation:                         [Close]           │
│  ├─ Threshold:                          [0]               │
│  ├─ Hide Overlap:                       [✓]               │
│  ├─ Show Mid-Line:                      [✓]               │
│  ├─ Extend FVG:                         [  ]              │
│  └─ Display Raids:                      [  ]              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧠 NEURAL NETWORK ARCHITECTURE

### **ภาพรวมของระบบ:**
```
┌────────────────────────────────────────────────────────────────┐
│                    INPUT LAYER                                 │
│  (Data Collection & Preprocessing)                             │
├────────────────────────────────────────────────────────────────┤
│  📊 Price Data  │  📈 Indicators  │  ⚙️  Settings  │  📅 Time  │
│  - OHLC         │  - Heikin Ashi  │  - TPS Type    │  - HTF    │
│  - Volume       │  - RSI          │  - Setup Type  │  - Date   │
│  - Spread       │  - ATR          │  - Filters     │  - Bar    │
│                 │  - EMA          │                │           │
└────────┬───────────────┬───────────────┬──────────────┬────────┘
         │               │               │              │
         ▼               ▼               ▼              ▼
┌────────────────────────────────────────────────────────────────┐
│                   HIDDEN LAYER 1                               │
│         (Feature Extraction & Signal Generation)               │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🔷 HEIKIN ASHI PROCESSOR                                      │
│  ├─ HTF Calculation (Current TF × 18)                         │
│  ├─ HA Open/Close Calculation                                 │
│  └─ Crossover Detection                                        │
│                                                                │
│  🔶 RENKO PROCESSOR                                            │
│  ├─ Renko Bar Construction (ATR-based)                        │
│  ├─ EMA1(2) & EMA2(10) Calculation                            │
│  └─ EMA Crossover Detection                                    │
│                                                                │
│  🔹 RSI PROCESSOR                                              │
│  ├─ RSI(7) Calculation                                         │
│  ├─ Overbought/Oversold Detection                             │
│  └─ Sideways Market Detection                                 │
│                                                                │
│  🔸 ATR PROCESSOR                                              │
│  ├─ ATR(20) for TP/SL                                         │
│  ├─ ATR(5) for Filter                                         │
│  ├─ ATR MA(5) Calculation                                     │
│  └─ Volatility Assessment                                     │
│                                                                │
└────────┬───────────────┬───────────────┬──────────────────────┘
         │               │               │
         ▼               ▼               ▼
┌────────────────────────────────────────────────────────────────┐
│                   HIDDEN LAYER 2                               │
│            (Filter Application & Logic Gates)                  │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🚦 FILTER GATE                                                │
│  ├─ No Filtering       → Always TRUE                          │
│  ├─ Filter with ATR    → ATR >= ATR_MA                        │
│  ├─ Filter with RSI    → RSI > 45 OR RSI < 10                │
│  ├─ ATR or RSI         → ATR_Filter OR RSI_Filter             │
│  ├─ ATR and RSI        → ATR_Filter AND RSI_Filter            │
│  ├─ Sideways (OR)      → Sideways_ATR OR Sideways_RSI         │
│  └─ Sideways (AND)     → Sideways_ATR AND Sideways_RSI        │
│                                                                │
│  🎯 SETUP SELECTOR                                             │
│  ├─ Open/Close Setup   → HA Crossover Signals                 │
│  └─ Renko Setup        → EMA Crossover Signals                │
│                                                                │
│  📅 DATE FILTER                                                │
│  └─ Check: fromDate <= now <= toDate                          │
│                                                                │
│  🔀 SIGNAL COMBINER (AND Logic)                               │
│  ├─ leTrigger = Setup_Buy AND Filter AND DateAllowed          │
│  └─ seTrigger = Setup_Sell AND Filter AND DateAllowed         │
│                                                                │
└────────┬───────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│                   HIDDEN LAYER 3                               │
│              (State Machine & Risk Calculator)                 │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🔄 STATE MACHINE                                              │
│  ├─ condition = 0.0    → No Position                          │
│  ├─ condition = ±1.0   → Entry State (TP1 pending)            │
│  ├─ condition = ±1.1   → TP1 Hit (TP2 pending)                │
│  ├─ condition = ±1.2   → TP2 Hit (TP3 pending)                │
│  └─ condition = ±1.3   → TP3 Hit (Complete)                   │
│                                                                │
│  💹 TP/SL CALCULATOR (ATR Mode)                                │
│  ├─ Entry Price        = close                                 │
│  ├─ ATR Value          = ta.atr(20)                           │
│  ├─ TP1 Distance       = 1 × 2.5 × ATR                        │
│  ├─ TP2 Distance       = 2 × 2.5 × ATR                        │
│  ├─ TP3 Distance       = 3 × 2.5 × ATR                        │
│  └─ SL Distance        = 1 × 2.5 × ATR                        │
│                                                                │
│  📊 POSITION SIZE CALCULATOR                                   │
│  ├─ Initial Volume     = Account × 50% (default_qty_value)    │
│  ├─ TP1 Volume         = Initial × 50%                        │
│  ├─ TP2 Volume         = Initial × 30%                        │
│  └─ TP3 Volume         = Initial × 20%                        │
│                                                                │
│  🎯 CROSSOVER DETECTOR                                         │
│  ├─ TP1 Cross          = high > tp1Line (Long)                │
│  ├─ TP2 Cross          = high > tp2Line (Long)                │
│  ├─ TP3 Cross          = high > tp3Line (Long)                │
│  └─ SL Cross           = low < slLine (Long)                  │
│                                                                │
└────────┬───────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│                   OUTPUT LAYER                                 │
│              (Order Execution & Visualization)                 │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  📤 ORDER EXECUTION                                            │
│  ├─ TPS_ATR Mode:                                              │
│  │  ├─ strategy.entry() → Open position                       │
│  │  ├─ strategy.exit(TP1) → 50% at limit=tp1Line             │
│  │  ├─ strategy.exit(TP2) → 30% at limit=tp2Line             │
│  │  ├─ strategy.exit(TP3) → 20% at limit=tp3Line             │
│  │  └─ All exits → stop=slLine                                │
│  │                                                             │
│  ├─ TPS_Trailing Mode:                                         │
│  │  ├─ strategy.close(opposite)                               │
│  │  └─ strategy.entry(current) → No SL/TP                     │
│  │                                                             │
│  └─ TPS_Options Mode:                                          │
│     ├─ strategy.entry(Long only)                              │
│     └─ strategy.close(Long) on sell signal                    │
│                                                                │
│  🎨 VISUALIZATION                                              │
│  ├─ Bar Colors → Green/Red based on trend                     │
│  ├─ TP/SL Lines → Blue/Green/Red lines on chart               │
│  ├─ Entry Line → Blue line at entry price                     │
│  ├─ Alert Shapes → Yellow markers for signals                 │
│  ├─ Order Blocks → Volume-based support/resistance            │
│  ├─ Fair Value Gaps → Price imbalance zones                   │
│  ├─ Market Structure → High/Low pivots                        │
│  ├─ ZigZag → Trend visualization                              │
│  └─ Performance Tables → Weekly/Monthly stats                 │
│                                                                │
│  📊 DASHBOARDS                                                 │
│  ├─ Strategy Performance → Win rate, PnL, trades              │
│  ├─ Weekly Performance → Performance by weekday               │
│  └─ Monthly Performance → Performance by month                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 🔗 DETAILED WORKFLOW WITH NEURAL NETWORK ANALOGY

### **1️⃣ INPUT LAYER → Data Collection (Neurons: ~20)**

#### **Neuron Group 1: Price Data (4 neurons)**
```python
INPUT_PRICE = {
    'open':   market_data.open,
    'high':   market_data.high,
    'low':    market_data.low,
    'close':  market_data.close,
    'weight': 1.0  # Base weight
}
```

#### **Neuron Group 2: Time Settings (3 neurons)**
```python
INPUT_TIME = {
    'current_tf':     timeframe.period,        # เช่น "5" (M5)
    'multiplier':     18,                      # HTF multiplier
    'higher_tf':      current_tf × 18,         # เช่น M5 × 18 = M90
    'weight':         1.0
}
```

#### **Neuron Group 3: User Settings (13 neurons)**
```python
INPUT_SETTINGS = {
    'TPS_Type':       'Trailing',              # [ATR, Trailing, Options]
    'Setup_Type':     'Open/Close',            # [Open/Close, Renko]
    'Filter_Type':    'No Filtering',          # 7 options
    'Show_Bars':      true,
    'Enable_Ribbon':  false,
    'RSI_Length':     7,
    'RSI_Top':        45,
    'RSI_Bot':        10,
    'EMA1_Length':    2,
    'EMA2_Length':    10,
    'TP1_Qty':        50,
    'TP2_Qty':        30,
    'TP3_Qty':        20,
    'weight':         1.0
}
```

**Activation Function:** `f(x) = x` (Linear, pass-through)

---

### **2️⃣ HIDDEN LAYER 1 → Feature Extraction (Neurons: ~30)**

#### **Processor 1: Heikin Ashi Calculator (6 neurons)**

```python
# Neuron HA_1: Calculate HA Close
def calculate_ha_close(open, high, low, close):
    """
    Weight Matrix: [0.25, 0.25, 0.25, 0.25]
    Activation: Linear sum
    """
    ha_close = (open + high + low + close) / 4
    return ha_close

# Neuron HA_2: Calculate HA Open
def calculate_ha_open(prev_ha_open, prev_ha_close):
    """
    Weight Matrix: [0.5, 0.5]
    Activation: Linear sum
    """
    ha_open = (prev_ha_open + prev_ha_close) / 2
    return ha_open

# Neuron HA_3: Calculate HA High
def calculate_ha_high(high, ha_open, ha_close):
    """
    Weight Matrix: max(inputs)
    Activation: Max pooling
    """
    ha_high = max(high, ha_open, ha_close)
    return ha_high

# Neuron HA_4: Calculate HA Low
def calculate_ha_low(low, ha_open, ha_close):
    """
    Weight Matrix: min(inputs)
    Activation: Min pooling
    """
    ha_low = min(low, ha_open, ha_close)
    return ha_low

# Neuron HA_5: HTF Transformation
def get_htf_ha_values():
    """
    Request higher timeframe data
    Uses lookahead=barmerge.lookahead_on (บาร์ที่ปิดแล้วเท่านั้น)
    """
    ticker = ticker.heikinashi(syminfo.tickerid)
    ha_open_htf = request.security(ticker, my_time, open, lookahead=on)
    ha_close_htf = request.security(ticker, my_time, close, lookahead=on)
    return ha_open_htf, ha_close_htf

# Neuron HA_6: Crossover Detection
def detect_ha_crossover(ha_close_curr, ha_open_curr, ha_close_prev, ha_open_prev):
    """
    Weight Matrix: Boolean logic
    Activation: Step function (0 or 1)
    """
    buy_signal = (ha_close_prev <= ha_open_prev) and (ha_close_curr > ha_open_curr)
    sell_signal = (ha_close_prev >= ha_open_prev) and (ha_close_curr < ha_open_curr)
    return buy_signal, sell_signal

# ตัวอย่างการคำนวณ:
# Bar[2]: HA_close = 1.0840, HA_open = 1.0850 → bearish
# Bar[1]: HA_close = 1.0860, HA_open = 1.0850 → crossover! 
#         → buy_signal = TRUE
```

---

#### **Processor 2: Renko Calculator (5 neurons)**

```python
# Neuron RENKO_1: Renko Bar Construction
def create_renko_bars(use_atr, atr_length, traditional_length):
    """
    Create Renko bars based on ATR or traditional method
    """
    if use_atr:
        param = ticker.renko(syminfo.tickerid, "ATR", atr_length=3)
    else:
        param = ticker.renko(syminfo.tickerid, "Traditional", traditional_length=1000)
    
    renko_close = request.security(param, my_time, close, lookahead=on)
    renko_open = request.security(param, my_time, open, lookahead=on)
    return renko_close, renko_open

# Neuron RENKO_2: EMA1 Calculation
def calculate_ema1(renko_close, period=2):
    """
    Weight: Exponential decay
    α = 2 / (period + 1) = 2 / 3 = 0.667
    EMA[t] = α × Close[t] + (1-α) × EMA[t-1]
    """
    ema1 = ta.ema(renko_close, period)
    return ema1

# Neuron RENKO_3: EMA2 Calculation
def calculate_ema2(renko_close, period=10):
    """
    α = 2 / 11 = 0.182
    """
    ema2 = ta.ema(renko_close, period)
    return ema2

# Neuron RENKO_4: EMA Crossover Detection
def detect_ema_crossover(ema1_curr, ema2_curr, ema1_prev, ema2_prev):
    """
    Activation: Boolean step function
    """
    buy_signal = (ema1_prev <= ema2_prev) and (ema1_curr > ema2_curr)
    sell_signal = (ema1_prev >= ema2_prev) and (ema1_curr < ema2_curr)
    return buy_signal, sell_signal

# Neuron RENKO_5: Color Determination
def get_renko_color(renko_close, renko_open):
    """
    Activation: Comparison function
    """
    bullish = renko_close > renko_open
    return 'green' if bullish else 'red'
```

---

#### **Processor 3: RSI Calculator (4 neurons)**

```python
# Neuron RSI_1: Price Changes
def calculate_price_changes(close, period=7):
    """
    Calculate up/down price movements
    """
    change = close - close[1]
    gain = change > 0 ? change : 0
    loss = change < 0 ? -change : 0
    return gain, loss

# Neuron RSI_2: Average Gain/Loss
def calculate_averages(gain, loss, period=7):
    """
    Weight: RMA (Wilder's smoothing)
    α = 1 / period = 1/7 = 0.143
    """
    avg_gain = ta.rma(gain, period)
    avg_loss = ta.rma(loss, period)
    return avg_gain, avg_loss

# Neuron RSI_3: RSI Calculation
def calculate_rsi(avg_gain, avg_loss):
    """
    RSI = 100 - (100 / (1 + RS))
    RS = avg_gain / avg_loss
    """
    rs = avg_gain / avg_loss
    rsi = 100 - (100 / (1 + rs))
    return rsi

# Neuron RSI_4: Level Detection
def detect_rsi_levels(rsi, top_limit=45, bot_limit=10):
    """
    Activation: Boolean comparison
    """
    is_overbought = rsi > top_limit
    is_oversold = rsi < bot_limit
    is_sideways = (rsi <= top_limit) and (rsi >= bot_limit)
    return is_overbought, is_oversold, is_sideways

# ตัวอย่าง:
# RSI = 52 → is_overbought = TRUE → Allow entry
# RSI = 30 → is_sideways = TRUE → Block entry (if using sideways filter)
```

---

#### **Processor 4: ATR Calculator (5 neurons)**

```python
# Neuron ATR_1: True Range
def calculate_true_range(high, low, close_prev):
    """
    TR = max(high-low, |high-close[1]|, |low-close[1]|)
    Weight: Max pooling
    """
    tr1 = high - low
    tr2 = abs(high - close_prev)
    tr3 = abs(low - close_prev)
    true_range = max(tr1, tr2, tr3)
    return true_range

# Neuron ATR_2: ATR(20) for TP/SL
def calculate_atr_tpsl(true_range, period=20):
    """
    ATR = RMA(TR, period)
    Weight: α = 1/20 = 0.05
    """
    atr = ta.atr(period)
    return atr

# Neuron ATR_3: ATR(5) for Filter
def calculate_atr_filter(true_range, period=5):
    """
    ATR = RMA(TR, period)
    Weight: α = 1/5 = 0.2
    """
    atr_filter = ta.atr(period)
    return atr_filter

# Neuron ATR_4: ATR Moving Average
def calculate_atr_ma(atr_filter, period=5, ma_type='EMA'):
    """
    Smooth ATR for filter comparison
    """
    if ma_type == 'EMA':
        atr_ma = ta.ema(atr_filter, period)
    else:
        atr_ma = ta.sma(atr_filter, period)
    return atr_ma

# Neuron ATR_5: Volatility Assessment
def assess_volatility(atr_filter, atr_ma):
    """
    Activation: Boolean comparison
    """
    is_volatile = atr_filter >= atr_ma      # มี movement
    is_sideways = atr_filter < atr_ma       # ไม่มี movement
    return is_volatile, is_sideways

# ตัวอย่าง:
# ATR(5) = 0.0012, ATR_MA(5) = 0.0010
# is_volatile = TRUE → Allow entry (market มี movement)
```

---

### **3️⃣ HIDDEN LAYER 2 → Logic Gates & Filters (Neurons: ~15)**

#### **Gate 1: Setup Selector (2 neurons)**

```python
# Neuron SETUP_1: Open/Close Branch
def process_openclose_setup(ha_buy, ha_sell, setup_type, filter_pass):
    """
    Weight Matrix: AND logic
    Activation: Boolean AND gate
    """
    if setup_type == "Open/Close":
        buy_signal = ha_buy and filter_pass
        sell_signal = ha_sell and filter_pass
        return buy_signal, sell_signal
    else:
        return False, False

# Neuron SETUP_2: Renko Branch
def process_renko_setup(ema_buy, ema_sell, setup_type, filter_pass):
    """
    Weight Matrix: AND logic
    Activation: Boolean AND gate
    """
    if setup_type == "Renko":
        buy_signal = ema_buy and filter_pass
        sell_signal = ema_sell and filter_pass
        return buy_signal, sell_signal
    else:
        return False, False

# Final Setup Output (OR gate)
def final_setup_signal(oc_buy, oc_sell, renko_buy, renko_sell):
    """
    Only one setup is active at a time
    """
    buy = oc_buy or renko_buy      # One will always be FALSE
    sell = oc_sell or renko_sell
    return buy, sell
```

---

#### **Gate 2: Filter Processor (7 neurons)**

```python
# Neuron FILTER_1: No Filtering
def filter_none():
    """Always pass"""
    return True

# Neuron FILTER_2: ATR Filter
def filter_atr(atr_volatile):
    """
    Pass if market is volatile
    """
    return atr_volatile

# Neuron FILTER_3: RSI Filter
def filter_rsi(rsi_overbought, rsi_oversold):
    """
    Pass if RSI shows extreme
    """
    return rsi_overbought or rsi_oversold

# Neuron FILTER_4: ATR or RSI
def filter_or(atr_pass, rsi_pass):
    """
    Weight: OR gate
    """
    return atr_pass or rsi_pass

# Neuron FILTER_5: ATR and RSI
def filter_and(atr_pass, rsi_pass):
    """
    Weight: AND gate
    """
    return atr_pass and rsi_pass

# Neuron FILTER_6: Sideways OR
def filter_sideways_or(atr_sideways, rsi_sideways):
    """
    Pass if market is sideways (inverse logic)
    """
    return atr_sideways or rsi_sideways

# Neuron FILTER_7: Sideways AND
def filter_sideways_and(atr_sideways, rsi_sideways):
    """
    Pass if market is sideways (both conditions)
    """
    return atr_sideways and rsi_sideways

# Filter Selector (MUX - Multiplexer)
def select_filter(filter_type, atr_data, rsi_data):
    """
    8-to-1 Multiplexer
    Input: filter_type (selector), atr_data, rsi_data
    Output: Boolean (pass/fail)
    """
    filters = {
        'No Filtering': filter_none(),
        'Filter with ATR': filter_atr(atr_data.is_volatile),
        'Filter with RSI': filter_rsi(rsi_data.is_overbought, rsi_data.is_oversold),
        'ATR or RSI': filter_or(filter_atr(...), filter_rsi(...)),
        'ATR and RSI': filter_and(filter_atr(...), filter_rsi(...)),
        'Sideways OR': filter_sideways_or(atr_data.is_sideways, rsi_data.is_sideways),
        'Sideways AND': filter_sideways_and(atr_data.is_sideways, rsi_data.is_sideways)
    }
    return filters[filter_type]
```

**ตัวอย่าง Truth Table:**
```
Filter Type         │ ATR≥MA │ RSI>45 │ Result │
────────────────────┼────────┼────────┼────────┤
No Filtering        │   X    │   X    │  TRUE  │
Filter with ATR     │  TRUE  │ FALSE  │  TRUE  │
Filter with ATR     │ FALSE  │   X    │ FALSE  │
Filter with RSI     │   X    │  TRUE  │  TRUE  │
ATR or RSI          │  TRUE  │ FALSE  │  TRUE  │
ATR or RSI          │ FALSE  │ FALSE  │ FALSE  │
ATR and RSI         │  TRUE  │  TRUE  │  TRUE  │
ATR and RSI         │  TRUE  │ FALSE  │ FALSE  │
Sideways OR         │ FALSE  │ FALSE  │  TRUE  │ (inverse)
Sideways AND        │ FALSE  │ FALSE  │  TRUE  │ (both sideways)
```

---

#### **Gate 3: Date Filter (2 neurons)**

```python
# Neuron DATE_1: Date Range Check
def check_date_range(current_time, from_date, to_date, enable_filter):
    """
    Weight: Comparison operators
    Activation: Boolean AND
    """
    if not enable_filter:
        return True
    
    in_range = (current_time >= from_date) and (current_time <= to_date)
    return in_range

# Neuron DATE_2: Trade Allowed Flag
def get_trade_allowed(date_check):
    """
    Pass-through neuron
    """
    return date_check

# ตัวอย่าง:
# fromDate = 2023-01-01
# toDate = 2099-12-31
# current = 2026-02-22
# → tradeDateIsAllowed = TRUE
```

---

#### **Gate 4: Final Signal Combiner (2 neurons)**

```python
# Neuron COMBINE_1: Long Entry Trigger
def get_long_trigger(setup_buy, filter_pass, date_allowed):
    """
    Weight Matrix: [1, 1, 1] (all must be TRUE)
    Activation: 3-input AND gate
    
    leTrigger = setup_buy AND filter_pass AND date_allowed
    """
    return setup_buy and filter_pass and date_allowed

# Neuron COMBINE_2: Short Entry Trigger
def get_short_trigger(setup_sell, filter_pass, date_allowed):
    """
    Weight Matrix: [1, 1, 1]
    Activation: 3-input AND gate
    
    seTrigger = setup_sell AND filter_pass AND date_allowed
    """
    return setup_sell and filter_pass and date_allowed

# ตัวอย่างการทำงาน:
#
# Scenario 1: Valid Long Signal
# ├─ HA crossover:      TRUE  (HA_close > HA_open)
# ├─ Filter (No Filter): TRUE
# └─ Date allowed:      TRUE
#     → leTrigger = TRUE  ✅ เปิด Long position
#
# Scenario 2: Invalid Long Signal (Filter block)
# ├─ HA crossover:      TRUE
# ├─ Filter (ATR):      FALSE (ATR < ATR_MA, no volatility)
# └─ Date allowed:      TRUE
#     → leTrigger = FALSE ❌ ไม่เปิด position
```

---

### **4️⃣ HIDDEN LAYER 3 → State Machine & Risk Management (Neurons: ~25)**

#### **State Machine Controller (12 neurons - 1 per state transition)**

```python
# State Variable (Global Memory)
var float condition = 0.0

# Neuron STATE_1: Entry Detection (Long)
def detect_long_entry(leTrigger, prev_condition):
    """
    Transition: condition[1] <= 0.0  AND  leTrigger = TRUE
    → New State: condition = 1.0
    
    Weight: IF-THEN logic
    Activation: State assignment
    """
    if leTrigger and prev_condition <= 0.0:
        return 1.0  # Long entry state
    else:
        return prev_condition  # Keep current state

# Neuron STATE_2: Entry Detection (Short)
def detect_short_entry(seTrigger, prev_condition):
    """
    Transition: condition[1] >= 0.0  AND  seTrigger = TRUE
    → New State: condition = -1.0
    """
    if seTrigger and prev_condition >= 0.0:
        return -1.0  # Short entry state
    else:
        return prev_condition

# Neuron STATE_3: TP1 Hit (Long)
def detect_tp1_long(tp1_cross, prev_condition):
    """
    Transition: condition[1] == 1.0  AND  high > tp1Line
    → New State: condition = 1.1
    """
    if tp1_cross and prev_condition == 1.0:
        return 1.1
    else:
        return prev_condition

# Neuron STATE_4: TP1 Hit (Short)
def detect_tp1_short(tp1_cross, prev_condition):
    """
    Transition: condition[1] == -1.0  AND  low < tp1Line
    → New State: condition = -1.1
    """
    if tp1_cross and prev_condition == -1.0:
        return -1.1
    else:
        return prev_condition

# Neuron STATE_5: TP2 Hit (Long)
def detect_tp2_long(tp2_cross, prev_condition):
    """
    Transition: condition[1] == 1.1  AND  high > tp2Line
    → New State: condition = 1.2
    """
    if tp2_cross and prev_condition == 1.1:
        return 1.2
    else:
        return prev_condition

# Neuron STATE_6: TP2 Hit (Short)
def detect_tp2_short(tp2_cross, prev_condition):
    if tp2_cross and prev_condition == -1.1:
        return -1.2
    else:
        return prev_condition

# Neuron STATE_7: TP3 Hit (Long)
def detect_tp3_long(tp3_cross, prev_condition):
    if tp3_cross and prev_condition == 1.2:
        return 1.3
    else:
        return prev_condition

# Neuron STATE_8: TP3 Hit (Short)
def detect_tp3_short(tp3_cross, prev_condition):
    if tp3_cross and prev_condition == -1.2:
        return -1.3
    else:
        return prev_condition

# Neuron STATE_9: SL Hit (Long)
def detect_sl_long(sl_cross, prev_condition):
    """
    Transition: condition[1] >= 1.0  AND  low < slLine
    → New State: condition = 0.0 (exit all)
    """
    if sl_cross and prev_condition >= 1.0:
        return 0.0
    else:
        return prev_condition

# Neuron STATE_10: SL Hit (Short)
def detect_sl_short(sl_cross, prev_condition):
    if sl_cross and prev_condition <= -1.0:
        return 0.0
    else:
        return prev_condition

# Neuron STATE_11: Manual Exit (Long)
def detect_manual_exit_long(lxTrigger, prev_condition):
    """
    User forced exit
    """
    if lxTrigger and prev_condition >= 1.0:
        return 0.0
    else:
        return prev_condition

# Neuron STATE_12: Manual Exit (Short)
def detect_manual_exit_short(sxTrigger, prev_condition):
    if sxTrigger and prev_condition <= -1.0:
        return 0.0
    else:
        return prev_condition

# State Update Logic (Switch Statement)
def update_state():
    """
    Run all state neurons in sequence
    First matching transition wins
    """
    new_state = condition  # Start with current state
    
    # Check all transitions
    new_state = detect_long_entry(leTrigger, new_state)
    new_state = detect_short_entry(seTrigger, new_state)
    new_state = detect_tp1_long(tp1Long, new_state)
    new_state = detect_tp1_short(tp1Short, new_state)
    new_state = detect_tp2_long(tp2Long, new_state)
    new_state = detect_tp2_short(tp2Short, new_state)
    new_state = detect_tp3_long(tp3Long, new_state)
    new_state = detect_tp3_short(tp3Short, new_state)
    new_state = detect_sl_long(slLong, new_state)
    new_state = detect_sl_short(slShort, new_state)
    new_state = detect_manual_exit_long(lxTrigger, new_state)
    new_state = detect_manual_exit_short(sxTrigger, new_state)
    
    condition := new_state  # Update global state
```

**State Diagram:**
```
         ┌─────────────┐
         │ condition=0 │ ← No Position
         └──────┬──────┘
                │
       ┌────────┴─────────┐
       │   Entry Signal   │
       └────────┬─────────┘
                │
     ┌──────────▼──────────┐
     │   condition=±1.0    │ ← Entry, Set TP1/TP2/TP3/SL
     │   (Waiting TP1)     │
     └──────────┬──────────┘
                │
       ┌────────┴─────────┐
       │    TP1 Cross     │
       └────────┬─────────┘
                │
     ┌──────────▼──────────┐
     │   condition=±1.1    │ ← Close 50%, Waiting TP2
     └──────────┬──────────┘
                │
       ┌────────┴─────────┐
       │    TP2 Cross     │
       └────────┬─────────┘
                │
     ┌──────────▼──────────┐
     │   condition=±1.2    │ ← Close 30%, Waiting TP3
     └──────────┬──────────┘
                │
       ┌────────┴─────────┐
       │    TP3 Cross     │
       └────────┬─────────┘
                │
     ┌──────────▼──────────┐
     │   condition=±1.3    │ ← Close 20%, Complete
     └──────────┬──────────┘
                │
                ▼
         ┌─────────────┐
         │ condition=0 │
         └─────────────┘

     Note: SL Cross from ANY state (±1.0/1.1/1.2) → 0.0
```

---

#### **TP/SL Calculator (6 neurons)**

```python
# Neuron RISK_1: Entry Price Memory
def save_entry_price(leTrigger, seTrigger, close, prev_entry):
    """
    Save entry price when new position opens
    Weight: Conditional assignment
    """
    if leTrigger and condition[1] <= 0.0:
        return close  # Save long entry
    elif seTrigger and condition[1] >= 0.0:
        return close  # Save short entry
    else:
        return prev_entry  # Keep previous entry

# Neuron RISK_2: ATR-based Distance
def calculate_tp_sl_distance(atr, profit_factor=2.5):
    """
    Weight Matrix: [profit_factor, multipliers]
    
    Distance Calculation:
    - TP1: 1 × 2.5 × ATR
    - TP2: 2 × 2.5 × ATR
    - TP3: 3 × 2.5 × ATR
    - SL:  1 × 2.5 × ATR
    """
    tp1_distance = 1 * profit_factor * atr
    tp2_distance = 2 * profit_factor * atr
    tp3_distance = 3 * profit_factor * atr
    sl_distance = 1 * profit_factor * atr
    
    return tp1_distance, tp2_distance, tp3_distance, sl_distance

# Neuron RISK_3: Long TP/SL Lines
def calculate_long_lines(entry, tp1_dist, tp2_dist, tp3_dist, sl_dist):
    """
    Weight: Addition/Subtraction operators
    """
    tp1_line = entry + tp1_dist
    tp2_line = entry + tp2_dist
    tp3_line = entry + tp3_dist
    sl_line = entry - sl_dist
    
    return tp1_line, tp2_line, tp3_line, sl_line

# Neuron RISK_4: Short TP/SL Lines
def calculate_short_lines(entry, tp1_dist, tp2_dist, tp3_dist, sl_dist):
    """
    Weight: Reverse direction (subtraction/addition)
    """
    tp1_line = entry - tp1_dist
    tp2_line = entry - tp2_dist
    tp3_line = entry - tp3_dist
    sl_line = entry + sl_dist
    
    return tp1_line, tp2_line, tp3_line, sl_line

# Neuron RISK_5: Line Persistence
def persist_lines(new_trigger, current_lines, calculated_lines):
    """
    Update lines only when new position opens
    Otherwise keep existing lines
    """
    if new_trigger:
        return calculated_lines
    else:
        return current_lines

# Neuron RISK_6: Cross Detection
def detect_cross(price1, price2, line, cross_over):
    """
    Detect if price crossed a line
    
    Input Features:
    - price1: Current price (high or low)
    - price2: Previous price
    - line: TP or SL line
    - cross_over: Direction (TRUE=cross above, FALSE=cross below)
    
    Weight: Boolean comparison
    Activation: AND gate
    """
    if cross_over:
        # Cross above (for TP in long, SL in short)
        crossed = (price1 > line) and (price2 <= line)
    else:
        # Cross below (for SL in long, TP in short)
        crossed = (price1 < line) and (price2 >= line)
    
    return crossed

# ตัวอย่างการคำนวณ:
#
# Long Entry @ 1.0850
# ATR(20) = 0.0010 (10 pips)
#
# TP/SL Distances:
# tp1_dist = 1 × 2.5 × 0.0010 = 0.0025 (25 pips)
# tp2_dist = 2 × 2.5 × 0.0010 = 0.0050 (50 pips)
# tp3_dist = 3 × 2.5 × 0.0010 = 0.0075 (75 pips)
# sl_dist  = 1 × 2.5 × 0.0010 = 0.0025 (25 pips)
#
# TP/SL Lines:
# tp1Line = 1.0850 + 0.0025 = 1.0875
# tp2Line = 1.0850 + 0.0050 = 1.0900
# tp3Line = 1.0850 + 0.0075 = 1.0925
# slLine  = 1.0850 - 0.0025 = 1.0825
```

---

#### **Position Size Calculator (4 neurons)**

```python
# Neuron SIZE_1: Initial Volume
def calculate_initial_volume(account_equity, default_qty_percent=50):
    """
    Strategy uses default_qty_type = strategy.percent_of_equity
    default_qty_value = 50
    
    Weight: Percentage multiplier
    """
    initial_volume = account_equity * (default_qty_percent / 100)
    return initial_volume

# Neuron SIZE_2: TP1 Volume
def calculate_tp1_volume(initial_volume, tp1_percent=50):
    """
    Close 50% at TP1
    Weight: 0.50
    """
    tp1_volume = initial_volume * (tp1_percent / 100)
    return tp1_volume

# Neuron SIZE_3: TP2 Volume
def calculate_tp2_volume(initial_volume, tp2_percent=30):
    """
    Close 30% at TP2 (of INITIAL volume, not remaining)
    Weight: 0.30
    """
    tp2_volume = initial_volume * (tp2_percent / 100)
    return tp2_volume

# Neuron SIZE_4: TP3 Volume
def calculate_tp3_volume(initial_volume, tp3_percent=20):
    """
    Close 20% at TP3
    Weight: 0.20
    """
    tp3_volume = initial_volume * (tp3_percent / 100)
    return tp3_volume

# Verification:
# tp1_percent + tp2_percent + tp3_percent = 50 + 30 + 20 = 100% ✅

# ตัวอย่าง:
# Account Equity = $5000
# default_qty_percent = 50%
#
# initial_volume = $5000 × 50% = $2500
#
# TP1: $2500 × 50% = $1250  (Close $1250, Remain $1250)
# TP2: $2500 × 30% = $750   (Close $750,  Remain $500)
# TP3: $2500 × 20% = $500   (Close $500,  Remain $0)
#
# Total Closed = $1250 + $750 + $500 = $2500 ✅
```

---

### **5️⃣ OUTPUT LAYER → Order Execution (Neurons: ~20)**

#### **Executor 1: ATR Mode Orders (12 neurons)**

```python
# Neuron ORDER_1: Long Entry
def execute_long_entry(longE, tps_type):
    """
    Condition: strategy.position_size <= 0 AND longE AND TPSType == "ATR"
    
    Order Type: Market Entry
    """
    if strategy.position_size <= 0 and longE and tps_type == "ATR":
        strategy.entry(
            id = 'Long',
            direction = strategy.long,
            alert_message = 'Long Entry',
            comment = 'long'
        )

# Neuron ORDER_2: Long TP1 Exit
def execute_long_tp1(condition, tps_type):
    """
    Condition: strategy.position_size > 0 AND condition == 1.0
    
    Order Type: Limit Order (exit)
    qty_percent: 50%
    """
    if strategy.position_size > 0 and condition == 1.0 and tps_type == "ATR":
        strategy.exit(
            id = 'LXTP1',
            from_entry = 'Long',
            qty_percent = 50,          # Close 50%
            limit = tp1Line,           # Take Profit price
            stop = slLine,             # Stop Loss price
            comment_profit = 'close',
            comment_loss = 'close',
            alert_profit = 'Long TP1',
            alert_loss = 'Long SL'
        )

# Neuron ORDER_3: Long TP2 Exit
def execute_long_tp2(condition, tps_type):
    """
    Condition: strategy.position_size > 0 AND condition == 1.1
    """
    if strategy.position_size > 0 and condition == 1.1 and tps_type == "ATR":
        strategy.exit(
            id = 'LXTP2',
            from_entry = 'Long',
            qty_percent = 30,          # Close 30% of INITIAL
            limit = tp2Line,
            stop = slLine,
            comment_profit = 'close',
            comment_loss = 'close',
            alert_profit = 'Long TP2',
            alert_loss = 'Long SL'
        )

# Neuron ORDER_4: Long TP3 Exit
def execute_long_tp3(condition, tps_type):
    """
    Condition: strategy.position_size > 0 AND condition == 1.2
    """
    if strategy.position_size > 0 and condition == 1.2 and tps_type == "ATR":
        strategy.exit(
            id = 'LXTP3',
            from_entry = 'Long',
            qty_percent = 20,          # Close 20% of INITIAL
            limit = tp3Line,
            stop = slLine,
            comment_profit = 'close',
            comment_loss = 'close',
            alert_profit = 'Long TP3',
            alert_loss = 'Long SL'
        )

# Neuron ORDER_5: Long Manual Close
def execute_long_close(longX):
    """
    Condition: longX (manual exit trigger)
    """
    if longX:
        strategy.close(
            id = 'Long',
            alert_message = 'Long Exit',
            comment = 'close'
        )

# Neuron ORDER_6-10: Short Entry & Exits
# (Same logic as Long but inverted)

def execute_short_entry(shortE, tps_type):
    if strategy.position_size >= 0 and shortE and tps_type == "ATR":
        strategy.entry('Short', strategy.short, ...)

def execute_short_tp1(condition, tps_type):
    if strategy.position_size < 0 and condition == -1.0:
        strategy.exit('SXTP1', from_entry='Short', qty_percent=50, ...)

def execute_short_tp2(condition, tps_type):
    if strategy.position_size < 0 and condition == -1.1:
        strategy.exit('SXTP2', from_entry='Short', qty_percent=30, ...)

def execute_short_tp3(condition, tps_type):
    if strategy.position_size < 0 and condition == -1.2:
        strategy.exit('SXTP3', from_entry='Short', qty_percent=20, ...)

def execute_short_close(shortX):
    if shortX:
        strategy.close('Short', ...)
```

**Order Lifecycle Example:**
```
Bar 1: Long Entry @ 1.0850
       ├─ strategy.entry('Long')
       ├─ Position Size: $2500
       ├─ State: condition = 1.0
       └─ strategy.exit('LXTP1', qty_percent=50, limit=1.0875, stop=1.0825) ← Pending

Bar 15: Price reaches TP1 (1.0875)
        ├─ LXTP1 order fills
        ├─ Close: $1250 (50%)
        ├─ Remaining: $1250
        ├─ State: condition = 1.1
        └─ strategy.exit('LXTP2', qty_percent=30, limit=1.0900, stop=1.0825) ← Pending

Bar 28: Price reaches TP2 (1.0900)
        ├─ LXTP2 order fills
        ├─ Close: $750 (30% of initial $2500)
        ├─ Remaining: $500
        ├─ State: condition = 1.2
        └─ strategy.exit('LXTP3', qty_percent=20, limit=1.0925, stop=1.0825) ← Pending

Bar 45: Price reaches TP3 (1.0925)
        ├─ LXTP3 order fills
        ├─ Close: $500 (20% of initial $2500)
        ├─ Remaining: $0
        └─ State: condition = 1.3 (Complete!)

Alternative: SL Hit @ Bar 8
            ├─ Price drops to 1.0825
            ├─ All LXTP orders cancelled
            ├─ Close: $2500 (100%)
            ├─ State: condition = 0.0
            └─ Loss: -$25 pips × $2500 = -$625
```

---

#### **Executor 2: Trailing Mode Orders (4 neurons)**

```python
# Neuron TRAIL_1: Trailing Buy
def execute_trailing_buy(buy, tps_type):
    """
    No TP/SL, hold until reverse signal
    """
    if buy and tps_type == "Trailing":
        strategy.close('Short')      # Close opposite first
        strategy.entry('Long', strategy.long, ...)

# Neuron TRAIL_2: Trailing Sell
def execute_trailing_sell(sell, tps_type):
    if sell and tps_type == "Trailing":
        strategy.close('Long')
        strategy.entry('Short', strategy.short, ...)

# Neuron TRAIL_3: Trailing Long Close (redundant, handled by TRAIL_2)
# Neuron TRAIL_4: Trailing Short Close (redundant, handled by TRAIL_1)
```

**Trailing Mode Behavior:**
```
Bar 1:  Buy signal → Open Long @ 1.0850
Bar 2:  Hold Long
...
Bar 50: Hold Long (no SL/TP)
Bar 51: Sell signal → Close Long @ 1.1000 (+150 pips)
                    → Open Short @ 1.1000
Bar 52: Hold Short
...
Bar 80: Hold Short
Bar 81: Buy signal → Close Short @ 1.0900 (+100 pips for short)
                   → Open Long @ 1.0900

# ลักษณะ: Follow trend จนกว่าจะกลับทิศ
# Risk: Drawdown สูงถ้า trend กลับอย่างรวดเร็ว
```

---

#### **Executor 3: Options Mode Orders (2 neurons)**

```python
# Neuron OPTION_1: Options Buy (Long Only)
def execute_options_buy(buy, tps_type):
    """
    Long only strategy
    No short positions
    """
    if buy and tps_type == "Options":
        strategy.entry('Long', strategy.long, ...)

# Neuron OPTION_2: Options Sell (Close Only)
def execute_options_sell(sell, tps_type):
    """
    Close long on sell signal
    Do NOT open short
    """
    if sell and tps_type == "Options":
        strategy.close('Long', ...)
        # No strategy.entry('Short') ← Key difference!
```

**Options Mode Behavior:**
```
Bar 1:  Buy signal → Open Long @ 1.0850
Bar 2:  Hold Long
...
Bar 50: Sell signal → Close Long @ 1.1000 (+150 pips)
                    → Wait (no short)
Bar 51: Hold cash
Bar 52: Hold cash
...
Bar 80: Buy signal → Open Long @ 1.0950
Bar 81: Hold Long

# ลักษณะ: Long only, ปลอดภัยกว่าในตลาดขาขึ้น
# Risk: พลาดกำไรจาก short side
```

---

#### **Visualizer (8 neurons)**

```python
# Neuron VIS_1: Bar Colors
def color_bars(close_alt, open_alt, show_colors):
    """
    Color bars based on trend
    """
    if show_colors:
        if close_alt > open_alt:
            barcolor(color.lime)      # Bullish
        else:
            barcolor(color.red)       # Bearish

# Neuron VIS_2: TP Lines
def plot_tp_lines(condition, tp1, tp2, tp3):
    """
    Plot TP lines when position is active
    """
    if condition != 0.0:
        plot(tp1, color=color.green, linewidth=1, style=plot.style_linebr)
        plot(tp2, color=color.green, linewidth=1, style=plot.style_linebr)
        plot(tp3, color=color.green, linewidth=1, style=plot.style_linebr)

# Neuron VIS_3: Entry Line
def plot_entry_line(condition, entry):
    if abs(condition) >= 1.0:
        plot(entry, color=color.blue, linewidth=1, style=plot.style_linebr)

# Neuron VIS_4: SL Line
def plot_sl_line(condition, sl):
    if abs(condition) >= 1.0:
        plot(sl, color=color.red, linewidth=1, style=plot.style_linebr)

# Neuron VIS_5: Fill Areas
def fill_areas(entry_plot, sl_plot):
    """
    Fill area between entry and SL with semi-transparent red
    """
    fill(entry_plot, sl_plot, color=color.new(color.red, 90))

# Neuron VIS_6: Alert Shapes
def plot_signals(was_long, was_short):
    """
    Show yellow markers for pending signals
    """
    plotshape(was_long, color=color.yellow, style=shape.circle, location=location.belowbar)
    plotshape(was_short, color=color.yellow, style=shape.circle, location=location.abovebar)

# Neuron VIS_7: Ribbon (Optional)
def plot_ribbon(show_ribbon, ha_close, ha_open):
    if show_ribbon:
        close_plot = plot(ha_close, color=color.red, linewidth=2)
        open_plot = plot(ha_open, color=color.lime, linewidth=2)
        fill(close_plot, open_plot, color=color.new(trend_color, 80))

# Neuron VIS_8: Order Blocks & FVG (Advanced)
def plot_order_blocks(show_ob, ob_data):
    """
    Plot supply/demand zones based on volume
    """
    if show_ob:
        for block in ob_data:
            box.new(block.left, block.top, block.right, block.bottom,
                    bgcolor=color.new(color.blue, 80))

# Example Visual Output:
# ┌───────────────────────────────────────────────┐
# │ Chart                                         │
# │                                               │
# │        TP3 ─────────────────  1.0925 (green) │
# │        TP2 ─────────────────  1.0900 (green) │
# │        TP1 ─────────────────  1.0875 (green) │
# │      Entry ─────────────────  1.0850 (blue)  │
# │     [Candlesticks - colored]                  │
# │         SL ─────────────────  1.0825 (red)   │
# │                                               │
# │     [Area: Entry to SL filled with light red]│
# │                                               │
# └───────────────────────────────────────────────┘
```

---

#### **Dashboard Generator (3 neurons)**

```python
# Neuron DASH_1: Strategy Performance
def generate_performance_table(show_table):
    """
    Display win rate, PnL, trades, etc.
    """
    if show_table:
        table = table.new(position.top_left, columns=2, rows=10)
        
        table.cell(0, 0, "Total Trades:", bgcolor=color.gray)
        table.cell(0, 1, str.tostring(strategy.closedtrades))
        
        table.cell(1, 0, "Win Rate:", bgcolor=color.gray)
        win_rate = (strategy.wintrades / strategy.closedtrades) * 100
        table.cell(1, 1, str.tostring(win_rate, '#.##') + "%")
        
        table.cell(2, 0, "Net Profit:", bgcolor=color.gray)
        table.cell(2, 1, "$" + str.tostring(strategy.netprofit, '#.##'))
        
        # ... more metrics

# Neuron DASH_2: Weekly Performance
def generate_weekly_table(show_weekly):
    """
    Display performance by day of week
    """
    if show_weekly:
        # Create 7-column table (Mon-Sun)
        # Fill with daily PnL data
        # Color cells: green (profit) / red (loss)

# Neuron DASH_3: Monthly Performance
def generate_monthly_table(show_monthly):
    """
    Display performance by month
    """
    if show_monthly:
        # Create 12-column table (Jan-Dec)
        # Fill with monthly PnL data
```

---

## 🔄 COMPLETE DATA FLOW EXAMPLE

### **Scenario: Long Entry → TP1 → TP2 → TP3**

#### **Bar 1: Entry Conditions**

**INPUT LAYER:**
```
Price Data:
├─ Open:   1.0845
├─ High:   1.0860
├─ Low:    1.0840
└─ Close:  1.0855

Settings:
├─ TPSType:        "ATR"
├─ SetupType:      "Open/Close"
├─ FilterType:     "No Filtering"
├─ TimeframeGEMult: 18 (M5 → M90)
└─ ProfitFactor:   2.5
```

**HIDDEN LAYER 1 - Feature Extraction:**
```
Heikin Ashi (HTF M90):
├─ HA_close_prev: 1.0840  (Bar[-2])
├─ HA_open_prev:  1.0850
├─ HA_close_curr: 1.0860  (Bar[-1]) ← Completed bar
├─ HA_open_curr:  1.0850
└─ Crossover: HA_close > HA_open (1.0860 > 1.0850) ✅

RSI(7):
└─ RSI = 52 → No filter block

ATR(20):
└─ ATR = 0.0010 (10 pips)

ATR(5) Filter:
├─ ATR(5) = 0.0012
├─ ATR_MA(5) = 0.0010
└─ Volatile: TRUE (0.0012 >= 0.0010) ✅
```

**HIDDEN LAYER 2 - Logic Gates:**
```
Setup Selector:
└─ BUYOC = HA_crossover AND setupType=="Open/Close" AND filter_pass
   = TRUE AND TRUE AND TRUE
   = TRUE ✅

Filter Gate:
└─ filter_pass = filter_none() = TRUE ✅

Date Filter:
└─ tradeDateIsAllowed = (now >= fromDate AND now <= toDate) = TRUE ✅

Signal Combiner:
├─ leTrigger = BUYOC AND filter_pass AND tradeDateIsAllowed
│  = TRUE AND TRUE AND TRUE
│  = TRUE ✅
└─ seTrigger = FALSE
```

**HIDDEN LAYER 3 - State Machine:**
```
Current State:
└─ condition[1] = 0.0 (No position)

Entry Detection:
└─ leTrigger AND condition[1] <= 0.0
   = TRUE AND TRUE
   → New State: condition = 1.0 ✅

TP/SL Calculator:
├─ Entry: 1.0855
├─ ATR: 0.0010
├─ TP1_dist: 1 × 2.5 × 0.0010 = 0.0025
├─ TP2_dist: 2 × 2.5 × 0.0010 = 0.0050
├─ TP3_dist: 3 × 2.5 × 0.0010 = 0.0075
├─ SL_dist:  1 × 2.5 × 0.0010 = 0.0025
├─ tp1Line: 1.0855 + 0.0025 = 1.0880
├─ tp2Line: 1.0855 + 0.0050 = 1.0905
├─ tp3Line: 1.0855 + 0.0075 = 1.0930
└─ slLine:  1.0855 - 0.0025 = 1.0830

Position Size:
├─ Account: $5000
├─ Qty%: 50%
├─ Initial: $2500
├─ TP1_vol: $1250 (50%)
├─ TP2_vol: $750 (30%)
└─ TP3_vol: $500 (20%)
```

**OUTPUT LAYER - Execution:**
```
Order 1: Entry
├─ strategy.entry('Long', strategy.long)
├─ Entry Price: 1.0855
├─ Volume: $2500
└─ Status: FILLED ✅

Order 2: TP1 Exit (Pending)
├─ strategy.exit('LXTP1', from_entry='Long')
├─ qty_percent: 50%
├─ limit: 1.0880
├─ stop: 1.0830
└─ Status: PENDING (waiting for price to reach 1.0880)

Visualization:
├─ Entry Line (blue) @ 1.0855
├─ TP1 Line (green) @ 1.0880
├─ TP2 Line (green) @ 1.0905
├─ TP3 Line (green) @ 1.0930
├─ SL Line (red) @ 1.0830
└─ Bar color: GREEN (bullish)
```

---

#### **Bar 15: TP1 Hit**

**INPUT LAYER:**
```
Price Data:
├─ Open:   1.0875
├─ High:   1.0885  ← Crosses TP1 (1.0880)
├─ Low:    1.0870
└─ Close:  1.0880
```

**HIDDEN LAYER 3 - State Machine:**
```
Cross Detection:
├─ tp1Long = high > tp1Line AND prev_high <= tp1Line
│  = 1.0885 > 1.0880 AND 1.0865 <= 1.0880
│  = TRUE AND TRUE
│  = TRUE ✅
└─ condition[1] = 1.0

State Transition:
└─ tp1Long AND condition[1] == 1.0
   = TRUE AND TRUE
   → New State: condition = 1.1 ✅
```

**OUTPUT LAYER:**
```
Order Execution:
├─ LXTP1 order FILLS @ 1.0880
├─ Close Volume: $1250 (50%)
├─ Remaining Volume: $1250
├─ Profit: ($1250 × 25 pips) = +$312.50 ✅
└─ Alert: "Long TP1"

New Order: TP2 Exit (Pending)
├─ strategy.exit('LXTP2')
├─ qty_percent: 30% (of initial $2500 = $750)
├─ limit: 1.0905
├─ stop: 1.0830
└─ Status: PENDING
```

---

#### **Bar 28: TP2 Hit**

**INPUT LAYER:**
```
Price Data:
├─ High:   1.0910  ← Crosses TP2 (1.0905)
```

**HIDDEN LAYER 3:**
```
Cross Detection:
└─ tp2Long = TRUE ✅

State Transition:
└─ condition: 1.1 → 1.2 ✅
```

**OUTPUT LAYER:**
```
Order Execution:
├─ LXTP2 order FILLS @ 1.0905
├─ Close Volume: $750 (30% of initial)
├─ Remaining: $500
├─ Profit: ($750 × 50 pips) = +$375 ✅
└─ Alert: "Long TP2"

New Order: TP3 Exit (Pending)
├─ limit: 1.0930
├─ qty_percent: 20% ($500)
```

---

#### **Bar 45: TP3 Hit**

**INPUT LAYER:**
```
Price Data:
├─ High:   1.0935  ← Crosses TP3 (1.0930)
```

**HIDDEN LAYER 3:**
```
State Transition:
└─ condition: 1.2 → 1.3 ✅ (Complete!)
```

**OUTPUT LAYER:**
```
Order Execution:
├─ LXTP3 order FILLS @ 1.0930
├─ Close Volume: $500 (20%)
├─ Remaining: $0
├─ Profit: ($500 × 75 pips) = +$375 ✅
└─ Alert: "Long TP3"

Total Trade Summary:
├─ Entry: 1.0855
├─ TP1: +$312.50 (50% @ 1.0880)
├─ TP2: +$375.00 (30% @ 1.0905)
├─ TP3: +$375.00 (20% @ 1.0930)
├─ Total Profit: +$1062.50
├─ Risk: $625 (25 pips × $2500)
└─ R:R = 1:1.7 ✅

State Reset:
└─ condition = 1.3 → Ready for new entry (when condition → 0.0)
```

---

## 📊 SETTINGS SUMMARY TABLE

| Group | Setting | Type | Default | Options | Purpose |
|-------|---------|------|---------|---------|---------|
| **Main** | TPS Type | Dropdown | Trailing | ATR, Trailing, Options | เลือกวิธีบริหาร TP/SL |
| **Main** | Setup Type | Dropdown | Open/Close | Open/Close, Renko | เลือก signal generator |
| **Main** | Show Colored Bars | Checkbox | TRUE | TRUE/FALSE | แสดงสี bar ตาม trend |
| **Main** | Enable Ribbon | Checkbox | FALSE | TRUE/FALSE | แสดง HA ribbon |
| **Strategy Options** | Sideways Filtering | Dropdown | No Filtering | 7 options | กรอง sideways market |
| **RSI Filtering** | RSI Length | Number | 7 | 1-100 | Period ของ RSI |
| **RSI Filtering** | TOP Limit | Number | 45 | 0-100 | RSI overbought level |
| **RSI Filtering** | BOT Limit | Number | 10 | 0-100 | RSI oversold level |
| **Renko Settings** | EMA1 Length | Number | 2 | 1-100 | EMA fast period |
| **Renko Settings** | EMA2 Length | Number | 10 | 1-100 | EMA slow period |
| **Risk Management** | Qty TP1 | Number | 50 | 0-100 | % ปิดที่ TP1 |
| **Risk Management** | Qty TP2 | Number | 30 | 0-100 | % ปิดที่ TP2 |
| **Risk Management** | Qty TP3 | Number | 20 | 0-100 | % ปิดที่ TP3 |
| **Dashboards** | Strategy Performance | Checkbox | FALSE | TRUE/FALSE | แสดงตาราง stats |
| **Dashboards** | Weekly Performance | Checkbox | FALSE | TRUE/FALSE | แสดง weekly PnL |
| **Dashboards** | Monthly Performance | Checkbox | FALSE | TRUE/FALSE | แสดง monthly PnL |
| **EMA & ATR** | Plot EMA | Checkbox | FALSE | TRUE/FALSE | แสดง EMA lines |
| **EMA & ATR** | Use Higher Time Frame | Checkbox | TRUE | TRUE/FALSE | ใช้ HTF data |
| **EMA & ATR** | Plot Dema | Checkbox | FALSE | TRUE/FALSE | แสดง DEMA |
| **ZigZag Config** | Depth | Number | 12 | 1-100 | ZigZag sensitivity |
| **ZigZag Config** | Deviation | Number | 5 | 1-100 | Min price change |
| **ZigZag Config** | Backstep | Number | 2 | 2-100 | Min bars between pivots |
| **Lines** | Line Thickness | Number | 2 | 1-4 | ความหนาของเส้น |
| **Labels** | Label Size | Number | 3 | 1-5 | ขนาดของ label |
| **Market Structure** | Window | Checkbox + Number | TRUE, 5000 | TRUE/FALSE, 1000+ | Window size for MS |
| **Market Structure** | Swing | Checkbox + Number | TRUE, 100 | TRUE/FALSE, 10-200 | Swing limit |
| **Market Structure** | Mapping Structure | Checkbox | FALSE | TRUE/FALSE | แสดง structure mapping |
| **Market Structure** | Color Candles | Checkbox | FALSE | TRUE/FALSE | ระบายสี candles |
| **Market Structure** | Algorithmic Logic | Dropdown | Adjusted Points | Extreme/Adjusted | วิธีหา pivot points |
| **Market Structure** | Node Length | Number | 5 | 2-100 | Length สำหรับ nodes |
| **Market Structure** | Build Sweep | Checkbox | TRUE | TRUE/FALSE | สร้าง sweep markers |
| **Market Structure** | Bubbles | Checkbox | TRUE | TRUE/FALSE | แสดง bubble markers |
| **Order Blocks** | Show Last | Checkbox + Number | TRUE, 5 | TRUE/FALSE, 0+ | จำนวน OB ที่แสดง |
| **Order Blocks** | Show Buy/Sell Activity | Checkbox | TRUE | TRUE/FALSE | แสดง activity labels |
| **Order Blocks** | Show Breakers | Checkbox | FALSE | TRUE/FALSE | แสดง breaker blocks |
| **Order Blocks** | Construction | Dropdown + Number | Length, 5 | Length/Full, 1+ | วิธีสร้าง OB |
| **Order Blocks** | Mitigation Method | Dropdown | Close | Close/Wick/Avg | วิธีตรวจสอบ mitigation |
| **Order Blocks** | Metric Size | Dropdown | Normal | Tiny-Huge | ขนาด metrics |
| **Order Blocks** | Show Metrics | Checkbox | TRUE | TRUE/FALSE | แสดงตัวเลข |
| **Order Blocks** | Show Mid-Line | Checkbox | TRUE | TRUE/FALSE | แสดงเส้นกลาง |
| **Order Blocks** | Hide Overlap | Checkbox + Dropdown | TRUE, Recent | TRUE/FALSE, Recent/Old | ซ่อน OB ซ้อนทับ |
| **Fair Value Gap** | Enable FVG | Checkbox + Dropdown | FALSE, FVG | TRUE/FALSE, FVG options | เปิดใช้ FVG |
| **Fair Value Gap** | Show Last | Number | 5 | 0+ | จำนวน FVG ที่แสดง |
| **Fair Value Gap** | Mitigation | Dropdown | Close | Close/Wick/Avg | วิธีตรวจสอบ mitigation |
| **Fair Value Gap** | Threshold | Number | 0 | 0+ | กรอง FVG เล็ก |
| **Fair Value Gap** | Hide Overlap | Checkbox | TRUE | TRUE/FALSE | ซ่อน FVG ซ้อนทับ |
| **Fair Value Gap** | Show Mid-Line | Checkbox | TRUE | TRUE/FALSE | แสดงเส้นกลาง |
| **Fair Value Gap** | Extend FVG | Checkbox | FALSE | TRUE/FALSE | ขยาย FVG ไปข้างหน้า |
| **Fair Value Gap** | Display Raids | Checkbox | FALSE | TRUE/FALSE | แสดง raid markers |

---

## 🎯 KEY TAKEAWAYS

### **Neural Network Layers:**
1. **INPUT (20 neurons)** → Collect price, time, settings
2. **HIDDEN 1 (30 neurons)** → Calculate HA, RSI, ATR, EMA
3. **HIDDEN 2 (15 neurons)** → Apply filters, combine signals
4. **HIDDEN 3 (25 neurons)** → State machine, TP/SL calculation
5. **OUTPUT (20 neurons)** → Execute orders, visualize

### **Total Neurons: ~110**

### **Activation Functions:**
- **Linear:** Price calculations, averages
- **Max/Min Pooling:** HA High/Low
- **Boolean Logic:** Filters, crossovers
- **Step Function:** Signal generation
- **Conditional Assignment:** State machine

### **Learning Type:**
- **Rule-based (not ML):** Uses explicit logic, not trained on data
- **Deterministic:** Same inputs → Same outputs
- **Real-time:** Processes every bar

### **Performance:**
- **Win Rate:** Depends on market conditions (~50-60% typical)
- **Risk:Reward:** 1:1.7 (ATR Mode with partial TP)
- **Commission:** 0.02% per trade
- **Max Drawdown:** Varies by mode (Trailing > ATR > Options)

---

## 🔗 INTERCONNECTIONS

```
Settings → Filter Selection → Signal Generation → State Machine → Order Execution
   ↓            ↓                    ↓                 ↓              ↓
 User        Block/Pass         leTrigger        condition      strategy.entry()
 Input      Sideways            seTrigger         ±1.0/1.1      strategy.exit()
                                                   ±1.2/1.3

HTF Data → HA Calculation → Crossover Detection → Setup Selector → Logic Gate
   ↓            ↓                    ↓                 ↓              ↓
M5 × 18     HA_close/open        buy_signal      OpenClose      leTrigger
  M90         formula            sell_signal       /Renko        seTrigger

ATR → TP/SL Distance → Line Calculation → Cross Detection → Order Fill
 ↓         ↓                ↓                   ↓               ↓
0.0010   ×2.5 = 0.0025   entry±0.0025     high>tp1Line    strategy.exit()
```

---

**สรุป:** Strategy นี้เป็นระบบ Neural Network แบบ rule-based ที่ประกอบด้วย 110 neurons กระจายอยู่ใน 5 layers โดยแต่ละ layer ทำหน้าที่เฉพาะ และเชื่อมโยงกันผ่าน data flow จาก Input → Feature Extraction → Logic Gates → State Machine → Output Execution

Settings ทุกตัวมีผลต่อพฤติกรรมของ neurons ในแต่ละ layer ทำให้ผู้ใช้สามารถปรับแต่ง strategy ได้อย่างละเอียด โดยไม่ต้องแก้โค้ด
