-- sites (6 записи)
INSERT INTO sites (site_name, city, address) VALUES
('ЦО-1 Москва', 'Москва', 'ул. Тверская, 1'),
('БС-Новосибирск', 'Новосибирск', 'ул. Ленина, 10'),
('ЦО-2 Санкт-Петербург', 'Санкт-Петербург', 'Невский пр., 25');
INSERT INTO sites (site_name, city, address) VALUES
('БС-Екатеринбург', 'Екатеринбург', 'ул. Малышева, 15'),
('ЦО-Ростов-на-Дону', 'Ростов-на-Дону', 'пр. Будённовский, 40'),
('БС-Красноярск', 'Красноярск', 'ул. Мира, 20');

-- device_types (7 записи)
INSERT INTO device_types (type_name, category) VALUES
('gNB', 'RAN'),
('eNB', 'RAN'),
('Core Router', 'CORE'),
('BBU', 'RAN');
INSERT INTO device_types (type_name, category) VALUES
('Transport Switch', 'TRANSPORT'),
('Firewall', 'SECURITY'),
('DHCP Server', 'CORE');

-- devices (12 записей)
INSERT INTO devices (device_name, serial_number, ip_address, site_id, device_type_id, status) VALUES
('GNB-001', 'SN001', '10.0.1.1', 1, 1, 'active'),
('ENB-002', 'SN002', '10.0.1.2', 2, 2, 'active'),
('CR-001', 'SN003', '10.0.0.1', 1, 3, 'active'),
('GNB-002', 'SN004', '10.0.1.3', 3, 1, 'maintenance'),
('ENB-003', 'SN005', '10.0.1.4', 2, 2, 'active'),
('BBU-001', 'SN006', '10.0.2.1', 1, 4, 'active');
INSERT INTO devices (device_name, serial_number, ip_address, site_id, device_type_id, status) VALUES
('TS-001', 'SN007', '10.0.2.2', 1, 5, 'active'),
('FW-001', 'SN008', '10.0.0.254', 1, 6, 'active'),
('DHCP-001', 'SN009', '10.0.0.10', 1, 7, 'active'),
('GNB-003', 'SN010', '10.0.1.10', 4, 1, 'active'),
('ENB-004', 'SN011', '10.0.1.11', 5, 2, 'maintenance'),
('TS-002', 'SN012', '10.0.2.12', 6, 5, 'active');

-- device_connections (10 записи)
INSERT INTO device_connections (source_device_id, target_device_id, connection_type, bandwidth_mbps) VALUES
(1, 3, 'FIBER', 10000),
(2, 3, 'FIBER', 10000),
(4, 6, 'ETHERNET', 1000),
(5, 10, 'WIRELESS', 100);
INSERT INTO device_connections (source_device_id, target_device_id, connection_type, bandwidth_mbps) VALUES
(3, 7, 'FIBER', 10000),
(7, 8, 'ETHERNET', 1000),
(8, 9, 'ETHERNET', 1000),
(10, 11, 'FIBER', 10000),
(11, 12, 'WIRELESS', 100),
(6, 7, 'FIBER', 10000);

-- metric_thresholds (7 записи)
INSERT INTO metric_thresholds (metric_type, warning_value, critical_value, unit) VALUES
('cpu_usage', 70, 90, '%'),
('memory_usage', 80, 95, '%'),
('temperature', 70, 85, 'C'),
('throughput', 800, 1000, 'Mbps');
INSERT INTO metric_thresholds (metric_type, warning_value, critical_value, unit) VALUES
('disk_usage', 75, 90, '%'),
('packet_loss', 1, 5, '%'),
('latency', 50, 100, 'ms');

-- alert_statuses (4 записи)
INSERT INTO alert_statuses (status_name) VALUES
('NEW'), ('IN_PROGRESS'), ('RESOLVED'), ('CLOSED');

-- engineers (7 записи)
INSERT INTO engineers (first_name, last_name, email, role) VALUES
('Иван', 'Петров', 'i.petrov@noc.ru', 'NETWORK_ENGINEER'),
('Анна', 'Сидорова', 'a.sidorova@noc.ru', 'NOC_OPERATOR'),
('Алексей', 'Иванов', 'a.ivanov@noc.ru', 'SUPPORT'),
('Мария', 'Кузнецова', 'm.kuznetsova@noc.ru', 'NETWORK_ENGINEER');
INSERT INTO engineers (first_name, last_name, email, role) VALUES
('Дмитрий', 'Соколов', 'd.sokolov@noc.ru', 'NOC_OPERATOR'),
('Елена', 'Волкова', 'e.volkova@noc.ru', 'NETWORK_ENGINEER'),
('Сергей', 'Морозов', 's.morozov@noc.ru', 'SUPPORT');

-- metrics (20 записей)
INSERT INTO metrics (device_id, threshold_id, metric_value) VALUES
(1, 1, 85), (1, 2, 90), (2, 1, 45), (2, 3, 65), (3, 1, 95),
(3, 2, 88), (4, 1, 72), (5, 1, 50), (5, 3, 60), (6, 1, 30);
INSERT INTO metrics (device_id, threshold_id, metric_value) VALUES
(7, 1, 80), (7, 2, 85), (8, 1, 95), (8, 4, 850), (9, 1, 40),
(10, 3, 75), (11, 1, 60), (11, 5, 82), (12, 1, 55), (12, 6, 2);

-- alerts (10 записей)
INSERT INTO alerts (device_id, threshold_id, severity, message, status_id) VALUES
(1, 1, 'WARNING', 'CPU выше 70%', 1),
(3, 1, 'CRITICAL', 'CPU выше 90%', 2),
(2, 3, 'WARNING', 'Температура выше 70C', 3),
(4, 1, 'WARNING', 'CPU выше 70%', 1),
(5, 1, 'INFO', 'CPU в норме', 4);
INSERT INTO alerts (device_id, threshold_id, severity, message, status_id) VALUES
(7, 1, 'WARNING', 'CPU 80%', 1),
(8, 1, 'CRITICAL', 'CPU 95%', 2),
(8, 4, 'WARNING', 'Throughput 850 Mbps', 1),
(11, 5, 'WARNING', 'Disk usage 82%', 3),
(12, 6, 'WARNING', 'Packet loss 2%', 1);

-- engineer_assignments (12 записей)
INSERT INTO engineer_assignments (engineer_id, device_id) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5), (4, 6);
INSERT INTO engineer_assignments (engineer_id, device_id) VALUES
(5, 7), (5, 8), (6, 9), (6, 10), (7, 11), (7, 12);

-- maintenance_tasks (добавляем 10 записей)
INSERT INTO maintenance_tasks (device_id, engineer_id, alert_id, task_type, description, scheduled_date, completed_date, status) VALUES
(1, 1, NULL, 'PREVENTIVE', 'Плановое обновление ПО', '2025-06-10', NULL, 'PENDING'),
(2, 2, 3, 'CORRECTIVE', 'Замена вентилятора', '2025-06-05', '2025-06-06', 'COMPLETED'),
(3, 1, 2, 'CORRECTIVE', 'Оптимизация CPU', '2025-06-01', '2025-06-02', 'COMPLETED'),
(4, 2, 4, 'CORRECTIVE', 'Перезагрузка BBU', '2025-06-07', NULL, 'IN_PROGRESS'),
(5, 3, 5, 'PREVENTIVE', 'Резервное копирование', '2025-06-12', NULL, 'PENDING'),
(6, 4, NULL, 'PREVENTIVE', 'Обновление прошивки', '2025-06-15', NULL, 'PENDING'),
(7, 5, 6, 'CORRECTIVE', 'Замена термопасты', '2025-06-08', '2025-06-08', 'COMPLETED'),
(8, 5, 7, 'CORRECTIVE', 'Апгрейд процессора', '2025-06-09', NULL, 'IN_PROGRESS'),
(11, 6, 9, 'CORRECTIVE', 'Очистка диска', '2025-06-11', NULL, 'PENDING'),
(12, 7, 10, 'CORRECTIVE', 'Настройка QoS', '2025-06-13', NULL, 'PENDING');

-- alert_history (добавляем 12 записей)
INSERT INTO alert_history (alert_id, old_status_id, new_status_id, changed_by, changed_at) VALUES
(1, 1, 2, 2, '2025-05-20 09:00:00'),
(1, 2, 3, 1, '2025-05-21 14:00:00'),
(2, 1, 2, 2, '2025-05-22 10:00:00'),
(2, 2, 4, 2, '2025-05-23 16:00:00'),
(3, 1, 2, 1, '2025-05-24 11:00:00'),
(3, 2, 3, 2, '2025-05-25 09:00:00'),
(4, 1, 2, 2, '2025-05-26 08:00:00'),
(5, 1, 4, 1, '2025-05-27 12:00:00'),
(6, 1, 2, 5, '2025-06-01 10:00:00'),
(7, 1, 2, 5, '2025-06-02 11:00:00'),
(8, 1, 3, 2, '2025-06-03 09:00:00'),
(9, 1, 2, 6, '2025-06-04 14:00:00');

-- Для запроса обновим данные
UPDATE alerts SET resolved_at = triggered_at + INTERVAL '2 hours' WHERE alert_id IN (1, 2, 3);
UPDATE alerts SET resolved_at = triggered_at + INTERVAL '5 hours' WHERE alert_id IN (4, 5);
INSERT INTO engineer_assignments (engineer_id, device_id) VALUES (1, 5);
INSERT INTO engineers (first_name, last_name, email, role) VALUES
('Новый', 'Инженер', 'new.engineer@noc.ru', 'SUPPORT');