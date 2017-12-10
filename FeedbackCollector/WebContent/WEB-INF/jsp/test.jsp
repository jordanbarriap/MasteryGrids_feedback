 <%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
	Connection connection = null;
    Class.forName(getServletContext().getInitParameter("db.driver"));
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
        	out.print("<span id="+concept+" class='concept "+lineClasses+"'onmouseover='selectConcept(this)'>"+concept+"</span><br>");
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
	<script>
	// Send a message to the child iframe
    var iframeEl = document.getElementById('act-frame'),
        messageButton = document.getElementById('message_button'),
        results = document.getElementById('results');
    console.log(iframeEl);
    // Send a message to the child iframe
    var sendMessage = function(msg) {
        // Make sure you are sending a string, and to stringify JSON
        iframeEl.contentWindow.postMessage(msg, '*');
    };
    // Send random messge data on every button click
    bindEvent(messageButton, 'click', function (e) {
        var random = Math.random();
        sendMessage('' + random);
    });
    // Listen to message from child window
    bindEvent(window, 'message', function (e) {
        results.innerHTML = e.data;
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