INSERT INTO stg.product_category_name_translation 
    (product_category_name, product_category_name_english) 

SELECT product_category_name, product_category_name_english
FROM
    olist.product_category_name_translation
