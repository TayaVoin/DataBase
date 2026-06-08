-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Функции PL/pgSQL для NOC (Network Operations Center)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Функция 1: расчёт доступности устройства (uptime)
-- Возвращает процент времени, когда устройство не было в аварии за последние 30 дней
CREATE OR REPLACE FUNCTION get_device_availability(p_device_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql AS
$$
DECLARE
    v_total_minutes INT;
    v_alert_minutes INT;
    v_availability NUMERIC;
BEGIN
    -- Всего минут за 30 дней
    v_total_minutes := 30 * 24 * 60;
    
    -- Минуты, когда была критическая авария
    SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (COALESCE(resolved_at, NOW()) - triggered_at)) / 60), 0)::INT
    INTO v_alert_minutes
    FROM alerts
    WHERE device_id = p_device_id
      AND severity IN ('WARNING', 'CRITICAL')
      AND triggered_at > NOW() - INTERVAL '30 days';
    
    v_availability := ((v_total_minutes - v_alert_minutes)::NUMERIC / v_total_minutes) * 100;
    RETURN ROUND(v_availability, 2);
END;
$$;

-- Функция 2: классификация аварии по критичности
CREATE OR REPLACE FUNCTION classify_alert_severity(p_metric_value NUMERIC, p_metric_type VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql AS
$$
DECLARE
    v_critical NUMERIC;
    v_warning NUMERIC;
BEGIN
    SELECT critical_value, warning_value INTO v_critical, v_warning
    FROM metric_thresholds
    WHERE metric_type = p_metric_type;
    
    IF NOT FOUND THEN
        RETURN 'UNKNOWN';
    END IF;
    
    IF p_metric_value >= v_critical THEN
        RETURN 'CRITICAL';
    ELSIF p_metric_value >= v_warning THEN
        RETURN 'WARNING';
    ELSE
        RETURN 'INFO';
    END IF;
END;
$$;