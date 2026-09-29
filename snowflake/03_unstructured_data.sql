/*
 * 03_unstructured_data.sql
 *
 * Creates tables from the CSV data files (product reviews and support tickets)
 * and builds a Cortex Search Service over them.
 *
 * Before running: Upload product_reviews.csv and support_tickets.csv to a stage
 * (see instructions below) or insert data directly.
 *
 * Run after: 02_structured_data.sql
 */

USE ROLE RETAIL_DEMO_ROLE;
USE DATABASE RETAIL_DEMO;
USE SCHEMA ECOMMERCE;
USE WAREHOUSE RETAIL_DEMO_WH;

-- ============================================================
-- PRODUCT_REVIEWS table
-- ============================================================
CREATE OR REPLACE TABLE PRODUCT_REVIEWS (
    review_id       INT,
    product_name    VARCHAR(100),
    category        VARCHAR(50),
    rating          INT,
    reviewer_name   VARCHAR(100),
    review_text     VARCHAR(2000),
    review_date     DATE
);

/*
 * Option A: Load from CSV file via stage
 *   1. In Snowsight, go to Data -> Databases -> RETAIL_DEMO -> ECOMMERCE
 *   2. Click on PRODUCT_REVIEWS table -> Load Data
 *   3. Select your warehouse, browse and upload data/product_reviews.csv
 *   4. File format: CSV, header: yes, field delimiter: comma
 *
 * Option B: Use PUT + COPY INTO from SnowSQL/CLI:
 *   PUT file:///path/to/data/product_reviews.csv @~;
 *   COPY INTO PRODUCT_REVIEWS FROM @~/product_reviews.csv
 *     FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1 FIELD_OPTIONALLY_ENCLOSED_BY='"');
 *
 * Option C: Insert directly (sample of 50 rows included below)
 */

INSERT INTO PRODUCT_REVIEWS VALUES
(1,'Wireless Headphones Pro','Electronics',5,'Sarah M.','Absolutely love these headphones! The noise cancellation is incredible on flights. Battery lasts forever. Best purchase I have made this year.','2024-06-15'),
(2,'Wireless Headphones Pro','Electronics',4,'James K.','Sound quality is excellent and the ANC works great. Only downside is they get a bit warm after 2-3 hours of continuous use. Still highly recommend.','2024-06-20'),
(3,'Wireless Headphones Pro','Electronics',3,'Lisa P.','Decent headphones for the price. ANC is good but not as strong as competitors. Bluetooth connection drops occasionally when walking around.','2024-07-01'),
(4,'Wireless Headphones Pro','Electronics',5,'Michael R.','The multipoint connection feature is a game changer. I can switch between my laptop and phone seamlessly. Audio quality with LDAC codec is phenomenal.','2024-07-10'),
(5,'Wireless Headphones Pro','Electronics',2,'Amy T.','Had connectivity issues from day one. Bluetooth keeps disconnecting from my iPhone. Tried the reset procedure from the manual but it only temporarily fixes it.','2024-07-15'),
(6,'SmartWatch X1','Electronics',5,'David L.','This watch replaced my Fitbit and Apple Watch. Sleep tracking is incredibly accurate and the 7-day battery life means I actually wear it to bed. GPS works perfectly for runs.','2024-06-18'),
(7,'SmartWatch X1','Electronics',4,'Jennifer W.','Great smartwatch with tons of features. The health monitoring is comprehensive. Only wish the always-on display did not drain the battery so much - goes from 7 days to 3.','2024-06-25'),
(8,'SmartWatch X1','Electronics',4,'Robert H.','Paired easily with my Android phone. Heart rate monitoring seems accurate compared to my chest strap. The stress monitoring feature is surprisingly useful.','2024-07-05'),
(9,'SmartWatch X1','Electronics',2,'Karen S.','Watch stopped syncing with the ShopSmart Health app after the last update. Have to unpair and repair every time. Very frustrating for a $250 device.','2024-07-12'),
(10,'SmartWatch X1','Electronics',1,'Thomas B.','Screen cracked after just 3 weeks of normal use. No drops or impacts. The 5ATM water resistance claim seems questionable too - had condensation under the screen after swimming.','2024-07-20'),
(11,'Bluetooth Speaker BoomBox','Electronics',5,'Rachel G.','Took this speaker to the pool party and it was a hit! Sound is incredible for its size. The PartyLink feature with two speakers creates amazing stereo sound.','2024-06-22'),
(12,'Bluetooth Speaker BoomBox','Electronics',4,'Chris M.','Really solid speaker. Bass is punchy and it gets surprisingly loud. Battery lasts all day at medium volume. The waterproofing gives me peace of mind at the beach.','2024-07-02'),
(13,'Bluetooth Speaker BoomBox','Electronics',3,'Emily F.','Good speaker for the price but the bass boost mode is way too aggressive. Standard mode sounds much better. Also the PartyLink feature is hit or miss with connectivity.','2024-07-08'),
(14,'Bluetooth Speaker BoomBox','Electronics',5,'Daniel P.','Best portable speaker I have owned. The IPX7 rating is legit - accidentally dropped it in the pool and it kept playing. Sound quality rivals speakers twice the price.','2024-07-18'),
(15,'Bluetooth Speaker BoomBox','Electronics',2,'Nicole J.','Speaker stopped holding a charge after 2 months. Battery dies after about 3 hours instead of the advertised 20. Contacted support and waiting for warranty replacement.','2024-08-01'),
(16,'Laptop Stand Ergo','Accessories',5,'Mark D.','Simple and effective. My neck pain from looking down at my laptop has completely gone. The aluminum build feels premium and it is light enough to carry to the office.','2024-06-28'),
(17,'Laptop Stand Ergo','Accessories',4,'Susan B.','Works great for my 15-inch MacBook Pro. Holds it securely at a comfortable angle. Only minor complaint is the silicone pads started peeling after a month.','2024-07-04'),
(18,'Laptop Stand Ergo','Accessories',5,'Andrew K.','Perfect ergonomic solution. I use it with an external keyboard and the viewing angle is much better. Hinge tension adjustment is a thoughtful feature.','2024-07-14'),
(19,'Laptop Stand Ergo','Accessories',3,'Patricia N.','It does the job but feels a bit flimsy with my heavier 17-inch gaming laptop. The hinge loosens over time and needs frequent adjustment. Fine for lighter laptops.','2024-07-22'),
(20,'Laptop Stand Ergo','Accessories',4,'George W.','Good value for $40. Folds flat and fits in my laptop bag. I use it every day at my standing desk setup. Recommended for anyone who works on a laptop all day.','2024-08-05'),
(21,'Wireless Headphones Pro','Electronics',5,'Olivia C.','The comfort level is outstanding. I wear these 8+ hours during work from home days. Ear cushions are soft and do not press on my glasses frames.','2024-08-10'),
(22,'Wireless Headphones Pro','Electronics',4,'Nathan S.','Quick charge feature is a lifesaver. 10 minutes gives me enough juice for a 3-hour flight. The carrying case is also surprisingly nice quality.','2024-08-15'),
(23,'SmartWatch X1','Electronics',5,'Victoria H.','The SpO2 monitoring caught an issue my doctor later confirmed. Literally a health lifesaver. Also love the 100+ watch faces - I change mine weekly.','2024-08-12'),
(24,'SmartWatch X1','Electronics',3,'Brian F.','Decent watch but the app is clunky. Step count seems higher than actual steps. GPS accuracy is good though and the band is comfortable for all-day wear.','2024-08-18'),
(25,'Bluetooth Speaker BoomBox','Electronics',4,'Stephanie R.','Great for outdoor gatherings. The carabiner clip is handy for attaching to a backpack. Sound fills a large patio area easily. Would buy again.','2024-08-20'),
(26,'Wireless Headphones Pro','Electronics',1,'Derek L.','Left ear cup stopped producing sound after 6 weeks. Customer service was helpful but it should not happen with $150 headphones. Waiting for replacement under warranty.','2024-08-25'),
(27,'SmartWatch X1','Electronics',4,'Catherine A.','The NFC for contactless payments is super convenient. Battery life lives up to the 7-day claim. Notifications mirror my phone perfectly. Very happy with it.','2024-08-28'),
(28,'Laptop Stand Ergo','Accessories',2,'Ryan T.','The hinge failed after 2 months of daily use. My laptop fell and got scratched. Not impressed with the durability for the price. Should have spent more on a better brand.','2024-09-01'),
(29,'Bluetooth Speaker BoomBox','Electronics',5,'Michelle K.','Camping trip essential! Used it for 3 days on a single charge at moderate volume. Survived rain and dust without issues. The outdoor EQ mode sounds great in the forest.','2024-09-05'),
(30,'Wireless Headphones Pro','Electronics',4,'Jason P.','Upgraded from the previous model and the difference in ANC is night and day. 35dB noise reduction is real. Call quality with the dual mics is also much improved.','2024-09-08'),
(31,'SmartWatch X1','Electronics',5,'Laura M.','As a runner this watch is everything I need. GPS locks fast the route tracking is precise and the heart rate zones during workouts are motivating. Love it.','2024-09-10'),
(32,'Bluetooth Speaker BoomBox','Electronics',3,'Timothy G.','Sound is good for the price but the volume buttons are too small and hard to press when your hands are wet. Design could use some improvement for a waterproof speaker.','2024-09-12'),
(33,'Laptop Stand Ergo','Accessories',5,'Angela D.','Bought 5 of these for our office team. Everyone loves them. Simple clean design and the angle range is perfect. Allen wrench for hinge adjustment is a nice touch.','2024-09-15'),
(34,'Wireless Headphones Pro','Electronics',3,'Kevin W.','Sound leaks at higher volumes which defeats the purpose of over-ear headphones. Also the headband creates noticeable pressure on top of my head after a while.','2024-09-18'),
(35,'SmartWatch X1','Electronics',4,'Diana R.','The watch faces are beautiful on the AMOLED display. Sleep tracking breakdown into light deep and REM stages matches my Oura ring data closely. Impressed.','2024-09-20'),
(36,'Wireless Headphones Pro','Electronics',5,'Paul N.','The transparency mode is so natural I forget I have headphones on. Perfect for office use where I need to hear colleagues. The best feature of these headphones.','2024-09-22'),
(37,'Bluetooth Speaker BoomBox','Electronics',4,'Hannah E.','Bought the teal color and it looks great. Speaker sounds fantastic in Standard mode. The bass boost mode is a bit much for my taste but the Outdoor mode is perfect for BBQs.','2024-09-25'),
(38,'SmartWatch X1','Electronics',2,'Steven C.','The band broke at the pin connection after 3 months. Had to buy a replacement. For a $250 watch the band quality should be better. Watch itself works fine though.','2024-09-28'),
(39,'Laptop Stand Ergo','Accessories',4,'Marie L.','Lightweight and portable which is exactly what I needed. Takes my 14-inch laptop perfectly. The rubber feet keep it stable on my glass desk which I was worried about.','2024-10-01'),
(40,'Wireless Headphones Pro','Electronics',4,'Alex V.','LDAC support makes these headphones sound amazing with my Sony Walkman. The soundstage is wide and detailed. Not quite audiophile level but impressive for wireless.','2024-10-05'),
(41,'Bluetooth Speaker BoomBox','Electronics',5,'Rebecca U.','Paired two of these in PartyLink mode for my daughters birthday party. The whole backyard had clear music. Kids were dancing for hours. Worth every penny.','2024-10-08'),
(42,'SmartWatch X1','Electronics',3,'Jonathan M.','Good features but the touch screen is sometimes unresponsive especially after workouts when my fingers are sweaty. Have to wipe the screen to get it to register taps.','2024-10-10'),
(43,'Wireless Headphones Pro','Electronics',5,'Sandra I.','I compared these against Sony and Bose at the same price range and chose these. No regrets. The 40-hour battery and quick charge make them the most practical option.','2024-10-12'),
(44,'Laptop Stand Ergo','Accessories',3,'William O.','Does the job but nothing special. The aluminum is thin and flexes a bit under my 16-inch laptop. Works fine for lighter machines.','2024-10-15'),
(45,'SmartWatch X1','Electronics',5,'Elizabeth H.','Perfect fitness companion. Tracked my marathon training over 3 months. The GPS is accurate and the heart rate data helped me optimize my training zones. Highly recommend for athletes.','2024-10-18'),
(46,'Bluetooth Speaker BoomBox','Electronics',1,'Christopher J.','Received a defective unit. No sound from the right driver. Contacted support immediately and they are sending a replacement. Hope the next one works properly.','2024-10-20'),
(47,'Wireless Headphones Pro','Electronics',4,'Amanda Q.','Very comfortable and great sound. The only thing missing is a physical volume knob - the button-based volume control is a bit clunky. Otherwise an excellent pair of headphones.','2024-10-22'),
(48,'SmartWatch X1','Electronics',4,'Matthew Z.','Impressive display and smooth UI. The watch can store music offline for Bluetooth headphone playback during runs without my phone. 32GB storage is generous.','2024-10-25'),
(49,'Laptop Stand Ergo','Accessories',5,'Jessica Y.','This little stand has made such a difference to my work-from-home setup. My posture has improved noticeably. Simple affordable and effective. Five stars.','2024-10-28'),
(50,'Bluetooth Speaker BoomBox','Electronics',4,'Richard B.','Solid build quality and impressive sound for the price. The USB-C charging is convenient. Would give 5 stars if it had an aux input for older devices.','2024-10-30');

-- ============================================================
-- SUPPORT_TICKETS table
-- ============================================================
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id       INT,
    customer_name   VARCHAR(100),
    product_name    VARCHAR(100),
    category        VARCHAR(50),
    issue_type      VARCHAR(50),
    description     VARCHAR(2000),
    status          VARCHAR(20),
    created_date    DATE
);

INSERT INTO SUPPORT_TICKETS VALUES
(1,'Sarah Johnson','Wireless Headphones Pro','Electronics','Connectivity','Bluetooth keeps dropping when I walk more than 3 meters from my phone. Tried resetting per the manual instructions but issue persists. Using iPhone 14 Pro.','Open','2024-07-15'),
(2,'Mike Chen','SmartWatch X1','Electronics','Software','ShopSmart Health app crashes every time I try to sync sleep data. Phone is Samsung Galaxy S24. App version 3.2.1. Watch firmware is up to date.','In Progress','2024-07-18'),
(3,'Emily Davis','Bluetooth Speaker BoomBox','Electronics','Hardware','Battery only lasts about 3 hours instead of the advertised 20 hours. Speaker is 2 months old. Have been charging fully before each use.','Open','2024-07-20'),
(4,'Robert Wilson','Laptop Stand Ergo','Accessories','Hardware','Hinge mechanism broke after 6 weeks of daily use. The stand can no longer hold my laptop at any angle. Laptop weighs about 2kg which is well under the 10kg limit.','Resolved','2024-07-22'),
(5,'Jennifer Martinez','Wireless Headphones Pro','Electronics','Audio Quality','Left ear cup produces a buzzing/crackling sound at any volume level. Started about a week ago. No physical damage to the headphones.','Open','2024-07-25'),
(6,'David Thompson','SmartWatch X1','Electronics','Hardware','Screen has developed condensation under the glass after wearing it in the shower. Watch is rated 5ATM but water got inside after just normal shower use.','In Progress','2024-07-28'),
(7,'Lisa Anderson','Wireless Headphones Pro','Electronics','Comfort','Headband creates too much pressure on top of my head causing headaches after 1 hour of use. Is there a way to adjust the clamping force?','Resolved','2024-08-01'),
(8,'James Taylor','Bluetooth Speaker BoomBox','Electronics','Connectivity','PartyLink feature will not connect my two speakers. Both are powered on and within 1 meter of each other. Tried the double-press procedure multiple times.','Open','2024-08-05'),
(9,'Karen Brown','SmartWatch X1','Electronics','Software','Heart rate readings seem inaccurate - showing 120 BPM while sitting still. Wearing the watch correctly as per manual guidelines. Cleaned sensor. Issue persists.','Open','2024-08-08'),
(10,'Thomas Garcia','Laptop Stand Ergo','Accessories','Quality','Silicone anti-slip pads fell off after 3 weeks. Laptop now slides on the bare aluminum surface. Used the extra pads included but they also came off quickly.','Resolved','2024-08-10'),
(11,'Amanda White','Wireless Headphones Pro','Electronics','Battery','Headphones only lasting about 15 hours instead of 40 hours advertised. ANC is turned off. Using SBC codec. Headphones are 3 months old.','In Progress','2024-08-12'),
(12,'Chris Robinson','SmartWatch X1','Electronics','Connectivity','Watch keeps losing connection to my phone throughout the day. Have to manually reconnect via the app 3-4 times daily. Phone is Pixel 8.','Open','2024-08-15'),
(13,'Patricia Clark','Bluetooth Speaker BoomBox','Electronics','Audio Quality','Distorted sound at volumes above 70%. The bass boost mode makes it worse. Standard mode is fine at lower volumes but any higher and it clips badly.','Resolved','2024-08-18'),
(14,'Steven Lee','Wireless Headphones Pro','Electronics','Return Inquiry','I bought these 25 days ago and want to return them. The ANC is not strong enough for my open office. Do I need the original box for the return?','Resolved','2024-08-20'),
(15,'Michelle Harris','SmartWatch X1','Electronics','Feature Request','Would love to see a blood pressure monitoring feature in a future update. Also the stress monitoring seems to always show high - not sure how accurate it is.','Closed','2024-08-22'),
(16,'Daniel King','Bluetooth Speaker BoomBox','Electronics','Hardware','USB-C port cover broke off. Now the charging port is exposed. Concerned about water resistance since I mainly use this at the pool.','Open','2024-08-25'),
(17,'Jessica Wright','Laptop Stand Ergo','Accessories','Return Inquiry','Stand wobbles on my desk even though the desk is flat. All 4 rubber feet are intact. Thinking of returning it. Can I get an exchange for a different model?','In Progress','2024-08-28'),
(18,'Ryan Lopez','Wireless Headphones Pro','Electronics','Software','Firmware update bricked my headphones. They turned off during the update and now will not turn back on or charge. LED does not light up at all.','Open','2024-09-01'),
(19,'Angela Hill','SmartWatch X1','Electronics','Battery','Watch battery draining in 2 days instead of 7. Always-on display is OFF. GPS is OFF. Only using basic notifications and health monitoring.','Open','2024-09-05'),
(20,'Nathan Scott','Bluetooth Speaker BoomBox','Electronics','Warranty','Speaker fell from about 1 meter height and now the passive bass radiator rattles. Is this covered under warranty? No cracks visible on the outside.','In Progress','2024-09-08');

-- ============================================================
-- Cortex Search Service
-- ============================================================

-- Combines reviews and tickets into a single searchable corpus.
-- The Cortex Agent will use this for questions about customer feedback,
-- product sentiment, and support issue patterns.

CREATE OR REPLACE CORTEX SEARCH SERVICE RETAIL_DEMO.ECOMMERCE.PRODUCT_REVIEW_SEARCH
    ON chunk
    ATTRIBUTES product_name, category, source_type
    WAREHOUSE = RETAIL_DEMO_WH
    TARGET_LAG = '1 hour'
    AS (
        SELECT
            review_text                     AS chunk,
            product_name,
            category,
            'review'                        AS source_type,
            reviewer_name                   AS author,
            rating::VARCHAR                 AS rating,
            review_date::VARCHAR            AS doc_date
        FROM RETAIL_DEMO.ECOMMERCE.PRODUCT_REVIEWS

        UNION ALL

        SELECT
            description                     AS chunk,
            product_name,
            category,
            'support_ticket'                AS source_type,
            customer_name                   AS author,
            NULL                            AS rating,
            created_date::VARCHAR           AS doc_date
        FROM RETAIL_DEMO.ECOMMERCE.SUPPORT_TICKETS
    );
