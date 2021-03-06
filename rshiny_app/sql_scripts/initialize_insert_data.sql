-- Insert general ledger account data (master data)
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (040, 'Asset', 0, 'Equipment (Anlagen und Maschinen)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (110,'Asset', 1, 'Materials (Bezogene Ressourcen)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (150,'Asset', 1, 'Finished goods (Fertige Erzeugnisse)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (200,'Asset', 2, 'Receivables (Lieferforderungen)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (250,'Asset', 2, 'Input VAT (Vorsteuer)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (270,'Asset', 2, 'Cash (Kassa)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (280,'Asset', 2, 'Bank (Bank)') 
	ON CONFLICT (AccountID) DO NOTHING;	
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (330,'Liability', 3, 'Liabilities (Lieferverbindlichkeiten)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (350,'Liability', 3, 'VAT (Umsatzsteuer)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (352,'Liability', 3, 'Tax payable (Zahllast)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (400,'Revenue', 4, 'Revenue account (Umsatzerloese)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (450,'Revenue', 4, 'Inventory variation (Bestandsveraenderung)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType) 
	VALUES (510,'Expense', 5, 'Consumption materials (Materialaufwand)', 'MAT', FALSE) 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType) 
	VALUES (699,'Expense', 6, 'Discharge personnel (Personalaufwand)', 'PERS', TRUE) 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType) 
	VALUES (700,'Expense', 7, 'Depreciation (Abschreibung)', 'TECH', TRUE) 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType) 
	VALUES (709,'Expense', 7, 'Operating expenses (Betriebsaufwand)', 'TECH', TRUE) 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType) 
	VALUES (720,'Expense', 7, 'Maintenance costs (Instandhaltungskosten)', 'MISC', TRUE) 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName, ResourceType, CostType)  
	VALUES (798,'Expense', 7, 'Administrative expenses (Verwaltungsaufwand)', 'MISC', TRUE)  
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (900,'Equity', 9, 'Equity (Eigenkapital)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (980,'Equity', 9, 'Opening balance sheet (Eroeffnungsbilanzkonto)') 
	ON CONFLICT (AccountID) DO NOTHING;
INSERT INTO TB_General_Ledger_Account (AccountID, AccountType, BookingMatrixNumber, AccountName) 
	VALUES (985,'Equity', 9, 'Closing balance sheet (Schlussbilanzkonto)') 
	ON CONFLICT (AccountID) DO NOTHING;

-- Insert finished good data (master data)
INSERT INTO TB_Finished_Good (FinishedGoodID, FinishedGoodName) 
	VALUES (120, 'Slot Car X1') 
	ON CONFLICT (FinishedGoodID) DO NOTHING;
INSERT INTO TB_Finished_Good (FinishedGoodID, FinishedGoodName) 
	VALUES (140, 'Slot Car Z2 Premium') 
	ON CONFLICT (FinishedGoodID) DO NOTHING;

-- Insert activity data (master data)
INSERT INTO TB_Activity (ActivityID, ActivityName, Description, ActivityCostDriver) 
	VALUES (10, 'Staging', 'Provide materials according to picking list', 'Number of items') 
	ON CONFLICT (ActivityID) DO NOTHING;
INSERT INTO TB_Activity (ActivityID, ActivityName, Description, ActivityCostDriver) 
	VALUES (20, 'Setting up', 'Setting up of the machines', 'Setups') 
	ON CONFLICT (ActivityID) DO NOTHING;
INSERT INTO TB_Activity (ActivityID, ActivityName, Description, ActivityCostDriver) 
	VALUES (30, 'Machining', 'Produce the Drive Unit', 'Machine hours') 
	ON CONFLICT (ActivityID) DO NOTHING;
INSERT INTO TB_Activity (ActivityID, ActivityName, Description, ActivityCostDriver) 
	VALUES (40, 'Assembling', 'Assemble Drive Unit, Front Unit, Undercarriage to finished Slot Car', 'Labor hours') 
	ON CONFLICT (ActivityID) DO NOTHING;
INSERT INTO TB_Activity (ActivityID, ActivityName, Description, ActivityCostDriver) 
	VALUES (50, 'Inspection', 'Quality inspection of the finished Slot Car', 'Proportion of inspections') 
	ON CONFLICT (ActivityID) DO NOTHING;

-- Insert routing data (master data)
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (120, 10, 10.00, 0.005, 0.010) 
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (120, 20, 0.10, 0.030, 0.075) 
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (120, 30, 3.00, 0.080, 0.275)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (120, 40, 4.00, 0.275, 0.090)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (120, 50, 0.25, 0.110, 0.050)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (140, 10, 10.00, 0.005, 0.010) 
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (140, 20, 0.25, 0.030, 0.075) 
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (140, 30, 4.00, 0.080, 0.275)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (140, 40, 6.00, 0.275, 0.090)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Routing (FinishedGoodID, ActivityID, ActivityCostDriverQuantity, StdProdCoefPers, StdProdCoefEquip) 
	VALUES (140, 50, 1.00, 0.110, 0.050)  
	ON CONFLICT (ActivityID, FinishedGoodID) DO NOTHING;
	
-- Insert resource cost driver rate data (master data)
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (10, 'PERS')
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (10, 'TECH') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (10, 'MISC') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (20, 'PERS') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (20, 'TECH') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (20, 'MISC') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (30, 'PERS') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (30, 'TECH') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (30, 'MISC') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (40, 'PERS') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (40, 'TECH') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (40, 'MISC') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (50, 'PERS') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (50, 'TECH') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;
INSERT INTO TB_Resource_Cost_Driver (ActivityID, ResourceType) 
	VALUES (50, 'MISC') 
	ON CONFLICT (ActivityID, ResourceType) DO NOTHING;

-- Insert material data (master data) 
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1201000, 'Slot Car X1', 'FG', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1201100, 'Body X-Series', 'RMA', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1201110, 'Front Unit - Blue', 'RMB', 'PC', 70.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1201120, 'Drive Unit X1', 'RMA', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1201121, 'Motor E500', 'RMB', 'PC', 85.50) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1201200, 'Undercarriage X-Series', 'RMB', 'PC', 138.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1401000, 'Slot Car Z2 Premium', 'FG', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1401100, 'Body Z-Series', 'RMA', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1401110, 'Front Unit - Red', 'RMB', 'PC', 100.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit) 
	VALUES (1401120, 'Drive Unit Z2', 'RMA', 'PC') 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1401121, 'Motor E700', 'RMB', 'PC', 196.50) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1401200, 'Undercarriage Z-Series', 'RMB', 'PC', 217.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1001001, 'Hexagon Screw', 'RMB', 'KG', 4.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1001002, 'Hexagon Nut', 'RMB', 'KG', 4.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1001003, 'Washer', 'RMB', 'KG', 4.00) 
	ON CONFLICT (MaterialID) DO NOTHING;
INSERT INTO TB_Material (MaterialID, MaterialName, MaterialType, Unit, UnitCost) 
	VALUES (1001004, 'Adhesives', 'RMB', 'L', 10.00) 
	ON CONFLICT (MaterialID) DO NOTHING;

-- Insert bill of material data into master data tables 
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity)
	VALUES (120, 1201000, 1.00) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1201100, 1.00, 1201000) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1201110, 1.00, 1201100) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1201120, 1.00, 1201100) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1201121, 1.00, 1201120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1001001, 0.25, 1201120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1001002, 0.65, 1201120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1001003, 0.10, 1201120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1001004, 0.25, 1201120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (120, 1201200, 1.00, 1201000) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity)
	VALUES (140, 1401000, 1.00) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1401100, 1.00, 1401000) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1401110, 1.00, 1401100) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1401120, 1.00, 1401100) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1401121, 1.00, 1401120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1001001, 0.25, 1401120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1001002, 0.65, 1401120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1001003, 0.10, 1401120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1001004, 0.25, 1401120) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;
INSERT INTO TB_Bill_Of_Material (FinishedGoodID, MaterialID, Quantity, SuperordinateMaterialID)
	VALUES (140, 1401200, 1.00, 1401000) 
	ON CONFLICT (FinishedGoodID, MaterialID) DO NOTHING;

-- Update resource cost driver rate table with rates for capacity resources
UPDATE TB_Resource_Cost_Driver
	SET Rate = (SELECT SUM(StdProdCoefPers) FROM TB_Routing WHERE TB_Routing.ActivityID = TB_Resource_Cost_Driver.ActivityID)
	WHERE ResourceType = 'PERS';
UPDATE TB_Resource_Cost_Driver
	SET Rate = (SELECT SUM(StdProdCoefEquip) FROM TB_Routing WHERE TB_Routing.ActivityID = TB_Resource_Cost_Driver.ActivityID)
	WHERE ResourceType = 'TECH';
	
-- Insert planning period data (transactional data)
INSERT INTO TB_Planning_Period (PeriodID, BudgetedParametersConfirmed, ActualParametersConfirmed)
	VALUES (0, TRUE, TRUE) 
	ON CONFLICT (PeriodID) DO NOTHING;

-- Insert quantity structure data (transactional data)
INSERT INTO TB_Production_Volume(PeriodID, FinishedGoodID, CapacityVolume, BudgetedVolume)
	VALUES (0, 120, 500.00, 480.00) 
	ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
INSERT INTO TB_Production_Volume(PeriodID, FinishedGoodID, CapacityVolume, BudgetedVolume)
	VALUES (0, 140, 200.00, 195.00) 
	ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
	
-- Insert expense structure data (transactional data)
INSERT INTO TB_Operating_Expense(PeriodID, AccountID, BudgetedExpense, Variator)
	VALUES (0, 699, 320000.00, 0.30) 
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
INSERT INTO TB_Operating_Expense(PeriodID, AccountID, BudgetedExpense, Variator)
	VALUES (0, 700, 280000.00, 0.20) 
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
INSERT INTO TB_Operating_Expense(PeriodID, AccountID, BudgetedExpense, Variator)
	VALUES (0, 709, 55000.00, 0.20) 
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
INSERT INTO TB_Operating_Expense(PeriodID, AccountID, BudgetedExpense, Variator)
	VALUES (0, 720, 25000.00, 0.50) 
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
INSERT INTO TB_Operating_Expense(PeriodID, AccountID, BudgetedExpense, Variator)
	VALUES (0, 798, 80000.00, 0.50) 
	ON CONFLICT (PeriodID, AccountID) DO NOTHING;
	
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

-- Update quantity structure data with ActualVolume
UPDATE TB_Production_Volume
	SET ActualVolume = 450.00
	WHERE PeriodID = 0 AND FinishedGoodID = 120; 
UPDATE TB_Production_Volume
	SET ActualVolume = 185.00
	WHERE PeriodID = 0 AND FinishedGoodID = 140; 
	
-- Update expense structure data with ActualExpense 
UPDATE TB_Operating_Expense
	SET ActualExpense = 300000.00
	WHERE PeriodID = 0 AND AccountID = 699; 
UPDATE TB_Operating_Expense
	SET ActualExpense = 275000.00
	WHERE PeriodID = 0 AND AccountID = 700;
UPDATE TB_Operating_Expense
	SET ActualExpense = 50000.00
	WHERE PeriodID = 0 AND AccountID = 709; 
UPDATE TB_Operating_Expense
	SET ActualExpense = 15000.00
	WHERE PeriodID = 0 AND AccountID = 720; 
UPDATE TB_Operating_Expense
	SET ActualExpense = 60000.00
	WHERE PeriodID = 0 AND AccountID = 798; 

-- Update resource expense structure with ActualResourceExpense
UPDATE TB_Resource_Expense_Structure
	SET ActualResourceExpense = temp.ActualResourceExpense
	FROM (SELECT TB_Operating_Expense.PeriodID, TB_General_Ledger_Account.ResourceType, 
			SUM(TB_Operating_Expense.ActualExpense) AS ActualResourceExpense 
		  FROM TB_General_Ledger_Account
			JOIN TB_Operating_Expense
				ON TB_General_Ledger_Account.AccountID = TB_Operating_Expense.AccountID
		  GROUP BY TB_General_Ledger_Account.ResourceType, TB_Operating_Expense.PeriodID) AS temp
 	WHERE TB_Resource_Expense_Structure.PeriodID = temp.PeriodID 
	AND TB_Resource_Expense_Structure.ResourceType = temp.ResourceType;

-- Update cost pool position data with ActualCostPoolExpense
UPDATE TB_Cost_Pool
	SET ActualCostPoolExpense = temp.ActualCostPoolExpense
	FROM (SELECT PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType,
			SUM(Rate*ActualResourceExpense) AS ActualCostPoolExpense,
			Variator
		  FROM TB_Resource_Cost_Driver
			JOIN TB_Resource_Expense_Structure
				ON TB_Resource_Cost_Driver.ResourceType = TB_Resource_Expense_Structure.ResourceType
		  GROUP BY PeriodID, ActivityID, TB_Resource_Cost_Driver.ResourceType, Variator) AS temp
	WHERE TB_Cost_Pool.PeriodID = temp.PeriodID
	AND TB_Cost_Pool.ActivityID = temp.ActivityID
	AND TB_Cost_Pool.ResourceType = temp.ResourceType;

-- Update activity level structure data with ActualActivityLevel
UPDATE TB_Activity_Level
	SET ActualActivityLevel = temp.ActualActivityLevel
	FROM (SELECT PeriodID, TB_Production_Volume.FinishedGoodID, ActivityID, 
			ActualVolume*ActivityCostDriverQuantity AS ActualActivityLevel
		  FROM TB_Production_Volume
			JOIN TB_Routing
				ON TB_Production_Volume.FinishedGoodID = TB_Routing.FinishedGoodID) AS temp
	WHERE TB_Activity_Level.PeriodID = temp.PeriodID 
	AND TB_Activity_Level.FinishedGoodID = temp.FinishedGoodID 
	AND TB_Activity_Level.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualActivityExpense
UPDATE TB_Activity_Pool
	SET ActualActivityExpense = temp.ActualActivityExpense
	FROM (SELECT TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID, 
			SUM(ActualCostPoolExpense) AS ActualActivityExpense
		  FROM TB_Cost_Pool
		  GROUP BY TB_Cost_Pool.PeriodID, TB_Cost_Pool.ActivityID) AS temp
	WHERE TB_Activity_Pool.PeriodID = temp.PeriodID 
	AND TB_Activity_Pool.ActivityID = temp.ActivityID;

-- Update activity pool position with ActualActivityLevel
UPDATE TB_Activity_Pool
	SET ActualActivityLevel = temp.ActualActivityLevel 
	FROM (SELECT PeriodID, ActivityID, SUM(ActualActivityLevel) AS ActualActivityLevel
			FROM TB_Activity_Level
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
	SET FlexibleBudget = (CommittedExpense + (BudgetedDriverRate * ActualActivityLevel));

-- Update activity pool position with SpendingVariance
UPDATE TB_Activity_Pool
	SET SpendingVariance = ActualActivityExpense - FlexibleBudget;
