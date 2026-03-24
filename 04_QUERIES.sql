-- Project Queries
-- 1. Get all projects
SELECT * FROM projects;

-- 2. Get project by ID
SELECT * FROM projects WHERE id = ?;

-- 3. Get projects by status
SELECT * FROM projects WHERE status = ?;

-- 4. Count of projects per status
SELECT status, COUNT(*) FROM projects GROUP BY status;


-- Line Item Queries
-- 1. Get all line items for a project
SELECT * FROM line_items WHERE project_id = ?;

-- 2. Get line item by ID
SELECT * FROM line_items WHERE id = ?;

-- 3. Get total cost of line items for a project
SELECT SUM(cost) FROM line_items WHERE project_id = ?;


-- Resource Queries
-- 1. Get all resources
SELECT * FROM resources;

-- 2. Get resource by ID
SELECT * FROM resources WHERE id = ?;

-- 3. Get resources allocated to a project
SELECT r.* FROM resources r JOIN line_items li ON r.id = li.resource_id WHERE li.project_id = ?;

-- 4. Get total hours worked by a resource
SELECT SUM(hours) FROM time_tracking WHERE resource_id = ?;


-- Time Tracking Queries
-- 1. Get all time entries for a project
SELECT * FROM time_tracking WHERE project_id = ?;

-- 2. Get time entries by resource
SELECT * FROM time_tracking WHERE resource_id = ?;

-- 3. Total number of hours tracked for a project
SELECT SUM(hours) FROM time_tracking WHERE project_id = ?;


-- Apartment Unit Queries
-- 1. Get all apartment units
SELECT * FROM apartment_units;

-- 2. Get apartment unit by ID
SELECT * FROM apartment_units WHERE id = ?;

-- 3. Get available apartment units
SELECT * FROM apartment_units WHERE availability = 'available';

-- 4. Get total count of apartment units by status
SELECT status, COUNT(*) FROM apartment_units GROUP BY status;


-- Financial Queries
-- 1. Get total project budget
SELECT SUM(budget) FROM projects;

-- 2. Get total expenses for a project
SELECT SUM(expense) FROM financial_records WHERE project_id = ?;

-- 3. Get financial summary by project
SELECT p.id, p.name, SUM(fr.expense) as total_expense FROM projects p JOIN financial_records fr ON p.id = fr.project_id GROUP BY p.id;

-- 4. Get total funding received for a project
SELECT SUM(amount) FROM funding WHERE project_id = ?;

-- 5. Financial performance ratio (expenses vs budget)
SELECT (SELECT SUM(expense) FROM financial_records WHERE project_id = ?) / (SELECT budget FROM projects WHERE id = ?) AS performance_ratio;


-- Performance Queries
-- 1. Get project performance metrics
SELECT id, name, status, completion_date, (SELECT COUNT(*) FROM time_tracking WHERE project_id = p.id) AS total_hours_tracked FROM projects p;

-- 2. Get line item performance
SELECT li.id, li.name, SUM(tt.hours) AS total_hours FROM line_items li LEFT JOIN time_tracking tt ON li.id = tt.line_item_id GROUP BY li.id;

-- 3. Get resource utilization
SELECT resource_id, SUM(hours) AS total_hours FROM time_tracking GROUP BY resource_id;

-- 4. Get project completion status
SELECT id, name, DATEDIFF(completion_date, start_date) AS duration FROM projects WHERE status = 'completed';