-- Update resource expense structure with ActuaResourceExpense
UPDATE TB_Resource_Expense_Structure
	SET ActualResourceExpense = temp.ActuaResourceExpense
	FROM (SELECT TB_Operating_Expense.PeriodID, TB_General_Ledger_Account.ResourceType, 
			SUM(TB_Operating_Expense.ActualExpense) AS ActualResourceExpense 
		  FROM TB_General_Ledger_Account
			JOIN TB_Operating_Expense
				ON TB_General_Ledger_Account.AccountID = TB_Operating_Expense.AccountID
		  GROUP BY TB_General_Ledger_Account.ResourceType, TB_Operating_Expense.PeriodID) AS temp
 	WHERE TB_Resource_Expense_Structure.PeriodID = temp.PeriodID 
	AND TB_Resource_Expense_Structure.ResourceType = temp.ResourceType;

-- Update cost pool position data with ActuaCostPoolExpense
UPDATE TB_Cost_Pool
	SET ActuaCostPoolExpense = temp.ActuaCostPoolExpense
	FROM (SELECT PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType,
			SUM(Rate*ActuaResourceExpense) AS ActuaCostPoolExpense,
			Variator
		  FROM TB_Resource_Cost_Driver
			JOIN TB_Resource_Expense_Structure
				ON TB_Resource_Cost_Driver.ResourceType = TB_Resource_Expense_Structure.ResourceType
		  GROUP BY PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType, Variator) AS temp
	WHERE TB_Cost_Pool.PeriodID = temp.PeriodID
	AND TB_Cost_Pool.ActivityID = temp.ActivityID
	AND TB_Cost_Pool.ResourceType = temp.ResourceType;

-- Update activity level structure data with ActualActivityLevel
UPDATE TB_Activity_Level_Structure
	SET ActualActivityLevel = temp.ActualActivityLevel
	FROM (SELECT PeriodID, TB_Production_Volume.FinishedGoodID, ActivityID, 
			ActualVolume*ActivityCostDriverQuantity AS ActualActivityLevel
		  FROM TB_Production_Volume
			JOIN TB_Routing
				ON TB_Production_Volume.FinishedGoodID = TB_Routing.FinishedGoodID) AS temp
	WHERE TB_Activity_Level_Structure.PeriodID = temp.PeriodID 
	AND TB_Activity_Level_Structure.FinishedGoodID = temp.FinishedGoodID 
	AND TB_Activity_Level_Structure.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualActivityExpense
UPDATE TB_Activity_Pool
	SET ActualActivityExpense = temp.ActualActivityExpense
	FROM (SELECT TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID, 
			SUM(ActuaCostPoolExpense) AS ActualActivityExpense
		  FROM TB_Cost_Pool
		  GROUP BY TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID) AS temp
	WHERE TB_Activity_Pool.PeriodID = temp.PeriodID 
	AND TB_Activity_Pool.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualActivityLevel
UPDATE TB_Activity_Pool
	SET ActualActivityLevel = temp.ActualActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(ActualActivityLevel) AS ActualActivityLevel
			FROM TB_Activity_Level_Structure
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool.ActivityID = temp.ActivityID AND TB_Activity_Pool.PeriodID = temp.PeriodID;
	
-- Update activity pool position with CapacityUtilizationVariance
UPDATE TB_Activity_Pool
	SET CapacityUtilizationVariance = (BudgetedActivityLevel - ActualActivityLevel) * CapacityDriverRate;

-- Update activity pool position with ExpenseChargedToProducts
UPDATE TB_Activity_Pool
	SET ExpenseChargedToProducts = (CapacityDriverRate + BudgetedDriverRate) * ActualActivityLevel;

-- Update activity pool position with FlexibleBudget
UPDATE TB_Activity_Pool
	SET FlexibleBudget = CommittedExpense + (BudgetedDriverRate * ActualActivityLevel);

-- Update activity pool position with SpendingVariance
UPDATE TB_Activity_Pool
	SET SpendingVariance = ActualActivityExpense - FlexibleBudget;
