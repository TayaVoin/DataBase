-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Демонстрация работы функций и триггеров
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- 1. Проверка функции классификации аварии
SELECT classify_alert_severity(95, 'cpu_usage') AS severity;   -- CRITICAL
SELECT classify_alert_severity(75, 'cpu_usage') AS severity;   -- WARNING
SELECT classify_alert_severity(50, 'cpu_usage') AS severity;   -- INFO
SELECT classify_alert_severity(90, 'unknown') AS severity;     -- UNKNOWN

-- 2. Проверка функции доступности устройства
SELECT device_id, device_name, get_device_availability(device_id) AS availability
FROM devices
WHERE device_id IN (1, 2, 3)
ORDER BY device_id;

-- 3. Демонстрация работы триггера:
--    Вставляем метрику, которая превышает порог
--    Триггер должен автоматически создать аварию

-- Посмотрим текущее количество аварий
SELECT COUNT(*) AS alerts_before FROM alerts;

-- Вставляем метрику с превышением (device_id=3, threshold_id=1 (cpu_usage), значение 92 > critical 90)
INSERT INTO metrics (device_id, threshold_id, metric_value, collected_at)
VALUES (3, 1, 92, NOW());

-- Проверяем, что создалась новая авария
SELECT COUNT(*) AS alerts_after FROM alerts;

-- Смотрим созданную аварию
SELECT a.alert_id, d.device_name, a.severity, a.message, a.triggered_at, ast.status_name
FROM alerts a
JOIN devices d ON a.device_id = d.device_id
JOIN alert_statuses ast ON a.status_id = ast.status_id
ORDER BY a.alert_id DESC
LIMIT 1;

-- 4. Демонстрация работы второго триггера: trg_alerts_update_timestamp
--    Триггер должен автоматически обновлять resolved_at при закрытии аварии

-- Посмотрим текущее состояние аварии с id = 1 (до изменений)
SELECT alert_id, status_id, resolved_at FROM alerts WHERE alert_id = 1;

-- Закрываем аварию (меняем статус на RESOLVED)
UPDATE alerts SET status_id = (SELECT status_id FROM alert_statuses WHERE status_name = 'RESOLVED')
WHERE alert_id = 1;

-- Проверяем, что resolved_at автоматически установился
SELECT alert_id, status_id, resolved_at FROM alerts WHERE alert_id = 1;

-- Возвращаем аварию в работу (меняем статус обратно на IN_PROGRESS)
UPDATE alerts SET status_id = (SELECT status_id FROM alert_statuses WHERE status_name = 'IN_PROGRESS')
WHERE alert_id = 1;

-- Проверяем, что resolved_at сбросился в NULL
SELECT alert_id, status_id, resolved_at FROM alerts WHERE alert_id = 1;