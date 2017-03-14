CREATE OR REPLACE PROCEDURE LOAN_APPLICATION(EMPID IN EMPLOYEE.EMP_ID%TYPE,LOAN_TYPE IN VARCHAR2) IS
TEMP PAYROLL_PAYMENTS%ROWTYPE;
V_MONTH NUMBER(2);
V_YEAR NUMBER(4);
TEMP_NETSALARY PAYROLL_PAYMENTS.NETPAY%TYPE;
TEMP_STAGE_CODE SALARY_COMPONENTS.STAGE_CODE%TYPE;
TEMP_BASIC SALARY_COMPONENTS.BASIC%TYPE;
TEMP_DESIGNATION SALARY_COMPONENTS.DESIGNATION%TYPE;
BEGIN
SELECT EXTRACT(MONTH FROM SYSDATE),EXTRACT(YEAR FROM SYSDATE) INTO V_MONTH,V_YEAR FROM DUAL;
V_MONTH:=V_MONTH-1;
  IF V_MONTH=0 THEN
      V_MONTH:=12;
    IF (LOAN_TYPE = 'Soft') THEN
              
    SELECT LOAN_AMOUNT INTO V_TEMP FROM SOFT_LOANS WHERE EMP_ID=EMPID AND MONTH=V_MONTH AND YEAR=V_YEAR;
      IF(SQL%FOUND) THEN
      DBMS_OUTPUT.PUT_LINE('Previous Soft Loan must be closed');
      ELSE
      SELECT STAGE_CODE,DESIGNATION INTO TEMP_STAGE_CODE,TEMP_DESIGNATION FROM EMPLOYEE WHERE EMP_ID=EMPID;
      SELECT BASIC INTO TEMP_BASIC FROM SALARY_COMPONENTS WHERE STAGE_CODE=TEMP_STAGE_CODE AND DESIGNATION=TEMP_DESIGNATION;
      TEMP_BASIC:=TEMP_BASIC*6;
      INSERT INTO SOFT_LOANS(EMP_ID,LOAN_ID,LOAN_AMOUNT,CURRENT_BALANCE,DATE_DISBURSED,DUE_DATE)
      VALUES (EMPID,LOANID_SEQ.NEXTVAL,TEMP_BASIC,0,SYSDATE,ADD_MONTHS(SYSDATE,24));
      DBMS_OUTPUT.PUT_LINE('LOAN PAYMENT OF $'||TEMP_BASIC||' CAN BE ISSUED TO THE EMPLOYEE '||EMPID );
END IF;      
    ELSIF (LOAN_TYPE = 'Advance')THEN
      SELECT * INTO TEMP FROM PAYROLL_PAYMENTS WHERE EMP_ID=EMPID AND MONTH=V_MONTH;
          IF(SQL%FOUND) THEN
          TEMP_NETSALARY:=TEMP.NETPAY;
          INSERT INTO ADVANCE_LOANS(EMP_ID,ADVANCE_ID,YEAR,MONTH,AMOUNT,DATE_DISBURSED) 
          VALUES (EMPID,ADVANCE_SEQ.NEXTVAL,V_YEAR,V_MONTH,TEMP_NETSALARY,SYSDATE);
          DBMS_OUTPUT.PUT_LINE('ADVANCE PAYMENT OF $'||TEMP_NETSALARY||' CAN BE ISSUED TO THE EMPLOYEE '||EMPID );
          END IF;
     ELSE 
          DBMS_OUTPUT.PUT_LINE('Invalid Loan Type Specified');
     END IF;

  END IF;
COMMIT;
END;

