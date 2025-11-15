load data 
characterset AL32UTF8
infile 'Branch_Types.csv' "str '\r\n'"
append
into table BRANCH_TYPES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( BRANCHTYPEID,
             TYPENAME CHAR(50),
             DESCRIPTION CHAR(4000)
           )
