OPTIONS (DIRECT=TRUE, ROWS=50000)

load data 
infile 'Order_Details.csv' "str '\r\n'"
append
into table ORDER_DETAILS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( 
             ORDERID,
             PRODUCTID,
             QUANTITY,
             UNITPRICE,
             ORDERDETAILID
           )
