//+------------------------------------------------------------------+
//|                                               FilterManager.mqh  |
//|                                  Filter Selector & Logic         |
//|                                  7 filter types from Pine Script |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Filter Manager - Handles all filter types                       |
//| Supports: No Filtering, ATR, RSI, ATR or RSI, ATR and RSI,      |
//|           Sideways OR, Sideways AND                              |
//+------------------------------------------------------------------+
class CFilterManager
{
private:
   // Input parameters
   string            m_filterType;
   int               m_rsiPeriod;
   double            m_rsiTop;
   double            m_rsiBot;
   int               m_atrPeriod;
   int               m_atrMaPeriod;
   
   // Indicator handles
   int               m_rsiHandle;
   int               m_atrHandle;
   
   // Buffers
   double            m_rsiBuffer[];
   double            m_atrBuffer[];
   double            m_atrMaBuffer[];     // Calculated manually
   
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   
public:
   //--- Constructor
   CFilterManager(string symbol, ENUM_TIMEFRAMES timeframe);
   ~CFilterManager();
   
   //--- Initialize
   bool              Init(string filterType, int rsiPeriod, double rsiTop, double rsiBot,
                         int atrPeriod, int atrMaPeriod);
   void              Deinit();
   
   //--- Update buffers (call on every new bar)
   bool              Update();
   
   //--- Main filter logic (returns true if signal should pass)
   bool              IsFilterPass() const;
   
   //--- Debug
   void              PrintFilterStatus() const;
   string            GetFilterType() const { return m_filterType; }
   
private:
   //--- Individual filter implementations
   bool              FilterNone() const;
   bool              FilterATR() const;
   bool              FilterRSI() const;
   bool              FilterATRorRSI() const;
   bool              FilterATRandRSI() const;
   bool              FilterSidewaysOR() const;
   bool              FilterSidewaysAND() const;
   
   //--- Helper: Calculate ATR MA manually
   void              CalculateATRMA();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CFilterManager::CFilterManager(string symbol, ENUM_TIMEFRAMES timeframe)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_rsiHandle = INVALID_HANDLE;
   m_atrHandle = INVALID_HANDLE;
   
   ArraySetAsSeries(m_rsiBuffer, true);
   ArraySetAsSeries(m_atrBuffer, true);
   ArraySetAsSeries(m_atrMaBuffer, true);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CFilterManager::~CFilterManager()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool CFilterManager::Init(string filterType, int rsiPeriod, double rsiTop, double rsiBot,
                         int atrPeriod, int atrMaPeriod)
{
   m_filterType = filterType;
   m_rsiPeriod = rsiPeriod;
   m_rsiTop = rsiTop;
   m_rsiBot = rsiBot;
   m_atrPeriod = atrPeriod;
   m_atrMaPeriod = atrMaPeriod;
   
   Print("Initializing Filter Manager...");
   Print("Filter Type: ", m_filterType);
   
   // Create RSI indicator
   m_rsiHandle = iRSI(m_symbol, m_timeframe, m_rsiPeriod, PRICE_CLOSE);
   if(m_rsiHandle == INVALID_HANDLE)
   {
      Print("Error creating RSI indicator: ", GetLastError());
      return false;
   }
   Print("RSI(", m_rsiPeriod, ") initialized. Limits: ", m_rsiTop, " / ", m_rsiBot);
   
   // Create ATR indicator
   m_atrHandle = iATR(m_symbol, m_timeframe, m_atrPeriod);
   if(m_atrHandle == INVALID_HANDLE)
   {
      Print("Error creating ATR indicator: ", GetLastError());
      return false;
   }
   Print("ATR(", m_atrPeriod, ") initialized. MA Period: ", m_atrMaPeriod);
   
   // Initialize buffers
   ArrayResize(m_rsiBuffer, 10);
   ArrayResize(m_atrBuffer, 20);    // Need extra for MA calculation
   ArrayResize(m_atrMaBuffer, 10);
   
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void CFilterManager::Deinit()
{
   if(m_rsiHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_rsiHandle);
      m_rsiHandle = INVALID_HANDLE;
   }
   
   if(m_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(m_atrHandle);
      m_atrHandle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Update buffers                                                    |
//+------------------------------------------------------------------+
bool CFilterManager::Update()
{
   // Copy RSI values
   if(CopyBuffer(m_rsiHandle, 0, 0, 10, m_rsiBuffer) <= 0)
   {
      Print("Error copying RSI buffer: ", GetLastError());
      return false;
   }
   
   // Copy ATR values (need extra for MA)
   if(CopyBuffer(m_atrHandle, 0, 0, 20, m_atrBuffer) <= 0)
   {
      Print("Error copying ATR buffer: ", GetLastError());
      return false;
   }
   
   // Calculate ATR MA manually
   CalculateATRMA();
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate ATR Moving Average manually                           |
//+------------------------------------------------------------------+
void CFilterManager::CalculateATRMA()
{
   // Calculate simple moving average of ATR
   for(int i = 0; i < 10; i++)
   {
      double sum = 0.0;
      for(int j = 0; j < m_atrMaPeriod; j++)
      {
         sum += m_atrBuffer[i + j];
      }
      m_atrMaBuffer[i] = sum / m_atrMaPeriod;
   }
}

//+------------------------------------------------------------------+
//| Main Filter Logic - Route to appropriate filter                 |
//+------------------------------------------------------------------+
bool CFilterManager::IsFilterPass() const
{
   if(m_filterType == "No Filtering")
      return FilterNone();
   else if(m_filterType == "Filter with ATR")
      return FilterATR();
   else if(m_filterType == "Filter with RSI")
      return FilterRSI();
   else if(m_filterType == "ATR or RSI")
      return FilterATRorRSI();
   else if(m_filterType == "ATR and RSI")
      return FilterATRandRSI();
   else if(m_filterType == "Sideways OR")
      return FilterSidewaysOR();
   else if(m_filterType == "Sideways AND")
      return FilterSidewaysAND();
   
   // Default: no filtering
   Print("Warning: Unknown filter type '", m_filterType, "'. Using No Filtering.");
   return true;
}

//+------------------------------------------------------------------+
//| Filter: No Filtering (always pass)                              |
//+------------------------------------------------------------------+
bool CFilterManager::FilterNone() const
{
   return true;
}

//+------------------------------------------------------------------+
//| Filter: ATR (pass if ATR >= ATR MA)                             |
//+------------------------------------------------------------------+
bool CFilterManager::FilterATR() const
{
   // Check completed bar (index 1)
   bool pass = (m_atrBuffer[1] >= m_atrMaBuffer[1]);
   return pass;
}

//+------------------------------------------------------------------+
//| Filter: RSI (pass if RSI > Top OR RSI < Bot)                    |
//+------------------------------------------------------------------+
bool CFilterManager::FilterRSI() const
{
   // Check completed bar (index 1)
   double rsi = m_rsiBuffer[1];
   bool pass = (rsi > m_rsiTop || rsi < m_rsiBot);
   return pass;
}

//+------------------------------------------------------------------+
//| Filter: ATR or RSI (pass if either condition met)               |
//+------------------------------------------------------------------+
bool CFilterManager::FilterATRorRSI() const
{
   return (FilterATR() || FilterRSI());
}

//+------------------------------------------------------------------+
//| Filter: ATR and RSI (pass if both conditions met)               |
//+------------------------------------------------------------------+
bool CFilterManager::FilterATRandRSI() const
{
   return (FilterATR() && FilterRSI());
}

//+------------------------------------------------------------------+
//| Filter: Sideways OR (pass if ATR low OR RSI in middle)          |
//+------------------------------------------------------------------+
bool CFilterManager::FilterSidewaysOR() const
{
   // Inverse of regular filters
   // Pass if market is sideways (low volatility)
   bool atr_sideways = !FilterATR();      // ATR < ATR_MA
   bool rsi_sideways = !FilterRSI();      // RSI between limits
   
   return (atr_sideways || rsi_sideways);
}

//+------------------------------------------------------------------+
//| Filter: Sideways AND (pass if both indicate sideways)           |
//+------------------------------------------------------------------+
bool CFilterManager::FilterSidewaysAND() const
{
   bool atr_sideways = !FilterATR();
   bool rsi_sideways = !FilterRSI();
   
   return (atr_sideways && rsi_sideways);
}

//+------------------------------------------------------------------+
//| Print filter status (debug)                                     |
//+------------------------------------------------------------------+
void CFilterManager::PrintFilterStatus() const
{
   Print("─────── Filter Status ───────");
   Print("Filter Type: ", m_filterType);
   Print("RSI[1]: ", DoubleToString(m_rsiBuffer[1], 2), 
         " (Limits: ", m_rsiTop, " / ", m_rsiBot, ")");
   Print("ATR[1]: ", DoubleToString(m_atrBuffer[1], _Digits + 1));
   Print("ATR MA[1]: ", DoubleToString(m_atrMaBuffer[1], _Digits + 1));
   Print("ATR > ATR_MA: ", (m_atrBuffer[1] >= m_atrMaBuffer[1] ? "YES" : "NO"));
   Print("RSI Extreme: ", (m_rsiBuffer[1] > m_rsiTop || m_rsiBuffer[1] < m_rsiBot ? "YES" : "NO"));
   Print("Filter Pass: ", (IsFilterPass() ? "YES ✓" : "NO ✗"));
   Print("────────────────────────────");
}
//+------------------------------------------------------------------+
