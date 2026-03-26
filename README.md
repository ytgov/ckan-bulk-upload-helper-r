# ckan-bulk-upload-helper-r

This set of R scripts automates bulk resource uploading for open.yukon.ca. It uses the [CKAN API](https://docs.ckan.org/en/2.11/api/) and is intended for open.yukon.ca site administrators and editors.

These scripts use the [Tidyverse](https://tidyverse.org/) and several other R packages.

To connect to the CKAN 2.11 API, this requires the development version of [ckanr](https://github.com/ropensci/ckanr) (version 0.8.1 or higher, which as of 2026-02 is not yet available on CRAN).

## Initial setup

1. Install the R packages found in `lib/ckan_helpers.R` (typically using the `renv::restore()` function from [renv](https://rstudio.github.io/renv/)).
2. Duplicate the `.env.example` file as `.env` and add your CKAN API token to the `.env` file (which is not Git-tracked).

## Usage

This script bulk-uploads resources from a local folder to an existing CKAN package on [open.yukon.ca](https://open.yukon.ca/). "Packages" in this context refers to a dataset or publication that has its own page on open.yukon.ca.

To use it:

1. Create the package (dataset or publication) on open.yukon.ca that will contain the planned resources, if it doesn't already exist.
2. Within the `input/` folder in this R project, add a folder with the same name as your package. (The package name is visible in the URL when you're viewing the package page on open.yukon.ca, it's the "slug-ified" version of the package title. For example, the package name would be `list-of-registered-yukon-societies`, not `List of registered Yukon societies`.)
3. In `bulk_upload.R`, add or uncomment a function call of `upload_all_files_to_package()` with your package name as the one parameter.
4. Run the `bulk_upload.R` script.
5. Optionally, save the run_log to a CSV file to review, or view it within the R console.

## For more information

Email <sean.boots@yukon.ca> or <eservices@yukon.ca>.

[Find out more about the Government of Yukon's open government program](https://yukon.ca/en/your-government/open-government/learn-about-open-government).
