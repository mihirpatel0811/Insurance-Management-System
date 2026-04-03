-- Active: 1772796517242@@127.0.0.1@3306@insurance_db
--create & use the database
CREATE DATABASE insurance_db;
USE insurance_db;

--create the insurance regarding tables

--Table for admin login
CREATE TABLE admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

-- Table for insurance types
CREATE TABLE insurance_type (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(255) NOT NULL
);

-- Table for insurance companies
CREATE TABLE insurance_company (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255)
);

-- Table for insurance policies
CREATE TABLE insurance_policy (
    policy_id INT PRIMARY KEY AUTO_INCREMENT,
    policy_name VARCHAR(255) NOT NULL,
    company_id INT,
    type_id INT,
    coverage_amount DECIMAL(10, 2),
    premium DECIMAL(10, 2),
    FOREIGN KEY (company_id) REFERENCES insurance_company(company_id),
    FOREIGN KEY (type_id) REFERENCES insurance_type(type_id)
);

-- Table for customers
CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

-- Table for customer policies (many-to-many relationship)
CREATE TABLE customer_policy (
    customer_id INT,
    policy_id INT,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY (customer_id, policy_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (policy_id) REFERENCES insurance_policy(policy_id)
);

-- Table for claims
CREATE TABLE claim (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    policy_id INT,
    claim_date DATE,
    claim_amount DECIMAL(10, 2),
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (policy_id) REFERENCES insurance_policy(policy_id)
);

--Insert of admin login data
INSERT INTO admin (username, password) VALUES ('admin', 'admin@123');