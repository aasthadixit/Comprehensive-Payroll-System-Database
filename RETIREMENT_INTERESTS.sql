CREATE OR REPLACE PROCEDURE RETIREMENT_INTEREST(PFINTEREST IN NUMBER,PENSIONINTEREST IN NUMBER,VPFINTEREST IN NUMBER) IS
V_RETIREMENT RETIREMENT_ACCOUNT%ROWTYPE;

CURSOR RETIREMENT IS SELECT * FROM RETIREMENT_ACCOUNT FOR UPDATE;

BEGIN

FOR V_TEMP IN RETIREMENT
LOOP
UPDATE RETIREMENT_ACCOUNT SET PF_BALANCE=PF_BALANCE+(PF_BALANCE*PFINTEREST/100),
                              PENSION_BALANCE=PENSION_BALANCE+(PENSION_BALANCE*PENSIONINTEREST/100),
                              VPF_BALANCE=VPF_BALANCE+(VPF_BALANCE*VPFINTEREST/100)
                              WHERE CURRENT OF RETIREMENT;
END LOOP;
COMMIT;
END;
