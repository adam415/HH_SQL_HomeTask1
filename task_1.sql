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
	company_image_url 					varchar(30) 	NOT NULL
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
	
    work_experience 					integer 		NOT NULL 	DEFAULT 0,
    work_schedule_type 					integer 		NOT NULL 	DEFAULT 0,
    employment_type 					integer 		NOT NULL 	DEFAULT 0,
	
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