SELECT
	vacancy_name
FROM
	vacancy AS vac
	JOIN vacancy_body  AS body using(vacancy_body_id)
	LEFT JOIN response AS resp using(vacancy_id)
WHERE
	resp.response_date - vac.creation_time < '1 week'::interval
	OR resp.response_id IS null
GROUP BY vacancy_id, vacancy_name
HAVING count(resp.response_id) < 5
ORDER BY 1;