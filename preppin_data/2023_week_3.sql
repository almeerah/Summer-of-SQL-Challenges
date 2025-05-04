/*
REQUIREMENTS

For the transactions file:
- Filter the transactions to just look at DSB 
  - These will be transactions that contain DSB in the Transaction Code field
- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
- Change the date to be the quarter 
- Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person)

For the targets file:
- Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
- Rename the fields
- Remove the 'Q' from the quarter field and make the data type numeric (help)

Join the two datasets together 
- You may need more than one join clause!

Remove unnecessary fields
Calculate the Variance to Target for each row
Output the data


Challenge source: 
https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html

This challenge was completed using PostgreSQL
*/

SELECT
    a.online_in_person,
    a.quarter,
    sum(a.actual_value) - sum(t.value) AS target_value
FROM (
    SELECT
        transaction_code,
        CASE
            WHEN online_or_in_person = 1 THEN 'Online'
            WHEN online_or_in_person = 2 THEN 'In Person'
        END AS online_in_person,
        CAST(TO_CHAR(TO_TIMESTAMP(transaction_date, 'DD/MM/YYYY HH24:MI:SS'), 'Q') AS INT) AS quarter,
        SUM(value) AS actual_value
    FROM pd2023_wk01
    WHERE transaction_code ILIKE 'DSB%'
    GROUP BY transaction_code, online_in_person, quarter
) a
JOIN (
    SELECT online_or_in_person, 1 AS quarter, q1 AS value FROM pd2023_wk03_targets
    UNION ALL
    SELECT online_or_in_person, 2, q2 FROM pd2023_wk03_targets
    UNION ALL
    SELECT online_or_in_person, 3, q3 FROM pd2023_wk03_targets
    UNION ALL
    SELECT online_or_in_person, 4, q4 FROM pd2023_wk03_targets
) t
ON a.online_in_person = t.online_or_in_person
AND a.quarter = t.quarter
GROUP BY a.online_in_person, a.quarter;
