-- Note: Table renamed from paysim_dataset_csv to paysim


select * from paysim;

EXPLAIN ANALYZE SELECT * FROM paysim WHERE nameOrig = 'C1231006815';

CREATE INDEX idx_paysim_name ON paysim(nameOrig);





-- Total CASH-IN volume by day, total CASH-OUT volume by day
-- Net flow = SUM(CASH-IN) - SUM(CASH-OUT)
-- Compare to previous day, show growth %
with daily_netflox as (
select
	step / 24 as day,
	SUM(case when type = 'CASH_IN' then amount else 0 END) as cash_in_volume,
	SUM(case when type = 'CASH_OUT' then amount else 0 END) as cash_out_volume,
	-- Net flow = SUM(CASH-IN) - SUM(CASH-OUT)
	SUM(case when type = 'CASH_IN' then amount else 0 end) - 
	SUM(CASE WHEN type = 'CASH_OUT' THEN amount ELSE 0 END) as netflow
from paysim
group by day
)
select
	day,
	cash_in_volume,
	cash_out_volume,
	netflow,
	netflow - lag(netflow) OVER(order by day) as growth,
	case
	when netflow - LAG(netflow) OVER (ORDER BY day) < 0 then 'negative_growth'
	when netflow - LAG(netflow) OVER (ORDER BY day) > 0 then 'positive_growth'
	else 'Nochange'
	end as Growth_rate
FROM (
    SELECT 
        day,
        cash_in_volume,
        cash_out_volume,
        netflow,
        netflow - LAG(netflow) OVER (ORDER BY day) as growth
    FROM daily_netflox
) t;


-- Find accounts where newbalanceOrg is negative after transaction (impossible)
-- Find accounts with multiple CASH-OUT in 1 hour exceeding oldbalanceOrg
-- These are potential overdraft/fraud cases
SELECT *
FROM paysim
WHERE newbalanceorig < 0;

SELECT 
    nameOrig,
    step,
    COUNT(*) as cashout_count
FROM paysim
WHERE type = 'CASH_OUT'
and amount > oldbalanceorg
GROUP BY nameOrig, step
HAVING COUNT(*) > 1
ORDER BY cashout_count DESC;
	

-- Verify: oldbalanceOrg - amount = newbalanceOrg for CASH-OUT
-- Verify: oldbalanceOrg + amount = newbalanceOrig for CASH-IN
-- Flag all mismatches (data quality issue)
select
	nameorig,
	newbalanceorig,
	oldbalanceorg,
	case
	when type = 'CASH_OUT' and oldbalanceorg - amount != newbalanceorig then 'Withdrawfraud'
	when type = 'CASH_IN' and oldbalanceorg + amount != newbalanceorig then 'depositfraud'
	else 'AllGood'
	end as Fraudcheck
from paysim;


-- For each nameOrig, calculate:
-- Total volume sent, total volume received
-- Transaction count by type
-- Classify as: "Saver" (net positive), "Spender" (net negative), "Transactor" (high volume both ways)
WITH sent AS (
    SELECT 
        nameorig as account,
        SUM(amount) as total_sent
    FROM paysim
    GROUP BY nameorig
),
received AS (
    SELECT 
        namedest as account,
        SUM(amount) as total_received
    FROM paysim
    GROUP BY namedest
), newer as (
SELECT 
    COALESCE(s.account, r.account) as account,
    COALESCE(s.total_sent, 0) as total_sent,
    COALESCE(r.total_received, 0) as total_received
FROM sent s
FULL OUTER JOIN received r ON s.account = r.account
)
SELECT 
    account,
    total_sent,
    total_received,
    total_received - total_sent as netflow,
    CASE 
        WHEN total_sent > 10000 AND total_received > 10000 THEN 'Transactor'
        WHEN total_received - total_sent > 0 THEN 'Saver'
        WHEN total_received - total_sent < 0 THEN 'Spender'
        ELSE 'Inactive'
    END as account_type
FROM newer
WHERE total_sent > 0 OR total_received > 0
ORDER BY account;


-- isFlaggedFraud column flags transfers > 200,000 [citation:1]
-- Find transfers just below threshold (150k-200k)
-- Check if same sender made multiple large transfers in short period
select
	nameorig,
	namedest,
	amount
from paysim
where type = 'TRANSFER'
and isflaggedfraud = 1
and amount > 200000;


select
	nameorig,
	namedest,
	amount::int
from paysim
where type = 'TRANSFER'
and amount < 200000;



select
	nameorig,
	step,
	COUNT(*) as timesend
from paysim
where type = 'TRANSFER'
and amount > 100
group by nameorig, step
having count(*) > 1;
	











