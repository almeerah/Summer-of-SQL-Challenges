/*
IBAN Code Order:
- Country Code
- Check Digits
- Bank Code
- Sort Code
- Account Number

REQUIREMENTS

- In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string
- Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account
- Add a field for the Country Code
  Hint: all these transactions take place in the UK so the Country Code should be GB
- Create the IBAN as above
  Hint: watch out for trying to combine sting fields with numeric fields - check data types
- Remove unnecessary fields
- Output the data

Challenge source: 
https://preppindata.blogspot.com/2023/01/2023-week-2-international-bank-account.html

This challenge was completed using PostgreSQL
*/

WITH IBAN_components as (
    SELECT REGEXP_REPLACE(tr.sort_code,'-', '', 'g') as sort_code_clean,
    sw.swift_code,
    sw.check_digits,
  	tr.account_number,
    'GB' as country_code
    FROM
    pd2023_wk02_transactions tr
    JOIN pd2023_wk02_swift_codes sw ON tr.bank = sw.Bank
    )
   SELECT country_code || check_digits || swift_code || sort_code_clean || account_number
   FROM IBAN_components
;
