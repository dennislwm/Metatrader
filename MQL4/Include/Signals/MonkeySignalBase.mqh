//+------------------------------------------------------------------+
//|                                             MonkeySignalBase.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <Common\OrderManager.mqh>
#include <Common\Comparators.mqh>
#include <Signals\AbstractSignal.mqh>
#include <Signals\Config\MonkeySignalConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MonkeySignalBase : public AbstractSignal
  {
public:
                     MonkeySignalBase(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL);
   virtual bool      DoesSignalMeetRequirements();
   virtual bool      Validate(ValidationResult *v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MonkeySignalBase::MonkeySignalBase(MonkeySignalConfig &config,AbstractSignal *aSubSignal=NULL):AbstractSignal(config,aSubSignal)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MonkeySignalBase::Validate(ValidationResult *v)
  {
   AbstractSignal::Validate(v);
   return v.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MonkeySignalBase::DoesSignalMeetRequirements()
  {
   if(!(AbstractSignal::DoesSignalMeetRequirements()))
     {
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
