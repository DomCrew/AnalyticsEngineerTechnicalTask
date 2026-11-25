DROP TABLE IF EXISTS trade_events;
DROP TABLE IF EXISTS market_prices;

CREATE TABLE trade_events(
    trade_id VARCHAR(3) NOT NULL,
    revision INT NOT NULL,
    delivery TIMESTAMP NOT NULL,
    side VARCHAR(4) NOT NULL CHECK (side IN ('BUY', 'SELL')),
    mwh INT NOT NULL,
    trade_price INT NOT NULL,
    status VARCHAR(9) NOT NULL CHECK (status IN ('ACTIVE', 'CANCELLED'))
);

CREATE TABLE market_prices(
    delivery TIMESTAMP NOT NULL,
    published_at TIMESTAMP NOT NULL,
    market_price INT NOT NULL
);

INSERT INTO trade_events (trade_id, revision, delivery, side, mwh, trade_price, status) VALUES
('A', 1, TIMESTAMP '2026-10-15 10:00', 'BUY', 10, 80, 'ACTIVE'),
('A', 2, TIMESTAMP '2026-10-15 10:00', 'BUY', 12, 80, 'ACTIVE'),
('A', 2, TIMESTAMP '2026-10-15 10:00', 'BUY', 12, 80, 'ACTIVE'),
('B', 1, TIMESTAMP '2026-10-15 10:00', 'SELL', 5, 82, 'ACTIVE'),
('C', 1, TIMESTAMP '2026-10-15 10:30', 'BUY', 8, 85, 'ACTIVE'),
('C', 2, TIMESTAMP '2026-10-15 10:30', 'BUY', 8, 85, 'CANCELLED'),
('D', 1, TIMESTAMP '2026-10-15 10:30', 'SELL', 4, 90, 'ACTIVE'),
('E', 1, TIMESTAMP '2026-10-15 11:00', 'BUY', 3, 99, 'ACTIVE'),
('F', 1, TIMESTAMP '2026-10-15 11:00', 'SELL', 3, 94, 'ACTIVE'),
('G', 1, TIMESTAMP '2026-10-15 10:00', 'BUY', 2, 100, 'ACTIVE'),
('G', 2, TIMESTAMP '2026-10-15 10:30', 'BUY', 2, 100, 'ACTIVE');

INSERT INTO market_prices (delivery, published_at, market_price) VALUES
(TIMESTAMP '2026-10-15 10:00', TIMESTAMP '2026-10-15 12:00', 85),
(TIMESTAMP '2026-10-15 10:00', TIMESTAMP '2026-10-15 12:10', 90),
(TIMESTAMP '2026-10-15 10:30', TIMESTAMP '2026-10-15 12:00', 92);
