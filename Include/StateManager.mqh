//+------------------------------------------------------------------+
//|                                                 StateManager.mqh |
//|                                  State Machine Manager for EA    |
//|                                  Based on Pine Script analysis   |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| State Manager Class - Handles state machine transitions         |
//| States: 0.0, ±1.0, ±1.1, ±1.2, ±1.3                            |
//+------------------------------------------------------------------+
class CStateManager
{
private:
   // State variables (persistent across ticks)
   double            m_condition;           // Current state: 0.0, ±1.0, ±1.1, ±1.2, ±1.3
   double            m_entryPrice;          // Entry price
   double            m_tp1Line;             // TP1 price
   double            m_tp2Line;             // TP2 price  
   double            m_tp3Line;             // TP3 price
   double            m_slLine;              // SL price
   ulong             m_tickets[3];          // Order tickets [TP1, TP2, TP3]
   datetime          m_entryTime;           // Entry time
   
public:
   //--- Constructor
   CStateManager();
   ~CStateManager() {}
   
   //--- Getters
   double            GetCondition() const { return m_condition; }
   double            GetEntryPrice() const { return m_entryPrice; }
   double            GetTP1() const { return m_tp1Line; }
   double            GetTP2() const { return m_tp2Line; }
   double            GetTP3() const { return m_tp3Line; }
   double            GetSL() const { return m_slLine; }
   ulong             GetTicket(int index) const;
   datetime          GetEntryTime() const { return m_entryTime; }
   
   //--- State checks
   bool              IsFlat() const { return m_condition == 0.0; }
   bool              IsLong() const { return m_condition > 0.0; }
   bool              IsShort() const { return m_condition < 0.0; }
   bool              IsEntry() const { return (MathAbs(m_condition) == 1.0); }
   bool              IsTP1Hit() const { return (MathAbs(m_condition) == 1.1); }
   bool              IsTP2Hit() const { return (MathAbs(m_condition) == 1.2); }
   bool              IsTP3Hit() const { return (MathAbs(m_condition) == 1.3); }
   bool              HasPosition() const { return !IsFlat(); }
   
   //--- State transitions
   void              OnLongEntry(double entry, double tp1, double tp2, double tp3, double sl);
   void              OnShortEntry(double entry, double tp1, double tp2, double tp3, double sl);
   void              OnTP1Hit();
   void              OnTP2Hit();
   void              OnTP3Hit();
   void              OnSLHit();
   void              Reset();
   
   //--- State update (main logic) - checks all transitions
   void              Update(double bid, double ask);
   
   //--- Ticket management
   void              SetTickets(ulong t1, ulong t2, ulong t3);
   void              ClearTicket(int index);
   
   //--- Debug
   string            GetStateString() const;
   void              PrintState() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CStateManager::CStateManager()
{
   m_condition = 0.0;
   m_entryPrice = 0.0;
   m_tp1Line = 0.0;
   m_tp2Line = 0.0;
   m_tp3Line = 0.0;
   m_slLine = 0.0;
   ArrayInitialize(m_tickets, 0);
   m_entryTime = 0;
}

//+------------------------------------------------------------------+
//| Get ticket by index                                              |
//+------------------------------------------------------------------+
ulong CStateManager::GetTicket(int index) const
{
   if(index < 0 || index >= 3)
      return 0;
   return m_tickets[index];
}

//+------------------------------------------------------------------+
//| On Long Entry - Set state to 1.0                                 |
//+------------------------------------------------------------------+
void CStateManager::OnLongEntry(double entry, double tp1, double tp2, double tp3, double sl)
{
   m_condition = 1.0;
   m_entryPrice = entry;
   m_tp1Line = tp1;
   m_tp2Line = tp2;
   m_tp3Line = tp3;
   m_slLine = sl;
   m_entryTime = TimeCurrent();
   
   Print("═══════════════════════════════════════════");
   Print("STATE TRANSITION: 0.0 → 1.0 (Long Entry)");
   Print("Entry: ", DoubleToString(entry, _Digits));
   Print("TP1: ", DoubleToString(tp1, _Digits), " (Target 1)");
   Print("TP2: ", DoubleToString(tp2, _Digits), " (Target 2)");
   Print("TP3: ", DoubleToString(tp3, _Digits), " (Target 3)");
   Print("SL: ", DoubleToString(sl, _Digits), " (Stop Loss)");
   Print("═══════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| On Short Entry - Set state to -1.0                               |
//+------------------------------------------------------------------+
void CStateManager::OnShortEntry(double entry, double tp1, double tp2, double tp3, double sl)
{
   m_condition = -1.0;
   m_entryPrice = entry;
   m_tp1Line = tp1;
   m_tp2Line = tp2;
   m_tp3Line = tp3;
   m_slLine = sl;
   m_entryTime = TimeCurrent();
   
   Print("═══════════════════════════════════════════");
   Print("STATE TRANSITION: 0.0 → -1.0 (Short Entry)");
   Print("Entry: ", DoubleToString(entry, _Digits));
   Print("TP1: ", DoubleToString(tp1, _Digits), " (Target 1)");
   Print("TP2: ", DoubleToString(tp2, _Digits), " (Target 2)");
   Print("TP3: ", DoubleToString(tp3, _Digits), " (Target 3)");
   Print("SL: ", DoubleToString(sl, _Digits), " (Stop Loss)");
   Print("═══════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Update State Machine (check all transitions)                     |
//+------------------------------------------------------------------+
void CStateManager::Update(double bid, double ask)
{
   // No position, nothing to update
   if(IsFlat())
      return;
   
   // ============================================================
   // LONG POSITION TRANSITIONS
   // ============================================================
   if(IsLong())
   {
      // Check TP3 first (highest priority)
      if(m_condition == 1.2 && bid >= m_tp3Line)
      {
         OnTP3Hit();
      }
      // Check TP2
      else if(m_condition == 1.1 && bid >= m_tp2Line)
      {
         OnTP2Hit();
      }
      // Check TP1
      else if(m_condition == 1.0 && bid >= m_tp1Line)
      {
         OnTP1Hit();
      }
      // Check SL (any long state)
      else if(bid <= m_slLine)
      {
         OnSLHit();
      }
   }
   
   // ============================================================
   // SHORT POSITION TRANSITIONS
   // ============================================================
   else if(IsShort())
   {
      // Check TP3 first (highest priority)
      if(m_condition == -1.2 && ask <= m_tp3Line)
      {
         OnTP3Hit();
      }
      // Check TP2
      else if(m_condition == -1.1 && ask <= m_tp2Line)
      {
         OnTP2Hit();
      }
      // Check TP1
      else if(m_condition == -1.0 && ask <= m_tp1Line)
      {
         OnTP1Hit();
      }
      // Check SL (any short state)
      else if(ask >= m_slLine)
      {
         OnSLHit();
      }
   }
}

//+------------------------------------------------------------------+
//| TP1 Hit Transition                                               |
//+------------------------------------------------------------------+
void CStateManager::OnTP1Hit()
{
   if(m_condition == 1.0)
   {
      m_condition = 1.1;
      Print("──────────────────────────────────────────");
      Print("STATE TRANSITION: 1.0 → 1.1 (Long TP1 Hit)");
      Print("50% Position Closed at TP1");
      Print("Remaining: 50% (TP2 + TP3 pending)");
      Print("──────────────────────────────────────────");
   }
   else if(m_condition == -1.0)
   {
      m_condition = -1.1;
      Print("──────────────────────────────────────────");
      Print("STATE TRANSITION: -1.0 → -1.1 (Short TP1 Hit)");
      Print("50% Position Closed at TP1");
      Print("Remaining: 50% (TP2 + TP3 pending)");
      Print("──────────────────────────────────────────");
   }
}

//+------------------------------------------------------------------+
//| TP2 Hit Transition                                               |
//+------------------------------------------------------------------+
void CStateManager::OnTP2Hit()
{
   if(m_condition == 1.1)
   {
      m_condition = 1.2;
      Print("──────────────────────────────────────────");
      Print("STATE TRANSITION: 1.1 → 1.2 (Long TP2 Hit)");
      Print("30% Position Closed at TP2");
      Print("Remaining: 20% (TP3 pending)");
      Print("──────────────────────────────────────────");
   }
   else if(m_condition == -1.1)
   {
      m_condition = -1.2;
      Print("──────────────────────────────────────────");
      Print("STATE TRANSITION: -1.1 → -1.2 (Short TP2 Hit)");
      Print("30% Position Closed at TP2");
      Print("Remaining: 20% (TP3 pending)");
      Print("──────────────────────────────────────────");
   }
}

//+------------------------------------------------------------------+
//| TP3 Hit Transition                                               |
//+------------------------------------------------------------------+
void CStateManager::OnTP3Hit()
{
   if(m_condition == 1.2)
   {
      m_condition = 1.3;
      Print("╔═══════════════════════════════════════════╗");
      Print("║ STATE TRANSITION: 1.2 → 1.3 (Long TP3)  ║");
      Print("║ 20% Position Closed at TP3               ║");
      Print("║ TRADE COMPLETE! All targets hit! ✓      ║");
      Print("╚═══════════════════════════════════════════╝");
      
      // Reset to flat after complete cycle
      // (In real scenario, might wait for opposite signal)
      // For now, keep it at 1.3 until next signal
   }
   else if(m_condition == -1.2)
   {
      m_condition = -1.3;
      Print("╔═══════════════════════════════════════════╗");
      Print("║ STATE TRANSITION: -1.2 → -1.3 (Short TP3)║");
      Print("║ 20% Position Closed at TP3               ║");
      Print("║ TRADE COMPLETE! All targets hit! ✓      ║");
      Print("╚═══════════════════════════════════════════╝");
   }
}

//+------------------------------------------------------------------+
//| SL Hit Transition                                                |
//+------------------------------------------------------------------+
void CStateManager::OnSLHit()
{
   double prev_condition = m_condition;
   
   Print("╔═══════════════════════════════════════════╗");
   Print("║ STOP LOSS HIT!                           ║");
   Print("║ State: ", GetStateString(), " → 0.0 (Flat)");
   Print("║ All remaining positions will be closed   ║");
   Print("╚═══════════════════════════════════════════╝");
   
   Reset();
}

//+------------------------------------------------------------------+
//| Reset state to flat                                             |
//+------------------------------------------------------------------+
void CStateManager::Reset()
{
   m_condition = 0.0;
   m_entryPrice = 0.0;
   m_tp1Line = 0.0;
   m_tp2Line = 0.0;
   m_tp3Line = 0.0;
   m_slLine = 0.0;
   ArrayInitialize(m_tickets, 0);
   m_entryTime = 0;
   
   Print("State Reset: Ready for new signal");
}

//+------------------------------------------------------------------+
//| Set order tickets                                                |
//+------------------------------------------------------------------+
void CStateManager::SetTickets(ulong t1, ulong t2, ulong t3)
{
   m_tickets[0] = t1;
   m_tickets[1] = t2;
   m_tickets[2] = t3;
   
   Print("Tickets Saved: ", t1, " | ", t2, " | ", t3);
}

//+------------------------------------------------------------------+
//| Clear specific ticket                                            |
//+------------------------------------------------------------------+
void CStateManager::ClearTicket(int index)
{
   if(index >= 0 && index < 3)
      m_tickets[index] = 0;
}

//+------------------------------------------------------------------+
//| Get state as string                                             |
//+------------------------------------------------------------------+
string CStateManager::GetStateString() const
{
   if(m_condition == 0.0) return "0.0 (Flat)";
   else if(m_condition == 1.0) return "1.0 (Long Entry)";
   else if(m_condition == 1.1) return "1.1 (Long TP1 Hit)";
   else if(m_condition == 1.2) return "1.2 (Long TP2 Hit)";
   else if(m_condition == 1.3) return "1.3 (Long Complete)";
   else if(m_condition == -1.0) return "-1.0 (Short Entry)";
   else if(m_condition == -1.1) return "-1.1 (Short TP1 Hit)";
   else if(m_condition == -1.2) return "-1.2 (Short TP2 Hit)";
   else if(m_condition == -1.3) return "-1.3 (Short Complete)";
   else return "Unknown";
}

//+------------------------------------------------------------------+
//| Print current state (debug)                                     |
//+------------------------------------------------------------------+
void CStateManager::PrintState() const
{
   Print("─────────── Current State ───────────");
   Print("Condition: ", GetStateString());
   if(!IsFlat())
   {
      Print("Entry: ", DoubleToString(m_entryPrice, _Digits));
      Print("TP1: ", DoubleToString(m_tp1Line, _Digits));
      Print("TP2: ", DoubleToString(m_tp2Line, _Digits));
      Print("TP3: ", DoubleToString(m_tp3Line, _Digits));
      Print("SL: ", DoubleToString(m_slLine, _Digits));
      Print("Tickets: ", m_tickets[0], " | ", m_tickets[1], " | ", m_tickets[2]);
   }
   Print("─────────────────────────────────────");
}
//+------------------------------------------------------------------+
