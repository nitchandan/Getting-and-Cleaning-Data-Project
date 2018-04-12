library(reshape2)

filename <- "data.zip"

### Download and unzip the dataset:  ###
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename,mode = 'wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

### Load activity labels & features ###
activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_Labels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresNeed <- grep(".*mean.*|.*std.*", features[,2])
featuresNeed.names <- features[featuresNeed,2]
featuresNeed.names = gsub('-mean', 'Mean', featuresNeed.names)
featuresNeed.names = gsub('-std', 'Std', featuresNeed.names)
featuresNeed.names <- gsub('[-()]', '', featuresNeed.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresNeed]
train_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_Subjects, train_Activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresNeed]
test_Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_Subjects, test_Activities, test)

# merge datasets and add labels
fullData <- rbind(train, test)
colnames(fullData) <- c("subject", "activity", featuresNeed.names)

# turn activities & subjects into factors
fullData$activity <- factor(fullData$activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
fullData$subject <- as.factor(fullData$subject)

fullData.melted <- melt(fullData, id = c("subject", "activity"))
fullData.mean <- dcast(fullData.melted, subject + activity ~ variable, mean)

write.table(fullData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)