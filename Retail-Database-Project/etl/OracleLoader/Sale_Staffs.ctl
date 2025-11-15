OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
characterset AL32UTF8
infile 'Sale_Staffs.csv' "str '\r\n'"
append
into table SALE_STAFFS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( SALE_STAFFID,
             ORDERID,
             EMPLOYEEID,
             CHANNELID,
             SHIPPEDDATE DATE "YYYY-MM-DD:HH24:MI:SS",
             DELIVERYDATE DATE "YYYY-MM-DD:HH24:MI:SS",
             STATUS CHAR(50)
           )
