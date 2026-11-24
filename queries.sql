-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- 1. Display all applications
SELECT *
FROM APPLICATION;


-- 2. Display all applications of a specific user
SELECT *
FROM APPLICATION
WHERE user_id = 1;


-- 3. Display application details using the application_details view
SELECT *
FROM application_details;


-- 4. Display applications of a specific user using the user_application view
SELECT *
FROM user_application
WHERE full_name = 'John Smith';


-- 5. Display the total number of applications for each status
SELECT *
FROM status_summary;


-- 6. Display all upcoming deadlines using the upcoming_deadlines view
SELECT *
FROM upcoming_deadlines
ORDER BY deadline ASC;


-- 7. Display contacts associated with a specific application
SELECT *
FROM application_contacts
WHERE app_id = 1;


-- 8. Search for applications by position
SELECT *
FROM APPLICATION
WHERE position LIKE '%Software Engineer%';


-- 9. Filter applications by status
SELECT *
FROM APPLICATION
WHERE status = 'Interview';


-- 10. Add a new application
INSERT INTO APPLICATION (
    user_id,
    comp_id,
    position,
    job,
    status,
    app_date,
    deadline,
    note
)
VALUES (
    1,
    1,
    'Software Engineer Intern',
    'Internship',
    'Applied',
    CURDATE(),
    '2026-12-01',
    'Applied through the company website'
);


-- 11. Update the status of an application
-- The trigger automatically saves the status change in APP_HISTORY
UPDATE APPLICATION
SET status = 'Interview'
WHERE app_id = 1;


-- 12. Display the status history of an application
SELECT *
FROM APP_HISTORY
WHERE app_id = 1
ORDER BY history_id ASC;


-- 13. Schedule a new interview
INSERT INTO INTERVIEW (
    app_id,
    int_date,
    `type`,
    location
)
VALUES (
    1,
    '2026-11-25 10:00:00',
    'Technical',
    'Online'
);


-- 14. Display all interviews of an application
SELECT *
FROM INTERVIEW
WHERE app_id = 1
ORDER BY int_date ASC;


-- 15. Add a new company
INSERT INTO COMPANY (
    name,
    industry,
    location,
    website
)
VALUES (
    'Google',
    'Technology',
    'USA',
    'https://www.google.com'
);


-- 16. Display all companies
SELECT *
FROM COMPANY;


-- 17. Display the total number of applications for each company
SELECT
    COMPANY.name AS company_name,
    COUNT(APPLICATION.app_id) AS total_applications
FROM COMPANY
LEFT JOIN APPLICATION
    ON COMPANY.comp_id = APPLICATION.comp_id
GROUP BY COMPANY.comp_id, COMPANY.name;


-- 18. Add a contact to an application
INSERT INTO APPLICATION_CONTACT (app_id, contact_id)
VALUES (1, 1);


-- 19. Delete an application
DELETE FROM APPLICATION
WHERE app_id = 1;


-- 20. Delete a company
DELETE FROM COMPANY
WHERE comp_id = 1;
