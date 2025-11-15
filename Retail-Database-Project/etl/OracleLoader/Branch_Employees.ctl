load data 
characterset AL32UTF8
infile 'Branch_Employees.csv' "str '\r\n'"
append
into table BRANCH_EMPLOYEES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( BRANCHEMPLOYEEID,
             BRANCHID,
             EMPLOYEEID,
             POSITION CHAR(100),
             STARTDATE DATE "YYYY-MM-DD"
           )
