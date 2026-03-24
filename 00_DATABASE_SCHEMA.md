# Database Schema Documentation

## Core Tables

### 1. users
- **id**: Primary Key, Integer
- **username**: Varchar, Unique
- **email**: Varchar, Unique
- **password**: Varchar
- **created_at**: Timestamp
- **updated_at**: Timestamp

### 2. projects
- **id**: Primary Key, Integer
- **name**: Varchar
- **description**: Text
- **start_date**: Date
- **end_date**: Date
- **user_id**: Foreign Key, Integer
- **created_at**: Timestamp
- **updated_at**: Timestamp

### 3. tasks
- **id**: Primary Key, Integer
- **name**: Varchar
- **status**: Varchar
- **project_id**: Foreign Key, Integer
- **assigned_to**: Foreign Key, Integer
- **created_at**: Timestamp
- **updated_at**: Timestamp

### 4. comments
- **id**: Primary Key, Integer
- **task_id**: Foreign Key, Integer
- **user_id**: Foreign Key, Integer
- **comment**: Text
- **created_at**: Timestamp

### 5. attachments
- **id**: Primary Key, Integer
- **task_id**: Foreign Key, Integer
- **file_path**: Varchar
- **created_at**: Timestamp

### 6. notifications
- **id**: Primary Key, Integer
- **user_id**: Foreign Key, Integer
- **message**: Text
- **created_at**: Timestamp

### 7. budgets
- **id**: Primary Key, Integer
- **project_id**: Foreign Key, Integer
- **amount**: Decimal
- **created_at**: Timestamp

### 8. invoices
- **id**: Primary Key, Integer
- **project_id**: Foreign Key, Integer
- **amount**: Decimal
- **due_date**: Date
- **created_at**: Timestamp

### 9. payments
- **id**: Primary Key, Integer
- **invoice_id**: Foreign Key, Integer
- **amount**: Decimal
- **payment_date**: Date

### 10. resources
- **id**: Primary Key, Integer
- **project_id**: Foreign Key, Integer
- **name**: Varchar
- **role**: Varchar

### 11. timesheets
- **id**: Primary Key, Integer
- **user_id**: Foreign Key, Integer
- **project_id**: Foreign Key, Integer
- **hours_worked**: Decimal
- **date**: Date

### 12. roles
- **id**: Primary Key, Integer
- **user_id**: Foreign Key, Integer
- **role_name**: Varchar

### 13. settings
- **id**: Primary Key, Integer
- **key**: Varchar, Unique
- **value**: Varchar

## Lookup Tables

### 1. statuses
- **id**: Primary Key, Integer
- **name**: Varchar, Unique
- **description**: Text

### 2. roles
- **id**: Primary Key, Integer
- **name**: Varchar, Unique
- **permissions**: JSON

### 3. priorities
- **id**: Primary Key, Integer
- **level**: Varchar, Unique

### 4. types
- **id**: Primary Key, Integer
- **name**: Varchar, Unique
- **description**: Text

### 5. currencies
- **id**: Primary Key, Integer
- **code**: Varchar, Unique
- **symbol**: Varchar

## Table Relationships
- A user can have multiple projects (One-to-Many).
- A project can have multiple tasks (One-to-Many).
- A task can have many comments (One-to-Many).
- A project can have many resources (One-to-Many).
- An invoice belongs to one project (Many-to-One).

## Entity-Relationship (ER) Diagram
Descriptive text for the ER diagram goes here, outlining how the entities are related structurally. For visual ER diagrams, consider using tools such as draw.io or Lucidchart.