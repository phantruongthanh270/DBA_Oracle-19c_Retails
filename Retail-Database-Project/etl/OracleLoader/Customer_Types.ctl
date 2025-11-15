load data 
characterset AL32UTF8
infile 'Customer_Types.csv' "str '\r\n'"
append
into table CUSTOMER_TYPES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( TYPEID,
             TYPENAME CHAR(50),
             DESCRIPTION CHAR(4000)
           )
