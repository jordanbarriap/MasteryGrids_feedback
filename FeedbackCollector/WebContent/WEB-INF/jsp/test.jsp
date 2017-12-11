 <%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<style type="text/css">
  <%@include file="feedback.css" %>
</style>
<% response.setHeader("Access-Control-Allow-Origin", "*"); %>
<%@ page language="java"%>
<%@ page import="java.sql.*" %>    
<%@ page import="java.io.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Arrays"%>

<% 
	HashMap<String, ArrayList<String>> conceptMap = new HashMap<String, ArrayList<String>>();

	String rdfID=request.getParameter("rdfID");
	String topicName = request.getParameter("topicName");
	String courseID = request.getParameter("courseID");
	
	Connection connection = null;
    Class.forName(getServletContext().getInitParameter("db.driver"));
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
	}
	
	String queryTopic = "SELECT topic_id FROM aggregate.ent_topic WHERE course_id='"+courseID+"' and topic_name='"+topicName+"'";   
	int topicID = 0;
	
	rs3 = statement.executeQuery(queryTopic);
	  
	while (rs3.next()) {
	    topicID = rs3.getInt("topic_id");
	    
	}
	//out.print("topic id "+topicID);
	
%>

<div id="before-feedback">
<div id="before-explanation">
<!-- 		An icon goes here.
 -->		
	<label>
		In this quiz, you will practice the following concepts. Please check
		any concepts to see the corresponding lines of codes.
	</label>
</div>
<br/>
<div id="before-concepts">
			<!-- TO DO: Connect these checkboxes to the concepts in the question and highlight the corresponding code -->
<%
		String query2 = "SELECT * FROM webex21.rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"' and r.concept not in (SELECT D.concept FROM aggregate.ent_topic as A inner join aggregate.rel_topic_content as B on A.topic_id = B.topic_id inner join aggregate.ent_content as C on B.content_id = C.content_id inner join webex21.ent_jquiz_concept as D on C.content_name = D.title where C.content_type ='question' and A.course_id = '"+courseID+"' and A.topic_id < '"+topicID+"')";
		//String query2 = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"'";      
        
		rs2 = statement.executeQuery(query2);
        
        ArrayList<String> conceptsInAppearanceOrder = new ArrayList<String>();
        
        while (rs2.next()) {
           String concept = rs2.getString("concept");
           String line = rs2.getString("sline");
           System.out.println(concept);
           System.out.println(line);
           if(!conceptMap.containsKey(concept)){
        	   conceptsInAppearanceOrder.add(concept);
        	   ArrayList<String> linesList = new ArrayList<String>();
        	   linesList.add(line);
        	   conceptMap.put(concept, linesList);
           }else{
        	   ArrayList<String> currentLinesList = conceptMap.get(concept);
        	   currentLinesList.add(line);
        	   conceptMap.put(concept, currentLinesList);
           } 
        }
        for(String concept: conceptsInAppearanceOrder){
        	ArrayList<String> lineList = conceptMap.get(concept);
        	System.out.println(concept);
        	System.out.println(Arrays.toString(lineList.toArray()));
        	String lineClasses = "";
        	for (int i=0; i<lineList.size(); i++){
        		lineClasses = lineClasses + "line"+ lineList.get(i) + " ";
        	}
        	//out.print("<input class='concepts-checkbox "+lineClasses+"' type='checkbox' value='"+lineClasses+"' onclick='checkConcept(this)'><span id="+concept+">"+concept+"</span>");
        	out.print("<div class='concept-tag'><span id="+concept+" class='concept "+lineClasses+"'onmouseover='selectConcept(this)'>"+concept+"&emsp;</span><span class='glyphicon glyphicon-question-sign'></span><span onclick='changeColor(this)' class='glyphicon glyphicon-ok-sign glyph-check'></span></div>");
        }
        %>
</div>
<div class='buttons'>
   <button class='btn' id='more-feedback' onclick='switchFeedback()'>Share More</button>
   <button class='btn' id='submit-btn' type="submit">Submit</button>
   <p id='encouragement'>
     <strong>Send your feedback and see a hint!</strong>
   </p>
   <br/>

   <!–– Connect this link to the before feedback page -->
   <!–– For this demo only clicking this link advances screens, due to JSFiddle button wackiness -->
   <a href='#' onclick='switchFeedback()'>Back to Concepts</a>
 </div>
</div>
<div id="correct-feedback">
<div id="correct-explanation">
<!-- 		An icon goes here.
 -->		
	<label>
		In this quiz, you will practice the following concepts. Please check
		any concepts to see the corresponding lines of codes.
	</label>
</div>
<br/>
<div id="correct-concepts">
<%
	  String query = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"'";      
   	  rs2 = statement.executeQuery(query2);
      
      while (rs2.next()) {
   	   out.print("<input class='concepts-checkbox line"+rs2.getString("sline")+"' type='checkbox' value='line"+rs2.getString("sline")+"' onclick='checkConcept(this)'><span class="+rs2.getString("sline")+">"+rs2.getString("concept") +"</span>");
      }
%>
</div>
</div>
<div id="wrong-feedback">
 <!–– Feedback HEADING Section -->
	<div id='incorrect-heading'>
	  <img id='information-icon'>
	
	  <div class="heading-text">
	    <h3>
	        Need Help?	
	    </h3>
	    <h4>
	      Share your thoughts on this problem to <span class='highlight'>get a hint</span>
	    </h4>
	  </div>
	
	</div>
<br/>
<div id="wrong-concepts">
<%
for(String concept: conceptsInAppearanceOrder){
	ArrayList<String> lineList = conceptMap.get(concept);
	System.out.println(concept);
	System.out.println(Arrays.toString(lineList.toArray()));
	String lineClasses = "";
	for (int i=0; i<lineList.size(); i++){
		lineClasses = lineClasses + "line"+ lineList.get(i) + " ";
	}
	//out.print("<input class='concepts-checkbox "+lineClasses+"' type='checkbox' value='"+lineClasses+"' onclick='checkConcept(this)'><span id="+concept+">"+concept+"</span>");
	out.print("<div class='concept-tag'><input type='checkbox'><span id="+concept+" class='concept "+lineClasses+"'onmouseover='selectConcept(this)'>"+concept+"</span></div>");
}
%>
</div>
</div>
<script>
// addEventListener support for IE8
   function bindEvent(element, eventName, eventHandler) {
       if (element.addEventListener){
           element.addEventListener(eventName, eventHandler, false);
       } else if (element.attachEvent) {
           element.attachEvent('on' + eventName, eventHandler);
       }
   }
   // Send a message to the child iframe
   var iframeEl = document.getElementById('act-frame');
       /*messageButton = document.getElementById('message_button'),
       results = document.getElementById('results');*/
   console.log(iframeEl);
       
   // Send a message to the child iframe
   var sendMessage = function(msg) {
       // Make sure you are sending a string, and to stringify JSON
       iframeEl.contentWindow.postMessage(msg, '*');
   };
   
   // Listen to message from child window
   bindEvent(window, 'message', function (e) {
   	var message = e.data;
    if(message == "wrong"){
    	$("#before-feedback").hide( "slide", { direction: "left" }, "slow", function(){
    		$("#wrong-feedback").show( "slide", { direction: "right" }, "slow" );
    	});
    }
    if(message == "correct"){
    	$("#before-feedback").hide( "slide", { direction: "left" }, "slow", function(){
    		$("#correct-feedback").show( "slide", { direction: "right" }, "slow" );
    	});
    	
    }
   	//results.innerHTML = e.data;
   });
   
function selectConcept(checkbox){
	var lines = checkbox.className.trim();
	var linesArray = lines.split(" ");
	sendMessage(lines);
	/* for (var i= 1; i<linesArray.length; i++){
		$("#act-frame").contents().find(".line."+linesArray[i]).addClass("selected-line");
	} */
	/*if(checkbox.checked){
		document.getElementById(line).setAttribute("style", "background-color: #ffb3b3");
		console.log(document.getElementsByClassName("line-checkbox "+line)[0]);
		document.getElementsByClassName("line-checkbox "+line)[0].checked=true;
	}else{
		document.getElementById(line).setAttribute("style", "background-color: none");
		document.getElementsByClassName("line-checkbox "+line)[0].checked=false;
	}*/
}
</script>