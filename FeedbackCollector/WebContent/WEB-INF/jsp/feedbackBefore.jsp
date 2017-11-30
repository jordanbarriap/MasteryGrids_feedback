<%--
Feedback Before
This is the page that will display feedback before answering a question.
By: Erin Price
Created: Nov 25, 2017
Updated: Nov 26, 2017
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
		<div id="concept">
			<label>
				In this quiz, you will practice the following concepts. Please select
				any concepts or click on lines of codes that are difficult or
				confusing.
			</label>
			<br/>
			<!-- TO DO: Connect these checkboxes to the concepts in the question and highlight the corresponding code -->
			<input type="checkbox" name="concept" id="concept1" value="Array"> Array
			<input type="checkbox" name="concept" id="concept2" value="While Loop"> While Loop
			<input type="checkbox" name="concept" id="concept3" value="Variables"> Variables
	</form>
</body>
</html>
