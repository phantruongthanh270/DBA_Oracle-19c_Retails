load data 
characterset AL32UTF8
infile 'Customer_Addresses.csv' "str '\r\n'"
append
into table CUSTOMER_ADDRESSES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( ADDRESSID,
             CUSTOMERID,
             STREET CHAR(100),
             CITY CHAR(50),
             DISTRICT CHAR(50),
             PROVINCE CHAR(50),
             POSTALCODE CHAR(10)
           )
