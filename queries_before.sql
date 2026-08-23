-- name: available_dogs
SELECT a.* FROM animals a
JOIN animal_breeds b ON a.animal_breed_id = b.id
JOIN animal_species s ON b.animal_species_id = s.id
JOIN animal_states st ON a.animal_state_id = st.id
WHERE s.name = 'Собака' AND st.name = 'Ищет дом';

-- name: current_diseases
SELECT d.name as diagnosis, hr.treatment_start_date
FROM animal_health_records hr
JOIN diagnoses d ON hr.diagnosis_id = d.id
WHERE hr.animal_id = 1 AND hr.treatment_end_date IS NULL;

-- name: monthly_donations
SELECT
	TO_CHAR(date, 'YYYY-MM') as year_month,
	SUM(amount) as total_amount,
	COUNT(*) as donations_count
FROM donations
WHERE date >= NOW() - INTERVAL '2 years'
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY year_month ASC;

-- name: supplier_items
SELECT
	e.name as supplier_name,
	si.name as item_name,
	COUNT(srd.id) as delivery_count
FROM supply_records sr
JOIN suppliers s ON sr.supplier_id = s.id
JOIN entities e ON s.entity_id = e.id
JOIN supply_record_details srd ON sr.id = srd.supply_record_id
JOIN supply_items si ON srd.supply_item_id = si.id
WHERE sr.date >= NOW() - INTERVAL '1 year'
GROUP BY e.name, si.name
ORDER BY e.name, delivery_count DESC;

-- name: animal_medical_history
SELECT
	d.name as diagnosis,
	hr.treatment_start_date,
	hr.treatment_end_date,
	m.name as medication,
	t.medication_start_date,
	t.medication_end_date
FROM animal_health_records hr
JOIN diagnoses d ON hr.diagnosis_id = d.id
JOIN treatments t ON hr.id = t.animal_health_record_id
JOIN medications m ON t.medication_id = m.id
WHERE hr.animal_id = 1
ORDER BY hr.treatment_start_date ASC, t.medication_start_date ASC;

-- name: manager_hiring_history
SELECT
	e.name as manager_name,
	ed.working_start_date as hire_date,
	ed.working_end_date as termination_date
FROM employees emp
JOIN entities e ON emp.entity_id = e.id
JOIN employee_details ed ON emp.id = ed.employee_id
JOIN jobs j ON ed.job_id = j.id
WHERE j.name = 'Менеджер'
ORDER BY ed.working_start_date ASC;