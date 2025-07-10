# Educational Management Database System

# Overview
This project implements a comprehensive database system using Oracle SQL to manage an educational platform. It includes object-relational types, tables, triggers, stored procedures, and functions to handle students, instructors, admins, courses, modules, assignments, quizzes, projects, enrollments, and submissions. The system supports analytics and progress tracking, built on data from the Gold layer of an ETL pipeline.

# Features
- **Object-Relational Design**: Defines custom types (e.g., `Student_t`, `Course_t`) with nested tables for learning objectives and privileges.
- **Data Management**: Manages 10+ entities with constraints and referential integrity.
- **Triggers**: Enforces business rules (e.g., valid instructor assignments, enrollment date checks).
- **Stored Procedures/Functions**: Includes `get_student_progress`, `get_course_stats`, `get_submission_status`, and `generate_course_analytics_report` for reporting.
- **Sample Data**: Populated with realistic data for testing and demonstration.

# Usage
- Execute the SQL script (`sql/educational_db.sql`) in an Oracle SQL environment to create and populate the database.
- Run procedures like `EXEC generate_course_analytics_report;` to view analytics.
- Query the system with provided examples (e.g., student submissions, course stats).


# Prerequisites
- Oracle SQL Database (e.g., Oracle 19c or later).
- SQL client (e.g., SQL Developer or SQL*Plus).
- Basic understanding of SQL and object-relational features.

# Notes
- The script includes cleanup commands to drop existing objects; use with caution on production systems.
- Sample data is generic; adjust dates or IDs as needed.


# Future Improvements
- Add user authentication and role-based access control.
- Implement incremental data updates.
- Integrate with a frontend application for real-time management.

# License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
