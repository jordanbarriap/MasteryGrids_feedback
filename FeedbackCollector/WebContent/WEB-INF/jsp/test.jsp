 <%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% response.setHeader("Access-Control-Allow-Origin", "*"); %>
<%@ page language="java"%>
<%@ page import="java.sql.*" %>    
<%@ page import="java.io.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<% 
	String rdfID=request.getParameter("rdfID");
	Connection connection = null;
	connection = DriverManager.getConnection(getServletContext().getInitParameter("db.url"),
				  getServletContext().getInitParameter("db.user"),
				  getServletContext().getInitParameter("db.passwd"));
	Statement statement = connection.createStatement(); 
	ResultSet rs1 = null;
	ResultSet rs2 = null;
	int quizID=0;
	String query1 = "select QuizID from ent_jquiz where rdfID = '"+rdfID+"'";      
	rs1 = statement.executeQuery(query1);
	  
	while (rs1.next()) {
	    quizID = rs1.getInt("QuizID");
	} 
%>

	<form name="feedbackBefore" action="">
		<div id="concept">
		<div>
		<div>
<!-- 		An icon goes here.
 -->		
 </div>
		<div>
			<label>
				In this quiz, you will practice the following concepts. Please check
				any concepts to see the corresponding lines of codes.
			</label>
			</div>
			<br/>
			</div>
			<div>
			<!-- TO DO: Connect these checkboxes to the concepts in the question and highlight the corresponding code -->
			<%
			        String query2 = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"'";      
        rs2 = statement.executeQuery(query2);
        
        while (rs2.next()) {
     	   out.print("<input class='concepts-checkbox line"+rs2.getString("sline")+"' type='checkbox' value='line"+rs2.getString("sline")+"' onclick='checkConcept(this)'><span id="+rs2.getString("sline")+">"+rs2.getString("concept") +"</span><br>");
        }
        %>
        </div>
        </div>
		<div id="before-concept">
			<div id="before-concept">
                    <div class="icon">
                        <img src="pen.png" id="pen-icon"/>
                    </div>
                    <div class="text">
                        <h3>In this quiz, you will practice the following concepts: </h3>
                        <p>Please select any concepts or click on lines of codes that are difficult or confusing.</p>	
                    </div>    
                </div>

                <!-- TO DO: Connect these checkboxes to the concepts in the question and highlight the corresponding code -->
                <div class="problem-concepts">
                    <input type="checkbox" name="concept" id="concept1" value="Array"> Array
                    <input type="checkbox" name="concept" id="concept2" value="While Loop"> While Loop
                    <input type="checkbox" name="concept" id="concept3" value="Variables"> Variables
                </div>
	</form>