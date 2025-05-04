/*
REQUIREMENTS

 - Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction
- Rename the new field with the Bank code 'Bank'. 
- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 
- Change the date to be the day of the week

Different levels of detail are required in the outputs. 
You will need to sum up the values of the transactions in three ways:
  1. Total Values of Transactions by each bank
  2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
  3. Total Values by Bank and Customer Code

Output each query

Challenge source: 
https://preppindata.blogspot.com/2023/01/2023-week-1-data-source-bank.html

This challenge was completed using PostgreSQL
*/


  -- 1. Total Values of Transactions by each bank
   
    SELECT
    SPLIT_PART(transaction_code, '-', 1) as bank,
    sum(value) as total_transactions
    FROM pd2023_wk01
    GROUP BY bank;
    
-- 2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)

    SELECT
    SPLIT_PART(transaction_code, '-', 1) as bank,
    CASE
    	WHEN online_or_in_person = 1
        	THEN 'Online'
        WHEN online_or_in_person = 2
        	THEN 'In Person'
        END AS online_in_person,
         TO_CHAR(TO_TIMESTAMP(transaction_date, 'DD/MM/YYYY HH24:MI:SS'), 'Day') AS day_of_week,
        sum(value)
    FROM pd2023_wk01
    GROUP BY bank, online_in_person,day_of_week;
    
-- 3. Total Values by Bank and Customer Code
    
    SELECT
    SPLIT_PART(transaction_code, '-', 1) as bank,
    customer_code,
        sum(value) as total_value
    FROM pd2023_wk01
    GROUP BY bank, customer_code;
