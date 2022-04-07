# Metabolites Cleaner 
![](https://img.shields.io/badge/-made%20with%20R-blue) [![Windows](https://svgshare.com/i/ZhY.svg)](https://svgshare.com/i/ZhY.svg)

Reject unwanted metabolites from the Excel workbook `RDA_Target_Data_Model.xlsx` in worksheet `Integrated Unimodal 1`. Clean metabolites names xlsx table. Carry out table with rejected metabolites.  

## How to use?
1. To sort png files easier they should be sorted by its chemical name. In [Total Commander](https://www.ghisler.com) use group rename all of png files with the regex function `[N6-]_[N1,4]`. You need to put to the end of the png file code of library `X021`, if such exists in the file name. Also remove all unwanted characters that block beginning of the chemical name. For Example: `X021_RIBOSE_MEOX_4TMS___1.png` -> `RIBOSE_MEOX_4TMS___1_X021.png`
2. Navigate through the png files repository of the metabolites peaks. 
3. All discarded png files move to `Rejected` folder in the root of the png files repository.  
4. `Metabolites Cleaner` by default uses `RDA_Target_Data_Model.xlsx` and worksheet `Integrated Unimodal 1`. You can modify it in `Metabolites Cleaner.R` file following variablses:
```
working_xlsx_workbook = "RDA_Target_Data_Model"
working_sheet = "Integrated Unimodal 1"
```
5. Run entire code
6. Select input folder with png files.
7. Done
## How it works?
1. `Metabolites Cleaner` creates `RDA_Target_Data_Model_CLEAN.xlsx` file that is a duplicate file `RDA_Target_Data_Model.xlsx`.
2. In the `RDA_Target_Data_Model_CLEAN.xlsx` worksheet `Integrated Unimodal 1` moves all columns of metabolites that found  in `Rejected` folder to `Rejected` worksheet.
3. Duplicates worksheet clean `Integrated Unimodal 1` and names it `CLEAN NAMES`.
4. Worksheet `CLEAN NAMES` cleans all head names of columns with metabolites. 
#### How it cleans metabolites names? 
1. Removes code of the library: `S227_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2` -> `_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2`.
2. Removes `nTMS`, where `n` is `n` character and digit and characters followed after `nTMS`: `_GLUCOSE_6_PHOSPHATE_MEOX_6TMS_minor___2` -> `_GLUCOSE_6_PHOSPHATE_MEOX_`.
3. Removes `MEOX` and characters followed after `MEOX`: `_GLUCOSE_6_PHOSPHATE_MEOX_` -> `_GLUCOSE_6_PHOSPHATE_`.
4. Removes unwanted spaces and `-` (dash symbols): `_GLUCOSE_6_PHOSPHATE_` -> `GLUCOSE 6 PHOSPHATE`.

**Metabolites Cleaner** requires listed below open source [CRAN](https://cran.r-project.org) packages: 
```
dplyr 
readxl 
rio
openxlsx
```  