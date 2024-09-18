-- QUESTION 1
-- Find the oldest 5 users
SELECT * FROM users
ORDER BY created_at
LIMIT 5;

-- QUESTION 2
-- Day of the week that most users register on
SELECT 
    DATE_FORMAT(created_at, '%W') AS day_of_week,
    COUNT(*) AS day_of_week_count
FROM users
GROUP BY day_of_week
ORDER BY day_of_week_count DESC;

-- QUESTION 3
-- Find users who have never posted a photo
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;

-- QUESTION 4
-- Find who has the most liked photo
SELECT username, image_url, COUNT(*) AS likes
FROM likes
JOIN photos ON likes.photo_id = photos.id
JOIN users ON photos.user_id = users.id
GROUP BY likes.photo_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- QUESTION 5
-- Average number of photos per user
SELECT
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
AS avg_photos_per_user;

-- QUESTION 6
-- Top 5 hashtags
SELECT tag_name, count
FROM tags
JOIN (
	SELECT tag_id, COUNT(*) AS count
	FROM photo_tags
	GROUP BY tag_id
	ORDER BY count DESC
	LIMIT 6
) AS top_5_tags
ON tags.id = top_5_tags.tag_id;

-- OR
SELECT tags.tag_name, COUNT(*) AS count
FROM photo_tags
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tags.id
ORDER BY count DESC
LIMIT 6;

-- QUESTION 7
-- Finding bots (Users who have liked every photo)
SELECT users.username, likes.user_id
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING COUNT(*) = (SELECT COUNT(*) FROM photos);