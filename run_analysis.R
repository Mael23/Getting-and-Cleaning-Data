# Install required packages
if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("reshape2")) {
        install.packages("reshape2")
}

if (!require("dplyr")) {
        install.packages("dplyr")
}

# Load packages: "data.table" "reshape2" "dplyr"
require("data.table")
require("reshape2")
require("dplyr")

# Set Working Directory
setwd("C:/Users/Mark/Desktop/CourseraR2")

# Set URL and File Name
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- file.path(getwd(), "Dataset.zip")

# Download data file
download.file(url, f)

# Unzip file and saves to working directory
unzip("Dataset.zip") 

# Load Activity labels
activeLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activeLabels[,2] <- as.character(activeLabels[,2])

# Load column names (features)
features <- read.table("./UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only Mean and Std data & eliminate unwanted chars
featuresFiltered <- grep(".*mean.*|.*std.*", features[,2])
featuresFiltered.names <- features[featuresFiltered, 2]
featuresFiltered.names <- gsub('-mean', 'Mean', featuresFiltered.names)
featuresFiltered.names <- gsub('std', 'Std', featuresFiltered.names)
featuresFiltered.names <- gsub('[-()]', '', featuresFiltered.names)

# Load Test dataset
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt") [featuresFiltered]
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
sub_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testData <- cbind.data.frame(sub_test, y_test, x_test)

# Load Train dataset
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt") [featuresFiltered]
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
sub_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(sub_train, y_train, x_train)

# Merge TEST & TRAIN to create single dataset & add labels
allData <- rbind(testData, trainData)
colnames(allData) <- c("subject", "activity", featuresFiltered.names)

# Change class for Activities & Subjects
allData$activity <- factor(allData$activity, levels = activeLabels[,1], 
           labels = activeLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# Write tidy data set with descriptive activity
write.table(allData.mean, file = "./tidydata.txt", row.names = FALSE, 
            quote = FALSE)