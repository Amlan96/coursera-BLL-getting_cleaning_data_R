library(reshape2)
# Downloading the file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip ", "data.zip", method="curl")
#extract
unzip("data.zip") 

# Getting activity labels + feature_list
activity_label<-read.table("UCI HAR Dataset/activity_labels.txt")
activity_label[,2]<-as.character(activity_label[,2])
feature_list<-read.table("UCI HAR Dataset/features.txt")
feature_list[,2]<-as.character(feature_list[,2])

# Extract only the data on mean and standard deviation
features_required<-grep(".*mean.*|.*std.*", feature_list[,2])
features_required.names<-feature_list[features_required,2]
features_required.names=gsub('-mean', 'Mean', features_required.names)
features_required.names=gsub('-std', 'Std', features_required.names)
features_required.names<-gsub('[-()]', '', features_required.names)


## Load the datasets

#training datasets
training_data<-read.table("UCI HAR Dataset/train/X_train.txt")[features_required]
training_activity_list<-read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects<-read.table("UCI HAR Dataset/train/subject_train.txt")
training_data<-cbind(train_subjects, training_activity_list, training_data)

#testing datasets
testing_data<-read.table("UCI HAR Dataset/test/X_test.txt")[features_required]
testing_activity_list<-read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects<-read.table("UCI HAR Dataset/test/subject_test.txt")
testing_data<-cbind(test_subjects, testing_activity_list, testing_data)

# combining datasets and labelling them
final_dataset <- rbind(training_data, testing_data)
colnames(final_dataset) <- c("subject", "activity", features_required.names)

# making factors out of activities and subjects
final_dataset$activity <- factor(final_dataset$activity, levels = activity_label[,1], labels = activity_label[,2])
final_dataset$subject <- as.factor(final_dataset$subject)

final_dataset.melted <- melt(final_dataset, id = c("subject", "activity"))
final_dataset.mean <- dcast(final_dataset.melted, subject + activity ~ variable, mean)

write.table(final_dataset.mean, "final_data.txt", row.names = FALSE, quote = FALSE)
