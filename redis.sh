#!/bin/bash

ID=$(id -u)
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y  &>> $LOGFILE

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "enabling redis"

dnf install redis -y

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

VALIDATE $? "allowing remote connections"

systemctl enable redis

VALIDATE $? "enabled redis"

systemctl start redis

VALIDATE $? "staring redis"

