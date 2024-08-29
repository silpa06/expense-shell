#!bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense"
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER
CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run the script with root previleages $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATION(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.. $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is ..$G SUCCESS $N" | tee -a $LOG_FILE
    fi
}
echo "Script started executing at: $(date)" | tee -a $LOG_FILE
CHECK_ROOT
dnf list installed mysql-server
if [ $? -ne 0 ]
then 
    echo "MYSQL server is not installed ..going to install"
    dnf install mysql-server -y & >> $LOG_FILE
    VALIDATION $? "MYSQL server installation"
else 
    echo "MYSQL server is already installed.. nothing to do"
fi




