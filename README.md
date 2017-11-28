# MasteryGrids_feedback
Students' feedback collection functionality added to Mastery Grids (initially just for QuizJet content)

Instructions for preparing the development environment: 

1. Download the latest commit from Github.

2. Put um-vis-dev2 in htdocs.

3. Import webex21.sql into PHPMyAdmin. Make sure you have user as root and password as root in the db to match web.xml or change to what you want to use.

4. Import QuizJet folder into Eclipse.

5. Setup Tomcat v7 server. (Note: It must be version 7 in order to be compatible.)

6. Right click on the QuizJet folder in Eclipse. Go to Properties > Java Build Path > Add Libraries. Add JRE System Library and Server Runtime.

7. In web.xml, adjust any necessary settings. 

	a. Change this local path.

	<param-value>/Users/yunhuang/Center/Study/Codes/CodingProjects/Java/QuizJET/		QuizJET_FromPET/</param-value>

	b. Make sure you are using 3306 for MySQL or adjust accordingly.

	<param-value>jdbc:mysql://localhost:3306/webex21</param-value>

	c. Make sure the username and password matches to your username and password in 	the db or adjust accordingly.

	<context-param>
		<param-name>db.user</param-name>
		<param-value>root</param-value>
	</context-param>
	<context-param>
		<param-name>db.passwd</param-name>
		<param-value>root</param-value>
	</context-param>

8. Run it. Go to http://localhost:8080/QuizJET/.

9. Import FeedbackCollector folder into Eclipse.

10. Run FeedbackCollector application in the same way as QuizJet.

11. Check if FeedbackCollector works by loading the following URL: http://localhost:8080/ConceptualFeedback/ConceptHandler?actID=1&provider=quizjet (here actID is the id of the Quiz on the QuizJet database which is webex21). You should receive an array of concepts that appear in a specific QuizJet problem.