
CREATE DATABASE drswik01_CECSProject;
USE drswik01_CECSProject;


CREATE TABLE drswik01_Professor(
`drswik01_faculty-id` SERIAL,
drswik01_name VARCHAR(30) NOT NULL,
drswik01_age INTEGER NOT NULL,
`drswik01_office-building` VARCHAR(30),
`drswik01_office-number` VARCHAR(30),
`drswik01_phone-number` VARCHAR(30),
drswik01_dept VARCHAR(30) NOT NULL);

CREATE TABLE drswik01_Department(
`drswik01_dept-code` CHAR(4) PRIMARY KEY,
drswik01_name VARCHAR(30) NOT NULL,
drswik01_address VARCHAR(30) NOT NULL,
drswik01_school VARCHAR(30) NOT NULL,
drswik01_chair BIGINT UNSIGNED,
FOREIGN KEY (drswik01_chair) REFERENCES drswik01_professor(`drswik01_faculty-id`));

ALTER TABLE drswik01_Professor
ADD FOREIGN KEY (drswik01_dept) REFERENCES drswik01_Department(`drswik01_dept-code`);

CREATE TABLE drswik01_Course(
drswik01_did CHAR(4) NOT NULL,
drswik01_cnumber INTEGER(4) NOT NULL,
drswik01_title VARCHAR(30) NOT NULL,
`drswik01_num-credits` INTEGER NOT NULL,
drswik01_teacher BIGINT UNSIGNED NOT NULL,
PRIMARY KEY(drswik01_did,drswik01_cnumber),
FOREIGN KEY (drswik01_did) REFERENCES drswik01_Department(`drswik01_dept-code`),
FOREIGN KEY (drswik01_teacher) REFERENCES drswik01_Professor(`drswik01_faculty-id`));

CREATE TABLE drswik01_Students(
drswik01_sid SERIAL,
drswik01_name VARCHAR(30) NOT NULL,
drswik01_address VARCHAR(30),
`drswik01_date-of-birth` DATE NOT NULL);

CREATE TABLE drswik01_Enrolls(
drswik01_sid BIGINT UNSIGNED NOT NULL,
drswik01_did CHAR(4) NOT NULL,
drswik01_cnumber INTEGER(4) NOT NULL,
drswik01_semester VARCHAR(6) NOT NULL,
drswik01_year INTEGER NOT NULL,
PRIMARY KEY (drswik01_sid, drswik01_did, drswik01_cnumber, drswik01_semester, drswik01_year),
FOREIGN KEY (drswik01_sid) REFERENCES drswik01_Students(drswik01_sid),
FOREIGN KEY (drswik01_did,drswik01_cnumber) REFERENCES drswik01_Course(drswik01_did,drswik01_cnumber));


#Season Check

CREATE TABLE drswik01_Seasons(drswik01_season VARCHAR(6));
INSERT INTO drswik01_Seasons(drswik01_season) VALUES ("Spring"),("Fall"),("Summer"),("Winter");


DELIMITER $$
CREATE TRIGGER verifySeason 
BEFORE INSERT ON drswik01_Enrolls
FOR EACH ROW
	BEGIN
		IF NOT EXISTS (
			SELECT S.drswik01_season
			FROM drswik01_Seasons S
			WHERE(S.drswik01_season = NEW.drswik01_semester))
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Not valid season';
		END IF;
	END$$
DELIMITER ;



CREATE TABLE drswik01_Grades (
drswik01_sid BIGINT UNSIGNED NOT NULL,
drswik01_did CHAR(4) NOT NULL,
drswik01_cnumber INTEGER(4) NOT NULL,
drswik01_grade CHAR(1) NOT NULL,
PRIMARY KEY (drswik01_sid,drswik01_did,drswik01_cnumber),
FOREIGN KEY (drswik01_sid) REFERENCES drswik01_Students(drswik01_sid),
FOREIGN KEY (drswik01_did,drswik01_cnumber) REFERENCES drswik01_Course(drswik01_did,drswik01_cnumber));

#Verify Grades

CREATE TABLE drswik01_GradesCheck(drswik01_grade CHAR(1));
INSERT INTO drswik01_GradesCheck(drswik01_grade) VALUES ("A"),("B"),("C"),("D"),("F"),("I");


DELIMITER $$
CREATE TRIGGER verifyGrade 
BEFORE INSERT ON drswik01_Grades
FOR EACH ROW
	BEGIN
		IF NOT EXISTS (
			SELECT GC.drswik01_grade
			FROM drswik01_GradesCheck GC
			WHERE(GC.drswik01_grade = NEW.drswik01_grade))
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Not valid Grade';
		END IF;
	END$$
DELIMITER ;

#Verify Student is enrolled

DELIMITER $$
CREATE TRIGGER verifyEnrolled 
BEFORE INSERT ON drswik01_Grades
FOR EACH ROW
	BEGIN
		IF NOT EXISTS (
			SELECT E.drswik01_sid, E.drswik01_did, E.drswik01_cnumber
			FROM drswik01_Enrolls E
			WHERE E.drswik01_sid = NEW.drswik01_sid AND E.drswik01_did = NEW.drswik01_did AND E.drswik01_cnumber = NEW.drswik01_cnumber) 
		THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Student is not enrolled in the class';
		END IF;
	END$$
DELIMITER ;


#Fill in Departments

INSERT INTO drswik01_Department (`drswik01_dept-code`, drswik01_name, drswik01_address, drswik01_school)
VALUES 
("CECS", "Computer Science", "432 Sorting Street", "Engineering"),
("CHEM", "Chemistry", "747 Proton Lane", "Arts and Sciences"),
("PHYS", "Physics", "394 Force Court", "Arts and Sciences"),
("ECON", "Economy", "835 Supply Street", "Arts and Sciences"),
("MATH", "Mathmatics", "532 Derivative Street", "Arts and Sciences");

#Fill in Professors

INSERT INTO drswik01_Professor (drswik01_name, drswik01_age, `drswik01_office-building`, `drswik01_office-number`, `drswik01_phone-number`, drswik01_dept)
VALUES 
("Alan Turing", "23", "JB Speed","327","502-555-4362", "CECS"),
("Neils Bohr", "30", "Duthie","274","502-555-7543", "CHEM"),
("Stephen Hawking", "43", "JB Speed","164","502-555-2634", "PHYS"),
("Adam Smith", "24","JB Speed","451","502-555-3953", "ECON"),
("Euler", "56", "Duthie","245","502-555-6322", "MATH");

#Update Chairs in Department

UPDATE drswik01_Department
SET drswik01_chair = "1"
WHERE `drswik01_dept-code` = "CECS";

UPDATE drswik01_Department
SET drswik01_chair = "2"
WHERE `drswik01_dept-code` = "CHEM";

UPDATE drswik01_Department
SET drswik01_chair = "3"
WHERE `drswik01_dept-code` = "PHYS";

UPDATE drswik01_Department
SET drswik01_chair = "4"
WHERE `drswik01_dept-code` = "ECON";

UPDATE drswik01_Department
SET drswik01_chair = "5"
WHERE `drswik01_dept-code` = "MATH";


#Course

INSERT INTO drswik01_Course (drswik01_did, drswik01_cnumber, drswik01_title, `drswik01_num-credits`, drswik01_teacher)
VALUES 
("CECS","3251", "Intro to Algorithms", "3","1"),
("CHEM","6541", "Chemistry Lab", "1","2"),
("PHYS","2181", "Electromagnitism", "4","3"),
("ECON","8361", "Macroeconomics", "3","4"),
("MATH","9421", "Calculus I", "3","5");

#Students

INSERT INTO drswik01_Students (drswik01_name, drswik01_address, `drswik01_date-of-birth`)
VALUES
("Stephen Burns", "526 Way Lane", "1996-1-12"),
("Gus Sorola", "134 Sea Street", "1996-11-6"),
("Barbara Dunkleman", "462 Fescue Street", "1996-10-20"),
("Jeff Huang", "753 Bourbon Street", "1996-5-14"),
("Shelby Bagley", "3723 Cony Way", "1996-7-9");


#Enrolls

INSERT INTO drswik01_Enrolls (drswik01_sid, drswik01_did, drswik01_cnumber, drswik01_semester, drswik01_year)
VALUES 
("1", "CECS", "3251", "Fall", "2017"),
("1", "PHYS", "2181", "Fall", "2017"),
("2", "ECON", "8361", "Fall", "2017"),
("2", "CHEM", "6541", "Spring", "2017"),
("3", "CHEM", "6541", "Fall", "2017"),
("3", "MATH", "9421", "Fall", "2017"),
("4", "CECS", "3251", "Fall", "2017"),
("4", "ECON", "8361", "Spring", "2017"),
("5", "MATH", "9421", "Fall", "2017"),
("5", "PHYS", "2181", "Fall", "2017");

#GRADES

INSERT INTO drswik01_Grades (drswik01_sid, drswik01_did, drswik01_cnumber, drswik01_grade)
VALUES
("1", "CECS", "3251", "A"),
("1", "PHYS", "2181", "B"),
("2", "ECON", "8361", "I"),
("2", "CHEM", "6541", "D"),
("3", "CHEM", "6541", "C"),
("3", "MATH", "9421", "C"),
("4", "CECS", "3251", "C"),
("4", "ECON", "8361", "A"),
("5", "MATH", "9421", "I"),
("5", "PHYS", "2181", "C");

#Student Performance

CREATE TABLE drswik01_StudentPerformance (
drswik01_sid BIGINT UNSIGNED PRIMARY KEY,
drswik01_gpa DECIMAL(3,2),
FOREIGN KEY (drswik01_sid) REFERENCES drswik01_Students(drswik01_sid));


INSERT INTO drswik01_StudentPerformance (drswik01_sid,drswik01_gpa)
SELECT G.drswik01_sid, GC.gradeCount/CC.classCount
FROM drswik01_grades G, 
( SELECT drswik01_sid AS sid, Count(drswik01_sid) as classCount
FROM drswik01_Grades
GROUP BY drswik01_sid) AS CC,
(
SELECT drswik01_sid AS sid, sum(
CASE 
WHEN drswik01_grade = 'A' THEN '4.0' 
WHEN drswik01_grade = 'B' THEN '3.5' 
WHEN drswik01_grade = 'C' THEN '3.0' 
WHEN drswik01_grade = 'D' THEN '2.5' 
WHEN drswik01_grade = 'F' THEN '1.0' 
ELSE '0'
END
) as gradeCount
FROM drswik01_Grades
GROUP BY drswik01_sid	
) AS GC
WHERE G.drswik01_sid = GC.sid AND G.drswik01_sid = CC.sid
GROUP BY G.drswik01_sid;

DELIMITER $$
CREATE TRIGGER newPerformance AFTER INSERT ON drswik01_Grades
FOR EACH ROW
	BEGIN
		IF NOT EXISTS(
			SELECT SP.drswik01_sid
			FROM drswik01_StudentPerformance SP
			WHERE(SP.drswik01_sid = NEW.drswik01_sid))
		THEN INSERT INTO drswik01_StudentPerformance (drswik01_sid,drswik01_gpa)
			SELECT G.drswik01_sid, GC.gradeCount/CC.classCount
			FROM drswik01_grades G, 
			( SELECT drswik01_sid AS sid, Count(drswik01_sid) as classCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid) AS CC,
			(
			SELECT drswik01_sid AS sid, sum(
			CASE 
			WHEN drswik01_grade = 'A' THEN '4.0' 
			WHEN drswik01_grade = 'B' THEN '3.5' 
			WHEN drswik01_grade = 'C' THEN '3.0' 
			WHEN drswik01_grade = 'D' THEN '2.5' 
			WHEN drswik01_grade = 'F' THEN '1.0' 
			ELSE '0'
			END
			) as gradeCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid	
			) AS GC
			WHERE G.drswik01_sid = GC.sid AND G.drswik01_sid = CC.sid AND G.drswik01_sid = NEW.drswik01_sid
			GROUP BY G.drswik01_sid;
		ELSE 
			UPDATE drswik01_StudentPerformance 
				SET drswik01_gpa = 
			(SELECT DISTINCT GC.gradeCount/CC.classCount
			FROM drswik01_grades G, 
			( SELECT drswik01_sid AS sid, Count(drswik01_sid) as classCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid) AS CC,
			(
			SELECT drswik01_sid AS sid, sum(
			CASE 
			WHEN drswik01_grade = 'A' THEN '4.0' 
			WHEN drswik01_grade = 'B' THEN '3.5' 
			WHEN drswik01_grade = 'C' THEN '3.0' 
			WHEN drswik01_grade = 'D' THEN '2.5' 
			WHEN drswik01_grade = 'F' THEN '1.0' 
			ELSE '0'
			END
			) as gradeCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid	
			) AS GC
			WHERE G.drswik01_sid = GC.sid AND G.drswik01_sid = CC.sid AND G.drswik01_sid = NEW.drswik01_sid
			GROUP BY drswik01_sid)
			WHERE drswik01_sid = NEW.drswik01_sid;
		END IF;
	END$$

DELIMITER ;

DELIMITER $$
CREATE TRIGGER updatePerformance AFTER UPDATE ON drswik01_Grades
FOR EACH ROW
	BEGIN
			UPDATE drswik01_StudentPerformance 
				SET drswik01_gpa = 
			(SELECT DISTINCT GC.gradeCount/CC.classCount
			FROM drswik01_grades G, 
			( SELECT drswik01_sid AS sid, Count(drswik01_sid) as classCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid) AS CC,
			(
			SELECT drswik01_sid AS sid, sum(
			CASE 
			WHEN drswik01_grade = 'A' THEN '4.0' 
			WHEN drswik01_grade = 'B' THEN '3.5' 
			WHEN drswik01_grade = 'C' THEN '3.0' 
			WHEN drswik01_grade = 'D' THEN '2.5' 
			WHEN drswik01_grade = 'F' THEN '1.0' 
			ELSE '0'
			END
			) as gradeCount
			FROM drswik01_Grades
			GROUP BY drswik01_sid	
			) AS GC
			WHERE G.drswik01_sid = GC.sid AND G.drswik01_sid = CC.sid AND G.drswik01_sid = NEW.drswik01_sid
			GROUP BY drswik01_sid)
			WHERE drswik01_sid = NEW.drswik01_sid;
	END$$
DELIMITER ;	

DELIMITER ;	
