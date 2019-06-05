-- Query aggregating results from database according to period
SELECT 
	TB_Activity_Pool_Position.PeriodID, 
	VolumeProduct1,
	VolumeProduct2,
	MaterialExpenseProduct1,
	MaterialExpenseProduct2,
	ExpenseChargedToProduct1,
	ExpenseChargedToProduct2,
	SUM(ExpenseChargedToProducts) AS ExpenseChargedToProducts,
	SUM(CommittedExpense) AS CommittedExpense, 
	SUM(FlexibleExpense) AS FlexibleExpense, 
	SUM(UnusedCapacity) AS UnusedCapacity, 
	SUM(CapacityUtilizationVariance) AS CapacityUtilizationVariance, 
	SUM(SpendingVariance) AS SpendingVariance, 
	SUM(FlexibleBudget) AS FlexibleBudget
FROM 
	TB_Activity_Pool_Position
JOIN
	(SELECT
		TB_Quantity_Structure.PeriodID,
		ActualVolume AS VolumeProduct1,
		(ActualVolume * MaterialUnitExpense) AS MaterialExpenseProduct1,
		(ActualVolume * (CommittedUnitExpense + FlexibleUnitExpense)) AS ExpenseChargedToProduct1
	FROM 
		TB_Quantity_Structure 
	JOIN
		TB_Cost_Object_Structure
			ON TB_Quantity_Structure.PeriodID = TB_Cost_Object_Structure.PeriodID AND TB_Quantity_Structure.FinishedGoodID = TB_Cost_Object_Structure.FinishedGoodID
	WHERE TB_Quantity_Structure.FinishedGoodID = 120
	) AS temp1
		ON TB_Activity_Pool_Position.PeriodID = temp1.PeriodID
JOIN
	(SELECT
		TB_Quantity_Structure.PeriodID,
		ActualVolume AS VolumeProduct2,
		(ActualVolume * MaterialUnitExpense) AS MaterialExpenseProduct2,
		(ActualVolume * (CommittedUnitExpense + FlexibleUnitExpense)) AS ExpenseChargedToProduct2
	FROM 
		TB_Quantity_Structure 
	JOIN
		TB_Cost_Object_Structure
			ON TB_Quantity_Structure.PeriodID = TB_Cost_Object_Structure.PeriodID AND TB_Quantity_Structure.FinishedGoodID = TB_Cost_Object_Structure.FinishedGoodID
	WHERE TB_Quantity_Structure.FinishedGoodID = 140
	) AS temp2
		ON TB_Activity_Pool_Position.PeriodID = temp2.PeriodID
GROUP BY 
	TB_Activity_Pool_Position.PeriodID, 
	VolumeProduct1,
	VolumeProduct2,
	MaterialExpenseProduct1,
	MaterialExpenseProduct2,
	ExpenseChargedToProduct1,
	ExpenseChargedToProduct2
ORDER BY TB_Activity_Pool_Position.PeriodID;
