//+------------------------------------------------------------------+
//|                                             PortfolioManager.mqh |
//|                                 Copyright © 2017, Matthew Kastor |
//|                                 https://github.com/matthewkastor |
//+------------------------------------------------------------------+
#property copyright "Matthew Kastor"
#property link      "https://github.com/matthewkastor"
#property strict

#include <PLManager\PLManager.mqh>
#include <Schedule\ScheduleSet.mqh>
#include <Signals\SignalSet.mqh>
#include <stdlib.mqh>
#include <Signals\BasketSignalScanner.mqh>
#include <BacktestOptimizations\BacktestOptimizations.mqh>
#include <BacktestOptimizations\BacktestOptimizationsConfig.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PortfolioManager
  {
private:
   BacktestOptimizationsConfig backtestConfig;
   bool              deleteLogger;
public:
   SymbolSet        *allowedSymbols;
   ScheduleSet      *schedule;
   OrderManager     *orderManager;
   PLManager        *plmanager;
   SignalSet        *signalSet;
   BasketSignalScanner *basketSignalScanner;
   BaseLogger       *logger;
   datetime          time;
   double            lotSize;
   bool              tradeEveryTick;
                     PortfolioManager(double lots,SymbolSet *aAllowedSymbolSet,ScheduleSet *aSchedule,OrderManager *aOrderManager,PLManager *aPlmanager,SignalSet *aSignalSet,BacktestOptimizationsConfig &backtestConfigs,BaseLogger *aLogger);
                    ~PortfolioManager();
   bool              Validate(ValidationResult *validationResult);
   bool              Validate();
   bool              ValidateAndLog();
   void              Initialize();
   void              Execute();
   bool              CanTrade();
   void              AllowExitsToBackslide(bool setTrueToMoveSLbackwardBySignal) { this.basketSignalScanner.disableExitsBacksliding=!setTrueToMoveSLbackwardBySignal; };
   bool              AllowExitsToBackslide() { return !this.basketSignalScanner.disableExitsBacksliding; };
   void              ClosePositionsOnOppositeSignal(bool setTrueToCloseOpenOrdersOnOppositeSignal) { this.basketSignalScanner.closePositionsOnOppositeSignal=setTrueToCloseOpenOrdersOnOppositeSignal; };
   bool              ClosePositionsOnOppositeSignal() { return this.basketSignalScanner.closePositionsOnOppositeSignal; };
   void              MaxOpenOrderCount(int max) { this.basketSignalScanner.maxOpenOrders=max; };
   int               MaxOpenOrderCount() { return this.basketSignalScanner.maxOpenOrders; };
   void              GridStepUpSizeInPricePercent(double percent) { this.basketSignalScanner.gridStepSizeUp=percent; };
   double            GridStepUpSizeInPricePercent() { return this.basketSignalScanner.gridStepSizeUp; };
   void              GridStepDownSizeInPricePercent(double percent) { this.basketSignalScanner.gridStepSizeDown=percent; };
   double            GridStepDownSizeInPricePercent() { return this.basketSignalScanner.gridStepSizeDown; };
   void              AverageUpStrategy(bool enableAverageUp) { this.basketSignalScanner.averageUp=enableAverageUp; };
   bool              AverageUpStrategy() { return this.basketSignalScanner.averageUp; };
   void              AverageDownStrategy(bool enableAverageDown) { this.basketSignalScanner.averageDown=enableAverageDown; };
   bool              AverageDownStrategy() { return this.basketSignalScanner.averageDown; };
   void              AllowHedging(bool enableHedging) { this.basketSignalScanner.hedgingAllowed=enableHedging; };
   bool              AllowHedging() { return this.basketSignalScanner.hedgingAllowed; };
   double            RiskRewardFilter() { return this.basketSignalScanner.filterRiskReward; };
   void              RiskRewardFilter(double riskReward) { this.basketSignalScanner.filterRiskReward=riskReward; };
   virtual double    CustomTestResult();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PortfolioManager::PortfolioManager(double lots,SymbolSet *aAllowedSymbolSet,ScheduleSet *aSchedule,OrderManager *aOrderManager,PLManager *aPlmanager,SignalSet *aSignalSet,BacktestOptimizationsConfig &backtestConfigs,BaseLogger *aLogger=NULL)
  {
   this.tradeEveryTick=true;
   this.lotSize=lots;
   this.allowedSymbols=aAllowedSymbolSet;
   this.schedule=aSchedule;
   this.orderManager=aOrderManager;
   this.plmanager=aPlmanager;
   this.signalSet=aSignalSet;
   this.basketSignalScanner=new BasketSignalScanner(this.allowedSymbols,this.signalSet,this.lotSize
                                                    ,false
                                                    ,false
                                                    ,1
                                                    ,1.25
                                                    ,1.25
                                                    ,false
                                                    ,false
                                                    ,false
                                                    ,1);
   if(aLogger==NULL)
     {
      this.logger=new BaseLogger();
      this.deleteLogger=true;
     }
   this.backtestConfig=backtestConfigs;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
PortfolioManager::~PortfolioManager()
  {
   delete this.basketSignalScanner;
   if(this.deleteLogger==true)
     {
      delete this.logger;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::Validate()
  {
   ValidationResult *validationResult=new ValidationResult();
   return this.Validate(validationResult);
   delete validationResult;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::Validate(ValidationResult *validationResult)
  {
   validationResult.Result=true;
   Comparators compare;

   bool omv=this.orderManager.Validate(validationResult);
   bool plv=this.plmanager.Validate(validationResult);
   bool sigv=this.signalSet.Validate(validationResult);

   validationResult.Result=(omv && plv && sigv);

   if(!compare.IsGreaterThan(this.lotSize,(double)0))
     {
      validationResult.AddMessage("Lots must be greater than zero.");
      validationResult.Result=false;
     }

   return validationResult.Result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PortfolioManager::ValidateAndLog()
  {
   string border[]=
     {
      "",
      "!~ !~ !~ !~ !~ User Settings validation failed ~! ~! ~! ~! ~!",
      ""
     };
   ValidationResult *v=new ValidationResult();
   bool out=this.Validate(v);
   if(out==false)
     {
      this.logger.Log(border);
      this.logger.Warn(v.Messages);
      this.logger.Log(border);
     }
   delete v;
   return out;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioManager::Initialize()
  {
   if(!this.ValidateAndLog())
     {
      ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PortfolioManager::Execute()
  {
   if(this.plmanager.CanTrade() && this.CanTrade())
     {
      if(this.tradeEveryTick || Time[0]!=this.time)
        {
         this.time=Time[0];
         if(this.schedule.IsActive(TimeCurrent()))
           {
            this.basketSignalScanner.Scan();
           }
        }
     }
   this.plmanager.Execute();
  }
//+------------------------------------------------------------------+
//|Rules to stop the bot from even trying to trade                   |
//+------------------------------------------------------------------+
bool PortfolioManager::CanTrade()
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PortfolioManager::CustomTestResult()
  {

   double days=PortfolioStats::HistoryDuration().ToDays();

   this.backtestConfig.FactorBy_GainsSlopeUpward_Granularity=((int)MathFloor(days/30.0));

   BacktestOptimizations bo(this.backtestConfig);

   return bo.GetScore();
  };
//+------------------------------------------------------------------+
