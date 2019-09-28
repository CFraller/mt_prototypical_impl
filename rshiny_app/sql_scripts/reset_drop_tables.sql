-- Drop transactional data tables
DROP TABLE IF EXISTS TB_Cost_Object_Structure;
DROP TABLE IF EXISTS TB_Activity_Pool;
DROP TABLE IF EXISTS TB_Cost_Pool;
DROP TABLE IF EXISTS TB_Activity_Level;
DROP TABLE IF EXISTS TB_Production_Volume;
DROP TABLE IF EXISTS TB_Resource_Expense_Structure;
DROP TABLE IF EXISTS TB_Operating_Expense;
DROP TABLE IF EXISTS TB_Planning_Period;

-- Drop master data tables
DROP TABLE IF EXISTS TB_Bill_Of_Material;
DROP TABLE IF EXISTS TB_Material;
DROP TABLE IF EXISTS TB_Routing;
DROP TABLE IF EXISTS TB_Resource_Cost_Driver;
DROP TABLE IF EXISTS TB_Activity;
DROP TABLE IF EXISTS TB_Finished_Good;
DROP TABLE IF EXISTS TB_General_Ledger_Account;

-- Drop enumerations
DROP TYPE IF EXISTS AccountEnum;
DROP TYPE IF EXISTS ResourceEnum;
DROP TYPE IF EXISTS MaterialEnum;
DROP TYPE IF EXISTS UnitEnum;
