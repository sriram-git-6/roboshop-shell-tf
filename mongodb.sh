#!/bin/bash

# create mongodb instance and add private ip in route53 record.

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongodb repo into yum.repos.d"

yum install mongodb-org -y

VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Edited mongodb conf"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting mongodb"

# after running the above script to check the whether the mongodb is installed or not execute netstat -lntp and systemctl status mongod