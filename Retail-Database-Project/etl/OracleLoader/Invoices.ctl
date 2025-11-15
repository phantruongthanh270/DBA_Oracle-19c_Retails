load data 
characterset AL32UTF8
infile 'Invoices.csv' "str '\r\n'"
append
into table INVOICES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( INVOICEID,
             INVOICEDATE DATE "YYYY-MM-DD:HH24:MI:SS",
             STATUSID,
             EMPLOYEEID,
             TOTALAMOUNT
           )
