# Binding libraries
require("shiny")
require("RPostgreSQL")
require("sqldf")
require("shinyjs")
require("DT")

# Initializing PostgreSQL DB
initializeDB <- function() {
  sqldf(paste(readLines("./sql_scripts/create_tables.sql"), collapse = "\n"))
  sqldf(paste(readLines("./sql_scripts/insert_data.sql"), collapse = "\n"))
}

# Load result1 table
loadResult1 <- function() {
  items <-
    sqldf(paste(
      readLines("./sql_scripts/query_results.sql"),
      collapse = "\n"
    ))
  dt <- datatable(
    data.frame(items),
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

# Get data of select row in results1
getDataOfSelectedRowResult1 <- function(input) {
  items <-
    sqldf(paste(
      readLines("./sql_scripts/query_results.sql"),
      collapse = "\n"
    ))
  temp <- reactive({
    items
  })
  row_count <- input
  data <- temp()[row_count, ]
  return(data)
}

# Load result2 table
loadResult2 <- function(period) {
  items <- sqldf(sprintf("
                SELECT
                ActivityID, 
                ResourceType, 
                Variator, 
                BudgetedOverheadExpenseResourceActivity, 
                ActualOverheadExpenseResourceActivity 
                FROM 
                TB_Cost_Pool_Position
                WHERE PeriodID = %s
                ORDER BY ActivityID;", period))
  dt <- datatable(
    data.frame(items),
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

# Load result3 table
loadResult3 <- function(period) {
  items <- sqldf(sprintf("
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
                         ", period))
  dt <- datatable(
    data.frame(items),
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

# Load chart of accounts table
loadChartOfAccounts <- function() {
  accounts <- sqldf(
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
    data.frame(accounts),
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

# Load bill of materials table
loadBillOfMaterial <- function() {
  items <-
    sqldf(paste(
      readLines("./sql_scripts/query_bill_of_materials.sql"),
      collapse = "\n"
    ))
  dt <- datatable(
    data.frame(items),
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

# Load routing table
loadRouting <- function() {
  activites <- sqldf(
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
    data.frame(activites),
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

# Load database table
loadDatabaseTable <- function(table) {
  data <- sqldf(sprintf(
    "SELECT * FROM %s;",
    table
  ))
  dt <- datatable(
    data.frame(data),
    selection = "single",
    options = list(scrollY = "600", pageLength = 25)
  )
  tabl <- DT::renderDT(dt)
  return(tabl)
}

# Get quantity structure of planning period
getQuantityStructure <- function(column, period, finishedgood) {
  value <- sqldf(
    sprintf(
      "
      SELECT %s
      FROM TB_Quantity_Structure
      WHERE PeriodID = %s AND FinishedGoodID = %s;
      ",
      column,
      period,
      finishedgood
    )
  )
  return(value[, 1])
}

# Get expense structure of planning period
getExpenseStructure <- function(column, period, account) {
  value <- sqldf(
    sprintf(
      "
      SELECT %s
      FROM TB_Account_Expense_Structure
      WHERE PeriodID = %s AND AccountID = %s;
      ",
      column,
      period,
      account
    )
  )
  return(value[, 1])
}

# Insert quantity structure
insertQuantityStructure <- function(period, finishedgood, capvol, budvol) {
  sqldf(
    sprintf(
      "
        INSERT INTO TB_Quantity_Structure(PeriodID, FinishedGoodID, CapacityVolume, BudgetedVolume)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (PeriodID, FinishedGoodID) DO NOTHING;
        ",
      period,
      finishedgood,
      capvol,
      budvol
    )
  )
}

# Update quantity structure
updateQuantityStructure <- function(period, finishedgood, actvol) {
  sqldf(
    sprintf(
      "
      UPDATE TB_Quantity_Structure
      SET ActualVolume = %s
      WHERE PeriodID = %s AND FinishedGoodID = %s;
      ",
      actvol,
      period,
      finishedgood
    )
  )
}

# Insert expense structure
insertExpenseStructure <- function(period, account, budexp, var) {
  sqldf(
    sprintf(
      "
      INSERT INTO TB_Account_Expense_Structure(PeriodID, AccountID, BudgetedOverheadExpense, Variator)
      VALUES (%s, %s, %s, %s)
      ON CONFLICT (PeriodID, AccountID) DO NOTHING;
      ",
      period,
      account,
      budexp,
      var
    )
  )
}

# Update expense structure
updateExpenseStructure <- function(period, account, actexp) {
  sqldf(
    sprintf(
      "
      UPDATE TB_Account_Expense_Structure
      SET ActualOverheadExpense = %s
      WHERE PeriodID = %s AND AccountID = %s;
      ",
      actexp,
      period,
      account
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

  # Initializing the database (only required for the first run)
  # initializeDB()

  # Load result1
  output$table_result1 <- loadResult1()

  # Initialize an empty table into result2
  output$table_result2 <- DT::renderDT(datatable(NULL))

  # Initialize an empty table into result3
  output$table_result3 <- DT::renderDT(datatable(NULL))

  # Load chart of accounts
  output$table_accounts <- loadChartOfAccounts()

  # Load bill of materials
  output$table_items <- loadBillOfMaterial()

  # Load routing
  output$table_activities <- loadRouting()

  # Image output about
  output$img <- renderUI({
    tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/TU_Wien-Logo.svg/200px-TU_Wien-Logo.svg.png")
  })

  # Text output about
  output$about <- renderText({
    readLines(textConnection("This R Shiny application, concerning flexible budgeting, is part of the prototypical implementation of a master thesis conducted at the Vienna University of Technology.
                             The underlying concepts rest on the capacity-based ABC approach with committed and flexible resources introduced by Kaplan (1994). \u00A9 Christoph Fraller, 01425649", encoding = "UTF-8"), encoding = "UTF-8")
  })

  # Update select input
  periods <- sqldf("
                   SELECT PeriodID FROM TB_Planning_Period;
                   ")
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

  # Select planning period
  observeEvent(input$select_period, {
    period <- input$select_period

    budgetedParConf <-
      sqldf(
        sprintf(
          "SELECT BudgetedParametersConfirmed FROM TB_Planning_Period WHERE PeriodID = %s;",
          period
        )
      )

    actualParConf <-
      sqldf(
        sprintf(
          "SELECT ActualParametersConfirmed FROM TB_Planning_Period WHERE PeriodID = %s;",
          period
        )
      )

    if (budgetedParConf[, 1]) {
      sapply(volumesInputFields$CapVol, disable)
      sapply(volumesInputFields$BudVol, disable)
      for (i in 1:nrow(volumesInputFields)) {
        updateTextInput(
          session,
          volumesInputFields$CapVol[i],
          value = getQuantityStructure(
            "CapacityVolume",
            period,
            volumesInputFields$FinishedGood[i]
          )
        )
        updateTextInput(
          session,
          volumesInputFields$BudVol[i],
          value = getQuantityStructure(
            "BudgetedVolume",
            period,
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
          value = getExpenseStructure(
            "BudgetedOverheadExpense",
            period,
            expensesInputFields$Account[i]
          )
        )
        updateTextInput(
          session,
          expensesInputFields$Var[i],
          value = getExpenseStructure("Variator", period, expensesInputFields$Account[i])
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
            value = getQuantityStructure(
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
            value = getExpenseStructure(
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

  # Add new period (user input)
  observeEvent(input$new_period_button, {
    sqldf(
      "
        INSERT INTO TB_Planning_Period (PeriodID, BudgetedParametersConfirmed, ActualParametersConfirmed, PreviousPeriodID)
        SELECT CASE WHEN MAX(PeriodID) IS NOT NULL THEN MAX(PeriodID)+1 ELSE 0 END, FALSE, FALSE, MAX(PeriodID) FROM TB_Planning_Period
        ON CONFLICT (PeriodID) DO NOTHING;
        "
    )
    period <- sqldf("SELECT MAX(PeriodID) FROM TB_Planning_Period;")[1, ]
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
        period,
        period
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

  # Add new period (naive callibration)
  observeEvent(input$new_naiveperiod_button, {
    sqldf(
      "
        INSERT INTO TB_Planning_Period (PeriodID, BudgetedParametersConfirmed, ActualParametersConfirmed, PreviousPeriodID)
        SELECT CASE WHEN MAX(PeriodID) IS NOT NULL THEN MAX(PeriodID)+1 ELSE 0 END, TRUE, TRUE, MAX(PeriodID) FROM TB_Planning_Period
        ON CONFLICT (PeriodID) DO NOTHING;
        "
    )
    period <- sqldf("SELECT MAX(PeriodID) FROM TB_Planning_Period;")[1, ]
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
        period,
        period
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
        period,
        1 - as.numeric(input$naiv_exp_input),
        period
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
    output$table_result1 <- loadResult1()
    output$table_result2 <- DT::renderDT(datatable(NULL))
    output$table_result3 <- DT::renderDT(datatable(NULL))
  })

  # Confirm budgeted parameters
  observeEvent(input$confirm_bud_par_button, {
    period <- input$select_period
    for (i in 1:nrow(volumesInputFields)) {
      insertQuantityStructure(
        period,
        volumesInputFields$FinishedGood[i],
        as.numeric(input[[as.character(volumesInputFields$CapVol[i])]]),
        as.numeric(input[[as.character(volumesInputFields$BudVol[i])]])
      )
    }
    for (i in 1:nrow(expensesInputFields)) {
      insertExpenseStructure(
        period,
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
        period
      )
    )
    updateSelectInput(session, "select_period", selected = 0)
    updateSelectInput(session, "select_period", selected = period)
    output$table_result1 <- loadResult1()
    output$table_result2 <- DT::renderDT(datatable(NULL))
    output$table_result3 <- DT::renderDT(datatable(NULL))
  })

  # Confirm actual parameters
  observeEvent(input$confirm_act_par_button, {
    period <- input$select_period
    for (i in 1:nrow(volumesInputFields)) {
      updateQuantityStructure(
        period,
        volumesInputFields$FinishedGood[i],
        as.numeric(input[[as.character(volumesInputFields$ActVol[i])]])
      )
    }
    for (i in 1:nrow(expensesInputFields)) {
      updateExpenseStructure(
        period,
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
        period
      )
    )
    updateSelectInput(session, "select_period", selected = 0)
    updateSelectInput(session, "select_period", selected = period)
    output$table_result1 <- loadResult1()
    output$table_result2 <- DT::renderDT(datatable(NULL))
    output$table_result3 <- DT::renderDT(datatable(NULL))
  })

  # Reset budgeted parameters
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

  # Reset actual parameters
  observeEvent(input$reset_act_par_button, {
    for (i in 1:nrow(volumesInputFields)) {
      updateTextInput(session, volumesInputFields$ActVol[i], value = "")
    }
    for (i in 1:nrow(expensesInputFields)) {
      updateTextInput(session, expensesInputFields$ActExp[i], value = "")
    }
  })

  # Load database table
  observeEvent(input$table_selector, {
    output$table_database <- loadDatabaseTable(input$table_selector)
  })

  # Observe rows select in tab inspection of outcomes
  observeEvent(input$table_result1_rows_selected, {
    data <- getDataOfSelectedRowResult1(input$table_result1_rows_selected)
    period <- as.numeric(data[, 1])
    output$table_result2 <- loadResult2(period)
    output$table_result3 <- loadResult3(period)
  })

  # Reset DB
  observeEvent(input$reset_db_button, {
    sqldf(paste(readLines("./sql_scripts/drop_tables.sql"), collapse = "\n"))
    initializeDB()
    output$table_result1 <- loadResult1()
    output$table_result2 <- DT::renderDT(datatable(NULL))
    output$table_result3 <- DT::renderDT(datatable(NULL))
    output$table_accounts <- loadChartOfAccounts()
    output$table_items <- loadBillOfMaterial()
    output$table_activities <- loadRouting()
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