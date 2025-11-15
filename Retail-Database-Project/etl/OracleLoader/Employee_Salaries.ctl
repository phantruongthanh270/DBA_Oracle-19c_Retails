load data 
characterset AL32UTF8
infile 'Employee_Salaries.csv' "str '\r\n'"
append
into table EMPLOYEE_SALARIES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( SALARYID,
             EMPLOYEEID,
             BASESALARY,
             BONUS,
             EFFECTIVEDATE DATE "YYYY-MM-DD",
             EXPIRYDATE DATE "YYYY-MM-DD"
           )
