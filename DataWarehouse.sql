CREATE DATABASE if not exists HospitalManagementSystem;

USE HospitalManagementSystem;

CREATE TABLE Departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    head_doctor VARCHAR(100)
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    phone_number VARCHAR(15)
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100), 
    department_id INT,

    CONSTRAINT fk_doctor_department
    FOREIGN KEY (department_id)
    REFERENCES Departments(department_id)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    status VARCHAR(30),

    CONSTRAINT fk_appointment_patient
    FOREIGN KEY (patient_id)
    REFERENCES Patients(patient_id),

    CONSTRAINT fk_appointment_doctor
    FOREIGN KEY (doctor_id)
    REFERENCES Doctors(doctor_id)
);

CREATE TABLE Treatments (
    treatment_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL,
    diagnosis VARCHAR(255),
    treatment_cost DECIMAL(10,2),
    treatment_notes VARCHAR(255),

    CONSTRAINT fk_treatment_appointment
    FOREIGN KEY (appointment_id)
    REFERENCES Appointments(appointment_id)
);

CREATE TABLE Medications (
    medication_id INT PRIMARY KEY AUTO_INCREMENT,
    treatment_id INT NOT NULL,
    medication_name VARCHAR(100),
    dosage VARCHAR(50),
    duration_days INT,

    CONSTRAINT fk_medication_treatment
    FOREIGN KEY (treatment_id)
    REFERENCES Treatments(treatment_id)
);

CREATE TABLE Bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    bill_amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Paid', 'Pending', 'Cancelled') NOT NULL DEFAULT 'Pending',
    payment_date DATE,
    insurance_id INT UNIQUE,   -- Ensures 1:1 relationship with Insurance
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
    FOREIGN KEY (insurance_id) REFERENCES Insurance(insurance_id)
);


CREATE TABLE Insurance (
    insurance_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_name VARCHAR(100) NOT NULL,
    policy_number VARCHAR(50) NOT NULL,
    coverage_details VARCHAR(255)
);


CREATE TABLE Patient_Treatment_Billing (
    patient_id INT,
    patient_name VARCHAR(100) NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    appointment_date DATE NOT NULL,
    diagnosis VARCHAR(255),
    treatment_cost DECIMAL(10,2),
    medication_name VARCHAR(100),
    dosage VARCHAR(50),
    bill_amount DECIMAL(10,2),
    payment_status VARCHAR(30),
    insurance_provider VARCHAR(100),
    policy_number VARCHAR(50)
);

SHOW TABLES;

DESCRIBE Patients;

DESCRIBE Doctors;

DESCRIBE Appointments;

DESCRIBE Treatments;

DESCRIBE Medications;

DESCRIBE Bills;

DESCRIBE Departments;

INSERT INTO Departments (department_name, location, head_doctor)
VALUES
('Cardiology', 'Block A', 'Dr. Smith'),
('Neurology', 'Block B', 'Dr. Adams'),
('Orthopedics', 'Block C', 'Dr. Brown');

Select * from Departments;

INSERT INTO Doctors (doctor_name, specialization, department_id)
VALUES
('Dr. Smith', 'Cardiologist', 1),
('Dr. Adams', 'Neurologist', 2),
('Dr. Brown', 'Orthopedic Surgeon', 3),
('Dr. Miller', 'Cardiologist', 1);

INSERT INTO Patients (first_name, last_name, date_of_birth, phone_number)
VALUES
('John', 'Doe', '1985-04-12', '123456789'),
('Emily', 'Clark', '1990-09-21', '987654321'),
('Michael', 'Lee', '1978-12-05', '555123456');

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
VALUES
(1, 1, '2024-03-10', 'Completed'),
(2, 2, '2024-01-12', 'Completed'),
(3, 3, '2024-03-15', 'Scheduled'),
(1, 2, '2024-01-11', 'Completed');

INSERT INTO Treatments (appointment_id, diagnosis, treatment_cost, treatment_notes)
VALUES
(1, 'High Blood Pressure', 150.00, 'Prescribed medication'),
(2, 'Migraine', 120.00, 'Recommended MRI'),
(3, 'Knee Pain', 200.00, 'Scheduled physiotherapy'),
(4, 'Chest Pain', 180.00, 'ECG performed');
Select * from appointments;

INSERT INTO Medications (treatment_id, medication_name, dosage, duration_days)
VALUES
(1, 'Amlodipine', '5mg', 30),
(2, 'Ibuprofen', '400mg', 7),
(3, 'Diclofenac', '50mg', 14),
(4, 'Aspirin', '75mg', 30);

INSERT INTO Insurance (provider_name, policy_number, coverage_details)
VALUES
('AOK Health', 'POL12345', 'Covers 80% of treatment cost'),
('TK Insurance', 'POL67890', 'Full coverage for diagnostics'),
('DAK Health', 'POL54321', 'Covers medication only'),
('Blue Shield', 'INS-9921-A', '80% coverage for general visits');

INSERT INTO Bills (patient_id, bill_amount, payment_status, payment_date, insurance_id)
VALUES
(1, 150.00, 'Paid', '2024-03-11', 1),
(3, 120.00, 'Pending', NULL, 2),
(2, 200.00, 'Paid', '2024-01-16', 3),
(1, 180.00, 'Paid', '2024-01-13',4);

select * from Bills;

-- View 1
CREATE VIEW PatientHistorySummary AS
SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    COALESCE(appt_counts.total_appointments, 0) AS total_appointments,
    COALESCE(appt_counts.total_treatments, 0) AS total_treatments,
    COALESCE(bill_counts.total_billed_amount, 0.00) AS total_billed_amount
FROM Patients p
LEFT JOIN (
    SELECT 
        a.patient_id,
        COUNT(a.appointment_id) AS total_appointments,
        COUNT(t.treatment_id) AS total_treatments
    FROM Appointments a
    LEFT JOIN Treatments t ON a.appointment_id = t.appointment_id
    GROUP BY a.patient_id
) appt_counts ON p.patient_id = appt_counts.patient_id
LEFT JOIN (
    SELECT 
        b.patient_id,
        SUM(b.bill_amount) AS total_billed_amount
    FROM Bills b
    GROUP BY b.patient_id
) bill_counts ON p.patient_id = bill_counts.patient_id;

select * from  PatientHistorySummary;

-- View2
CREATE VIEW MonthlyBillingTrend AS
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS month,
    COUNT(bill_id) AS total_bills,
    SUM(bill_amount) AS total_revenue
FROM Bills
WHERE payment_date IS NOT NULL
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month;

select * from MonthlyBillingTrend;

-- query Joint + groupby
SELECT 
    d.department_name AS 'Department Name',
    COUNT(DISTINCT a.patient_id) AS 'Unique Patients Treated',
    COUNT(t.treatment_id) AS 'Total Treatments Provided',
    CONCAT('$', FORMAT(SUM(t.treatment_cost), 2)) AS 'Total Revenue Generated'
FROM Departments d
INNER JOIN Doctors doc ON d.department_id = doc.department_id
INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
INNER JOIN Treatments t ON a.appointment_id = t.appointment_id
GROUP BY d.department_id, d.department_name
ORDER BY SUM(t.treatment_cost) DESC;

-- Qyery Case and subquery
SELECT 
    p.patient_id AS 'Patient ID',
    CONCAT(p.first_name, ' ', p.last_name) AS 'Patient Name',
    COALESCE(bill_summary.total_billed, 0.00) AS 'Lifetime Billed Amount',
    CASE 
        WHEN bill_summary.total_billed >= 300.00 THEN 'High Value / High Risk'
        WHEN bill_summary.total_billed BETWEEN 150.00 AND 299.99 THEN 'Moderate Value'
        WHEN bill_summary.total_billed < 150.00 THEN 'Low Value'
        ELSE 'No Billing History'
    END AS 'Financial Tier'
FROM Patients p
LEFT JOIN (
    SELECT 
        b.patient_id,
        SUM(b.bill_amount) AS total_billed
    FROM Bills b
    GROUP BY b.patient_id
) bill_summary ON p.patient_id = bill_summary.patient_id
ORDER BY bill_summary.total_billed DESC;

-- query window Function
SELECT 
    doc.doctor_name AS 'Doctor Name',
    doc.specialization AS 'Specialization',
    COUNT(a.appointment_id) AS 'Total Appointments',
    DENSE_RANK() OVER (
        PARTITION BY doc.specialization 
        ORDER BY COUNT(a.appointment_id) DESC
    ) AS 'Rank Within Specialization'
FROM Doctors doc
INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
GROUP BY doc.doctor_id, doc.doctor_name, doc.specialization;


-- The Test Baseline Query (Slow query)
SELECT 
    d.doctor_id,
    d.doctor_name,
    (
        SELECT SUM(t.treatment_cost) 
        FROM Appointments a 
        INNER JOIN Treatments t ON a.appointment_id = t.appointment_id
        WHERE a.doctor_id = d.doctor_id
    ) AS total_revenue
FROM Doctors d
WHERE d.doctor_name = 'Dr. Smith';

-- Fast Query with indexing and stroed procedure
-- Step Prevent full-table scans at scale
CREATE INDEX idx_appointments_doctor ON Appointments(doctor_id);

-- Step  Encapsulate into a pre-compiled structure
DELIMITER //
CREATE PROCEDURE GetDoctorRevenuePerformance(IN target_doctor_id INT)
BEGIN
    SELECT 
        d.doctor_id,
        d.doctor_name,
        COALESCE(SUM(t.treatment_cost), 0.00) AS total_revenue
    FROM Doctors d
    INNER JOIN Appointments a ON d.doctor_id = a.doctor_id
    INNER JOIN Treatments t ON a.appointment_id = t.appointment_id
    WHERE d.doctor_id = target_doctor_id
    GROUP BY d.doctor_id, d.doctor_name;
END //
DELIMITER ;

-- calling stroed procedure
CALL GetDoctorRevenuePerformance(1);





