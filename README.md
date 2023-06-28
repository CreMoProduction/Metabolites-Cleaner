


```
  __  __      _        _           _ _ _               _____ _                            
 |  \/  |    | |      | |         | (_) |             / ____| |                           
 | \  / | ___| |_ __ _| |__   ___ | |_| |_ ___  ___  | |    | | ___  __ _ _ __   ___ _ __ 
 | |\/| |/ _ \ __/ _` | '_ \ / _ \| | | __/ _ \/ __| | |    | |/ _ \/ _` | '_ \ / _ \ '__|
 | |  | |  __/ || (_| | |_) | (_) | | | ||  __/\__ \ | |____| |  __/ (_| | | | |  __/ |   
 |_|  |_|\___|\__\__,_|_.__/ \___/|_|_|\__\___||___/  \_____|_|\___|\__,_|_| |_|\___|_|   
```

# Metabolites Cleaner

**Metabolites Cleaner** is a tool to tidy up compounds list to simplify further metabolomics analysis

### [NIST Cleaner](#nist)
Removes `Targert` and `Orthogonal` as well as removes metabolites found in the folder `Rejected` from the NIST.txt file. Provides detailed info of the processing done. 

### [Excel Cleaner](##-how-to-use-excel-cleaner?) 
Reject unwanted metabolites from the Excel workbook. Creates a worksheet with rejected metabolites. 

### [Name Fixer](##-how-to-use-name-fixer?)
Cleans metabolite names in the excel table.  



------ 
<img src= "https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white"/><img src= "https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue"/><img src= "https://img.shields.io/badge/windows%20terminal-4D4D4D?style=for-the-badge&logo=windows%20terminal&logoColor=white"/>

------ 
# How to run?
1. Compatible with Windows command prompt. Just double click `Metabolites Cleaner.bat` to run.
2. It automatically checks if R is installed and finds correct path to it. If not R found then it downloads and installs one. 

**Note!** By default it requires installed R in `C'\Program Files\R...` directory.

3. It automatically downloads and installs all required R packages.
4. Select an option to run

**Note!** Make sure Metabolites Cleaner folder and working folder with input files are in folders named with no special characters and spaces. Avoid use spaces. Use `_` (underline) instead. 


------
<a id="nist"></a>
## How to use NIST Cleaner?
1. Navigate to the png files repository of the metabolites peaks. 
2. Create `Rejected` folder in the root of the png files repository.  
3. All png files you want to discard move to `Rejected` folder. 
4. Select `RDA_Target_NIST.txt` file.
5. By default it removes `Targert`, `Orthogonal` and entries found in `Rejected` folder. Modify `config.yml`. To activate function set 1 to a property, to deactivate set 0.
```
remove_Target: 1
remove_Orthogonal: 1
remove_Recursion: 0
remove_rejceted: 1
```	

### How NIST Cleaner work?
1. Creates `RDA_Target_NIST_CLEAN.txt` file in the root folder.
2. Removes selected entry types.
3. Finds matches of the png names in the `Rejected` folder in the NIST file and removes such entries.
4. Finds exceptions and ignores errors so it will ends properly. 
5. Provides detailed info about the processions was done.  


------ 
## How to use Excel Cleaner?
1. Navigate to the png files repository of the metabolites peaks. 
2. Create `Rejected` folder (if such does not exist) in the root folder.  
3. All png files you want ot discard move to `Rejected` folder.  
4. Select excel file. 
`Excel Cleaner` by default uses worksheet `Integrated Unimodal 1`. You can modify it in `config.yml` file following variable:
```
xlsx_sheet: Integrated Unimodal 1
```
5. In `config.yml` select search algorithm to use, where search by index set 0, search by name set 1:
```
search_algorithm: 1
```  
6. Select input file with pop up window.

### How Excel Cleaner work?
1. `Metabolites Cleaner` creates `RDA_Target_Data_Model_CLEAN.xlsx` file that is a duplicate file `RDA_Target_Data_Model.xlsx`.
2. In the `RDA_Target_Data_Model_CLEAN.xlsx` worksheet `Integrated Unimodal 1` moves all columns of metabolites that found  in `Rejected` folder to `Rejected` worksheet.
3. Duplicates worksheet clean `Integrated Unimodal 1` and names it `CLEAN NAMES`.
4. Worksheet `CLEAN NAMES` cleans all head names of columns with metabolites. 


------ 
## How to use Name Fixer?
1. Select excel file to fix component names. 
2. Done.
By default it uses worksheet `Integrated Unimodal 1`. You can modify it in `config.yml` file following variable:
```
xlsx_sheet: Integrated Unimodal 1
```

### How Name Fixer work? 
1. Removes index if such exists: `S227_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2` -> `_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2`.
2. Removes `nTMS`, where `n` is `n` character and digit and characters followed after `nTMS`: `_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2` -> `_GLUCOSE_6_PHOSPHATE_MEOX_`.
3. Removes `MEOX` and characters followed after `MEOX`: `_GLUCOSE_6_PHOSPHATE_MEOX_` -> `_GLUCOSE_6_PHOSPHATE_`.
4. Removes unwanted characters such as spaces and underlines: `_GLUCOSE_6_PHOSPHATE_` -> `GLUCOSE 6 PHOSPHATE`.
5. Replaces uppercase to lowercase: `GLUCOSE 6 PHOSPHATE` -> `Glucose 6 phosphate`.
------


 

**Metabolites Cleaner** tool requires listed below open source [CRAN](https://cran.r-project.org) packages: 
```
dplyr
readxl
yaml
rio
openxlsx
progress
R.utils
stringdist
yaml
stringr
``` 
