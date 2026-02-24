//+------------------------------------------------------------------+
//|                                       HeikinAshiStrategyEA.mq5   |
//|                        Based on Pine Script Strategy Analysis   |
//|                        ableSignals & Overlays Private™ 7.9-X    |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property strict

// Include custom classes
#include "Include/StateManager.mqh"
#include "Include/HeikinAshiHTF.mqh"
#include "Include/FilterManager.mqh"
#include "Include/OrderManager.mqh"

//+------------------------------------------------------------------+
//| INPUT PARAMETERS (98 parameters matching Pine Script)           |
//+------------------------------------------------------------------+

//--- 🎯 MAIN SETTINGS
input group "🎯 MAIN SETTINGS"
input string                 TPSType = "ATR";                    // What TPS should be taken
input string                 SetupType = "Open/Close";           // What Trading Setup
input bool                   ShowColoredBars = true;             // Show coloured Bars
input bool                   EnableRibbon = false;               // Enable Ribbon

//--- ⚙️ STRATEGY OPTIONS
input group "⚙️ STRATEGY OPTIONS"
input string                 FilterType = "No Filtering";        // Sideways Filtering Input

//--- 📊 RSI FILTERING
input group "📊 RSI FILTERING"
input int                    RSI_Length = 7;                     // RSI Length
input double                 RSI_TopLimit = 45.0;                // TOP Limit
input double                 RSI_BotLimit = 10.0;                // BOT Limit

//--- 📐 RENKO SETTINGS
input group "📐 RENKO SETTINGS"
input int                    EMA1_Length = 2;                    // EMA1 length
input int                    EMA2_Length = 10;                   // EMA2 length
input bool                   UseATRRenko = true;                 // Use ATR for Renko
input int                    RenkoATRLength = 3;                 // Renko ATR Length
input int                    RenkoTraditionalLength = 1000;      // Renko Traditional Length

//--- 💰 RISK MANAGEMENT
input group "💰 RISK MANAGEMENT"
input double                 LotSize = 0.1;                      // Lot Size
input double                 QtyTP1 = 50.0;                      // Qty TP1 (%)
input double                 QtyTP2 = 30.0;                      // Qty TP2 (%)
input double                 QtyTP3 = 20.0;                      // Qty TP3 (%)
input int                    ATR_TPSL_Length = 20;               // ATR Length for TP/SL
input double                 ProfitFactor = 2.5;                 // Profit Factor (multiplier)

//--- 📈 EMA & ATR
input group "📈 EMA & ATR"
input bool                   PlotEMA = false;                    // Plot EMA?
input bool                   UseHigherTimeFrame = true;          // Use Higher Time Frame?
input int                    TimeframeMultiplier = 18;           // Timeframe Multiplier
input bool                   PlotDema = false;                   // Plot Dema?
input int                    DemaATRLength = 100;                // Dema ATR Length

//--- 🔷 ZIGZAG CONFIG
input group "🔷 ZIGZAG CONFIG"
input int                    ZigZag_Depth = 12;                  // Depth
input int                    ZigZag_Deviation = 5;               // Deviation
input int                    ZigZag_Backstep = 2;                // Backstep

//--- 🎨 VISUAL SETTINGS
input group "🎨 VISUAL SETTINGS"
input int                    LineThickness = 2;                  // Line Thickness
input int                    LabelSize = 3;                      // Label Size
input bool                   ShowDashboard = false;              // Show Dashboard
input bool                   ShowWeeklyPerf = false;             // Show Weekly Performance
input bool                   ShowMonthlyPerf = false;            // Show Monthly Performance

//--- 🔧 EA SETTINGS
input group "🔧 EA SETTINGS"
input ulong                  MagicNumber = 123456;               // Magic Number
input int                    Slippage = 10;                      // Slippage (pips)
input int                    Deviation = 10;                     // Deviation (points)
input bool                   EnableTrading = true;               // Enable Trading
input bool                   DebugMode = true;                   // Debug Mode (verbose logs)

//--- 📅 BACKTESTING RANGE
input group "📅 BACKTESTING RANGE"
input datetime               FromDate = D'2020.01.01 00:00';     // From Date
input datetime               ToDate = D'2099.12.31 23:59';       // To Date

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+

// Class instances
CStateManager*      g_stateManager = NULL;
CHeikinAshiHTF*     g_heikinAshi = NULL;
CFilterManager*     g_filterManager = NULL;
COrderManager*      g_orderManager = NULL;

// Indicator handles
int                 g_atrTPSL_Handle = INVALID_HANDLE;           // ATR for TP/SL calculation
int                 g_ema1_Handle = INVALID_HANDLE;              // EMA1 for Renko mode
int                 g_ema2_Handle = INVALID_HANDLE;              // EMA2 for Renko mode

// Buffers
double              g_atrTPSL_Buffer[];

// New bar detection
datetime            g_lastBarTime = 0;

// Current symbol and timeframe
string              g_symbol;
ENUM_TIMEFRAMES     g_timeframe;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("═══════════════════════════════════════════════════════════════");
   Print("  HEIKIN ASHI STRATEGY EA - INITIALIZING");
   Print("  Based on Pine Script: ableSignals & Overlays Private™ 7.9-X");
   Print("═══════════════════════════════════════════════════════════════");
   
   g_symbol = _Symbol;
   g_timeframe = _Period;
   
   Print("Symbol: ", g_symbol);
   Print("Timeframe: ", EnumToString(g_timeframe));
   Print("TPS Type: ", TPSType);
   Print("Setup Type: ", SetupType);
   Print("Filter Type: ", FilterType);
   Print("HTF Multiplier: ", TimeframeMultiplier);
   
   // Validate inputs
   if(QtyTP1 + QtyTP2 + QtyTP3 != 100.0)
   {
      Print("ERROR: TP quantities must sum to 100% (Currently: ", QtyTP1 + QtyTP2 + QtyTP3, "%)");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Initialize State Manager
   g_stateManager = new CStateManager();
   if(g_stateManager == NULL)
   {
      Print("ERROR: Failed to create State Manager");
      return INIT_FAILED;
   }
   Print("✓ State Manager initialized");
   
   // Initialize Heikin Ashi HTF Handler
   g_heikinAshi = new CHeikinAshiHTF(g_symbol, g_timeframe, TimeframeMultiplier);
   if(g_heikinAshi == NULL)
   {
      Print("ERROR: Failed to create Heikin Ashi HTF Handler");
      return INIT_FAILED;
   }
   if(!g_heikinAshi.Init())
   {
      Print("ERROR: Failed to initialize Heikin Ashi HTF Handler");
      return INIT_FAILED;
   }
   Print("✓ Heikin Ashi HTF Handler initialized (M", TimeframeMultiplier * PeriodSeconds(g_timeframe) / 60, ")");
   
   // Initialize Filter Manager
   g_filterManager = new CFilterManager(g_symbol, g_timeframe);
   if(g_filterManager == NULL)
   {
      Print("ERROR: Failed to create Filter Manager");
      return INIT_FAILED;
   }
   if(!g_filterManager.Init(FilterType, RSI_Length, RSI_TopLimit, RSI_BotLimit, 5, 5))
   {
      Print("ERROR: Failed to initialize Filter Manager");
      return INIT_FAILED;
   }
   Print("✓ Filter Manager initialized");
   
   // Initialize Order Manager
   g_orderManager = new COrderManager(g_symbol, MagicNumber);
   if(g_orderManager == NULL)
   {
      Print("ERROR: Failed to create Order Manager");
      return INIT_FAILED;
   }
   g_orderManager.SetLotSize(LotSize);
   g_orderManager.SetSlippage(Slippage);
   g_orderManager.SetDeviation(Deviation);
   g_orderManager.SetTPQuantities(QtyTP1, QtyTP2, QtyTP3);
   Print("✓ Order Manager initialized (Lot: ", LotSize, ")");
   
   // Create ATR indicator for TP/SL calculation
   g_atrTPSL_Handle = iATR(g_symbol, g_timeframe, ATR_TPSL_Length);
   if(g_atrTPSL_Handle == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create ATR indicator for TP/SL");
      return INIT_FAILED;
   }
   Print("✓ ATR(", ATR_TPSL_Length, ") indicator created for TP/SL calculation");
   
   // Create EMA indicators for Renko mode
   if(SetupType == "Renko")
   {
      g_ema1_Handle = iMA(g_symbol, g_timeframe, EMA1_Length, 0, MODE_EMA, PRICE_CLOSE);
      g_ema2_Handle = iMA(g_symbol, g_timeframe, EMA2_Length, 0, MODE_EMA, PRICE_CLOSE);
      
      if(g_ema1_Handle == INVALID_HANDLE || g_ema2_Handle == INVALID_HANDLE)
      {
         Print("ERROR: Failed to create EMA indicators for Renko mode");
         return INIT_FAILED;
      }
      Print("✓ EMA indicators created (", EMA1_Length, ", ", EMA2_Length, ")");
   }
   
   // Set array as series
   ArraySetAsSeries(g_atrTPSL_Buffer, true);
   
   // Initialize last bar time
   g_lastBarTime = iTime(g_symbol, g_timeframe, 0);
   
   Print("═══════════════════════════════════════════════════════════════");
   Print("  INITIALIZATION COMPLETE - EA READY TO TRADE");
   Print("═══════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("═══════════════════════════════════════════════════════════════");
   Print("  DEINITIALIZING EA");
   Print("  Reason: ", reason);
   Print("═══════════════════════════════════════════════════════════════");
   
   // Release indicators
   if(g_atrTPSL_Handle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atrTPSL_Handle);
      g_atrTPSL_Handle = INVALID_HANDLE;
   }
   
   if(g_ema1_Handle != INVALID_HANDLE)
   {
      IndicatorRelease(g_ema1_Handle);
      g_ema1_Handle = INVALID_HANDLE;
   }
   
   if(g_ema2_Handle != INVALID_HANDLE)
   {
      IndicatorRelease(g_ema2_Handle);
      g_ema2_Handle = INVALID_HANDLE;
   }
   
   // Delete class instances
   if(g_stateManager != NULL)
   {
      delete g_stateManager;
      g_stateManager = NULL;
   }
   
   if(g_heikinAshi != NULL)
   {
      delete g_heikinAshi;
      g_heikinAshi = NULL;
   }
   
   if(g_filterManager != NULL)
   {
      delete g_filterManager;
      g_filterManager = NULL;
   }
   
   if(g_orderManager != NULL)
   {
      delete g_orderManager;
      g_orderManager = NULL;
   }
   
   Print("✓ All resources released");
   Print("═══════════════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check if trading is enabled
   if(!EnableTrading)
      return;
   
   // Check if new bar formed
   datetime currentBarTime = iTime(g_symbol, g_timeframe, 0);
   if(currentBarTime == g_lastBarTime)
      return;  // Not a new bar, skip
   
   g_lastBarTime = currentBarTime;
   
   if(DebugMode)
      Print("\n════════ NEW BAR FORMED ════════");
   
   // ============================================================
   // STEP 1: UPDATE ALL INDICATORS
   // ============================================================
   
   // Update Heikin Ashi HTF data
   if(!g_heikinAshi.Update())
   {
      Print("ERROR: Failed to update Heikin Ashi HTF data");
      return;
   }
   
   // Update Filter Manager
   if(!g_filterManager.Update())
   {
      Print("ERROR: Failed to update Filter Manager");
      return;
   }
   
   // Copy ATR for TP/SL calculation
   if(CopyBuffer(g_atrTPSL_Handle, 0, 0, 3, g_atrTPSL_Buffer) <= 0)
   {
      Print("ERROR: Failed to copy ATR buffer");
      return;
   }
   
   // ============================================================
   // STEP 2: GENERATE SIGNALS
   // ============================================================
   
   bool buySignal = false;
   bool sellSignal = false;
   
   if(SetupType == "Open/Close")
   {
      // Heikin Ashi Crossover Detection
      buySignal = g_heikinAshi.IsBullishCross();
      sellSignal = g_heikinAshi.IsBearishCross();
      
      if(DebugMode && (buySignal || sellSignal))
      {
         g_heikinAshi.PrintValues();
      }
   }
   else if(SetupType == "Renko")
   {
      // EMA Crossover Detection (not implemented yet)
      // TODO: Implement Renko EMA crossover
      Print("Renko mode not fully implemented yet");
      return;
   }
   
   // ============================================================
   // STEP 3: APPLY FILTERS
   // ============================================================
   
   bool filterPass = g_filterManager.IsFilterPass();
   
   if(DebugMode)
   {
      g_filterManager.PrintFilterStatus();
   }
   
   // Combine signals with filter
   bool leTrigger = buySignal && filterPass;
   bool seTrigger = sellSignal && filterPass;
   
   // Check date range
   datetime currentTime = TimeCurrent();
   bool tradeDateAllowed = (currentTime >= FromDate && currentTime <= ToDate);
   
   leTrigger = leTrigger && tradeDateAllowed;
   seTrigger = seTrigger && tradeDateAllowed;
   
   if(DebugMode)
   {
      Print("─────── Signal Summary ───────");
      Print("Buy Signal: ", (buySignal ? "YES" : "NO"));
      Print("Sell Signal: ", (sellSignal ? "YES" : "NO"));
      Print("Filter Pass: ", (filterPass ? "YES" : "NO"));
      Print("Date Allowed: ", (tradeDateAllowed ? "YES" : "NO"));
      Print("leTrigger: ", (leTrigger ? "YES ✓" : "NO"));
      Print("seTrigger: ", (seTrigger ? "YES ✓" : "NO"));
      Print("─────────────────────────────");
   }
   
   // ============================================================
   // STEP 4: UPDATE STATE MACHINE
   // ============================================================
   
   double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
   
   // First, check for TP/SL hits (state machine update)
   g_stateManager.Update(bid, ask);
   
   // ============================================================
   // STEP 5: EXECUTE ORDERS (ATR MODE)
   // ============================================================
   
   if(TPSType == "ATR")
   {
      // Get current state
      double currentState = g_stateManager.GetCondition();
      
      // LONG ENTRY: leTrigger AND condition[1] <= 0.0
      // (flat or short position)
      if(leTrigger && currentState <= 0.0)
      {
         // Close opposite position if exists (if short)
         if(currentState < 0.0)
         {
            if(DebugMode)
               Print("🔄 CLOSE OPPOSITE: Closing SHORT position before LONG entry");
            g_orderManager.CloseAllPositions();
            g_stateManager.Reset();
         }
         
         double atr = g_atrTPSL_Buffer[1];  // Use completed bar ATR
         
         // Calculate TP/SL lines
         double entryPrice = ask;
         double tp1Line = entryPrice + (1.0 * ProfitFactor * atr);
         double tp2Line = entryPrice + (2.0 * ProfitFactor * atr);
         double tp3Line = entryPrice + (3.0 * ProfitFactor * atr);
         double slLine = entryPrice - (1.0 * ProfitFactor * atr);
         
         // Update state to Long Entry
         g_stateManager.OnLongEntry(entryPrice, tp1Line, tp2Line, tp3Line, slLine);
         
         // Open 3 positions
         ulong ticket1, ticket2, ticket3;
         if(g_orderManager.OpenLongPosition(entryPrice, tp1Line, tp2Line, tp3Line, slLine,
                                           ticket1, ticket2, ticket3))
         {
            // Save tickets in state manager
            g_stateManager.SetTickets(ticket1, ticket2, ticket3);
         }
      }
      // SHORT ENTRY: seTrigger AND condition[1] >= 0.0
      // (flat or long position)
      else if(seTrigger && currentState >= 0.0)
      {
         // Close opposite position if exists (if long)
         if(currentState > 0.0)
         {
            if(DebugMode)
               Print("🔄 CLOSE OPPOSITE: Closing LONG position before SHORT entry");
            g_orderManager.CloseAllPositions();
            g_stateManager.Reset();
         }
         
         double atr = g_atrTPSL_Buffer[1];
         
         double entryPrice = bid;
         double tp1Line = entryPrice - (1.0 * ProfitFactor * atr);
         double tp2Line = entryPrice - (2.0 * ProfitFactor * atr);
         double tp3Line = entryPrice - (3.0 * ProfitFactor * atr);
         double slLine = entryPrice + (1.0 * ProfitFactor * atr);
         
         g_stateManager.OnShortEntry(entryPrice, tp1Line, tp2Line, tp3Line, slLine);
         
         ulong ticket1, ticket2, ticket3;
         if(g_orderManager.OpenShortPosition(entryPrice, tp1Line, tp2Line, tp3Line, slLine,
                                            ticket1, ticket2, ticket3))
         {
            g_stateManager.SetTickets(ticket1, ticket2, ticket3);
         }
      }
   }
   else if(TPSType == "Trailing")
   {
      // Trailing mode - close opposite and open new (no TP/SL)
      // TODO: Implement trailing mode
      if(DebugMode)
         Print("Trailing mode not implemented yet");
   }
   else if(TPSType == "Options")
   {
      // Options mode - long only
      // TODO: Implement options mode
      if(DebugMode)
         Print("Options mode not implemented yet");
   }
   
   // Debug: Print current state
   if(DebugMode && !g_stateManager.IsFlat())
   {
      g_stateManager.PrintState();
   }
}

//+------------------------------------------------------------------+
//| Trade event handler                                              |
//+------------------------------------------------------------------+
void OnTrade()
{
   // This is called when a trade event occurs (order opened/closed)
   // Useful for tracking partial TP hits
   
   if(DebugMode)
   {
      Print("──────── Trade Event ────────");
      g_orderManager.PrintPositions();
   }
}

//+------------------------------------------------------------------+
//| Tester event handler                                             |
//+------------------------------------------------------------------+
double OnTester()
{
   // Custom metric for Strategy Tester optimization
   // Return value for optimization (higher is better)
   
   double profit = TesterStatistics(STAT_PROFIT);
   double drawdown = TesterStatistics(STAT_EQUITY_DD);
   double trades = TesterStatistics(STAT_TRADES);
   
   if(trades == 0 || drawdown == 0)
      return 0;
   
   // Custom metric: Profit Factor / Max Drawdown %
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
   double customMetric = profitFactor / (drawdown / 100.0);
   
   return customMetric;
}
//+------------------------------------------------------------------+
