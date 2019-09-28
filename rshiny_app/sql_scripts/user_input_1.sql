-- Update resource cost driver rate table with rates for miscellaneous resources
UPDATE TB_Resource_Cost_Driver
	SET Rate = (SELECT 1.00/COUNT(ActivityID) FROM TB_Activity)
	WHERE ResourceType = 'MISC';
	
-- Insert resource expense structure data (transactional data)
INSERT INTO TB_Resource_Expense_Structure(PeriodID, ResourceType, Variator, BudgetedResourceExpense)
	SELECT TB_Operating_Expense.PeriodID, TB_General_Ledger_Account.ResourceType, 
		SUM(TB_Operating_Expense.BudgetedExpense*TB_Operating_Expense.Variator) / SUM(TB_Operating_Expense.BudgetedExpense) AS Variator,
		SUM(TB_Operating_Expense.BudgetedExpense) AS BudgetedResourceExpense 
	FROM TB_General_Ledger_Account
		JOIN TB_Operating_Expense
			ON TB_General_Ledger_Account.AccountID = TB_Operating_Expense.AccountID
	GROUP BY TB_General_Ledger_Account.ResourceType, TB_Operating_Expense.PeriodID
	ON CONFLICT (PeriodID, ResourceType) DO NOTHING;

-- Insert activity level structure data (transactional data)
INSERT INTO TB_Activity_Level(PeriodID, FinishedGoodID, ActivityID, CapacityActivityLevel, BudgetedActivityLevel)
	SELECT PeriodID, TB_Production_Volume.FinishedGoodID, ActivityID, 
		CapacityVolume*ActivityCostDriverQuantity AS CapacityActivityLevel, 
		BudgetedVolume*ActivityCostDriverQuantity AS BudgetedActivityLevel
	FROM TB_Production_Volume
		JOIN TB_Routing
			ON TB_Production_Volume.FinishedGoodID = TB_Routing.FinishedGoodID
	ON CONFLICT (PeriodID, FinishedGoodID, ActivityID) DO NOTHING;
	
-- Insert cost pool position data (transactional data)
INSERT INTO TB_Cost_Pool(PeriodID, ActivityID, ResourceType, BudgetedCostPoolExpense, Variator)
	SELECT PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType,
		SUM(Rate*BudgetedResourceExpense) AS BudgetedCostPoolExpense,
		Variator
	FROM TB_Resource_Cost_Driver
		JOIN TB_Resource_Expense_Structure
			ON TB_Resource_Cost_Driver.ResourceType = TB_Resource_Expense_Structure.ResourceType
	GROUP BY PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType, Variator
	ON CONFLICT (PeriodID, ActivityID, ResourceType) DO NOTHING;

-- Insert activity pool position data (transactional data) 
INSERT INTO TB_Activity_Pool(PeriodID, ActivityID, BudgetedActivityExpense, Variator)
	SELECT TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID, 
		SUM(BudgetedCostPoolExpense) AS BudgetedActivityExpense, 
		SUM(BudgetedCostPoolExpense*Variator) / SUM(BudgetedCostPoolExpense) AS Variator
	FROM TB_Cost_Pool
	GROUP BY TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID
	ON CONFLICT (PeriodID, ActivityID) DO NOTHING;

-- Update CommittedExpense in activity pool position data
UPDATE TB_Activity_Pool
	SET CommittedExpense = BudgetedActivityExpense - (Variator * BudgetedActivityExpense);

-- Update FlexibleExpense in activity pool position data
UPDATE TB_Activity_Pool
	SET FlexibleExpense = Variator * BudgetedActivityExpense;

-- Update CapacityActivityLevel in activity pool position data
UPDATE TB_Activity_Pool
	SET CapacityActivityLevel = temp.CapacityActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(CapacityActivityLevel) AS CapacityActivityLevel
			FROM TB_Activity_Level
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool.ActivityID = temp.ActivityID AND TB_Activity_Pool.PeriodID = temp.PeriodID;

-- Update BudgetedActivityLevel in activity pool position data
UPDATE TB_Activity_Pool
	SET BudgetedActivityLevel = temp.BudgetedActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(BudgetedActivityLevel) AS BudgetedActivityLevel
			FROM TB_Activity_Level
			GROUP BY PeriodID, ActivityID) AS temp
	WHERE TB_Activity_Pool.ActivityID = temp.ActivityID AND TB_Activity_Pool.PeriodID = temp.PeriodID;

-- Update CapacityDriverRate in activity pool position data
UPDATE TB_Activity_Pool
	SET CapacityDriverRate = CommittedExpense / CapacityActivityLevel;
	
-- Update BudgetedDriverRate in activity pool position data
UPDATE TB_Activity_Pool
	SET BudgetedDriverRate = FlexibleExpense / BudgetedActivityLevel;
	
-- Update UnusedCapacity in activity pool position data
UPDATE TB_Activity_Pool
	SET UnusedCapacity = (CapacityActivityLevel - BudgetedActivityLevel) * CapacityDriverRate;

-- Update cost object structure with MaterialUnitExpense
UPDATE TB_Cost_Object_Structure
	SET MaterialUnitExpense = temp.MaterialUnitExpense 
	FROM (
	WITH CTE_Bill_Of_Material AS(
	WITH RECURSIVE Recursion_Calculate_Unit_Costs AS (
		SELECT TB_Material.MaterialID, TB_Material.MaterialID AS SuperordinateMaterialID, (TB_Material.UnitCost*TB_Bill_Of_Material.Quantity) AS UnitCost, TB_Material.MaterialType
			FROM TB_Material
				JOIN TB_Bill_Of_Material
					ON TB_Material.MaterialID = TB_Bill_Of_Material.MaterialID
			WHERE TB_Material.UnitCost IS NULL
		UNION  ALL 
		SELECT Recursion_Calculate_Unit_Costs.MaterialID, TB_Material.MaterialID, (TB_Material.UnitCost*TB_Bill_Of_Material.Quantity) AS UnitCost, TB_Material.MaterialType
			FROM Recursion_Calculate_Unit_Costs
				JOIN TB_Bill_Of_Material 
					USING (SuperordinateMaterialID)
				JOIN TB_Material 
					ON TB_Material.MaterialID = TB_Bill_Of_Material.MaterialID
	),
    Descendants AS (
		SELECT MaterialID, SuperordinateMaterialID, 0 ItemLevel
			FROM TB_Bill_Of_Material
			WHERE SuperordinateMaterialID IS NULL
		UNION
		SELECT TB_Bill_Of_Material.MaterialID, TB_Bill_Of_Material.SuperordinateMaterialID, Descendants.ItemLevel+ 1
			FROM TB_Bill_Of_Material 
				INNER JOIN Descendants 
					ON TB_Bill_Of_Material.SuperordinateMaterialID = Descendants.MaterialID
    )
		SELECT TB_Bill_Of_Material.FinishedGoodID, Descendants.ItemLevel, TB_Material.MaterialID, TB_Material.MaterialName, TB_Material.MaterialType, TB_Bill_Of_Material.Quantity, TB_Material.Unit, 
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
			JOIN TB_Bill_Of_Material
				ON TB_Material.MaterialID = TB_Bill_Of_Material.MaterialID
			JOIN Descendants
				ON TB_Material.MaterialID = Descendants.MaterialID
		ORDER BY TB_Bill_Of_Material.FinishedGoodID, Descendants.ItemLevel, TB_Material.MaterialID, TB_Bill_Of_Material.SuperordinateMaterialID
	) 
	SELECT DISTINCT FinishedGoodID, UnitCost AS MaterialUnitExpense
	FROM CTE_Bill_Of_Material
	WHERE ItemLevel = 0
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID;

-- Update cost object structure with CommittedUnitExpense
UPDATE TB_Cost_Object_Structure
	SET CommittedUnitExpense = temp.CommittedUnitExpense 
	FROM (SELECT TB_Activity_Pool.PeriodID, 
			TB_Routing.FinishedGoodID,
			SUM(TB_Activity_Pool.CapacityDriverRate*TB_Routing.ActivityCostDriverQuantity) AS CommittedUnitExpense
		  FROM TB_Activity_Pool
			JOIN TB_Routing
				ON TB_Activity_Pool.ActivityID = TB_Routing.ActivityID
	      GROUP BY TB_Activity_Pool.PeriodID, TB_Routing.FinishedGoodID
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID AND TB_Cost_Object_Structure.PeriodID = temp.PeriodID;

-- Update cost object structure with FlexibleUnitExpense
UPDATE TB_Cost_Object_Structure
	SET FlexibleUnitExpense = temp.FlexibleUnitExpense 
	FROM (SELECT TB_Activity_Pool.PeriodID, 
			TB_Routing.FinishedGoodID,
			SUM(TB_Activity_Pool.BudgetedDriverRate*TB_Routing.ActivityCostDriverQuantity) AS FlexibleUnitExpense
		  FROM TB_Activity_Pool
			JOIN TB_Routing
				ON TB_Activity_Pool.ActivityID = TB_Routing.ActivityID
	      GROUP BY TB_Activity_Pool.PeriodID, TB_Routing.FinishedGoodID
	) AS temp
	WHERE TB_Cost_Object_Structure.FinishedGoodID = temp.FinishedGoodID AND TB_Cost_Object_Structure.PeriodID = temp.PeriodID;
