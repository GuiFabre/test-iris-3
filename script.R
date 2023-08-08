################## 
#     UQAM       #
##################

# import libraries

library(tidyverse)   # to transform and shape files
library(fabR)        # read/write files
library(madshapR)    # for the function dataset_visualize
library(haven)       # for categorical variables
library(fs)
library(janitor)

# import local functions
dataset_visualize_redo <- function(report_name){
  
  library(xfun)
  library(bookdown)
  
  # Remove unnecessary elements of the report
  ##### _output.yml ##########
  path_to = path_abs(report_name)
  dir = paste0(path_to, "/temp_bookdown_report/file/bookdown-template-master/")
  
  paste0(
'bookdown::gitbook:
  css: style.css
    ') %>% write_lines(
  file = paste0(dir,"/_output.yml"),
  append = FALSE)
  
  
  input = paste0(dir,"/index.Rmd")
  in_dir(dir = dir, expr = render_book(input))
  
  if(file.exists(paste0(path_to,"/docs"))) try(dir_delete(paste0(path_to,"/docs")))
  dir_copy(paste0(dir,"/docs"),paste0(path_to,"/docs"),overwrite = TRUE)  
}
create_example_files <- function(){
  if(file.exists('example_files')) dir_delete('example_files')
  dir_create('example_files')
  storms <-
    dplyr::storms %>%
    unite(
      col = date ,na.rm = TRUE,
      c('year','month','day'),
      sep = '-', remove = TRUE) %>%
    filter(name %in% c("Bertha","Edouard","Josephine")) %>%
    filter(status %in% c(
      "hurricane","extratropical",
      "subtropical storm","tropical storm")) %>%
    mutate(date = as_any_date(date,format = 'ymd')) %>%
    mutate(status = factor(status))
  
  write_csv(storms,na = "",'example_files/storms.csv')
  
  storms_data_dict <- data_dict_extract(storms)
  
  write_excel_allsheets(storms_data_dict, "example_files/data_dict_storm.xlsx")
  
}
prepare_for_git <- function(report_name){
  
  # when everything is ok for the report, you can delete original files

  paste0(
    '.Rproj.user
*.Rproj
*example_files
.Rhistory
.RData
.Ruserdata
',report_name,"/") %>% write_lines(
      file = paste0(".gitignore"),
      append = FALSE)
  
  if(dir.exists('docs')) try(dir_delete("docs"))
  try(dir_copy(paste0(report_name,"/docs"),'docs'))
  
}

# import files
# create_example_files()
all_dataset <- read_excel_allsheets("Mission ECLAIR - 2023 - cleaned_data - datasets.xlsx")
all_data_dict <- read_excel_allsheets("Mission ECLAIR - 2023 - cleaned_data - data_dict.xlsx")

# select and filter column/rows you would like to include in your visualization
### 
etablissement <- 'Data_UQAM'

my_dataset <- 
  all_dataset$`cleaned_data - all data` %>%
  filter(table_id == etablissement) %>%
  select(id, table_id,contains("logement")) %>%
  remove_empty("cols")

my_data_dict <- 
  all_data_dict %>% 
  data_dict_filter(
    filter_all = 'dataset_name == "Mission ECLAIR - 2023 - cleaned_data"') %>%
  data_dict_match_dataset(dataset = my_dataset,out = 'data_dict')

my_dataset <- 
  data_dict_apply(my_dataset, my_data_dict) %>%
  dataset_cat_as_labels()

# specify the name of the report and the dataset to visualize

dataset_visualize(
  dataset = my_dataset,
  to = etablissement)

open_visual_report(etablissement)

# Possibility to edit and add comments to the report.
# Open each Rmd files you want to edit (variables or index) and add a comment 
# (using > ) or any modification you would like to perform to the report.
# When done, redo the report manually using the function dataset_visualize_redo.

# redo the report
dataset_visualize_redo(report_name)
open_visual_report(report_name)

# when everything is ok for the report, you can delete original files

prepare_for_git(report_name)

# Go to terminal, add, commit and push.
