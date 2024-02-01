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
    "progress"
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
rm_Target= config$nist_cleaner$remove_Target
rm_Orthogonal= config$nist_cleaner$remove_Orthogonal
rm_Recursion= config$nist_cleaner$remove_Recursion
rm_Rejceted= config$nist_cleaner$remove_rejceted
#search_algorithm= config$nist_cleaner$search_algorithm
#-----------------------работаю с файлами картинок
#файлы approved
#dir=choose.files(caption= "Select NIST file")
dir=file.choose()
if (length(dir) == 0 || substr(dir, nchar(dir) - 2, nchar(dir)) !="txt") {
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
    if (file.exists(file_name))
      break
    file_number <- file_number + 1
  }
} else {file_name= paste(file_name, ".txt", sep="")}
#---------------Основные функции
text <- readLines(paste(dir,sep=""))
total_count_name <- length(grep("Name:", text))
#============OLD==============
#=============================
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
      while(condition_met) {
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
  while(condition_met) {
    #print(text[i])
    text <- text[-i]
    if (any(grepl("^\\s{2}$", text[c(i)]))==TRUE & any(grepl("Name:", text[c(i+1)]))==TRUE & any(grepl("Synon:Retention index:", text[c(i+2)]))==TRUE) {
      condition_met= TRUE
    }
  }

  #print(count_target)
  return(text)
}
#=============================
#=============================


text_df_maker= function(text) {
  text_df=data.frame(matrix(NA, nrow = 350, ncol = 1))
  text_1 = text
  length(text_1)
  i=1
  start_row=i
  end_row=i+1
  while(length(text_1)!=0) {
    condition_met= TRUE
    while(condition_met) {
      end_row=end_row+1
      if (any(grepl("^\\s{2}$", text_1[c(end_row)]))==TRUE) {
        condition_met= FALSE
      }
      
    }
    text_block= text_1[start_row:end_row]
    text_block= data.frame(Text = text_block, stringsAsFactors = FALSE)
    empty_lines=350 - nrow(text_block)
    empty_lines_df= data.frame(matrix(nrow = empty_lines, ncol = 1))
    colnames(empty_lines_df)[1]= "Text"
    text_block= rbind(text_block, empty_lines_df)
    
    text_1= text_1[-c(start_row:end_row)]
    text_df=cbind(text_df, text_block)
    
    end_row=1
    start_row=1
  }
  colnames(text_df) <- text_df[1,] #first row of the data frame as name of column
  text_df <- text_df[-1,] #first row of the data frame as name of column
  text_df= text_df[,-1]
  #colnames(text_df)
  return(text_df)
}
text_maker= function() {
  # New column names to add
  merged_data= data.frame()
  text_df_1= text_df 
  new_column_names <- c(1:ncol(text_df_1))
  original_column_names= colnames(text_df_1)
  colnames(text_df_1)=new_column_names
  # Add a row below the existing column names with the new names
  text_df_1 <- rbind(original_column_names, text_df_1)
  merged_data <- stack(text_df_1) # Use the stack function to merge all columns into a single column data frame
  merged_data= merged_data[,-2]
  merged_data= merged_data[complete.cases(merged_data)]
  text <- paste(merged_data, collapse = "\n")
  return(text)
}
aim= "Target"
remover_func_v2= function(aim) {
  fun_aim= paste("  ", aim," ", sep="")
  count_target_init <- length(grep(fun_aim, colnames(text_df)))
  count_target <- length(grep(fun_aim, colnames(text_df)))
  count_name <- length(grep("Name:", colnames(text_df)))
  print(paste("-------------"))
  print(paste("Found to remove ", aim, ": ",count_target))
  i=1
  pb <- txtProgressBar(min = 0, max = count_target, style = 3) #progressbar
  progress <- 0 #progressbar
  while (count_target!=0) {
    #pattern <- paste0(aim, "(..)$") #проверяю если 2 символа следуют после aim
    pattern= aim
    #print(paste(count_target, i, sep=" "))
    if (any(grepl(fun_aim, colnames(text_df)[i])) & grepl(pattern, colnames(text_df)[i])) {
      text_df= text_df[,-i]
      i=1
      count_target <- length(grep(fun_aim, colnames(text_df)))
      progress <- progress + 1 #progressbar
      setTxtProgressBar(pb, progress) #progressbar
      Sys.sleep(0.5) #progressbar
    } else {
      if (i<length(colnames(text_df))) {
        i=i+1
      } else {
        i=1  
        count_target= count_target-1 #исключение если count_target никогда не достигнет 0
      }
    }
    if (count_target == 0) { #progressbar
      # Close the progress bar
      close(pb)
    }
  }
  return(text_df)
}
#aim= lst_files_rejected[1]
remove_rejected_func_v2= function(aim) {  #удаляю строки из папки rejected
  distances <- stringdist::stringdistmatrix(aim, colnames(text_df))
  # Find the index of the string with the highest match level
  highest_match_index <- which.min(distances)
  # Get the string with the highest match level
  highest_match_string <- colnames(text_df)[highest_match_index]
  print(paste(highest_match_string, " --- ", aim, sep=" "))
  text_df= text_df[,-highest_match_index]
  return(text_df)
  }






start_time= Sys.time()
text_df= text_df_maker(text)
if (rm_Target==1) 
  text_df=remover_func_v2("Target")
#text= remover_func("Target")
if (rm_Orthogonal==1)
  text_df=remover_func_v2("Orthogonal")
#text= remover_func("Orthogonal")
if (rm_Recursion==1)
  text_df= remover_func_v2("Recursion")
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
          if (length(lst_files_rejected)!=0) {
            text_df= remove_rejected_func_v2(lst_files_rejected[i]) #метод
          }
        },  timeout = 9.1) #время задержки в секуднах для отработки исключения
      }, 
      TimeoutException = function(ex) {
        timeout_count <<- timeout_count + 1
        cat("Timeout. Skipping.\n")
      }
    )
  }
} else {
  i=0 
  timeout_count <- 0
}
text_output=text_maker()
writeLines(text_output, file.path(paste(dirname(dir), "/", file_name, sep=""), fsep="\\"))
end_time =Sys.time()
#--------------
print("")
print(paste("TOTAL REMOVED REJECTED METABOLITES:", i-timeout_count, "of", length(lst_files_rejected), sep=" "))
count_orthogonal <- length(grep("   Orthogonal", colnames(text_df)))
count_recursion <- length(grep("   Recursion", colnames(text_df)))
count_target <- length(grep("   Target", colnames(text_df)))
count_name <- length(grep("Name:", colnames(text_df)))
print(" ")
print("In the output NIST file found:")
print(paste("Orthogonal:", count_orthogonal, "   Recursion:", count_recursion, "   Target:", count_target, "   Total Names Left:", count_name, "   Total Names Before:", total_count_name,  sep=""))
print(paste("-------------"))
print(paste("Elapsed Time:", round(as.numeric(gsub("Time difference of ", "", difftime(end_time, start_time, units="secs")/60)), 2), "min"))




