-- CTE of the bill of material including a recursive query for ItemLevel and UnitCost calculation
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
SELECT DISTINCT FinishedGoodID, ItemLevel, MaterialID, MaterialName, MaterialType, Quantity, Unit, UnitCost 
FROM CTE_Bill_Of_Material
ORDER BY FinishedGoodID, ItemLevel;
