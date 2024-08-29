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
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATION $? "nodejs module disabled is"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATION $? "nodejs:20 module enabled"

dnf install nodejs -y &>>$LOG_FILE
VALIDATION $? "nodejs installation"
id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then   
    echo -e "expense user is not exist $G CREATING $N"
    useradd expense &>>$LOG_FILE
    VALIDATION $? "adding expense app user"
else
    echo -e "expense user is already exist $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATION $? "creating /app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATION $? "downloading backend application code"

cd /app
rm -rf /app/* # removing the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATION $? "extracting backend application code"
npm install &>>$LOG_FILE

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
dnf install mysql -y &>>$LOG_FILE
VALIDATION $? "mysql installation"
mysql -h db.devteck.xyz -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATION $? "validate schema loading"
systemctl daemon-reload &>>$LOG_FILE
VALIDATION $? "daemon reload"
systemctl enable backend &>>$LOG_FILE
VALIDATION $? "enabled backend"
systemctl restart backend &>>$LOG_FILE
VALIDATION $? "restarting backend"









