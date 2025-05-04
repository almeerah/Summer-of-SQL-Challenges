/*
REQUIREMENTS

- We want to stack the tables on top of one another, since they have the same fields in each sheet.
- Drag each table into the canvas and use a union step to stack them on top of one another
- Use a wildcard union in the input step of one of the tables
- Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
- Make a Joining Date field based on the Joining Day, Table Names and the year 2023
- Now we want to reshape our data so we have a field for each demographic, for each new customer
- Make sure all the data types are correct for each field
- Remove duplicates 
- If a customer appears multiple times take their earliest joining date

Output the data

Challenge source: 
https://preppindata.blogspot.com/2023/01/2023-week-4-new-customers.html

This challenge was completed using PostgreSQL
*/

WITH unioned_table AS (
    SELECT *, 'pd2023_wk04_january' AS tablename FROM pd2023_wk04_january
    UNION ALL
    SELECT *, 'pd2023_wk04_february' AS tablename FROM pd2023_wk04_february
    UNION ALL
    SELECT *, 'pd2023_wk04_march' AS tablename FROM pd2023_wk04_march
    UNION ALL
    SELECT *, 'pd2023_wk04_april' AS tablename FROM pd2023_wk04_april
    UNION ALL
    SELECT *, 'pd2023_wk04_may' AS tablename FROM pd2023_wk04_may
    UNION ALL
    SELECT *, 'pd2023_wk04_june' AS tablename FROM pd2023_wk04_june
    UNION ALL
    SELECT *, 'pd2023_wk04_july' AS tablename FROM pd2023_wk04_july
    UNION ALL
    SELECT *, 'pd2023_wk04_august' AS tablename FROM pd2023_wk04_august
    UNION ALL
    SELECT *, 'pd2023_wk04_september' AS tablename FROM pd2023_wk04_september
    UNION ALL
    SELECT *, 'pd2023_wk04_october' AS tablename FROM pd2023_wk04_october
    UNION ALL
    SELECT *, 'pd2023_wk04_november' AS tablename FROM pd2023_wk04_november
    UNION ALL
    SELECT *, 'pd2023_wk04_december' AS tablename FROM pd2023_wk04_december
),
pivoted_table AS (
    SELECT
        "ID",
        "Joining Day",
        -- Pivoting "Ethnicity"
        MAX(CASE WHEN "Demographic" = 'Ethnicity' THEN "Value" END) AS "Ethnicity",
        -- Pivoting "Date of Birth"
        MAX(CASE WHEN "Demographic" = 'Date of Birth' THEN "Value" END) AS "Date of Birth",
        -- Pivoting "Account Type"
        MAX(CASE WHEN "Demographic" = 'Account Type' THEN "Value" END) AS "Account Type",
        -- Calculate the formatted joining date
        '2023-' || LPAD(EXTRACT(MONTH FROM TO_DATE(INITCAP(split_part(tablename, '_', 3)), 'Month'))::text, 2, '0') || '-' || LPAD("Joining Day"::text, 2, '0') AS joining_date
    FROM unioned_table
    GROUP BY "ID", "Joining Day", tablename
),
ranked_table AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY "ID" ORDER BY joining_date ASC) AS rn
    FROM pivoted_table
)
SELECT
    "ID",
    "Ethnicity",
    "Date of Birth",
    "Account Type",
    "joining_date"
FROM ranked_table
ORDER BY "ID", "Joining Day";
