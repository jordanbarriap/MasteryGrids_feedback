<%--
Feedback Before
This is the page that will display feedback before answering a question.
By: Erin Price
Created: Nov 25, 2017
Updated: Dec 01, 2017
--%>

<%@ page language="java"%>

<!-- TO DO: Create a CSS3 stylesheet -->
<link href="feedback.css" rel="stylesheet" type="text/css" />

<link href="quizjet.css" rel="stylesheet" type="text/css" />
<link href="tab.css" rel="stylesheet" type="text/css" />
<SCRIPT type="text/javascript" src="tab.js"></SCRIPT>

<html>
<head>
<title>Feedback: Before</title>
</head>

<body>

	<form name="feedbackBefore" action="">
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
</body>
</html>