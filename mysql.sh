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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disable mysql version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copied mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enableing mySql server"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mySql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE 

VALIDATE $? "setting mysql root password"
