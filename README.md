---
title: "README"
author: "Maria Stoica"
date: "Friday, June 19, 2015"
output: html_document
---

# README

## Overview

The files provided are

- run_analysis.R : the script that processes the data set and produces a tidy data set
- README.md : this overview of the processing performed by run_analysis.R
- CodeBook.txt : A file describing the variables in the tidy data set
- UCI HAR averages tidy.txt : The final data set after analysis with run_analysis.R

To generate the tidy data set, simply run the run_analysis.R script by sourcing it at the R prompt. The UCI HAR dataset folder should be in your owrking directory. If the folder is zipped, please uncomment the first line to unzip the folder before performing the analysis.

## Description of run_analysis.R

### Reading in and cleaning the data.

This analysis reads in the computed features (not the raw data) from X_test.txt and X_train.txt. It assigns these features the names in features.txt. It also reads in the corresponding Subject ID and Activity for each observation in both data sets, and binds the information by columns int a test and a train data set. It then binds the test and train data together by rows to result in 10299 observations of 561 features. The activity number (1-6) is converted to a factor with associated labels ("WALKING", "LAYING", etc) as indicated in activity_labels.txt.

### Processing the data

The columns with the string "mean()" or "std()" (66 features total) are extracted and grouped by an interaction factor of unique Subject ID-Activity pairs (30 Subjects x 6 activities = 180 unique pairs). For each feature, the average is taken by Subject ID-Activity pair factor. A new data frame is constructed with 180 observations (one for each Subject ID-Activity pair) and 68 variables (Subject ID, Activity, average of the 66 mean and std features by ID-Activity pair). The resulting data frame is stored with write.table() and row.names=F in the file "UCI HAR averages tidy.txt". 