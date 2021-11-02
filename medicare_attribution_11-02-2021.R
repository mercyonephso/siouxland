library(tidyverse)
library(readxl)
library(data.table)
library(magrittr)
library(here)


medicare<- dir("J:/Mwangi Files/AWS Downloads",
          recursive = TRUE,
          full.names = TRUE,
          pattern = "attribution_11-02-2021"
) %>% 
  map_df(vroom::vroom,
         col_names = TRUE,
         col_types = cols(.default = "c")) %>% 
  .[!duplicated(.["empi"]),]


# CRED ---------------------------------------------

cred <- list.files("V:/INNOVACCER PROJECT/Transfer - Data Team/009 Provider Credentialing Mapping/2021-08/",
                   recursive = FALSE, full.names = TRUE, pattern = "CRED.+\\.xlsx$"
) %>%
  .[!str_detect(., "(Copy|locked|~)")] %>% # recursive false no subfolders
  readxl::read_excel(
    sheet = "Query", range = cell_cols("A:BB"),
    na = "NULL", col_names = TRUE, col_types = "text"
  ) %>% 
  filter(Provider_Location_Code == "PP")



patient <- dir("J:/Mwangi Files/AWS Downloads",
           recursive = TRUE,
           full.names = TRUE,
           pattern = "Patient.+error.xlsx$"
) %>% 
  .[!grepl("~",.)] %>% 
  map_df(read_xlsx,
         col_names = TRUE,
         col_types = "text") %>% 
  janitor::clean_names()


patient_df <- patient %>% 
  left_join(select(medicare, empi, medic_pcpnpi = pcpnpi,medic_pcpn = pcpn,medic_orgn = orgn,medic_orgtin = orgtin), by = "empi")
