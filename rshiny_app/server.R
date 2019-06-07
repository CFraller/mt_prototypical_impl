# Binding libraries
require("shiny")
require("RPostgreSQL")
require("sqldf")
require("shinyjs")
require("DT")

# Initializing PostgreSQL database
initializeDatabase <- function() {
  sqldf(paste(readLines("./sql_scripts/create_tables.sql"), collapse = "\n"))
  sqldf(paste(readLines("./sql_scripts/insert_data.sql"), collapse = "\n"))
}

# Loading data of the main results table from database
loadMainResultTable <- function() {
  data <-
    sqldf(paste(
      readLines("./sql_scripts/query_results.sql"),
      collapse = "\n"
    ))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "200", pageLength = 10),
    colnames = c(
      "Period ID",
      "Actual volume of Slot Car X1",
      "Actual volume of Slot Car Z2",
      "Material expense of Slot Car X1",
      "Material expense of Slot Car Z2",
      "Overhead expense char. to Slot Car X1",
      "Overhead expense char. to Slot Car Z2",
      "Total overhead expense char. to prod.",
      "Committed expense",
      "Flexible expense",
      "Unused capacity",
      "Capacity utilization variance",
      "Spending variance",
      "Flexible budget"
    )
  ) %>%
    formatRound(columns = "volumeproduct1", digits = 2) %>%
    formatRound(columns = "volumeproduct2", digits = 2) %>%
    formatCurrency(columns = "materialexpenseproduct1") %>%
    formatCurrency(columns = "materialexpenseproduct2") %>%
    formatCurrency(columns = "expensechargedtoproduct1") %>%
    formatCurrency(columns = "expensechargedtoproduct2") %>%
    formatCurrency(columns = "expensechargedtoproducts") %>%
    formatCurrency(columns = "committedexpense") %>%
    formatCurrency(columns = "flexibleexpense") %>%
    formatCurrency(columns = "unusedcapacity") %>%
    formatCurrency(columns = "capacityutilizationvariance") %>%
    formatCurrency(columns = "spendingvariance") %>%
    formatCurrency(columns = "flexiblebudget")
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Get the data of selected row of the main results table
getDataOfSelectedRow <- function(selectedRow) {
  data <-
    sqldf(paste(
      readLines("./sql_scripts/query_results.sql"),
      collapse = "\n"
    ))
  return(data[selectedRow, ])
}

# Loading data of the cost pool table of selected period from database
loadCostPoolTable <- function(periodId) {
  data <- sqldf(sprintf("
                SELECT
                ActivityID, 
                ResourceType, 
                Variator, 
                BudgetedOverheadExpenseResourceActivity, 
                ActualOverheadExpenseResourceActivity 
                FROM 
                TB_Cost_Pool_Position
                WHERE PeriodID = %s
                ORDER BY ActivityID;", periodId))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "200", pageLength = 10),
    colnames = c(
      "Activity ID",
      "Resource type",
      "Variator",
      "Budgeted overhead expense",
      "Actual overhead expense"
    )
  ) %>%
    formatRound(columns = "variator", digits = 2) %>%
    formatCurrency(columns = "budgetedoverheadexpenseresourceactivity") %>%
    formatCurrency(columns = "actualoverheadexpenseresourceactivity")
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Loading data of the activity pool table of selected period from database
loadActivityPoolTable <- function(periodId) {
  data <- sqldf(sprintf("
                         SELECT 
	                       ActivityID,
                         CommittedExpense,
                         FlexibleExpense, 
                         CapacityDriverRate,
                         BudgetedDriverRate,
                         UnusedCapacity,
                         CapacityUtilizationVariance,
                         ExpenseChargedToProducts,
                         SpendingVariance, 
                         FlexibleBudget
                         FROM 
                         TB_Activity_Pool_Position
                         WHERE PeriodID = %s
                         ORDER BY ActivityID;
                         ", periodId))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "200", pageLength = 10),
    colnames = c(
      "Activity ID",
      "Committed expense",
      "Flexible expense",
      "Cap. driver rate",
      "Bud. driver rate",
      "Unused capacity",
      "Capacity utilization variance",
      "Expense char. to prod.",
      "Spending variance",
      "Flexible budget"
    )
  ) %>%
    formatCurrency(columns = "committedexpense") %>%
    formatCurrency(columns = "flexibleexpense") %>%
    formatCurrency(columns = "capacitydriverrate") %>%
    formatCurrency(columns = "budgeteddriverrate") %>%
    formatCurrency(columns = "expensechargedtoproducts") %>%
    formatCurrency(columns = "unusedcapacity") %>%
    formatCurrency(columns = "capacityutilizationvariance") %>%
    formatCurrency(columns = "spendingvariance") %>%
    formatCurrency(columns = "flexiblebudget")
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Loading data of chart of accounts table from database
loadChartOfAccountsTableTable <- function() {
  data <- sqldf(
    "
    SELECT
    AccountID,
    AccountType,
    BookingMatrixNumber,
    AccountName,
    ResourceType,
    CASE
    WHEN CostType = TRUE THEN 'Overhead'
    WHEN CostType = FALSE THEN 'Direct'
    ELSE NULL END
    FROM
    TB_General_Ledger_Account
    ORDER BY
    AccountID
    ASC;
    "
  )
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(
      scrollY = "600",
      pageLength = 25
    ),
    colnames = c(
      "G/L account ID",
      "Account type",
      "Booking matrix number",
      "Account name",
      "Resource type",
      "Cost type"
    )
  )
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Loading data of bill of materials table from database
loadBillOfMaterialTable <- function() {
  data <-
    sqldf(paste(
      readLines("./sql_scripts/query_bill_of_materials.sql"),
      collapse = "\n"
    ))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "600", pageLength = 25),
    colnames = c(
      "Finished good ID",
      "Item level",
      "Material ID",
      "Material name",
      "Material type",
      "Quantity",
      "Unit",
      "Unit cost"
    )
  ) %>% formatRound(columns = "quantity", digits = 3) %>% formatCurrency(columns = "unitcost")
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Load data of routing table from database
loadRouting <- function() {
  data <- sqldf(
    "
    SELECT
    FinishedGoodID,
    TB_Activity.ActivityID,
    ActivityName,
    Description,
    ActivityCostDriver,
    ActivityCostDriverQuantity,
    StdProdCoefPers,
    StdProdCoefEquip
    FROM
    TB_Routing_Position
    LEFT JOIN
    TB_Activity
    ON
    TB_Routing_Position.ActivityID = TB_Activity.ActivityID;
    "
  )
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "600", pageLength = 25),
    colnames = c(
      "Finished good ID",
      "Activity ID",
      "Activity name",
      "Description",
      "Activity cost driver",
      "Quantity",
      "Std. prod. coef. personnel",
      "Std. prod. coef. equipment"
    )
  ) %>%
    formatRound(columns = "activitycostdriverquantity", digits = 2) %>%
    formatRound(columns = "stdprodcoefpers", digits = 3) %>%
    formatRound(columns = "stdprodcoefequip", digits = 3)
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Loading data of an arbitrary table from database
loadDatabaseTable <- function(tableName) {
  data <- sqldf(sprintf(
    "SELECT * FROM %s;",
    tableName
  ))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "600", pageLength = 25)
  )
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Get selected column of a quantity structure from particular planning period and finished good
getColumnOfQuantityStructure <- function(column, periodId, finishedGoodId) {
  value <- sqldf(
    sprintf(
      "
      SELECT %s
      FROM TB_Quantity_Structure
      WHERE PeriodID = %s AND FinishedGoodID = %s;
      ",
      column,
      periodId,
      finishedGoodId
    )
  )
  return(value[, 1])
}

# Get selected column of a expense structure from particular planning period and account
getColumnOfExpenseStructure <- function(column, periodId, accountId) {
  value <- sqldf(
    sprintf(
      "
      SELECT %s
      FROM TB_Account_Expense_Structure
      WHERE PeriodID = %s AND AccountID = %s;
      ",
      column,
      periodId,
      accountId
    )
  )
  return(value[, 1])
}

# Insert a new quantity structure to a planning period
insertQuantityStructure <- function(periodId, finishedGoodId, capacityVolume, budgetedVolume) {
  sqldf(
    sprintf(
      "
        INSERT INTO TB_Quantity_Structure(PeriodID, FinishedGoodID, CapacityVolume, BudgetedVolume)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        ",
      periodId,
      finishedGoodId,
      capacityVolume,
      budgetedVolume
    )
  )
}

# Update a quantity structure of a particular planning period
updateQuantityStructure <- function(periodId, finishedGoodId, actualVolume) {
  sqldf(
    sprintf(
      "
      UPDATE TB_Quantity_Structure
      SET ActualVolume = %s
      WHERE PeriodID = %s AND FinishedGoodID = %s;
      ",
      actualVolume,
      periodId,
      finishedGoodId
    )
  )
}

# Insert a new expense structure to a planning period
insertExpenseStructure <- function(periodId, accountId, budgetedExpense, variator) {
  sqldf(
    sprintf(
      "
      INSERT INTO TB_Account_Expense_Structure(PeriodID, AccountID, BudgetedOverheadExpense, Variator)
      VALUES (%s, %s, %s, %s)
      ON CONFLICT (PeriodID, AccountID) DO NOTHING;
      ",
      periodId,
      accountId,
      budgetedExpense,
      variator
    )
  )
}

# Update an expense structure of a particular planning period
updateExpenseStructure <- function(periodId, accountId, actualExpense) {
  sqldf(
    sprintf(
      "
      UPDATE TB_Account_Expense_Structure
      SET ActualOverheadExpense = %s
      WHERE PeriodID = %s AND AccountID = %s;
      ",
      actualExpense,
      periodId,
      accountId
    )
  )
}

# Load server application
server <- function(input, output, session) {

  # Establish connection to PoststgreSQL using RPostgreSQL
  username <- "postgres"
  password <- ""
  ipaddress <- "localhost"
  portnumber <- 5432
  databasename <- "postgres"
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(
    drv,
    user = username,
    password = password,
    host = ipaddress,
    port = portnumber,
    dbname = databasename
  )
  options(
    sqldf.RPostgreSQL.user = username,
    sqldf.RPostgreSQL.password = password,
    sqldf.RPostgreSQL.dbname = databasename,
    sqldf.RPostgreSQL.host = ipaddress,
    sqldf.RPostgreSQL.port = portnumber
  )

  # Initializing the database (only required for the first run, because of the enumerations)
  # initializeDatabase()

  # Loading content of main table
  output$table_main_result <- loadMainResultTable()

  # Initialize an empty table into cost pool table
  output$table_cost_pool <- DT::renderDT(datatable(NULL))

  # Initialize an empty table into activity pool table
  output$table_activity_pool <- DT::renderDT(datatable(NULL))

  # Loading content of chart of accounts
  output$table_chart_of_accounts <- loadChartOfAccountsTable()

  # Loading content of bill of materials
  output$table_bill_of_materials <- loadBillOfMaterialTable()

  # Loading content of routing
  output$table_rounting <- loadRouting()

  # Displaying the TU Wien logo
  output$img_tuwien_logo <- renderUI({
    tags$img_tuwien_logo(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/TU_Wien-Logo.svg/200px-TU_Wien-Logo.svg.png")
  })

  # Displaying the "txt_about" - statement
  output$txt_about <- renderText({
    readLines(textConnection("This R Shiny application, concerning flexible budgeting, is part of the prototypical implementation of a master thesis conducted at the Vienna University of Technology.
                             The underlying concepts rest on the capacity-based ABC approach with committed and flexible resources introduced by Kaplan (1994). \u00A9 Christoph Fraller, 01425649", encoding = "UTF-8"), encoding = "UTF-8")
  })

  periods <- sqldf("SELECT PeriodID FROM TB_Planning_Period;")
  if (nrow(periods) <= 1) {
    periods <- 0
  }
  updateSelectInput(
    session,
    "select_period",
    choices = periods,
    selected = 0
  )

  volumesInputFields <- data.frame(
    FinishedGood = c(120, 140),
    CapVol = c("cap_vol_input_x1", "cap_vol_input_z2"),
    BudVol = c("bud_vol_input_x1", "bud_vol_input_z2"),
    ActVol = c("act_vol_input_x1", "act_vol_input_z2")
  )

  expensesInputFields <- data.frame(
    Account = c(699, 700, 709, 720, 798),
    BudExp = c(
      "699_bud_input",
      "700_bud_input",
      "709_bud_input",
      "720_bud_input",
      "798_bud_input"
    ),
    Var = c(
      "699_var_input",
      "700_var_input",
      "709_var_input",
      "720_var_input",
      "798_var_input"
    ),
    ActExp = c(
      "699_act_input",
      "700_act_input",
      "709_act_input",
      "720_act_input",
      "798_act_input"
    )
  )

  # Selecting planning period event
  observeEvent(input$select_period, {
    periodId <- input$select_period
    budgetedParConf <-
      sqldf(
        sprintf(
          "SELECT BudgetedParametersConfirmed FROM TB_Planning_Period WHERE PeriodID = %s;",
          periodId
        )
      )
    actualParConf <-
      sqldf(
        sprintf(
          "SELECT ActualParametersConfirmed FROM TB_Planning_Period WHERE PeriodID = %s;",
          periodId
        )
      )
    if (budgetedParConf[, 1]) {
      sapply(volumesInputFields$CapVol, disable)
      sapply(volumesInputFields$BudVol, disable)
      for (i in 1:nrow(volumesInputFields)) {
        updateTextInput(
          session,
          volumesInputFields$CapVol[i],
          value = getColumnOfQuantityStructure(
            "CapacityVolume",
            periodId,
            volumesInputFields$FinishedGood[i]
          )
        )
        updateTextInput(
          session,
          volumesInputFields$BudVol[i],
          value = getColumnOfQuantityStructure(
            "BudgetedVolume",
            periodId,
            volumesInputFields$FinishedGood[i]
          )
        )
      }
      sapply(expensesInputFields$BudExp, disable)
      sapply(expensesInputFields$Var, disable)
      for (i in 1:nrow(expensesInputFields)) {
        updateTextInput(
          session,
          expensesInputFields$BudExp[i],
          value = getColumnOfExpenseStructure(
            "BudgetedOverheadExpense",
            periodId,
            expensesInputFields$Account[i]
          )
        )
        updateTextInput(
          session,
          expensesInputFields$Var[i],
          value = getColumnOfExpenseStructure(
            "Variator",
            periodId,
            expensesInputFields$Account[i]
          )
        )
      }

      disable("reset_bud_par_button")
      disable("confirm_bud_par_button")
    }
    else {
      sapply(volumesInputFields$CapVol, enable)
      sapply(volumesInputFields$BudVol, enable)
      for (i in 1:nrow(volumesInputFields)) {
        updateTextInput(session, volumesInputFields$CapVol[i], value = "")
        updateTextInput(session, volumesInputFields$BudVol[i], value = "")
      }

      sapply(expensesInputFields$BudExp, enable)
      sapply(expensesInputFields$Var, enable)
      for (i in 1:nrow(expensesInputFields)) {
        updateTextInput(session, expensesInputFields$BudExp[i], value = "")
        updateTextInput(session, expensesInputFields$Var[i], value = "")
      }

      enable("reset_bud_par_button")
      enable("confirm_bud_par_button")
    }
    if (!actualParConf[, 1] & budgetedParConf[, 1]) {
      sapply(volumesInputFields$ActVol, enable)
      for (i in 1:nrow(volumesInputFields)) {
        updateTextInput(session, volumesInputFields$ActVol[i], value = "")
      }

      sapply(expensesInputFields$ActExp, enable)
      for (i in 1:nrow(expensesInputFields)) {
        updateTextInput(session, expensesInputFields$ActExp[i], value = "")
      }

      enable("reset_act_par_button")
      enable("confirm_act_par_button")
    }
    else {
      if (actualParConf[, 1]) {
        sapply(volumesInputFields$ActVol, disable)
        for (i in 1:nrow(volumesInputFields)) {
          updateTextInput(
            session,
            volumesInputFields$ActVol[i],
            value = getColumnOfQuantityStructure(
              "ActualVolume",
              period,
              volumesInputFields$FinishedGood[i]
            )
          )
        }
        sapply(expensesInputFields$ActExp, disable)
        for (i in 1:nrow(expensesInputFields)) {
          updateTextInput(
            session,
            expensesInputFields$ActExp[i],
            value = getColumnOfExpenseStructure(
              "ActualOverheadExpense",
              period,
              expensesInputFields$Account[i]
            )
          )
        }
        disable("reset_act_par_button")
        disable("confirm_act_par_button")
      }
      else {
        sapply(volumesInputFields$ActVol, disable)
        for (i in 1:nrow(volumesInputFields)) {
          updateTextInput(session, volumesInputFields$ActVol[i], value = "")
        }

        sapply(expensesInputFields$ActExp, disable)
        for (i in 1:nrow(expensesInputFields)) {
          updateTextInput(session, expensesInputFields$ActExp[i], value = "")
        }
        disable("reset_act_par_button")
        disable("confirm_act_par_button")
      }
    }
  })

  # Add new period (user input) event
  observeEvent(input$new_period_button, {
    sqldf(
      "
        INSERT INTO TB_Planning_Period (PeriodID, BudgetedParametersConfirmed, ActualParametersConfirmed, PreviousPeriodID)
        SELECT CASE WHEN MAX(PeriodID) IS NOT NULL THEN MAX(PeriodID)+1 ELSE 0 END, FALSE, FALSE, MAX(PeriodID) FROM TB_Planning_Period
        ON CONFLICT (PeriodID) DO NOTHING;
        "
    )
    periodId <- sqldf("SELECT MAX(PeriodID) FROM TB_Planning_Period;")[1, ]
    sqldf(
      sprintf(
        "
        INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
        VALUES (%s, 120)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
        VALUES (%s, 140)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        ",
        periodId,
        periodId
      )
    )
    periods <- sqldf("
                     SELECT PeriodID FROM TB_Planning_Period;
                     ")
    updateSelectInput(
      session,
      "select_period",
      "Select planning period",
      choices = periods,
      selected = ifelse(nrow(periods) > 0, periods[nrow(periods), ], 0)
    )
  })

  # Observe input fields of volume and expense for naive callibration
  observe({
    toggleState(
      "new_naiveperiod_button",
      (input$naiv_vol_input != "" | is.null(input$naiv_vol_input)) & (input$naiv_exp_input != "" | is.null(input$naiv_exp_input))
    )
  })

  # Add new period (naive callibration) event
  observeEvent(input$new_naiveperiod_button, {
    sqldf(
      "
        INSERT INTO TB_Planning_Period (PeriodID, BudgetedParametersConfirmed, ActualParametersConfirmed, PreviousPeriodID)
        SELECT CASE WHEN MAX(PeriodID) IS NOT NULL THEN MAX(PeriodID)+1 ELSE 0 END, TRUE, TRUE, MAX(PeriodID) FROM TB_Planning_Period
        ON CONFLICT (PeriodID) DO NOTHING;
        "
    )
    periodId <- sqldf("SELECT MAX(PeriodID) FROM TB_Planning_Period;")[1, ]
    sqldf(
      sprintf(
        "
        INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
        VALUES (%s, 120)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        INSERT INTO TB_Cost_Object_Structure(PeriodID, FinishedGoodID)
        VALUES (%s, 140)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        ",
        periodId,
        periodId
      )
    )
    sqldf(paste(
      readLines("./sql_scripts/insert_data_naivecallibration_1.sql"),
      collapse = "\n"
    ))
    sqldf(
      sprintf(
        "
        UPDATE TB_Quantity_Structure
        SET ActualVolume = ROUND(BudgetedVolume * %s)
        WHERE PeriodID = %s;
        UPDATE TB_Account_Expense_Structure
        SET ActualOverheadExpense = BudgetedOverheadExpense * %s
        WHERE PeriodID = %s;
        ",
        1 - as.numeric(input$naiv_vol_input),
        periodId,
        1 - as.numeric(input$naiv_exp_input),
        periodId
      )
    )
    sqldf(paste(
      readLines("./sql_scripts/insert_data_naivecallibration_2.sql"),
      collapse = "\n"
    ))
    periods <- sqldf("
                     SELECT PeriodID FROM TB_Planning_Period;
                     ")
    updateSelectInput(
      session,
      "select_period",
      "Select planning period",
      choices = periods,
      selected = ifelse(nrow(periods) > 0, periods[nrow(periods), ], 0)
    )
    output$table_main_result <- loadMainResultTable()
    output$table_cost_pool <- DT::renderDT(datatable(NULL))
    output$table_activity_pool <- DT::renderDT(datatable(NULL))
  })

  # Confirm budgeted parameters event
  observeEvent(input$confirm_bud_par_button, {
    periodId <- input$select_period
    for (i in 1:nrow(volumesInputFields)) {
      insertQuantityStructure(
        periodId,
        volumesInputFields$FinishedGood[i],
        as.numeric(input[[as.character(volumesInputFields$CapVol[i])]]),
        as.numeric(input[[as.character(volumesInputFields$BudVol[i])]])
      )
    }
    for (i in 1:nrow(expensesInputFields)) {
      insertExpenseStructure(
        periodId,
        expensesInputFields$Account[i],
        as.numeric(input[[as.character(expensesInputFields$BudExp[i])]]),
        as.numeric(input[[as.character(expensesInputFields$Var[i])]])
      )
    }
    sqldf(paste(
      readLines("./sql_scripts/perform_calculations_1.sql"),
      collapse = "\n"
    ))
    sqldf(
      sprintf(
        "
        UPDATE TB_Planning_Period
        SET BudgetedParametersConfirmed = TRUE
        WHERE PeriodID = %s;
        ",
        periodId
      )
    )
    updateSelectInput(session, "select_period", selected = 0)
    updateSelectInput(session, "select_period", selected = periodId)
    output$table_main_result <- loadMainResultTable()
    output$table_cost_pool <- DT::renderDT(datatable(NULL))
    output$table_activity_pool <- DT::renderDT(datatable(NULL))
  })

  # Confirm actual parameters event
  observeEvent(input$confirm_act_par_button, {
    periodId <- input$select_period
    for (i in 1:nrow(volumesInputFields)) {
      updateQuantityStructure(
        periodId,
        volumesInputFields$FinishedGood[i],
        as.numeric(input[[as.character(volumesInputFields$ActVol[i])]])
      )
    }
    for (i in 1:nrow(expensesInputFields)) {
      updateExpenseStructure(
        periodId,
        expensesInputFields$Account[i],
        as.numeric(input[[as.character(expensesInputFields$ActExp[i])]])
      )
    }
    sqldf(paste(
      readLines("./sql_scripts/perform_calculations_2.sql"),
      collapse = "\n"
    ))
    sqldf(
      sprintf(
        "
        UPDATE TB_Planning_Period
        SET ActualParametersConfirmed = TRUE
        WHERE PeriodID = %s;
        ",
        periodId
      )
    )
    updateSelectInput(session, "select_period", selected = 0)
    updateSelectInput(session, "select_period", selected = periodId)
    output$table_main_result <- loadMainResultTable()
    output$table_cost_pool <- DT::renderDT(datatable(NULL))
    output$table_activity_pool <- DT::renderDT(datatable(NULL))
  })

  # Reset budgeted parameters event
  observeEvent(input$reset_bud_par_button, {
    for (i in 1:nrow(volumesInputFields)) {
      updateTextInput(session, volumesInputFields$CapVol[i], value = "")
      updateTextInput(session, volumesInputFields$BudVol[i], value = "")
    }
    for (i in 1:nrow(expensesInputFields)) {
      updateTextInput(session, expensesInputFields$BudExp[i], value = "")
      updateTextInput(session, expensesInputFields$Var[i], value = "")
    }
  })

  # Reset actual parameters event
  observeEvent(input$reset_act_par_button, {
    for (i in 1:nrow(volumesInputFields)) {
      updateTextInput(session, volumesInputFields$ActVol[i], value = "")
    }
    for (i in 1:nrow(expensesInputFields)) {
      updateTextInput(session, expensesInputFields$ActExp[i], value = "")
    }
  })

  # Load database table event
  observeEvent(input$table_selector, {
    output$table_database <- loadDatabaseTable(input$table_selector)
  })

  # Observe rows select in tab inspection of outcomes event
  observeEvent(input$table_main_result_rows_selected, {
    data <- getDataOfSelectedRow(input$table_main_result_rows_selected)
    periodId <- as.numeric(data[, 1])
    output$table_cost_pool <- loadCostPoolTable(periodId)
    output$table_activity_pool <- loadActivityPoolTable(periodId)
  })

  # Reset database event
  observeEvent(input$reset_db_button, {
    sqldf(paste(readLines("./sql_scripts/drop_tables.sql"), collapse = "\n"))
    initializeDatabase()
    output$table_main_result <- loadMainResultTable()
    output$table_cost_pool <- DT::renderDT(datatable(NULL))
    output$table_activity_pool <- DT::renderDT(datatable(NULL))
    output$table_chart_of_accounts <- loadChartOfAccountsTable()
    output$table_bill_of_materials <- loadBillOfMaterialTable()
    output$table_rounting <- loadRouting()
    output$table_database <- loadDatabaseTable(input$table_selector)
    updateSelectInput(session,
      "select_period",
      selected = 0,
      choices = 0
    )
  })

  # Close PostgreSQL connection
  dbDisconnect(con)
}
