-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it


-- Create the database
CREATE DATABASE IF NOT EXISTS application_tracker;

-- Select the database
USE application_tracker;


-- Create the user table
CREATE TABLE `USER` (
    user_id INT AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE (email)
);


-- Create the company table
CREATE TABLE COMPANY (
    comp_id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    location VARCHAR(100),
    website VARCHAR(255),

    PRIMARY KEY (comp_id)
);


-- Create the application table
CREATE TABLE APPLICATION (
    app_id INT AUTO_INCREMENT,
    user_id INT NOT NULL,
    comp_id INT NOT NULL,
    position VARCHAR(100) NOT NULL,
    job VARCHAR(100),
    status ENUM('Applied', 'Interview', 'Accepted', 'Rejected', 'Withdrawn') NOT NULL DEFAULT 'Applied',
    app_date DATE DEFAULT CURRENT_TIMESTAMP,
    deadline DATE,
    note TEXT,

    PRIMARY KEY (app_id),
    FOREIGN KEY (user_id) REFERENCES `USER`(user_id) ON DELETE CASCADE,
    FOREIGN KEY (comp_id) REFERENCES COMPANY(comp_id) ON DELETE CASCADE
);


-- Create the contact table
CREATE TABLE CONTACT (
    contact_id INT AUTO_INCREMENT,
    comp_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(30),

    PRIMARY KEY (contact_id),
    FOREIGN KEY (comp_id) REFERENCES COMPANY(comp_id) ON DELETE CASCADE
);


-- Create the involves table
CREATE TABLE APPLICATION_CONTACT(
    app_id INT,
    contact_id INT,

    PRIMARY KEY (app_id, contact_id),
    FOREIGN KEY (app_id) REFERENCES APPLICATION(app_id) ON DELETE CASCADE,
    FOREIGN KEY (contact_id) REFERENCES CONTACT(contact_id) ON DELETE CASCADE
);


-- Create the interview table
CREATE TABLE INTERVIEW (
    int_id INT AUTO_INCREMENT,
    app_id INT NOT NULL,
    int_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    `type` VARCHAR(50),
    location VARCHAR(100),
    result VARCHAR(100),
    note TEXT,

    PRIMARY KEY (int_id),
    FOREIGN KEY (app_id) REFERENCES APPLICATION(app_id) ON DELETE CASCADE
);


-- Create the app_history table
CREATE TABLE APP_HISTORY (
    app_id INT,
    history_id INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (app_id, history_id),
    FOREIGN KEY (app_id) REFERENCES APPLICATION(app_id) ON DELETE CASCADE
);


-- Create an index for application status
CREATE INDEX idx_application_status
ON APPLICATION(status);


-- Create a view for application status summary
CREATE VIEW status_summary AS
SELECT
    status,
    COUNT(*) AS total_applications
FROM APPLICATION
GROUP BY status;

-- Create a view for application details
CREATE VIEW application_details AS
SELECT
    APPLICATION.app_id,
    APPLICATION.position,
    APPLICATION.status,
    COMPANY.name AS company_name
FROM APPLICATION
JOIN COMPANY
    ON APPLICATION.comp_id = COMPANY.comp_id;


-- Create a view for user applications
CREATE VIEW user_application AS
SELECT
    `USER`.full_name,
    APPLICATION.position,
    APPLICATION.status,
    COMPANY.name AS company_name
FROM `USER`
JOIN APPLICATION
    ON `USER`.user_id = APPLICATION.user_id
JOIN COMPANY
    ON APPLICATION.comp_id = COMPANY.comp_id;


-- Create a view for upcoming deadlines
CREATE VIEW upcoming_deadlines AS
SELECT
    APPLICATION.app_id,
    APPLICATION.position,
    COMPANY.name AS company_name,
    APPLICATION.deadline,
    APPLICATION.status
FROM APPLICATION
JOIN COMPANY
    ON APPLICATION.comp_id = COMPANY.comp_id
WHERE APPLICATION.deadline >= CURDATE()
AND APPLICATION.status IN ('Applied', 'Interview');

-- Create a view for application contacts
CREATE VIEW application_contacts AS
SELECT
    APPLICATION_CONTACT.app_id,
    CONTACT.contact_id,
    CONTACT.name,
    CONTACT.role,
    CONTACT.email,
    CONTACT.phone
FROM CONTACT
JOIN APPLICATION_CONTACT
    ON CONTACT.contact_id = APPLICATION_CONTACT.contact_id;


-- Create a trigger for application status changes
DELIMITER //

CREATE TRIGGER after_application_status_update
AFTER UPDATE ON APPLICATION
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN

        INSERT INTO APP_HISTORY (
            app_id,
            history_id,
            old_status,
            new_status,
            changed_at
        )
        VALUES (
            NEW.app_id,
            (SELECT COALESCE(MAX(history_id), 0) + 1
             FROM APP_HISTORY AS history
             WHERE history.app_id = NEW.app_id),
            OLD.status,
            NEW.status,
            CURRENT_TIMESTAMP
        );

    END IF;
END //

DELIMITER ;
