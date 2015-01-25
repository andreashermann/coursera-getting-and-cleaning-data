## This R script executes the analysis as described in the README.md file.
## The file CodeBook.md describes the structure and content of the resulting data set.

## download the data set
if (!file.exists("UCI HAR Dataset")) {
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
              "HAR Dataset.zip", method="curl")
  unzip("HAR Dataset.zip")
}

## 1. Merges the training and the test sets to create one data set.
activity.train <- read.table("UCI HAR Dataset//train/Y_train.txt", 
                           colClasses = c("character"), 
                           col.names=c("activity"))
activity.test <- read.table("UCI HAR Dataset//test/y_test.txt", 
                             colClasses = c("character"), 
                             col.names=c("activity"))
activity <- rbind(activity.train,activity.test)

subject.train <- read.table("UCI HAR Dataset//train/subject_train.txt", 
                            colClasses = c("factor"),
                            col.names=c("subject"))
subject.test <- read.table("UCI HAR Dataset//test//subject_test.txt", 
                            colClasses = c("factor"),
                            col.names=c("subject"))
subject <- rbind(subject.train,subject.test)

features <- read.table("UCI HAR Dataset//features.txt",
                       col.names=c("index","label"),
                       stringsAsFactors=F)
features$label <- gsub("()-","",features$label,fixed = T)
dataset.train <- read.table("UCI HAR Dataset//train/X_train.txt",col.names = features$label)
dataset.test <- read.table("UCI HAR Dataset//test//X_test.txt",col.names = features$label)
dataset <- rbind(dataset.train,dataset.test)

combined.data <- cbind(dataset,subject,activity)


## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
used.features <- features[grepl("mean",features$label,fixed=T) | 
                            grepl("std", features$label,fixed=T),"index"]
extracted.data <- combined.data[,used.features]
extracted.data$subject <- combined.data[,"subject"]
extracted.data$activity <- combined.data[,"activity"]

## 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table("UCI HAR Dataset//activity_labels.txt",
                              colClasses = c("NULL","character"),
                              col.names=c("index","label"))$label
levels(extracted.data$activity) <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS",
                                     "SITTING","STANDING","LAYING")

## 4. Appropriately labels the data set with descriptive variable names.
## already done in step one

## 5. From the data set in step 4, creates a second, 
## independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
data.melt <- melt(extracted.data, id=c("subject","activity"))
tidy.data <- dcast(data.melt, subject + activity ~ variable, mean)
write.table(tidy.data, "tidy.data.txt", row.name=FALSE)
