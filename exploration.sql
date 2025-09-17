SELECT  *
FROM [staging].[order_reviews]


-- une transformation qui fait de customer_unique_id la clé primaire et en nvarchar 250, customer_city customer_id et customer_id  en nvarchar 250
-- une transformation  [geolocation_zip_code_prefix] small int, NULL. [geolocation_city] [geolocation_state] en nvarchar 250 Null.
-- une transformation [order_id] nvarchar 250 . [order_item_id] en small int 
-- [product_id] nvarchar 250 , [seller_id] Nvarchar 250, shipping_limit_date datetime
-- dans [staging].[order_payments] transformation [payment_sequential] small int , [payment_type] nvarchar 50, [payment_installments]small int,
-- dans [staging].[order_reviews] transformation [review_id] et [order_id] nvarchar 250, [review_score] small int, [review_comment_title] nvarchar 50, 
-- [review_comment_message] nvarchar max, [review_creation_date] datetime, [review_answer_timestamp] datetime.

SELECT  * 
FROM staging.geolocation

