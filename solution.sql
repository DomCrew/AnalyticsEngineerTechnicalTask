WITH latest_market_prices AS (
    SELECT * FROM (
        SELECT
            delivery,
            market_price,
            ROW_NUMBER() OVER (PARTITION BY delivery ORDER BY published_at DESC) AS rn
        FROM
            market_prices
    ) WHERE rn = 1
), latest_active_trades AS (
    SELECT * FROM (
        SELECT
            trade_id,
            delivery,
            status,
            mwh * (CASE WHEN side = 'BUY' THEN 1 ELSE -1 END) AS signed_mwh,
            trade_price,
            ROW_NUMBER() OVER (PARTITION BY trade_id ORDER BY revision DESC) AS rn
        FROM
            trade_events
    ) WHERE rn = 1 AND status = 'ACTIVE'
)
SELECT
    delivery,
    SUM(signed_mwh) AS net_traded_volume,
    SUM(ABS(signed_mwh)) AS gross_traded_volume,
    SUM(signed_mwh * (market_price - trade_price)) AS total_unrealised_pnl,
    (CASE WHEN market_price IS NULL THEN TRUE ELSE FALSE END) AS market_price_unavailable
FROM
    latest_active_trades
LEFT JOIN
    latest_market_prices USING (delivery)
GROUP BY
    delivery,
    market_price
;