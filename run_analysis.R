run_analysis <- function () {
  # Coursera - Getting and Cleaning Data
  # @author Wojciech Malinowski
  
  # This function checks for data file in the working directory, if it's not found it downloads the dataset from 
  # predefined url: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
  # extracts the file to a temporary file and reads the data from training and testing datasets.
  # After extraction the temporary files are unlinked and the datasets are combined.
  #   Important! Only the measurements on the mean and standard deviation are preserved in the results.
  # After the data is merged it is given appropriate names from activity labels file.
  
  # check if data file exists
  if(!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")) {
    # download the dataset
    url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    temp <- tempfile()
    download.file(url, temp, mode ='wb') 
    # extract files
    zipdir <- tempfile()
    dir.create(zipdir)
    unzip(temp, exdir = zipdir)
  } else {
    # extract files
    zipdir <- tempfile()
    dir.create(zipdir)
    unzip("getdata-projectfiles-UCI HAR Dataset.zip", exdir = zipdir)
  }
   
  # load files into variables
  labels <- read.table(paste(zipdir, "\\UCI HAR Dataset\\activity_labels.txt", sep = "" ))
  features <- read.table(paste(zipdir, "\\UCI HAR Dataset\\features.txt", sep = "" ))
  
  x.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\X_train.txt", sep = "" ))
  y.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\y_train.txt", sep = "" ))
  subject.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\subject_train.txt", sep = "" ))
  
  x.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\X_test.txt", sep = "" ))
  y.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\y_test.txt", sep = "" ))
  subject.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\subject_test.txt", sep = "" ))
  
  # close temporary files
  if(exists("temp"))
    unlink(temp)
  unlink(zipdir)
  
  # merge training and test data
  x <- rbind(x.train, x.test)
  y <- rbind(y.train, y.test)
  subject <- rbind(subject.train, subject.test)
  
  # unlink unnecessary variables for slower machines
  rm(x.test);  rm(y.test); rm(subject.test); rm(x.train); rm(y.train); rm(subject.train);
  
  # naming the columns in datasets
  colnames(x) <- features[,2]
  colnames(y) <- "Activity"
  colnames(subject) <- "Subject"
  
  # removes unnecessary measurements
  x = x[, grep("mean|std", colnames(x))]
  
  # changes numerical into descriptive data
  y$Activity <- factor(y$Activity, labels = labels[,2])
  
  # binds data into one variable
  x <- cbind(subject, y, x)
  
  # unlink unnecessary variables for slower machines
  rm(y);  rm(subject);
  
  # fixing names in the dataset, use PascalCase notation
  colnames(x) <- gsub("\\(\\)", "", colnames(x))
  colnames(x) <- gsub("Freq", "Frequency", colnames(x))
  colnames(x) <- gsub("Acc", "Acceleration", colnames(x))
  colnames(x) <- gsub("Mag", "Magnitude", colnames(x))
  colnames(x) <- gsub("Gyro", "Gyroscope", colnames(x))
  colnames(x) <- gsub("^t", "Time", colnames(x))
  colnames(x) <- gsub("^f", "Frequency", colnames(x))
  
  # creates result tidy data set with avarage over each subject and activity
  result <- aggregate(x[,3:81], list(Subject = x[,1], Activity = x[,2]), mean)
  write.table(result, file = "result.txt")
}