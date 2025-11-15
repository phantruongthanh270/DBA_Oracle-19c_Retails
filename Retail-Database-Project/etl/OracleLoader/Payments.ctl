OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
characterset AL32UTF8
infile 'Payments.csv' "str '\r\n'"
append
into table PAYMENTS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( INVOICEID,
             PAYMENTDATE DATE "YYYY-MM-DD:HH24:MI:SS",
             METHODID,
             PAYMENTID,
             AMOUNTPAID
           )
