-- Section 1: Basic Analytics
-- a) How many users?
SELECT COUNT(*) FROM users;

-- b) How many posts?
SELECT COUNT(*) FROM photos;

-- c) What is the average post per user?
SELECT (
	(SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users)
) as avg_photo_per_user;

-- d) What is the average amount of likes per post?
SELECT (
	(SELECT COUNT(*) FROM likes) / (SELECT COUNT(*) FROM photos)
) AS avg_likes_per_photo;

-- Section 2: User Engagement
-- a) User registration by year/month/day/hour
SELECT YEAR(created_at) AS year, COUNT(*) AS total
FROM users
GROUP BY year
ORDER BY year DESC;

SELECT MONTHNAME(created_at) AS month, COUNT(*) AS total
FROM users
GROUP BY month
ORDER BY FIELD(MONTH,'January','February','March','April','May','June',
					 'July','August','September','October','November','December');

SELECT DAYNAME(created_at) AS day_of_week, COUNT(*) AS total
FROM users
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

SELECT HOUR(created_at) AS hour, COUNT(*) AS total
FROM users
GROUP BY hour
ORDER BY hour; 

-- b) Which users are the most active? When are they most active?
-- Active users will be calculated as such: 
-- i ) activity = # of photos + # of likes + # of comments + # of followings
-- ii) activity_rate = (# of photos + # of likes + # of comments + # of followings) / # of days since the user registered

CREATE VIEW user_photos AS (
	SELECT users.id, username, COUNT(*) AS num_of_photos
	FROM users
	LEFT OUTER JOIN photos ON users.id = photos.user_id
	GROUP BY users.id, username
	ORDER BY num_of_photos DESC
);

CREATE VIEW user_likes AS (
	SELECT id, username, COUNT(*) AS num_of_likes
	FROM users
	LEFT OUTER JOIN likes ON users.id = likes.user_id
	GROUP BY id, username
	ORDER BY num_of_likes DESC
);

CREATE VIEW user_comments AS (
	SELECT users.id, username, COUNT(*) AS num_of_comments
	FROM users
	LEFT OUTER JOIN comments ON users.id = comments.user_id
	GROUP BY users.id, username
	ORDER BY num_of_comments DESC
);

CREATE VIEW user_followings AS (
	SELECT users.id, username, COUNT(*) AS num_of_followings
	FROM users
	LEFT OUTER JOIN follows ON users.id = follows.follower_id
	GROUP BY users.id, username
	ORDER BY num_of_followings DESC
);

-- Activity (note that users with activity>1000 are suspected bots)
CREATE VIEW user_activity AS (
	SELECT 
		users.id, 
		users.username, 
        num_of_photos,
        num_of_likes,
        num_of_comments,
        num_of_followings,
        (num_of_photos + num_of_likes + num_of_comments + num_of_followings) AS activity
	FROM users
	JOIN user_photos ON users.id = user_photos.id
	JOIN user_likes ON users.id = user_likes.id
	JOIN user_comments ON users.id = user_comments.id
	JOIN user_followings ON users.id = user_followings.id
	GROUP BY users.id, username
	ORDER BY activity DESC
);

-- Activity rate (excluding suspected bots and new users)
CREATE VIEW user_activity_rate AS (
	SELECT 
		users.id, users.username,
		activity,
		DATEDIFF(NOW(), users.created_at) AS days_on_minigram,
		activity / DATEDIFF(NOW(), users.created_at) AS activity_rate
	FROM users
	JOIN user_activity ON users.id = user_activity.id
	HAVING users.id NOT IN (SELECT id FROM user_activity WHERE activity > 1000) AND days_on_minigram > 10
	ORDER BY activity_rate DESC
);

-- Active users (by activity)
DROP VIEW active_users;
CREATE VIEW active_users AS (
	SELECT * FROM user_activity WHERE activity < 1000 AND activity > 150
);

-- Active users (by activity rate)
DROP VIEW active_users;
CREATE VIEW active_users AS (
	SELECT * FROM user_activity_rate WHERE activity_rate >= 1
);

-- User activities by day
SELECT DAYNAME(photos.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN photos ON users.id = photos.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(likes.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN likes ON users.id = likes.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(comments.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN comments ON users.id = comments.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(follows.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN follows ON users.id = follows.follower_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

-- c) Which users are the most inactive? When are they most active?
DROP VIEW inactive_users;
CREATE VIEW inactive_users AS (
	SELECT * FROM user_activity WHERE activity <= 100
);

DROP VIEW inactive_users;
CREATE VIEW inactive_users AS (
	SELECT * FROM user_activity_rate WHERE activity_rate <= 0.03 ORDER BY activity_rate
);

-- User activities by day
SELECT DAYNAME(photos.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN photos ON users.id = photos.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(likes.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN likes ON users.id = likes.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(comments.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN comments ON users.id = comments.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT DAYNAME(follows.created_at) AS day, COUNT(*) AS total
FROM users 
JOIN follows ON users.id = follows.follower_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

-- Section 3: Posts and Content
-- a) Which types of content typically receive the most engagement?
-- b) What is the ideal time for a user to post content?

-- Section 4: Influencers
-- a) What types of content do influencers post compared to non-influencers?
-- b) Find the difference in activity between influencers and non-influencers.
-- c) How do influencers impact other users' engagement on MiniGram?

-- Section 5: Bots
-- a) When are the bots most active?
-- b) How do bots impact the posts that they engage in?
-- c) Find which accounts (if any) implement the use of bots.

-- Section 6: Year by Year Analysis
-- a) Compare the amount of posts/likes/comments from year to year
-- b) Is there an increase in the rate of user and content growth from year to year?