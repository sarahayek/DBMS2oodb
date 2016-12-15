--campus
create or replace campus_t  as object();
--professor: object, varray 5

--units: varray 5 varchar2

--school

--department

--research-center

--faculty

--equipments: varray 3 varchar2 

--building

--office 

create or replace type office_T as object
(bld_id varchar2(10),
off_no varchar2(10),
off_phone varchar2(12),
member procedure show_office)
/
create table office of office_T
(bld_id not null,
off_no not null,
primary key(bld_id, off_no),
foreign key(bld_id) references
build(bld_id))
cluster build_cluster(bld_id);

--classroom

--lab

--degree

CREATE OR REPLACE TYPE Degree_T AS OBJECT(
  deg_ID VARCHAR2(20),
  deg_name VARCHAR2(30),
  deg_length VARCHAR2(30),
  deg_prereq VARCHAR2(30),
  faculty REF Faculty_T,
  
  STATIC PROCEDURE insert_degree (
    dge_id IN VARCHAR,
    deg_name IN VARCHAR2,
    deg_length IN VARCHAR2,
    deg_prereq IN VARCHAR2,
    fact_id IN VARCHAR2
  ),
  MEMBER PROCEDURE delete_degree,
  MEMBER PROCEDURE show_deg_record
);


CREATE TABLE Degrees OF Degree_T(
  PRIMARY KEY(deg_ID)
);

CREATE TABLE Degree_Records (
  deg_id VARCHAR2(20) PRIMARY KEY,
  deg_name VARCHAR2(30),
  deg_length  VARCHAR2(30),
  deg_prereq  VARCHAR2(30),
  all_students INTEGER
  
);

CREATE TYPE BODY Degree_T AS 
    STATIC PROCEDURE insert_degree (
    dge_id IN VARCHAR,
    deg_name IN VARCHAR2,
    deg_length IN VARCHAR2,
    deg_prereq IN VARCHAR2,
    fact_id IN VARCHAR2
  ) IS
     faculty REF Faculty_T;
    Begin
      SELECT REF(f) INTO faculty FROM Faculty f
      WHERE f.fact_id = fact_id;
      
      INSERT INTO Degrees VALUES
      (dge_id , deg_name , deg_length , deg_prereq , faculty);
    END insert_degree;
    
    MEMBER PROCEDURE delete_degree IS
      BEGIN 
        DELETE FROM Enrolls_In WHERE Enrolls_In.degree 
        IN (SELECT REF(d) FROM Degrees d 
        WHERE d.deg_id = SELF.deg_id);
        
        DELETE FROM Degrees d 
        WHERE d.deg_id = SELF.deg_id;
      END delete_degree;
        
    MEMBER PROCEDURE show_deg_record IS
      all_degrees INTEGER;
       BEGIN 
        SELECT COUNT(*) AS All_Students INTO 
        all_degrees FROM Degrees d , Enrolls_In e
        WHERE e.degree = REF(d) AND d.deg_id = SELF.deg_id GROUP BY d.deg_id;
   
        INSERT INTO Degree_Records VALUES 
        (SELF.deg_id , SELF.deg_name
         , SELF.deg_length , SELF.deg_prereq , all_degrees );
  
    END show_deg_record;
END;

--person

--staff

--student

--admin

--technician

--lecturer

--senior_lecturer

--associate_lecturer

--tutor

--enrolls_in

--BODY OF OFFICE -SONDOS

create or replace type body office_T as
member procedure show_office is
cursor c_office is
select s.pers_surname, b.off_no, b.off_phone
from person p, build b, office o, staff s
where b.bld_id = self.bld_id and b.bld_id =
o.bld_id
and p.pers_id = s.pers_id and s.in_office = ref
(o);
begin
dbms_output.put_line
(‘surname’||’  ‘||’office no’||’  ‘||‘office
phone’);

for v_office in c_office loop
dbms_output.put_line
(v_office.pers_surname||’ ‘||
v_office.off_no||’ ‘||
v_office.off_phone);
end loop;
end show_office;
end;
/

--subject
CREATE OR REPLACE TYPE Subject_T AS OBJECT 
(subj_id VARCHAR2(20),
subj_name VARCHAR2(50),
subj_credit VARCHAR2(50),
subj_prereq VARCHAR2(50), 
teach REF Lecturer_T,

 MEMBER PROCEDURE insert_subject (
 new_subj_id IN VARCHAR2,
 new_subj_name IN VARCHAR2,
 new_subj_credit IN VARCHAR2,
 new_subj_prereq IN VARCHAR2,
 new_pers_id IN VARCHAR2 ),
MEMBER PROCEDURE delete_subject
);

CREATE TABLE Subject OF Subject_T (
subj_id NOT NULL,
PRIMARY KEY (subj_id)
);

CREATE TABLE Takes (
student REF Student_T,
subject REF Subject_T,
marks NUMBER
);

CREATE OR REPLACE TYPE BODY Subject_T AS
MEMBER PROCEDURE insert_subject ( 
new_subj_id IN VARCHAR2,
new_subj_name IN VARCHAR2,
new_subj_credit IN VARCHAR2, 
new_subj_prereq IN VARCHAR2, 
new_pers_id IN VARCHAR2
) 
IS
lecturer_temp REF Lecturer_T;
BEGIN 
SELECT REF(a) INTO lecturer_temp FROM Lecturer a 
WHERE a.pers_id = new_pers_id;

INSERT INTO Subject VALUES
(new_subj_id, new_subj_name, new_subj_credit, new_subj_prereq, lecturer_temp);
END insert_subject;

MEMBER PROCEDURE delete_subject IS
BEGIN 
DELETE FROM Subject WHERE subj_id = self.subj_id;
END delete_subject;

CREATE OR REPLACE PROCEDURE Insert_Takes ( 
new_pers_id IN Person.pers_id%TYPE,
new_subj_id IN Subject.subj_id%TYPE,
new_marks IN NUMBER
) AS
student_temp REF Student_T;
subject_temp REF Subject_T;
BEGIN 
SELECT REF(a) INTO student_temp 
FROM Student a
WHERE a.pers_id = new_pers_id;

SELECT REF(b) INTO subject_temp FROM Subject b 
WHERE b.subj_id = new_subj_id;

INSERT INTO Takes VALUES (student_temp, subject_temp, new_marks);
 END Insert_Takes;
 
CREATE OR REPLACE PROCEDURE Delete_Takes (
deleted_pers_id IN Person.pers_id%TYPE, deleted_subj_id IN Subject.subj_id%TYPE
) AS
BEGIN 
DELETE FROM Takes 
WHERE Takes.student IN (
SELECT REF(a) FROM Student a WHERE a.pers_id = deleted_pers_id)
AND Takes.subject IN
(SELECT REF(b) FROM Subject b WHERE b.subj_id = deleted_subj_id);
END Delete_Takes;


--takes



