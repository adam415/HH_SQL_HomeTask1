INSERT INTO company(company_name)
SELECT
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150)::integer))
FROM generate_series(1, 800);


INSERT INTO vacancy_body(
    company_name, vacancy_name, vacancy_text, area_id, address_id, work_experience, 
    compensation_from, test_solution_required,
    work_schedule_type, employment_type, compensation_gross
)
SELECT 
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150 + i % 10)::integer)) AS company_name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 25 + i % 10)::integer)) AS vacancy_name,

    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 50 + i % 10)::integer)) AS vacancy_text,

    (random() * 1000)::int AS area_id,
    (random() * 50000)::int AS address_id,
    NULL AS work_experience,
    25000 + (random() * 150000)::int AS compensation_from,
    (random() > 0.5) AS test_solution_required,
    floor(random() * 5)::int AS work_schedule_type,
    floor(random() * 5)::int AS employment_type,
    (random() > 0.5) AS compensation_gross
FROM generate_series(1, 1000) AS g(i);

UPDATE vacancy_body
SET compensation_to = compensation_from + (random() * 100000)::int;

UPDATE vacancy_body
SET compensation_from = null, compensation_to = null
WHERE vacancy_body_id in (
	SELECT vacancy_body_id
	FROM vacancy_body
	ORDER BY random()
	LIMIT 100
);


INSERT INTO vacancy(
    vacancy_body_id, creation_time, expire_time, company_id, disabled, visible,
    available_for_disabled, available_for_unfilled, hidden_without_letters, area_id)
SELECT
    body.vacancy_body_id                                                AS vacancy_body_id,
    -- random in last 5 years
    now() - (random() * 5 * 365 * 24 * 60 * 60) * '1 second'::interval  AS creation_time,
    -- random in next 5 years
    now() + (random() * 5 * 365 * 24 * 60 * 60) * '1 second'::interval  AS expire_time,
    (random() * ((SELECT COUNT(*) FROM company) - 1) + 1)::int          AS company_id,

    (random() > 0.5)            AS disabled,
    (random() > 0.5)            AS visible,
    (random() > 0.5)            AS available_for_disabled,
    (random() > 0.5)            AS available_for_unfilled,
    (random() > 0.5)            AS hidden_without_letters,
    (random() * 1000)::int      AS area_id
FROM vacancy_body AS body;


INSERT INTO resume(
    creation_time, expire_time,
    user_lastname, user_firstname, for_position, description, user_sex, education_level)
SELECT
    -- random in last 5 years
    now() - (random() * 5 * 365 * 24 * 60 * 60) * '1 second'::interval  AS creation_time,
    -- random in next 5 years
    now() + (random() * 5 * 365 * 24 * 60 * 60) * '1 second'::interval  AS expire_time,
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150 + i % 10)::integer)) AS user_lastname,
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150 + i % 10)::integer)) AS user_firstname,
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150 + i % 10)::integer)) AS for_position,
    (SELECT string_agg(
        substr(
            '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 
            (random() * 77)::integer + 1, 1
        ), 
        '') 
    FROM generate_series(1, 1 + (random() * 150 + i % 10)::integer)) AS description,

    (random() > 0.5)    AS user_sex,
    floor(random() * 7) AS education_level
FROM generate_series(1, 1000) as g(i);


INSERT INTO response(response_date, vacancy_id, resume_id)
SELECT
    now()       AS response_date,
    vacancy_id,
    resume_id
FROM vacancy, resume
ORDER BY random()
LIMIT 500;