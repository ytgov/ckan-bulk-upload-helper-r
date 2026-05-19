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


upload_all_files_to_package <- function(package_name, replace_existing_files = FALSE) {
  
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
  
  if(package$num_resources > 0) {
    existing_package_resources <- package$resources |> pull(name)
    existing_package_resources_data <- package$resources |> as_tibble()
  }
  else {
    existing_package_resources <- NA_character_
    existing_package_resources_data <- tibble()
  }
  
  
  number_of_resources_added <- 0
  number_of_existing_resources_skipped <- 0
  number_of_existing_resources_replaced <- 0
  
  add_log_entry(str_c("Adding resources for ", package_name, " (", package_id, ") found on ", ckan_url))
  
  folder_path <- path("input", package_name)
  
  resources_to_upload <- dir_ls(folder_path, type = "file")
  
  for (i in seq_along(resources_to_upload)) { 
    
    new_resource_name <- path_ext_remove(path_file(resources_to_upload[i]))
    
    if(new_resource_name %in% existing_package_resources) {
      
      if(replace_existing_files == TRUE) {
        
        # Find matching resource ID
        resource_id <- NA_character_
        
        resource_id <- existing_package_resources_data |> 
          filter(name == new_resource_name) |> 
          first() |> 
          pull("id")
        
        if(! is.na(resource_id)) {
          
          add_log_entry(str_c("Replacing existing resource '", new_resource_name, "' with ", resources_to_upload[i]))
          
          resource_update(
            id = resource_id,
            path = resources_to_upload[i],
          )
          
          number_of_existing_resources_replaced <- number_of_existing_resources_replaced + 1
          
          Sys.sleep(0.4)
          
        }
        else {
          add_log_entry(str_c("Error when trying to replace existing resource '", new_resource_name, "' with ", resources_to_upload[i]))
        }

        

        
      }
      else {
        
        add_log_entry(str_c("Did not upload ", resources_to_upload[i], "; resource named '", new_resource_name, "' already exists."))
        
        number_of_existing_resources_skipped <- number_of_existing_resources_skipped + 1
      }
      
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
  
  if(number_of_existing_resources_replaced > 0) {
    add_log_entry(str_c("Replaced ", number_of_existing_resources_replaced, " existing package resources for ", package_name, "."))
  }
  
  if(number_of_existing_resources_skipped > 0) {
    add_log_entry(str_c("Did not upload ", number_of_existing_resources_skipped, " existing package resources for ", package_name, "."))
  }
  
  package_id
  
}

# Upload all files in input/ to the matching package names:
upload_all_input_files <- function(replace_existing_files = FALSE) {
  
  package_directories <- dir_ls("input", type = "directory")
  
  for (i in seq_along(package_directories)) { 
    
    current_package_directory <- path_file(package_directories[i])
    
    add_log_entry(str_c("Finding local resources in ", current_package_directory, "."))
    
    upload_all_files_to_package(current_package_directory, replace_existing_files)
    
  }
  
}

