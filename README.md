# ckan-bulk-upload-helper-r

This set of R scripts automates bulk resource uploading for open.yukon.ca. It uses the [CKAN API](https://docs.ckan.org/en/2.11/api/) and is intended for open.yukon.ca site administrators and editors.

These scripts use the [Tidyverse](https://tidyverse.org/) and several other R packages.

To connect to the CKAN 2.11 API, this requires the development version of [ckanr](https://github.com/ropensci/ckanr) (version 0.8.1 or higher, which as of 2026-02 is not yet available on CRAN).

## Initial setup

1. Install the R packages found in `lib/ckan_helpers.R` (typically using the `renv::restore()` function from [renv](https://rstudio.github.io/renv/)).
2. Duplicate the `.env.example` file as `.env` and add your CKAN API token to the `.env` file (which is not Git-tracked).

## For more information

Email <sean.boots@yukon.ca> or <eservices@yukon.ca>.

[Find out more about the Government of Yukon's open government program](https://yukon.ca/en/your-government/open-government/learn-about-open-government).
