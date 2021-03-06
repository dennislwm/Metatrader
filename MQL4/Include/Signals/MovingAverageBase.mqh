//+------------------------------------------------------------------+
//|                                            MovingAverageBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MovingAverageBase : public AbstractSignal
  {
protected:
   int               _maShift;
   ENUM_MA_METHOD    _maMethod;
   ENUM_APPLIED_PRICE _maAppliedPrice;
public:
   double            GetMovingAverage(string symbol,int shift);
   PriceTrend        GetMovingAverageTrend(string symbol,int shift);
   void              MovingAverageBase(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrHotPink,AbstractSignal *aSubSignal=NULL);
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverageBase::MovingAverageBase(int period,ENUM_TIMEFRAMES timeframe,ENUM_MA_METHOD maMethod,ENUM_APPLIED_PRICE maAppliedPrice,int maShift,int shift=0,double minimumSpreadsTpSl=1,color indicatorColor=clrHotPink,AbstractSignal *aSubSignal=NULL):AbstractSignal(period,timeframe,shift,indicatorColor,minimumSpreadsTpSl,aSubSignal)
  {
   this._maMethod=maMethod;
   this._maAppliedPrice=maAppliedPrice;
   this._maShift=maShift;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MovingAverageBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);

   if(!this._compare.IsNotBelow(this._maShift,0))
     {
      v.Result=false;
      v.AddMessage("maShift must be 0 or greater.");
     }

   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MovingAverageBase::GetMovingAverage(string symbol,int shift)
  {
   return this.GetMovingAverage(symbol,shift,this._maShift,this._maMethod,this._maAppliedPrice);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PriceTrend MovingAverageBase::GetMovingAverageTrend(string symbol,int shift)
  {
   PriceTrend pt;
   pt.current=this.GetMovingAverage(symbol,shift);
   pt.previous=this.GetMovingAverage(symbol,this.Period()+shift);
   return pt;
  }
//+------------------------------------------------------------------+
