/* ============================================================
   0) Helper : DROP PK si existante (quel que soit son nom)
   ============================================================ */
IF OBJECT_ID('dbo._drop_pk_if_exists', 'P') IS NOT NULL
    DROP PROCEDURE dbo._drop_pk_if_exists;
GO
CREATE PROCEDURE dbo._drop_pk_if_exists
  @schema SYSNAME,
  @table  SYSNAME
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @pk SYSNAME;
  SELECT @pk = kc.name
  FROM sys.key_constraints kc
  WHERE kc.parent_object_id = OBJECT_ID(QUOTENAME(@schema)+'.'+QUOTENAME(@table))
    AND kc.[type] = 'PK';
  IF @pk IS NOT NULL
  BEGIN
    DECLARE @cmd NVARCHAR(MAX) =
      N'ALTER TABLE ' + QUOTENAME(@schema)+'.'+QUOTENAME(@table) +
      N' DROP CONSTRAINT ' + QUOTENAME(@pk) + N';';
    EXEC sp_executesql @cmd;
  END
END
GO

/* ============================================================
   1) staging.customers
   ============================================================ */
ALTER TABLE staging.customers  ALTER COLUMN customer_id         NVARCHAR(250) NOT NULL;
ALTER TABLE staging.customers  ALTER COLUMN customer_unique_id  NVARCHAR(250) NULL;
ALTER TABLE staging.customers  ALTER COLUMN customer_city       NVARCHAR(250) NULL;
ALTER TABLE staging.customers  ALTER COLUMN customer_state      NVARCHAR(250) NULL;
GO
EXEC dbo._drop_pk_if_exists 'staging','customers';
GO
ALTER TABLE staging.customers
  ADD CONSTRAINT PK_customers PRIMARY KEY CLUSTERED (customer_id);
GO
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_customers_customer_unique_id'
      AND object_id = OBJECT_ID('staging.customers')
)
CREATE NONCLUSTERED INDEX IX_customers_customer_unique_id
  ON staging.customers(customer_unique_id);
GO

/* ============================================================
   2) staging.product_category_name_translation (table de réf)
   ============================================================ */
ALTER TABLE staging.product_category_name_translation 
  ALTER COLUMN product_category_name         NVARCHAR(50) NOT NULL;
ALTER TABLE staging.product_category_name_translation 
  ALTER COLUMN product_category_name_english NVARCHAR(50) NULL;
GO
EXEC dbo._drop_pk_if_exists 'staging','product_category_name_translation';
GO
ALTER TABLE staging.product_category_name_translation
  ADD CONSTRAINT PK_product_category_name_translation PRIMARY KEY CLUSTERED (product_category_name);
GO

/* -- Normalisation + ajout des catégories manquantes repérées -- */
UPDATE staging.product_category_name_translation
SET product_category_name = LTRIM(RTRIM(product_category_name));
GO
INSERT INTO staging.product_category_name_translation (product_category_name, product_category_name_english)
SELECT v.product_category_name, NULL
FROM (VALUES
    (N'pc_gamer'),
    (N'portateis_cozinha_e_preparadores_de_alimentos')
) AS v(product_category_name)
LEFT JOIN staging.product_category_name_translation t
  ON t.product_category_name = v.product_category_name
WHERE t.product_category_name IS NULL;
GO

/* ============================================================
   3) staging.products
   ============================================================ */
ALTER TABLE staging.products  ALTER COLUMN product_id            NVARCHAR(250) NOT NULL;
ALTER TABLE staging.products  ALTER COLUMN product_category_name NVARCHAR(50)  NULL;
GO
EXEC dbo._drop_pk_if_exists 'staging','products';
GO
ALTER TABLE staging.products
  ADD CONSTRAINT PK_products PRIMARY KEY CLUSTERED (product_id);
GO
/* Normaliser et préparer la future FK */
UPDATE staging.products
SET product_category_name = NULL
WHERE LTRIM(RTRIM(ISNULL(product_category_name,''))) = '';
GO
UPDATE staging.products
SET product_category_name = LTRIM(RTRIM(product_category_name));
GO

/* ============================================================
   4) staging.sellers
   ============================================================ */
ALTER TABLE staging.sellers  ALTER COLUMN seller_id              NVARCHAR(250) NOT NULL;
ALTER TABLE staging.sellers  ALTER COLUMN seller_zip_code_prefix INT           NULL;
ALTER TABLE staging.sellers  ALTER COLUMN seller_city            NVARCHAR(50)  NULL;
ALTER TABLE staging.sellers  ALTER COLUMN seller_state           NVARCHAR(25)  NULL;
GO
EXEC dbo._drop_pk_if_exists 'staging','sellers';
GO
ALTER TABLE staging.sellers
  ADD CONSTRAINT PK_sellers PRIMARY KEY CLUSTERED (seller_id);
GO

/* ============================================================
   5) staging.orders
   ============================================================ */
UPDATE staging.orders
SET customer_id = NULL
WHERE LTRIM(RTRIM(ISNULL(customer_id,''))) = '';
GO
ALTER TABLE staging.orders  ALTER COLUMN order_id                      NVARCHAR(250) NOT NULL;
ALTER TABLE staging.orders  ALTER COLUMN customer_id                   NVARCHAR(250) NOT NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_status                  NVARCHAR(50)  NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_purchase_timestamp      DATETIME      NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_approved_at             DATETIME      NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_delivered_carrier_date  DATETIME      NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_delivered_customer_date DATETIME      NULL;
ALTER TABLE staging.orders  ALTER COLUMN order_estimated_delivery_date DATETIME      NULL;
GO
EXEC dbo._drop_pk_if_exists 'staging','orders';
GO
ALTER TABLE staging.orders
  ADD CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (order_id);
GO

/* ============================================================
   6) staging.order_items
   ============================================================ */
UPDATE staging.order_items
SET order_id = NULL
WHERE LTRIM(RTRIM(ISNULL(order_id,''))) = '';
GO
DELETE FROM staging.order_items
WHERE order_id IS NULL OR order_item_id IS NULL;
GO
ALTER TABLE staging.order_items  ALTER COLUMN order_id            NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_items  ALTER COLUMN order_item_id       INT           NOT NULL;
ALTER TABLE staging.order_items  ALTER COLUMN product_id          NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_items  ALTER COLUMN seller_id           NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_items  ALTER COLUMN shipping_limit_date DATETIME      NULL;
GO
;WITH d AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY order_id, order_item_id
           ORDER BY (SELECT 0)
         ) AS rn
  FROM staging.order_items
)
DELETE FROM d WHERE rn > 1;
GO
EXEC dbo._drop_pk_if_exists 'staging','order_items';
GO
ALTER TABLE staging.order_items
  ADD CONSTRAINT PK_order_items PRIMARY KEY CLUSTERED (order_id, order_item_id);
GO

/* ============================================================
   7) staging.order_payments
   ============================================================ */
UPDATE staging.order_payments
SET order_id = NULL
WHERE LTRIM(RTRIM(ISNULL(order_id,''))) = '';
GO
DELETE FROM staging.order_payments
WHERE order_id IS NULL OR payment_sequential IS NULL;
GO
ALTER TABLE staging.order_payments  ALTER COLUMN order_id             NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_payments  ALTER COLUMN payment_sequential   INT           NOT NULL;
ALTER TABLE staging.order_payments  ALTER COLUMN payment_type         NVARCHAR(50)  NULL;
ALTER TABLE staging.order_payments  ALTER COLUMN payment_installments SMALLINT      NULL;
GO
;WITH d AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY order_id, payment_sequential
           ORDER BY (SELECT 0)
         ) AS rn
  FROM staging.order_payments
)
DELETE FROM d WHERE rn > 1;
GO
EXEC dbo._drop_pk_if_exists 'staging','order_payments';
GO
ALTER TABLE staging.order_payments
  ADD CONSTRAINT PK_order_payments PRIMARY KEY CLUSTERED (order_id, payment_sequential);
GO

/* ============================================================
   8) staging.order_reviews (PK NONCLUSTERED + index CLUSTERED étroit)
   ============================================================ */
-- nettoyer clés
UPDATE staging.order_reviews
SET review_id = NULL
WHERE LTRIM(RTRIM(ISNULL(review_id,''))) = '';
UPDATE staging.order_reviews
SET order_id = NULL
WHERE LTRIM(RTRIM(ISNULL(order_id,''))) = '';
GO
DELETE FROM staging.order_reviews
WHERE review_id IS NULL OR order_id IS NULL;
GO
-- types
ALTER TABLE staging.order_reviews  ALTER COLUMN order_id                NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_id               NVARCHAR(250) NOT NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_score            INT           NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_comment_title    NVARCHAR(100) NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_comment_message  NVARCHAR(MAX) NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_creation_date    DATETIME      NULL;
ALTER TABLE staging.order_reviews  ALTER COLUMN review_answer_timestamp DATETIME      NULL;
GO
-- dédoublonnage (garder la plus "récente")
;WITH d AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY order_id, review_id
           ORDER BY ISNULL(review_creation_date,'1900-01-01') DESC,
                    ISNULL(review_answer_timestamp,'1900-01-01') DESC
         ) AS rn
  FROM staging.order_reviews
)
DELETE FROM d WHERE rn > 1;
GO
-- PK NONCLUSTERED pour éviter la limite 900 bytes
EXEC dbo._drop_pk_if_exists 'staging','order_reviews';
GO
ALTER TABLE staging.order_reviews
  ADD CONSTRAINT PK_order_reviews PRIMARY KEY NONCLUSTERED (order_id, review_id);
GO
-- Index CLUSTERED étroit
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'CX_order_reviews'
      AND object_id = OBJECT_ID('staging.order_reviews')
)
CREATE CLUSTERED INDEX CX_order_reviews ON staging.order_reviews(order_id);
GO

/* ============================================================
   9) geolocation (types propres ; pas de PK)
   ============================================================ */
ALTER TABLE staging.geolocation  ALTER COLUMN geolocation_zip_code_prefix INT           NULL;
ALTER TABLE staging.geolocation  ALTER COLUMN geolocation_city           NVARCHAR(250)  NULL;
ALTER TABLE staging.geolocation  ALTER COLUMN geolocation_state          NVARCHAR(250)  NULL;
GO

/* ============================================================
   10) Foreign Keys
   ============================================================ */
-- orders → customers
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_orders_customers')
  ALTER TABLE staging.orders DROP CONSTRAINT FK_orders_customers;
GO
ALTER TABLE staging.orders
  ADD CONSTRAINT FK_orders_customers
  FOREIGN KEY (customer_id) REFERENCES staging.customers(customer_id);
GO

-- order_items → orders
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_order_items_orders')
  ALTER TABLE staging.order_items DROP CONSTRAINT FK_order_items_orders;
GO
ALTER TABLE staging.order_items
  ADD CONSTRAINT FK_order_items_orders
  FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);
GO

-- order_items → products
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_order_items_products')
  ALTER TABLE staging.order_items DROP CONSTRAINT FK_order_items_products;
GO
ALTER TABLE staging.order_items
  ADD CONSTRAINT FK_order_items_products
  FOREIGN KEY (product_id) REFERENCES staging.products(product_id);
GO

-- order_items → sellers
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_order_items_sellers')
  ALTER TABLE staging.order_items DROP CONSTRAINT FK_order_items_sellers;
GO
ALTER TABLE staging.order_items
  ADD CONSTRAINT FK_order_items_sellers
  FOREIGN KEY (seller_id) REFERENCES staging.sellers(seller_id);
GO

-- order_payments → orders
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_order_payments_orders')
  ALTER TABLE staging.order_payments DROP CONSTRAINT FK_order_payments_orders;
GO
ALTER TABLE staging.order_payments
  ADD CONSTRAINT FK_order_payments_orders
  FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);
GO

-- order_reviews → orders
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_order_reviews_orders')
  ALTER TABLE staging.order_reviews DROP CONSTRAINT FK_order_reviews_orders;
GO
ALTER TABLE staging.order_reviews
  ADD CONSTRAINT FK_order_reviews_orders
  FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);
GO

-- products(product_category_name) → product_category_name_translation(product_category_name)
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_products_product_category_name_translation')
  ALTER TABLE staging.products DROP CONSTRAINT FK_products_product_category_name_translation;
GO
ALTER TABLE staging.products
  ADD CONSTRAINT FK_products_product_category_name_translation
  FOREIGN KEY (product_category_name)
  REFERENCES staging.product_category_name_translation (product_category_name);
GO

/* ============================================================
   11) Nettoyage : supprimer la proc helper
   ============================================================ */
DROP PROCEDURE IF EXISTS dbo._drop_pk_if_exists;
GO
