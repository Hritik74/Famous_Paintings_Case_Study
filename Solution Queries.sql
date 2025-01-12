

-- 1) Fetch all the paintings which are not displayed on any museums?

SELECT 
    name as Paintings_Name
FROM
    work
WHERE
    museum_id IS NULL;
    

-- 2) Are there museuems without any paintings?

SELECT 
    m.museum_id,m.name
FROM
    museum m
        LEFT JOIN
    work w ON m.museum_id = w.museum_id
WHERE
    w.museum_id IS NULL;
    

-- 3) How many paintings have an asking price more than their regular price? 

SELECT 
    *
FROM
    work w
        JOIN
    product_size ps ON w.work_id = ps.work_id
WHERE
    sale_price > regular_price;


-- 4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT 
    name, sale_price, regular_price
FROM
    work w
        JOIN
    product_size ps ON w.work_id = ps.work_id
WHERE
    sale_price < (regular_price * 0.5);
    

-- 5) Which canva size costs the most?

SELECT 
    label, sale_price
FROM
    product_size ps
        JOIN
    canvas_size cs ON ps.size_id = cs.size_id
WHERE
    sale_price = (SELECT 
            MAX(sale_price)
        FROM
            product_size);


-- 6) Delete duplicate records from work, product_size, subject and image_link tables
 
 -- for WORK Table
WITH ranked_rows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY work_id) AS row_num
    FROM work
)
DELETE FROM work
WHERE work_id IN (
    SELECT work_id
    FROM ranked_rows
    WHERE row_num > 1
);

-- for PRODUCT_SIZE Table

WITH ranked_rows AS (
    SELECT work_id, size_id, 
    ROW_NUMBER() OVER (PARTITION BY work_id, size_id) AS row_num
    FROM product_size
)
DELETE FROM product_size
where (work_id, size_id) in(
	SELECT work_id, size_id
    FROM ranked_rows
    WHERE row_num > 1
);

-- for SUBJECT Table

WITH ranked_rows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY work_id) AS row_num
    FROM subject
)
DELETE FROM work
WHERE work_id IN (
    SELECT work_id
    FROM ranked_rows
    WHERE row_num > 1
);

-- for IMAGE_LINK Table

WITH ranked_rows AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY work_id) AS row_num
    FROM image_link
)
DELETE FROM image_link
WHERE work_id IN (
    SELECT work_id
    FROM ranked_rows
    WHERE row_num > 1
);


-- 7) Identify the museums with invalid city information in the given dataset

SELECT 
    *
FROM
    museum
WHERE
    city REGEXP '^[0-9]';
    
    
-- 8) Fetch the top 10 most famous painting subject

with cte as (
	select s.subject, count(1) as no_of_subjects
	, rank() over(order by count(1) desc) as rn 
	FROM work w
	join subject s on w.work_id=s.work_id 
	group by 1
	order by 2 desc
)
select subject, no_of_subjects
from cte 
where rn<=10;


-- 9) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT 
    DISTINCT m.name, m.city
FROM
    museum_hours mh1
        JOIN
    museum_hours mh2 ON mh1.museum_id = mh2.museum_id
        JOIN
    museum m ON m.museum_id = mh1.museum_id
WHERE
    mh1.day = 'Sunday' AND mh2.day = 'Monday';
    
    
-- 10) How many museums are open every single day?

SELECT 
    COUNT(1) as total_museums_opn_everyday
FROM
    (SELECT 
        museum_id, COUNT(1)
    FROM
        museum_hours
    GROUP BY museum_id
    HAVING COUNT(1) = 7) x;
    
    
-- 11) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT 
    name, 
    count_of_paintings 
FROM (
    SELECT 
        m.name, 
        COUNT(w.name) AS count_of_paintings, 
        RANK() OVER (ORDER BY COUNT(w.name) DESC) AS rn
    FROM 
        museum m
    JOIN 
        work w ON m.museum_id = w.museum_id
    GROUP BY 
        m.name
) x
WHERE 
    rn <= 5;


-- 12) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT 
    full_name, 
    count_of_paintings 
FROM (
    SELECT 
        a.full_name, 
        COUNT(w.name) AS count_of_paintings, 
        RANK() OVER (ORDER BY COUNT(w.name) DESC) AS rn
    FROM 
        artist a
    JOIN 
        work w ON a.artist_id = w.artist_id
    GROUP BY 
        a.full_name
) x
WHERE 
    rn <= 5;


-- 13) Display the 3 least popular canva sizes

select label,no_of_paintings, ranking
	from(
SELECT 
    c.size_id, c.label, COUNT(c.size_id) as no_of_paintings, dense_rank() over(order by count(c.size_id) ) as ranking
FROM
    WORK w
        JOIN
    product_size p ON w.work_id = p.work_id
        JOIN
    canvas_size c ON p.size_id = c.size_id
GROUP BY c.size_id , c.label
) x
where ranking<=3;


-- 14) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?

-- first updating time colums with valid formats for calculation
UPDATE museum_hours 
SET open = CONCAT(
    SUBSTRING(open, 1, LOCATE(':', open, LOCATE(':', open) + 1) - 1),
    ' ',
    SUBSTRING(open, LOCATE(':', open, LOCATE(':', open) + 1) + 1)
);

UPDATE museum_hours
SET close = CONCAT(
    SUBSTRING(close, 1, LOCATE(':', close, LOCATE(':', close) + 1) - 1),
    ' ',
    SUBSTRING(close, LOCATE(':', close, LOCATE(':', close) + 1) + 1)
);

SELECT 
    museum_name, 
    state, 
    day, 
    duration
FROM (
    SELECT 
        m.name AS museum_name, 
        m.state, 
        day, 
        STR_TO_DATE(open, '%h:%i %p') AS open_time, 
        STR_TO_DATE(close, '%h:%i %p') AS close_time,
        TIMEDIFF(
            STR_TO_DATE(close, '%h:%i %p'), 
            STR_TO_DATE(open, '%h:%i %p')
        ) AS duration,
        RANK() OVER (
            ORDER BY TIMEDIFF(
                STR_TO_DATE(close, '%h:%i %p'), 
                STR_TO_DATE(open, '%h:%i %p')
            ) DESC
        ) AS rnk
    FROM 
        museum_hours AS mh
    JOIN 
        museum m 
    ON 
        m.museum_id = mh.museum_id
) x
WHERE 
    x.rnk = 1;
    

-- 15) Which museum has the most popular painting style?

with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1;


-- 16) Identify the artists whose paintings are displayed in multiple countries

WITH cte AS (
    SELECT DISTINCT 
        a.full_name AS artist,
        m.country
    FROM 
        work w
    JOIN 
        artist a 
        ON a.artist_id = w.artist_id
    JOIN 
        museum m 
        ON m.museum_id = w.museum_id
)
SELECT 
    artist,
    COUNT(DISTINCT country) AS no_of_countries
FROM 
    cte
GROUP BY 
    artist
Having 
	COUNT(DISTINCT country) >1
ORDER BY 
    2 desc;


-- 17) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

WITH cte_country AS (
    SELECT 
        country, 
        COUNT(1) AS museum_count,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        museum
    GROUP BY 
        country
),
cte_city AS (
    SELECT 
        city, 
        COUNT(1) AS museum_count,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        museum
    GROUP BY 
        city
)
SELECT 
    GROUP_CONCAT(DISTINCT country ORDER BY country SEPARATOR ', ') AS top_countries,
    GROUP_CONCAT(city ORDER BY city SEPARATOR ', ') AS top_cities
FROM 
    cte_country 
CROSS JOIN 
    cte_city 
WHERE 
    cte_country.rnk = 1
    AND cte_city.rnk = 1;


 /* 18) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
		Display the artist name, sale_price, painting name, museum name, museum city and canvas label */	

WITH cte AS (
    SELECT 
        a.full_name AS artist, 
        ps.sale_price,
        w.name AS painting,
        m.name AS museum,
        m.city AS city,
        cz.label AS canvas,
        RANK() OVER (ORDER BY sale_price DESC) AS rnk,
        RANK() OVER (ORDER BY sale_price ASC) AS rnk_asc
    FROM 
        product_size ps
    JOIN 
        canvas_size cz ON cz.size_id = ps.size_id
    JOIN 
        work w ON w.work_id = ps.work_id
    JOIN 
        museum m ON m.museum_id = w.museum_id
    JOIN 
        artist a ON a.artist_id = w.artist_id
)
SELECT 
    artist,
    sale_price,
    painting,
    museum,
    city,
    canvas,
    CASE 
        WHEN cte.rnk = 1 THEN 'most_expensive' 
        WHEN cte.rnk_asc = 1 THEN 'least_expensive'
    END AS max_or_min
FROM 
    cte
WHERE 
    cte.rnk = 1 
    OR cte.rnk_asc = 1;

-- 19) Which country has the 5th highest no of paintings?

SELECT 
    country,
    no_of_paintings
FROM (
    SELECT 
        country, 
        COUNT(1) AS no_of_paintings, 
        RANK() OVER (ORDER BY COUNT(1) DESC) AS rnk
    FROM 
        work w
    JOIN 
        museum m ON w.museum_id = m.museum_id
    GROUP BY 
        country
) x
WHERE 
    rnk = 5;
    

-- 20) Which are the 3 most popular and 3 least popular painting styles?
 
 WITH cte AS (
    SELECT 
        style, 
        COUNT(1) AS cnt_of_paintings,
        RANK() OVER (ORDER BY COUNT(1) ASC) AS asc_rnk,
        RANK() OVER (ORDER BY COUNT(1) DESC) AS desc_rnk
    FROM 
        work
    GROUP BY 
        style
)
SELECT 
    style, 
    cnt_of_paintings,
    CASE 
        WHEN cte.desc_rnk <= 3 THEN 'most_popular' 
        WHEN cte.asc_rnk <= 3 THEN 'least_popular'
    END AS popularity
FROM 
    cte
WHERE 
    asc_rnk <= 3 
    OR desc_rnk <= 3;


-- 21) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

WITH cte AS (
    SELECT 
        a.full_name, 
        nationality, 
        COUNT(1) AS no_of_paintings
    FROM 
        work w
    JOIN 
        artist a ON w.artist_id = a.artist_id
    JOIN 
        museum m ON w.museum_id = m.museum_id
    JOIN 
        subject s ON s.work_id = w.work_id
    WHERE 
        s.subject = 'Portraits' 
        AND m.country != 'USA'
    GROUP BY 
        a.full_name, nationality
)
SELECT 
    * 
FROM 
	cte 
WHERE 
    no_of_paintings = (SELECT MAX(no_of_paintings) FROM cte);





							



