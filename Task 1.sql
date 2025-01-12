-- 1) Fetch all the paintings which are not displayed on any museums?

SELECT 
    name as Paintings_Name
FROM
    work
WHERE
    museum_id IS NULL;

