-- ============================================================
-- PROJECT: Kimia Farma Big Data Analytics 2020-2023
-- Author : Big Data Analytics Intern
-- Dataset: keen-oasis-496509-r8.kimia_farma
-- ============================================================

-- ============================================================
-- STEP 1: Create Analysis Table (kf_analisa)
-- ============================================================
CREATE OR REPLACE TABLE `keen-oasis-496509-r8.kimia_farma.kf_analisa` AS
SELECT
  -- Transaction Info
  ft.transaction_id,
  ft.date,
  
  -- Branch Info
  ft.branch_id,
  kc.branch_name,
  kc.kota,
  kc.provinsi,
  kc.rating                                        AS rating_cabang,
  
  -- Customer & Product Info
  ft.customer_name,
  ft.product_id,
  p.product_name,
  
  -- Price & Discount
  ft.price                                         AS actual_price,
  ft.discount_percentage,
  
  -- Gross Profit Percentage (tiered by price)
  CASE
    WHEN ft.price <= 50000                        THEN 0.10
    WHEN ft.price >  50000  AND ft.price <= 100000 THEN 0.15
    WHEN ft.price > 100000  AND ft.price <= 300000 THEN 0.20
    WHEN ft.price > 300000  AND ft.price <= 500000 THEN 0.25
    ELSE                                               0.30
  END                                              AS persentase_gross_laba,
  
  -- Nett Sales: price after discount
  ft.price * (1 - ft.discount_percentage)         AS nett_sales,
  
  -- Nett Profit: nett_sales × gross profit %
  ft.price * (1 - ft.discount_percentage) *
  CASE
    WHEN ft.price <= 50000                        THEN 0.10
    WHEN ft.price >  50000  AND ft.price <= 100000 THEN 0.15
    WHEN ft.price > 100000  AND ft.price <= 300000 THEN 0.20
    WHEN ft.price > 300000  AND ft.price <= 500000 THEN 0.25
    ELSE                                               0.30
  END                                              AS nett_profit,
  
  -- Transaction Rating
  ft.rating                                        AS rating_transaksi

FROM `keen-oasis-496509-r8.kimia_farma.kf_final_transaction` ft
LEFT JOIN `keen-oasis-496509-r8.kimia_farma.kf_kantor_cabang`  kc
       ON ft.branch_id  = kc.branch_id
LEFT JOIN `keen-oasis-496509-r8.kimia_farma.kf_product`        p
       ON ft.product_id = p.product_id;


-- ============================================================
-- STEP 2: Verification – row count
-- ============================================================
SELECT COUNT(*) AS total_rows FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`;


-- ============================================================
-- STEP 3: Annual Revenue Comparison (2020-2023)
-- ============================================================
SELECT
  EXTRACT(YEAR FROM date)            AS tahun,
  COUNT(transaction_id)              AS total_transaksi,
  ROUND(SUM(nett_sales),  2)         AS total_nett_sales,
  ROUND(SUM(nett_profit), 2)         AS total_nett_profit,
  ROUND(AVG(rating_transaksi), 2)    AS avg_rating_transaksi
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY tahun
ORDER BY tahun;


-- ============================================================
-- STEP 4: Top 10 Provinsi – Total Transaksi
-- ============================================================
SELECT
  provinsi,
  COUNT(transaction_id)  AS total_transaksi
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY provinsi
ORDER BY total_transaksi DESC
LIMIT 10;


-- ============================================================
-- STEP 5: Top 10 Provinsi – Total Nett Sales
-- ============================================================
SELECT
  provinsi,
  ROUND(SUM(nett_sales), 2) AS total_nett_sales
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY provinsi
ORDER BY total_nett_sales DESC
LIMIT 10;


-- ============================================================
-- STEP 6: Top 5 Cabang – Rating Tertinggi & Rating Transaksi Terendah
-- ============================================================
SELECT
  branch_name,
  kota,
  provinsi,
  MAX(rating_cabang)              AS rating_cabang,
  ROUND(AVG(rating_transaksi), 2) AS avg_rating_transaksi
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY branch_name, kota, provinsi
ORDER BY rating_cabang DESC, avg_rating_transaksi ASC
LIMIT 5;


-- ============================================================
-- STEP 7: Total Profit Per Provinsi (untuk Geo Map Indonesia)
-- ============================================================
SELECT
  provinsi,
  ROUND(SUM(nett_profit), 2)  AS total_profit,
  COUNT(transaction_id)       AS total_transaksi,
  ROUND(SUM(nett_sales),  2)  AS total_nett_sales
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY provinsi
ORDER BY total_profit DESC;


-- ============================================================
-- STEP 8: Top 10 Produk Terlaris berdasarkan Nett Sales
-- ============================================================
SELECT
  product_name,
  COUNT(transaction_id)         AS total_transaksi,
  ROUND(SUM(nett_sales),  2)    AS total_nett_sales,
  ROUND(SUM(nett_profit), 2)    AS total_nett_profit
FROM `keen-oasis-496509-r8.kimia_farma.kf_analisa`
GROUP BY product_name
ORDER BY total_nett_sales DESC
LIMIT 10;
