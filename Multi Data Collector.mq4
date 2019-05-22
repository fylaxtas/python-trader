//+------------------------------------------------------------------+
//|                                               Data Collector.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


extern ENUM_TIMEFRAMES FrequencyTimeFrame =PERIOD_CURRENT;
  string Symbols="EURUSD,GBPUSD,USDJPY,USDCAD,EURJPY,AUDUSD,GBPJPY";
string Prefix="";
string Suffix="";
extern string FileName="";
extern string Folder="Data";
extern datetime Endate=D'2015.01.01 00:00';
datetime lasttime=0;
int file_handle;
string tempSymbolsArray[];
string SymbolsArray[];
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   int HowManySymbols=SymbolsTotal(true);
 
   string ListSymbols="";
   for(int i=0;i<HowManySymbols;i++)
     {
    //  ListSymbols=StringConcatenate(ListSymbols,SymbolName(i,true),",");
      ArrayResize(SymbolsArray,ArraySize(SymbolsArray)+1);
      SymbolsArray[ArraySize(SymbolsArray)-1]=SymbolName(i,true);
     }
  /*
    Symbols=ListSymbols;



     //==== Prepare Array
      string sep=",";                // A separator as a character
     //--- Get the separator code
      ushort u_sep=StringGetCharacter(sep,0);
     //--- Split the string to substrings
      StringSplit(Symbols,u_sep,tempSymbolsArray);
      ArrayResize(SymbolsArray,ArraySize(tempSymbolsArray));
      
*/
      
  
       
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
 

  Comment("Collecting");
  
   if (  iTime(Symbol(),FrequencyTimeFrame,0) >lasttime)
  {
      lasttime=iTime(Symbol(),FrequencyTimeFrame,0);
      for (int s=0; s<ArraySize(SymbolsArray); s++)
      {
    
         CollectFunction(PERIOD_M1,SymbolsArray[s]);
         CollectFunction(PERIOD_M5,SymbolsArray[s]);
         CollectFunction(PERIOD_M15,SymbolsArray[s]);
         CollectFunction(PERIOD_M30,SymbolsArray[s]);
         CollectFunction(PERIOD_H1,SymbolsArray[s]);
         CollectFunction(PERIOD_H4,SymbolsArray[s]); 
         CollectFunction(PERIOD_D1,SymbolsArray[s]);       
      /*
         CollectFunction(PERIOD_M1);
         CollectFunction(PERIOD_M5);
         CollectFunction(PERIOD_M15);
         CollectFunction(PERIOD_M30);
         CollectFunction(PERIOD_H1);
         CollectFunction(PERIOD_H4); 
         CollectFunction(PERIOD_D1);    
       */             
      }
  }   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CollectFunction (ENUM_TIMEFRAMES sTimeFrame=PERIOD_M1, string symbol="")
{
      if (symbol=="") symbol=Symbol();
      file_handle =FileOpen(Folder+"//"+FileName+""+symbol+"_"+TFtoString(sTimeFrame)+".csv",FILE_CSV|FILE_READ|FILE_WRITE,',');
       
       FileWrite(file_handle,"Time,Open,High,Low,Close,Volume");



      for(int i=1; i<Bars; i++)
      {
            datetime etime=iTime(symbol,sTimeFrame,i);
            double eopen=iOpen(symbol,sTimeFrame,i);
            double eclose=iClose(symbol,sTimeFrame,i);
            double elow=iLow(symbol,sTimeFrame,i);
            double ehigh=iHigh(symbol,sTimeFrame,i);     
            double evolume= (double)iVolume(symbol,sTimeFrame,i);  
            
            if (etime<Endate) break;
         
           FileWrite(file_handle,
           TimeToStr(etime,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+","
           +DoubleToString(eopen,Digits)+","
           +DoubleToString(ehigh,Digits)+","              
           +DoubleToString(elow,Digits)+","             
           +DoubleToString(eclose,Digits)+"," 
           +DoubleToString(evolume,0)                           
          );                                           
      }
  FileClose(file_handle);
}  
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFtoString(int tf)
  {
   string TF="";
   if(tf==0)tf=Period();
   if(tf==1)TF="M1";
   if(tf==5)TF="M5";
   if(tf==15)TF="M15";
   if(tf==30)TF="M30";
   if(tf==60)TF="H1";
   if(tf==240)TF="H4";
   if(tf==1440)TF="D1";
   if(tf==10080)TF="W1";
   if(tf==43200)TF="MN1";
   return(TF);
  }