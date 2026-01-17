# Introduction – Database DDL Standards

This tutorial is based on a strict and consistent database foundation.
Before creating any Oracle APEX pages or business logic, we define mandatory
DDL standards for tables and sequences.

These rules apply to all database objects in this project and are not optional.

---

## 1. General Principles

- Every database object follows a clear naming convention
- Every table:
  - has exactly one numeric primary key
  - is backed by exactly one dedicated sequence
  - contains audit and lifecycle columns
- All DDL scripts are:
  - idempotent (safe to re-run)
  - readable and consistently formatted
  - self-contained

---

## 2. Table Naming Convention

- Tables are always named in plural form
- Table names represent a set of records, not a single entity

Examples:

COMPANIES  
USERS  
ORDERS  
PRODUCTS  

---

## 3. Column Prefix Convention

Each table uses a fixed 4-letter prefix derived from the table name.
All columns in the table must start with this prefix.

Table → Prefix mapping:

COMPANIES → COMP_  
USERS → USER_  
ORDERS → ORDE_  
PRODUCTS → PROD_  

Correct examples:

USER_ID  
USER_LOGIN_EMAIL  
USER_CREATED  

Incorrect examples:

ID  
EMAIL  
CREATED_AT  

---

## 4. Primary Key Rule

- Every table has exactly one primary key
- Data type is always NUMBER
- The primary key value is generated via a table-specific sequence
- Column name pattern: <PREFIX>_ID

Example:

COMP_ID NUMBER DEFAULT COMP_SEQ.NEXTVAL NOT NULL

Primary key constraint naming:

PK_<TABLE_NAME>

Example:

PK_COMPANIES

---

## 5. Sequence Rule

- Every table has exactly one sequence
- Sequence name pattern: <PREFIX>_SEQ
- Sequences use:
  - NOCACHE
  - NOCYCLE

Example:

CREATE SEQUENCE COMP_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

---

## 6. Idempotent DDL Pattern

All tables and sequences are dropped safely before being created.

Rules:

- Never assume an object exists
- Always check USER_TABLES and USER_SEQUENCES
- Tables are dropped with CASCADE CONSTRAINTS

This guarantees that DDL scripts can be executed multiple times in:

- DEV
- TEST
- PROD

Without manual cleanup.

---

## 7. Audit and Lifecycle Columns (Mandatory)

Every table must contain the following audit and lifecycle columns.

Audit columns:

<PREFIX>_CREATED  
<PREFIX>_CREATED_BY  
<PREFIX>_UPDATED  
<PREFIX>_UPDATED_BY  

Lifecycle columns:

<PREFIX>_VALID_FROM  
<PREFIX>_VALID_TO  
<PREFIX>_DELETED_YN  

Default rules:

- VALID_FROM defaults to SYSDATE
- VALID_TO defaults to 31.12.2999
- DELETED_YN defaults to 'NO'

User resolution for *_BY columns is done via:

- APEX session user
- OS user
- Database session user

---

## 8. YES / NO Convention

Boolean-like fields never use Y/N or 1/0.

Only the following values are allowed:

YES  
NO  

Column naming pattern:

<PREFIX>_ACTIVE_YN  
<PREFIX>_DELETED_YN  

---

## 9. Foreign Key Rule

- Foreign keys always reference the primary key of the parent table
- Foreign key column name pattern: <CHILD>_<PARENT>_FK
- Foreign key constraints are explicitly named

Example column:

USER_COMP_FK

Example constraint:

FK_USER_COMP_FK

---

## 10. Formatting Rules

- SQL keywords are written in UPPERCASE
- Each column starts on a new line
- Commas are placed at the beginning of the line
- Section separators are mandatory

These rules ensure:

- high readability
- clean diffs in version control
- easy onboarding for new developers

---

## 11. Conclusion

These DDL standards form the foundation of this tutorial.
All future tables, APIs, and Oracle APEX components rely on these rules.

Once the database foundation is established, application development
can proceed in a structured and predictable way.
