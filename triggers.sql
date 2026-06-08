-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Триггеры для NOC
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Триггерная функция: автоматическое создание аварии при превышении метрики
CREATE OR REPLACE FUNCTION trg_check_metric_threshold()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_metric_type VARCHAR;
    v_severity VARCHAR;
    v_status_id INT;
BEGIN
    -- Получаем тип метрики
    SELECT metric_type INTO v_metric_type
    FROM metric_thresholds
    WHERE threshold_id = NEW.threshold_id;
    
    -- Классифицируем критичность
    v_severity := classify_alert_severity(NEW.metric_value, v_metric_type);
    
    -- Получаем статус NEW
    SELECT status_id INTO v_status_id FROM alert_statuses WHERE status_name = 'NEW';
    
    -- Если превышены пороги — создаём аварию
    IF v_severity IN ('WARNING', 'CRITICAL') THEN
        INSERT INTO alerts (device_id, threshold_id, severity, message, triggered_at, status_id)
        VALUES (
            NEW.device_id,
            NEW.threshold_id,
            v_severity,
            'Автоматическая авария: ' || v_metric_type || ' = ' || NEW.metric_value,
            NOW(),
            v_status_id
        );
    END IF;
    
    RETURN NEW;
END;
$$;

-- Триггер: срабатывает после вставки метрики
CREATE TRIGGER trg_metric_threshold_alert
AFTER INSERT ON metrics
FOR EACH ROW
EXECUTE FUNCTION trg_check_metric_threshold();