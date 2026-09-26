# VLabR

VLabR is a small R utility package for common data-cleaning and summary-table
tasks. It includes helpers for column-name cleaning, duplicate detection,
uniqueness checks, quote removal, one-row summaries for categorical and
continuous variables, covariate balance comparison, stable de-identified SID
generation, and date formatting.

The core data-cleaning helpers are intentionally lightweight. The personal-name
masking workflow can use `reticulate` plus spaCy when Python is available, but it
also has a pure R regex fallback for locked-down work computers where Python
cannot be changed. VLabR requires R 4.1.0 or later.

### Installation

Install the development version from GitHub:

```r
install.packages("remotes")
remotes::install_github("LaboratoireV/VLabR", upgrade = "never")
```

Load the package:

```r
library(VLabR)
```

If you need to reinstall the latest GitHub version over an existing local copy:

```r
remotes::install_github("LaboratoireV/VLabR", force = TRUE, upgrade = "never")
```

### Startup package loading

Load the default VLabR workflow package set in the current R session:

```r
vlab_load_vlabr_packages()
```

The default set is:

```r
vlab_default_vlabr_packages()
```

To make R or RStudio load those packages automatically every time it starts,
run this once:

```r
vlab_enable_vlabr_startup_packages()
```

This writes a VLabR-managed block to `~/.Rprofile`. Restart R or RStudio after
enabling it. To remove the automatic startup loading later:

```r
vlab_disable_vlabr_startup_packages()
```

### Functions

Use the `vlab_`-prefixed names. A few older unprefixed helper names remain
available for name masking and package loading.

> **Development notice:** `vlab_google_travel()` is currently in development
> and has not been formally released. `vlab_travel()` also remains
> experimental. Their interfaces, routing behavior, and returned results may
> change while development and testing are in progress. Do not rely on them for
> safety-critical, clinical, or production decisions without independent
> validation.

| Recommended function | Older compatible name | Purpose |
| --- | --- | --- |
| `vlab_fix_colname()` | - | Clean column names by replacing spaces and removing selected special characters. |
| `vlab_get_duplicates()` | - | Find duplicated rows by one or more key columns. |
| `vlab_google_travel()` | - | In development: add Google Routes API travel distance and travel time; current traffic is disabled by default. |
| `vlab_check_unique()` | - | Check whether a column contains unique values. |
| `vlab_count_unique_categories()` | - | Count unique categories in a variable. |
| `vlab_cross_table()` | - | Build a two-variable cross table with counts and percentages. |
| `vlab_data_type()` | - | Classify selected columns as continuous, categorical, date, or other. |
| `vlab_quote_rm()` | - | Remove common quote characters from character and factor columns. |
| `vlab_1_cat()` | - | Build a one-row count and percentage table for a categorical variable. |
| `vlab_1_cont()` | - | Build a one-row summary table for a continuous variable. |
| `vlab_compare_balance()` | - | Compare covariate balance between two data frames. |
| `vlab_SID_creator()` | - | Create a stable de-identified SID from name, date of birth, and gender. |
| `vlab_today()` | - | Return today's date in underscore and compact formats. |
| `vlab_read_csv()` | - | Import one CSV file or all CSV files in a directory. |
| `vlab_read_xlsx()` | - | Import one XLSX workbook or all XLSX files in a directory. |
| `vlab_read_rds()` | - | Import one RDS object or all RDS files in a directory. |
| `vlab_SRds()` | - | Save an R object to an RDS file. |
| `vlab_LRds()` | - | Restore an R object from an RDS file. |
| `vlab_setup_name_masking()` | `setup_name_masking()` | Prepare the spaCy engine when available, or the pure R regex fallback. |
| `vlab_check_name_masking()` | `check_name_masking()` | Report the current Python, spaCy, and model setup status. |
| `vlab_mask()` | - | Mask complete values or a chosen number of characters from the front or back. |
| `vlab_mask_person_names()` | `mask_person_names()` | Replace detected personal names in text with a replacement string. |
| `vlab_mask_PHN()` | - | Mask nine-digit Personal Health Numbers near a `PHN` label. |
| `vlab_mask_PHN_flag()` | - | Return 1 when a PHN is detected and 0 otherwise. |
| `vlab_detect_person_names()` | `detect_person_names()` | Return an audit table of detected names and character offsets. |
| `vlab_name_flag()` | - | Return a 1/0 vector showing whether each text value contains a detected personal name. |
| `vlab_mask_person_names2()` | - | Mask only exact or similar names from row-aligned known-name columns. |
| `vlab_name_flag2()` | - | Flag only exact or similar names from row-aligned known-name columns. |
| `vlab_apply_name_masking_rules()` | `apply_name_masking_rules()` | Apply supplementary regex-based name-masking rules. |
| `vlab_todate()` | - | Convert common date inputs to R `Date` values. |
| `vlab_todatetime()` | - | Convert common date and date-time inputs to R `POSIXct` values. |
| `vlab_travel()` | - | Experimental: add OSRM road travel distance and travel time for coordinate pairs. |
| `vlab_boost_data()` | - | Detect and convert date-like columns in a data set. |
| `vlab_load_packages()` | `load_packages()` | Install missing packages and load a package list. |
| `vlab_load_vlabr_packages()` | `load_vlabr_packages()` | Load the default VLabR startup package set. |
| `vlab_enable_vlabr_startup_packages()` | `enable_vlabr_startup_packages()` | Enable automatic package loading at R startup. |
| `vlab_disable_vlabr_startup_packages()` | `disable_vlabr_startup_packages()` | Disable automatic package loading at R startup. |

### Google travel (in development)

`vlab_google_travel()` is in development and has not been formally released.
It sends each unique valid origin-destination coordinate pair to the Google
Routes API and adds distance in metres and travel time in seconds. The default
`TRAFFIC_UNAWARE` preference does not use current traffic.

For a direct request, store a restricted key outside your script:

```r
Sys.setenv(GOOGLE_MAPS_API_KEY = "your_restricted_key")

result <- vlab_google_travel(
  dataset = trips,
  start_latitude = "start_lat",
  start_longitude = "start_lon",
  end_latitude = "end_lat",
  end_longitude = "end_lon"
)
```

The direct backend is pinned to `https://routes.googleapis.com`; callers cannot
change that endpoint. For another computer that must not receive the Google API
key, use the separately deployed VLabR proxy. The client sends only Basic Auth
credentials to the fixed `https://google-routes.mooseweb3.com` HTTPS endpoint:

```r
Sys.setenv(
  VLABR_GOOGLE_USER = "your_proxy_username",
  VLABR_GOOGLE_PASSWORD = "your_proxy_password"
)

result <- vlab_google_travel(
  dataset = trips,
  start_latitude = "start_lat",
  start_longitude = "start_lon",
  end_latitude = "end_lat",
  end_longitude = "end_lon",
  backend = "vlabr_proxy"
)
```

The proxy is not included in the R package and must be deployed before proxy
mode will work. The proxy must inject its Google key server-side, overwrite or
strip any client-supplied Google key header, restrict allowed routes and HTTP
methods, and apply appropriate rate limits. Coordinates are ultimately sent to
Google in both modes.
Traffic-aware preferences currently use the Compute Routes Pro tier, and
`TWO_WHEELER` currently uses the Enterprise tier. Review current
[Google pricing](https://developers.google.com/maps/billing-and-pricing/pricing),
[Routes API billing](https://developers.google.com/maps/documentation/routes/usage-and-billing),
and [Routes API policies](https://developers.google.com/maps/documentation/routes/policies)
before large jobs or storing/displaying results.

### Examples

Clean column names:

```r
df <- data.frame("Col (1)" = 1:3, "Name's-Age" = c(20, 25, 30))
vlab_fix_colname(df)
```

Summarize a categorical variable:

```r
df <- data.frame(group = c("A", "B", "A", NA, "C", "B", "B"))
vlab_1_cat(df, "group", display_name = "Group")
```

Summarize a continuous variable:

```r
df <- data.frame(age = c(21, 34, 45, 52, NA, 63))
vlab_1_cont(df, "age", display_name = "Age")
```

Find duplicate rows by key:

```r
vlab_get_duplicates(mtcars, cyl, gear, .keep_all = FALSE)
```

Check uniqueness:

```r
vlab_check_unique(iris, Species)
vlab_check_unique(iris, "Species", na.rm = TRUE)
```

Create stable de-identified SIDs:

```r
vlab_SID_creator(
  first_name = c("Ann", "Marie"),
  last_name = c("Martin", "Dubois"),
  DOB_ready = c("1990-07-03", "2000/01/02"),
  gender = c("F", "M")
)
```

Compare balance between two data frames:

```r
set.seed(1)
a <- data.frame(x = rnorm(100), g = sample(c("M", "F"), 100, TRUE))
b <- data.frame(x = rnorm(120, 0.2, 1.1), g = sample(c("M", "F"), 120, TRUE))

vlab_compare_balance(a, b, vars = c("x", "g"), include_smd = TRUE)
```

Get today's date:

```r
vlab_today()
```

Convert common date and date-time inputs:

```r
vlab_todate(c("2024-01-05", "01/06/2024", "20240107"))
vlab_todate(c("01/02/2026", "13/02/2026", "03/02/2026"))
vlab_todate("13-Jul-26") # 2026-07-13
vlab_todate(c("09/01/26", "Sep 1, 26", "260901"))
vlab_todate("09/01/26", two_digit_year_cutoff = 20) # 1926-09-01
vlab_todate(c(20240105, 45296))

vlab_todatetime(c("2024-01-05 13:30:00", "2024/01/06 8:05"))
vlab_todatetime("09/01/26 13:30:00")
vlab_todatetime(c(202401051330, 1704450600))
```

By default, two-digit years follow the R convention: `00`-`68` become
2000-2068 and `69`-`99` become 1969-1999. Set `two_digit_year_cutoff` to a
whole number from 0 to 99 to change the boundary: years at or below the cutoff
use the 2000s, while larger years use the 1900s. Prefer four-digit years when
the century must be unambiguous. Month names such as `Sep` use the current R
`LC_TIME` locale.

For ambiguous numeric dates, VLabR examines other values in the same vector.
Values such as `13/02/2026` support day/month/year, while `02/13/2026`
supports month/day/year. The order with more evidence is used; `day_first` is
the fallback for a tie. Inputs already stored with a year from 0000 to 0099
are also normalized using the two-digit-year cutoff.

Automatically convert date-like columns in a data set:

```r
raw_data <- data.frame(
  visit_date = c("2024-01-05", "2024/01/06"),
  created_at = c("2024-01-05 13:30", "2024-01-06 08:05"),
  note = c("First visit", "Follow-up")
)

boosted_data <- vlab_boost_data(raw_data)
str(boosted_data)
```

`vlab_boost_data()` also accepts `two_digit_year_cutoff` and passes it to
both date converters.

Save and restore an R object in RDS format:

```r
vlab_SRds(boosted_data, "boosted_data")
restored_data <- vlab_LRds("boosted_data")
```

Import every supported file in a directory at once:

```r
vlab_read_csv("C:/data/csv")
vlab_read_xlsx("C:/data/xlsx")
vlab_read_rds("C:/data/rds")
```

Files are sorted by name and assigned in the calling environment as
`imported_data_001`, `imported_data_002`, and so on. Each function reports the
mapping, for example:

```text
the_data.csv is imported as imported_data_001
```

Directory imports refuse to replace existing objects by default. Use a
different `prefix`, or set `overwrite = TRUE` intentionally. XLSX imports
require `install.packages("readxl")` and read the first worksheet by default.
The older single-file CSV call remains supported:

```r
one_data_set <- vlab_read_csv("C:/data", "the_data.csv")
```

Set up personal-name masking. On normal computers, `engine = "auto"` tries spaCy
and falls back to regex if Python cannot be initialized:

```r
vlab_setup_name_masking()
vlab_check_name_masking()
```

On locked-down work computers where Python cannot be changed, use the pure R
engine directly:

```r
vlab_setup_name_masking(engine = "regex")
vlab_check_name_masking()
```

In regex mode, `vlab_check_name_masking()` should show `Engine: regex`. Python,
spaCy, and the spaCy model are not used in that mode.

The regex engine ignores standalone all-uppercase phrases such as
`MEDICAL RECORDS` or `THE PATIENT`. It accepts all-uppercase names only after a
supported title, such as `RN SMITH`, or a workflow phrase, such as
`Reviewed by JOHN SMITH`.
Healthcare organization names ending in words such as `Hospital`, `Clinic`,
`Centre`, `Health`, or `Foundation` are not treated as personal names. For
example, `St Mary Hospital` and `Vancouver General Hospital` are preserved.
Clinical phrases containing words such as `Chest`, `Pain`, `Disease`, or
`Syndrome` are also preserved; for example, `Cardia Chest Pain` is not masked.
Treatment phrases such as `Normal Saline IV` are also preserved.
Clinical document labels such as `RN Report` are also preserved.
The built-in medical whitelist also preserves title-cased phrases such as
`Chief Complaint`, `Present Illness`, `Code Status`, `On Arrival`, `En Route`,
`Public Assist`, `Covid Screen`, `Year Old`, `Community Paramedic`,
`Orange Event`, `Red Event`, `Yellow Event`,
`Interfacility Transfer`, `Transport Truck`, `Transport Cause`, `Ground Level`, `Nursing Home`, `Altered Mental Status`,
`Nausea Vomiting`, `Nose Bleed`, `Dog Bite`, `Urinary Issues`, `Patient Demographics`,
`Behavioural Problems`, `Substance Abuse`, `Heart Transplant`, `Seizure Activity`,
`Opioid Overdose`, `Heat Exhaustion`, `Dispatched`, `General Malaise`,
`Supportive Living`, `Wellness Check`, `Refill Prescription`, `Return Trip`,
`Edmonton General`, `Safety Alerted`, `Not Feeling`, `Bus Stop`, and
`Language Barrier`, `Cognitive Impairment`, `Emerge Call`, `Contact Droplet`,
`Patient Name`,
`Non Small Cell Lung`, as well as `Situational Crisis`.
This whitelist intentionally takes precedence over the title-case name pattern;
audit data where a real person's name could contain one of these terms.
Common shorthand such as `Hx`, `PMHx`, `HPI`, `ROS`, `PE`, `Dx`, `Rx`, `Tx`,
`Sx`, `GCS`, `SpO2`, `MVC`, and `IFT` are also preserved. The list follows common
clinical-context forms illustrated by the AHS Connect Care
[Smart Naming guide](https://publicshare.albertahealthservices.ca/Main/assets/cmio/AHS_CC_TIP_Smart-Naming.pdf).
It is a name-filtering list, not an approved clinical abbreviation policy;
organizations should apply their own standardized and prohibited-abbreviation
rules.
Comma-separated names are also detected, including `Smith, John`,
`SMITH, JOHN`, `Smith, J.`, and `O'Neil, Anne-Marie`. Canadian geographic
forms such as `Edmonton, Alberta` and `Vancouver, British Columbia` are
preserved. Address or location labels followed by an Alberta municipality,
such as `Avenue, Calgary`, are also preserved.
Location phrases such as `Private Residence`, `West Side`, `Costco Store`, and
`Edmonton International Airport`,
and clinical states such as `Pt Syncopal` and `Heavily Intoxicated`, are also
preserved. `Pt` is treated as the patient abbreviation: it remains visible in
`Pt Smith`, while the name is masked as `Pt [NAME]`.
These exclusions are applied to both the regex and spaCy engines.
VLabR also preserves all 334 official Alberta municipality names, including
`Medicine Hat`, `Red Deer`, and `Rocky Mountain House`. The registry follows
the Government of Alberta 2024 Municipal Codes and excludes the administrative
`Special Areas Board`. The Alberta place name `Fort McMurray` and the common
spelling `Fort McMurry` are also preserved.
VLabR also excludes the 1,150 unique facility names in the Alberta Health
Services [Find Healthcare directory](https://www.albertahealthservices.ca/findhealth/search.aspx),
including hospitals, health centres, clinics, continuing-care sites, and other
official service locations. The complete facility name must occur in the text:
`Peter Lougheed Centre`, `Grand Manor`, and `Chartwell Griesbach` are preserved,
while a standalone personal name is still detected.
VLabR also excludes all 2,616 unique school names in the Alberta Education
[School Information Report](https://education.alberta.ca/alberta-education/school-authority-index/),
covering public, separate, Francophone, charter, independent, First Nations,
ECS private-operator, and provincial schools. Matching is case-insensitive, and
the complete school name must occur in the text. A person's name that is also
part of a school name is still detected when the full school name is absent.
VLabR also preserves 12,435 English and French brand and active-ingredient
names for marketed or approved human drugs from the Health Canada
[Drug Product Database](https://www.canada.ca/en/health-canada/services/drugs-health-products/drug-products/drug-product-database/what-data-extract-drug-product-database.html).
Matching is case-insensitive and ignores accents and punctuation. A partial
match is excluded only when the complete registered drug name occurs in the
text, which limits collisions with personal names.

Mask complete values, or mask a chosen number of characters from either side:

```r
ids <- c("1023056", "98765", NA)

vlab_mask(ids)
#> [1] "*******" "*****"   NA

vlab_mask(ids, side = "front", n = 3)
#> [1] "***3056" "***65"   NA

vlab_mask(ids, side = "back", n = 3)
#> [1] "1023***" "98***"   NA
```

`vlab_mask()` always returns a character vector. Partial masking is not
anonymization, and even complete masking retains value length, missingness,
and any vector `names()`.

Mask names in a character vector:

```r
comments <- c(
  "John Smith spoke with Sarah Johnson in Vancouver.",
  "The patient was transported to Vancouver.",
  "Reviewed by Michael Brown.",
  "",
  NA
)

vlab_mask_person_names(comments)
```

Force the pure R regex engine:

```r
vlab_mask_person_names(comments, engine = "regex")
```

Keep the original and masked text side by side:

```r
vlab_mask_person_names(comments, keep_original = TRUE)
```

Use row-aligned name columns as an additional source of known names. Matching
is case-insensitive and includes individual fields, `First Last`, and
`Last, First` forms:

```r
records <- data.frame(
  comments = c("ALICE SMITH called.", "Spoke to Tremblay, Jean-Paul."),
  first_name = c("Alice", "Jean-Paul"),
  last_name = c("Smith", "Tremblay")
)

records$comments_masked <- vlab_mask_person_names(
  records$comments,
  data = records,
  name_columns = c("first_name", "last_name")
)
records$name_flag <- vlab_name_flag(
  records$comments,
  data = records,
  name_columns = c("first_name", "last_name")
)
```

Each comment is compared only with the name values in the same data-frame row.
This keeps the operation practical for large data sets and avoids treating
every name in the data set as a match for every comment.

Use the `2` functions when names not represented by the same row's known-name
columns must remain unchanged. They do not run spaCy or general name detection:

```r
records$known_names_masked <- vlab_mask_person_names2(
  records$comments,
  data = records,
  name_columns = c("first_name", "last_name")
)
records$known_name_flag <- vlab_name_flag2(
  records$comments,
  data = records,
  name_columns = c("first_name", "last_name")
)
```

The default similar-name rule allows one spelling edit only for known names
with at least five letters. Use `max_distance = 0L` for exact matching only.

Create an audit table of detected names:

```r
vlab_detect_person_names(comments, explain = TRUE)
```

The default `sensitivity = "high_recall"` preserves the broad legacy behavior
and prioritizes avoiding missed names. To reduce false positives from
uncontextualized title-case phrases such as `Home Support`, use
`sensitivity = "balanced"`. The stricter `"high_precision"` mode disables
those broad title-case pairs while retaining titles, workflow phrases,
patient abbreviations, comma-separated names, known-name columns, and spaCy
`PERSON` entities:

```r
vlab_mask_person_names(
  comments,
  engine = "regex",
  sensitivity = "balanced"
)
```

Add a row-level flag for detected personal names:

```r
records <- data.frame(comments = comments)
flagged_records <- dplyr::mutate(
  records,
  name_flag = vlab_name_flag(comments)
)
flagged_records
```

For large data sets, remove grouping first so the complete column is processed
in one call:

```r
flagged_records <- records |>
  dplyr::ungroup() |>
  dplyr::mutate(
    name_flag = vlab_name_flag(comments, batch_size = 2000L)
  )
```

Use supplementary regex rules after spaCy masking:

```r
masked <- vlab_mask_person_names(comments)
vlab_apply_name_masking_rules(masked)
```

For real medical or privacy-sensitive data, keep the audit table and
review a sample of the output. Named-entity recognition is helpful, but it is
not a guarantee that every personal name is found.

### License

MIT license. Copyright (c) 2026 MooseWeb3.
