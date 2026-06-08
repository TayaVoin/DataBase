-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Запросы (устройства, метрики, топология)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 1. Список всех активных устройств
SELECT device_id, device_name, serial_number, ip_address, status
FROM devices
WHERE status = 'active'
ORDER BY device_name;

-- 2. Поиск устройств по городу (JOIN)
SELECT d.device_name, d.ip_address, s.city, s.site_name
FROM devices d
JOIN sites s ON d.site_id = s.site_id
WHERE s.city = 'Москва';

-- 3. Количество устройств по типам (агрегация GROUP BY)
SELECT dt.type_name, COUNT(*) AS device_count
FROM devices d
JOIN device_types dt ON d.device_type_id = dt.device_type_id
GROUP BY dt.type_name
ORDER BY device_count DESC;

-- 4. Устройства с превышением порога CPU (JOIN с фильтрацией)
SELECT d.device_name, m.metric_value, mt.warning_value, mt.critical_value
FROM metrics m
JOIN devices d ON m.device_id = d.device_id
JOIN metric_thresholds mt ON m.threshold_id = mt.threshold_id
WHERE mt.metric_type = 'cpu_usage' AND m.metric_value > mt.warning_value;

-- 5. Топология сети (список связей между устройствами)
SELECT d1.device_name AS source, d2.device_name AS target, 
       dc.connection_type, dc.bandwidth_mbps
FROM device_connections dc
JOIN devices d1 ON dc.source_device_id = d1.device_id
JOIN devices d2 ON dc.target_device_id = d2.device_id;

-- 6. Средние метрики по устройствам (GROUP BY + HAVING)
SELECT d.device_name, mt.metric_type, AVG(m.metric_value) AS avg_value
FROM metrics m
JOIN devices d ON m.device_id = d.device_id
JOIN metric_thresholds mt ON m.threshold_id = mt.threshold_id
GROUP BY d.device_name, mt.metric_type
HAVING AVG(m.metric_value) > 50;

-- 7. Устройства с максимальной метрикой выше критического порога (подзапрос)
SELECT d.device_name, mt.metric_type, MAX(m.metric_value) AS max_value, mt.critical_value
FROM metrics m
JOIN devices d ON m.device_id = d.device_id
JOIN metric_thresholds mt ON m.threshold_id = mt.threshold_id
GROUP BY d.device_name, mt.metric_type, mt.critical_value
HAVING MAX(m.metric_value) > mt.critical_value;

-- 8. Метрики за последние 24 часа (CTE)
WITH recent_metrics AS (
    SELECT device_id, threshold_id, metric_value, collected_at
    FROM metrics
    WHERE collected_at > NOW() - INTERVAL '24 hours'
)
SELECT d.device_name, mt.metric_type, rm.metric_value, rm.collected_at
FROM recent_metrics rm
JOIN devices d ON rm.device_id = d.device_id
JOIN metric_thresholds mt ON rm.threshold_id = mt.threshold_id
ORDER BY rm.collected_at DESC;

-- 9. Топ-5 устройств по количеству критических аварий (ORDER BY + LIMIT)
SELECT d.device_name, COUNT(a.alert_id) AS critical_alerts
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
WHERE a.severity = 'CRITICAL'
GROUP BY d.device_name
ORDER BY critical_alerts DESC
LIMIT 5;

-- 10. Доступность устройств (вызов функции get_device_availability)
SELECT device_id, device_name, get_device_availability(device_id) AS availability_percent
FROM devices
WHERE status = 'active'
ORDER BY availability_percent DESC;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ЗАПРОСЫ СТУДЕНТА 2 (аварии, инженеры, обслуживание)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 1. Список всех открытых аварий
SELECT a.alert_id, d.device_name, a.severity, a.message, a.triggered_at, ast.status_name
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
JOIN alert_statuses ast ON a.status_id = ast.status_id
WHERE ast.status_name IN ('NEW', 'IN_PROGRESS')
ORDER BY a.triggered_at DESC;

-- 2. Инженеры и их закреплённые устройства (JOIN)
SELECT e.first_name, e.last_name, e.role, d.device_name, d.status AS device_status
FROM engineer_assignments ea
JOIN engineers e ON ea.engineer_id = e.engineer_id
JOIN devices d ON ea.device_id = d.device_id
ORDER BY e.last_name;

-- 3. Количество задач по инженерам (агрегация GROUP BY)
SELECT e.first_name, e.last_name, COUNT(mt.task_id) AS task_count
FROM maintenance_tasks mt
JOIN engineers e ON mt.engineer_id = e.engineer_id
GROUP BY e.engineer_id
ORDER BY task_count DESC;

-- 4. Задачи с просроченным сроком (условие + JOIN)
SELECT mt.task_id, d.device_name, mt.task_type, mt.scheduled_date, mt.status
FROM maintenance_tasks mt
JOIN devices d ON mt.device_id = d.device_id
WHERE mt.scheduled_date < CURRENT_DATE AND mt.status = 'PENDING';

-- 5. История изменений аварии (с подзапросом)
SELECT ah.alert_id, 
       (SELECT status_name FROM alert_statuses WHERE status_id = ah.old_status_id) AS old_status,
       (SELECT status_name FROM alert_statuses WHERE status_id = ah.new_status_id) AS new_status,
       e.first_name || ' ' || e.last_name AS changed_by,
       ah.changed_at
FROM alert_history ah
JOIN engineers e ON ah.changed_by = e.engineer_id
ORDER BY ah.alert_id, ah.changed_at;

-- 6. Агрегация: среднее время закрытия аварии по критичности (GROUP BY + HAVING)
SELECT severity, AVG(EXTRACT(EPOCH FROM (resolved_at - triggered_at)) / 3600) AS avg_resolution_hours
FROM alerts
WHERE resolved_at IS NOT NULL
GROUP BY severity
HAVING AVG(EXTRACT(EPOCH FROM (resolved_at - triggered_at)) / 3600) IS NOT NULL;

-- 7. CTE: инженеры, у которых больше 2 закреплённых устройств
WITH engineer_device_count AS (
    SELECT engineer_id, COUNT(device_id) AS device_count
    FROM engineer_assignments
    GROUP BY engineer_id
)
SELECT e.first_name, e.last_name, edc.device_count
FROM engineer_device_count edc
JOIN engineers e ON edc.engineer_id = e.engineer_id
WHERE edc.device_count > 2;

-- 8. Топ-3 инженеров по закрытым задачам (ORDER BY + LIMIT)
SELECT e.first_name, e.last_name, COUNT(mt.task_id) AS completed_tasks
FROM maintenance_tasks mt
JOIN engineers e ON mt.engineer_id = e.engineer_id
WHERE mt.status = 'COMPLETED'
GROUP BY e.engineer_id
ORDER BY completed_tasks DESC
LIMIT 3;

-- 9. Сводка по авариям за последние 30 дней (агрегация)
SELECT DATE(triggered_at) AS alert_date, severity, COUNT(*) AS alert_count
FROM alerts
WHERE triggered_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(triggered_at), severity
ORDER BY alert_date DESC, severity;

-- 10. Инженеры, которые не назначены на задачи (подзапрос NOT IN)
SELECT e.engineer_id, e.first_name, e.last_name, e.role
FROM engineers e
WHERE e.engineer_id NOT IN (SELECT DISTINCT engineer_id FROM maintenance_tasks);