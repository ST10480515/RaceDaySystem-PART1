CREATE DATABASE RaceDaySystem;

CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    CreatedAt DATETIME DEFAULT GETDATE()
);


CREATE TABLE dbo.Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    EventName NVARCHAR(200) NOT NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    RegistrationDeadline DATETIME NULL,
    MaxParticipants INT DEFAULT 100,
    CurrentParticipants INT DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'Upcoming' CHECK (Status IN ('Upcoming', 'Ongoing', 'Completed', 'Cancelled')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserID) REFERENCES dbo.Users(UserID)
);


CREATE TABLE dbo.Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Distance DECIMAL(8,2) NOT NULL,
    DistanceUnit NVARCHAR(20) DEFAULT 'km',
    Description NVARCHAR(500) NULL,
    MinAge INT NULL,
    MaxAge INT NULL,
    MaxParticipants INT DEFAULT 50,
    CurrentParticipants INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID) ON DELETE CASCADE
);



CREATE TABLE dbo.EventEnrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    UserID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Withdrawn', 'Disqualified')),
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Refunded')),
    RegistrationNumber NVARCHAR(50) NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventID) REFERENCES dbo.Events(EventID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID)
);



CREATE TABLE dbo.Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Currency NVARCHAR(3) DEFAULT 'ZAR',
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50) NOT NULL,
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,
    CONSTRAINT FK_Payments_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES dbo.EventEnrolments(EnrolmentID) ON DELETE CASCADE
);


CREATE TABLE dbo.Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL,
    FinishTime TIME NULL,
    FinishTimeSeconds INT NULL,
    Position INT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Completed', 'DNS', 'Disqualified')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES dbo.EventEnrolments(EnrolmentID) ON DELETE CASCADE
);


-- Insert Users 

INSERT INTO dbo.Users (FullName, Email, Password, Role, CreatedAt) VALUES
('BOITU MAHLAKO', 'boitu.mahlako@raceday.com', 'hashed_password_1', 'Organiser', GETDATE()),
('Sarah Johnson', 'sarah.johnson@raceday.com', 'hashed_password_2', 'Organiser', GETDATE()),
('AKANI SIMBINE', 'akani.simbine@gmail.com', 'hashed_password_3', 'Participant', GETDATE()),
('BAYANDA WALAZA', 'bayanda.walaza@gmail.com', 'hashed_password_4', 'Participant', GETDATE()),
('GLENROSE XABA', 'glenrose.xaba@gmail.com', 'hashed_password_5', 'Participant', GETDATE()),
('LISA TAYLOR', 'lisa.taylor@gmail.com', 'hashed_password_6', 'Participant', GETDATE());

-- Insert Events
INSERT INTO dbo.Events (OrganiserID, EventName, EventDate, Location, Description, RegistrationDeadline, MaxParticipants, Status) VALUES
(1, 'Cape Town Marathon 2026', '2026-10-15 06:00:00', 'Cape Town, South Africa', 'Annual marathon through the beautiful streets of Cape Town', '2026-10-01 23:59:59', 5000, 'Upcoming'),
(1, 'Cape Town 10km Challenge', '2026-11-05 07:00:00', 'Cape Town Waterfront, South Africa', 'Fast and flat 10km race along the Cape Town waterfront', '2026-10-20 23:59:59', 2000, 'Upcoming'),
(2, 'Joburg Night Run', '2026-12-01 19:00:00', 'Johannesburg, South Africa', 'Exciting night run through the streets of Johannesburg', '2026-11-15 23:59:59', 3000, 'Upcoming');


-- Insert Categories
INSERT INTO dbo.Categories (EventID, CategoryName, Distance, Description, MinAge, MaxAge, MaxParticipants) VALUES
-- Cape Town Marathon Categories (EventID = 1)
(1, 'Full Marathon', 42.20, 'Full marathon distance of 42.2km', 18, 99, 2000),
(1, 'Half Marathon', 21.10, 'Half marathon distance of 21.1km', 16, 99, 1500),
(1, '10km Fun Run', 10.00, '10km fun run for all ages', 6, 99, 1500),
-- Cape Town 10km Challenge Categories (EventID = 2)
(2, 'Elite 10km', 10.00, 'Competitive 10km for elite runners', 18, 40, 500),
(2, 'Open 10km', 10.00, 'Open category for all runners', 18, 99, 1000),
(2, 'Youth 10km', 10.00, 'Youth category', 12, 17, 500),
-- Joburg Night Run Categories (EventID = 3)
(3, 'Night 10km', 10.00, '10km night race', 18, 99, 1000),
(3, 'Night 5km', 5.00, '5km night family run', 8, 99, 2000);


-- Insert Event Enrolments
INSERT INTO dbo.EventEnrolments (EventID, UserID, CategoryID, Status, PaymentStatus, RegistrationNumber, EnrolmentDate) VALUES
-- AKANI SIMBINE (UserID = 3) enrolments
(1, 3, 1, 'Confirmed', 'Paid', 'REG-2026-001', GETDATE()),
(2, 3, 4, 'Pending', 'Unpaid', NULL, GETDATE()),
-- BAYANDA WALAZA (UserID = 4) enrolments
(1, 4, 2, 'Confirmed', 'Paid', 'REG-2026-002', GETDATE()),
(3, 4, 7, 'Confirmed', 'Paid', 'REG-2026-003', GETDATE()),
-- GLENROSE XABA (UserID = 5) enrolments
(2, 5, 5, 'Confirmed', 'Paid', 'REG-2026-004', GETDATE()),
(3, 5, 8, 'Pending', 'Unpaid', NULL, GETDATE()),
-- LISA TAYLOR (UserID = 6) enrolments
(1, 6, 3, 'Confirmed', 'Paid', 'REG-2026-005', GETDATE()),
(3, 6, 8, 'Confirmed', 'Paid', 'REG-2026-006', GETDATE());


-- Insert Payments
INSERT INTO dbo.Payments (EnrolmentID, Amount, Currency, PaymentMethod,  PaymentStatus, PaymentDate) VALUES
(1, 50.00, 'ZAR', 'Credit Card',  'Completed', GETDATE()),
(2, 30.00, 'ZAR', 'PayPal',  'Completed', GETDATE()),
(3, 40.00, 'ZAR', 'Bank Transfer',  'Completed', GETDATE()),
(4, 45.00, 'ZAR', 'Credit Card',  'Completed', GETDATE()),
(5, 35.00, 'ZAR', 'PayPal',  'Completed', GETDATE()),
(7, 25.00, 'ZAR', 'Credit Card',  'Completed', GETDATE());

-- Insert Results
INSERT INTO dbo.Results (EnrolmentID, FinishTime, FinishTimeSeconds, Position,  Status ) VALUES
(1, '03:45:30', 13530, 156,  'Completed' ),
(3, '01:55:15', 6915, 245,  'Completed'),
(5, '00:52:45', 3165, 89,  'Completed');


