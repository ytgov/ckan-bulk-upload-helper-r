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
  package <- NULL;
  
  tryCatch({
    package <- package_show(package_name, as = "table")
  }, error = function(e) {
    add_log_entry(e$message)
    add_log_entry(str_c("No package with the name ", package_name, " found on ", ckan_url))
  })

  # package |> View()
  
  if(is.null(package)) {
    return(NULL);
  }
  
  package_id <- package$id
  existing_package_resources <- package$resources |> pull(name)
  
  number_of_resources_added <- 0
  number_of_existing_resources <- 0
  
  add_log_entry(str_c("Adding resources for ", package_name, " (", package_id, ") found on ", ckan_url))
  
  # TODO: upload matching files here.
  folder_path <- path("input", package_name)
  
  resources_to_upload <- dir_ls(folder_path, type = "file")
  
  for (i in seq_along(resources_to_upload)) { 
    
    new_resource_name <- path_ext_remove(path_file(resources_to_upload[i]))
    
    if(new_resource_name %in% existing_package_resources) {
      
      add_log_entry(str_c("Did not upload ", resources_to_upload[i], "; resource named '", new_resource_name, "' already exists."))
      
      number_of_existing_resources <- number_of_existing_resources + 1
      
    }
    else {
      
      add_log_entry(str_c("Uploading ", resources_to_upload[i]))
      
      resource_create(
        package_id = package_id,
        upload = resources_to_upload[i],
        name = new_resource_name
      )
      
      number_of_resources_added <- number_of_resources_added + 1
      
      Sys.sleep(0.4)
    }
    

    
  }
  
  add_log_entry(str_c("Uploaded ", number_of_resources_added, " new resources for ", package_name, "."))
  
  if(number_of_existing_resources > 0) {
    add_log_entry(str_c("Did not upload ", number_of_existing_resources, " existing package resources for ", package_name, "."))
  }
  
  package_id
  
}

# Upload all files in input/ to the matching package names:
upload_all_input_files <- function() {
  
  package_directories <- dir_ls("input", type = "directory")
  
  for (i in seq_along(package_directories)) { 
    
    current_package_directory <- path_file(package_directories[i])
    
    add_log_entry(str_c("Finding local resources in ", current_package_directory, "."))
    
    upload_all_files_to_package(current_package_directory)
    
  }
  
}

