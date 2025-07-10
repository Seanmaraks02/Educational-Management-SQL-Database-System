
-- =============================================
-- CLEANUP EXISTING OBJECTS
-- =============================================
BEGIN EXECUTE IMMEDIATE 'DROP TABLE CourseModules CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Enrollments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Submissions CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Assignments CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Quizzes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Projects CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Modules CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Courses CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Students CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Instructors CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Admins CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Submission_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Enrollment_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE CourseModule_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Course_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Project_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Quiz_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Assignment_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Module_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE LearningObjectiveList_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE LearningObjective_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Student_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Instructor_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE Admin_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE User_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE PrivilegesList_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE NumberList_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TYPE TechnologyList_t FORCE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE user_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE course_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE module_seq'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- =============================================
-- TYPE DEFINITIONS
-- =============================================

-- Sequences for unique IDs
CREATE SEQUENCE user_seq START WITH 10 INCREMENT BY 1;
CREATE SEQUENCE course_seq START WITH 604 INCREMENT BY 1;
CREATE SEQUENCE module_seq START WITH 506 INCREMENT BY 1;

-- Base User type
CREATE TYPE User_t AS OBJECT (
    id INTEGER,
    name VARCHAR2(100),
    email VARCHAR2(100),
    registrationDate DATE,
    createdAt TIMESTAMP
) NOT FINAL;
/

-- Nested table for privileges
CREATE TYPE PrivilegesList_t AS TABLE OF VARCHAR2(100);
/

-- Admin type inheriting from User_t
CREATE TYPE Admin_t UNDER User_t (
    privileges PrivilegesList_t
);
/

-- Nested table for course IDs
CREATE TYPE NumberList_t AS TABLE OF NUMBER;
/

-- Instructor type inheriting from User_t
CREATE TYPE Instructor_t UNDER User_t (
    department VARCHAR2(100),
    office VARCHAR2(100),
    courses_taught NumberList_t
);
/

-- Student type inheriting from User_t
CREATE TYPE Student_t UNDER User_t (
    major VARCHAR2(100),
    enrollmentYear INTEGER
);
/

-- Learning Objective type
CREATE TYPE LearningObjective_t AS OBJECT (
    objective_id INTEGER,
    description VARCHAR2(500),
    difficulty_level VARCHAR2(20)
);
/

-- Nested table for learning objectives
CREATE TYPE LearningObjectiveList_t AS TABLE OF LearningObjective_t;
/

-- Module type
CREATE TYPE Module_t AS OBJECT (
    moduleId INTEGER,
    title VARCHAR2(200),
    content CLOB,
    objectives LearningObjectiveList_t
);
/

-- Nested table for technologies
CREATE TYPE TechnologyList_t AS TABLE OF VARCHAR2(100);
/

-- Assignment type
CREATE TYPE Assignment_t AS OBJECT (
    assignmentId INTEGER,
    title VARCHAR2(200),
    description VARCHAR2(1000),
    deadline DATE,
    maxScore INTEGER,
    courseId INTEGER
);
/

-- Quiz type
CREATE TYPE Quiz_t AS OBJECT (
    quizId INTEGER,
    assignmentId INTEGER,
    timeLimit INTERVAL DAY TO SECOND,
    questionCount INTEGER
);
/

-- Project type
CREATE TYPE Project_t AS OBJECT (
    projectId INTEGER,
    assignmentId INTEGER,
    groupSize INTEGER,
    technologies TechnologyList_t
);
/

-- Course type
CREATE TYPE Course_t AS OBJECT (
    courseId INTEGER,
    title VARCHAR2(200),
    description VARCHAR2(1000),
    startDate DATE,
    endDate DATE,
    totalScore INTEGER,
    instructor REF Instructor_t
);
/

-- CourseModule type for linking courses and modules
CREATE TYPE CourseModule_t AS OBJECT (
    courseId INTEGER,
    moduleId INTEGER,
    sequenceNumber INTEGER
);
/

-- Enrollment type
CREATE TYPE Enrollment_t AS OBJECT (
    studentId INTEGER,
    courseId INTEGER,
    enrollmentDate DATE,
    completionDate DATE,
    status VARCHAR2(20)
);
/

-- Submission type
CREATE TYPE Submission_t AS OBJECT (
    submissionId INTEGER,
    assignmentId INTEGER,
    studentId INTEGER,
    submittedDate TIMESTAMP WITH TIME ZONE,
    score NUMBER,
    feedback VARCHAR2(1000),
    content CLOB,
    MEMBER FUNCTION requestFeedback RETURN VARCHAR2
);
/

CREATE TYPE BODY Submission_t AS
    MEMBER FUNCTION requestFeedback RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Feedback requested for submission ' || self.submissionId || ' by student ' || self.studentId;
    END;
END;
/

-- =============================================
-- OBJECT TABLE DEFINITIONS
-- =============================================

-- Object table for Admins
CREATE TABLE Admins OF Admin_t (
    id CONSTRAINT pk_admins_id PRIMARY KEY
) NESTED TABLE privileges STORE AS admin_privs_nt;

-- Object table for Instructors
CREATE TABLE Instructors OF Instructor_t (
    id PRIMARY KEY
) NESTED TABLE courses_taught STORE AS instructor_courses_nt;

-- Object table for Students
CREATE TABLE Students OF Student_t (
    id PRIMARY KEY
);

-- Object table for Modules
CREATE TABLE Modules OF Module_t (
    moduleId PRIMARY KEY
) NESTED TABLE objectives STORE AS module_objectives_nt;

-- Object table for Assignments
CREATE TABLE Assignments OF Assignment_t (
    assignmentId PRIMARY KEY
);

-- Object table for Quizzes
CREATE TABLE Quizzes OF Quiz_t (
    quizId PRIMARY KEY,
    CONSTRAINT fk_quizzes_assignment FOREIGN KEY (assignmentId) REFERENCES Assignments(assignmentId)
);

-- Object table for Projects
CREATE TABLE Projects OF Project_t (
    projectId PRIMARY KEY,
    CONSTRAINT fk_projects_assignment FOREIGN KEY (assignmentId) REFERENCES Assignments(assignmentId)
) NESTED TABLE technologies STORE AS project_tech_nt;

-- Object table for Courses
CREATE TABLE Courses OF Course_t (
    courseId PRIMARY KEY,
    instructor SCOPE IS Instructors
);

-- Object table for CourseModules
CREATE TABLE CourseModules OF CourseModule_t (
    courseId NOT NULL,
    moduleId NOT NULL,
    PRIMARY KEY (courseId, moduleId),
    CONSTRAINT fk_coursemodules_course FOREIGN KEY (courseId) REFERENCES Courses(courseId),
    CONSTRAINT fk_coursemodules_module FOREIGN KEY (moduleId) REFERENCES Modules(moduleId)
);

-- Object table for Enrollments
CREATE TABLE Enrollments OF Enrollment_t (
    studentId NOT NULL,
    courseId NOT NULL,
    PRIMARY KEY (studentId, courseId),
    CONSTRAINT fk_enrollments_student FOREIGN KEY (studentId) REFERENCES Students(id),
    CONSTRAINT fk_enrollments_course FOREIGN KEY (courseId) REFERENCES Courses(courseId)
);

-- Object table for Submissions
CREATE TABLE Submissions OF Submission_t (
    submissionId PRIMARY KEY,
    CONSTRAINT fk_submissions_assignment FOREIGN KEY (assignmentId) REFERENCES Assignments(assignmentId),
    CONSTRAINT fk_submissions_student FOREIGN KEY (studentId) REFERENCES Students(id)
);

-- =============================================
-- TRIGGERS
-- =============================================

-- Trigger to ensure only Instructors are assigned to Courses
CREATE OR REPLACE TRIGGER trg_course_instructor_type
BEFORE INSERT OR UPDATE OF instructor ON Courses
FOR EACH ROW
DECLARE
    v_instr Instructor_t;
BEGIN
    IF :NEW.instructor IS NOT NULL THEN
        SELECT DEREF(:NEW.instructor) INTO v_instr FROM dual;
        IF v_instr IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Only Instructors can be assigned to a Course.');
        END IF;
    END IF;
END;
/

-- Trigger to validate enrollment dates
CREATE OR REPLACE TRIGGER trg_enrollment_before_end
BEFORE INSERT OR UPDATE ON Enrollments
FOR EACH ROW
DECLARE
    v_endDate DATE;
BEGIN
    SELECT endDate INTO v_endDate FROM Courses WHERE courseId = :NEW.courseId;
    IF :NEW.enrollmentDate > v_endDate THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cannot enroll after the course end date.');
    END IF;

    IF :NEW.completionDate IS NOT NULL AND :NEW.completionDate < :NEW.enrollmentDate THEN
        RAISE_APPLICATION_ERROR(-20003, 'Completion date cannot be before enrollment date.');
    END IF;
END;
/

-- Trigger to update Instructor's courses_taught
CREATE OR REPLACE TRIGGER trg_instructor_course_assignment
AFTER INSERT OR UPDATE OF instructor ON Courses
FOR EACH ROW
DECLARE
    v_instr Instructor_t;
BEGIN
    IF :NEW.instructor IS NOT NULL THEN
        SELECT DEREF(:NEW.instructor) INTO v_instr FROM dual;
        IF v_instr.courses_taught IS NULL THEN
            UPDATE Instructors i
            SET i.courses_taught = NumberList_t(:NEW.courseId)
            WHERE REF(i) = :NEW.instructor;
        ELSE
            UPDATE Instructors i
            SET i.courses_taught = v_instr.courses_taught MULTISET UNION DISTINCT NumberList_t(:NEW.courseId)
            WHERE REF(i) = :NEW.instructor;
        END IF;
    END IF;
END;
/

-- =============================================
-- SECTION 5: STORED PROCEDURES AND FUNCTIONS
-- =============================================

CREATE OR REPLACE PROCEDURE get_student_progress(
    p_student_id IN NUMBER,
    p_course_id IN NUMBER DEFAULT NULL
) IS
    CURSOR c_progress IS
        SELECT c.courseId, c.title AS course_title,
               m.title AS module_title,
               a.title AS assignment_title,
               s.score, a.maxScore,
               s.submittedDate
        FROM Students st
        JOIN Enrollments e ON st.id = e.studentId
        JOIN Courses c ON e.courseId = c.courseId
        LEFT JOIN CourseModules cm ON c.courseId = cm.courseId
        LEFT JOIN Modules m ON cm.moduleId = m.moduleId
        LEFT JOIN Assignments a ON a.courseId = c.courseId
        LEFT JOIN Submissions s ON s.assignmentId = a.assignmentId AND s.studentId = st.id
        WHERE st.id = p_student_id
        AND (p_course_id IS NULL OR c.courseId = p_course_id)
        ORDER BY c.courseId, cm.sequenceNumber, a.deadline;
    v_course_id NUMBER := -1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Student Progress Report');
    DBMS_OUTPUT.PUT_LINE('-----------------------');

    FOR rec IN c_progress LOOP
        IF rec.courseId != v_course_id THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || 'COURSE: ' || rec.course_title || ' (ID: ' || rec.courseId || ')');
            v_course_id := rec.courseId;
        END IF;

        IF rec.module_title IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('  Module: ' || rec.module_title);
        END IF;

        IF rec.assignment_title IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('    Assignment: ' || rec.assignment_title || ' - Score: ' || NVL(TO_CHAR(rec.score), 'Not submitted') || '/' || rec.maxScore ||
                                 ' (Submitted: ' || CASE WHEN rec.submittedDate IS NULL THEN 'No' ELSE TO_CHAR(rec.submittedDate, 'DD-MON-YYYY') END || ')');
        END IF;
    END LOOP;
END;
/

CREATE OR REPLACE FUNCTION get_course_stats(
    p_course_id IN NUMBER DEFAULT NULL
) RETURN SYS_REFCURSOR IS
    v_result SYS_REFCURSOR;
BEGIN
    OPEN v_result FOR
        SELECT
            CASE GROUPING(c.courseId) WHEN 1 THEN 'All Courses' ELSE TO_CHAR(c.courseId) END AS course_id,
            CASE GROUPING(c.title) WHEN 1 THEN 'All Titles' ELSE c.title END AS course_title,
            CASE GROUPING(st.major) WHEN 1 THEN 'All Majors' ELSE st.major END AS student_major,
            COUNT(DISTINCT e.studentId) AS student_count,
            AVG(s.score) AS avg_score,
            MAX(s.score) AS max_score,
            MIN(s.score) AS min_score
        FROM Courses c
        LEFT JOIN Enrollments e ON c.courseId = e.courseId
        LEFT JOIN Students st ON e.studentId = st.id
        LEFT JOIN Submissions s ON s.studentId = st.id
        LEFT JOIN Assignments a ON s.assignmentId = a.assignmentId AND a.courseId = c.courseId
        WHERE p_course_id IS NULL OR c.courseId = p_course_id
        GROUP BY ROLLUP(c.courseId, c.title), st.major
        ORDER BY GROUPING(c.courseId), c.courseId, GROUPING(st.major), st.major;

    RETURN v_result;
END;
/

-- Stored Function: Determines submission status based on timestamp and deadline
CREATE OR REPLACE FUNCTION get_submission_status(
    p_submitted_date IN TIMESTAMP WITH TIME ZONE,
    p_deadline IN DATE
) RETURN VARCHAR2 AS
    v_days_late NUMBER;
    v_interval INTERVAL DAY TO SECOND;
BEGIN
    IF p_submitted_date IS NULL OR p_deadline IS NULL THEN
        RETURN 'NOT_SUBMITTED';
    END IF;
    
    v_interval := p_submitted_date - CAST(p_deadline AS TIMESTAMP);
    v_days_late := EXTRACT(DAY FROM v_interval);
    
    IF v_days_late < 0 THEN
        RETURN 'EARLY';
    ELSIF v_days_late = 0 THEN
        RETURN 'ON_TIME';
    ELSE
        RETURN 'LATE_BY_' || v_days_late || '_DAYS';
    END IF;
END;
/



-- =============================================
-- Sample Data 
-- =============================================

-- 1. Admins (10 rows)
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Alice Smith', 'alice.smith@university.edu', SYSDATE - 365, SYSTIMESTAMP, PrivilegesList_t('MANAGE_USERS', 'APPROVE_COURSES')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Bob Johnson', 'bob.johnson@university.edu', SYSDATE - 300, SYSTIMESTAMP, PrivilegesList_t('MANAGE_COURSES', 'VIEW_REPORTS')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Carol White', 'carol.white@university.edu', SYSDATE - 200, SYSTIMESTAMP, PrivilegesList_t('MANAGE_USERS', 'EDIT_CONTENT')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'David Brown', 'david.brown@university.edu', SYSDATE - 150, SYSTIMESTAMP, PrivilegesList_t('APPROVE_COURSES', 'VIEW_REPORTS')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Emma Davis', 'emma.davis@university.edu', SYSDATE - 100, SYSTIMESTAMP, PrivilegesList_t('MANAGE_USERS', 'EDIT_CONTENT')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Frank Wilson', 'frank.wilson@university.edu', SYSDATE - 90, SYSTIMESTAMP, PrivilegesList_t('VIEW_REPORTS')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Grace Lee', 'grace.lee@university.edu', SYSDATE - 80, SYSTIMESTAMP, PrivilegesList_t('MANAGE_COURSES')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Henry Moore', 'henry.moore@university.edu', SYSDATE - 70, SYSTIMESTAMP, PrivilegesList_t('EDIT_CONTENT')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'Isabella Taylor', 'isabella.taylor@university.edu', SYSDATE - 60, SYSTIMESTAMP, PrivilegesList_t('MANAGE_USERS')));
INSERT INTO Admins VALUES (Admin_t(user_seq.NEXTVAL, 'James Anderson', 'james.anderson@university.edu', SYSDATE - 50, SYSTIMESTAMP, PrivilegesList_t('APPROVE_COURSES')));

-- 2. Instructors (10 rows)
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Evans', 'evans@university.edu', SYSDATE - 400, SYSTIMESTAMP, 'Computer Science', 'Room 101', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Clark', 'clark@university.edu', SYSDATE - 350, SYSTIMESTAMP, 'Mathematics', 'Room 102', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Lewis', 'lewis@university.edu', SYSDATE - 300, SYSTIMESTAMP, 'Physics', 'Room 103', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Walker', 'walker@university.edu', SYSDATE - 250, SYSTIMESTAMP, 'Computer Science', 'Room 104', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Hall', 'hall@university.edu', SYSDATE - 200, SYSTIMESTAMP, 'Mathematics', 'Room 105', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Allen', 'allen@university.edu', SYSDATE - 150, SYSTIMESTAMP, 'Physics', 'Room 106', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Young', 'young@university.edu', SYSDATE - 100, SYSTIMESTAMP, 'Computer Science', 'Room 107', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. King', 'king@university.edu', SYSDATE - 90, SYSTIMESTAMP, 'Mathematics', 'Room 108', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Wright', 'wright@university.edu', SYSDATE - 80, SYSTIMESTAMP, 'Physics', 'Room 109', NumberList_t()));
INSERT INTO Instructors VALUES (Instructor_t(user_seq.NEXTVAL, 'Dr. Scott', 'scott@university.edu', SYSDATE - 70, SYSTIMESTAMP, 'Computer Science', 'Room 110', NumberList_t()));

-- 3. Students (10 rows)
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'John Doe', 'john.doe@university.edu', SYSDATE - 365, SYSTIMESTAMP, 'Computer Science', 2023));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Jane Roe', 'jane.roe@university.edu', SYSDATE - 360, SYSTIMESTAMP, 'Mathematics', 2023));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Mike Brown', 'mike.brown@university.edu', SYSDATE - 350, SYSTIMESTAMP, 'Physics', 2024));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Sarah Green', 'sarah.green@university.edu', SYSDATE - 340, SYSTIMESTAMP, 'Computer Science', 2023));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Tom White', 'tom.white@university.edu', SYSDATE - 330, SYSTIMESTAMP, 'Mathematics', 2024));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Lisa Black', 'lisa.black@university.edu', SYSDATE - 320, SYSTIMESTAMP, 'Physics', 2023));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'James Blue', 'james.blue@university.edu', SYSDATE - 310, SYSTIMESTAMP, 'Computer Science', 2024));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Emma Red', 'emma.red@university.edu', SYSDATE - 300, SYSTIMESTAMP, 'Mathematics', 2023));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'David Gray', 'david.gray@university.edu', SYSDATE - 290, SYSTIMESTAMP, 'Physics', 2024));
INSERT INTO Students VALUES (Student_t(user_seq.NEXTVAL, 'Anna Yellow', 'anna.yellow@university.edu', SYSDATE - 280, SYSTIMESTAMP, 'Computer Science', 2023));

-- 4. Modules (10 rows)
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'SQL Basics', 'Introduction to SQL queries', LearningObjectiveList_t(LearningObjective_t(1, 'Write basic SQL queries', 'Beginner'), LearningObjective_t(2, 'Understand joins', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Database Design', 'Database normalization and ERD', LearningObjectiveList_t(LearningObjective_t(3, 'Design ER diagrams', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Calculus I', 'Limits and derivatives', LearningObjectiveList_t(LearningObjective_t(4, 'Compute limits', 'Beginner'), LearningObjective_t(5, 'Apply derivatives', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Linear Algebra', 'Matrices and vectors', LearningObjectiveList_t(LearningObjective_t(6, 'Solve linear systems', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Mechanics', 'Newton’s laws', LearningObjectiveList_t(LearningObjective_t(7, 'Apply Newton’s laws', 'Beginner'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Programming Basics', 'Introduction to Python', LearningObjectiveList_t(LearningObjective_t(8, 'Write Python functions', 'Beginner'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Data Structures', 'Stacks and queues', LearningObjectiveList_t(LearningObjective_t(9, 'Implement data structures', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Probability', 'Basic probability concepts', LearningObjectiveList_t(LearningObjective_t(10, 'Calculate probabilities', 'Beginner'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Electromagnetism', 'Electric fields', LearningObjectiveList_t(LearningObjective_t(11, 'Understand electric fields', 'Intermediate'))));
INSERT INTO Modules VALUES (Module_t(module_seq.NEXTVAL, 'Algorithms', 'Sorting and searching', LearningObjectiveList_t(LearningObjective_t(12, 'Analyze algorithm complexity', 'Advanced'))));

-- 5. Courses (10 rows)
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Database Systems', 'Intro to databases', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 20)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Calculus I', 'Limits and derivatives', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 21)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Physics I', 'Mechanics and motion', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 22)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Programming I', 'Intro to programming', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 23)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Linear Algebra', 'Matrix operations', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 24)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Data Structures', 'Advanced programming', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 25)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Probability', 'Probability theory', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 26)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Electromagnetism', 'Electric and magnetic fields', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 27)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Algorithms', 'Algorithm design', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 28)));
INSERT INTO Courses VALUES (Course_t(course_seq.NEXTVAL, 'Advanced Databases', 'Advanced DB concepts', SYSDATE, SYSDATE + 90, 100, (SELECT REF(i) FROM Instructors i WHERE i.id = 29)));

-- 6. Assignments (10 rows)
INSERT INTO Assignments VALUES (Assignment_t(1, 'SQL Query Assignment', 'Write 5 SQL queries', SYSDATE + 7, 100, 604));
INSERT INTO Assignments VALUES (Assignment_t(2, 'ER Diagram', 'Design an ERD', SYSDATE + 14, 100, 604));
INSERT INTO Assignments VALUES (Assignment_t(3, 'Calculus Problem Set', 'Solve derivatives', SYSDATE + 7, 100, 605));
INSERT INTO Assignments VALUES (Assignment_t(4, 'Matrix Operations', 'Matrix calculations', SYSDATE + 10, 100, 608));
INSERT INTO Assignments VALUES (Assignment_t(5, 'Mechanics Lab', 'Newton’s laws experiment', SYSDATE + 7, 100, 606));
INSERT INTO Assignments VALUES (Assignment_t(6, 'Python Functions', 'Write Python functions', SYSDATE + 7, 100, 607));
INSERT INTO Assignments VALUES (Assignment_t(7, 'Stack Implementation', 'Implement a stack', SYSDATE + 14, 100, 609));
INSERT INTO Assignments VALUES (Assignment_t(8, 'Probability Problems', 'Solve probability questions', SYSDATE + 7, 100, 610));
INSERT INTO Assignments VALUES (Assignment_t(9, 'Electric Field Analysis', 'Analyze electric fields', SYSDATE + 10, 100, 611));
INSERT INTO Assignments VALUES (Assignment_t(10, 'Sorting Algorithms', 'Implement sorting algorithms', SYSDATE + 14, 100, 612));


-- 7. Quizzes (10 rows)
INSERT INTO Quizzes VALUES (Quiz_t(1, 1, INTERVAL '0 01:00:00' DAY TO SECOND, 10));
INSERT INTO Quizzes VALUES (Quiz_t(2, 2, INTERVAL '0 00:30:00' DAY TO SECOND, 5));
INSERT INTO Quizzes VALUES (Quiz_t(3, 3, INTERVAL '0 01:00:00' DAY TO SECOND, 15));
INSERT INTO Quizzes VALUES (Quiz_t(4, 4, INTERVAL '0 00:45:00' DAY TO SECOND, 8));
INSERT INTO Quizzes VALUES (Quiz_t(5, 5, INTERVAL '0 01:00:00' DAY TO SECOND, 10));
INSERT INTO Quizzes VALUES (Quiz_t(6, 6, INTERVAL '0 00:30:00' DAY TO SECOND, 5));
INSERT INTO Quizzes VALUES (Quiz_t(7, 7, INTERVAL '0 01:00:00' DAY TO SECOND, 10));
INSERT INTO Quizzes VALUES (Quiz_t(8, 8, INTERVAL '0 00:45:00' DAY TO SECOND, 8));
INSERT INTO Quizzes VALUES (Quiz_t(9, 9, INTERVAL '0 01:00:00' DAY TO SECOND, 10));
INSERT INTO Quizzes VALUES (Quiz_t(10, 10, INTERVAL '0 00:30:00' DAY TO SECOND, 5));

-- 8. Projects (10 rows)
INSERT INTO Projects VALUES (Project_t(1, 1, 3, TechnologyList_t('SQL', 'Oracle')));
INSERT INTO Projects VALUES (Project_t(2, 2, 2, TechnologyList_t('SQL', 'MySQL')));
INSERT INTO Projects VALUES (Project_t(3, 3, 4, TechnologyList_t('MATLAB')));
INSERT INTO Projects VALUES (Project_t(4, 4, 3, TechnologyList_t('MATLAB', 'Python')));
INSERT INTO Projects VALUES (Project_t(5, 5, 2, TechnologyList_t('LabVIEW')));
INSERT INTO Projects VALUES (Project_t(6, 6, 3, TechnologyList_t('Python', 'Jupyter')));
INSERT INTO Projects VALUES (Project_t(7, 7, 4, TechnologyList_t('Python', 'C++')));
INSERT INTO Projects VALUES (Project_t(8, 8, 2, TechnologyList_t('R', 'Python')));
INSERT INTO Projects VALUES (Project_t(9, 9, 3, TechnologyList_t('MATLAB', 'Simulink')));
INSERT INTO Projects VALUES (Project_t(10, 10, 4, TechnologyList_t('Python', 'Java')));

-- 9. CourseModules (10 rows)
INSERT INTO CourseModules VALUES (CourseModule_t(604, 506, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(604, 507, 2));
INSERT INTO CourseModules VALUES (CourseModule_t(605, 508, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(608, 509, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(606, 510, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(607, 511, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(609, 512, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(610, 513, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(611, 514, 1));
INSERT INTO CourseModules VALUES (CourseModule_t(612, 515, 1));

-- 10. Enrollments (10 rows)
INSERT INTO Enrollments VALUES (Enrollment_t(30, 604, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(31, 605, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(32, 606, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(33, 607, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(34, 608, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(35, 609, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(36, 610, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(37, 611, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(38, 612, SYSDATE - 10, NULL, 'ACTIVE'));
INSERT INTO Enrollments VALUES (Enrollment_t(39, 604, SYSDATE - 10, NULL, 'ACTIVE'));

-- 11. Submissions (10 rows)
INSERT INTO Submissions VALUES (Submission_t(1, 1, 30, SYSTIMESTAMP, 85, 'Good SQL queries', 'SELECT * FROM table'));
INSERT INTO Submissions VALUES (Submission_t(2, 2, 30, SYSTIMESTAMP, 90, 'Well-designed ERD', 'ERD diagram content'));
INSERT INTO Submissions VALUES (Submission_t(3, 3, 31, SYSTIMESTAMP, 80, 'Correct derivatives', 'Derivative solutions'));
INSERT INTO Submissions VALUES (Submission_t(4, 4, 34, SYSTIMESTAMP, 88, 'Accurate matrices', 'Matrix calculations'));
INSERT INTO Submissions VALUES (Submission_t(5, 5, 32, SYSTIMESTAMP, 75, 'Good experiment', 'Lab report'));
INSERT INTO Submissions VALUES (Submission_t(6, 6, 33, SYSTIMESTAMP, 92, 'Excellent functions', 'Python code'));
INSERT INTO Submissions VALUES (Submission_t(7, 7, 35, SYSTIMESTAMP, 87, 'Solid stack implementation', 'Stack code'));
INSERT INTO Submissions VALUES (Submission_t(8, 8, 36, SYSTIMESTAMP, 78, 'Correct probabilities', 'Probability solutions'));
INSERT INTO Submissions VALUES (Submission_t(9, 9, 37, SYSTIMESTAMP, 85, 'Good analysis', 'Field calculations'));
INSERT INTO Submissions VALUES (Submission_t(10, 10, 38, SYSTIMESTAMP, 90, 'Efficient algorithms', 'Sorting code'));



-- =============================================
-- Query to find all students enrolled in Computer Science courses with their submissions and assignment details
-- Includes inner join between Students and Enrollments, left join to Courses, and left join to Submissions
SELECT s.id AS student_id, s.name AS student_name, c.courseId, c.title AS course_title,
       a.assignmentId, a.title AS assignment_title, 
       sub.score, sub.submittedDate,
       get_submission_status(sub.submittedDate, a.deadline) AS submission_status
FROM Students s
INNER JOIN Enrollments e ON s.id = e.studentId
LEFT JOIN Courses c ON e.courseId = c.courseId
LEFT JOIN Assignments a ON c.courseId = a.courseId
LEFT JOIN Submissions sub ON a.assignmentId = sub.assignmentId AND sub.studentId = s.id
WHERE s.major = 'Computer Science'
ORDER BY s.name, c.title, a.deadline;

--===========================================================
-- Query to find all users (students, instructors, and admins) with their roles and creation dates
SELECT id, name, email, 'Student' AS role, createdAt
FROM Students
WHERE enrollmentYear = 2023
UNION
SELECT id, name, email, 'Instructor' AS role, createdAt
FROM Instructors
WHERE department = 'Computer Science'
UNION
SELECT id, name, email, 'Admin' AS role, createdAt
FROM Admins
WHERE 'MANAGE_USERS' IN (SELECT * FROM TABLE(privileges))
ORDER BY createdAt DESC;

--=============================================================================
-- Query to find projects requiring Python technology and their group sizes
SELECT p.projectId, a.title AS project_title, p.groupSize,
       (SELECT COUNT(*) FROM TABLE(p.technologies)) AS tech_count,
       (SELECT LISTAGG(column_value, ', ') FROM TABLE(p.technologies)) AS technologies_used
FROM Projects p
JOIN Assignments a ON p.assignmentId = a.assignmentId
WHERE 'Python' MEMBER OF p.technologies
ORDER BY p.groupSize DESC;


--=============================================================================
-- Query to find assignments due in the next 7 days with time remaining
SELECT a.assignmentId, a.title, a.deadline,
       ROUND(a.deadline - TRUNC(SYSDATE)) AS days_remaining,
       TO_CHAR(a.deadline, 'DY') AS due_day,
       CASE 
           WHEN (a.deadline - SYSDATE) < 1 THEN 'URGENT'
           WHEN (a.deadline - SYSDATE) < 3 THEN 'SOON'
           ELSE 'UPCOMING'
       END AS priority
FROM Assignments a
WHERE a.deadline BETWEEN SYSDATE AND SYSDATE + 7
ORDER BY a.deadline;

--====================================================================================
-- Procedure to generate a comprehensive course analytics report with ROLLUP
CREATE OR REPLACE PROCEDURE generate_course_analytics_report AS
    v_cursor SYS_REFCURSOR;
    v_course_id VARCHAR2(20);
    v_course_title VARCHAR2(200);
    v_student_major VARCHAR2(100);
    v_student_count NUMBER;
    v_avg_score NUMBER;
    v_max_score NUMBER;
    v_min_score NUMBER;
    v_is_total NUMBER := 0;
BEGIN
    OPEN v_cursor FOR
        WITH student_scores AS (
            SELECT 
                c.courseId,
                c.title,
                st.major,
                st.id AS student_id,
                AVG(s.score) AS student_avg_score
            FROM Courses c
            LEFT JOIN Enrollments e ON c.courseId = e.courseId
            LEFT JOIN Students st ON e.studentId = st.id
            LEFT JOIN Submissions s ON s.studentId = st.id
            LEFT JOIN Assignments a ON s.assignmentId = a.assignmentId AND a.courseId = c.courseId
            GROUP BY c.courseId, c.title, st.major, st.id
        )
        SELECT 
            CASE GROUPING(courseId) WHEN 1 THEN 'All Courses' ELSE TO_CHAR(courseId) END AS course_id,
            CASE GROUPING(title) WHEN 1 THEN 'All Titles' ELSE title END AS course_title,
            CASE GROUPING(major) WHEN 1 THEN 'All Majors' ELSE major END AS student_major,
            COUNT(DISTINCT student_id) AS student_count,
            ROUND(AVG(student_avg_score), 2) AS avg_score,
            MAX(student_avg_score) AS max_score,
            MIN(student_avg_score) AS min_score,
            GROUPING(courseId) AS is_total
        FROM student_scores
        GROUP BY ROLLUP(courseId, title), major
        ORDER BY GROUPING(courseId), courseId, GROUPING(major), major;
    
    DBMS_OUTPUT.PUT_LINE('COURSE ANALYTICS REPORT');
    DBMS_OUTPUT.PUT_LINE('=======================');
    DBMS_OUTPUT.PUT_LINE(RPAD('Course ID', 15) || RPAD('Course Title', 40) || RPAD('Major', 20) || 
                         RPAD('Students', 10) || RPAD('Avg Score', 10) || RPAD('Max', 10) || RPAD('Min', 10));
    DBMS_OUTPUT.PUT_LINE(LPAD('-', 115, '-'));
    
    LOOP
        FETCH v_cursor INTO v_course_id, v_course_title, v_student_major, v_student_count, v_avg_score, v_max_score, v_min_score, v_is_total;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_course_id, 15) || 
            RPAD(v_course_title, 40) || 
            RPAD(v_student_major, 20) || 
            RPAD(NVL(TO_CHAR(v_student_count), '0'), 10) || 
            RPAD(NVL(TO_CHAR(v_avg_score), 'N/A'), 10) || 
            RPAD(NVL(TO_CHAR(v_max_score), 'N/A'), 10) || 
            RPAD(NVL(TO_CHAR(v_min_score), 'N/A'), 10)
        );
        
        IF v_is_total = 1 THEN
            DBMS_OUTPUT.PUT_LINE(LPAD('-', 115, '-'));
        END IF;
    END LOOP;
    
    CLOSE v_cursor;
END;
/
EXEC generate_course_analytics_report;
