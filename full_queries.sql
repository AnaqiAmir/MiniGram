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
SELECT
	YEAR(created_at) AS year,
    COUNT(*) AS total
FROM users
GROUP BY year
ORDER BY year DESC;

SELECT
	MONTHNAME(created_at) AS month,
    COUNT(*) AS total
FROM users
GROUP BY month
ORDER BY FIELD(MONTH,'January','February','March','April','May','June',
					 'July','August','September','October','November','December');

SELECT
	DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS total
FROM users
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

SELECT
	HOUR(created_at) AS hour,
    COUNT(*) AS total
FROM users
GROUP BY hour
ORDER BY hour;

-- b) Which users are the most active? When are they most active?
-- Active users will be calculated as such:
-- i ) activity = # of photos + # of likes + # of comments + # of followings
-- ii) activity_rate = (# of photos + # of likes + # of comments + # of followings) / # of days since the user registered

CREATE VIEW user_photos AS (
	SELECT
		users.id, username,
        COUNT(*) AS num_of_photos
	FROM users
	LEFT OUTER JOIN photos ON users.id = photos.user_id
	GROUP BY users.id, username
	ORDER BY num_of_photos DESC
);

CREATE VIEW user_likes AS (
	SELECT
		id,
        username,
        COUNT(*) AS num_of_likes
	FROM users
	LEFT OUTER JOIN likes ON users.id = likes.user_id
	GROUP BY id, username
	ORDER BY num_of_likes DESC
);

CREATE VIEW user_comments AS (
	SELECT
		users.id,
        username,
        COUNT(*) AS num_of_comments
	FROM users
	LEFT OUTER JOIN comments ON users.id = comments.user_id
	GROUP BY users.id, username
	ORDER BY num_of_comments DESC
);

CREATE VIEW user_followings AS (
	SELECT
		users.id,
		username,
        COUNT(*) AS num_of_followings
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

-- Activity rate
CREATE VIEW user_activity_rate AS (
	SELECT
		users.id, users.username,
		activity,
		DATEDIFF(NOW(), users.created_at) AS days_on_minigram,
		activity / DATEDIFF(NOW(), users.created_at) AS activity_rate
	FROM users
	JOIN user_activity ON users.id = user_activity.id
	ORDER BY activity_rate DESC
);

-- Active users (by activity) (excludes bots)
DROP VIEW active_users;
CREATE VIEW active_users AS (
	SELECT * FROM user_activity
    WHERE
		activity < 1000 AND
		activity > 150
);

-- Active users (by activity rate) (excludes suspected bots and new users)
DROP VIEW active_users;
CREATE VIEW active_users AS (
	SELECT * FROM user_activity_rate
    WHERE
		activity_rate >= 1 AND
        activity < 1000
        AND days_on_minigram > 10
);

-- Active user activities by day
SELECT
	DAYNAME(photos.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN photos ON users.id = photos.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN likes ON users.id = likes.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(comments.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN comments ON users.id = comments.user_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(follows.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN follows ON users.id = follows.follower_id
WHERE users.id IN (SELECT id FROM active_users)
GROUP BY day
ORDER BY total DESC;

-- c) Which users are the most inactive? When are they most active?
DROP VIEW inactive_users;
CREATE VIEW inactive_users AS (
	SELECT * FROM user_activity
    WHERE activity <= 150
);

DROP VIEW inactive_users;
CREATE VIEW inactive_users AS (
	SELECT * FROM user_activity_rate
    WHERE activity_rate <= 0.05
);

-- Inactive user activities by day
SELECT
	DAYNAME(photos.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN photos ON users.id = photos.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN likes ON users.id = likes.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(comments.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN comments ON users.id = comments.user_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

SELECT
	DAYNAME(follows.created_at) AS day,
    COUNT(*) AS total
FROM users
JOIN follows ON users.id = follows.follower_id
WHERE users.id IN (SELECT id FROM inactive_users)
GROUP BY day
ORDER BY total DESC;

-- Cleaning views
DROP VIEW user_activity;
DROP VIEW user_activity_rate;
DROP VIEW user_photos;
DROP VIEW user_likes;
DROP VIEW user_comments;
DROP VIEW user_followings;
DROP VIEW active_users;
DROP VIEW inactive_users;

-- Section 3: Posts and Content
-- a) Which types of content typically receive the most engagement?
-- Engagement = # of likes + (# of comments)*1.5 <----- Comments are worth more
DROP VIEW photo_engagement;
CREATE VIEW photo_engagement AS (
	SELECT
		photo_likes.id AS photo_id,
        total_likes,
        total_comments,
        (total_likes + (1.5*total_comments)) AS engagement
	FROM (
		SELECT
			photos.id,
            COUNT(*) AS total_likes
		FROM photos
		JOIN likes ON photos.id = likes.photo_id
		GROUP BY photos.id
		ORDER BY total_likes DESC
	) AS photo_likes
	JOIN (
		SELECT
			photos.id,
            COUNT(*) AS total_comments
		FROM photos
		JOIN comments ON photos.id = comments.photo_id
		GROUP BY photos.id
		ORDER BY total_comments DESC
	) AS photo_comments
	ON photo_likes.id = photo_comments.id
	HAVING engagement >= 100
	ORDER BY engagement DESC
);

SELECT
	tag_name,
    COUNT(*) AS total
FROM (
	SELECT
		photo_tags.photo_id,
        tags.tag_name
	FROM photo_tags
	JOIN tags ON photo_tags.tag_id = tags.id
	HAVING photo_id IN (SELECT photo_id FROM photo_engagement)
) AS a
GROUP BY tag_name
ORDER BY total DESC;

-- b) What is the ideal time for a user to post content?
SELECT
	HOUR(photos.created_at) AS hour,
    COUNT(*) AS total
FROM photos
WHERE id IN (SELECT photo_id FROM photo_engagement)
GROUP BY hour
ORDER BY total DESC;

-- Cleaning views
DROP VIEW photo_engagement;

-- Section 4: Influencers
-- Influencers are defined as users who have >10% of all users as their followers

CREATE VIEW influencers AS (
	SELECT
		users.id,
        users.username,
        users.created_at,
        COUNT(*) AS num_of_followers
	FROM users
	JOIN follows ON users.id = follows.followee_id
	GROUP BY follows.followee_id
	HAVING num_of_followers > (SELECT COUNT(*) FROM users)*0.1
	ORDER BY num_of_followers DESC
);

-- a) What types of content do influencers post compared to non-influencers?
SELECT
	tags.tag_name,
    COUNT(*) AS total
FROM (
	SELECT * FROM photos
    WHERE photos.user_id IN (SELECT id FROM influencers)
) AS photo_temp
JOIN photo_tags ON photo_temp.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tag_name
ORDER BY total DESC;

SELECT
	tags.tag_name,
    COUNT(*) AS total
FROM (
	SELECT * FROM photos
    WHERE photos.user_id NOT IN (SELECT id FROM influencers)
) AS photo_temp
JOIN photo_tags ON photo_temp.id = photo_tags.photo_id
JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY tag_name
ORDER BY total DESC;

-- b) Find the difference in activity between influencers and non-influencers.
-- i) activity
SELECT
	AVG(activity) AS avg_influencer_activity
FROM (
	SELECT *
	FROM user_activity
	WHERE id IN (SELECT id FROM influencers)
	ORDER BY activity DESC
) AS a;

SELECT
	AVG(activity) AS avg_non_influencer_activity
FROM (
	SELECT *
	FROM user_activity
	WHERE
		id NOT IN (SELECT id FROM influencers) AND
        activity < 1000
	ORDER BY activity DESC
) AS a;

-- ii) activity rate
SELECT
	AVG(activity_rate) AS avg_influencer_activity_rate
FROM (
	SELECT *
	FROM user_activity_rate
	WHERE id IN (SELECT id FROM influencers)
	ORDER BY activity DESC
) AS a;

SELECT
	AVG(activity_rate) AS avg_non_influencer_activity_rate
FROM (
	SELECT *
	FROM user_activity_rate
	WHERE id NOT IN (SELECT id FROM influencers)
	ORDER BY activity DESC
) AS a;

-- c) How do influencers impact other users' engagement on MiniGram?
-- Find which users engage the most with influencers

CREATE VIEW user_influencer_likes AS (
	SELECT
		likes.user_id AS user_id,
        photos.user_id AS influencer,
        COUNT(*) AS total_likes
	FROM likes
	JOIN photos ON likes.photo_id = photos.id
	GROUP BY user_id, influencer
	HAVING influencer in (SELECT id FROM influencers)
	ORDER BY total_likes DESC
);

CREATE VIEW user_influencer_comments AS (
	SELECT
		comments.user_id AS user_id,
        photos.user_id AS influencer,
        COUNT(*) AS total_comments
	FROM comments
	JOIN photos ON comments.photo_id = photos.id
	GROUP BY user_id, influencer
	HAVING influencer in (SELECT id FROM influencers)
	ORDER BY total_comments DESC
);

CREATE VIEW user_influencer_engagement AS (
	SELECT
		user_influencer_likes.user_id,
		user_influencer_likes.influencer,
		total_likes,
		total_comments,
		total_likes + total_comments AS total_engagement
	FROM user_influencer_likes
	JOIN user_influencer_comments ON
		user_influencer_likes.user_id = user_influencer_comments.user_id AND
		user_influencer_likes.influencer = user_influencer_comments.influencer
	ORDER BY total_engagement DESC
);

CREATE VIEW user_non_influencer_likes AS (
	SELECT
		likes.user_id AS user_id,
        photos.user_id AS non_influencer,
        COUNT(*) AS total_likes
	FROM likes
	JOIN photos ON likes.photo_id = photos.id
	GROUP BY user_id, non_influencer
	HAVING non_influencer NOT IN (SELECT id FROM influencers)
	ORDER BY total_likes DESC
);

CREATE VIEW user_non_influencer_comments AS (
	SELECT
		comments.user_id AS user_id,
        photos.user_id AS non_influencer,
        COUNT(*) AS total_comments
	FROM comments
	JOIN photos ON comments.photo_id = photos.id
	GROUP BY user_id, non_influencer
	HAVING non_influencer NOT IN (SELECT id FROM influencers)
	ORDER BY total_comments DESC
);

CREATE VIEW user_non_influencer_engagement AS (
	SELECT
		user_non_influencer_likes.user_id,
		user_non_influencer_likes.non_influencer,
		total_likes,
		total_comments,
		total_likes + total_comments AS total_engagement
	FROM user_non_influencer_likes
	JOIN user_non_influencer_comments ON
		user_non_influencer_likes.user_id = user_non_influencer_comments.user_id AND
		user_non_influencer_likes.non_influencer = user_non_influencer_comments.non_influencer
	ORDER BY total_engagement DESC
);

-- Average engagement of users towards influencers and non-influencers
SELECT AVG(total_engagement) FROM user_influencer_engagement;
SELECT AVG(total_engagement) FROM user_non_influencer_engagement;

-- Conduct t-test after

-- Section 5: Bots
-- Bots are defined as users who like >5% of all photos

DROP VIEW suspected_bots;
CREATE VIEW suspected_bots AS (
	SELECT
		users.id,
        users.username
	FROM users
	JOIN likes ON users.id = likes.user_id
	GROUP BY likes.user_id
	HAVING COUNT(*) >= (SELECT COUNT(*) FROM photos) * 0.05
);

-- a) When are the bots most active?
SELECT
	YEAR(likes.created_at) AS year,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY year
ORDER BY total DESC;

SELECT
	MONTHNAME(likes.created_at) AS month,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY month
ORDER BY total DESC;

SELECT
	DAYNAME(likes.created_at) AS day,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY day
ORDER BY total DESC;

SELECT
	HOUR(likes.created_at) AS hour,
    COUNT(*) AS total
FROM likes
WHERE user_id IN (SELECT id FROM suspected_bots)
GROUP BY hour
ORDER BY total DESC;

-- b) How do bots impact the posts that they engage in?
-- Create df with photo.id, bot_likes, user_likes, total_likes

CREATE VIEW user_bot_likes AS (
	WITH likes_by_bots AS (

		SELECT
			photo_id,
			COUNT(*) AS bot_likes
		FROM likes
		WHERE user_id IN (SELECT id FROM suspected_bots)
		GROUP BY photo_id

	),

	likes_by_users AS (

		SELECT
			photo_id,
			COUNT(*) AS user_likes
		FROM likes
		WHERE user_id NOT IN (SELECT id FROM suspected_bots)
		GROUP BY photo_id

	)

	SELECT
		likes_by_bots.photo_id,
		likes_by_bots.bot_likes,
		likes_by_users.user_likes,
		likes_by_bots.bot_likes + likes_by_users.user_likes AS total_likes,
        likes_by_bots.bot_likes / (likes_by_bots.bot_likes + likes_by_users.user_likes) AS pct_of_bot_likes,
        likes_by_users.user_likes / (likes_by_bots.bot_likes + likes_by_users.user_likes) AS pct_of_user_likes
	FROM likes_by_bots
	INNER JOIN likes_by_users ON likes_by_bots.photo_id = likes_by_users.photo_id
);

-- Average percentage of likes by bots and likes by users on photos
SELECT
	AVG(pct_of_bot_likes) AS avg_pct_of_bot_likes,
    AVG(pct_of_user_likes) AS avg_pct_of_user_likes
FROM user_bot_likes;

-- c) Find which accounts (if any) implement the use of bots.
-- Combine user_bot_like with photos and group by user_id
-- Find users where their >50% of their likes are by bots
SELECT
	photos.user_id AS user_id,
    users.username AS username,
	SUM(bot_likes) AS total_likes_by_bots,
	SUM(total_likes) AS total_likes,
	SUM(bot_likes) / SUM(total_likes) AS pct_liked_by_bots
FROM photos
JOIN user_bot_likes ON photos.id = user_bot_likes.photo_id
JOIN users ON photos.user_id = users.id
GROUP BY user_id
HAVING pct_liked_by_bots >= 0.5
ORDER BY pct_liked_by_bots DESC;

-- Section 6: Year by Year Analysis
-- a) Compare the amount of posts/likes/comments from year to year

CREATE VIEW yoy_analysis AS (
	WITH photos_by_year AS (

		SELECT
			YEAR(photos.created_at) AS year,
			COUNT(*) AS total_photos
		FROM photos
		GROUP BY year
		ORDER BY year

	),

	likes_by_year AS (

		SELECT
			YEAR(likes.created_at) AS year,
			COUNT(*) AS total_likes
		FROM likes
		GROUP BY year
		ORDER BY year

	),

	comments_by_year AS (

		SELECT
			YEAR(comments.created_at) AS year,
			COUNT(*) AS total_comments
		FROM comments
		GROUP BY year
		ORDER BY year

	)

	SELECT
		photos_by_year.year AS year,
		total_photos,
		total_likes,
		total_comments,
		total_photos + total_likes + total_comments AS total
	FROM photos_by_year
	JOIN likes_by_year ON photos_by_year.year = likes_by_year.year
	JOIN comments_by_year ON photos_by_year.year = comments_by_year.year
	ORDER BY year
);

SELECT * FROM yoy_analysis;

-- b) Is there an increase in the rate of user and content growth from year to year?
-- Find the percentage increase from previous year

SELECT
	year,
    total_photos,
    (LEAD(total_photos) OVER() - total_photos) / total_photos AS photos_pct_diff,
    total_likes,
    (LEAD(total_likes) OVER() - total_likes) / total_likes AS likes_pct_diff,
    total_comments,
    (LEAD(total_comments) OVER() - total_comments) / total_comments AS comments_pct_diff,
    total,
	(LEAD(total) OVER() - total) / total AS pct_diff
FROM yoy_analysis;
