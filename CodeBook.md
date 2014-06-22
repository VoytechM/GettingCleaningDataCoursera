## Codebook - Human Activity Recognition Using Smartphones Dataset

### Data
All data was obtained from http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones and described as:

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 

Attribute Information:
For each record in the dataset it is provided: 
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration. 
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

### Result dataset
The result dataset is an avarage of each variable for each activity and each subject. It contains rows of 30 subjects * 6 activities - so total 180 rows of data of 79 variables. It is saved into "result.txt" file in a working directory.


### Function work flow
Function run_analysis() checks if the dataset is stored locally in the working directory under the name "getdata-projectfiles-UCI HAR Dataset.zip", if not it downloads the file from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

When the zip file is ready the following data are being extracted: activity labels, features, and for both training and test dataset activities, subjects and data.
```{}
  labels <- read.table(paste(zipdir, "\\UCI HAR Dataset\\activity_labels.txt", sep = "" ))
  features <- read.table(paste(zipdir, "\\UCI HAR Dataset\\features.txt", sep = "" ))
  
  x.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\X_train.txt", sep = "" ))
  y.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\y_train.txt", sep = "" ))
  subject.train <- read.table(paste(zipdir, "\\UCI HAR Dataset\\train\\subject_train.txt", sep = "" ))
  
  x.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\X_test.txt", sep = "" ))
  y.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\y_test.txt", sep = "" ))
  subject.test <- read.table(paste(zipdir, "\\UCI HAR Dataset\\test\\subject_test.txt", sep = "" ))
```

Then training and test data are bind first by pairs.
```{}
  x <- rbind(x.train, x.test)
  y <- rbind(y.train, y.test)
  subject <- rbind(subject.train, subject.test)
```

Given appropriate column names.
```{}
  colnames(x) <- features[,2]
  colnames(y) <- "Activity"
  colnames(subject) <- "Subject"
```

The resulting data set is focused on mean and std data. It's obtained in the following way:
```{}
  x = x[, grep("mean|std", colnames(x))]
```

The labels are changed from numerical into descriptive data
```{}
  y$Activity <- factor(y$Activity, labels = labels[,2])
```

And all data is merged into one variable.
```{}
  x <- cbind(subject, y, x)
```

After that the names are cleaned to ensure more readable format.
```{}
  colnames(x) <- gsub("\\(\\)", "", colnames(x))
  colnames(x) <- gsub("Freq", "Frequency", colnames(x))
  colnames(x) <- gsub("Acc", "Acceleration", colnames(x))
  colnames(x) <- gsub("Mag", "Magnitude", colnames(x))
  colnames(x) <- gsub("Gyro", "Gyroscope", colnames(x))
  colnames(x) <- gsub("^t", "Time", colnames(x))
  colnames(x) <- gsub("^f", "Frequency", colnames(x))
```

The final step, avarage over the subject and activity. Results are saved into "result.txt" file.
```{}
  result <- aggregate(x[,3:81], list(Subject = x[,1], Activity = x[,2]), mean)
  write.table(result, file = "result.txt")
```
