//+------------------------------------------------------------------+
//|                                             TestHelper.mqh       |
//|                        Helper functions for demo                 |
//+------------------------------------------------------------------+

// This code will be COPIED into Test_Include_Demo.mq5 during compilation
// MT5 will NOT load this .mqh file at runtime

//+------------------------------------------------------------------+
//| Get welcome message                                              |
//+------------------------------------------------------------------+
string GetWelcomeMessage()
{
   return "✅ Include system works! This function is from TestHelper.mqh";
}

//+------------------------------------------------------------------+
//| Add two numbers                                                  |
//+------------------------------------------------------------------+
int Add(int a, int b)
{
   return a + b;
}

//+------------------------------------------------------------------+
//| More functions can be added here...                             |
//+------------------------------------------------------------------+
// They will all be compiled into the .ex5 file!
