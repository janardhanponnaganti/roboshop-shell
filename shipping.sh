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

dnf install maven -y

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user creation"
 else 
    echo -e "roboshop user already exit $Y SKIPPING $N"
fi       

mkdir -p /app

VALIDATE $? "creating app directory" 

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
 
VALIDATE $? "Downloading shipping application" 

cd /app

unzip -o /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOGFILE

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE

systemctl enable shipping &>> $LOGFILE

systemctl start shipping &>> $LOGFILE

dnf install mysql -y &>> $LOGFILE

mysql -h mysql.ponnaganti.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

systemctl restart shipping &>> $LOGFILE

