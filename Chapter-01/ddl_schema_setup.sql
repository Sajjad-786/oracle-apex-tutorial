------------------------------------------------------------------------------
-- COMPANIES
------------------------------------------------------------------------------
DECLARE
    l_count NUMBER;
    l_sql   VARCHAR2(32767);
BEGIN
    --------------------------------------------------------------------------
    -- DROP COMPANIES TABLE (if exists)
    --------------------------------------------------------------------------
    SELECT COUNT(1)
      INTO l_count
      FROM user_tables
     WHERE table_name = 'COMPANIES'
    ;

    IF l_count > 0 THEN
        l_sql := 'DROP TABLE COMPANIES CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE l_sql;
    END IF;

    --------------------------------------------------------------------------
    -- DROP COMP_SEQ SEQUENCE (if exists)
    --------------------------------------------------------------------------
    SELECT COUNT(1)
      INTO l_count
      FROM user_sequences
     WHERE sequence_name = 'COMP_SEQ'
    ;

    IF l_count > 0 THEN
        l_sql := 'DROP SEQUENCE COMP_SEQ';
        EXECUTE IMMEDIATE l_sql;
    END IF;
END; 
/
------------------------------------------------------------------------------
-- CREATE COMPANIES SEQUENCE
------------------------------------------------------------------------------
CREATE SEQUENCE COMP_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
; 
/
------------------------------------------------------------------------------
-- CREATE COMPANIES TABLE
------------------------------------------------------------------------------
CREATE TABLE COMPANIES
(
    --------------------------------------------------------------------------
    -- PRIMARY KEY
    --------------------------------------------------------------------------
    COMP_ID                    NUMBER
        DEFAULT COMP_SEQ.NEXTVAL
        NOT NULL

  , --------------------------------------------------------------------------
    -- COMPANY MASTER DATA
    --------------------------------------------------------------------------
    COMP_NAME                  VARCHAR2(300)
        NOT NULL

  , COMP_SHORT_NAME            VARCHAR2(100)

  , COMP_EMAIL                 VARCHAR2(320)

  , COMP_PHONE                 VARCHAR2(50)

  , COMP_STREET                VARCHAR2(400)
  , COMP_STREET_NR             VARCHAR2(50)
  , COMP_POSTCODE              VARCHAR2(20)
  , COMP_CITY                  VARCHAR2(200)
  , COMP_COUNTRY               VARCHAR2(100)

  , COMP_ACTIVE_YN             VARCHAR2(4)
        DEFAULT 'YES'
        NOT NULL

  , --------------------------------------------------------------------------
    -- AUDIT & LIFECYCLE (STANDARD TEMPLATE)
    --------------------------------------------------------------------------
    COMP_REMARK                CLOB

  , COMP_CREATED               TIMESTAMP(6)
        DEFAULT SYSDATE

  , COMP_CREATED_BY            VARCHAR2(4000)
        DEFAULT COALESCE(
                    SYS_CONTEXT('apex$session', 'app_user')
                  , SYS_CONTEXT('userenv', 'os_user')
                  , SYS_CONTEXT('userenv', 'session_user')
                )

  , COMP_UPDATED               TIMESTAMP(6)
        DEFAULT SYSDATE

  , COMP_UPDATED_BY            VARCHAR2(4000)
        DEFAULT COALESCE(
                    SYS_CONTEXT('apex$session', 'app_user')
                  , SYS_CONTEXT('userenv', 'os_user')
                  , SYS_CONTEXT('userenv', 'session_user')
                )

  , COMP_VALID_FROM            TIMESTAMP(6)
        DEFAULT SYSDATE

  , COMP_VALID_TO              TIMESTAMP(6)
        DEFAULT TO_DATE('31.12.2999', 'DD.MM.YYYY')

  , COMP_DELETED_YN            VARCHAR2(4)
        DEFAULT 'NO'

  , --------------------------------------------------------------------------
    -- CONSTRAINTS
    --------------------------------------------------------------------------
    CONSTRAINT PK_COMP_ID
        PRIMARY KEY (COMP_ID)
); 
/
------------------------------------------------------------------------------
-- USERS
------------------------------------------------------------------------------
DECLARE
    l_count NUMBER;
    l_sql   VARCHAR2(32767);
BEGIN
    --------------------------------------------------------------------------
    -- DROP USERS TABLE (if exists)
    --------------------------------------------------------------------------
    SELECT COUNT(1)
      INTO l_count
      FROM user_tables
     WHERE table_name = 'USERS'
    ;

    IF l_count > 0 THEN
        l_sql := 'DROP TABLE USERS CASCADE CONSTRAINTS';
        EXECUTE IMMEDIATE l_sql;
    END IF;

    --------------------------------------------------------------------------
    -- DROP USER_SEQ SEQUENCE (if exists)
    --------------------------------------------------------------------------
    SELECT COUNT(1)
      INTO l_count
      FROM user_sequences
     WHERE sequence_name = 'USER_SEQ'
    ;

    IF l_count > 0 THEN
        l_sql := 'DROP SEQUENCE USER_SEQ';
        EXECUTE IMMEDIATE l_sql;
    END IF;
END; 
/
------------------------------------------------------------------------------
-- CREATE USERS SEQUENCE
------------------------------------------------------------------------------
CREATE SEQUENCE USER_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
; 
/
------------------------------------------------------------------------------
-- CREATE USERS TABLE
------------------------------------------------------------------------------
CREATE TABLE USERS
(
    --------------------------------------------------------------------------
    -- PRIMARY KEY
    --------------------------------------------------------------------------
    USER_ID                        NUMBER
        DEFAULT USER_SEQ.NEXTVAL
        NOT NULL

  , --------------------------------------------------------------------------
    -- RELATIONSHIPS
    --------------------------------------------------------------------------
    USER_COMP_FK                   NUMBER
        NOT NULL

  , --------------------------------------------------------------------------
    -- USER IDENTITY DATA
    --------------------------------------------------------------------------
    USER_FIRST_NAME                VARCHAR2(200)
        NOT NULL

  , USER_LAST_NAME                 VARCHAR2(200)
        NOT NULL

  , USER_LOGIN_EMAIL               VARCHAR2(320)
        NOT NULL

  , --------------------------------------------------------------------------
    -- LOGIN / SECURITY DATA
    --------------------------------------------------------------------------
    USER_LOGIN_PASSWORD            VARCHAR2(4000)
        NOT NULL 

  , USER_ACTIVE_YN                 VARCHAR2(4)
        DEFAULT 'YES'
        NOT NULL

  , --------------------------------------------------------------------------
    -- AUDIT & LIFECYCLE (STANDARD TEMPLATE)
    --------------------------------------------------------------------------
    USER_REMARK                    CLOB

  , USER_CREATED                   TIMESTAMP(6)
        DEFAULT SYSDATE

  , USER_CREATED_BY                VARCHAR2(4000)
        DEFAULT COALESCE(
                    SYS_CONTEXT('apex$session', 'app_user')
                  , SYS_CONTEXT('userenv', 'os_user')
                  , SYS_CONTEXT('userenv', 'session_user')
                )

  , USER_UPDATED                   TIMESTAMP(6)
        DEFAULT SYSDATE

  , USER_UPDATED_BY                VARCHAR2(4000)
        DEFAULT COALESCE(
                    SYS_CONTEXT('apex$session', 'app_user')
                  , SYS_CONTEXT('userenv', 'os_user')
                  , SYS_CONTEXT('userenv', 'session_user')
                )

  , USER_VALID_FROM                TIMESTAMP(6)
        DEFAULT SYSDATE

  , USER_VALID_TO                  TIMESTAMP(6)
        DEFAULT TO_DATE('31.12.2999', 'DD.MM.YYYY')

  , USER_DELETED_YN                VARCHAR2(4)
        DEFAULT 'NO'

  , --------------------------------------------------------------------------
    -- CONSTRAINTS
    --------------------------------------------------------------------------
    CONSTRAINT PK_USER_ID
        PRIMARY KEY (USER_ID)

  , CONSTRAINT FK_USER_COMP_FK
        FOREIGN KEY (USER_COMP_FK)
        REFERENCES COMPANIES (COMP_ID)
);
/