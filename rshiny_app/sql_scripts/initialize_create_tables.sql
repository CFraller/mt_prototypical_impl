-- Create enumerations
DO $$ BEGIN
    CREATE TYPE AccountEnum AS ENUM ('Asset', 'Liability', 'Revenue', 'Expense', 'Equity');
	CREATE TYPE ResourceEnum AS ENUM ('MAT', 'PERS', 'TECH', 'MISC');
	CREATE TYPE MaterialEnum AS ENUM ('FG', 'RMA', 'RMB');
	CREATE TYPE UnitEnum AS ENUM ('PC', 'KG', 'L');
EXCEPTION
    WHEN DUPLICATE_OBJECT THEN NULL;
END $$;

-- Create master data tables
CREATE TABLE IF NOT EXISTS TB_General_Ledger_Account(
    AccountID INTEGER NOT NULL,
	AccountType AccountEnum NOT NULL,
    AccountName VARCHAR(100) NOT NULL,
	BookingMatrixNumber INTEGER NOT NULL,
    ResourceType ResourceEnum,
	CostType BOOLEAN,
    PRIMARY KEY (AccountID)
);

CREATE TABLE IF NOT EXISTS TB_Finished_Good(
    FinishedGoodID INTEGER NOT NULL,
    FinishedGoodName VARCHAR(100) NOT NULL,
    PRIMARY KEY (FinishedGoodID)
);

CREATE TABLE IF NOT EXISTS TB_Activity(
    ActivityID INTEGER NOT NULL,
    ActivityName VARCHAR(100) NOT NULL,
	Description VARCHAR(500) NOT NULL,
	ActivityCostDriver VARCHAR(100) NOT NULL,
    PRIMARY KEY (ActivityID)
);

CREATE TABLE IF NOT EXISTS TB_Routing(
    FinishedGoodID INTEGER NOT NULL,
	ActivityID INTEGER NOT NULL,
	ActivityCostDriverQuantity NUMERIC(16,8) NOT NULL,
	StdProdCoefPers NUMERIC(16,8) NOT NULL,
	StdProdCoefEquip NUMERIC(16,8) NOT NULL,
	FOREIGN KEY (ActivityID) REFERENCES TB_Activity(ActivityID),
	FOREIGN KEY (FinishedGoodID) REFERENCES TB_Finished_Good(FinishedGoodID),
    PRIMARY KEY (FinishedGoodID, ActivityID)
);

CREATE TABLE IF NOT EXISTS TB_Resource_Cost_Driver(
    ActivityID INTEGER NOT NULL,
    ResourceType ResourceEnum NOT NULL,
	Rate NUMERIC(16,8),  -- Calculate ex ante
	FOREIGN KEY (ActivityID) REFERENCES TB_Activity(ActivityID),
    PRIMARY KEY (ActivityID, ResourceType)
);

CREATE TABLE IF NOT EXISTS TB_Material(
    MaterialID INTEGER NOT NULL,
	MaterialName VARCHAR(100) NOT NULL,
	MaterialType MaterialEnum NOT NULL,
	Unit UnitEnum NOT NULL,
	UnitCost NUMERIC(16,8),
    PRIMARY KEY (MaterialID)
);

CREATE TABLE IF NOT EXISTS TB_Bill_Of_Material(
    FinishedGoodID INTEGER NOT NULL,
	MaterialID INTEGER NOT NULL,
	Quantity NUMERIC(16,8) NOT NULL,
	SuperordinateMaterialID INTEGER,
	FOREIGN KEY (FinishedGoodID) REFERENCES TB_Finished_Good(FinishedGoodID),
	FOREIGN KEY (MaterialID) REFERENCES TB_Material(MaterialID),
	FOREIGN KEY (SuperordinateMaterialID) REFERENCES TB_Material(MaterialID),
    PRIMARY KEY (FinishedGoodID, MaterialID)
);

-- Create transactional data tables 
CREATE TABLE IF NOT EXISTS TB_Planning_Period(
    PeriodID INTEGER NOT NULL,
	BudgetedParametersConfirmed BOOLEAN NOT NULL,
	ActualParametersConfirmed BOOLEAN NOT NULL,
	PreviousPeriodID INTEGER,
	FOREIGN KEY (PreviousPeriodID) REFERENCES TB_Planning_Period(PeriodID),
    PRIMARY KEY (PeriodID)
);

CREATE TABLE IF NOT EXISTS TB_Operating_Expense(
    PeriodID INTEGER NOT NULL,
	AccountID INTEGER NOT NULL,
	BudgetedExpense NUMERIC(16,8) NOT NULL,
	Variator NUMERIC(16,8) NOT NULL,
	ActualExpense NUMERIC(16,8),
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (AccountID) REFERENCES TB_General_Ledger_Account(AccountID),
    PRIMARY KEY (PeriodID, AccountID)
);

CREATE TABLE IF NOT EXISTS TB_Resource_Expense_Structure(
	PeriodID INTEGER NOT NULL,
	ResourceType ResourceEnum NOT NULL,
	Variator NUMERIC(16,8) NOT NULL,
	BudgetedResourceExpense NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	ActualResourceExpense NUMERIC(16,8), -- Calculate ex post
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	PRIMARY KEY (PeriodID, ResourceType)
);

CREATE TABLE IF NOT EXISTS TB_Production_Volume(
    PeriodID INTEGER NOT NULL,
	FinishedGoodID INTEGER NOT NULL,
	CapacityVolume NUMERIC(16,8) NOT NULL,
	BudgetedVolume NUMERIC(16,8) NOT NULL,
	ActualVolume NUMERIC(16,8),
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (FinishedGoodID) REFERENCES TB_Finished_Good(FinishedGoodID),
    PRIMARY KEY (PeriodID, FinishedGoodID)
);

CREATE TABLE IF NOT EXISTS TB_Activity_Level(
    PeriodID INTEGER NOT NULL,
	FinishedGoodID INTEGER NOT NULL,
	ActivityID INTEGER NOT NULL,
	CapacityActivityLevel NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	BudgetedActivityLevel NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	ActualActivityLevel NUMERIC(16,8), -- Calculate ex post
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (FinishedGoodID) REFERENCES TB_Finished_Good(FinishedGoodID),
	FOREIGN KEY (ActivityID) REFERENCES TB_Activity(ActivityID),
    PRIMARY KEY (PeriodID, FinishedGoodID, ActivityID)
);

CREATE TABLE IF NOT EXISTS TB_Cost_Pool(
    PeriodID INTEGER NOT NULL,
	ActivityID INTEGER NOT NULL,
	ResourceType ResourceEnum NOT NULL,
	BudgetedCostPoolExpense NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	Variator NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	ActualCostPoolExpense NUMERIC(16,8), -- Calculate ex post
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (ActivityID) REFERENCES TB_Activity(ActivityID),
    PRIMARY KEY (PeriodID, ActivityID, ResourceType)
);

CREATE TABLE IF NOT EXISTS TB_Activity_Pool(
    PeriodID INTEGER NOT NULL,
	ActivityID INTEGER NOT NULL,
	BudgetedActivityExpense NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	Variator NUMERIC(16,8) NOT NULL, -- Calculate ex ante
	CommittedExpense NUMERIC(16,8), -- Calculate ex ante
	FlexibleExpense NUMERIC(16,8), -- Calculate ex ante
	ActualActivityExpense NUMERIC(16,8), -- Calculate ex post
	CapacityActivityLevel NUMERIC(16,8), -- Calculate ex ante
	BudgetedActivityLevel NUMERIC(16,8), -- Calculate ex ante
	ActualActivityLevel NUMERIC(16,8), -- Calculate ex post
	CapacityDriverRate NUMERIC(16,8), -- Calculate ex ante
	BudgetedDriverRate NUMERIC(16,8), -- Calculate ex ante
	UnusedCapacity NUMERIC(16,8), -- Calculate ex ante
	CapacityUtilizationVariance NUMERIC(16,8), -- Calculate ex post
	ExpenseChargedToProducts NUMERIC(16,8), -- Calculate ex post
	FlexibleBudget NUMERIC(16,8), -- Calculate ex post
	SpendingVariance NUMERIC(16,8), -- Calculate ex post
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (ActivityID) REFERENCES TB_Activity(ActivityID),
    PRIMARY KEY (PeriodID, ActivityID)
);

CREATE TABLE IF NOT EXISTS TB_Cost_Object_Structure(
    PeriodID INTEGER NOT NULL,
	FinishedGoodID INTEGER NOT NULL,
	MaterialUnitExpense NUMERIC(16,8), -- Calculate ex ante
	CommittedUnitExpense NUMERIC(16,8), -- Calculate ex ante
	FlexibleUnitExpense NUMERIC(16,8), -- Calculate ex ante
	FOREIGN KEY (PeriodID) REFERENCES TB_Planning_Period(PeriodID),
	FOREIGN KEY (FinishedGoodID) REFERENCES TB_Finished_Good(FinishedGoodID),
	PRIMARY KEY(PeriodID, FinishedGoodID)
);
