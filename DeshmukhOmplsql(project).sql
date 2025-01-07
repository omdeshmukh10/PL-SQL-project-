CREATE DATABASE VehicleParkingDB;
use VehicleParkingDB;

CREATE TABLE Users ( 
    UserID NUMBER PRIMARY KEY, 
    Username VARCHAR2(50) NOT NULL, 
    Password VARCHAR2(50) NOT NULL, 
    Role VARCHAR2(20) CHECK (Role IN ('Admin', 'Attendant')) 
);

describe Users;

INSERT INTO Users (UserID, Username, Password, Role) 
VALUES (1, 'admin', 'admin123', 'Admin');

INSERT INTO Users (UserID, Username, Password, Role) 
VALUES (2, 'attendant1', 'pass123', 'Attendant');



select * from Users;


CREATE TABLE ParkingSlots ( 
    SlotID NUMBER PRIMARY KEY, 
    SlotType VARCHAR2(20) NOT NULL, -- e.g., Small, Medium, Large 
    IsAvailable CHAR(1) DEFAULT 'Y' CHECK (IsAvailable IN ('Y', 'N')) 
);

INSERT INTO ParkingSlots (SlotID, SlotType) 
VALUES (101, 'Small');

INSERT INTO ParkingSlots (SlotID, SlotType) 
VALUES (102, 'Medium');



CREATE TABLE Vehicles ( 
    VehicleNumber VARCHAR2(20) PRIMARY KEY, 
    VehicleType VARCHAR2(20), -- e.g., Car, Bike, Truck 
    OwnerName VARCHAR2(50) 
);

INSERT INTO Vehicles (VehicleNumber, VehicleType, OwnerName) 
VALUES ('MH12AB1234', 'Car', 'John Doe');

INSERT INTO Vehicles (VehicleNumber, VehicleType, OwnerName) 
VALUES ('MH12AB1234', 'Car', 'John Doe');



CREATE TABLE Transactions ( 
    TransactionID NUMBER PRIMARY KEY, 
    VehicleNumber VARCHAR2(20) REFERENCES Vehicles(VehicleNumber), 
    SlotID NUMBER REFERENCES ParkingSlots(SlotID), 
    EntryTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ExitTime TIMESTAMP, 
    Charges NUMBER 
);

INSERT INTO Transactions (TransactionID, VehicleNumber, SlotID) 
VALUES (1, 'MH12AB1234', 101);

select * from Vehicles;

select * from ParkingSlots;

select * from Vehicles;

select * from Transactions;

CREATE VIEW AvailableSlots AS
SELECT SlotID, SlotType
FROM ParkingSlots
WHERE IsAvailable = 'Y';


/*Write PL/SQL Procedures:
Add new parking slots:*/

CREATE OR REPLACE PROCEDURE AddParkingSlot (
    p_SlotID IN NUMBER, 
    p_SlotType IN VARCHAR2
) IS
BEGIN
    INSERT INTO ParkingSlots (SlotID, SlotType, IsAvailable)
    VALUES (p_SlotID, p_SlotType, 'Y');
END;

--Create a Function to Calculate Charges:
CREATE OR REPLACE FUNCTION CalculateCharges (
    p_EntryTime IN TIMESTAMP, 
    p_ExitTime IN TIMESTAMP
) RETURN NUMBER IS
    duration NUMBER;
    charges NUMBER;
BEGIN
    -- Extract hours from the interval between the two timestamps
    duration := EXTRACT(DAY FROM (p_ExitTime - p_EntryTime)) * 24 + 
                EXTRACT(HOUR FROM (p_ExitTime - p_EntryTime)) +
                EXTRACT(MINUTE FROM (p_ExitTime - p_EntryTime)) / 60;

    -- Calculate charges
    charges := duration * 10; -- ₹10/hour

    -- Return the calculated charges
    RETURN charges;
END;
/


--Add Triggers
--Trigger to Update Slot Availability on Vehicle Entry

CREATE OR REPLACE TRIGGER UpdateSlotOnEntry
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    UPDATE ParkingSlots
    SET IsAvailable = 'N'
    WHERE SlotID = :NEW.SlotID;
END;

--Trigger to Update Charges on Vehicle Exit

CREATE OR REPLACE TRIGGER UpdateChargesOnExit
BEFORE UPDATE ON Transactions
FOR EACH ROW
BEGIN
    :NEW.Charges := CalculateCharges(:OLD.EntryTime, :NEW.ExitTime);
END;



SELECT * FROM Transactions;
SELECT * FROM AvailableSlots;





