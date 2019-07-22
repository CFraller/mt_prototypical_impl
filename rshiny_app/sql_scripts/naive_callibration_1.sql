-- Insert quantity structure data (transactional data)
INSERT INTO TB_Quantity_Structure(PeriodID, FinishedGoodID, CapacityVolume, BudgetedVolume)
	SELECT TB_Planning_Period.PeriodID, FinishedGoodID, CapacityVolume, ActualVolume
	FROM TB_Planning_Period
		JOIN TB_Quantity_Structure
			ON TB_Planning_Period.PreviousPeriodID = TB_Quantity_Structure.PeriodID
	ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
	
-- Insert expense structure data (transactional data)
INSERT INTO TB_Account_Expense_Structure(PeriodID, AccountID, BudgetedOverheadExpense, Variator)
	SELECT TB_Planning_Period.PeriodID, AccountID, ActualOverheadExpense, Variator
	FROM TB_Planning_Period
		JOIN TB_Account_Expense_Structure
			ON TB_Planning_Period.PreviousPeriodID = TB_Account_Expense_Structure.PeriodID
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
	
-- Update resource cost driver rate table with rates for miscellaneous resources
UPDATE TB_Resource_Cost_Driver_Rate
	SET Rate = (SELECT 1.00/COUNT(ActivityID) FROM TB_Activity)
	WHERE ResourceType = 'MISC';
	
-- Insert resource expense structure data (transactional data)
INSERT INTO TB_Resource_Expense_Structure(PeriodID, ResourceType, Variator, BudgetedOverheadExpenseResource)
	SELECT TB_Account_Expense_Structure.PeriodID, TB_General_Ledger_Account.ResourceType, 
		SUM(TB_Account_Expense_Structure.Variator) / COUNT(TB_General_Ledger_Account.ResourceType) AS Variator ,
		SUM(TB_Account_Expense_Structure.BudgetedOverheadExpense) AS BudgetedOverheadExpenseResource 
	FROM TB_General_Ledger_Account
		JOIN TB_Account_Expense_Structure
			ON TB_General_Ledger_Account.AccountID = TB_Account_Expense_Structure.AccountID
	GROUP BY TB_General_Ledger_Account.ResourceType, TB_Account_Expense_Structure.PeriodID
	ON CONFLICT (PeriodID, ResourceType) DO NOTHING;

-- Insert activity level structure data (transactional data)
INSERT INTO TB_Activity_Level_Structure(PeriodID, FinishedGoodID, ActivityID, CapacityActivityLevel, BudgetedActivityLevel)
	SELECT PeriodID, TB_Quantity_Structure.FinishedGoodID, ActivityID, 
		CapacityVolume*ActivityCostDriverQuantity AS CapacityActivityLevel, 
		BudgetedVolume*ActivityCostDriverQuantity AS BudgetedActivityLevel
	FROM TB_Quantity_Structure
		JOIN TB_Routing_Position
			ON TB_Quantity_Structure.FinishedGoodID = TB_Routing_Position.FinishedGoodID
	ON CONFLICT (PeriodID, FinishedGoodID, ActivityID) DO NOTHING;
	
-- Insert cost pool position data (transactional data)
INSERT INTO TB_Cost_Pool_Position(PeriodID, ActivityID, ResourceType, BudgetedOverheadExpenseResourceActivity, Variator)
	SELECT PeriodID, ActivityID, TB_Resource_Cost_Driver_Rate.ResourceType,
		SUM(Rate*BudgetedOverheadExpenseResource) AS BudgetedOverheadExpenseResourceActivity,
		Variator
	FROM TB_Resource_Cost_Driver_Rate
		JOIN TB_Resource_Expense_Structure
			ON TB_Resource_Cost_Driver_Rate.ResourceType = TB_Resource_Expense_Structure.ResourceType
	GROUP BY PeriodID, ActivityID, TB_Resource_Cost_Driver_Rate.ResourceType, Variator
	ON CONFLICT (PeriodID, ActivityID, ResourceType) DO NOTHING;

-- Insert activity pool position data (transactional data) 
INSERT INTO TB_Activity_Pool_Position(PeriodID, ActivityID, BudgetedOverheadExpenseActivity, Variator)
	SELECT TB_Cost_Pool_Position.PeriodID, TB_Cost_Pool_Position.ActivityID, 
		SUM(BudgetedOverheadExpenseResourceActivity) AS BudgetedOverheadExpenseActivity, 
		SUM(BudgetedOverheadExpenseResourceActivity*Variator) / SUM(BudgetedOverheadExpenseResourceActivity) AS Variator
	FROM TB_Cost_Pool_Position
	GROUP BY TB_Cost_Pool_Position.PeriodID, TB_Cost_Pool_Position.ActivityID
	ON CONFLICT (PeriodID, ActivityID) DO NOTHING;

-- Update CommittedExpense in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET CommittedExpense = BudgetedOverheadExpenseActivity - (Variator * BudgetedOverheadExpenseActivity);

-- Update FlexibleExpense in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET FlexibleExpense = Variator * BudgetedOverheadExpenseActivity;

-- Update CapacityActivityLevel in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET CapacityActivityLevel = temp.CapacityActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(CapacityActivityLevel) AS CapacityActivityLevel
			FROM TB_Activity_Level_Structure
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool_Position.ActivityID = temp.ActivityID AND TB_Activity_Pool_Position.PeriodID = temp.PeriodID;

-- Update BudgetedActivityLevel in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET BudgetedActivityLevel = temp.BudgetedActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(BudgetedActivityLevel) AS BudgetedActivityLevel
			FROM TB_Activity_Level_Structure
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool_Position.ActivityID = temp.ActivityID AND TB_Activity_Pool_Position.PeriodID = temp.PeriodID;

-- Update CapacityDriverRate in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET CapacityDriverRate = CommittedExpense / CapacityActivityLevel;
	
-- Update BudgetedDriverRate in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET BudgetedDriverRate = FlexibleExpense / BudgetedActivityLevel;
	
-- Update UnusedCapacity in activity pool position data
UPDATE TB_Activity_Pool_Position
	SET UnusedCapacity = (CapacityActivityLevel - BudgetedActivityLevel) * CapacityDriverRate;

-- Insert cost object structure data (transactional data)
INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
	VALUES (0, 120) 
	ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
	VALUES (0, 140) 
	ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;

-- Update cost object structure with MaterialUnitExpense
UPDATE TB_Cost_Object_Structure
	SET MaterialUnitExpense = temp.MaterialUnitExpense 
	FROM (
	WITH CTE_Bill_Of_Material AS(
	WITH RECURSIVE Recursion_Calculate_Unit_Costs AS (
		SELECT TB_Material.MaterialID, TB_Material.MaterialID AS SuperordinateMaterialID, (TB_Material.UnitCost*TB_Bill_Of_Material_Position.Quantity) AS UnitCost, TB_Material.MaterialType
			FROM TB_Material
				JOIN TB_Bill_Of_Material_Position
					ON TB_Material.MaterialID = TB_Bill_Of_Material_Position.MaterialID
			WHERE TB_Material.UnitCost IS NULL
		UNION  ALL 
		SELECT Recursion_Calculate_Unit_Costs.MaterialID, TB_Material.MaterialID, (TB_Material.UnitCost*TB_Bill_Of_Material_Position.Quantity) AS UnitCost, TB_Material.MaterialType
			FROM Recursion_Calculate_Unit_Costs
				JOIN TB_Bill_Of_Material_Position 
					USING (SuperordinateMaterialID)
				JOIN TB_Material 
					ON TB_Material.MaterialID = TB_Bill_Of_Material_Position.MaterialID
	),
    Descendants AS (
		SELECT MaterialID, SuperordinateMaterialID, 0 ItemLevel
			FROM TB_Bill_Of_Material_Position
			WHERE SuperordinateMaterialID IS NULL
		UNION
		SELECT TB_Bill_Of_Material_Position.MaterialID, TB_Bill_Of_Material_Position.SuperordinateMaterialID, Descendants.ItemLevel+ 1
			FROM TB_Bill_Of_Material_Position 
				INNER JOIN Descendants 
					ON TB_Bill_Of_Material_Position.SuperordinateMaterialID = Descendants.MaterialID
    )
		SELECT TB_Bill_Of_Material_Position.FinishedGoodID, Descendants.ItemLevel, TB_Material.MaterialID, TB_Material.MaterialName, TB_Material.MaterialType, TB_Bill_Of_Material_Position.Quantity, TB_Material.Unit, 
				CASE 
				WHEN TB_Material.UnitCost IS NULL THEN 
				(SELECT UnitCost 
					FROM 
						(SELECT Recursion_Calculate_Unit_Costs.MaterialID, SUM(Recursion_Calculate_Unit_Costs.UnitCost) AS UnitCost 
							FROM Recursion_Calculate_Unit_Costs 
							WHERE Recursion_Calculate_Unit_Costs.MaterialID = TB_Material.MaterialID 
							GROUP BY Recursion_Calculate_Unit_Costs.MaterialID
						) AS temp
				) 
				ELSE TB_Material.UnitCost 
				END AS UnitCost
		FROM TB_Material
			JOIN TB_Bill_Of_Material_Position
				ON TB_Material.MaterialID = TB_Bill_Of_Material_Position.MaterialID
			JOIN Descendants
				ON TB_Material.MaterialID = Descendants.MaterialID
		ORDER BY TB_Bill_Of_Material_Position.FinishedGoodID, Descendants.ItemLevel, TB_Material.MaterialID, TB_Bill_Of_Material_Position.SuperordinateMaterialID
	) 
	SELECT DISTINCT FinishedGoodID, UnitCost AS MaterialUnitExpense
	FROM CTE_Bill_Of_Material
	WHERE ItemLevel = 0
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID;

-- Update cost object structure with CommittedUnitExpense
UPDATE TB_Cost_Object_Structure
	SET CommittedUnitExpense = temp.CommittedUnitExpense 
	FROM (SELECT TB_Activity_Pool_Position.PeriodID, 
			TB_Routing_Position.FinishedGoodID,
			SUM(TB_Activity_Pool_Position.CapacityDriverRate*TB_Routing_Position.ActivityCostDriverQuantity) AS CommittedUnitExpense
		  FROM TB_Activity_Pool_Position
			JOIN TB_Routing_Position
				ON TB_Activity_Pool_Position.ActivityID = TB_Routing_Position.ActivityID
	      GROUP BY TB_Activity_Pool_Position.PeriodID, TB_Routing_Position.FinishedGoodID
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID AND TB_Cost_Object_Structure.PeriodID = temp.PeriodID;

-- Update cost object structure with FlexibleUnitExpense
UPDATE TB_Cost_Object_Structure
	SET FlexibleUnitExpense = temp.FlexibleUnitExpense 
	FROM (SELECT TB_Activity_Pool_Position.PeriodID, 
			TB_Routing_Position.FinishedGoodID,
			SUM(TB_Activity_Pool_Position.BudgetedDriverRate*TB_Routing_Position.ActivityCostDriverQuantity) AS FlexibleUnitExpense
		  FROM TB_Activity_Pool_Position
			JOIN TB_Routing_Position
				ON TB_Activity_Pool_Position.ActivityID = TB_Routing_Position.ActivityID
	      GROUP BY TB_Activity_Pool_Position.PeriodID, TB_Routing_Position.FinishedGoodID
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID AND TB_Cost_Object_Structure.PeriodID = temp.PeriodID;
