# 📋 Project Rules & Progress Documentation
**Heikin Ashi Strategy EA - Pine Script to MQ5 Conversion**

*สำหรับ AI Assistant: โปรดอ่านเอกสารนี้ทั้งหมดก่อนทำการแก้ไขโค้ด*

---

## 📌 Project Overview

### **Objective**
แปลง Pine Script Strategy (ableSignals & Overlays Private™ 7.9-X) จาก TradingView เป็น MQ5 Expert Advisor สำหรับ MetaTrader 5 โดยต้องมี **feature parity 95%+**

### **Source Code**
- Pine Script: `ttt.txt` (2702 lines)
- Target Platform: MetaTrader 5 (MQL5)
- Symbol: XAUUSD/XAUUSDm (Gold)
- Timeframe: M5 (สำคัญ! ต้องใช้ M5 เท่านั้น)

### **GitHub Repositories**
- **Mac Repo (Primary/Latest):** https://github.com/beebobby-11/FN.git ✅
- **Windows Repo:** https://github.com/athens-21/FN.git ⚠️ (outdated)

---

## 🏗️ Architecture Design

### **5-Layer Neural Network Structure**

```
Layer 1: Input Parameters (98 params)
    ↓
Layer 2: Indicator Handlers (iCustom, iRSI, iATR)
    ↓
Layer 3: Signal Processor (HTF Heikin Ashi + Filters)
    ↓
Layer 4: State Machine (7 states: 0.0, ±1.0, ±1.1, ±1.2, ±1.3)
    ↓
Layer 5: Order Executor (3 orders: 50%, 30%, 20% TP)
```

### **File Structure**

```
📁 Project Root/
├── HeikinAshiStrategyEA.mq5          ← Main EA (532 lines)
├── ttt.txt                            ← Pine Script source (READ-ONLY!)
├── 📁 Include/
│   ├── StateManager.mqh               ← State machine (350 lines)
│   ├── HeikinAshiHTF.mqh             ← M90 HA calculator (373 lines)
│   ├── FilterManager.mqh              ← 7 filters (340 lines)
│   └── OrderManager.mqh               ← Order execution (450 lines)
├── 📁 Indicators/
│   └── HeikinAshiM90.mq5             ← Custom indicator (280 lines)
└── 📁 Documentation/
    ├── README.md
    ├── MQ5_BLUEPRINT_COMPLETE_ARCHITECTURE.md
    └── COMPLETE_SETTINGS_NEURAL_NETWORK_ANALYSIS.md
```

---

## 🚨 CRITICAL RULES (Must Follow!)

### **1. Pine Script State Machine Logic**

**❌ WRONG (Old Code):**
```mql5
if(g_stateManager.IsFlat()) {
    if(leTrigger) { OpenLongPosition(); }
}
```

**✅ CORRECT (Current Implementation):**
```mql5
double currentState = g_stateManager.GetCondition();

// Long entry: condition[1] <= 0.0 (flat OR short)
if(leTrigger && currentState <= 0.0) {
    if(currentState < 0.0) {  // If short exists
        CloseAllPositions();   // Close opposite first
        Reset();
    }
    OpenLongPosition();        // Then open new
}

// Short entry: condition[1] >= 0.0 (flat OR long)
if(seTrigger && currentState >= 0.0) {
    if(currentState > 0.0) {   // If long exists
        CloseAllPositions();   // Close opposite first
        Reset();
    }
    OpenShortPosition();       // Then open new
}
```

**Why?** Pine Script allows position reversal:
- `leTrigger and condition[1] <= 0.0` means can enter long from flat OR from short position
- `seTrigger and condition[1] >= 0.0` means can enter short from flat OR from long position
- **Source:** `ttt.txt` lines 386-387

---

### **2. Include Paths - Relative, Not Absolute**

**❌ WRONG:**
```mql5
#include <StateManager.mqh>           // Looks in MT5 standard library
#include <HeikinAshiHTF.mqh>          // Will fail!
```

**✅ CORRECT:**
```mql5
#include "Include/StateManager.mqh"   // Relative to project folder
#include "Include/HeikinAshiHTF.mqh"
#include "Include/FilterManager.mqh"
#include "Include/OrderManager.mqh"
```

---

### **3. Custom Indicator Path**

**❌ WRONG:**
```mql5
iCustom(symbol, tf, "Indicators\\HeikinAshiM90", multiplier);
// MT5 adds "Indicators\" prefix automatically!
// Result: Indicators\Indicators\HeikinAshiM90.ex5 → Error [557]
```

**✅ CORRECT:**
```mql5
iCustom(symbol, tf, "HeikinAshiM90", multiplier);
// MT5 will automatically find: Indicators\HeikinAshiM90.ex5
```

---

### **4. Compilation Order**

**ALWAYS compile in this order:**

1. **Indicator first:** `Indicators\HeikinAshiM90.mq5` (F7)
2. **Then EA:** `HeikinAshiStrategyEA.mq5` (F7)

**Why?** EA needs `HeikinAshiM90.ex5` to exist before compilation.

---

### **5. Const Correctness**

All "read-only" methods in helper classes **MUST** be marked `const`:

```mql5
// ✅ Correct
double GetCondition() const { return m_condition; }
bool IsFlat() const { return m_condition == 0.0; }
bool IsFilterPass() const { ... }

// ❌ Wrong
double GetCondition() { return m_condition; }  // Missing const
```

**Error if missing:** `"call non-const method for constant object"`

---

### **6. HTF Calculation - M5 × 18 = M90**

**Key Logic:**
- Base TF: **M5** (PERIOD_M5)
- Multiplier: **18**
- Result: 90-minute HTF (M90)

**Aggregation:**
```
HTF Bar 0 (current):    M5 bars 0-17   (most recent)
HTF Bar 1 (completed):  M5 bars 18-35
HTF Bar 2 (previous):   M5 bars 36-53
```

**NEVER change:**
- Base timeframe (must be M5)
- Multiplier formula
- Array indexing logic

---

### **7. Crossover Detection Logic**

From Pine Script `ttt.txt` lines 131-132:

```
BUYOC  = buy_entry == 1 and close > open and close[1] <= open[1]
SELLOC = sel_entry == 1 and close < open and close[1] >= open[1]
```

**MQ5 Implementation:**
```mql5
bool CHeikinAshiHTF::IsBullishCross() const
{
    // Previous: HA_close <= HA_open (bearish/neutral)
    // Current:  HA_close > HA_open (bullish)
    bool prev_bearish = (m_ha_close[2] <= m_ha_open[2]);
    bool curr_bullish = (m_ha_close[1] > m_ha_open[1]);
    return prev_bearish && curr_bullish;
}

bool CHeikinAshiHTF::IsBearishCross() const
{
    // Previous: HA_close >= HA_open (bullish/neutral)
    // Current:  HA_close < HA_open (bearish)
    bool prev_bullish = (m_ha_close[2] >= m_ha_open[2]);
    bool curr_bearish = (m_ha_close[1] < m_ha_open[1]);
    return prev_bullish && curr_bearish;
}
```

**Note:** Use `<=` and `>=` for previous state (allows neutral bars)

---

### **8. State Machine States**

```mql5
0.0   = Flat (no position)
1.0   = Long Entry
1.1   = Long TP1 Hit (50%)
1.2   = Long TP2 Hit (30%)
1.3   = Long TP3 Hit (20%) - Full exit

-1.0  = Short Entry
-1.1  = Short TP1 Hit (50%)
-1.2  = Short TP2 Hit (30%)
-1.3  = Short TP3 Hit (20%) - Full exit
```

**Transition Rules (from Pine Script lines 386-397):**
```
leTrigger and condition[1] <= 0.0  → 1.0
seTrigger and condition[1] >= 0.0  → -1.0
tp1Long and condition[1] == 1.0    → 1.1
tp2Long and condition[1] == 1.1    → 1.2
tp3Long and condition[1] == 1.2    → 1.3
// ... same for short
```

---

## ✅ Progress Completed

### **Phase 1: Core Implementation** ✅
- [x] StateManager.mqh (state machine with 7 states)
- [x] HeikinAshiHTF.mqh (M90 calculator + crossover detection)
- [x] FilterManager.mqh (7 filter types: ATR, RSI, combinations)
- [x] OrderManager.mqh (3-order partial TP system)
- [x] HeikinAshiStrategyEA.mq5 (main orchestrator)
- [x] HeikinAshiM90.mq5 (custom indicator)

### **Critical Fixes Applied** ✅
- [x] **Reverse Position Logic** (commit: 4ce89f6)
  - Changed from `IsFlat()` to `condition <= 0.0` check
  - Added `CloseAllPositions()` before opposite entry
  - Matches Pine Script lines 386-387
  
- [x] **Indicator Path Fix** (commit: 3e629de)
  - Removed `Indicators\\` prefix from iCustom()
  - Prevents double path error [557]
  
- [x] **Const Correctness** (commit: 697752f)
  - Added `const` to all read-only methods
  - Fixed compilation errors in FilterManager

### **Current Status**
- ✅ Compiles: 0 errors, 0 warnings
- ✅ Custom indicator: Loads successfully
- ✅ State machine: Working with reverse logic
- ✅ Git: Pushed to GitHub (Mac repo)

---

## ⏳ Pending Implementation

### **Trading Modes**
- [x] **ATR Mode** (Partial TP with 3 orders) - DONE
- [ ] **Trailing Mode** (No TP/SL, trailing only)
- [ ] **Options Mode** (Long only, no shorts)

### **Setup Types**
- [x] **Open/Close** (Heikin Ashi crossover) - DONE
- [ ] **Renko** (EMA crossover)

### **Additional Features**
- [ ] Visual elements (TP/SL lines on chart)
- [ ] State recovery after EA restart
- [ ] Dashboard display
- [ ] Performance statistics

---

## 🧪 Testing Requirements

### **Before Any Code Changes:**

1. **Read Pine Script Source:**
   ```bash
   grep -n "keyword" ttt.txt
   ```
   Find the exact Pine Script logic you're implementing

2. **Check Current Implementation:**
   Verify how it's currently coded in MQ5

3. **Plan Changes:**
   Write down what will change and why

### **After Code Changes:**

1. **Compile Check:**
   ```
   F7 in MetaEditor → Must show 0 errors
   ```

2. **Strategy Tester:**
   - Symbol: XAUUSDm
   - Timeframe: M5 (critical!)
   - Period: 2024.01.01 - 2024.06.10
   - Model: Every tick (most accurate)
   - Optimization: Off (for testing)

3. **Check Journal Tab:**
   ```
   ✓ Using custom Heikin Ashi M90 indicator
   leTrigger: YES ✓
   Filter Result: PASS ✓
   ```

4. **Verify Trades:**
   - Are positions opening?
   - Are positions reversing on opposite signals?
   - Are partial TPs executing correctly?
   - Check trade count matches expectations

---

## 🐛 Common Pitfalls (Avoid These!)

### **1. Using Wrong Repo**
❌ Windows repo (athens-21/FN) - outdated, missing fixes
✅ Mac repo (beebobby-11/FN) - latest, all fixes applied

### **2. Testing on Wrong Timeframe**
❌ M15, H1, etc. → EA won't work correctly
✅ M5 only → HTF calculation requires M5 base

### **3. Forgetting to Compile Indicator**
❌ Compile EA only → Error [557] indicator not found
✅ Compile indicator first, then EA

### **4. Modifying Pine Script Source**
❌ Editing ttt.txt → Will break reference
✅ ttt.txt is READ-ONLY reference document

### **5. Breaking State Machine Logic**
❌ Changing `condition <= 0.0` to `condition == 0.0`
✅ Keep exact comparisons from Pine Script

### **6. Hardcoding Values**
❌ `if(atr > 2.5)` → Won't work for all symbols
✅ Use input parameters and dynamic calculations

---

## 📚 Pine Script Mapping Reference

### **Key Variables Mapping**

| Pine Script | MQ5 Implementation | Location |
|-------------|-------------------|----------|
| `condition` | `m_condition` | StateManager.mqh |
| `close`, `open` | `m_ha_close[]`, `m_ha_open[]` | HeikinAshiHTF.mqh |
| `leTrigger` | `leTrigger` | OnTick() calculation |
| `seTrigger` | `seTrigger` | OnTick() calculation |
| `trendType` | `FilterType` input | FilterManager.mqh |
| `atr(20)` | `iATR(symbol, tf, 20)` | EA OnInit() |

### **Critical Code Sections in ttt.txt**

| Line Range | Description | MQ5 Location |
|------------|-------------|--------------|
| 119-140 | HTF Heikin Ashi calculation | HeikinAshiHTF.mqh |
| 131-132 | Crossover detection (BUYOC/SELLOC) | IsBullishCross(), IsBearishCross() |
| 185-200 | Signal routing (buy_entry/sel_entry) | OnTick() Step 2 |
| 386-397 | State transitions (condition :=) | StateManager transitions |
| 460-520 | Filter combinations | FilterManager.mqh |

---

## 🔄 Git Workflow

### **Branching Strategy**
- `main` - Stable, tested code
- Feature branches not needed (single developer)

### **Commit Message Format**
```
Type: Short description

- Detailed change 1
- Detailed change 2
- Reference to Pine Script line if applicable
```

**Types:**
- `Fix:` - Bug fixes
- `Add:` - New features
- `Update:` - Improvements
- `Refactor:` - Code restructuring
- `Docs:` - Documentation only

### **Example:**
```
Fix: Implement reverse position logic matching Pine Script

- Changed entry condition from IsFlat() to condition <= 0.0
- Added CloseAllPositions() before opening opposite direction
- Matches Pine Script lines 386-387
- Enables close opposite + open new functionality
```

---

## 💡 AI Assistant Guidelines

### **When Starting Work:**

1. **Read this document first** (you're doing it now ✓)
2. Check git commit history: `git log --oneline -10`
3. Read relevant Pine Script sections in `ttt.txt`
4. Check current code implementation
5. Plan changes before coding

### **When Making Changes:**

1. **One change at a time** - Don't mix multiple fixes
2. **Test after each change** - Compile + Strategy Tester
3. **Document reasoning** - Why this change matches Pine Script
4. **Verify constants** - Don't change magic numbers without reason
5. **Keep comments** - Explain Pine Script references

### **When Encountering Issues:**

1. **Check Journal tab** in Strategy Tester
2. Search Pine Script: `grep -n "keyword" ttt.txt`
3. Compare with Pine Script logic exactly
4. Ask for clarification before guessing
5. Document the issue and solution

### **Red Flags (Stop and Ask!):**

- Changing include paths
- Modifying HTF calculation logic
- Changing state machine comparisons (`<=` to `==`)
- Altering crossover detection logic
- Breaking const correctness
- Hardcoding symbol-specific values

---

## 📝 Quick Reference Commands

### **Git**
```bash
git status                          # Check changes
git log --oneline -10              # Recent commits
git diff file.mq5                  # See changes
git add -A                         # Stage all
git commit -m "message"            # Commit
git push origin main               # Upload
```

### **Search Pine Script**
```bash
grep -n "leTrigger" ttt.txt        # Find line numbers
grep -A 5 "BUYOC" ttt.txt          # Show 5 lines after
grep -B 5 "condition :=" ttt.txt   # Show 5 lines before
```

### **File Locations (MT5 Windows)**
```
C:\Users\[Username]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\
├── Experts\HeikinAshiStrategyEA.mq5
├── Include\*.mqh
└── Indicators\HeikinAshiM90.mq5
```

---

## 🎯 Success Criteria

### **Code Quality:**
- ✅ 0 compilation errors
- ✅ 0 compilation warnings
- ✅ All const methods marked correctly
- ✅ All includes use relative paths
- ✅ Matches Pine Script logic 95%+

### **Functionality:**
- ✅ Custom indicator loads successfully
- ✅ HTF Heikin Ashi calculates correctly
- ✅ Crossover detection works
- ✅ Filters apply correctly
- ✅ State machine transitions match Pine Script
- ✅ Positions open on signals
- ✅ Positions reverse on opposite signals
- ✅ Partial TP executes (50%, 30%, 20%)
- ✅ SL protects positions

### **Testing:**
- ✅ Backtests run without errors
- ✅ Trades appear in Results tab
- ✅ Journal shows correct indicator loading
- ✅ Trade count is reasonable (not 0, not thousands)
- ✅ Profit/loss curve makes sense

---

## 📧 Contact & Resources

### **Documentation Files:**
- `README.md` - Installation guide
- `MQ5_BLUEPRINT_COMPLETE_ARCHITECTURE.md` - Full architecture
- `COMPLETE_SETTINGS_NEURAL_NETWORK_ANALYSIS.md` - Pine Script analysis
- `ttt.txt` - Pine Script source (2702 lines)

### **GitHub Repos:**
- Primary: https://github.com/beebobby-11/FN.git
- Windows: https://github.com/athens-21/FN.git

### **Pine Script Reference:**
- Lines 386-397: State machine transitions (CRITICAL!)
- Lines 131-132: Crossover logic
- Lines 119-140: HTF calculation
- Lines 185-200: Signal routing

---

## 🔐 Final Notes

**For AI Assistants working on Windows:**

1. **Always use Mac repo as source of truth** (beebobby-11/FN)
2. **Never modify ttt.txt** - it's the reference document
3. **Test every change** in Strategy Tester before committing
4. **Read Pine Script first** before implementing any logic
5. **Ask before making structural changes** to architecture
6. **Document all changes** with Pine Script line references
7. **Keep code readable** - others will work on this
8. **Follow naming conventions** - don't rename existing functions

**This EA implements a complex 5-layer neural network strategy. Small changes can have big impacts. When in doubt, refer to Pine Script source (ttt.txt) and ask for clarification.**

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-25  
**Project Status:** Phase 1 Complete, Ready for Phase 2 (Renko/Trailing/Options)  
**Primary Repo:** https://github.com/beebobby-11/FN.git (commit: 3e629de)
