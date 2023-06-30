#debug settings, use --FALSE-- value when running in RStudio

OS_environment = TRUE  #<-------EDIT HERE TO DEBUG MODE


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
    "yaml"      #для импорта настроек
  )
  install.packages(setdiff(packages, rownames(installed.packages())), repos = "http://cran.us.r-project.org")
  #remove.packages(packages)
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

rm_Target= config$nist_cleaner$remove_Target
rm_Orthogonal= config$nist_cleaner$remove_Orthogonal
rm_Recursion= config$nist_cleaner$remove_Recursion
rm_Rejceted= config$nist_cleaner$remove_rejceted
#search_algorithm= config$nist_cleaner$search_algorithm


#-----------------------работаю с файлами картинок
#файлы approved

dir=choose.files(caption= "Select NIST file")
if (length(dir) == 0 || !tools::file_ext(dir) =="txt") {
  stop("No file selected or wrong file type")
}

#dir = choose.dir(default = "", caption = "Select Output RDA folder")
lst_files = list.files(path=dirname(dir), pattern="\\.png$", all.files=FALSE, full.names=FALSE)

#файлы rejected
dir_rejected = file.path(dirname(dir), "Rejected", fsep="\\")
lst_files_rejected = list.files(path=dir_rejected, pattern="\\.png$", all.files=FALSE, full.names=FALSE)

#получаю расширение файла .png
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

remove_extension= function (lst) { #удаляю расширение из имени файла
  lapply(lst, function(x) {
  x <- substring(x, 1, nchar(x)-4) # remove the last 8 characters
  if (substr(x, nchar(x), nchar(x)) == "_") {
    x <- substring(x, 1, nchar(x)-1) # remove the trailing underscore
  }
  return(x)
  })
}
lst_files_clear= remove_extension(lst_files)
lst_files_clear <- gsub("[(_)-]", " ", lst_files_clear) #удаляю лишние знаки
lst_files_clear <- gsub("\\s+", " ", lst_files_clear) #удаляю лишние пробелы
print("Found metabolites to keep: ")
print(lst_files_clear)

lst_files_rejected= remove_extension(lst_files_rejected)
lst_files_rejected <- gsub("[(_)-]", " ", lst_files_rejected) #удаляю лишние знаки
lst_files_rejected <- gsub("\\s+", " ", lst_files_rejected) #удаляю лишние пробелы
print("Found metabolites to reject: ")
print(lst_files_rejected)
#-----------------конец

# проверяю если файл CLEAN существует
file_name <- paste(tools::file_path_sans_ext(basename(dir)),"_CLEAN", sep="")
if (file.exists(paste(dirname(dir), "/", file_name, ".txt", sep=""))) {
  # File exists, add a number to the end of the file name
  file_number <- 1
  repeat {
    file_name <- paste(gsub("\\.txt$", "", file_name), "_", file_number, ".txt", sep="")
    if (!file.exists(file_name))
      break
    file_number <- file_number + 1
  }
} else {file_name= paste(file_name, ".txt", sep="")}





#---------------Основные функции
text <- readLines(paste(dir,sep=""))
total_count_name <- length(grep("Name:", text))
#aim= "Target"
remover_func= function(aim) {
  fun_aim= paste("  ", aim," ", sep="")
  count_target_init <- length(grep(fun_aim, text))
  count_target <- length(grep(fun_aim, text))
  count_name <- length(grep("Name:", text))
  print(paste("-------------"))
  print(paste("Found to remove ", aim, ": ",count_target))
  i=1
  pb <- txtProgressBar(min = 0, max = count_target, style = 3) #progressbar
  progress <- 0 #progressbar
  
  while (count_target!=0) {
    pattern <- paste0(aim, "(..)$") #проверяю если 2 символа следуют после aim
    if (any(grepl(fun_aim, text[i])) & grepl(pattern, text[i])) { 
      start_row= i
      text <- text[-i]
      condition_met= FALSE
      while(!condition_met) {
        #print(text[i])
        text <- text[-i]
        if (any(grepl("^\\s{2}$", text[c(i)]))==TRUE & any(grepl("Name:", text[c(i+1)]))==TRUE & any(grepl("Synon:Retention index:", text[c(i+2)]))==TRUE) {
          condition_met= TRUE
        }
      }
      count_target <- length(grep(fun_aim, text))
      progress <- progress + 1 #progressbar
      setTxtProgressBar(pb, progress) #progressbar
      Sys.sleep(0.5) #progressbar
      #print(paste(count_target))
      #cat(paste(count_target,fun_aim , " remains to remove"))
      #Sys.sleep(.05)
      #cat('\014')
      #count_recursion <- length(grep("   Orthogonal", text))
      #count_orthogonal <- length(grep("   Recursion", text))
      #print(paste(count_target, count_recursion, count_orthogonal, sep= " "))
      i=i
      
      
    } else {i=i+1}
    if (count_target == 0) { #progressbar
      # Close the progress bar
      close(pb)
    }
  }
  #print(count_target)
  return(text)
}
#aim= lst_files_rejected
remove_rejected_func= function(aim) {  #удаляю строки из папки rejected
  i=1
  text_names= NULL
  text_names_index= NULL
  for(i in i:length(text)) {
    if (any(grepl("^\\s{2}$", text[c(i)]))==TRUE & any(grepl("Name:", text[c(i+1)]))==TRUE & any(grepl("Synon:Retention index:", text[c(i+2)]))==TRUE) {
      text_names= c(text_names, text[c(i+1)])
      text_names_index = c(text_names_index, i+1)
    } else {}
  }
  distances <- stringdist::stringdistmatrix(aim, text_names)
  # Find the index of the string with the highest match level
  highest_match_index <- which.min(distances)
  # Get the string with the highest match level
  highest_match_string <- text_names[highest_match_index]
  print(paste(highest_match_string, " --- ", aim, sep=" "))
  i= text_names_index[highest_match_index]
  text <- text[-i]
  condition_met= FALSE
  while(!condition_met) {
    #print(text[i])
    text <- text[-i]
    if (any(grepl("^\\s{2}$", text[c(i)]))==TRUE & any(grepl("Name:", text[c(i+1)]))==TRUE & any(grepl("Synon:Retention index:", text[c(i+2)]))==TRUE) {
      condition_met= TRUE
    }
  }
  
  #print(count_target)
  return(text)
}

#text1=text

#text= text1




#--------главная исполняемая фишка здесь
start_time= Sys.time()
if (rm_Target==1) 
  text= remover_func("Target")
if (rm_Orthogonal==1)
  text= remover_func("Orthogonal")
if (rm_Recursion==1)
  text= remover_func("Recursion")
if (rm_Rejceted==1) {
  i=1
  print(paste("-------------"))
  print("REMOVED REJECTED:")
  timeout_count <- 0
  print(paste("(Input:)  ", " --- ","  (Match:)", sep=" "))
  for (i in i:length(lst_files_rejected)) {
    tryCatch(
      expr= {
        withTimeout({
          text= remove_rejected_func(lst_files_rejected[i]) #метод
        },  timeout = 9.1) #время задержки в секуднах для отработки исключения
      }, 
      TimeoutException = function(ex) {
        timeout_count <<- timeout_count + 1
        cat("Timeout. Skipping.\n")
        }
    )
  }
}
text <- gsub("^\\s{2}$", "", text, perl = TRUE) #удалить лишние пустые строки
#text= gsub("\n{2,}", "\n", text)
writeLines(text, file.path(paste(dirname(dir), "/", file_name, sep=""), fsep="\\"))
end_time =Sys.time()
#--------------
print("")
print(paste("TOTAL REMOVED REJECTED METABOLITES:", i-timeout_count, "of", length(lst_files_rejected), sep=" "))
count_orthogonal <- length(grep("   Orthogonal", text))
count_recursion <- length(grep("   Recursion", text))
count_target <- length(grep("   Target", text))
count_name <- length(grep("Name:", text))
print(" ")
print("In the output NIST file found:")
print(paste("Orthogonal:", count_orthogonal, "   Recursion:", count_recursion, "   Target:", count_target, "   Total Names Left:", count_name, "   Total Names Before:", total_count_name,  sep=""))
print(paste("-------------"))
print(paste("Elapsed Time:", round(as.numeric(gsub("Time difference of ", "", difftime(end_time, start_time, units="secs")/60)), 2), "min"))





