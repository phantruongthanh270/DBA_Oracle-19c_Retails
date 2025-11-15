load data 
characterset AL32UTF8
infile 'Branches.csv' "str '\r\n'"
append
into table BRANCHES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( BRANCHID,
             BRANCHNAME CHAR(100),
             TYPEID,
             STATUSID,
             ADDRESS CHAR(255),
             PHONE CHAR(20),
             EMAIL CHAR(100),
             CREATEDDATE DATE "YYYY-MM-DD"
           )
