OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
characterset AL32UTF8
infile 'Payment_Methods.csv' "str '\r\n'"
append
into table PAYMENT_METHODS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( METHODID,
             METHODNAME CHAR(50),
             DESCRIPTION CHAR(4000)
           )
