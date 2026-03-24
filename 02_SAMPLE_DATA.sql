-- Sample Data for Projects
INSERT INTO projects (project_id, project_name, start_date, end_date) VALUES 
(1, 'Project Alpha', '2026-01-10', '2026-12-15'),
(2, 'Project Beta', '2026-02-20', '2026-11-30'),
(3, 'Project Gamma', '2026-03-01', '2026-10-01');

-- Sample Data for Organizations
INSERT INTO organizations (org_id, org_name) VALUES 
(1, 'Org One'),
(2, 'Org Two'),
(3, 'Org Three'),
(4, 'Org Four'),
(5, 'Org Five'),
(6, 'Org Six');

-- Sample Data for Resources
INSERT INTO resources (resource_id, resource_name) VALUES 
(1, 'Resource A'),
(2, 'Resource B'),
(3, 'Resource C'),
(4, 'Resource D'),
(5, 'Resource E'),
(6, 'Resource F');

-- Sample Data for Apartment Units
INSERT INTO apartment_units (unit_id, project_id, unit_number) VALUES 
(1, 1, 'A101'),
(2, 1, 'A102'),
(3, 2, 'B201'),
(4, 3, 'C301');

-- Sample Data for Line Items
INSERT INTO line_items (line_item_id, project_id, description, amount) VALUES 
(1, 1, 'Concrete Supply', 2000.00),
(2, 1, 'Labor Costs', 1500.00),
(3, 2, 'Steel Fabrication', 3000.00),
(4, 2, 'Electrical Wiring', 1800.00),
(5, 3, 'Roof Installation', 2200.00);

-- Sample Data for Time Entries
INSERT INTO time_entries (entry_id, resource_id, hours_worked, project_id) VALUES 
(1, 1, 8, 1),
(2, 2, 6, 1),
(3, 3, 7, 2),
(4, 4, 5, 2),
(5, 5, 4, 3);

-- Sample Cost Transactions
INSERT INTO cost_transactions (transaction_id, project_id, amount, transaction_date) VALUES
(1, 1, 2000.00, '2026-03-01'),
(2, 2, 3000.00, '2026-03-15'),
(3, 3, 2200.00, '2026-03-20');

-- Sample Invoices
INSERT INTO invoices (invoice_id, project_id, amount, invoice_date) VALUES
(1, 1, 3500.00, '2026-03-02'),
(2, 2, 4500.00, '2026-03-16'),
(3, 3, 3200.00, '2026-03-21');

-- Sample Payables
INSERT INTO payables (payable_id, org_id, amount, due_date) VALUES
(1, 1, 500.00, '2026-04-01'),
(2, 2, 750.00, '2026-04-05'),
(3, 3, 600.00, '2026-04-10');

-- Sample Receivables
INSERT INTO receivables (receivable_id, org_id, amount, due_date) VALUES
(1, 5, 1000.00, '2026-04-15'),
(2, 6, 1200.00, '2026-04-20');

-- Sample Salesman Performance Records
INSERT INTO salesman_performance (record_id, salesman_id, total_sales, performance_date) VALUES
(1, 1, 15000.00, '2026-03-01'),
(2, 2, 18000.00, '2026-03-15');

-- Sample Supplier Performance Data
INSERT INTO supplier_performance (supplier_id, project_id, satisfaction_rating) VALUES
(1, 1, 4.5),
(2, 2, 4.0);