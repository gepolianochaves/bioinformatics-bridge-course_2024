library(shiny)
library(googlesheets4)

googlesheets4::gs4_deauth()
googlesheets4::gs4_auth()

# Define the fields we want to save from the form
fields <- c("name", "used_shiny", "r_num_years")

# Save a response
# ---- This is one of the two functions we will change for every storage type ----
saveData <- function(data) {
  # The data must be a dataframe rather than a named vector
  data <- data %>% as.list() %>% data.frame()
  # Add the data as a new row
  sheet_append("https://docs.google.com/spreadsheets/d/13kZKmkpdM_JfvpFUO5KfpX_AIwrjeVdVh_Mlz0Gy5sI/edit?gid=0#", data)
}




# Load all previous responses
# ---- This is one of the two functions we will change for every storage type ----
loadData <- function() {
  # Read the data
  read_sheet("https://docs.google.com/spreadsheets/d/13kZKmkpdM_JfvpFUO5KfpX_AIwrjeVdVh_Mlz0Gy5sI/edit?gid=0#")
}

# Shiny app with 3 fields that the user can submit data for
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("responses", width = 300), tags$hr(),
    textInput("name", "Name", ""),
    checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
    sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
    actionButton("submit", "Submit")
  ),
  server = function(input, output, session) {
    
    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })     
  }
)