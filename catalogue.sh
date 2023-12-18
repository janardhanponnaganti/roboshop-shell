#!/bin/bash

ID=$(id -u)
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"
MONGODB_HOST=mongodb.ponnaganti.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2... $R failed $N"
    else
        echo -e "$2 ... $G success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: plese run this script with root access $N"
    exit 1 # you can give other then 0
else
    echo "you are root user"
fi # fi means reverse of if, indicating condition end 

dnf module disable nodejs -y

VALIDATE $? "disabling current nodeJs" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "enabling nodeJS:18"  &>> $LOGFILE

dnf install nodejs -y

VALIDATE $? "installing nodeJS:18" &>> $LOGFILE

useradd roboshop

VALIDATE $? "crating roboshop user" &>> $LOGFILE

mkdir /app

VALIDATE $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "Downloading catalougue application" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip

VALIDATE $? "unzipping catalogue" &>> $LOGFILE

npm install 

VALIDATE $? "installing dependencies" &>> $LOGFILE

#use absolute, because catalogue.service exits there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalougue service file" &>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "catalogue demon reload" &>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalogue" &>> $LOGFILE

systemctl start catalogue

VALIDATE $? "starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo $>> $LOGFILE

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "loading catalougue data into MongoDB"




