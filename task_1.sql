-- DROP TABLE response;
-- DROP TABLE resume_to_specialization;
-- DROP TABLE resume_to_language_skill;
-- DROP TABLE language_skill;
-- DROP TABLE resume_to_skill;
-- DROP TABLE resume_to_work_experience;
-- DROP TABLE work_experience;
-- DROP TABLE resume_to_user_citizenship;
-- DROP TABLE resume;
-- DROP TABLE vacancy_body_to_contact;
-- DROP TABLE contact;
-- DROP TABLE vacancy_body_to_skill;
-- DROP TABLE skill;
-- DROP TABLE vacancy_body_to_specialization;
-- DROP TABLE specialization;
-- DROP TABLE vacancy;
-- DROP TABLE vacancy_body;
-- DROP TABLE currency;
-- DROP TABLE company_to_company_badge;
-- DROP TABLE company;
-- DROP TABLE company_badge;

CREATE TABLE company_badge (
	-- Проверенная компания, номинант премии и прочие
	badge_id 							serial 			PRIMARY KEY,
	badge_name							varchar(20) 	NOT NULL,
	badge_image_url 					varchar(30) 	NOT NULL
);

CREATE TABLE company (
	-- Только необходимое для вакансии
	company_id 							serial 			PRIMARY KEY,
	company_name 						varchar(150) 	NOT NULL,
	company_image_url 					varchar(30) 	NULL
);

CREATE TABLE company_to_company_badge (
	company_to_company_badge_id 		serial 			PRIMARY KEY,
	company_id 							integer 		REFERENCES company(company_id),
	badge_id							integer 		REFERENCES company_badge(badge_id)
);

CREATE TABLE currency (
	currency_id							serial 			PRIMARY KEY,
	currency_name 						varchar(30) 	NOT NULL 	-- Название валюты на некотором оригинальном языке.
	-- Для локализации целесообразно использовать отдельные схемы и, возможно, базы данных
);

CREATE TABLE vacancy_body (
    vacancy_body_id 					serial 			PRIMARY KEY,
    vacancy_name						varchar(220) 	NOT NULL 	DEFAULT ''::varchar,
	
    compensation_from 					bigint 			DEFAULT 0,
    compensation_to 					bigint 			DEFAULT 0,
	compensation_currency_id			integer 		REFERENCES currency(currency_id),
    compensation_gross 					boolean,
	
	-- Пока не знаю, оставлять ли название здесь. Не нормально (в смысле формы, какой каламбурчик)
    company_name 						varchar(150) 	NOT NULL 	DEFAULT ''::varchar,
	company_id 							integer 		REFERENCES company(company_id),
	
	-- Зачем здесь area_id, когда он есть в vacancy?
	-- Или в vacancy тот, который из "Вакансия опубликована ..."?
    area_id 							integer,
    address_id 							integer,
	
    work_experience 					integer 		NULL	 	DEFAULT 0,
    work_schedule_type 					integer 		NULL	 	DEFAULT 0,
    employment_type 					integer 		NULL	 	DEFAULT 0,
	
    vacancy_text						text,
	
	-- Нормализация? Она же единый формат и удобный поиск даст, вроде.
	-- Но и оптимизировать бы как-то, чтобы не прогонять кучу связанных таблиц, дабы одну вакансию открыть
    driver_license_types 				varchar(5)[],
	
    test_solution_required 				boolean 		NOT NULL 	DEFAULT false,
	
    CONSTRAINT vacancy_body_employment_type_validate 		CHECK ((employment_type 	=	ANY (ARRAY[0, 1, 2, 3, 4]))),
    CONSTRAINT vacancy_body_work_schedule_type_validate 	CHECK ((work_schedule_type 	= 	ANY (ARRAY[0, 1, 2, 3, 4])))
);

CREATE TABLE vacancy (
    vacancy_id 							serial 			PRIMARY KEY,
	
    creation_time 						timestamp 		NOT NULL,
    expire_time 						timestamp 		NOT NULL,
    area_id 							integer,
	
    company_id 							integer			REFERENCES company(company_id),
	
	-- Это для соискателей с инвалидностью или вакансия "отключена"?
    disabled 							boolean 		NOT NULL DEFAULT false,
    visible 							boolean 		NOT NULL DEFAULT true,
	available_for_disabled 				boolean 		NOT NULL DEFAULT false,
	available_for_unfilled 				boolean 		NOT NULL DEFAULT true,
	hidden_without_letters 				boolean 		NOT NULL DEFAULT false,
	
    vacancy_body_id 					integer 		REFERENCES vacancy_body(vacancy_body_id)
);

CREATE TABLE specialization (
	specialization_id 					serial 			PRIMARY KEY,
	specialization_title 				varchar(50) 	NOT NULL
);

CREATE TABLE vacancy_body_to_specialization (
    vacancy_body_to_specialization_id 	serial  		PRIMARY KEY,
    vacancy_body_id 					integer 		REFERENCES vacancy_body(vacancy_body_id),
    specialization_id 					integer 		REFERENCES specialization(specialization_id)
);

CREATE TABLE skill (
	skill_id 							serial 			PRIMARY KEY,
	skill_description 					varchar(50) 	NOT NULL
);

CREATE TABLE vacancy_body_to_skill (
	vacancy_body_to_skill_id 			serial 			PRIMARY KEY,
	vacancy_body_id 					integer 		REFERENCES vacancy_body(vacancy_body_id),
	skill_id 							integer 		REFERENCES skill(skill_id)
);

CREATE TABLE contact (
	contact_id 							serial 			PRIMARY KEY,
	contact_name 						varchar(250) 	NOT NULL,
	contact_post 						varchar(250) 	NOT NULL,
	contact_email 						varchar(50),
	contact_phone 						varchar(20) 
);

CREATE TABLE vacancy_body_to_contact (
	vacancy_body_to_contact 			serial 			PRIMARY KEY,
	vacancy_body_id						integer 		REFERENCES vacancy_body(vacancy_body_id),
	contact_id 							integer 		REFERENCES contact(contact_id)
);

CREATE TABLE resume (
	resume_id 							serial 			PRIMARY KEY,
    creation_time 						timestamp 		NOT NULL,
    expire_time 						timestamp 		NOT NULL,

	user_lastname						varchar(250)	NOT NULL,
	user_firstname						varchar(250)	NOT NULL,
	user_middlename						varchar(250),

	user_phone							varchar(20),
	user_email							varchar(50),

    area_id 							integer,

	user_birthdate						date,
	user_sex							boolean			NOT NULL,
	user_citizenship					integer[],

	education_level						integer			NOT NULL,
	no_experience_reason				text,

	for_position						varchar(200)	NOT NULL,
	compensation						bigint,

	description							text			NOT NULL,

    work_schedule_type 					integer,
    employment_type 					integer,
	ready_for_move						boolean,
	owns_car							boolean,
    driver_license_types 				varchar(5)[],
	job_allowance_country_ids			integer[],

	CONSTRAINT education_level_validate 					CHECK ((education_level 	= 	ANY (ARRAY[0, 1, 2, 3, 4, 5, 6, 7]))),
    CONSTRAINT vacancy_body_employment_type_validate 		CHECK ((employment_type 	=	ANY (ARRAY[0, 1, 2, 3, 4]) OR employment_type		= NULL)),
    CONSTRAINT vacancy_body_work_schedule_type_validate 	CHECK ((work_schedule_type 	= 	ANY (ARRAY[0, 1, 2, 3, 4]) OR work_schedule_type	= NULL))
);

CREATE TABLE resume_to_user_citizenship (
	resume_to_user_citizenship_id		serial			PRIMARY KEY,
	resume_id							integer			REFERENCES resume(resume_id),
	country_id							integer			DEFAULT 0
);

CREATE TABLE work_experience (
	work_experience_id					serial			PRIMARY KEY,

	hired_from							date			NOT NULL,
	work_until							date,

	company_name						varchar(250)	NOT NULL,
	position							varchar(250)	NOT NULL,
	obligations							text			NOT NULL
);

CREATE TABLE resume_to_work_experience (
	resume_to_work_experience_id		serial			PRIMARY KEY,
	resume_id							integer			REFERENCES resume(resume_id),
	work_experience_id					integer			REFERENCES work_experience(work_experience_id)
);

CREATE TABLE resume_to_skill (
	resume_to_skill_id 					serial 			PRIMARY KEY,
	resume_id 							integer 		REFERENCES resume(resume_id),
	skill_id 							integer 		REFERENCES skill(skill_id)
);

CREATE TABLE language_skill (
	language_skill_id					serial			PRIMARY KEY,
	language_id							integer			DEFAULT 0,
	skill_level							integer			NOT NULL,

	CONSTRAINT skill_level_validate 	CHECK ((skill_level = 	ANY (ARRAY[0, 1, 2, 3, 4, 5])))
);

CREATE TABLE resume_to_language_skill (
	resume_to_language_skill_id			serial			PRIMARY KEY,
	resume_id							integer			REFERENCES resume(resume_id),
	language_skill_id					integer			REFERENCES language_skill(language_skill_id)
);

CREATE TABLE resume_to_specialization (
	resume_to_specialization_id			serial			PRIMARY KEY,
	resume_id							integer			REFERENCES resume(resume_id),
	specialization_id					integer			REFERENCES specialization(specialization_id)
);

CREATE TABLE response (
	response_id							serial			PRIMARY KEY,
	response_date						timestamp		NOT NULL,
	vacancy_id							integer			REFERENCES vacancy(vacancy_id),
	resume_id							integer			REFERENCES resume(resume_id)
);