OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
characterset AL32UTF8
infile 'Customers.csv' "str '\r\n'"
append
into table CUSTOMERS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( CUSTOMERID,
             FULLNAME CHAR(100),
             TYPEID,
             STATUSID,
             EMAIL CHAR(100),
             PHONE CHAR(20),
             REGISTRATIONDATE DATE "YYYY-MM-DD"
           )


