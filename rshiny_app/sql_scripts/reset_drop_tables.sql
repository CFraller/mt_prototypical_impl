-- Drop transactional data tables
DROP TABLE IF EXISTS TB_Cost_Object_Structure;
DROP TABLE IF EXISTS TB_Activity_Pool_Position;
DROP TABLE IF EXISTS TB_Cost_Pool_Position;
DROP TABLE IF EXISTS TB_Activity_Level_Structure;
DROP TABLE IF EXISTS TB_Quantity_Structure;
DROP TABLE IF EXISTS TB_Resource_Expense_Structure;
DROP TABLE IF EXISTS TB_Account_Expense_Structure;
DROP TABLE IF EXISTS TB_Planning_Period;

-- Drop master data tables
DROP TABLE IF EXISTS TB_Bill_Of_Material_Position;
DROP TABLE IF EXISTS TB_Material;
DROP TABLE IF EXISTS TB_Routing_Position;
DROP TABLE IF EXISTS TB_Resource_Cost_Driver_Rate;
DROP TABLE IF EXISTS TB_Activity;
DROP TABLE IF EXISTS TB_Finished_Good;
DROP TABLE IF EXISTS TB_General_Ledger_Account;

-- Drop enumerations
DROP TYPE IF EXISTS AccountEnum;
DROP TYPE IF EXISTS ResourceEnum;
DROP TYPE IF EXISTS MaterialEnum;
DROP TYPE IF EXISTS UnitEnum;
