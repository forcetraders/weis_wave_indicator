
//+------------------------------------------------------------------+
//|                                                     WeisWave.mq5 |
//|                                                      Semen Ligin |
//|                       https://www.freelancer.com/u/gabontau.html |
//+------------------------------------------------------------------+
#property copyright "Semen Ligin"
#property link      "https://www.freelancer.com/u/gabontau.html"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1

enum ENUM_DISPLAY_DATA
{
total_volume,
length,
width,
bar_d_volume,
length_d_volume
};

#property indicator_label1  "Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Red, Green
#property indicator_width1  2

input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK;
input ENUM_DISPLAY_DATA Display1Type=total_volume;
input ENUM_DISPLAY_DATA Display2Type=total_volume;
input ENUM_DISPLAY_DATA SubDisplayType=total_volume;

input int      BarStarting=1;
input int      Direction=50;
input int      Distance=20;
input bool     DrawDisplay=true;
input bool     DrawConfirmedWaveDirections=true;
input bool     UseHighLow=false;

double HistoBuffer[];
double HistoColorBuffer[];
double ArrowsBuffer[];


int trend=0;
int MinIndex=1;
int MaxIndex=1;
int LastIndex=1;
double Cumulated=0;
string NAME = "";
int Ext[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0,HistoBuffer, INDICATOR_DATA);
    SetIndexBuffer(1,HistoColorBuffer,INDICATOR_COLOR_INDEX);
   
    IndicatorSetInteger(INDICATOR_DIGITS,0);
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
   if (true)
   {
      ArrayResize(Ext, rates_total+1);
      for (int i=0; i<rates_total; i++)
      {
         Ext[i] = 0;
         HistoBuffer[i] = 0;
         HistoColorBuffer[i] = 0;
      }
      
      if (UseHighLow == false)
         GetExtremumsByClose(rates_total, close);
      else
         GetExtremumsByHighLow(rates_total, high, low, close);
         
      vDrawZigZag(rates_total, time, high, low, close);
      
      
      if (DrawDisplay)
         {
         vDrawDisplay(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
         }
      
      vDrawSubgraphic(rates_total, prev_calculated, time, open, high, low, close, tick_volume, volume, spread);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
 

void vDrawDisplay(const int rates_total,
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
          LastIndex = 1;
          string ret = "";
          
          for (int i=BarStarting; i<rates_total-1; i++)
          {    
              Cumulated = 0;
              if (Ext[i]!=0)
              {
                      NAME = "Line_" + (string)LastIndex;
                      
                      if (ObjectFind(0, NAME)<0)
                      {
                         ObjectCreate(0, NAME, OBJ_TREND, 0,time[LastIndex], close[LastIndex], time[i], close[i]);
                         ObjectSetInteger( 0, NAME , OBJPROP_COLOR,White);
                         ObjectSetInteger(0, NAME , OBJPROP_SELECTABLE, false);
                         ObjectSetInteger(0, NAME , OBJPROP_HIDDEN, true);
                      }
                      
                  if (Display1Type==total_volume)
                      {
                         if(InpVolumeType==VOLUME_TICK) 
                             for (int j=LastIndex+1; j<=i; j++)
                                 Cumulated += (double)tick_volume[j];
                         else
                             for (int j=LastIndex+1; j<=i; j++)
                                 Cumulated += (double)volume[j];
                         ret = (string)Cumulated;
                      }
                  else if (Display1Type==length)
                      ret = (string)(double)(long)MathAbs((close[i] - close[LastIndex])/_Point-1);
                  else if (Display1Type==width)
                      ret = (string)(double)MathAbs(i - LastIndex);
                  else if (Display1Type==bar_d_volume)
                      {
                      if(InpVolumeType==VOLUME_TICK) 
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += close[j]/tick_volume[j];
                      else
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += close[j]/volume[j];
                      
                      ret = DoubleToString(Cumulated, 3);
                      
                      }
                  else if (Display1Type==length_d_volume)
                      {
                      if(InpVolumeType==VOLUME_TICK) 
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point - 1)/tick_volume[j];
                      else
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point - 1)/volume[j];
                      
                      ret = DoubleToString(Cumulated, 3);
                      
                      }  
                      
                  NAME="Red_"+string(LastIndex);
                  if (ObjectFind(0, NAME)<0)
                  {
                  ObjectCreate(0, NAME, OBJ_TEXT, 0, time[i],(Ext[i]==1)?(high[i] + _Point*Distance):(low[i] - _Point*Distance));
                  ObjectSetInteger( 0, NAME , OBJPROP_COLOR,Red);
                  ObjectSetInteger(0, NAME , OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, NAME , OBJPROP_HIDDEN, true);
                  ObjectSetString(0, NAME , OBJPROP_TEXT, ret);
                  }
                  //2 дисплей
                  
                  Cumulated = 0;
                  
                  if (Display2Type==total_volume)
                      {
                         if(InpVolumeType==VOLUME_TICK) 
                             for (int j=LastIndex+1; j<=i; j++)
                                 Cumulated += (double)tick_volume[j];
                         else
                             for (int j=LastIndex+1; j<=i; j++)
                                 Cumulated += (double)volume[j];
                         ret = (string)Cumulated;
                      }
                  else if (Display2Type==length)
                      ret = (string)(double)(long)MathAbs((close[i] - close[LastIndex])/_Point-1);
                  else if (Display2Type==width)
                      ret = (string)(double)MathAbs(i - LastIndex);
                  else if (Display2Type==bar_d_volume)
                      {
                      if(InpVolumeType==VOLUME_TICK) 
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += close[j]/tick_volume[j];
                      else
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += close[j]/volume[j];
                      
                      ret = DoubleToString(Cumulated, 3);
                      
                      }
                  else if (Display2Type==length_d_volume)
                      {
                      if(InpVolumeType==VOLUME_TICK) 
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point - 1)/tick_volume[j];
                      else
                          for (int j=LastIndex+1; j<=i; j++)
                              Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point - 1)/volume[j];
                      
                      ret = DoubleToString(Cumulated, 3);
                      
                      }  
                      
                  NAME="Yellow_"+string(LastIndex);
                  if (ObjectFind(0, NAME)<0)
                  {
                  ObjectCreate(0, NAME, OBJ_TEXT, 0, time[i],(Ext[i]==1)?(high[i] + _Point*4*Distance):(low[i] - _Point*4*Distance));
                  ObjectSetInteger( 0, NAME , OBJPROP_COLOR,Yellow);
                  ObjectSetInteger(0, NAME , OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, NAME , OBJPROP_HIDDEN, true);
                  ObjectSetString(0, NAME , OBJPROP_TEXT, ret);
                  }
                  
                  LastIndex = i;
             }
            }     
};


void vDrawSubgraphic(const int rates_total,
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
for (int i=BarStarting; i<rates_total-1; i++)
            {         
                Cumulated = 0; 
            if (SubDisplayType==total_volume)
                if(InpVolumeType==VOLUME_TICK) 
                    for (int j=LastIndex+1; j<=i; j++)
                        Cumulated += (double)tick_volume[j];
                else
                    for (int j=LastIndex+1; j<=i; j++)
                        Cumulated += (double)volume[j]; 
            else if (SubDisplayType==length)
                Cumulated = (double)(long)MathAbs((close[i] - close[LastIndex])/_Point + 1);
            else if (SubDisplayType==width)
                Cumulated = (double)MathAbs(i - LastIndex);
            else if (SubDisplayType==bar_d_volume)
                {
                if(InpVolumeType==VOLUME_TICK) 
                    for (int j=LastIndex; j<=i; j++)
                        Cumulated += close[j]/tick_volume[j];
                else
                    for (int j=LastIndex; j<=i; j++)
                        Cumulated += close[j]/volume[j];
                Cumulated = NormalizeDouble(Cumulated, 3);
                }
            else if (SubDisplayType==length_d_volume)
                {
                if(InpVolumeType==VOLUME_TICK) 
                    for (int j=LastIndex; j<=i; j++)
                        Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point)/tick_volume[j];
                else
                    for (int j=LastIndex; j<=i; j++)
                        Cumulated += (double)(long)MathAbs((close[i] - close[LastIndex])/_Point)/volume[j];
                Cumulated = NormalizeDouble(Cumulated, 3);
                }  
            
            
            HistoBuffer[i] = Cumulated;
            if (Ext[LastIndex] == 1)
                  HistoColorBuffer[i] = 0;
            else 
                  HistoColorBuffer[i] = 1;
            
            if (Ext[i]!=0)
                LastIndex = i;       
         }
};

 
 
void vDrawZigZag(const int rates_total, 
                 const datetime &time[], 
                 const double &high[],
                 const double &low[],
                 const double &close[]
                 )
{
   LastIndex = 1;
   for (int i=BarStarting; i<rates_total; i++)
      if (Ext[i]!=0)
         {
         NAME = "Line_" + (string)i;  
         if (!UseHighLow)
            ObjectCreate(0, NAME, OBJ_TREND, 0,time[LastIndex], close[LastIndex], time[i], close[i]);
         else
            if (Ext[i]==-1)
               ObjectCreate(0, NAME, OBJ_TREND, 0,time[LastIndex], high[LastIndex], time[i], low[i]);
            else
               ObjectCreate(0, NAME, OBJ_TREND, 0,time[LastIndex], low[LastIndex], time[i], high[i]);
            
            
         
         ObjectSetInteger( 0, NAME , OBJPROP_COLOR,White);
         ObjectSetInteger(0, NAME , OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, NAME , OBJPROP_HIDDEN, true);
         
         LastIndex = i;
         }
}


void GetExtremumsByClose(const int rates_total,
                         const double &close[]
                        )
{

LastIndex = 1;
MinIndex=1;
MaxIndex=1;

for (int i=BarStarting; i<rates_total; i++)
           {
              if (close[i] > close[MaxIndex])
                  MaxIndex = i;
              if (close[i] < close[MinIndex])
                  MinIndex = i;
                  
              if ((close[MaxIndex] - close[i])>(Direction*_Point))
                  if ((close[MaxIndex] - close[LastIndex]) > (Direction*_Point))
                  {
                     if (trend == 1)
                         Ext[MinIndex] = -1;
                     Ext[MaxIndex] = 1;
                     LastIndex = MaxIndex;
                     MinIndex = i;
                     trend = 1;
                     continue;
                  }
               if ((close[i] - close[MinIndex])>(Direction*_Point))
                   if ((close[LastIndex] - close[MinIndex]) > (Direction*_Point))
                   {
                      if (trend == -1)
                          Ext[MaxIndex] = 1;
                      Ext[MinIndex] = -1;
                      LastIndex = MinIndex;
                      MaxIndex = i;
                      trend = -1;
                      continue;
                  }
                }
}


void GetExtremumsByHighLow(const int rates_total,
                           const double &high[],
                           const double &low[],
                           const double &close[]
                           )
                           
{

LastIndex = 1;
MinIndex=1;
MaxIndex=1;
double LastPrice = close[1];


for (int i=BarStarting; i<rates_total; i++)
           {
           if (high[i] > high[MaxIndex])
           {
               MaxIndex=i;
               continue;
           }
           
           if (low[i] < low[MinIndex]) 
           {
               MinIndex=i;
               continue;
           }
           
           if ((high[MaxIndex] - low[i])>(Direction*_Point))
               if ((high[MaxIndex] - LastPrice) > (Direction*_Point))
               {
                     if (trend == 1)  
                     {
                        Ext[MinIndex] = -1;
                        LastPrice = low[MinIndex];
                     }
                     
                     Ext[MaxIndex] = 1;
                     LastPrice = high[MaxIndex];
                     LastIndex = MaxIndex;
                     MinIndex = i;
                     trend = 1;
                     
                     continue;
               }
               
           if ((high[i] - low[MinIndex])>(Direction*_Point))
               if ((LastPrice - low[MinIndex]) > (Direction*_Point))
               {
                     if (trend == -1) 
                     {
                        Ext[MaxIndex] = 1;
                        LastPrice = high[MaxIndex];
                     }  
                       
                     Ext[MinIndex] = -1;
                     LastPrice = low[MinIndex];
                     LastIndex = MinIndex;
                     MaxIndex = i;
                     trend = -1;
                      
                     continue;
                }
           }
}
             
void OnDeinit(const int reason)
{
    ObjectsDeleteAll(0); //it's only way to do
}