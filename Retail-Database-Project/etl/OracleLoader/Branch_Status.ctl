load data 
characterset AL32UTF8
infile 'Branch_Status.csv' "str '\r\n'"
append
into table BRANCH_STATUS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( BRANCHSTATUSID,
             STATUSNAME CHAR(50),
             DESCRIPTION CHAR(4000)
           )
