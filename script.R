# import libraries

library(fabR)        # read/write files
library(tidyverse)   # to transform and shape files
library(madshapR)    # for the function dataset_visualize
library(haven)       # for categorical variables
library(fs)

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

# import files
storms <- read_csv_any_formats("storms.csv")
storms_data_dict <- read_excel_allsheets("data_dict_storm.xlsx")

# select and filter column/rows you would like to include in your visualization
storms <- 
  storms %>% 
  filter(
    status %in%
      c("extratropical","hurricane","tropical storm")) %>%
  select(name, status, date, lat, wind, pressure)

# specify the name of the report and the dataset to visualize
report_name <- 'report_storms'

dataset_visualize(
  dataset = storms,
  data_dict = storms_data_dict,
  to = report_name)

open_visual_report(report_name)

# Possibility to group the visual report by one variable. each statistics and
# showing results (graphs and charts) will be separated by the grouping variable
# the variable must be a categorical variable. 

report_name_group <- 'report_storms_by_status'

dataset_visualize(
  dataset = storms,
  data_dict = storms_data_dict,
  group_by = 'status',
  to = report_name_group)

open_visual_report(report_name_group)

# Possibility to edit and add comments to the report.
# Open each Rmd files you want to edit (variables or index) and add a comment 
# (using > ) or any modification you would like to perform to the report.
# When done, redo the report manually using the function dataset_visualize_redo.

# redo the report
dataset_visualize_redo(report_name)
open_visual_report('report_storms')

# when everything is ok for the report, you can delete original files
try(dir_delete(paste0(report_name,"/temp_bookdown_report/")))
