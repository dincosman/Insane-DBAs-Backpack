SQL> SELECT 
    username, 
    guessed_password, 
    stored_hashed_pwd,
    CASE 
        WHEN stored_hashed_pwd = computed_hashed_pwd THEN 'Y' 
        ELSE 'N' 
    END AS result
FROM ( -- This SELECT concatenates the salt with the guessed password and hashes it.
    SELECT 
        name AS username, 
        password_brute  AS guessed_password,
        SUBSTR(SUBSTR(spare4, 3, 60), 1, 40) AS stored_hashed_pwd,  -- Extract the first 20 bytes (40 characters) of the hashed password
        SUBSTR(SUBSTR(spare4, 3, 60), -20) AS stored_salt,         -- Extract the last 10 bytes (20 characters) of the plaintext salt
        -- The "3" indicates the use of the SHA-1 algorithm (If you have :S in spare4 then you are using SHA-1)
        sys.dbms_crypto.hash(
            utl_raw.cast_to_raw(password_brute) || CAST(SUBSTR(SUBSTR(spare4, 3, 60), -20) AS RAW(10)), 3
        ) AS computed_hashed_pwd
    FROM sys.user$ , t_passwords_ext where name='SYSTEM') where stored_hashed_pwd = computed_hashed_pwd 
