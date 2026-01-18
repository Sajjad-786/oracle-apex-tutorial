CREATE OR REPLACE PACKAGE authentication
AS

    --------------------------------------------------------------------------------
    -- Function: fn_hash_pass
    -- Purpose : Generate a deterministic password hash based on email and password.
    -- Notes   :
    --   - Email is part of the hash to prevent rainbow-table reuse
    --   - Must be identical across DEV / TEST / PROD
    --------------------------------------------------------------------------------
    FUNCTION fn_hash_pass(
        pi_email            IN VARCHAR2 DEFAULT NULL
      , pi_password         IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2;

    --------------------------------------------------------------------------------
    -- Function: fn_authenticate_user_super_admin
    -- Purpose : Authenticate a Super Admin user using username and password.
    -- Notes   :
    --   - Used for privileged access (bootstrap / system users)
    --   - Returns TRUE only on successful authentication
    --------------------------------------------------------------------------------
    FUNCTION fn_authenticate_user_super_admin(
        pi_user_name        IN VARCHAR2
      , pi_password         IN VARCHAR2
    ) RETURN BOOLEAN;

    --------------------------------------------------------------------------------
    -- Procedure: pr_process_login
    -- Purpose  : Central login handler for Oracle APEX applications.
    -- Notes    :
    --   - Validates credentials
    --   - Sets APEX session state
    --   - Handles application-specific login logic
    --------------------------------------------------------------------------------
    PROCEDURE pr_process_login(
        pi_user_name        IN VARCHAR2
      , pi_password         IN VARCHAR2
      , pi_app_id           IN NUMBER
    );

END authentication;
/


create or replace PACKAGE BODY authentication
AS

    --------------------------------------------------------------------------------
    -- Function: fn_hash_pass
    -- Purpose : Generate a deterministic password hash based on email and password.
    -- Notes   :
    --   - Email is part of the hash to prevent rainbow-table reuse
    --   - Must be stable across all environments
    --------------------------------------------------------------------------------
    FUNCTION fn_hash_pass(
        pi_email            IN VARCHAR2 DEFAULT NULL
      , pi_password         IN VARCHAR2 DEFAULT NULL
    ) RETURN VARCHAR2
    IS
        v_hash_pass         VARCHAR2(4000);
        v_salt              VARCHAR2(4000)
            := 'hdjikndbbhitasuihfnnkqyhiplwmneuyndnloidj';
    BEGIN
        v_hash_pass :=
            UTL_RAW.cast_to_raw(
                DBMS_OBFUSCATION_TOOLKIT.md5(
                    input_string =>
                           pi_password
                        || SUBSTR(v_salt, 10, 13)
                        || LOWER(pi_email)
                        || SUBSTR(v_salt, 4, 10)
                )
            );

        RETURN v_hash_pass;
    END fn_hash_pass;

    --------------------------------------------------------------------------------
    -- Function: fn_authenticate_user
    -- Purpose : Authenticate application user using email and password.
    -- Notes   :
    --   - Raises application errors instead of UI messaging
    --   - Can be consumed by APEX, REST, or background jobs
    --------------------------------------------------------------------------------
    FUNCTION fn_authenticate_user(
        pi_user_name        IN VARCHAR2
      , pi_password         IN VARCHAR2
    ) RETURN BOOLEAN
    IS
        v_password          VARCHAR2(4000);
        v_active_yn         VARCHAR2(4);
        v_deleted_yn        VARCHAR2(4);
        v_first_name        VARCHAR2(200);
        v_last_name         VARCHAR2(200);
    BEGIN
        ----------------------------------------------------------------------
        -- Input validation
        ----------------------------------------------------------------------
        IF pi_user_name IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, '📧 Login failed – email address is missing.');
        END IF;

        IF pi_password IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, '🔑 Login failed – password is missing.');
        END IF;

        ----------------------------------------------------------------------
        -- Fetch user
        ----------------------------------------------------------------------
        BEGIN
            SELECT user_login_password
                 , user_active_yn
                 , user_deleted_yn
                 , user_first_name
                 , user_last_name
              INTO v_password
                 , v_active_yn
                 , v_deleted_yn
                 , v_first_name
                 , v_last_name
              FROM users
             WHERE LOWER(user_login_email) = LOWER(pi_user_name);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, '🕵️‍♂️ Login failed – no account found for this email address.');
        END;

        ----------------------------------------------------------------------
        -- Password validation
        ----------------------------------------------------------------------
        IF v_password <>
           authentication.fn_hash_pass(
               LOWER(pi_user_name)
             , pi_password
           )
        THEN
            RAISE_APPLICATION_ERROR(-20004, '🔒 Login failed – the password you entered is incorrect.');
        END IF;

        ----------------------------------------------------------------------
        -- Status validation
        ----------------------------------------------------------------------
        IF v_deleted_yn = 'YES' THEN
            RAISE_APPLICATION_ERROR(-20005, '🚫 Account disabled – this user has been permanently deactivated.');
        END IF;

        IF v_active_yn <> 'YES' THEN
            RAISE_APPLICATION_ERROR(-20006, '⏸️ Account inactive – please contact your company administrator.');
        END IF;

        RETURN TRUE;
    END fn_authenticate_user;


    --------------------------------------------------------------------------------
    -- Procedure: pr_process_login
    -- Purpose  : Central login handler without UI dependencies.
    -- Notes    :
    --   - Relies purely on raised exceptions
    --   - Redirect logic handled by caller (APEX / API)
    --------------------------------------------------------------------------------
    PROCEDURE pr_process_login(
        pi_user_name        IN VARCHAR2
      , pi_password         IN VARCHAR2
      , pi_app_id           IN NUMBER
    )
    IS
        v_result            BOOLEAN;
    BEGIN
        v_result :=
            fn_authenticate_user(
                pi_user_name
              , pi_password
            );

        Wwv_Flow_Custom_Auth_Std.post_login(
            pi_user_name
          , pi_password
          , v('APP_SESSION')
          , pi_app_id || ':1'
        );
    END pr_process_login;


END authentication;
/

