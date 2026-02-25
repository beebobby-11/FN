# 🚀 Quick Start Guide for Windows

**สำหรับ AI Assistant บน Windows - อ่านนี้ก่อน!**

---

## ⚡ TL;DR - ข้อมูลสำคัญที่สุด

### 1. **ใช้ Mac Repo เป็นหลัก** ✅
```
https://github.com/beebobby-11/FN.git
```
Windows repo (athens-21/FN) **ล้าสมัย** ไม่มี critical fixes!

### 2. **Reverse Position Logic (CRITICAL!)**
```mql5
// ✅ ถูกต้อง
if(leTrigger && currentState <= 0.0) {  // เข้าได้ตั้งแต่ flat หรือ short
    if(currentState < 0.0) {
        CloseAllPositions();            // ปิด short ก่อน
    }
    OpenLongPosition();                 // เปิด long ใหม่
}

// ❌ ผิด (แบบเก่า)
if(g_stateManager.IsFlat()) {          // รอ flat เท่านั้น - ไม่ตรงกับ Pine Script!
    OpenLongPosition();
}
```

### 3. **Compilation Order**
```
1. Compile Indicator: Indicators\HeikinAshiM90.mq5 (F7)
2. Compile EA: HeikinAshiStrategyEA.mq5 (F7)
```

### 4. **Include Paths**
```mql5
#include "Include/StateManager.mqh"     // ✅ Relative path
#include <StateManager.mqh>             // ❌ Wrong!
```

### 5. **Indicator Path**
```mql5
iCustom(symbol, tf, "HeikinAshiM90", mult);  // ✅ ไม่มี Indicators\
iCustom(symbol, tf, "Indicators\\HeikinAshiM90", mult);  // ❌ ซ้ำ!
```

---

## 🪟 Installation (One-Command!)

### **Method 1: PowerShell Auto-Installer** ⚡ (Recommended)

```powershell
# Download repo
git clone https://github.com/beebobby-11/FN.git
cd FN

# Run installer (auto-detect MT5)
.\Install-MT5-EA-Auto.ps1
```

**What it does:**
- Auto-finds MT5 Data Folder
- Copies all files to correct locations
- Creates folders if needed
- Shows step-by-step next steps

### **Method 2: Manual Download**

1. Download: https://github.com/beebobby-11/FN/archive/refs/heads/main.zip
2. Extract ZIP
3. Find MT5: File → Open Data Folder → MQL5\
4. Copy files:
   - `HeikinAshiStrategyEA.mq5` → `MQL5\Experts\`
   - `Include\*.mqh` → `MQL5\Include\`
   - `Indicators\*.mq5` → `MQL5\Indicators\`

---

## 📂 File Structure

```
📁 MQL5/
├── 📁 Experts/
│   └── HeikinAshiStrategyEA.mq5        ← Main EA (532 lines)
├── 📁 Include/
│   ├── StateManager.mqh                 ← State machine
│   ├── HeikinAshiHTF.mqh               ← M90 calculator
│   ├── FilterManager.mqh                ← Filters
│   └── OrderManager.mqh                 ← Order execution
└── 📁 Indicators/
    └── HeikinAshiM90.mq5               ← Custom indicator (280 lines)
```

---

## 🎯 Testing Checklist

- [ ] Symbol: XAUUSDm (หรือ XAUUSD)
- [ ] Timeframe: **M5** (critical!)
- [ ] Period: 2024.01.01 - 2024.06.10
- [ ] Journal shows: `✓ Using custom Heikin Ashi M90 indicator`
- [ ] Trades are opening (not 0 trades!)
- [ ] Positions reverse on opposite signals

---

## 🔍 Common Issues

### Issue: Error [557] "program file read error"
**Fix:** 
1. Path ผิด - เช็ค `iCustom("HeikinAshiM90")` ไม่มี `Indicators\` prefix
2. ยังไม่ compile indicator - compile `HeikinAshiM90.mq5` ก่อน

### Issue: EA ไม่มีการซื้อขายเลย (0 trades)
**Fix:**
1. เช็คว่าใช้ reverse logic แล้วหรือยัง (`condition <= 0.0` not `IsFlat()`)
2. ดู Journal tab: `leTrigger: YES ✓` หรือ `NO`
3. เช็ค Filter: `PASS ✓` หรือ `BLOCKED ✗`
4. ตรวจสอบ timeframe: ต้อง **M5** เท่านั้น!

### Issue: "call non-const method for constant object"
**Fix:** เพิ่ม `const` ท้ายฟังก์ชัน:
```mql5
double GetCondition() const { return m_condition; }
```

---

## 📚 Full Documentation

อ่านเอกสารฉบับเต็ม: **PROJECT_RULES_AND_PROGRESS.md**

สำคัญมาก:
- Section: "CRITICAL RULES" 🚨
- Section: "Common Pitfalls" 🐛
- Section: "Pine Script Mapping Reference" 📚

---

## 🔗 Quick Links

- **Mac Repo (Latest):** https://github.com/beebobby-11/FN.git
- **Pine Script Source:** `ttt.txt` (2702 lines)
- **Critical Lines:** 386-387 (state transitions), 131-132 (crossover)

---

**Remember:** Pine Script is the source of truth. Always reference `ttt.txt` before making changes!

**Current Status:** Phase 1 Complete ✅ | Commit: 2b47074
