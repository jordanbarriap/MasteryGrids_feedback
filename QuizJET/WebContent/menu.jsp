<%@ page language="java" %>
<%@ page import="java.sql.*" %>	
<%@ page import="java.util.Random" %>
<head>
<link href="quizjet.css" rel="stylesheet" type="text/css">
<link href="complete.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
<!--
function switchMenu(obj) {
	var el = document.getElementById(obj);
	if ( el.style.display != "none" ) {
		el.style.display = 'none';
	}
	else {
		el.style.display = '';
	}
}


//-->

</script>
</head>

<body bgcolor="#ffffff" onLoad="pageLoad()">

<%	      
	  String appID = getServletContext().getInitParameter("appID");
	  String domain = getServletContext().getInitParameter("language");
	  String appName = getServletContext().getInitParameter("appName");
      String act = request.getParameter("act");   
      String sub = request.getParameter("sub");   
      %><table><tr><td class="navigation_aid"><%
      if (act!=null && sub!=null){
      	out.println("<p>"+act+">>"+sub+"</p>");
      }
      %></td></tr></table><%
      
	 Connection connection = null;
	 Class.forName(getServletContext().getInitParameter("db.driver"));
	 connection = DriverManager.getConnection(getServletContext().getInitParameter("db.url"),
	      		 							  getServletContext().getInitParameter("db.user"),
	      		 							  getServletContext().getInitParameter("db.passwd"));
	 Statement statement = connection.createStatement();  
	
	    //generate session ID 2008.01.09
	 String[] letters= {"A","B","C","D","E","0","1","2","3","4","5","6","7","8","9"};
	 Random randomNumberSession = new Random(); // random number generator	
	 String SessionLetters = letters[randomNumberSession.nextInt(15)]+letters[randomNumberSession.nextInt(15)]+letters[randomNumberSession.nextInt(15)]+letters[randomNumberSession.nextInt(15)]+letters[randomNumberSession.nextInt(15)]+letters[randomNumberSession.nextInt(15)];       	       
	 //System.out.print("session letters:"+SessionLetters );	
	 
	 ResultSet rs1 = null;  	 	 
	 String QID[];
	 String QTitle[];
	 String QCnt[];
	 QID= new String[30];
	 QTitle= new String[30];
	 QCnt= new String[30];
	 int cnt=0;
	 // Get each topic's ID, title, and #contents
	 String query = "select r.QuestionID, q.Title, count(*) FROM ent_jquiz z, rel_question_quiz r, ent_jquestion q where q.Privacy='1' and z.Privacy='1' and z.QuizID=r.QuizID and q.QuestionID=r.QuestionID " + "and q.domain='" + domain + "'" + " group by r.QuestionID ";
	 rs1 = statement.executeQuery(query); //group by topic	 	  	 		 	
/* 	 System.out.println("Creating menu from webex21: " + query);
 */	 while(rs1.next()){
	 	QID[cnt]=rs1.getString(1);
	 	QTitle[cnt]=rs1.getString(2);
	 	QCnt[cnt]=rs1.getString(3);
	 	cnt++;
	 }
		
	//int outcnt=1;  //for quiz1, quiz2...
	//int incnt=0;  //over 5 items, jump to quiz2
	%>
	
<div id="s1">
<form>
<ul>

<%
  	String displayQuizServlet = "displayQuiz.jsp";//getServletContext().getInitParameter("displayQuizServlet");
  	String usr = getServletContext().getInitParameter("usr");
  	String grp = getServletContext().getInitParameter("grp");
  	for(int a=0; a<cnt; a++){         		
	 	ResultSet rs3 = null;  	 
	 	//Choose contents for each topic; 
		String sql3 = "SELECT distinct z.QuizID,z.Title as ContentTitle,z.rdfID,q.Title as TopicTitle,z.QuesType FROM ent_jquiz z,rel_question_quiz r,ent_jquestion q where z.Privacy='1' and z.QuizID=r.QuizID and q.QuestionID=r.QuestionID and r.QuestionID='"+QID[a]+"' "; 	 	  	 		
		rs3 = statement.executeQuery(sql3);
		//System.out.println("rs3.getString(\"TopicTitle\"):" + rs3.getString("TopicTitle"));
		//System.out.println("rs3.getString(\"ContentTitle\"):" + rs3.getString("ContentTitle"));
		//<%=request.getContextPath()

%>
	
<li><a onclick="switchMenu('<%=QTitle[a]%>');"><%=QTitle[a]%></a></li><ul>
<div id="<%=QTitle[a]%>">			
<% 	while(rs3.next()){
%>			
<li><a class="navigation_aid" href="<%=displayQuizServlet%>?rdfID=<%=rs3.getString("rdfID")%>&app=<%=appID%>&act=<%=rs3.getString("TopicTitle")%>&sub=<%=rs3.getString("ContentTitle")%>&usr=<%=usr%>&grp=<%=grp%>&sid=<%=SessionLetters%>&svc=<%=appName%>&ums=''"  target="mainFrame"><%=rs3.getString(2)%></a></li>			
<%			
		session.setAttribute("quizid",rs3.getString(1));
		out.println("<input type=hidden name=act value="+rs3.getString("TopicTitle")+">");
		out.println("<input type=hidden name=QuesType value="+rs3.getInt("QuesType")+">");
		out.println("<input type=hidden name=sid value="+SessionLetters+">");			
	}				
%>
			
			</div>
			</ul></form><%		
	 		}       
%>

</ul>
</div>			
</body>



