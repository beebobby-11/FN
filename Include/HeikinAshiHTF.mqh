//+------------------------------------------------------------------+
//|                                              HeikinAshiHTF.mqh   |
//|                                  Higher Timeframe HA Handler     |
//|                                  M5 × 18 = M90 calculation       |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Heikin Ashi Higher Timeframe Handler                             |
//| Handles M90 (M5 × 18) Heikin Ashi calculation                   |
//+------------------------------------------------------------------+
class CHeikinAshiHTF
{
private:
   string            m_symbol;              // Symbol
   ENUM_TIMEFRAMES   m_base_tf;             // Base timeframe (M5)
   int               m_multiplier;          // HTF multiplier (18)
   
   // Heikin Ashi buffers
   double            m_ha_close[];          // HA Close buffer
   double            m_ha_open[];           // HA Open buffer
   double            m_ha_high[];           // HA High buffer
   double            m_ha_low[];            // HA Low buffer
   
   // Custom indicator handle (if using custom indicator)
   int               m_custom_handle;
   bool              m_use_custom_indicator;
   
   // For manual calculation
   datetime          m_last_calc_time;
   
public:
   //--- Constructor
   CHeikinAshiHTF(string symbol, ENUM_TIMEFRAMES base_tf, int multiplier);
   ~CHeikinAshiHTF();
   
   //--- Initialize
   bool              Init();
   void              Deinit();
   
   //--- Update buffers (call on every new bar)
   bool              Update();
   
   //--- Get values (index 1 = completed bar, index 2 = previous bar)
   double            GetClose(int index) const;
   double            GetOpen(int index) const;
   double            GetHigh(int index) const;
   double            GetLow(int index) const;
   
   //--- Crossover detection
   bool              IsBullishCross() const;
   bool              IsBearishCross() const;
   
   //--- Debug
   void              PrintValues() const;
   
private:
   //--- Manual calculation methods
   bool              CalculateManually();
   void              CalculateHABar(int htf_bar_index, const MqlRates &rates[], 
                                   double &ha_close, double &ha_open, 
                                   double &ha_high, double &ha_low);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CHeikinAshiHTF::CHeikinAshiHTF(string symbol, ENUM_TIMEFRAMES base_tf, int multiplier)
{
   m_symbol = symbol;
   m_base_tf = base_tf;
   m_multiplier = multiplier;
   m_custom_handle = INVALID_HANDLE;
   m_use_custom_indicator = false;
   m_last_calc_time = 0;
   
   ArraySetAsSeries(m_ha_close, true);
   ArraySetAsSeries(m_ha_open, true);
   ArraySetAsSeries(m_ha_high, true);
   ArraySetAsSeries(m_ha_low, true);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CHeikinAshiHTF::~CHeikinAshiHTF()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize indicator                                             |
//+------------------------------------------------------------------+
bool CHeikinAshiHTF::Init()
{
   Print("Initializing Heikin Ashi HTF Handler...");
   Print("Symbol: ", m_symbol);
   Print("Base TF: ", EnumToString(m_base_tf));
   Print("Multiplier: ", m_multiplier, " (", m_multiplier * PeriodSeconds(m_base_tf) / 60, " minutes)");
   
   // Try to load custom indicator first
   m_custom_handle = iCustom(m_symbol, m_base_tf, "Indicators\\HeikinAshiM90", m_multiplier);
   
   if(m_custom_handle != INVALID_HANDLE)
   {
      m_use_custom_indicator = true;
      Print("✓ Using custom Heikin Ashi M90 indicator (handle: ", m_custom_handle, ")");
      
      // Initialize buffers for custom indicator
      ArrayResize(m_ha_close, 3);
      ArrayResize(m_ha_open, 3);
      ArrayResize(m_ha_high, 3);
      ArrayResize(m_ha_low, 3);
      
      return true;
   }
   
   // Fallback to manual calculation if custom indicator not found
   m_use_custom_indicator = false;
   Print("⚠ Custom indicator not found, using manual Heikin Ashi calculation");
   
   // Initialize buffers
   ArrayResize(m_ha_close, 3);
   ArrayResize(m_ha_open, 3);
   ArrayResize(m_ha_high, 3);
   ArrayResize(m_ha_low, 3);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CHeikinAshiHTF::Deinit()
{
   if(m_custom_handle != INVALID_HANDLE)
   {
      IndicatorRelease(m_custom_handle);
      m_custom_handle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Update buffers                                                    |
//+------------------------------------------------------------------+
bool CHeikinAshiHTF::Update()
{
   if(m_use_custom_indicator)
   {
      // Copy from custom indicator
      // Buffer order in HeikinAshiM90.mq5:
      // 0 = HA_Open, 1 = HA_High, 2 = HA_Low, 3 = HA_Close
      if(CopyBuffer(m_custom_handle, 0, 0, 3, m_ha_open) <= 0)
      {
         Print("Error copying HA_Open buffer: ", GetLastError());
         return false;
      }
      if(CopyBuffer(m_custom_handle, 1, 0, 3, m_ha_high) <= 0)
      {
         Print("Error copying HA_High buffer: ", GetLastError());
         return false;
      }
      if(CopyBuffer(m_custom_handle, 2, 0, 3, m_ha_low) <= 0)
      {
         Print("Error copying HA_Low buffer: ", GetLastError());
         return false;
      }
      if(CopyBuffer(m_custom_handle, 3, 0, 3, m_ha_close) <= 0)
      {
         Print("Error copying HA_Close buffer: ", GetLastError());
         return false;
      }
      
      ArraySetAsSeries(m_ha_open, true);
      ArraySetAsSeries(m_ha_high, true);
      ArraySetAsSeries(m_ha_low, true);
      ArraySetAsSeries(m_ha_close, true);
      
      return true;
   }
   else
   {
      // Manual calculation
      return CalculateManually();
   }
}

//+------------------------------------------------------------------+
//| Calculate Heikin Ashi manually for HTF                          |
//+------------------------------------------------------------------+
bool CHeikinAshiHTF::CalculateManually()
{
   // Get enough bars for 3 HTF bars
   int bars_needed = m_multiplier * 3;
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(m_symbol, m_base_tf, 0, bars_needed, rates) < bars_needed)
   {
      Print("Error copying rates for HA calculation: ", GetLastError());
      return false;
   }
   
   // Calculate 3 HTF bars (current, previous, before previous)
   // HTF Bar 0 (current): M5 bars 0-17
   // HTF Bar 1 (previous): M5 bars 18-35
   // HTF Bar 2 (before previous): M5 bars 36-53
   
   for(int htf_bar = 0; htf_bar < 3; htf_bar++)
   {
      CalculateHABar(htf_bar, rates, 
                     m_ha_close[htf_bar], 
                     m_ha_open[htf_bar], 
                     m_ha_high[htf_bar], 
                     m_ha_low[htf_bar]);
   }
   
   m_last_calc_time = TimeCurrent();
   return true;
}

//+------------------------------------------------------------------+
//| Calculate single HTF Heikin Ashi bar                            |
//+------------------------------------------------------------------+
void CHeikinAshiHTF::CalculateHABar(int htf_bar_index, const MqlRates &rates[], 
                                   double &ha_close, double &ha_open, 
                                   double &ha_high, double &ha_low)
{
   int start_index = htf_bar_index * m_multiplier;
   int end_index = start_index + m_multiplier - 1;
   
   // Get OHLC for HTF bar by aggregating base TF bars
   double htf_open = rates[end_index].open;     // Open of first bar in range
   double htf_close = rates[start_index].close; // Close of last bar in range
   double htf_high = rates[end_index].high;
   double htf_low = rates[end_index].low;
   
   // Find highest high and lowest low in range
   for(int i = start_index; i <= end_index && i < ArraySize(rates); i++)
   {
      if(rates[i].high > htf_high) htf_high = rates[i].high;
      if(rates[i].low < htf_low) htf_low = rates[i].low;
   }
   
   // Calculate Heikin Ashi values
   // HA Close = (O + H + L + C) / 4
   ha_close = (htf_open + htf_high + htf_low + htf_close) / 4.0;
   
   // HA Open = (Previous HA Open + Previous HA Close) / 2
   if(htf_bar_index == 2)  // First bar (oldest)
   {
      // For first bar, use regular open-close average as approximation
      ha_open = (htf_open + htf_close) / 2.0;
   }
   else
   {
      // Use previous HA values
      int prev_index = htf_bar_index + 1;
      if(prev_index < 3)
         ha_open = (m_ha_open[prev_index] + m_ha_close[prev_index]) / 2.0;
      else
         ha_open = (htf_open + htf_close) / 2.0;
   }
   
   // HA High = max(H, HA Open, HA Close)
   ha_high = MathMax(htf_high, MathMax(ha_open, ha_close));
   
   // HA Low = min(L, HA Open, HA Close)
   ha_low = MathMin(htf_low, MathMin(ha_open, ha_close));
}

//+------------------------------------------------------------------+
//| Get HA Close value                                               |
//+------------------------------------------------------------------+
double CHeikinAshiHTF::GetClose(int index) const
{
   if(index < 0 || index >= ArraySize(m_ha_close))
      return 0.0;
   return m_ha_close[index];
}

//+------------------------------------------------------------------+
//| Get HA Open value                                                |
//+------------------------------------------------------------------+
double CHeikinAshiHTF::GetOpen(int index) const
{
   if(index < 0 || index >= ArraySize(m_ha_open))
      return 0.0;
   return m_ha_open[index];
}

//+------------------------------------------------------------------+
//| Get HA High value                                                |
//+------------------------------------------------------------------+
double CHeikinAshiHTF::GetHigh(int index) const
{
   if(index < 0 || index >= ArraySize(m_ha_high))
      return 0.0;
   return m_ha_high[index];
}

//+------------------------------------------------------------------+
//| Get HA Low value                                                 |
//+------------------------------------------------------------------+
double CHeikinAshiHTF::GetLow(int index) const
{
   if(index < 0 || index >= ArraySize(m_ha_low))
      return 0.0;
   return m_ha_low[index];
}

//+------------------------------------------------------------------+
//| Detect Bullish Crossover                                         |
//| Previous: HA_close <= HA_open (bearish/neutral)                 |
//| Current:  HA_close > HA_open (bullish)                          |
//+------------------------------------------------------------------+
bool CHeikinAshiHTF::IsBullishCross() const
{
   if(ArraySize(m_ha_close) < 2 || ArraySize(m_ha_open) < 2)
      return false;
   
   // Index 1 = completed bar (current)
   // Index 2 = previous bar
   bool prev_bearish = (m_ha_close[2] <= m_ha_open[2]);
   bool curr_bullish = (m_ha_close[1] > m_ha_open[1]);
   
   return prev_bearish && curr_bullish;
}

//+------------------------------------------------------------------+
//| Detect Bearish Crossover                                         |
//| Previous: HA_close >= HA_open (bullish/neutral)                 |
//| Current:  HA_close < HA_open (bearish)                          |
//+------------------------------------------------------------------+
bool CHeikinAshiHTF::IsBearishCross() const
{
   if(ArraySize(m_ha_close) < 2 || ArraySize(m_ha_open) < 2)
      return false;
   
   bool prev_bullish = (m_ha_close[2] >= m_ha_open[2]);
   bool curr_bearish = (m_ha_close[1] < m_ha_open[1]);
   
   return prev_bullish && curr_bearish;
}

//+------------------------------------------------------------------+
//| Print HA values (debug)                                         |
//+------------------------------------------------------------------+
void CHeikinAshiHTF::PrintValues() const
{
   Print("─────── Heikin Ashi HTF Values ───────");
   Print("Completed Bar (Index 1):");
   Print("  HA Close: ", DoubleToString(m_ha_close[1], _Digits));
   Print("  HA Open:  ", DoubleToString(m_ha_open[1], _Digits));
   Print("  HA High:  ", DoubleToString(m_ha_high[1], _Digits));
   Print("  HA Low:   ", DoubleToString(m_ha_low[1], _Digits));
   Print("  Status:   ", (m_ha_close[1] > m_ha_open[1] ? "BULLISH" : "BEARISH"));
   
   Print("Previous Bar (Index 2):");
   Print("  HA Close: ", DoubleToString(m_ha_close[2], _Digits));
   Print("  HA Open:  ", DoubleToString(m_ha_open[2], _Digits));
   Print("  Status:   ", (m_ha_close[2] > m_ha_open[2] ? "BULLISH" : "BEARISH"));
   
   Print("Crossover Detection:");
   Print("  Bullish Cross: ", (IsBullishCross() ? "YES ✓" : "NO"));
   Print("  Bearish Cross: ", (IsBearishCross() ? "YES ✓" : "NO"));
   Print("──────────────────────────────────────");
}
//+------------------------------------------------------------------+
