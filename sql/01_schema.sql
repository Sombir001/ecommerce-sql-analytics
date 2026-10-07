-- =========================================================
-- E-Commerce Sales & Customer Intelligence
-- Database Schema
-- MySQL 8+
-- =========================================================

CREATE DATABASE IF NOT EXISTS final_project_ecommerce;
USE final_project_ecommerce;

CREATE TABLE Regions (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(100),
    Country VARCHAR(100)
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(30),
    RegionID INT,
    CreatedAt DATE,
    FOREIGN KEY (RegionID)
        REFERENCES Regions(RegionID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    IsReturned BOOLEAN,
    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
