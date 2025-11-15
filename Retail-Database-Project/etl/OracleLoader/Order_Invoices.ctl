OPTIONS (DIRECT=TRUE, ROWS=50000)
load data 
characterset AL32UTF8
infile 'Order_Invoices.csv' "str '\r\n'"
append
into table ORDER_INVOICES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( ORDERINVOICEID,
             ORDERID,
             INVOICEID
           )
