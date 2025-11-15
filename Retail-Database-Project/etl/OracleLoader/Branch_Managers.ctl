load data 
characterset AL32UTF8
infile 'Branch_Managers.csv' "str '\r\n'"
append
into table BRANCH_MANAGERS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( BRANCHMANAGERID,
             BRANCHID,
             EMPLOYEEID,
             STARTDATE DATE "YYYY-MM-DD"
           )
