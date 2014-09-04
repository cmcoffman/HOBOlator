HOBOlator
=========
Say you operate several growth chambers or incubators and while they have their own thermostats and humidistats, you monitor the chambers with "HOBO" (Onset Computer Corp.) data loggers.

By exporting the HOBO logger data as .csv files, you can run these scripts on these files and it will suggest calibration offsets for your growth chambers based on the HOBO data.

The hobo_analysis_and_offset_calculation.R file is all the scripts combined into one. Running it in a folder containing all the csv files will output a table indicating what the needed chamber offsets are.
