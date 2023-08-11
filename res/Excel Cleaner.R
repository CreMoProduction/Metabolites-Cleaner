#debug settings, use --FALSE-- value when running in RStudio
#
OS_environment = TRUE  #<-------EDIT HERE TO DEBUG MODE
#
#
if (OS_environment==TRUE) {
  #install.packages('plyr', repos = "http://cran.us.r-project.org")
  print("running in command prompt")
  options(repos = list(CRAN="http://cran.rstudio.com/"))
} else {
  print("runnning in RStudio")
  rm(list=setdiff(ls(), "OS_environment"))   #clear environment
}
package= function() {
  packages <- c(
                "dplyr", 
                "readxl", 
                "yaml",      #для импорта настроек
                "rio",       #экспорт xlsx файл
                "openxlsx",
                "stringdist" #ищу совпадения в строках
  )
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")
  #-----------
  lapply(packages, require, character.only = TRUE)
}
#Импорт данных
#---получаю путь к этому файлу
if  (OS_environment==FALSE) { 
  getCurrentFileLocation <-  function(){
    this_file <- commandArgs() %>% 
      tibble::enframe(name = NULL) %>%
      tidyr::separate(col=value, into=c("key", "value"), sep="=", fill='right') %>%
      dplyr::filter(key == "--file") %>%
      dplyr::pull(value)
    if (length(this_file)==0)
    {
      this_file <- rstudioapi::getSourceEditorContext()$path
      package()
    }
    return(dirname(this_file))
  }
  currentfillelocation = getCurrentFileLocation()
} else {
  currentfillelocation <- "C:/metabolite_cleaner_data"
  source(paste(currentfillelocation, "/package", sep=""))
  package_OS()
}
currentfillelocation = gsub("/res","",currentfillelocation) 
#---импортирую настройки из файла config.yml
config = yaml.load_file(file.path(currentfillelocation, "config.yml"))
#working_xlsx_workbook= config$excel_cleaner$xlsx_name
working_sheet= config$excel_cleaner$xlsx_sheet
search_algorithm= config$excel_cleaner$search_algorithm
#--------------
#working_xlsx_workbook = "RDA_Target_Data_Model"
#working_sheet = "Integrated Unimodal 1"
#--------------
#-----------------------работаю с файлами картинок
#файлы approved
#if (interactive() && .Platform$OS.type == "windows") {
dir=choose.files( caption= "Select Excel File", multi = FALSE)
# Check if a file was selected
if (length(dir) == 0 || :file_ext(dir) =="xlsx") {
  stop("No file selected or wrong file type")
}
#  }
#dir = choose.dir(default = "", caption = "Select Output RDA folder")
lst_files = list.files(path=dirname(dir), pattern="\\.png$", all.files=FALSE, full.names=FALSE)
#файлы rejected
dir_rejected = file.path(dirname(dir), "Rejected", fsep="\\")
lst_files_rejected = list.files(path=dir_rejected, pattern="\\.png$", all.files=FALSE, full.names=FALSE)
#получаю расширение файла .png
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
#создаю список только с названиями .png
lst_files_png = c()
for (i in 1:length(lst_files)) {
  if (grepl(substrRight(lst_files[i], 4), ".png")== TRUE) {
    #print(lst_files[i])
    lst_files_png = append(lst_files_png, lst_files[i])
  } 
}
print(paste("Total found metabolites: ", length(lst_files)+length(lst_files_rejected), sep=""))
print(paste("Found metabolites to reject: ", length(lst_files_rejected), sep=""))
#создаю дубликат xlsx
xlsx = file.path(dir)
xlsx_new= file.path(dirname(dir), paste(tools::file_path_sans_ext(basename(dir)),"_CLEAN.xlsx", sep=""), fsep="/")
file.copy(xlsx, xlsx_new, overwrite = TRUE )
#открываю excel файл
Excel_file = read_excel(xlsx_new, sheet = working_sheet)
#создаю лист Rejected
wb <- loadWorkbook(file = xlsx_new)
addWorksheet(wb, paste("Rejected"))
df_rejected = NULL
df_rejected =  Excel_file[,1:2]
#----------
#поиск по индексу
index_search= function() {
  for (k in 1:length(lst_files_rejected)) {
    for (i in 3:ncol(Excel_file)) {
      if (substr(names(Excel_file[,i]), 1, 4)== substr(lst_files_rejected[k], 1, 4)) {
        df_rejected = cbind(df_rejected, Excel_file[,i])
        print(paste(colnames(Excel_file)[i]))
        #Excel_file=Excel_file[,-i]
        Excel_file[,i]= NULL
        break
      } else {
        i=i+1
      }
    }
  }
  result <- list(df_rejected, Excel_file)
  return(result)
}
#поиск по имени
name_search= function() {
  for (k in 1:length(lst_files_rejected)) {
    q= gsub("[(_)-]", " ", lst_files_rejected[k])
    q= substr(q, 1, nchar(q) - 4)
    distances= stringdist::stringdistmatrix(
      q,
      gsub("[(_)-]", " ", colnames(Excel_file))
      )
    highest_match_index <- which.min(distances)
    highest_match_string <- colnames(Excel_file)[highest_match_index]
    print(paste(gsub("[(_)-]", " ", highest_match_string), " --- ", q, sep=" "))
    df_rejected = cbind(df_rejected, Excel_file[,highest_match_index])
    #Excel_file=Excel_file[,-highest_match_index]
    Excel_file[,highest_match_index]= NULL
    #print(paste("TRUE", i))
  }
  result <- list(df_rejected, Excel_file)
  return(result)
ECHO is off.
  # for (k in 1:length(lst_files_rejected)) {
  #   for (i in 3:ncol(Excel_file)) {
  # 
  # 
  # 
  #     if (substr(names(Excel_file[,i]), 1, 4)== substr(lst_files_rejected[k], 1, 4)) {
  #       df_rejected = cbind(df_rejected, Excel_file[,i])
  #       Excel_file[,i] = NULL
  #       print(paste("TRUE", i))
  #       break
  #     } else {
  #       i=i+1
  #     }
  #   }
  # }
}
#--------главная исполняемая фишка здесь
if (search_algorithm==0) {
  print(paste("-------------"))
  print("REMOVED REJECTED:")
  result=index_search()
} else {
  print(paste("-------------"))
  print("REMOVED REJECTED:")
  print(paste("(Input:)  ", " --- ","  (Match:)", sep=" "))
  result=name_search()
}
#получаю датасетыдля эксель
df_rejected= data.frame(result[1])
Excel_file= data.frame(result[2])
#заменяю точки на пробел
colnames(df_rejected)= gsub("\\.", " ", colnames(df_rejected))
colnames(Excel_file)= gsub("\\.", " ", colnames(Excel_file))
removeWorksheet(wb, sheet = working_sheet)
saveWorkbook(wb, xlsx_new, overwrite = TRUE)
#deleteData(wb,working_sheet, 1:ncol(Excel_file)+length(lst_files_rejected), 1:nrow(Excel_file), gridExpand = TRUE)
addWorksheet(wb, paste(working_sheet))
writeData(wb,paste(working_sheet), Excel_file)
saveWorkbook(wb,xlsx_new, overwrite = TRUE)
#writeData(wb,working_sheet, Excel_file)
#сохраняю файл с Rejected
writeData(wb,paste("Rejected"), df_rejected)
saveWorkbook(wb,xlsx_new,overwrite = TRUE)
#--------
#xlsx_new_clean = read_excel(xlsx_new, sheet = working_sheet)
#addWorksheet(wb, paste("CLEAN NAMES"))
#Excel_file_clean = Excel_file
#writeData(wb,paste("CLEAN NAMES"), Excel_file_clean)
saveWorkbook(wb,xlsx_new,overwrite = TRUE)
print(paste("Excel saved", sep=" "))
ECHO is off.
