# Load tidyverse libraries, and set up CKAN URLs and API tokens
source("lib/ckan_helpers.R")

# Example usage:

# 1. Upload all (new) resource files in input/*, using a directory for each package that matches the CKAN package name.

# upload_all_input_files()

# 2a. Alternatively, upload a specific directory. This adds any new files in "input/bulk-upload-testing-001" to the package named "bulk-upload-testing-001".

# upload_all_files_to_package("bulk-upload-testing-001")

# 2b. If the package does not exist on the CKAN instance specified in .env, it will raise an error message.

# upload_all_files_to_package("non-existent-bulk-upload-testing-001")

# 3. After finishing, optionally list the run log or export it to CSV:

# run_log |> write_csv("log/run_log.csv")
# run_log |> View()
