<%--
Feedback Incorrect
This is the page that will display feedback after answering a question incorrectly.
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
<title>Feedback: Incorrect</title>
</head>

<body>

	<!-- TO DO: Submit the form and store in the db -->
	<form name="feedbackIncorrect" action="">

		<div id="incorrect-concept">
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
		</div>
	<br/>
		<div class="tag">
			<label>
				How do you feel about this question?
			</label>
			<br/>
			<!-- TO DO: Connect these tags to the database instead of this manual list -->
			<!-- TO DO: Add actions to these buttons -->
			<button type="button" name="tagIncorrect1">Too Difficult</button>
			<button type="button" name="tagIncorrect2">Need to Ask Professor</button><br/>
			<button type="button" name="tagIncorrect3">Did Not Learn in Class</button>
			<button type="button" name="tagIncorrect4">Not Clear</button><br/>
			<button type="button" name="tagIncorrect5">Time-Consuming</button>
		</div>
	<br/>
		<div class="comment">
			<label>
			Comment on this question and what is difficult:
			</label>
			<br/>
			<textarea name="incorrectcomment" rows="5" placeholder="Comment here on what is difficult or confusing about the question"></textarea>
		</div>
		
		<div class="submit">
			<button type="submit">Submit Feedback</button>
		</div>
		
	</form>
</body>
</html>