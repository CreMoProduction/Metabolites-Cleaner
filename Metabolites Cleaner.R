packages <- c(
              "dplyr", 
              "readxl", 
              "rio",       #экспорт xlsx файл
              "openxlsx"
)
install.packages(setdiff(packages, rownames(installed.packages())))
#-----------
lapply(packages, require, character.only = TRUE)
#----------------

#--------------
working_xlsx_workbook = "RDA_Target_Data_Model"
working_sheet = "Integrated Unimodal 1"
#--------------

#файлы approved
dir = choose.dir(default = "", caption = "Select folder")
lst_files = list.files(path=dir, pattern=NULL, all.files=FALSE, full.names=FALSE)

#файлы rejected
dir_rejected = file.path(dir, "Rejected", fsep="\\")
lst_files_rejected = list.files(path=dir_rejected, pattern=NULL, all.files=FALSE, full.names=FALSE)

#получаю расширение файла .png
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#создаю список только с названиями .png
lst_files_png = c()
for (i in 1:length(lst_files)) {
  if (grepl(substrRight(lst_files[i], 4), ".png")== TRUE) {
    print(lst_files[i])
    lst_files_png = append(lst_files_png, lst_files[i])
  } 
}



#создаю дубликат xlsx
xlsx = file.path(dir, paste(working_xlsx_workbook, ".xlsx", sep=""), fsep="\\")
xlsx_new = file.path(dir, paste(working_xlsx_workbook, "_CLEAN.xlsx", sep= ""), fsep="\\")
file.copy(xlsx, xlsx_new, overwrite = TRUE )
#открываю excel файл
Excel_file = read_excel(xlsx_new, sheet = working_sheet)

#создаю лист Rejected
wb <- loadWorkbook(file = xlsx_new)
addWorksheet(wb, paste("Rejected"))
df_rejected = NULL
df_rejected =  Excel_file[,1:2]
#----------

ncol(Excel_file)

names(Excel_file)[164]



for (k in 1:length(lst_files_rejected)) {
  for (i in 3:ncol(Excel_file)) {
    if (substr(names(Excel_file[,i]), 1, 4)== substr(lst_files_rejected[k], nchar(lst_files_rejected[k])-7,nchar(lst_files_rejected[k])-4)) {
      df_rejected = cbind(df_rejected, Excel_file[,i])
      Excel_file[,i] = NULL
      print(paste("TRUE", i))
      break
    } else {
      i=i+1
    }
  }
}

deleteData(wb,working_sheet, 1:ncol(Excel_file)+length(lst_files_rejected), 1:nrow(Excel_file), gridExpand = TRUE)
saveWorkbook(wb,xlsx_new, overwrite = TRUE)
writeData(wb,working_sheet, Excel_file)
#сохраняю файл с Rejected
writeData(wb,paste("Rejected"), df_rejected)
saveWorkbook(wb,xlsx_new,overwrite = TRUE)
#--------
xlsx_new_clean = read_excel(xlsx_new, sheet = working_sheet)
addWorksheet(wb, paste("CLEAN NAMES"))
Excel_file_clean = Excel_file


colnames(Excel_file)[4] = substring(names(Excel_file[,4]), 6)
colnames(Excel_file)[4] = substr(names(Excel_file[,4]), 1, nchar(names(Excel_file[,4]))-7)
colnames(Excel_file)[4] = gsub("\\-", " ", names(Excel_file[,4]))


str = "S320 MANNOSE-MEOX major 5TMS  1  M/z322"
i=8
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
  if (substr(str,1,1)!="C" && grepl("[^a-zA-Z]", substr(str,1,1))==FALSE && grepl("[^a-zA-Z]", substr(str,2,4))==TRUE) {
    str = substring(str, 6)
  }
  if (substr(str,1,1)==" ") {
    str = trimws(str)
  }
  if (substr(str,nchar(str),nchar(str))=="-") {
    str = substr(str,1,nchar(str)-1)
  }
  if (substr(str,nchar(str),nchar(str))=="1" | substr(str,nchar(str),nchar(str))=="2") {
    str = substr(str, 1, nchar(str)-2)
  }
  str = trimws(str)
  names(Excel_file_clean)[i] = str
}

writeData(wb,paste("CLEAN NAMES"), Excel_file_clean)
saveWorkbook(wb,xlsx_new,overwrite = TRUE)








          