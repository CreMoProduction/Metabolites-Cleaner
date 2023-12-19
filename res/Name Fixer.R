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
    "progress",
    "R.utils",  #пакет для отработки исключения в случе ошибки в цикле для проуска итерации
    "stringdist", #ищу совпадения в строках
    "yaml",      #для импорта настроек
    "stringr",
    "tools"     #получаю расширение файла
  )
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")
  #remove.packages(packages)
  #-----------
  lapply(packages, require, character.only = TRUE)
}
package()
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
working_sheet= config$name_fixer$xlsx_sheet
#-----------------
#открываю excel файл
dir=choose.files( caption= "Select Excel File", multi = FALSE)
# Check if a file was selected
if (length(dir) == 0 || substr(dir, nchar(dir) - 3, nchar(dir)) !="xlsx") {
  stop("No file selected or wrong file type")
}
Excel_file = read_excel(dir, sheet = working_sheet)
Excel_file_clean = Excel_file
#первая буква заглавная
caprialzied_first_character = function(x){
  paste(toupper(substring(x, 1, 1)),
        tolower(substring(x, 2, nchar(x))),
        sep = "")
}
remove_index= function(str) { #удаляю индекс 
  first_space_position <- regexpr(" ", str)
  if (first_space_position > 1) {
    first_character <- substr(str, 1, 1)
    preceding_characters <- substr(str, 2, first_space_position - 1)
    if (grepl("^[A-Za-z]$", first_character) && grepl("^[0-9]+$", preceding_characters)) {
      # First character is a letter and preceding characters before the first space are digits
      # Your desired actions here
      if (first_space_position > 0) {
        str <- substr(str, first_space_position + 1, nchar(str))
      }
    } 
  } 
  return(str)
}
#чистка строки от мусора

for (i in 3:ncol(Excel_file_clean)) {
  str = names(Excel_file_clean[,i])
  tms = unlist(gregexpr(pattern ='TMS',str))
  if (tms!=-1) {
    str = substr(str, 1, tms-3)
  }
  mz = unlist(gregexpr(pattern ='Mz',str))
  if (mz!=-1) {
    str = substr(str, 1, mz-3)
  }
  Mz = unlist(gregexpr(pattern ='M/z',str))
  if (Mz!=-1) {
    str = substr(str, 1, Mz-3)
  }
  meox = unlist(gregexpr(pattern ='MEOX',str))
  if (meox!=-1) {
    str = substr(str, 1, meox-2)
  }
  # if (grepl("^[A-Za-z]", substr(str, 1, 1)) && grepl("^[0-9]", substr(str, 2, 2))) { #удаляю индекс 
  #   str = substring(str, which(str == " ")[1])
  # }
  str=remove_index(str) #удаляю индекс 
  if (substr(str,1,1)==" ") {
    str = trimws(str)
  }
  if (substr(str,nchar(str),nchar(str))=="-") {
    str = substr(str,1,nchar(str)-1)
  }
  if (substr(str,nchar(str),nchar(str))=="1" | substr(str,nchar(str),nchar(str))=="2") {
    str = substr(str, 1, nchar(str)-2)
  }
  str=caprialzied_first_character(str)#первая буква заглавная
  str = trimws(str)
  if(str=="") {
    str= names(Excel_file_clean[,i])
  }
  print(str)
  names(Excel_file_clean)[i] = str
}
#удаляю лист из эксель, если он существует
wb <- loadWorkbook(file = dir)
if ("FIXED NAMES" %in% getSheetNames(dir)) {
  removeWorksheet(wb, sheet = "FIXED NAMES")
  saveWorkbook(wb, dir, overwrite = TRUE)
}
addWorksheet(wb, paste("FIXED NAMES"))
writeData(wb,paste("FIXED NAMES"), Excel_file_clean)
saveWorkbook(wb,dir,overwrite = TRUE)
print(paste("------------", sep=" "))
print(paste("Excel saved", sep=" "))
print(paste("Find sheet 'FIXED NAMES' in an excel file you imported", sep=" "))
