# Source of data for this project: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# First step is to download zip file and put in data folder

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Go ahead and unzip the file

unzip(zipfile="./data/Dataset.zip",exdir="./data")

# all unzipped files get placed in folder UCI HAR Dataset. Get the list of all files

path <- file.path("./data" , "UCI HAR Dataset")
all_files<-list.files(path, recursive=TRUE)
all_files

# Below R script meets project steps and does the following:

##################################

# 1. Merges the training and the test sets to create one data set.

# Track and read the activity files

v_ActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
v_ActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

# Track and read the subject files

v_SubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
v_SubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

# Track and read features files

v_FeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
v_FeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

## 1.1.Next step is to concatenate activity, subject and feature data tables by rows

v_Subject <- rbind(v_SubjectTrain, v_SubjectTest)
v_Activity<- rbind(v_ActivityTrain, v_ActivityTest)
v_Features<- rbind(v_FeaturesTrain, v_FeaturesTest)

## 1.2.Assign names to concatenated variables

names(v_Subject)<-c("subject")
names(v_Activity)<- c("activity")
v_FeatureNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(v_Features)<- v_FeatureNames$V2

## 1.3. Capture data frame for all data by merging columns

v_Combine <- cbind(v_Subject, v_Activity)
v_Data <- cbind(v_Features, v_Combine)

##################################

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

## 2.1.Capture name of subset of Features by measuring mean and standard deviation

SubFeatureNames<-v_FeatureNames$V2[grep("mean\\(\\)|std\\(\\)", v_FeatureNames$V2)]

## 2.2. Gather subset the data by seleted names of Features
selectedNames<-c(as.character(SubFeatureNames), "subject", "activity" )
v_Data<-subset(v_Data,select=selectedNames)

##################################


# 3. Uses descriptive activity names to name the activities in the data set.

activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
activityLabels[, 2] = gsub("_", "", tolower(as.character(activityLabels[, 2])))
v_Activity[,1] = activityLabels[v_Activity[,1], 2]
names(v_Activity) <- "activity"


##################################

# 4. Appropriately labels the data set with descriptive activity names.

names(v_Data)<-gsub("^t", "time", names(v_Data))
names(v_Data)<-gsub("^f", "frequency", names(v_Data))
names(v_Data)<-gsub("Acc", "Accelerometer", names(v_Data))
names(v_Data)<-gsub("Gyro", "Gyroscope", names(v_Data))
names(v_Data)<-gsub("Mag", "Magnitude", names(v_Data))
names(v_Data)<-gsub("BodyBody", "Body", names(v_Data))


##################################

# 5. Creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
v_Data2<-aggregate(. ~subject + activity, v_Data, mean)
v_Data2<-v_Data2[order(v_Data2$subject,v_Data2$activity),]
write.table(v_Data2, file = "tidydata.txt",row.name=FALSE)

##################################
