# Binding libraries
require("shiny")
require("shinythemes")
require("miniUI")
require("shinyjs")
require("DT")

# Load user interface (UI)
ui <- fluidPage(
  theme = shinytheme("flatly"),
  style = "max-height: 100vh; overflow-y: auto; overflow-x: hidden;",
  useShinyjs(),
  navbarPage(
    "Flexible Budgeting",
    tabPanel(
      "Estimation of Parameters",
      value = "Estimation of Parameters",
      fluidRow(column(
        12, titlePanel("Estimation of budgeted parameters and realization of actual parameters"),
        offset = 3
      )),
      fluidPage(
        fluidRow(
          div(style = "height:20px;"), h4("Option 1: Add a new planning period using data from naive callibration")
        ),
        fluidRow(
          div(style = "height:10px;"),
          column(
            2,
            actionButton(
              "new_naiveperiod_button",
              "Add new period (naive callibr.)",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            )
          ),
          column(
            2,
            textInput("naiv_vol_input", "Reduction of actual volume", width = "80%")
          ),
          column(
            2,
            textInput("naiv_exp_input", "Reduction of actual expenses", width = "80%")
          )
        ),
        fluidRow(
          div(style = "height:20px;"), h4("Option 2: Add a new planning period using data from user input")
        ),
        fluidRow(
          column(
            2,
            actionButton(
              "new_period_button",
              "Add new period (user input)",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            )
          ),
          column(6, div(style = "height:10px;"), h4("Estimation of budgeted parameters: cap. volumes, bud. volumes, bud. expenses, and variators")),
          column(4, div(style = "height:10px;"), h4("Realization of actual parameters: act. volumes and act. expenses", offset = 1))
        ),
        fluidRow(
          div(style = "height:10px;"),
          column(
            2,
            selectInput(
              "select_period",
              "Select planning period",
              choices = c("0"),
              selected = "0",
              width = "80%"
            )
          ),
          column(
            2,
            textInput("cap_vol_input_x1", "Cap. volume of Slot Car X1", width = "80%")
          ),
          column(
            2,
            textInput("699_bud_input", "Bud. exp. of '699 Disc. Personnel'", width = "80%")
          ),
          column(
            2,
            textInput("699_var_input", "Variator of '699 Disc. Personnel'", width = "80%")
          ),
          column(
            2,
            textInput("act_vol_input_x1", "Act. vol. of Slot Car X1", width = "80%")
          ),
          column(
            2,
            textInput("699_act_input", "Act. exp. of '699 Dis. Personnel'", width = "80%")
          )
        ),
        fluidRow(
          column(
            2,
            textInput("bud_vol_input_x1", "Bud. volume of Slot Car X1", width = "80%"),
            offset = 2
          ),
          column(
            2,
            textInput("700_bud_input", "Bud. exp. of '700 Depreciation'", width = "80%")
          ),
          column(
            2,
            textInput("700_var_input", "Variator of '700 Depreciation'", width = "80%")
          ),
          column(
            2,
            textInput("act_vol_input_z2", "Act. vol. of Slot Car Z2", width = "80%")
          ),
          column(
            2,
            textInput("700_act_input", "Act. exp. of '700 Depreciation'", width = "80%")
          )
        ),
        fluidRow(
          column(
            2,
            textInput("cap_vol_input_z2", "Cap. volume of Slot Car Z2", width = "80%"),
            offset = 2
          ),
          column(
            2,
            textInput("709_bud_input", "Bud. exp. of '709 Operating exp.'", width = "80%")
          ),
          column(
            2,
            textInput("709_var_input", "Variator of '709 Operating exp.'", width = "80%")
          ),
          column(
            2,
            textInput("709_act_input", "Act. exp. of '709 Operating exp.'", width = "80%"),
            offset = 2
          )
        ),
        fluidRow(
          column(
            2,
            textInput("bud_vol_input_z2", "Bud. volume of Slot Car Z2", width = "80%"),
            offset = 2
          ),
          column(
            2,
            textInput("720_bud_input", "Bud. exp. of '720 Maint. costs'", width = "80%")
          ),
          column(
            2,
            textInput("720_var_input", "Variator of '720 Maint. costs'", width = "80%")
          ),
          column(
            2,
            textInput("720_act_input", "Act. exp. of '720 Maint. costs'", width = "80%"),
            offset = 2
          )
        ),
        fluidRow(
          column(
            2,
            textInput("798_bud_input", "Bud. exp. of '798 Admin. exp.'", width = "80%"),
            offset = 4
          ),
          column(
            2,
            textInput("798_var_input", "Variator of '798 Admin. exp.'", width = "80%")
          ),
          column(
            2,
            textInput("798_act_input", "Act. exp. of '798 Admin. exp.'", width = "80%"),
            offset = 2
          )
        ),
        fluidRow(
          column(
            2,
            actionButton(
              "reset_bud_par_button",
              "Reset budgeted parameters",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            ),
            offset = 4
          ),
          column(
            2,
            actionButton(
              "confirm_bud_par_button",
              "Confirm budgeted parameters",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            )
          ),
          column(
            2,
            actionButton(
              "reset_act_par_button",
              "Reset actual parameters",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            )
          ),
          column(
            2,
            actionButton(
              "confirm_act_par_button",
              "Confirm actual parameters",
              width = "80%",
              style = "padding:12px; margin-top:20px;"
            )
          )
        )
      )
    ),
    tabPanel(
      "Inspection of Results",
      fluidPage(
        fluidRow(column(
          12, titlePanel("Results of flexible budgeting using an capacity-based ABC approach with flexible and committed resources"),
          offset = 1
        )),
        fluidRow(
          div(style = "height:10px;"), column(8, h4("Table 1: Results of flexible budgeting grouped by periods"))
        ),
        fluidRow(DT::dataTableOutput("table_main_result")),
        fluidRow(
          div(style = "height:10px;"),
          column(5, h4("Table 2: Cost pool data of selected period grouped by activities and res.")),
          column(5, h4("Table 3: Activity pool data of selected period grouped by activities"))
        ),
        fluidRow(
          div(style = "height:5px;"),
          column(4, DT::dataTableOutput("table_cost_pool")),
          column(7, DT::dataTableOutput("table_activity_pool"), offset = 1)
        )
      )
    ),
    tabPanel(
      "Chart of Accounts",
      fluidPage(
        fluidRow(column(
          12, titlePanel("Chart of Accounts"),
          offset = 5
        )),
        DT::dataTableOutput("table_chart_of_accounts")
      )
    ),
    tabPanel(
      "Bill of Material",
      fluidPage(
        fluidRow(column(
          12, titlePanel("Bill of Material (BOM)"),
          offset = 5
        )),
        DT::dataTableOutput("table_bill_of_materials")
      )
    ),
    tabPanel(
      "Routing",
      fluidPage(
        fluidRow(column(12, titlePanel("Routing"),
          offset = 5
        )),
        DT::dataTableOutput("table_rounting")
      )
    ),
    navbarMenu(
      "More",
      tabPanel(
        "About",
        fluidPage(
          fluidRow(
            column(2, uiOutput("img_tuwien_logo")),
            column(4, textOutput("txt_about"))
          )
        )
      ),
      tabPanel(
        "Database",
        sidebarLayout(
          sidebarPanel(
            fluidRow(
              selectInput(
                "table_selector",
                "Select a table to display",
                selected = "tb_general_ledger_account",
                choices = sort(
                  c(
                    "tb_general_ledger_account",
                    "tb_finished_good",
                    "tb_material",
                    "tb_activity",
                    "tb_routing_position",
                    "tb_bill_of_material_position",
                    "tb_resource_cost_driver_rate",
                    "tb_planning_period",
                    "tb_cost_object_structure",
                    "tb_quantity_structure",
                    "tb_account_expense_structure",
                    "tb_resource_expense_structure",
                    "tb_activity_level_structure",
                    "tb_cost_pool_position",
                    "tb_activity_pool_position"
                  )
                ),
                width = "415px"
              )
            ),
            fluidRow(column(
              3,
              actionButton("reset_db_button", "Reset database", width = "200px"),
              div(style = "height:20px;"),
              offset = 4
            ))
          ),
          mainPanel(DT::dataTableOutput("table_database"))
        )
      )
    )
  )
)
