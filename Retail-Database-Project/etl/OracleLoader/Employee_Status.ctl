load data 
characterset AL32UTF8
infile 'Employee_Status.csv' "str '\r\n'"
append
into table EMPLOYEE_STATUS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( STATUSID,
             STATUSNAME CHAR(50),
             DESCRIPTION CHAR(4000)
           )
