//+------------------------------------------------------------------+
//|                                          Test_Include_Demo.mq5   |
//|                        Demo: How MQL5 #include works            |
//+------------------------------------------------------------------+
#property copyright "Athens"
#property version   "1.00"
#property strict

// This line tells compiler: "Copy all code from TestHelper.mqh here"
#include "Include/TestHelper.mqh"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Call function from TestHelper.mqh (it's compiled inside .ex5 now!)
   string message = GetWelcomeMessage();
   Print(message);
   
   // Call another function from TestHelper.mqh
   int result = Add(5, 10);
   Print("5 + 10 = ", result);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Do nothing, just a demo
}
