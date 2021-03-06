/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM  Facilities 
WHERE membercost > 0;

/* name
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court */

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) 
FROM  Facilities 
WHERE membercost = 0;

/* COUNT(name)
4 */

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND (membercost < monthlymaintenance*.2);

/*facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1,5);

/* name	membercost	guestcost	facid	initialoutlay	monthlymaintenance	
Tennis Court 2	5.0	25.0	1	8000	200
Massage Room 2	9.9	80.0	5	4000	3000 */

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
CASE WHEN monthlymaintenance > 100
THEN  'expensive'
ELSE  'cheap'
END AS  "cost"
FROM Facilities;

/*name	cost	
Tennis Court 1	expensive
Tennis Court 2	expensive
Badminton Court	cheap
Table Tennis	cheap
Massage Room 1	expensive
Massage Room 2	expensive
Squash Court	cheap
Snooker Table	cheap
Pool Table	cheap*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
WHERE joindate = (
SELECT MAX(joindate) 
FROM Members
);

/*firstname	surname	joindate	
Darren	Smith	2012-09-26 18:08:45*/

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT(Members.firstname," ", Members.surname," ", Facilities.name) as entry
FROM Members
INNER JOIN Bookings ON Members.memid = Bookings.memid
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE 'Tennis Court%'
ORDER BY entry;

/* entry	
Anne Baker Tennis Court 1
Anne Baker Tennis Court 2
Burton Tracy Tennis Court 1
Burton Tracy Tennis Court 2
...
John Hunt Tennis Court 2 */

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT CONCAT(firstname, " ", surname, " ", name) AS entry,
CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
ORDER BY cost DESC;

/* entry	cost	
GUEST GUEST Massage Room 2	320.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Tennis Court 2	150.0
GUEST GUEST Tennis Court 1	75.0
GUEST GUEST Tennis Court 2	75.0
GUEST GUEST Tennis Court 1	75.0
GUEST GUEST Squash Court	70.0
Jemima Farrell Massage Room 1	39.6
GUEST GUEST Squash Court	35.0
GUEST GUEST Squash Court	35.0 */

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT
CONCAT(firstname, " ", surname, " ", name) AS entry,
cost
FROM
(SELECT
firstname,
surname,
name,
CASE WHEN firstname = 'GUEST'
 THEN guestcost * slots 
 ELSE membercost * slots END AS cost,
starttime
FROM Members
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid) AS inner_table
WHERE starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND cost > 30
ORDER BY cost DESC;

/*entry	cost	
GUEST GUEST Massage Room 2	320.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Massage Room 1	160.0
GUEST GUEST Tennis Court 2	150.0
GUEST GUEST Tennis Court 2	75.0
GUEST GUEST Tennis Court 1	75.0
GUEST GUEST Tennis Court 1	75.0
GUEST GUEST Squash Court	70.0
Jemima Farrell Massage Room 1	39.6
GUEST GUEST Squash Court	35.0
GUEST GUEST Squash Court	35.0*/

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name, revenue
FROM
(SELECT
name,
SUM(CASE WHEN memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS revenue
FROM Bookings INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
GROUP BY name) AS temptable
WHERE revenue < 1000
ORDER BY revenue;

/*name	revenue	
Table Tennis	180.0
Snooker Table	240.0
Pool Table	270.0 */