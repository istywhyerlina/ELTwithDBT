INSERT INTO stg.order_reviews 
    (review_id, order_id, review_score,review_comment_title,review_comment_message,review_creation_date) 

SELECT
    review_id, order_id, review_score,review_comment_title,review_comment_message,review_creation_date
FROM
    olist.order_reviews
