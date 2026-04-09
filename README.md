# Paysim Fraud Detection - SQL Portfolio Project

## Project Overview
Analysis of synthetic financial transaction data (PaySim) to identify fraudulent patterns, data quality issues, and customer behavior segmentation. Detected overdraft anomalies, impossible balance changes, and large transfer patterns.

## Dataset
PaySim mobile money transaction dataset simulating fraud patterns in financial systems.

## Key Analyses Performed

### 1. Performance Optimization
- **Index Creation** - Added index on `nameOrig` for faster lookups
- **Query Analysis** - Used EXPLAIN ANALYZE to benchmark performance

### 2. Fraud Detection Logic
- **Impossible Balance Changes** - Found transactions where `newbalanceOrg` is negative
- **Overdraft Patterns** - Identified CASH-OUT transactions exceeding available balance
- **Multiple Large Transfers** - Same sender making multiple transfers in same step
- **Balance Mismatch Verification** - Flagged transactions where balance doesn't add up:
  - CASH-OUT: `oldbalanceOrg - amount ≠ newbalanceOrg`
  - CASH-IN: `oldbalanceOrg + amount ≠ newbalanceOrg`

### 3. Transaction Flow Analysis
- **Daily Net Flow** - Calculated CASH-IN vs CASH-OUT volume by day
- **Growth Rate** - Compared net flow to previous day with trend classification
- **Negative Growth Detection** - Identified days with declining net flow

### 4. Customer Behavior Segmentation
- **Account Classification**:
  - **Saver** - Net positive flow (received > sent)
  - **Spender** - Net negative flow (sent > received)
  - **Transactor** - High volume both ways (10k+ sent AND received)

### 5. Fraud Flag Analysis
- **Threshold Analysis** - Examined transfers just below 200k flag threshold
- **Suspicious Patterns** - Multiple transfers >100 from same sender in same step

## Key Findings

1. **Data Quality Issues**: Found transactions with impossible balance calculations
2. **Overdraft Patterns**: Identified accounts with CASH-OUT exceeding available balance
3. **Customer Segments**: Classified accounts as Savers, Spenders, or Transactors
4. **Threshold Gaming**: Found senders making multiple large transfers just below fraud flag threshold

## SQL Techniques Demonstrated

### Window Functions
- `LAG()` - Day-over-day growth calculation

### Advanced Queries
- CTEs with `FULL OUTER JOIN`
- Conditional aggregation (`CASE` statements)
- Multiple CTEs chaining

### Data Quality
- Balance verification logic
- Anomaly detection queries
- NULL handling with `COALESCE`

### Performance
- Index creation
- `EXPLAIN ANALYZE` usage

## Files
- `fraud_detection.sql` - Complete SQL analysis
- `README.md` - Project documentation

## How to Use
1. Load PaySim dataset into PostgreSQL
2. Run queries sequentially from `fraud_detection.sql`
3. Each query includes comments explaining the fraud detection logic

## Skills Demonstrated
- Fraud detection logic implementation
- Data quality validation
- Customer behavior segmentation
- Financial transaction analysis
- Query performance optimization

## Business Value
This analysis helps financial institutions identify:
- Potential overdraft fraud
- Balance calculation errors
- Suspicious transfer patterns
- Customer spending/saving behaviors
