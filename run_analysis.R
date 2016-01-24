### The script below should enable one to pull data collected from Samsung Galaxy S smartphones and create a tidy dataset from it. 

## Download the files and save them to a directory
    if(!file.exists("./datacleaningassignment")){dir.create("./datacleaningassignment")}
    fileUrl1 = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl1, destfile = "./datacleaningassignment/UCI.zip", mode="wb")

##Unzip the files 
    unzip("./datacleaningassignment/UCI.zip", exdir= "./datacleaningassignment")

##Load the dplyr library 
    library(dplyr, data.table)

## Read in X_training file and label the columns with the appropriate feature descriptions
    xtrain<- read.table("./datacleaningassignment/UCI HAR Dataset/train/X_train.txt")
    features <- read.table("./datacleaningassignment/UCI HAR Dataset/features.txt")
    featurenames <- as.vector(features[,2])
    colnames(xtrain)<- featurenames

##Remove the columns from xtrain that are not the mean and standard deviation of each measurement
    xtraincols <- xtrain[,grepl("mean", colnames(xtrain))]
    xtraincols2 <-xtrain[,grepl("std", colnames(xtrain))]
    xtrainms<-cbind(xtraincols, xtraincols2)    
        
##Read in the associated activity numbers and relabel the column name  
    xtranames<-read.table("./datacleaningassignment/UCI HAR Dataset/train/y_train.txt", col.names="Activity.Number")

##Read in the associated subject ID and relabel the column names    
    xtrasubject<-read.table("./datacleaningassignment/UCI HAR Dataset/train/subject_train.txt", col.names="Subject")    

## Combine the xtrainms, xtranames and xtrasubject tables 
    xnamedtrain<- cbind(xtranames, xtrasubject, xtrainms)            

## Read in activity labels
    labels<-read.table("./datacleaningassignment/UCI HAR Dataset/activity_labels.txt", col.names=c("Activity.Number","Activity"))

## Merge activity labels with xnamedtest 
    xlabeledtrain<-merge(xnamedtrain, labels, by.x = "Activity.Number", by.y = "Activity.Number", all.x = TRUE)    

## Add "train" labels to xlabeledtrain
    xlabeledtrain <-mutate(xlabeledtrain, DataSet = "Train")    
       
###Repeat steps for the test data 
    
## Read in X_test file and label the columns with the appropriate feature descriptions
    xtest<- read.table("./datacleaningassignment/UCI HAR Dataset/test/X_test.txt")
    colnames(xtest)<- featurenames
    
##Remove the columns from xtest that are not the mean and standard deviation of each measurement
    xtestcols <- xtest[,grepl("mean", colnames(xtest))]
    xtestcols2 <-xtest[,grepl("std", colnames(xtest))]
    xtestms<-cbind(xtestcols, xtestcols2)
    
##Read in the associated activity numbers and relabel the column name  
    xnames<-read.table("./datacleaningassignment/UCI HAR Dataset/test/y_test.txt", col.names="Activity.Number")
    
##Read in the associated subject ID and relabel the column names    
    xsubject<-read.table("./datacleaningassignment/UCI HAR Dataset/test/subject_test.txt", col.names="Subject")
    
## Combine the xtestms, xnames and xsubject tables 
    xnamedtest<- cbind(xnames, xsubject, xtestms)
    
## Merge activity labels with xnamedtest 
    xlabeledtest<-merge(xnamedtest, labels, by.x = "Activity.Number", by.y = "Activity.Number", all.x = TRUE)

## Add "test" labels to xlabeledtest
    xlabeledtest <-mutate(xlabeledtest, DataSet = "Test")

### Combine the training and test data sets together. 
    combineddata<- rbind(xlabeledtrain, xlabeledtest)
    combineddata<- as.data.table(combineddata)

##  Remove the DataSet, Activity.Number and meanFreq
    combineddata <- select(combineddata, -contains ("Freq"))
    combineddata <- select(combineddata, -DataSet, -Activity.Number)
   
### Take the mean of each measurement, sorted by subject, activity and dataset type  
    ID <- c("Subject", "Activity")
    setkeyv(combineddata, ID)
    tidydata <- combineddata[, lapply(.SD,mean), by = key(combineddata)]
    write.table(tidydata, file = "RGtidydata.txt", row.names=FALSE)
