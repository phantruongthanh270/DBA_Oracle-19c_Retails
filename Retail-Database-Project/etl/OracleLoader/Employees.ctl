load data 
characterset AL32UTF8
infile 'Employees.csv' "str '\r\n'"
append
into table EMPLOYEES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( EMPLOYEEID,
             FULLNAME CHAR(100),
             TYPEID,
             STATUSID,
             HIREDATE DATE "YYYY-MM-DD",
             EMAIL CHAR(100),
             PHONE CHAR(20)
           )
