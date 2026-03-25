library(tidyverse)
library(fs)
library(readxl)
library(rmarkdown)
library(janitor)
library(ckanr)
library(lubridate)
library(DescTools)

# The list of libraries above could be shortened; we're not going for efficiency here. :P 

# Initial setup -----------------------------------------------------------

run_log <- tribble(
  ~time, ~message
)

# Logging helper function
add_log_entry <- function(log_text) {
  
  new_row = tibble_row(
    time = now(),
    message = log_text
  )
  
  run_log <<- run_log |>
    bind_rows(
      new_row
    )
  
  cat(log_text, "\n")
}

run_start_time <- now()
add_log_entry(str_c("Start time was: ", run_start_time))

if(file_exists(".env")) {
  readRenviron(".env")
  
  ckan_url <- Sys.getenv("ckan_url")
  
  ckanr_setup(
    url = ckan_url, 
    key = Sys.getenv("ckan_api_token")
  )
  
} else {
  stop("No .env file found, create it before running this script.")
}


upload_all_files_to_package <- function(package_name) {
  
  # package_name <- "bulk-upload-testing-001"
  
  tryCatch({
    package <- package_show(package_name, as = "table")
  }, error = function(e) {
    
    # e |> View()
    add_log_entry(e$message)
    add_log_entry(str_c("No package with the name ", package_name, " found on ", ckan_url))
    return(NULL);
    
  })

  
  package_id <- package$id
  
  add_log_entry(str_c("Adding resources for ", package_name, " (", package_id, ") found on ", ckan_url))
  
  # TODO: upload matching files here.
  
  package_id
  
}

# upload_all_files_to_package("bulk-upload-testing-001")

# upload_all_files_to_package("non-existent-bulk-upload-testing-001")
