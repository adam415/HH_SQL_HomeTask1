SELECT	
    (SELECT	extract(month FROM creation_time) AS month_with_max_resumes
	FROM resume
	GROUP BY extract(month FROM creation_time)
	ORDER BY count(resume_id) DESC
	LIMIT 1),
    (SELECT	extract(month FROM creation_time) AS month_with_max_vacancies
	FROM vacancy
	GROUP BY extract(month FROM creation_time)
	ORDER BY count(vacancy_id) DESC
	LIMIT 1);