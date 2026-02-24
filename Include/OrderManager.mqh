//+------------------------------------------------------------------+
//|                                                OrderManager.mqh  |
//|                                  Order Execution & Management    |
//|                                  3-order partial TP system       |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property link      ""
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Order Manager - Handles all order operations                    |
//| Implements 3-order partial TP system (50%, 30%, 20%)           |
//+------------------------------------------------------------------+
class COrderManager
{
private:
   CTrade            m_trade;               // Trade object
   string            m_symbol;
   ulong             m_magic;
   double            m_lotSize;
   int               m_slippage;
   int               m_deviation;
   
   // Lot percentages for partial TP
   double            m_qtyTP1;              // Default: 50%
   double            m_qtyTP2;              // Default: 30%
   double            m_qtyTP3;              // Default: 20%
   
public:
   //--- Constructor
   COrderManager(string symbol, ulong magic);
   ~COrderManager() {}
   
   //--- Settings
   void              SetLotSize(double lot) { m_lotSize = lot; }
   void              SetSlippage(int slippage) { m_slippage = slippage; }
   void              SetDeviation(int deviation) { m_deviation = deviation; m_trade.SetDeviationInPoints(deviation); }
   void              SetTPQuantities(double qty1, double qty2, double qty3);
   
   //--- Entry orders (3 tickets with different TP levels)
   bool              OpenLongPosition(double entry, double tp1, double tp2, double tp3, double sl,
                                     ulong &ticket1, ulong &ticket2, ulong &ticket3);
   
   bool              OpenShortPosition(double entry, double tp1, double tp2, double tp3, double sl,
                                      ulong &ticket1, ulong &ticket2, ulong &ticket3);
   
   //--- Close operations
   bool              ClosePosition(ulong ticket);
   bool              CloseAllPositions();
   int               ClosePositionsByMagic();
   
   //--- Modify operations
   bool              ModifyPosition(ulong ticket, double sl, double tp);
   
   //--- Position checks
   int               CountOpenPositions();
   bool              HasPosition(ulong ticket);
   bool              HasAnyPosition();
   
   //--- Debug
   void              PrintPositions();
   
private:
   //--- Helper functions
   double            NormalizeLot(double lot);
   double            NormalizePrice(double price);
   bool              CheckMoneyForTrade(double lots, ENUM_ORDER_TYPE type);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
COrderManager::COrderManager(string symbol, ulong magic)
{
   m_symbol = symbol;
   m_magic = magic;
   m_lotSize = 0.1;
   m_slippage = 10;
   m_deviation = 10;
   
   // Default partial TP quantities (matching Pine Script)
   m_qtyTP1 = 50.0;  // 50%
   m_qtyTP2 = 30.0;  // 30%
   m_qtyTP3 = 20.0;  // 20%
   
   // Configure trade object
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetDeviationInPoints(m_deviation);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);  // Fill or Kill
   m_trade.SetAsyncMode(false);  // Synchronous mode
   
   Print("Order Manager initialized for ", m_symbol, " | Magic: ", m_magic);
}

//+------------------------------------------------------------------+
//| Set TP quantities                                                |
//+------------------------------------------------------------------+
void COrderManager::SetTPQuantities(double qty1, double qty2, double qty3)
{
   m_qtyTP1 = qty1;
   m_qtyTP2 = qty2;
   m_qtyTP3 = qty3;
   
   Print("TP Quantities set: ", qty1, "% | ", qty2, "% | ", qty3, "%");
}

//+------------------------------------------------------------------+
//| Open Long Position with 3 Partial TPs                           |
//+------------------------------------------------------------------+
bool COrderManager::OpenLongPosition(double entry, double tp1, double tp2, double tp3, double sl,
                                     ulong &ticket1, ulong &ticket2, ulong &ticket3)
{
   // Calculate lot sizes
   double lot1 = NormalizeLot(m_lotSize * m_qtyTP1 / 100.0);
   double lot2 = NormalizeLot(m_lotSize * m_qtyTP2 / 100.0);
   double lot3 = NormalizeLot(m_lotSize * m_qtyTP3 / 100.0);
   
   // Normalize prices
   tp1 = NormalizePrice(tp1);
   tp2 = NormalizePrice(tp2);
   tp3 = NormalizePrice(tp3);
   sl = NormalizePrice(sl);
   
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   Print("╔════════════════════════════════════════════╗");
   Print("║ OPENING LONG POSITION                     ║");
   Print("╠════════════════════════════════════════════╣");
   Print("║ Entry: ", DoubleToString(ask, _Digits));
   Print("║ Lots: ", lot1, " | ", lot2, " | ", lot3);
   Print("║ TP1: ", DoubleToString(tp1, _Digits), " (", m_qtyTP1, "%)");
   Print("║ TP2: ", DoubleToString(tp2, _Digits), " (", m_qtyTP2, "%)");
   Print("║ TP3: ", DoubleToString(tp3, _Digits), " (", m_qtyTP3, "%)");
   Print("║ SL:  ", DoubleToString(sl, _Digits));
   Print("╚════════════════════════════════════════════╝");
   
   // Check money for all orders
   if(!CheckMoneyForTrade(lot1 + lot2 + lot3, ORDER_TYPE_BUY))
   {
      Print("ERROR: Insufficient funds for trade");
      return false;
   }
   
   // Order 1: 50% at TP1
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_BUY, lot1, ask, sl, tp1, "Long_TP1"))
   {
      Print("ERROR: Failed to open Long TP1 | Error: ", GetLastError());
      Print("Trade Result Code: ", m_trade.ResultRetcode());
      Print("Trade Result Comment: ", m_trade.ResultComment());
      return false;
   }
   ticket1 = m_trade.ResultOrder();
   Print("✓ Order 1 opened: Ticket #", ticket1, " | Lot: ", lot1, " | TP: ", tp1);
   Sleep(100);  // Small delay between orders
   
   // Order 2: 30% at TP2
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_BUY, lot2, ask, sl, tp2, "Long_TP2"))
   {
      Print("ERROR: Failed to open Long TP2 | Error: ", GetLastError());
      return false;
   }
   ticket2 = m_trade.ResultOrder();
   Print("✓ Order 2 opened: Ticket #", ticket2, " | Lot: ", lot2, " | TP: ", tp2);
   Sleep(100);
   
   // Order 3: 20% at TP3
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_BUY, lot3, ask, sl, tp3, "Long_TP3"))
   {
      Print("ERROR: Failed to open Long TP3 | Error: ", GetLastError());
      return false;
   }
   ticket3 = m_trade.ResultOrder();
   Print("✓ Order 3 opened: Ticket #", ticket3, " | Lot: ", lot3, " | TP: ", tp3);
   
   Print("════════════════════════════════════════════");
   Print("LONG POSITION OPENED SUCCESSFULLY");
   Print("Total Lots: ", lot1 + lot2 + lot3);
   Print("════════════════════════════════════════════");
   
   return true;
}

//+------------------------------------------------------------------+
//| Open Short Position with 3 Partial TPs                          |
//+------------------------------------------------------------------+
bool COrderManager::OpenShortPosition(double entry, double tp1, double tp2, double tp3, double sl,
                                      ulong &ticket1, ulong &ticket2, ulong &ticket3)
{
   // Calculate lot sizes
   double lot1 = NormalizeLot(m_lotSize * m_qtyTP1 / 100.0);
   double lot2 = NormalizeLot(m_lotSize * m_qtyTP2 / 100.0);
   double lot3 = NormalizeLot(m_lotSize * m_qtyTP3 / 100.0);
   
   // Normalize prices
   tp1 = NormalizePrice(tp1);
   tp2 = NormalizePrice(tp2);
   tp3 = NormalizePrice(tp3);
   sl = NormalizePrice(sl);
   
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   Print("╔════════════════════════════════════════════╗");
   Print("║ OPENING SHORT POSITION                    ║");
   Print("╠════════════════════════════════════════════╣");
   Print("║ Entry: ", DoubleToString(bid, _Digits));
   Print("║ Lots: ", lot1, " | ", lot2, " | ", lot3);
   Print("║ TP1: ", DoubleToString(tp1, _Digits), " (", m_qtyTP1, "%)");
   Print("║ TP2: ", DoubleToString(tp2, _Digits), " (", m_qtyTP2, "%)");
   Print("║ TP3: ", DoubleToString(tp3, _Digits), " (", m_qtyTP3, "%)");
   Print("║ SL:  ", DoubleToString(sl, _Digits));
   Print("╚════════════════════════════════════════════╝");
   
   // Check money
   if(!CheckMoneyForTrade(lot1 + lot2 + lot3, ORDER_TYPE_SELL))
   {
      Print("ERROR: Insufficient funds for trade");
      return false;
   }
   
   // Order 1: 50% at TP1
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_SELL, lot1, bid, sl, tp1, "Short_TP1"))
   {
      Print("ERROR: Failed to open Short TP1 | Error: ", GetLastError());
      return false;
   }
   ticket1 = m_trade.ResultOrder();
   Print("✓ Order 1 opened: Ticket #", ticket1, " | Lot: ", lot1, " | TP: ", tp1);
   Sleep(100);
   
   // Order 2: 30% at TP2
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_SELL, lot2, bid, sl, tp2, "Short_TP2"))
   {
      Print("ERROR: Failed to open Short TP2 | Error: ", GetLastError());
      return false;
   }
   ticket2 = m_trade.ResultOrder();
   Print("✓ Order 2 opened: Ticket #", ticket2, " | Lot: ", lot2, " | TP: ", tp2);
   Sleep(100);
   
   // Order 3: 20% at TP3
   if(!m_trade.PositionOpen(m_symbol, ORDER_TYPE_SELL, lot3, bid, sl, tp3, "Short_TP3"))
   {
      Print("ERROR: Failed to open Short TP3 | Error: ", GetLastError());
      return false;
   }
   ticket3 = m_trade.ResultOrder();
   Print("✓ Order 3 opened: Ticket #", ticket3, " | Lot: ", lot3, " | TP: ", tp3);
   
   Print("════════════════════════════════════════════");
   Print("SHORT POSITION OPENED SUCCESSFULLY");
   Print("Total Lots: ", lot1 + lot2 + lot3);
   Print("════════════════════════════════════════════");
   
   return true;
}

//+------------------------------------------------------------------+
//| Close position by ticket                                        |
//+------------------------------------------------------------------+
bool COrderManager::ClosePosition(ulong ticket)
{
   if(!m_trade.PositionClose(ticket))
   {
      Print("ERROR: Failed to close position #", ticket, " | Error: ", GetLastError());
      return false;
   }
   
   Print("✓ Position #", ticket, " closed successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Close all positions for this EA                                 |
//+------------------------------------------------------------------+
bool COrderManager::CloseAllPositions()
{
   int closed = ClosePositionsByMagic();
   Print("Closed ", closed, " position(s)");
   return (closed > 0);
}

//+------------------------------------------------------------------+
//| Close positions by magic number                                 |
//+------------------------------------------------------------------+
int COrderManager::ClosePositionsByMagic()
{
   int closed = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC) == m_magic)
         {
            if(ClosePosition(ticket))
               closed++;
         }
      }
   }
   
   return closed;
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                |
//+------------------------------------------------------------------+
int COrderManager::CountOpenPositions()
{
   int count = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC) == m_magic)
         {
            count++;
         }
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Check if specific position exists                               |
//+------------------------------------------------------------------+
bool COrderManager::HasPosition(ulong ticket)
{
   return PositionSelectByTicket(ticket);
}

//+------------------------------------------------------------------+
//| Check if any position exists                                    |
//+------------------------------------------------------------------+
bool COrderManager::HasAnyPosition()
{
   return (CountOpenPositions() > 0);
}

//+------------------------------------------------------------------+
//| Normalize lot size                                              |
//+------------------------------------------------------------------+
double COrderManager::NormalizeLot(double lot)
{
   double minLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
   
   if(lot < minLot) lot = minLot;
   if(lot > maxLot) lot = maxLot;
   
   lot = MathFloor(lot / stepLot) * stepLot;
   
   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Normalize price                                                  |
//+------------------------------------------------------------------+
double COrderManager::NormalizePrice(double price)
{
   return NormalizeDouble(price, _Digits);
}

//+------------------------------------------------------------------+
//| Check if enough money for trade                                 |
//+------------------------------------------------------------------+
bool COrderManager::CheckMoneyForTrade(double lots, ENUM_ORDER_TYPE type)
{
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   // Calculate required margin (approximate)
   double price = (type == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(m_symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(m_symbol, SYMBOL_BID);
   
   // This is simplified - real margin calculation is more complex
   double requiredMargin = lots * 100000 * price / 100;  // Assuming 1:100 leverage
   
   if(freeMargin < requiredMargin)
   {
      Print("Insufficient margin: Required=", requiredMargin, " Available=", freeMargin);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Print all open positions                                        |
//+------------------------------------------------------------------+
void COrderManager::PrintPositions()
{
   Print("═══════ Open Positions ═══════");
   
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetString(POSITION_SYMBOL) == m_symbol &&
            PositionGetInteger(POSITION_MAGIC) == m_magic)
         {
            count++;
            Print("Ticket #", ticket, 
                  " | Type: ", (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                  " | Lot: ", PositionGetDouble(POSITION_VOLUME),
                  " | Entry: ", PositionGetDouble(POSITION_PRICE_OPEN),
                  " | SL: ", PositionGetDouble(POSITION_SL),
                  " | TP: ", PositionGetDouble(POSITION_TP),
                  " | Profit: ", PositionGetDouble(POSITION_PROFIT));
         }
      }
   }
   
   if(count == 0)
      Print("No open positions");
   
   Print("═════════════════════════════");
}
//+------------------------------------------------------------------+
