# MiniGram

## Overview
MiniGram is a social media platform designed for users to share moments from their lives with close friends and their broader community. It enables users to post photos, engage with followers, and interact with content through likes, comments, and descriptive tags, allowing easy discovery of similar posts.

This report provides an in-depth analysis of MiniGram's database, focusing on how users utilize the application and how they interact with one another within it. It offers valuable insights into user behavior that the marketing team can leverage to develop targeted strategies, enhancing outreach to specific user segments.

The following areas will be covered in this report:
* **User Engagement**: Discover the distribution of user registration period and which users are most active/inactive and when they are most active/inactive.
* **Posts and Content**: Investigate what types of post gets the most engagement and how users can optimize the timing of their post to increase their change to make it go viral.
* **Influencers**: Find the different influencers on MiniGram and how they behave differently from normal users.
* **Bots**: Locate suspected bots through their behaviours and understand the impact that they create through their interactions with other users and their activities.
* **Year over Year Analysis**: Observe the trends of how MiniGram is progressing from year to year.

**Disclaimer:** The data in MiniGram was created using a synthetic process, detailed in the file `Synthetic Data Generator.ipynb`. This approach allowed for full control over the distributions and variability of key features such as user behavior, engagement metrics, and activity patterns. If you're looking to fine-tune the dataset, you can easily adjust various parameters within the notebook to better suit different analytical or modeling needs.

## Executive Summary

Upon analysis, we can see a steady growth in user registrations and activity from year to year with 5000 total users and 25000 total photos posted on MiniGram by the end of 2024. Influencers make up 2.7% of the users and plays a pivotal role in driving up engagement on the platform, with users being 4.21x more likely to engage with posts by influencers compared to normal users. The issue of bots on MiniGram is significant, with suspected bots comprising approximately 0.98% of the total user base. These bots have a noticeable impact on user engagement, as they account for an average of 23% of the likes on photos.

Results of further analysis can be found below under the Deep Dive section of this report.

You can find the link to the Tableau dashboard [here](https://public.tableau.com/app/profile/anaqi.amir/viz/MiniGram/MiniGramReport).

![alt text](<MiniGram Report.png>)

## Data Structure
MiniGram's database structure can be seen below consisting of 7 tables:
1. users
2. photos
3. tags
4. photo_tags
5. follows
6. likes
7. comments

![ERD MiniGram](https://github.com/user-attachments/assets/9913087b-bf00-49c7-8372-534c53ea1e6e)

## Deep Dive

**Quick Numbers:**
* 5000 users
* 25000 photos
* 250 tags
* 504025 likes
* 350333 comments
* 135 influencers
* 49 suspected bots
* An average of 5 photos per user
* An average of 20.16 likes per photo
* An average of 14.01 comments per photo

**User Engagement:**

* **User Registration Trends**: Registrations on MiniGram peaked in 2020, with 491 new users, likely influenced by the COVID-19 pandemic as people sought to increase their social interactions online. This surge reflects how external factors can significantly impact user acquisition.

* **Seasonal Registration Patterns**: August stands out as the most popular month for sign-ups, with 451 registrations, while February saw the lowest with only 359. January and March also experienced lower registration numbers (417 and 408, respectively), indicating a potential gap in marketing efforts at the start of the year. This trend suggests that ramping up promotional activities in early months could help maintain consistent growth throughout the year.

* **Activity Patterns Among Active Users**: Active users tend to post photos and follow others mostly on weekends, with 231 photos posted on Saturdays and 989 follows on Sundays. In contrast, Wednesdays see the highest engagement in likes (4,370) and comments (3,299). This suggests users reserve weekends for personal activities, such as posting and following, when they have more free time, while passive activities like liking and commenting occur mid-week when users are likely busier. These patterns align with intuitive user behavior.

* **Inactive User Engagement**: For the 255 inactive users, engagement peaks at the end of the week. These users liked the most photos on Thursdays (2,340), posted the most on Fridays (172), and followed other users primarily on Saturdays (553). This insight can guide targeted marketing efforts to re-engage these users by leveraging their existing activity patterns to increase their overall platform interaction.

**Posts and Content:**

* **Highly Engaged Tags**: The top three tags associated with highly engaged photos are positive in nature—bestoftheday (14), cute (10), and celebration (10). This indicates that users are more likely to engage with content that is uplifting or positive, suggesting a strong correlation between emotional appeal and user interaction.

* **Photography-Related Engagement**: Interestingly, three of the top eight tags are related to photography—blackandwhite (9), camera (8), and digitalmarketing (8). This highlights the interest of MiniGram's audience in visually-oriented content, making photography a key driver of engagement on the platform.

* **Sports and Fitness Tags**: Three out of the top twelve tags are associated with sports and fitness—gym (8), cardio (7), and biker (7). This shows that users interested in active lifestyles form a significant segment of the engaged community, making fitness-related content another important category for driving interactions.

**Influencers**:

* **Top Tags for Influencers**: Influencers on MiniGram predominantly use the tags bestoftheday, blackandwhite, comedy, quoteoftheday, and cute, with bestoftheday being the most popular at 33 instances. This suggests that influencers tend to focus on visually appealing or emotionally resonant content to engage their audiences.

* **Top Tags for Non-Influencers**: Non-influencers gravitate toward the tags blackandwhite, photography, comedy, motivation, and bestoftheday, with blackandwhite being the most frequently used at 751 instances. This indicates that non-influencers also place a strong emphasis on photography and motivational content to drive engagement.

* **Shared Tags Between Influencers and Non-Influencers**: The tags bestoftheday, blackandwhite, and comedy are commonly used by both influencers and non-influencers, highlighting that these themes resonate across different user groups and play a significant role in generating engagement regardless of follower count or influence level.

* **Difference in Activities**: There is no significant difference in the activity levels or activity rates between influencers and non-influencers, suggesting that it is not the volume of activity that drives someone to become an influencer, but rather an external factor that remains to be identified.

* **Engagement in Posts**: There is a significant disparity in user engagement between posts by influencers and non-influencers, with posts from influencers being 4.21 times more likely to receive interaction.

**Bots:**

* **Yearly Trends**
    * **Highest Activity (2024)**: The year 2024 saw the most bot engagement, with 21,563 bot likes recorded. This reflects a growing presence of bots on the platform.
    * **Lowest Activity (2014)**: In contrast, 2014 had the least amount of bot activity, with only 682 bot likes.
    * **Increasing Bot Activity Over Time**: A clear trend emerges where bot activity increases as the years progress. This is likely due to the continuous creation of bot accounts, contributing to the growing level of engagement.
* **Monthly Trends**
    * **Most Active Month (December)**: December saw the highest bot activity, with 7,696 bot likes.
    * **Least Active Month (February)**: February registered the fewest bot likes, totaling 5,223.
    * **Second Half of the Year Spike**: Interestingly, bot activity trends higher in the latter half of the year. The last six months hold the highest bot engagement totals, suggesting bots become more active towards year-end.
* **Day of the Week Trends**
    * **Highest Activity Day (Thursday)**: Thursdays have the highest bot activity, with 11,351 bot likes.
    * **Lowest Activity Day (Wednesday)**: Wednesdays saw the least bot engagement, with 10,964 bot likes.
    * **No Distinct Weekly Pattern**: Bot activity does not show a consistent pattern when broken down by the day of the week, suggesting a more random distribution.
* **Hourly Trends**
    * **Peak Hour (8 PM)**: The hour of 8 PM saw the most bot activity, with 3,363 bot likes.
    * **Lowest Hour (4 AM)**: The least amount of bot activity occurred at 4 AM, with 3,149 bot likes.
    * **No Clear Hourly Pattern**: Similar to the weekly breakdown, bot activity does not follow a predictable pattern based on the time of day.
* **Bot Impact on Engagement**
    * **Average Bot-Driven Likes**: On average, 23% of likes on photos are generated by bots. This significant percentage suggests bots have a notable impact on the platform’s engagement metrics.
    * **Users Boosting Engagement via Bots:**
        * There are 11 users whose posts receive more than 50% of their total likes from bots.
        * The user xcarter stands out, with 70% of their likes coming from bots. This highlights a potential issue of artificially inflated engagement, raising questions about the authenticity of user popularity.

**Year over Year Analysis:**

* **Steady Growth Across All Pillars:** There has been a steady increase in total activity across all key pillars (users, engagement, content creation, etc.) from year to year. This consistent growth highlights the platform’s ability to maintain momentum as it evolves.

* **2015: A Year of Success:** The year 2015 experienced the highest growth rates across all pillars, indicating that MiniGram's user adoption strategy in its initial stages was highly successful. This early surge established a strong foundation for the platform.

* **Post-2015 Decline in Growth:** Following the rapid expansion in 2015, the platform has not been able to replicate the same level of success in subsequent years. While growth has continued, the rates have tapered off, suggesting that the initial surge was unique to MiniGram’s early launch phase.

* **2024 Surge in Growth (Excluding Users):** There was a notable resurgence in growth across all pillars in 2024, except for the user base. This may point to increased activity and engagement from existing users or possibly new feature rollouts driving higher levels of interaction on the platform.

* **User Growth Consistency:** Despite fluctuations in other areas, user growth has remained relatively stable. The platform has seen around 400 new users each year, with annual growth rates staying within a +/- 10% range. This steady increase suggests that MiniGram has maintained a consistent appeal to new users over time, even if engagement growth has varied.

## Limitations
The primary limitation of this project lies in the nature of the data, as it is based on synthetic data rather than real-world user interactions. As a result, the findings of this report may not perfectly mirror actual user behavior on social media platforms. However, the objective of this report is to analyze the unique dynamics of MiniGram's ecosystem. Therefore, it should be viewed as an analysis specific to this application, rather than a comprehensive reflection of broader social media trends.

## Recommendations

Recommendations for Growing MiniGram as a Platform

**Boosting User Growth Through Targeted Marketing:**
* MiniGram has experienced relatively stagnant user growth, averaging around 450 new users per year over the past decade. A new marketing push, particularly focused on Q1, is highly recommended. Historically, Q1 has had the lowest user adoption rates, with only 1,184 users registering during this period. Launching targeted campaigns during the early months, and emphasizing weekends when both active and inactive users are most engaged, could help increase the platform's overall adoption and engagement.

**Leveraging Popular Content Themes for Partnerships:**
* Analysis of highly engaged posts shows a strong affinity for photography and sports-related tags, suggesting an opportunity for MiniGram to explore partnerships or collaborations with brands and organizations within these industries. By aligning with the interests of its most engaged users, MiniGram could drive both engagement and brand visibility.

**Maximizing Influence Through Influencer Promotion:**
* With posts by influencers being 4.21 times more likely to receive engagement, MiniGram should consider actively promoting its influencers to increase platform awareness. Providing incentives for influencers to create more content and promoting their visibility could help MiniGram capitalize on its existing engagement and mirror the success of platforms like Instagram, TikTok, and YouTube, which have benefited from influencer-driven growth.

**Addressing the Issue of Bot Activity:**
* Although there are only 49 suspected bots on MiniGram, these accounts account for 15.5% of all likes on the platform, with an average of 23% of likes on posts being generated by bots. As MiniGram grows, it will be crucial to manage and mitigate the influence of bots on the platform. I recommend dedicating a development team to proactively identify and eliminate bot accounts to preserve the integrity of user engagement moving forward.
