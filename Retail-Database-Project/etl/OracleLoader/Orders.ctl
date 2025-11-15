OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
characterset AL32UTF8
infile 'Orders.csv' "str '\r\n'"
append
into table ORDERS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( ORDERID,
             CUSTOMERID,
             BRANCHID,
             ORDERDATE DATE "YYYY-MM-DD:HH24:MI:SS",
             STATUSID,
             TOTALAMOUNT
           )
