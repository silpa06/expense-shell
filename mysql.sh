LOG_FOLDER="/var/log/expense"
FILENAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOGFILE="$LOG_FOLDER/$FILENAME-TIMESTAMP.log"
mkdir -p $LOG_FOLDER

USERID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

CHECK_ROOT(){
    if [ USERID -ne 0 ]
    then 
    echo -e "$R RUn the script with root previleages $N" | tee -a $LOGFILE
    EXIT 1
    fi 
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2 is .. $R FAILED $N"
    exit 1
    else -e "$2 is .. $G SUCCESS $N"
    fi 
}

echo  "script started executing at: $(date) | tee -a $LOGFILE

CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? "msql-server-installation"
systemctl enable mysqld
VALIDATE $? "enabled mysql server"
systemctl start mysqld
VALIDATE $? "started mysql server"

mysql -h "dns name" -u root -pExpenseApp@1 -e 'show databases;' & >> $LOGFILE
if [ $? -ne 0 ]
then
echo "mysql root password is not setup..setting now" & >> $LOGFILE
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "setting up root password"
else
echo "mysql root password is already setup..$Y SKIPPIND $N"
fi




