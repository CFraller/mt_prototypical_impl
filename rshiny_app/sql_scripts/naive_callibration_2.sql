-- Update resource expense structure with ActualOverheadExpenseResource
UPDATE TB_Resource_Expense_Structure
	SET ActualOverheadExpenseResource = temp.ActualOverheadExpenseResource
	FROM (SELECT TB_Account_Expense_Structure.PeriodID, TB_General_Ledger_Account.ResourceType, 
			SUM(TB_Account_Expense_Structure.ActualOverheadExpense) AS ActualOverheadExpenseResource 
		  FROM TB_General_Ledger_Account
			JOIN TB_Account_Expense_Structure
				ON TB_General_Ledger_Account.AccountID = TB_Account_Expense_Structure.AccountID
		  GROUP BY TB_General_Ledger_Account.ResourceType, TB_Account_Expense_Structure.PeriodID) AS temp
 	WHERE TB_Resource_Expense_Structure.PeriodID = temp.PeriodID 
	AND TB_Resource_Expense_Structure.ResourceType = temp.ResourceType;

-- Update cost pool position data with ActualOverheadExpenseResourceActivity
UPDATE TB_Cost_Pool_Position
	SET ActualOverheadExpenseResourceActivity = temp.ActualOverheadExpenseResourceActivity
	FROM (SELECT PeriodID, ActivityID, TB_Resource_Cost_Driver_Rate.ResourceType,
			SUM(ROUND(Rate*ActualOverheadExpenseResource, 2)) AS ActualOverheadExpenseResourceActivity,
			Variator
		  FROM TB_Resource_Cost_Driver_Rate
			JOIN TB_Resource_Expense_Structure
				ON TB_Resource_Cost_Driver_Rate.ResourceType = TB_Resource_Expense_Structure.ResourceType
		  GROUP BY PeriodID, ActivityID, TB_Resource_Cost_Driver_Rate.ResourceType, Variator) AS temp
	WHERE TB_Cost_Pool_Position.PeriodID = temp.PeriodID
	AND TB_Cost_Pool_Position.ActivityID = temp.ActivityID
	AND TB_Cost_Pool_Position.ResourceType = temp.ResourceType;

-- Update activity level structure data with ActualActivityLevel
UPDATE TB_Activity_Level_Structure
	SET ActualActivityLevel = temp.ActualActivityLevel
	FROM (SELECT PeriodID, TB_Quantity_Structure.FinishedGoodID, ActivityID, 
			ROUND(ActualVolume*ActivityCostDriverQuantity, 2) AS ActualActivityLevel
		  FROM TB_Quantity_Structure
			JOIN TB_Routing_Position
				ON TB_Quantity_Structure.FinishedGoodID = TB_Routing_Position.FinishedGoodID) AS temp
	WHERE TB_Activity_Level_Structure.PeriodID = temp.PeriodID 
	AND TB_Activity_Level_Structure.FinishedGoodID = temp.FinishedGoodID 
	AND TB_Activity_Level_Structure.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualOverheadExpenseActivity
UPDATE TB_Activity_Pool_Position
	SET ActualOverheadExpenseActivity = temp.ActualOverheadExpenseActivity
	FROM (SELECT TB_Cost_Pool_Position.PeriodID, TB_Cost_Pool_Position.ActivityID, 
			SUM(ActualOverheadExpenseResourceActivity) AS ActualOverheadExpenseActivity
		  FROM TB_Cost_Pool_Position
		  GROUP BY TB_Cost_Pool_Position.PeriodID, TB_Cost_Pool_Position.ActivityID) AS temp
	WHERE TB_Activity_Pool_Position.PeriodID = temp.PeriodID 
	AND TB_Activity_Pool_Position.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualActivityLevel
UPDATE TB_Activity_Pool_Position
	SET ActualActivityLevel = temp.ActualActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(ActualActivityLevel) AS ActualActivityLevel
			FROM TB_Activity_Level_Structure
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool_Position.ActivityID = temp.ActivityID AND TB_Activity_Pool_Position.PeriodID = temp.PeriodID;
	
-- Update activity pool position with CapacityUtilizationVariance
UPDATE TB_Activity_Pool_Position
	SET CapacityUtilizationVariance = ROUND((BudgetedActivityLevel - ActualActivityLevel) * CapacityDriverRate, 2);

-- Update activity pool position with ExpenseChargedToProducts
UPDATE TB_Activity_Pool_Position
	SET ExpenseChargedToProducts = ROUND((CapacityDriverRate + BudgetedDriverRate) * ActualActivityLevel, 2);

-- Update activity pool position with FlexibleBudget
UPDATE TB_Activity_Pool_Position
	SET FlexibleBudget = ROUND(CommittedExpense + (BudgetedDriverRate * ActualActivityLevel), 2);

-- Update activity pool position with SpendingVariance
UPDATE TB_Activity_Pool_Position
	SET SpendingVariance = ActualOverheadExpenseActivity - FlexibleBudget;
