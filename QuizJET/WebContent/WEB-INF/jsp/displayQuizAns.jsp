<%@ page language="java" %>
<%@ page import="java.sql.*" %>	
<%@ page import="java.io.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.util.Enumeration"%>


<?xml version="1.0" encoding="utf8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>QuizJET</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf8" />

<link href="quizjet.css" rel="stylesheet" type="text/css" />
<link href="tab.css" rel="stylesheet" type="text/css" />
<SCRIPT type="text/javascript">

/* 
 if (top.vis) {
	  var A = document.location.search.substr(1).split("&");
	  for (var i = 0; i < A.length; i++) {
	    var B = A[i].split("=");
	    if (B[0] === "res") top.vis.actDone(parseInt(B[1]));
	  }
	}
 
 if (top.vis) {
	var A = document.location.search.split("&");
	for (var i = 0; i <= A.length; i++) {
		var B = A[i].split("=");
		if (B[0] === "res") top.vis.actDone(parseInt(B[1]));
	}
} */
</SCRIPT>
<SCRIPT type="text/javascript" src="tab.js"></SCRIPT>

</head>
<!-- WebFX Layout Include -->
<script type="text/javascript">

var articleMenu= new WebFXMenu;
articleMenu.left  = 384;
articleMenu.top   = 86;
articleMenu.width = 140;
articleMenu.add(new WebFXMenuItem("Driver Class", "javascript:showArticleTab( \"main\" )"));
articleMenu.add(new WebFXMenuItem("Supplemental Class", "javascript:showArticleTab( \"usage\" )"));

webfxMenuBar.add(new WebFXMenuButton("Article Menu", null, null, articleMenu));

</script>



<div class="webfx-main-body">
<!-- end WebFX Layout Includes -->

<!-- begin tab pane -->
<div class="tab-pane" id="article-tab">

<script type="text/javascript">
tabPane = new WebFXTabPane( document.getElementById( "article-tab" ), true );

//@@Jordan
// addEventListener support for IE8
function bindEvent(element, eventName, eventHandler) {
    if (element.addEventListener) {
        element.addEventListener(eventName, eventHandler, false);
    } else if (element.attachEvent) {
        element.attachEvent('on' + eventName, eventHandler);
    }
}
// Send a message to the parent
var sendMessage = function (msg) {
    // Make sure you are sending a string, and to stringify JSON
    window.parent.postMessage(msg, '*');
};
/*var results = document.getElementById('results'),
    messageButton = document.getElementById('message_button');*/
// Listen to messages from parent window
bindEvent(window, 'message', function (e) {
    //results.innerHTML = e.data;
    console.log(e.data);
});
// Send random message data on every button click
/*bindEvent(messageButton, 'click', function (e) {
    var random = Math.random();
    sendMessage('' + random);
});*/
//@@Jordan

</script>

<%	    
		//TODO: use configuration; why it doesn't throw exception using wrong user name and password?
		String appDir = getServletContext().getInitParameter("appDir");
		String appID = getServletContext().getInitParameter("appID");        
		String language = getServletContext().getInitParameter("language");
		boolean windows = getServletContext().getInitParameter("windows").equals("true") ? true : false;
		boolean verbose  = getServletContext().getInitParameter("verbose").equals("true") ? true : false;
		Connection connection = null;
		Class.forName(getServletContext().getInitParameter("db.driver"));
		connection = DriverManager.getConnection(getServletContext().getInitParameter("db.url"),
				 								  getServletContext().getInitParameter("db.user"),
				 								  getServletContext().getInitParameter("db.passwd"));
		Statement statement = connection.createStatement();  
		
		String dirDelim = windows ? "\\\\" : "//";
		String fileSurfix = "." + language;
		String extraClassDir = appDir + "class" + dirDelim;//appDir + 
		String curActionDir = "";
         
         //hy
         if (verbose){
             System.out.println("\n******** In the jsp displaying quizes answers ******");
              Enumeration<String> en = request.getParameterNames();
              for (; en.hasMoreElements();) {
                  String name = (String) en.nextElement();
                  System.out.print(name);
                  String[] values = request.getParameterValues(name);
                  for (int i = 0; i < values.length; i++) {
                      System.out.print("=" + values[i] + ",  ");
                  }
              }
              System.out.println("");
         }

    ResultSet rs = null;
    ResultSet rs1 = null;
    ResultSet rs2 = null;
    ResultSet rs3 = null;
    Blob codeBlob = null;
    int min=0;
    int max=0;  
    int anstype=0;  
    int quesType=0; 
    int quizID=0;    	
    
    //  @@ BEGIN Yun and Julio 10/2016
    String svcParam = request.getParameter("svc");
    boolean tryAgain = true;
    boolean showFeedback = true;
    if(svcParam != null && svcParam.contains("[notryagain]")) tryAgain=false;
    if(svcParam != null && svcParam.contains("[nofeedback]")) showFeedback=false;
    if(svcParam != null && svcParam.contains("pretest")) {
    	showFeedback=false;
    	tryAgain=false;
    }
    //  @@ END Yun and Julio 10/2016
    
    // for 11/2016 Yun comb study :
    boolean showRecRankInstructionMessage = (svcParam.contains("oriproblem")? true:false);
        
    // for recognizing which type of question (1=class)
    int flag=0;
    String replace = request.getParameter("replace");
    if (replace == null)
    	replace = "___";//This is for replacing newline symbols, since we are passing it by URL. should always be the same symbol repeated three times, if changes, should change in the display_quiz_ans.jsp, too. 
    if (verbose)
        System.out.println("replace: " + replace); 
    char replaceChar = replace.charAt(0);
    if (verbose)
        System.out.println("replaceChar: " + replaceChar); 
    
    String rdfID = request.getParameter("rdfID");    
    String query = "select QuizID,Code,MinVar,MaxVar,AnsType,QuesType from ent_jquiz where  rdfID = '"+rdfID+"'";      
    rs = statement.executeQuery(query);
      
      while (rs.next()) {
        codeBlob = rs.getBlob("Code");        
        min = rs.getInt("MinVar");
        max = rs.getInt("MaxVar");        
        anstype = rs.getInt("AnsType");  
        quesType =  rs.getInt("QuesType");
        quizID = rs.getInt("QuizID");
      }
      
      //Random randomNumbers = new Random(); // random number generator
      //int P = min + randomNumbers.nextInt( max );     
      //int P = Integer.parseInt(request.getParameter("P"));
      //20100304
      String P = request.getParameter("P");
      
      //int position=0;
      //String codepart="";
      //String fileName_short = "";
	
      //check multiple classes, get class name
      String sql = "select * from rel_quiz_class where QuizID = '"+quizID+"' ";      
      int ClassID=0;
	    rs1 = statement.executeQuery(sql);     
		while (rs1.next()) {      
			ClassID=rs1.getInt("ClassID");
			flag=1;
      		}
      		
	    String sql2 = "select * from ent_class c, rel_quiz_class r where c.ClassID = r.ClassID and r.QuizID= '"+quizID+"' ";      
	    ArrayList<String> fileName = new ArrayList<String>();
	    rs2 = statement.executeQuery(sql2);  
		 while (rs2.next()) {  
		 	fileName.add(rs2.getString("ClassName"));				 	
		 }  	    	 		
		 //check multiple classes end
     
      
%>      
<!-- begin intro page -->
<div class="tab-page" id="intro-page">   
<h2 class="tab">Tester.py</h2>
<script type="text/javascript">
tabPane.addTabPage( document.getElementById( "intro-page" ) );
</script>    
<pre><%
		
		byte[] codeByte = codeBlob.getBytes(1, (int) codeBlob.length());
		String codeStr = new String(codeByte);
		//System.out.println("Before:\n" + codeStr);
		codeStr = codeStr.replace("\r\n", "\n").replace("\r", "\n").replace("\n\n\n", "\n\n");
		codeStr = codeStr.replace("_Param", P).replace("<", "&lt;");
		if (!codeStr.endsWith("\n"))
			codeStr += "\n";
		//System.out.println("After:\n" + codeStr);
		/* InputStream in = codeBlob.getBinaryStream();
		int length = (int) codeBlob.length();
		
		int bufferSize = 1024;
		byte[] buffer = new byte[bufferSize];    

	      while ((length = in.read(buffer)) != -1) {	
	      	StringBuffer textBf = new StringBuffer(new String(buffer));
	        String text = new String(textBf);
	        text = text.replace("\r\n", "\n").replace("\r", "\n").replace("\n\n", "\n");
	        int loc = text.indexOf('\n',position); 
	        if (verbose)
	        	System.out.println("displayQuizAns.jsp Code:\n" + text);
	        int linecount = 0;       		              	
	        while(loc >= 0){       	        		                    
		            loc = (new String(text)).indexOf('\n',position);		            
		            String line = "";
		            if (loc>position){	   
		            	line = text.substring(position,loc);
		            	if (language.equals("py"))
	                	   line += "\n";
				int  b = line.indexOf("_Param");
				int  b2 = line.lastIndexOf("_Param");
				if (b>0 && b==b2){				
					line= line.substring(0,b) + P + line.substring(b+6);					
					}					
				else if(b>0 && b2>b){
					line= line.substring(0,b) + P + line.substring(b+6,b2) + P +line.substring(b2+6);
				}					
														
				linecount = linecount + 1;
				//for Question Type 3
				if (QuesType==3){
					out.print("<font color=blue><b>"+linecount+"</b></font>	");
					out.println("<span style=background-color:#DDDDDD>"+line+"</span><br>");
				}else {
					codepart+=line;	
					//2008.09 fix ArrayList<TYPE>
					char[] chars = line.toCharArray();
					StringBuffer buffer1 = new StringBuffer(chars.length);	
					for (int index = 0; index < chars.length; index++) {
					      	char ch1 = chars[index];	      	
					      	if (ch1 == '<')
					      	{   buffer1.append("&lt;");
					      	}else{
		        			    buffer1.append(ch1);
		        			}				 	      
				        }
				        line = buffer1.toString();				
		            		out.print(line); //print each line of the program question
		            	}
		            	//codepart+=line;		            	
		            }
		            
		            position=loc+1;	            
	         }         */
	         
      	  //out.println(codeStr + "");
        String[] lines = codeStr.split("\n");
         String checkboxLines = "";
         for(int i=0;i<lines.length-1;i++){
      	   if(!lines[i].replace(" ", "").equals(""))
      	   {
      	   out.print( checkboxLines+"<input class='line-checkbox line line"+i+"' type='checkbox' value='line"+i+"' onclick='checkLine(this)'><span id='line"+i+"'>"+lines[i]+"</span><br>");
      		//out.print( checkboxLines+"<span id='line"+i+"'>"+lines[i]+"</span><br>");
         }
      	   else
      	   {
          	   out.print(  "<span id='line"+i+"'>"+lines[i]+"</span><br>");
      	   }
         }

	      //2008.04.10 replace space&break line into symbols
	      String userAns = "";   				 
	      String replacedUserAns ="";
	      String correctAns = "";
	      String replacedCorrectAns = "";

	      if(request.getParameter("ans")!=null){
	     	userAns = request.getParameter("ans");
	     	if (verbose)
	             System.out.println("request.getParameter(ans): userAns's length: " + userAns.length() + ", userAns:\n" + userAns + "//");
	      }
	     
	      char[] chars = userAns.toCharArray();
	      StringBuffer buffer_ans = new StringBuffer(chars.length);	 
 	      for (int index = 0; index < chars.length; index++) {
		      	char ch = chars[index];	      	
		      	if (ch == ' '){
		      		buffer_ans.append("<font color=\"#aaaaaa\">&#8226;</font>"); 
		      	}	 
		      	else if(ch==replaceChar && index <= (chars.length-3) && chars[index+1] == replaceChar && chars[index+2] == replaceChar ){
		        	buffer_ans.append("<font color=\"#aaaaaa\">&#182;</font><br />");
		        	index = index + 2;
 		        } 
		        else{
		        	buffer_ans.append(ch);
		        }	      
	      } 
	      replacedUserAns = buffer_ans.toString();
	      
	      if(request.getParameter("c")!=null){
	     	correctAns = request.getParameter("c");
	     	if (verbose)
                System.out.println("request.getParameter(c): correctAns's length " + correctAns.length() + ", correctAns\n" + correctAns +"//");
	      }

	      char[] chars1 = correctAns.toCharArray();
	      StringBuffer buffer1 = new StringBuffer(chars1.length);
	       for (int index = 0; index < chars1.length; index++) {
		      	char ch1 = chars1[index];	      	
		      	if (ch1 == ' '){
		      	  buffer1.append("<font color=\"#aaaaaa\">&#8226;</font>");
		      	}
		        else if(ch1==replaceChar && index <= (chars1.length-3) && chars1[index+1] == replaceChar && chars1[index+2] == replaceChar ){
		        	buffer1.append("<font color=\"#aaaaaa\">&#182;</font><br />");
		        	index = index + 2;
 		        }
		        else{
		        	buffer1.append(ch1);
		        }	      
	      }
	      replacedCorrectAns = buffer1.toString(); 
	     if (quesType == 1)
	     	out.println("<font color=blue>What is the final value of <b>result</b>?</font><br>");
	     else if (quesType == 2)
	     	out.println("<font color=blue>What is the output?</font><br><font color=grey size=0.25>Be careful of the space/newline in your answer.</font><br>");
	     else if (quesType == 3)
		    out.println("Which line is wrong?<br>");
	     
		String tryAgainDisableMessage = "Don't click 'Try Again' before the left side panel appears.";
	     out.print("<table><tr><td class=\"tab-page\" style=\"vertical-align:top;\"><div  id=\"answer-pane\" style=\"white-space: normal;\">");
	     out.print("<form method=post>");	          	     	     
	     if(quesType==1){
	     	if(showFeedback) {
	     		if(request.getParameter("res").equals("1")){
	     			out.println("<font size=4 color=blue><b>CORRECT!</b></font><br><br>");
	     			%>
					<script> 
		     			console.log("Correct");
		     			sendMessage("correct");
	     			</script>
	     			<%
	     		}else{
		     		out.println("<font size=4 color=red><b>WRONG!</b></font><br><br>");
		     		%>
		     		<script>
			     		console.log("Wrong");
		     			sendMessage("wrong");
	     			</script>
	     			<%
	     		}
		     	out.println("<b>Your Answer: </b><br>"+request.getParameter("ans")+"<br>");
	     		out.println("<b>Correct Answer: </b><br>"+request.getParameter("c")+"<br>");
	     	}else{
	     		out.println("<b>Your Answer: </b><br>"+request.getParameter("ans")+"<br>");
	     	}
	        if(tryAgain) {
	     		if(showRecRankInstructionMessage)
	     			out.println("<br><font color=grey size=2>" + tryAgainDisableMessage + "</font><br>");
	     		out.println("<br><input type=submit value=\"Try Again\" onclick=submitFunction(this.form,1)>");
	     	}
	     	
	     /* if(request.getParameter("res").equals("1")){//if(session.getAttribute("res").equals("1")){
	     		out.println("<font size=4 color=blue><b>CORRECT!</b></font><br>");
	     	}else{
	     		out.println("<font size=4 color=red><b>WRONG!</b></font><br>");
	     	}
	     	out.println("<b>Your Answer is: </b><br>"+request.getParameter("ans")+"<br>");
	     	out.println("<b>Correct Answer is: </b><br>"+request.getParameter("c")+"<br>");
	     	out.println("<input type=submit value=\"Try Again\" onclick=submitFunction(this.form,1)>");// + "," + displayQuizServlet + ")>");
		 */
	     	}else if (quesType==2){ 	        
	        if(showFeedback) {
	     		if(request.getParameter("res").equals("1")){
	     			out.println("<font size=4 color=blue><b>CORRECT!</b></font><br><br>");
	     			%> 
	     			<script> 
		     			console.log("Correct");
		     			sendMessage("correct");
	     			</script>
	     			<% 
	     		}else{
	     			out.println("<font size=4 color=red><b>WRONG!</b></font><br><br>");
	     			%> 
					<script>
			     		console.log("Wrong");
		     			sendMessage("wrong");
	     			</script>
	     			<%
	     		}
	     		out.println("<b>Your Answer: </b><br>"+replacedUserAns+"<br>");
        		out.println("<b>Correct Answer: </b><br>"+replacedCorrectAns+"<br>");			     		
	     	}else{
	     		out.println("<b>Your Answer: </b><br>"+replacedUserAns+"<br>");
	     	}
	        if(tryAgain) {
	     		if(showRecRankInstructionMessage)
	     			out.println("<br><font color=grey size=2>" + tryAgainDisableMessage + "</font><br>");
	     		out.println("<br><input type=submit value=\"Try Again\" onclick=submitFunction(this.form,1)>");
	     	}
	        
	        /* if(request.getParameter("res").equals("1")){//if(session.getAttribute("res").equals("1")){
	     		out.println("<font size=4 color=blue><b>CORRECT!</b></font><br>");
	  	        out.println("<b>Your Answer is: </b><br>"+replacedCorrectAns+"<br>");//replacedUserAns
	        	out.println("<b>Correct Answer is: </b><br>"+replacedCorrectAns+"<br>");	
	     	}else{
	     		out.println("<font size=4 color=red><b>WRONG!</b></font><br>");
	       		out.println("<b>Your Answer is: </b><br>"+replacedUserAns+"<br>");
	        	out.println("<b>Correct Answer is: </b><br>"+replacedCorrectAns+"<br>");			     		
	     	}	        		                
	        out.println("<input type=submit value=\"Try Again\"  onclick=submitFunction(this.form,1)>"); */// + "," + displayQuizServlet + ")>");
		}
		else if (quesType==3){
	        out.println("Your Answer is:"+request.getParameter("ans")+"<br>");
	        if(tryAgain) {
	     		if(showRecRankInstructionMessage)
	     			out.println("<br><font color=grey size=2>" + tryAgainDisableMessage + "</font><br>");
	     		out.println("<br><input type=submit value=\"Try Again\" onclick=submitFunction(this.form,1)>");
	     	}
/* 			out.println("<input type=submit value=\"Try Again\"  onclick=submitFunction(this.form,1)>");// + "," + displayQuizServlet + ")>");
 */
		}
		
	     //for UM
	     out.print("<input type=hidden name=app value='"+request.getParameter("app")+"'>");
	     out.print("<input type=hidden name=act value='"+request.getParameter("act")+"'>");
	     out.print("<input type=hidden name=sub value='"+request.getParameter("sub")+"'>");
	     out.print("<input type=hidden name=sid value='"+request.getParameter("sid")+"'>");		     
	     out.print("<input type=hidden name=grp value='"+request.getParameter("grp")+"'>");
	     out.print("<input type=hidden name=usr value='"+request.getParameter("usr")+"'>");
	     out.print("<input type=hidden name=svc value='"+request.getParameter("svc")+"'>");				     		     			     
	     out.print("</form>");
         out.print("</div></td>");
         if(showRecRankInstructionMessage){
/*         	 out.print("<td style=\"width:3px;\" >&nbsp</td>");
 */        	 out.print("<td id=\"rankingMessage\" class=\"tab-page\" style=\"vertical-align:top;\" >");
        	 out.print("<div style=\"width: 300px; white-space: normal;vertical-align:top;\">");
//         	 out.print("<h3 style=\"margin-top: 0px;\">Ranking Instruction Message</h3>");
         	 out.print("<span id=\"rankingMessageTitle\">Ranking Instruction Message</span><br />");
 			 out.print("<p>The left panel will display recommended subproblems (sorry that it may take some time to load them). Please:</p>");
 			 out.print("<b>Rank</b> them according to <b>helpfulness for solving original problem</b> (1 for most helpful).");
        	 out.print("<br><br><b>Try to solve subproblems</b> before you rank them and then go back to <b>solve the original problem</b>. You can choose to view them if you already solve original problem.");
             out.print("<br><br><b>Adjust</b> your ranking anytime and <b>confirm your ranking before closing the window</b>.");
         	 out.print("<br><br>Give <b>feedback on each subproblem</b> in the <b>bottom orange panel</b>. Make sure you give the feedback after you finishing trying the subproblem.");
             out.print("<br><br><b>Solve the original problem</b> before you close this window."); 
 	         	 
          /* out.print("<ul>");
             out.print("<li><b>Rank</b> them. Put value 1 to the most <b>helpful one for solving the original problem</b>, which should also be the one you would like to be recommended first. Put value 2 to the 2nd helpful one, etc.</li>");
        	 out.print("<li><b>Try to solve these subproblems</b> before you rank them (if you already solve the original problem, you could also just read these subproblems).</li>");
             out.print("<li><b>Adjust</b> your ranking anytime until it accurately reflects your judgement and <b>confirm your ranking before you close this window</b>.</li>");
             out.print("<li>Try your best to <b>solve this original problem</b> before you close this window and move to the next problem.</li>"); 
         	 out.print("<li>Optionally, give feedback on each subproblem in the bottom panel, which will appear once you click a subproblem.</li>");
         	 out.print("</ul>");
         	 */ 
        	 out.print("</div>");
        	 out.print("</td>");

         }
         out.print("</tr></table>");  
      
%>
</pre>
</div>
<!-- end intro page -->      

<%
if(flag==1){ 
	//2008.04.04
	String RealFileName = "";
	for(int j=0;j<fileName.size();j++){
%>
	<!-- begin usage page -->
	<div class="tab-page" id="usage-page">    
	<%
	if(fileName.get(j).toString().substring(0,1).equals("0")){
     	     		RealFileName = fileName.get(j).toString().substring(2,fileName.get(j).toString().length());        	     		
	%>     	     		
		<h2 class="tab"><%=RealFileName%></h2>
	<%     	}
	else if(fileName.get(j).toString().substring(0,1).equals("1")){
			RealFileName = fileName.get(j).toString().substring(2,fileName.get(j).toString().length()); 
	%>     	     		
		<h2 class="tab"><%=RealFileName%></h2>
	<%
	}else{	%>
		<h2 class="tab"><%=fileName.get(j).toString().substring(0,fileName.get(j).toString().length()-5)%></h2>
	<%}%>

	<pre><%
		    //print out other classes			    			    
				    BufferedReader br1 = new BufferedReader(new FileReader(extraClassDir+fileName.get(j)));
				    String fileLine = "";			    
					    while ((fileLine = br1.readLine()) != null) {
					 	  out.println(fileLine);
					    }				    			  	    	    		    	
		    //print out other classes end
	%>
	</pre>
	</div>
	<!-- end usage tab -->
<%
	}
}
%>

</div>
<!-- end tab pane -->

<!-- end webfx-main-body -->
</div>
      
<%                       			   	
	    	    
    // } 

%> 

<!-- JULIO: remote load of a page that will male the visualization of MG refresh -->
<% 
String result = request.getParameter("res");
String[] multipleRes = request.getParameterValues("res");
if(multipleRes != null && multipleRes.length > 1) result = multipleRes[1];
result = "0";
%>
<iframe style="" width="5" scrolling="no" height="5" frameborder="0" src="http://localhost/um-vis-adl/remote_update.html?action=actDone&param=<%= result%>"></iframe>


 
<script language="JavaScript">
<!-- 
//hy: add "date"
function submitFunction(obj,i){//}, functionName) {
   if (i==1) {obj.action="displayQuiz.jsp?rdfID=<%=request.getParameter("rdfID")%>&sid=<%=request.getParameter("sid")%>&testerSurfix=<%=request.getParameter("testerSurfix")%>&folderSurfix=<%=request.getParameter("folderSurfix")%>&app=<%=request.getParameter("app")%>&sub=<%=request.getParameter("sub")%>&act=<%=request.getParameter("act")%>&usr=<%=request.getParameter("usr")%>&grp=<%=request.getParameter("grp")%>&svc=<%=request.getParameter("svc")%>";}
   obj.submit()
   }
//-->

</script>  


