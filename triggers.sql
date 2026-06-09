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

-- Триггер: автоматическое обновление resolved_at при закрытии аварии
CREATE OR REPLACE FUNCTION trg_alerts_update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_resolved_status_id INT;
    v_closed_status_id INT;
    v_new_status_id INT;
    v_in_progress_status_id INT;
BEGIN
    -- Получаем ID статусов
    SELECT status_id INTO v_resolved_status_id FROM alert_statuses WHERE status_name = 'RESOLVED';
    SELECT status_id INTO v_closed_status_id FROM alert_statuses WHERE status_name = 'CLOSED';
    SELECT status_id INTO v_new_status_id FROM alert_statuses WHERE status_name = 'NEW';
    SELECT status_id INTO v_in_progress_status_id FROM alert_statuses WHERE status_name = 'IN_PROGRESS';
    
    -- Если статус изменился
    IF OLD.status_id != NEW.status_id THEN
        -- Если новый статус — закрывающий (RESOLVED или CLOSED)
        IF NEW.status_id IN (v_resolved_status_id, v_closed_status_id) THEN
            -- Устанавливаем время закрытия, если его ещё нет
            IF NEW.resolved_at IS NULL THEN
                NEW.resolved_at := NOW();
            END IF;
        -- Если новый статус — открывающий (NEW или IN_PROGRESS)
        ELSIF NEW.status_id IN (v_new_status_id, v_in_progress_status_id) THEN
            -- Сбрасываем время закрытия
            NEW.resolved_at := NULL;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Создаём триггер на UPDATE таблицы alerts
CREATE TRIGGER trg_alerts_update_timestamp
BEFORE UPDATE ON alerts
FOR EACH ROW
EXECUTE FUNCTION trg_alerts_update_timestamp();