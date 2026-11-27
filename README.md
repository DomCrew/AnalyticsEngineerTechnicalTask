# Powertica Analytics Engineer Technical Task

## Part 1 — Power Trading Desk Reporting Task

Run the [setup script](setup.sql) in your database to create the tables and insert the test data. Assumed Types used for each column are as follows:

| Table         | Column       | Type       |
|---------------|--------------|------------|
| trade_events  | trade_id     | varchar(3) |
| trade_events  | revision     | int        |
| trade_events  | delivery     | timestamp  |
| trade_events  | side         | varchar(4) |
| trade_events  | mwh          | int        |
| trade_events  | trade_price  | bigint     |
| trade_events  | status       | varchar(9) |
| market_prices | delivery     | timestamp  |
| market_prices | published_at | timestamp  |
| market_prices | market_price | int        |

Run the [solution script](solution.sql) in your database to get the solution.

| delivery            | net_traded_volume | gross_traded_volume | total_unrealised_pnl | market_price_unavailable |
|---------------------|-------------------|---------------------|----------------------|--------------------------|
| 2026-10-15 10:00:00 | 7                 | 17                  | 80                   | f                        |
| 2026-10-15 10:30:00 | -2                | 6                   | -24                  | f                        |
| 2026-10-15 11:00:00 | 0                 | 6                   | NULL                 | t                        |

## Part 2 — Data quality

> Describe at least three automated tests or validation checks you would implement to ensure the resulting data is reliable.

1. Trade and Market Correctness - Check that each individual stage of the query is completed correctly. In this example, I would probably use views or functions in place of the CTEs that I actually used. Those could be tested separately for their correctness. You would want to check; cancelled trades are excluded, there are no duplicates in either table, trade ID is unique and only the most recent prices and revisions are used.

2. Output Validation - Make sure the actual output is acceptable. There are multiple things to test here; only one row per interval, unrealised P&L is NULL for unavailable market prices, unrealised P&L and net/gross traded volume are correct given the input.

3. Integration Tests - Run the query in an actual database with known real data, comparing the complete output to the correct expected result and testing that output on any downstream processes that might rely on it.

These could be run as part of CI/CD pipelines to ensure no regression has taken place or bugs have been introduced.

## Part 3 — Production design

> The raw data receives new trades, corrections, and late-arriving updates throughout the day. Explain how you would design this transformation to run incrementally in production without rebuilding the entire history unnecessarily.

To avoid rebuilding the entire history, you would want to know which delivery intervals are going to be affected by the incoming changes. Then you would only perform the aggregation and calculations for those intervals. I would then overwrite existing rows with UPSERT, where delivery is unique.

To do this, I would schedule a job (possibly with Airflow) to check for any new changes since the last run and work from there. Another row in both tables which defaults to the current time would be required for this implementation. I would call it "recieved_at". You would also have to keep track of when the last successful run took place. Then find any trade revision or market update with a recieved time after the last successful update. From there, you would know which intervals would need to be calculated again.

After this, I would perform data quality checks and update the time for the last successful run. You would want to rollback the update and leave the timestamp as is if data checks do not pass.

You could schedule it however often is needed based on requirements but I would start at every half hour just to match the interval.