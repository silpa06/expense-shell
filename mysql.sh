#!bin/bash
USERID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run the script with root previleages $N"
        exit 1
    fi
}

VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.. $R FAILED $N"
        exit 1
    else
        echo -e "$2 is ..$G SUCCESS $N"
    fi
}
CHECK_ROOT
dnf install mysql-server -y
VALIDATION $? "MYSQL server installation"