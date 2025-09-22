SELECT  *
FROM [staging].[order_reviews]


-- une transformation qui fait de customer_unique_id la cl� primaire et en nvarchar 250, customer_city customer_id et customer_id  en nvarchar 250
-- une transformation  [geolocation_zip_code_prefix] small int, NULL. [geolocation_city] [geolocation_state] en nvarchar 250 Null.
-- une transformation [order_id] nvarchar 250 . [order_item_id] en small int 
-- [product_id] nvarchar 250 , [seller_id] Nvarchar 250, shipping_limit_date datetime
-- dans [staging].[order_payments] transformation [payment_sequential] small int , [payment_type] nvarchar 50, [payment_installments]small int,
-- dans [staging].[order_reviews] transformation [review_id] et [order_id] nvarchar 250, [review_score] small int, [review_comment_title] nvarchar 50, 
-- [review_comment_message] nvarchar max, [review_creation_date] datetime, [review_answer_timestamp] datetime.
-- [staging].[orders] transformation [order_id] [customer_id] en nvarchar 250, [order_status] nvarchar 50, [order_purchase_timestamp][order_approved_at][order_delivered_carrier_date] et 
-- [order_delivered_customer_date] [order_estimated_delivery_date] tous en datetime
--[staging].[product_category_name_translation] transformation [product_category_name] et [product_category_name_english] en nvarchar 50
-- [staging].[products] transformation [product_id] en nvarchar 250 , [product_category_name] nvarchar 50, 
-- [staging].[sellers] transformation [seller_id] nvarchar 250, [seller_zip_code_prefix] small int, [seller_city] nvarchar 50, [seller_state] nvarchar 25
SELECT  * 
FROM [staging].[sellers]

