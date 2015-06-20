##Unzip the data
#unzip("getdata_projectfiles_UCI HAR Dataset.zip")

library(dplyr) #load dplyr for select() and arrange() functions

#read in the main folder information, activity labels and feature names
prefix<-"UCI HAR Dataset//"
filename<-paste(prefix,"activity_labels.txt",sep="")
activity.labels<-read.table(filename)
filename<-paste(prefix,"features.txt",sep="")
features<-read.table(filename)

##get training data - subject.train contains the subject ID for each observation
##                  - y.train contains the activity number (1-6 as in activity.labels)
##                  - x.train contains the 561 features for each observation (as in features)
## total observations = 7352
prefix.train<-paste(prefix,"train//",sep="")
subject.train<-read.table(paste(prefix.train,"subject_train.txt",sep=""))
y.train<-read.table(paste(prefix.train,"y_train.txt",sep=""))
x.train<-read.table(paste(prefix.train,"X_train.txt",sep=""))

##Read in Inertial Signals - not necessary
#prefix.train<-paste(prefix,"train//Inertial Signals//",sep="")
#filelist<-list.files(prefix.train,pattern="*.txt")
#data.train<-lapply(paste(prefix.train,filelist,sep=""),FUN=read.table)


##get test data - subject.test contains the subject ID for each observation
##              - y.test contains the activity number (1-6 as in activity.labels)
##              - x.test contains the 561 features for each observation (as in features)
## total observations = 2947
prefix.test<-paste(prefix,"test//",sep="")
subject.test<-read.table(paste(prefix.test,"subject_test.txt",sep=""))
y.test<-read.table(paste(prefix.test,"y_test.txt",sep=""))
x.test<-read.table(paste(prefix.test,"X_test.txt",sep=""))

##Read in Inertial Signals - not necessary
#prefix.test<-paste(prefix,"test//Inertial Signals//",sep="")
#filelist<-list.files(prefix.test,pattern="*.txt")
#data.test<-lapply(paste(prefix.test,filelist,sep=""),FUN=read.table)

##Clean and organize the data

#First, label all columns appropriately
names(x.test)<-features[,2]
names(x.train)<-features[,2]
names(subject.test)<-"Subject.ID"
names(subject.train)<-"Subject.ID"
names(y.test)<-"Activity"
names(y.train)<-"Activity"

#Next, cbind test and train data individually, then rbind test and train data together
testdata<-cbind(subject.test,y.test,x.test)
traindata<-cbind(subject.train,y.train,x.train)
alldata<-rbind(testdata,traindata)

#Convert activity to a factor according to the labels in activity.labels
alldata$Activity<-factor(alldata$Activity,levels=activity.labels[,1],labels=activity.labels[,2])

#Process the appended data by first taking out data that confuses finding the mean() and std() cols 
#         i.e., containing "bandsEnergy()"
#   and then select the cols that correspond to the mean() and std()
#   Finally, arrange the data first by Subject ID, then by Activity
#   This final data set is the one requested at the end of step 4, 
#         including descriptive factor labels (activity names) and variable names
filtered.data<-alldata[,!grepl("bandsEnergy()",names(alldata))]
filtered.data<-cbind(filtered.data[,1:2],select(filtered.data,contains("mean()")),select(filtered.data,contains("std()")))
filtered.data<-arrange(filtered.data,Subject.ID,Activity)

##Use the tidy data set filtered.data to obtain the processed data set for step 5.

#First, find the unique factor of subject ID interacting with Activity type
filtered.data[,"id.activity"]<-interaction(filtered.data$Activity,filtered.data$Subject.ID)

#Then, create a new data frame containing Subject ID, Activity name, and then the mean and std
#     of each unique Subject ID-Activity pair
UCI.HAR.tidy<-data.frame("Subject.ID"=gl(30,6),"Activity"=gl(6,1,180,labels=activity.labels[,2]))
for (i in 3:68) {
  UCI.HAR.tidy[,names(filtered.data)[i]]<-tapply(filtered.data[,i],filtered.data$id.activity,mean)
}
names(UCI.HAR.tidy)<-paste(names(UCI.HAR.tidy),"-av-ID-Activity",sep="")

#UCI.HAR.tidy now contains the cleaned data. Let's print it to a file for future reference.
write.table(UCI.HAR.tidy,file="UCI HAR averages tidy.txt",row.names=F)