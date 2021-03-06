##----------------------------------------------------------------------------##
## Server function for Cerebro.
##----------------------------------------------------------------------------##
server <- function(input, output, session) {

  ##--------------------------------------------------------------------------##
  ## Load color setup, plotting and utility functions.
  ##--------------------------------------------------------------------------##
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/color_setup.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/plotting_functions.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/utility_functions.R"), local = TRUE)

  ##--------------------------------------------------------------------------##
  ## Central parameters.
  ##--------------------------------------------------------------------------##
  scatter_plot_point_size <- list(
    min = 1,
    max = 20,
    step = 1,
    default = 5
  )

  scatter_plot_point_opacity <- list(
    min = 0.1,
    max = 1.0,
    step = 0.1,
    default = 1.0
  )

  scatter_plot_percentage_cells_to_show <- list(
    min = 10,
    max = 100,
    step = 10,
    default = 100
  )

  preferences <- reactiveValues(
    use_webgl = TRUE
  )

  ## paths for storing plots
  available_storage_volumes <- c(
    Home = "~",
    shinyFiles::getVolumes()()
  )

  ##--------------------------------------------------------------------------##
  ## Load data set.
  ##--------------------------------------------------------------------------##

  ## reactive value holding path to file of data set to load
  data_to_load <- reactiveValues()

  ## listen to selected 'input_file', initialize before UI element is loaded
  observeEvent(input[['input_file']], ignoreNULL = FALSE, {

    ## grab path from 'input_file' if one is specified
    if (
      !is.null(input[["input_file"]]) &&
      !is.na(input[["input_file"]]) &&
      file.exists(input[["input_file"]]$datapath)
    ) {
      new_path <- input[["input_file"]]$datapath

    ## take path from 'Cerebro.options' if it is set
    } else if (
      exists('Cerebro.options') &&
      !is.null(Cerebro.options[["crb_file_to_load"]]) &&
      file.exists(Cerebro.options[["crb_file_to_load"]])
    ) {
      new_path <- .GlobalEnv$Cerebro.options$crb_file_to_load

    ## if none of the above apply, get path of example data set
    } else {
      new_path <- system.file("extdata/v1.3/example.crb", package = "cerebroApp")
    }

    ## set reactive value to new file path
    data_to_load$path <- new_path
  })

  ## create reactive value holding the current data set
  data_set <- reactive({

    ## log message
    print(glue::glue("[{Sys.time()}] File to load: {data_to_load$path}"))

    ## read the file
    data <- readRDS(data_to_load$path)

    ## log message
    message(data$print())

    ## check if 'expression' slot exists and print log message with its format
    ## if it does
    if ( !is.null(data$expression) ) {
      print(glue::glue("[{Sys.time()}] Format of expression data: {class(data$expression)}"))
    }

    ## return loaded data
    return(data)
  })

  ##--------------------------------------------------------------------------##
  ## Show "Trajectory" tab if there are trajectories in the data set.
  ##--------------------------------------------------------------------------##

  ## the tab item needs to be in the `output`
  output[["sidebar_item_trajectory"]] <- renderMenu({

    ## require a data set to be loaded
    req(
      !is.null(data_set())
    )

    menuItem("Trajectory", tabName = "trajectory", icon = icon("random"))
  })

  ## this reactive value checks whether the tab should be shown or not
  show_trajectory_tab <- reactive({

    ## require a data set to be loaded
    req(
      !is.null(data_set())
    )

    ## if at least one trajectory is present, return TRUE, otherwise FALSE
    if (
      !is.null(getMethodsForTrajectories()) &&
      length(getMethodsForTrajectories()) > 0
    ) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  })

  ## listen to reactive value defined above and toggle visibility of trajectory
  ## tab accordingly
  observe({
    shinyjs::toggleElement(
      id = "sidebar_item_trajectory",
      condition = show_trajectory_tab()
    )
  })

  ##--------------------------------------------------------------------------##
  ## Show "Extra material" tab if there is some extra material in the data set.
  ##--------------------------------------------------------------------------##

  ## the tab item needs to be in the `output`
  output[["sidebar_item_extra_material"]] <- renderMenu({

    ## require a data set to be loaded
    req(
      !is.null(data_set())
    )

    menuItem("Extra material", tabName = "extra_material", icon = icon("gift"))
  })

  ## this reactive value checks whether the tab should be shown or not
  show_extra_material_tab <- reactive({

    ## require a data set to be loaded
    req(
      !is.null(data_set())
    )

    ## if at least one piece of extra material is present, return TRUE,
    ## otherwise FALSE
    if (
      !is.null(getExtraMaterialCategories()) &&
      length(getExtraMaterialCategories()) > 0
    ) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  })

  ## listen to reactive value defined above and toggle visibility of extra
  ## material tab accordingly
  observe({
    shinyjs::toggleElement(
      id = "sidebar_item_extra_material",
      condition = show_extra_material_tab()
    )
  })

  ##--------------------------------------------------------------------------##
  ## Print log message when switching tab (for debugging).
  ##--------------------------------------------------------------------------##
  observe({
    print(glue::glue("[{Sys.time()}] Active tab: {input[['sidebar']]}"))
  })

  ##--------------------------------------------------------------------------##
  ## Tabs.
  ##--------------------------------------------------------------------------##
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/load_data/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/overview/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/groups/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/most_expressed_genes/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/marker_genes/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/enriched_pathways/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/gene_expression/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/trajectory/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/extra_material/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/gene_id_conversion/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/analysis_info/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/color_management/server.R"), local = TRUE)
  source(paste0(Cerebro.options[["cerebro_root"]], "/shiny/v1.3/about/server.R"), local = TRUE)
}
