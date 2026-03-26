# Load tidyverse libraries, and set up CKAN URLs and API tokens
source("lib/ckan_helpers.R")

# Example usage:
# This uploads all the files in "input/bulk-upload-testing-001" to the package named "bulk-upload-testing-001".

# upload_all_files_to_package("bulk-upload-testing-001")

# If the package does not exist on the CKAN instance specified in .env, it will raise an error message.

# upload_all_files_to_package("non-existent-bulk-upload-testing-001")

# Optionally list the run log or export it to CSV:

# run_log |> write_csv("log/run_log.csv")
# run_log |> View()
