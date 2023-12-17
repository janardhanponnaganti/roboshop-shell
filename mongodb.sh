#!/bin/bash

ID=$(id -u)
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongoDB repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "installing mongoDB"

systemctl enable mongod

VALIDATE $? "enabling MongoDB"

systemctl start mongod

VALIDATE $? "stating mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to MongoDB"

systemctl restart  mongod &>> $LOGFILE

VALIDATE $? "restaring MongoDB" 