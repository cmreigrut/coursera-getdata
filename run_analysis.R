message("Starting analysis")

get_dataset <- function(name, labels) {
	pattern = ".*mean\\(\\)|std\\(\\).*"
	#pattern = "tBodyAcc-mean\\(\\)-.*"

	message(paste("Getting", name, "dataset"))

	message("Reading data")
	message(paste0("./data/UCI HAR Dataset/",name,"/X_",name,".txt"))
	data = read.table(paste0("./data/UCI HAR Dataset/",name,"/X_",name,".txt"),col.names=labels,check.names=FALSE)
	
	message("Reading subjects")
	message(paste0("./data/UCI HAR Dataset/",name,"/subject_",name,".txt"))
	subjects = read.table(paste0("./data/UCI HAR Dataset/",name,"/subject_",name,".txt"),col.names=c("subject"),check.names=FALSE)

	message("Reading activities")
	message(paste0("./data/UCI HAR Dataset/",name,"/y_",name,".txt"))
	activities = read.table(paste0("./data/UCI HAR Dataset/",name,"/y_",name,".txt"),col.names=c("activity"),check.names=FALSE)

	return(cbind(subjects, activities, data[,grep(pattern, labels, perl=TRUE)]))
}

if(!file.exists("./data")) {
    message("Creating data directory")
    dir.create("./data")
}

if (!file.exists("./data/dataset.zip")) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    message("Downloading dataset")
    download.file(fileUrl, destfile="./data/dataset.zip")
}
 
if (!file.exists("./data/UCI HAR Dataset")) {
    message("Unzipping dataset")
    unzip("./data/dataset.zip", exdir="./data")
}


features = read.table("./data/UCI HAR Dataset/features.txt", col.names=c("feature","feature_label"))
activity_labels = read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names=c("activity","activity_label"))

train = get_dataset("train", features$feature_label)
test = get_dataset("test", features$feature_label)
total = rbind(train, test)
total = aggregate(total, by=list(total$subject,total$activity), FUN=mean)
total = merge(activity_labels, total, by.x="activity", by.y="activity")
total = total[-c(3:4)]

write.table(total, file="./analysis.txt",row.names=FALSE)

message("Finished")