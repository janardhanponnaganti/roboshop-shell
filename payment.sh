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
        exit 1
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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "install pyton"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user creation"
 else 
    echo -e "roboshop user already exit $Y SKIPPING $N"
fi       

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory" 

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
 
VALIDATE $? "Downloading payment application"

cd /app &>> $LOGFILE

unzip -o /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzipping payment"  

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "installing dependencies" 

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "deamon reload" 

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enabling payment" 

systemctl start payment &>> $LOGFILE

VALIDATE $? "starting payment" 
