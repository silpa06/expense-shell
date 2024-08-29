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

dnf list installed nginx 
if [ $? -ne 0 ]
then
    echo "nginx is not installed..going to install"
    dnf install nginx -y &>>$LOG_FILE
    VALIDATION $? "nginx installation"
else
    echo "nginx is already installed..$Y SKIPPING $N"
fi

systemctl enable nginx &>>$LOG_FILE
VALIDATION $? "enabled nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATION $? "started nginx"

rm -rf /usr/share/nginx/html/*
VALIDATION $? "removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATION $? "downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATION $? "extracted front end code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/defaultd.d/expense.conf
VALIDATION $? "copied expense conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATION $? "restarted nginx"








 