<%--
Feedback Correct
This is the page that will display feedback after answering a question correctly.
By: Erin Price
Created: Nov 25, 2017
Updated: Nov 26, 2017
--%>

<%@ page language="java"%>
<%@ page import="java.sql.*" %>    
<%@ page import="java.io.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.apache.commons.io.FileUtils"%>

<%@ page language="java"%>

<!-- TO DO: Create a CSS3 stylesheet -->
<link href="feedback.css" rel="stylesheet" type="text/css" />

<link href="quizjet.css" rel="stylesheet" type="text/css" />
<link href="tab.css" rel="stylesheet" type="text/css" />
<SCRIPT type="text/javascript" src="tab.js"></SCRIPT>

<html>
<head>
<title>Feedback: Correct</title>
</head>

<body>
<%
String rdfID=request.getParameter("rdfID");

Connection connection = null;
connection = DriverManager.getConnection(getServletContext().getInitParameter("db.url"),
			  getServletContext().getInitParameter("db.user"),
			  getServletContext().getInitParameter("db.passwd"));

Statement statement = connection.createStatement(); 

ResultSet rs1 = null;
ResultSet rs2 = null;
ResultSet rs3 = null;

int quizID=0;


String query1 = "select QuizID from ent_jquiz where rdfID = '"+rdfID+"'";      
rs1 = statement.executeQuery(query1);

  
while (rs1.next()) {
    quizID = rs1.getInt("QuizID");
}%>
	<!-- TO DO: Submit the form and store in the db -->
	<form name="feedbackCorrect" action="">
	
	<div>
	<label>
	Well done, your answer is correct! Please, tell us how did you solve the question in order to help your peers that are struggling on it.
	</label>

<<<<<<< HEAD
		<div id="concept">
		<div>
		
		<div>
<!-- 		An icon goes here. 
 -->		
 </div>
		<div> 
=======
		<div id="correct-concept">
>>>>>>> ff096b7c6d4f84698fd95c95daa4154ea31cf75a
			<label>
				1. Please select any concepts that have been difficult for you or select the lines of code that have been confusing or difficult to understand.
			</label>
			<br/>
			<!-- TO DO: Connect these checkboxes to the concepts in the question and highlight the corresponding code -->
			<%
			        String query2 = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"'";      
        rs2 = statement.executeQuery(query2);
        
        while (rs2.next()) {
     	   out.print("<input class='concepts-checkbox line"+rs2.getString("sline")+"' type='checkbox' value='line"+rs2.getString("sline")+"' onclick='checkConcept(this)'><span class="+rs2.getString("sline")+">"+rs2.getString("concept") +"</span><br>");
        }
        %>
        </div>
        </div>
        </div>
        
	<br/>
<<<<<<< HEAD
		<div id="tag">
		<div>
<!-- 		An icon goes here. 
 -->		
 </div>
		<div>
=======
		<div class="tag">
>>>>>>> ff096b7c6d4f84698fd95c95daa4154ea31cf75a
			<label>
				2. How would you describe the problem that you are having with this quiz (choose one or more tags)?
			</label>
			<br/>
			</div>
			</div>
			<div>
			<%
			//The query will be updated once a new table is created in the database.

		String query3 = "SELECT * FROM correct_scenario_tags";      
        rs3 = statement.executeQuery(query3);
        
        while (rs3.next()) {
     	   out.print("<button type='button' class='tag_buttons' id='"+rs3.getString("tagID")+"' onclick='checkTag(this)'>"+rs3.getString("tagName")+"</button><br>");
        }
        %>
   <script language="JavaScript">
        
   function checkTag(button){
		var id=button.id;
		var tempColor=button.style.backgroundColor;
		console.log(button.style);
		console.log(tempColor);
		if(tempColor!='rgb(255, 179, 179)'){
			document.getElementById(id).setAttribute("style", "background-color: #ffb3b3");

			}else{
			document.getElementById(id).setAttribute("style", "background-color: none");

			}
	}
        </script>
        </div>
	<br/>
<<<<<<< HEAD
	<div>
		<div id="comment">
=======
		<div class="comment">
>>>>>>> ff096b7c6d4f84698fd95c95daa4154ea31cf75a
			<label>
               3. Please, leave a comment that could guide or help to your classmates that are trying to solve this problem
			</label>
			<br/>
			<textarea name="commentCorrect" rows="5" placeholder="Comment here on what is difficult or confusing about the question."></textarea>
		</div>
		
		<div class="submit">
			<button type="submit">Submit Feedback</button>
		</div>
		</div>
		</div>
		
	</form>
</body>
</html>