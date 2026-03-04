-- ================================================
-- Library System Database
-- ================================================
CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

-- Tables
CREATE TABLE Books (
    BookID      INT PRIMARY KEY IDENTITY(1,1),
    Title       NVARCHAR(100) NOT NULL,
    Author      NVARCHAR(100) NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Members (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Phone    NVARCHAR(20)  NOT NULL
);
GO

CREATE TABLE Borrows (
    BorrowID   INT PRIMARY KEY IDENTITY(1,1),
    BookID     INT  NOT NULL FOREIGN KEY REFERENCES Books(BookID),
    MemberID   INT  NOT NULL FOREIGN KEY REFERENCES Members(MemberID),
    BorrowDate DATE NOT NULL DEFAULT GETDATE(),
    ReturnDate DATE NULL
);
GO

-- Seed Data
INSERT INTO Books (Title, Author) VALUES
('C# Programming',   'Ahmed Ali'),
('Clean Code',       'Robert Martin'),
('Java Basics',      'Mohamed Saad'),
('Python Crash',     'Youssef Omar'),
('SQL Server Guide', 'Ehab Hassan');
GO

INSERT INTO Members (FullName, Phone) VALUES
('Omar Khaled', '01001234567'),
('Sara Ahmed',  '01109876543'),
('Ali Mohamed', '01223344556');
GO

-- View
CREATE VIEW AvailableBooks AS
    SELECT BookID, Title, Author FROM Books WHERE IsAvailable = 1;
GO

-- SP: Borrow
CREATE PROCEDURE SP_BorrowBook @BookID INT, @MemberID INT AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsAvailable = 1)
    BEGIN PRINT 'Book not available.'; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM Members WHERE MemberID = @MemberID)
    BEGIN PRINT 'Member not found.'; RETURN; END

    INSERT INTO Borrows (BookID, MemberID, BorrowDate) VALUES (@BookID, @MemberID, GETDATE());
    UPDATE Books SET IsAvailable = 0 WHERE BookID = @BookID;
END
GO

-- SP: Return
CREATE PROCEDURE SP_ReturnBook @BorrowID INT AS
BEGIN
    DECLARE @BookID INT;
    SELECT @BookID = BookID FROM Borrows WHERE BorrowID = @BorrowID AND ReturnDate IS NULL;

    IF @BookID IS NULL BEGIN PRINT 'Borrow record not found.'; RETURN; END

    UPDATE Borrows SET ReturnDate = GETDATE() WHERE BorrowID = @BorrowID;
    UPDATE Books   SET IsAvailable = 1         WHERE BookID  = @BookID;
END
GO

-- Trigger: Prevent borrowing unavailable book
CREATE TRIGGER TR_PreventUnavailableBorrow ON Borrows INSTEAD OF INSERT AS
BEGIN
    DECLARE @BookID INT;
    SELECT @BookID = BookID FROM inserted;

    IF EXISTS (SELECT 1 FROM Books WHERE BookID = @BookID AND IsAvailable = 0)
    BEGIN RAISERROR('Cannot borrow: Book is already borrowed.', 16, 1); RETURN; END

    INSERT INTO Borrows (BookID, MemberID, BorrowDate)
    SELECT BookID, MemberID, BorrowDate FROM inserted;
END
GO
