SELECT 
	area_id, 
	avg(compensation_from * factor) AS average_from, 
	avg(compensation_to * factor) AS average_to, 
	avg((compensation_from + compensation_to) * factor / 2) AS average_all
FROM 
	(SELECT 
		area_id, 
		compensation_from, 
		compensation_to, 
		CASE WHEN compensation_gross = true THEN 1 ELSE 0.87 END AS factor 
	FROM vacancy_body
    WHERE compensation_from is not null AND compensation_to is not null) AS rows
GROUP BY area_id ORDER BY area_id;