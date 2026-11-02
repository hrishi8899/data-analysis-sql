-- Business operation: create a completed order with one line item.
-- PostgreSQL stored procedure. Raises an exception for invalid input.
CREATE OR REPLACE PROCEDURE create_completed_order(
    IN p_customer_id BIGINT,
    IN p_product_id BIGINT,
    IN p_quantity INTEGER,
    IN p_discount_pct NUMERIC DEFAULT 0,
    IN p_sales_channel VARCHAR DEFAULT 'Online'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id BIGINT;
    v_unit_price NUMERIC(12,2);
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be greater than zero';
    END IF;

    IF p_discount_pct IS NULL OR p_discount_pct < 0 OR p_discount_pct > 100 THEN
        RAISE EXCEPTION 'Discount must be between 0 and 100';
    END IF;

    IF p_sales_channel NOT IN ('Online', 'Store', 'Phone') THEN
        RAISE EXCEPTION 'Unsupported sales channel: %', p_sales_channel;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer % does not exist', p_customer_id;
    END IF;

    SELECT unit_price INTO v_unit_price
    FROM products
    WHERE product_id = p_product_id AND active = TRUE;

    IF v_unit_price IS NULL THEN
        RAISE EXCEPTION 'Product % does not exist or is inactive', p_product_id;
    END IF;

    INSERT INTO orders (customer_id, order_date, order_status, sales_channel)
    VALUES (p_customer_id, CURRENT_DATE, 'Completed', p_sales_channel)
    RETURNING order_id INTO v_order_id;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct)
    VALUES (v_order_id, p_product_id, p_quantity, v_unit_price, p_discount_pct);

    RAISE NOTICE 'Created order % for customer %', v_order_id, p_customer_id;
END;
$$;

-- Example invocation (uncomment to test after loading sample_data.sql):
-- CALL create_completed_order(1, 1, 2, 5, 'Online');
