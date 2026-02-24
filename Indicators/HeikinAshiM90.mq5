//+------------------------------------------------------------------+
//|                                               HeikinAshiM90.mq5  |
//|                          Higher Timeframe Heikin Ashi Indicator  |
//|                              M90 = M5 × 18 bars (customizable)   |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1

//--- Plot as candlesticks
#property indicator_label1  "Heikin Ashi M90"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrLimeGreen, clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input int      HTF_Multiplier = 18;      // HTF Multiplier (M5 × 18 = M90)
input color    BullishColor = clrLimeGreen;   // Bullish candle color
input color    BearishColor = clrRed;         // Bearish candle color

//+------------------------------------------------------------------+
//| Indicator Buffers                                                |
//+------------------------------------------------------------------+
double   HA_OpenBuffer[];      // Heikin Ashi Open
double   HA_HighBuffer[];      // Heikin Ashi High
double   HA_LowBuffer[];       // Heikin Ashi Low
double   HA_CloseBuffer[];     // Heikin Ashi Close
double   ColorBuffer[];        // Color index buffer

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int      g_htf_period;         // HTF period in minutes
datetime g_last_htf_time;      // Last HTF bar time
double   g_prev_ha_open;       // Previous HA Open for calculation
double   g_prev_ha_close;      // Previous HA Close for calculation

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Indicator buffers mapping
   SetIndexBuffer(0, HA_OpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HA_HighBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HA_LowBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, HA_CloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, ColorBuffer, INDICATOR_COLOR_INDEX);
   
   //--- Set buffer properties
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, BullishColor);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, BearishColor);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   
   //--- Set arrays as series
   ArraySetAsSeries(HA_OpenBuffer, true);
   ArraySetAsSeries(HA_HighBuffer, true);
   ArraySetAsSeries(HA_LowBuffer, true);
   ArraySetAsSeries(HA_CloseBuffer, true);
   ArraySetAsSeries(ColorBuffer, true);
   
   //--- Calculate HTF period
   g_htf_period = HTF_Multiplier * PeriodSeconds(PERIOD_CURRENT) / 60;
   
   //--- Set indicator short name
   string short_name = StringFormat("Heikin Ashi M%d (M%d × %d)", 
                                     g_htf_period, 
                                     PeriodSeconds(PERIOD_CURRENT) / 60,
                                     HTF_Multiplier);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   
   //--- Set digit precision
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   //--- Initialize previous values
   g_prev_ha_open = 0;
   g_prev_ha_close = 0;
   g_last_htf_time = 0;
   
   Print("═══════════════════════════════════════════════════");
   Print("  Heikin Ashi M", g_htf_period, " Indicator Initialized");
   Print("  Base TF: M", PeriodSeconds(PERIOD_CURRENT) / 60);
   Print("  Multiplier: ", HTF_Multiplier);
   Print("  HTF Period: M", g_htf_period);
   Print("═══════════════════════════════════════════════════");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- Set arrays as series
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   //--- Check for minimum bars
   if(rates_total < HTF_Multiplier * 3)
   {
      Print("Not enough bars for calculation. Need: ", HTF_Multiplier * 3, ", Have: ", rates_total);
      return(0);
   }
   
   //--- Calculate start position
   int start_pos = 0;
   
   if(prev_calculated == 0)
   {
      // First calculation - initialize all buffers
      start_pos = rates_total - HTF_Multiplier * 2;
      
      // Initialize buffers with empty values
      ArrayInitialize(HA_OpenBuffer, EMPTY_VALUE);
      ArrayInitialize(HA_HighBuffer, EMPTY_VALUE);
      ArrayInitialize(HA_LowBuffer, EMPTY_VALUE);
      ArrayInitialize(HA_CloseBuffer, EMPTY_VALUE);
      ArrayInitialize(ColorBuffer, 0);
      
      Print("First calculation - processing ", start_pos, " bars");
   }
   else
   {
      // Recalculate last few bars
      start_pos = HTF_Multiplier * 2;
   }
   
   //--- Main calculation loop
   for(int i = start_pos; i >= 0; i--)
   {
      // Calculate HTF bar time
      datetime htf_time = GetHTFBarTime(time[i], HTF_Multiplier);
      
      // Find the start index for this HTF bar
      int htf_start_index = i;
      
      // Aggregate bars for this HTF period
      double htf_open = 0, htf_high = -DBL_MAX, htf_low = DBL_MAX, htf_close = 0;
      int bars_aggregated = 0;
      
      // Find all bars belonging to this HTF period
      for(int j = i; j < rates_total && bars_aggregated < HTF_Multiplier; j++)
      {
         datetime bar_htf_time = GetHTFBarTime(time[j], HTF_Multiplier);
         
         if(bar_htf_time != htf_time)
            break;
            
         if(bars_aggregated == 0)
            htf_open = open[j];  // First bar's open
            
         if(high[j] > htf_high)
            htf_high = high[j];
            
         if(low[j] < htf_low)
            htf_low = low[j];
            
         htf_close = close[j];  // Last bar's close (newest)
         bars_aggregated++;
      }
      
      // Skip if not enough bars aggregated
      if(bars_aggregated < HTF_Multiplier && i > HTF_Multiplier)
         continue;
      
      // Calculate Heikin Ashi values
      double ha_close = (htf_open + htf_high + htf_low + htf_close) / 4.0;
      double ha_open;
      
      // Get previous HA values
      if(i < rates_total - 1 && HA_OpenBuffer[i + 1] != EMPTY_VALUE)
      {
         // Use previous calculated values
         ha_open = (HA_OpenBuffer[i + 1] + HA_CloseBuffer[i + 1]) / 2.0;
      }
      else
      {
         // First bar - use actual open/close
         ha_open = (htf_open + htf_close) / 2.0;
      }
      
      double ha_high = MathMax(htf_high, MathMax(ha_open, ha_close));
      double ha_low = MathMin(htf_low, MathMin(ha_open, ha_close));
      
      // Store values in buffers
      HA_OpenBuffer[i] = ha_open;
      HA_HighBuffer[i] = ha_high;
      HA_LowBuffer[i] = ha_low;
      HA_CloseBuffer[i] = ha_close;
      
      // Set color based on trend
      if(ha_close >= ha_open)
         ColorBuffer[i] = 0;  // Bullish - Green
      else
         ColorBuffer[i] = 1;  // Bearish - Red
   }
   
   //--- Return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Get HTF bar time                                                 |
//+------------------------------------------------------------------+
datetime GetHTFBarTime(datetime bar_time, int multiplier)
{
   // Round down to HTF bar boundary
   int base_period_seconds = PeriodSeconds(PERIOD_CURRENT);
   int htf_period_seconds = base_period_seconds * multiplier;
   
   // Round down to nearest HTF period
   datetime htf_time = (bar_time / htf_period_seconds) * htf_period_seconds;
   
   return htf_time;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("═══════════════════════════════════════════════════");
   Print("  Heikin Ashi M", g_htf_period, " Indicator Deinitialized");
   Print("  Reason: ", reason);
   Print("═══════════════════════════════════════════════════");
}
//+------------------------------------------------------------------+
