-- Query aggregating results from database according to period
SELECT 
	TB_Activity_Pool.PeriodID, 
	VolumeProduct1,
	VolumeProduct2,
	MaterialExpenseProduct1,
	MaterialExpenseProduct2,
	ExpenseChargedToProduct1,
	ExpenseChargedToProduct2,
	(ExpenseChargedToProduct1 + ExpenseChargedToProduct2) AS ExpenseChargedToProducts,
	SUM(CommittedExpense) AS CommittedExpense, 
	SUM(FlexibleExpense) AS FlexibleExpense, 
	SUM(UnusedCapacity) AS UnusedCapacity, 
	SUM(CapacityUtilizationVariance) AS CapacityUtilizationVariance, 
	SUM(FlexibleBudget) AS FlexibleBudget,
	SUM(SpendingVariance) AS SpendingVariance
FROM 
	TB_Activity_Pool
JOIN
	(SELECT
		TB_Production_Volume.PeriodID,
		ActualVolume AS VolumeProduct1,
		(ActualVolume * MaterialUnitExpense) AS MaterialExpenseProduct1,
		(ActualVolume * (CommittedUnitExpense + FlexibleUnitExpense)) AS ExpenseChargedToProduct1
	FROM 
		TB_Production_Volume 
	JOIN
		TB_Cost_Object_Structure
			ON TB_Production_Volume.PeriodID = TB_Cost_Object_Structure.PeriodID AND TB_Production_Volume.FinishedGoodID = TB_Cost_Object_Structure.FinishedGoodID
	WHERE TB_Production_Volume.FinishedGoodID = 120
	) AS temp1
		ON TB_Activity_Pool.PeriodID = temp1.PeriodID
JOIN
	(SELECT
		TB_Production_Volume.PeriodID,
		ActualVolume AS VolumeProduct2,
		(ActualVolume * MaterialUnitExpense) AS MaterialExpenseProduct2,
		(ActualVolume * (CommittedUnitExpense + FlexibleUnitExpense)) AS ExpenseChargedToProduct2
	FROM 
		TB_Production_Volume 
	JOIN
		TB_Cost_Object_Structure
			ON TB_Production_Volume.PeriodID = TB_Cost_Object_Structure.PeriodID AND TB_Production_Volume.FinishedGoodID = TB_Cost_Object_Structure.FinishedGoodID
	WHERE TB_Production_Volume.FinishedGoodID = 140
	) AS temp2
		ON TB_Activity_Pool.PeriodID = temp2.PeriodID
GROUP BY 
	TB_Activity_Pool.PeriodID, 
	VolumeProduct1,
	VolumeProduct2,
	MaterialExpenseProduct1,
	MaterialExpenseProduct2,
	ExpenseChargedToProduct1,
	ExpenseChargedToProduct2
ORDER BY TB_Activity_Pool.PeriodID;
