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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "staring nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "remove default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "downloaded web application"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moveing ngix html directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copied roboshop reverse proxy"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarting nginx" 