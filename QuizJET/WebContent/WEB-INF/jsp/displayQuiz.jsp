<%@ page language="java" %>
<%@ page import="java.sql.*" %>    
<%@ page import="java.io.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Enumeration"%>
<%@ page import="org.apache.commons.io.FileUtils"%>

<link href="quizjet.css" rel="stylesheet" type="text/css" />
<link href="tab.css" rel="stylesheet" type="text/css" />
<SCRIPT type="text/javascript" src="tab.js"></SCRIPT>

<!-- WebFX Layout Include -->
<script type="text/javascript">
//if (top.vis) top.vis.actLoad();

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

<div class="tab-pane" id="concepts-tab">



</div>

<div class="tab-pane" id="article-tab">
<script type="text/javascript">
tabPane = new WebFXTabPane( document.getElementById( "article-tab" ), true );
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
      	
        String dirDelim = windows ? "\\\\" : "/";
        String fileSurfix = "." + language;
        String onlineCompileDir = appDir + "online_compile" + dirDelim;//appDir + 
        String extraClassDir = appDir + "class" + dirDelim;//appDir + 
        String curActionDir = "";
         
         //hy
         if (verbose){
             System.out.println("\n******** In the jsp displaying quizes ******");
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
        // for recognizing which type of question (1=class)
        int flag=0;
        String usr = request.getParameter("usr");
        String SID = request.getParameter("sid");
        String folderSurfix;
        String testerSurfix;
        long date = System.currentTimeMillis();
        String dateStr = String.valueOf(date);
        if (!dateStr.matches("[0-9]+")){
          if (verbose)
             System.out.println("Generating dateStr: dateStr is '' or empty or null, use dateStr='temp'. "
                      + dateStr);
            dateStr = "temp";
        }
        testerSurfix = dateStr;
        if (SID == null || SID.equalsIgnoreCase("null") || SID.length() == 0 || SID.equals("") || SID.equals("\"\"") || SID.equals("''")) {    
          if (verbose)
               System.out.println("Generating SID: SID is '' or empty or null, use SID=dateStr. "
                       + dateStr);
          SID = dateStr;
        }
        if (usr == null || usr.equalsIgnoreCase("null") || usr.length() == 0 || usr.equals("") || usr.equals("\"\"") || usr.equals("''")) {    
          if (verbose)
            System.out.println("Generating folderSurfix: usr is '' or empty or null, use SID+dateStr. "
                    + dateStr);
          folderSurfix = SID + dateStr;
        }
        else{
            folderSurfix = usr;
        }    
        
        String rdfID = request.getParameter("rdfID");
        out.print(rdfID);
        String query = "select QuizID,Code,MinVar,MaxVar,AnsType,QuesType from ent_jquiz where rdfID = '"+rdfID+"'";      
        rs = statement.executeQuery(query);
        if (verbose)
            System.out.println(query);
          
        while (rs.next()) {
            codeBlob = rs.getBlob("Code");   
            min = rs.getInt("MinVar");
            max = rs.getInt("MaxVar");        
            anstype = rs.getInt("AnsType");  
            quesType =  rs.getInt("QuesType");
            quizID = rs.getInt("QuizID");
        }  
     
        //Mohammed
        ResultSet rs10 = null;
        String text="TestRec";
        String query10 = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+quizID+"'";      
        rs10 = statement.executeQuery(query10);
        
        while (rs10.next()) {
     	   out.print("<input class='concepts-checkbox line"+rs10.getString("sline")+"' type='checkbox' value='line"+rs10.getString("sline")+"' onclick='checkConcept(this)'><span id="+rs10.getString("sline")+">"+rs10.getString("concept") +"</span><br>");
        }
        
        Random randomNumbers = new Random(); // random number generator
        Integer P =  min + (int) (randomNumbers.nextInt((max - min) + 1));//ori: min + randomNumbers.nextInt( max+1 ); //Returns a pseudorandom, uniformly distributed int value between 0 (inclusive) and the specified value (exclusive), drawn from this random number generator's sequence.           
        int position=0;
        //String codePart="";    
        
        //check multiple classes, get class name
        String sql = "select * from rel_quiz_class where QuizID = '"+quizID+"' ";  
        if (verbose)
            System.out.println(sql);
        int ClassID=0;
        rs1 = statement.executeQuery(sql);     
        while (rs1.next()) {//if only one class, the query will return nothing
            ClassID=rs1.getInt("ClassID");//not used later                    
            flag=1;//is useful later to indicate there are multiple classes
        }
        
        String sql2 = "select * from ent_class c, rel_quiz_class r where c.ClassID = r.ClassID and r.QuizID= '"+quizID+"' "; 
        if (verbose)
            System.out.println(sql2);
        ArrayList<String> fileName = new ArrayList<String>();
        rs2 = statement.executeQuery(sql2);  
        while (rs2.next()) {  
            fileName.add(rs2.getString("ClassName")); //"03BankAccount.java"                 
        } 
     
      
%>      
<!-- begin intro page -->
<div class="tab-page" id="intro-page">   
<h2 class="tab">Tester</h2>
    
<pre><%  

		byte[] codeByte = codeBlob.getBytes(1, (int) codeBlob.length());
		String codeStr = new String(codeByte);
		//System.out.println("Before:\n" + codeStr);
		codeStr = codeStr.replace("\r\n", "\n").replace("\r", "\n").replace("\n\n\n", "\n\n");
		codeStr = codeStr.replace("_Param", Integer.toString(P)).replace("<", "&lt;");
		if (!codeStr.endsWith("\n"))
			codeStr += "\n";
       String[] lines = codeStr.split("\n");
       String checkboxLines = "";
       //Mohammed
       for(int i=0;i<lines.length-1;i++){
    	   if(!lines[i].replace(" ", "").equals(""))
    	   {
    	   out.print( checkboxLines+"<input class='line-checkbox line"+i+"' type='checkbox' value='line"+i+"' onclick='checkLine(this)'><span id='line"+i+"'>"+lines[i]+"</span><br>");
       }
    	   else
    	   {
        	   out.print(  "<span id='line"+i+"'>"+lines[i]+"</span><br>");
    	   }
       }
       
       out.println("<form method=post>");   
       String submitString = "<br><input type=submit value=Submit name=submitButton onclick=submitFunction(this.form,1)>";// + "," + evalAnsServlet + ")>";
       if(quesType==1){
           out.println("<font color=blue>What is the final value of <b>result</b>?</font><br>");
           out.println("<input type=text name=inputans size=7>" + submitString);
       }else if (quesType==2){
	      out.println("<font color=blue>What is the output?</font><br><font color=grey size=2>Be careful of the space/newline in your answer.</font><br>");
          out.println("<textarea name=inputans rows=7 cols=45></textarea>" + submitString);
       }
       else if (quesType==3){
          out.println("Which line is wrong?<br>");
          out.println("<input type=text name=inputans size=7>" + submitString);
       } 
       out.println("<input type=hidden name=quesType value=" + quesType + ">");          

%> 
</pre><%                  
       out.println("<input type=hidden name=rdfID value='"+rdfID+"'>");
       out.println("<input type=hidden name=code value='"+codeStr+"'>");
       out.println("<input type=hidden name=P value='"+P+"'>");     
       
       //for UM
       out.println("<input type=hidden name=app value='" + appID + "'>");
       out.println("<input type=hidden name=act value='"+request.getParameter("act")+"'>");
       out.println("<input type=hidden name=sub value='"+request.getParameter("sub")+"'>");
       out.println("<input type=hidden name=sid value='"+request.getParameter("sid")+"'>");         
       out.println("<input type=hidden name=grp value='"+request.getParameter("grp")+"'>");
       out.println("<input type=hidden name=usr value='"+request.getParameter("usr")+"'>");
       out.println("<input type=hidden name=svc value='"+request.getParameter("svc")+"'>");
       
       //hy
       out.println("<input type=hidden name=folderSurfix value='"+ folderSurfix +"'>");
       out.println("<input type=hidden name=testerSurfix value='"+ testerSurfix +"'>");

                     
       //pass thru file name to QP
       int countFile = 0;
       for(int k=0;k<fileName.size();k++){
            out.println("<input type=hidden name='fileName"+k+"' value='"+fileName.get(k)+"'>");      
         	countFile++;
       }
       out.println("<input type=hidden name=class_size value='"+fileName.size()+"'>");         
       //2008.04.04 work for only one class
       out.println("<input type=hidden name=countFile value='"+countFile+"'>");
       //out.println("<input type=hidden name=fileName value='"+fileName+"'>");          
       out.println("<input type=hidden name=flag value='"+flag+"'>");         
       out.println("</form>");
%>                    

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
		    %>  <h2 class="tab"><%=RealFileName%></h2> 
		    <%         
		    }
		    else if(fileName.get(j).toString().substring(0,1).equals("1")){
		        RealFileName = fileName.get(j).toString().substring(2,fileName.get(j).toString().length()); 
		    %> <h2 class="tab"><%=RealFileName%></h2>
		    <%
		    }
		    else{    
		    %> <h2 class="tab"><%=fileName.get(j).toString().substring(0,fileName.get(j).toString().length()-5)%></h2>
		    <%
		    }
		    %>
		    <pre><%
	        //print out other classes                                
	        BufferedReader br1 = new BufferedReader(new FileReader(extraClassDir+fileName.get(j)));
	        String fileLine = "";                
	        while ((fileLine = br1.readLine()) != null)
	           out.println(fileLine);                                                          
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
<div id="concepts">

</div>
<!-- end tab pane -->

<!-- end webfx-main-body -->
</div>

<!-- JULIO: remote load of a page that will male the visualization of MG refresh -->
<%
if (request.getParameter("svc").indexOf("subproblem") >= 0){
	
}else{
%>
<iframe style="" id="remoteMGNotification" width="5" scrolling="no" height="5" frameborder="0" src="http://localhost/um-vis-adl/remote_update.html?action=actLoad&param=0"></iframe>
<%	
}
%>

<script language="JavaScript">
//<!-- 


//start code added by @Jordan
function checkLine(checkbox){
	var line = checkbox.value;
	if(checkbox.checked){ concepts-checkbox
		document.getElementById(line).setAttribute("style", "background-color: #ffb3b3");
	document.getElementsByClassName("concepts-checkbox "+line)[0].checked=true;


	}else{
		document.getElementById(line).setAttribute("style", "background-color: none");
		document.getElementsByClassName("concepts-checkbox "+line)[0].checked=false;
		
	}
}
//Mohammed
function checkConcept(checkbox){
	var line = checkbox.value;
	if(checkbox.checked){
		document.getElementById(line).setAttribute("style", "background-color: #ffb3b3");
		console.log(document.getElementsByClassName("line-checkbox "+line)[0]);
		document.getElementsByClassName("line-checkbox "+line)[0].checked=true;
		//document.getElementsByName(line)[0].setAttribute("style", "background-color: #ffb3b3");
	
	}else{
		document.getElementById(line).setAttribute("style", "background-color: none");
		document.getElementsByClassName("line-checkbox "+line)[0].checked=false;
		//document.getElementsByName(line)[0].setAttribute("style", "background-color: none");

	}
}

//Code for connecting the iframe with the feeback section
//addEventListener support for IE8
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

var results = document.getElementById('results'),
    messageButton = document.getElementById('message_button');
// Listen to messages from parent window
bindEvent(window, 'message', function (e) {
    results.innerHTML = e.data;
});

// Send random message data on every button click
bindEvent(messageButton, 'click', function (e) {
    var random = Math.random();
    sendMessage('' + random);
});

//end @Jordan


function submitFunction(obj, i){//}, functionName) {
    if (obj.inputans.value==""){
        alert("Please give your answer ;-)");
        return false;
    }
    else {
           obj.submitButton.disabled = true;
           //if (top.vis) top.vis.actSubmit();
           if (i==1) {
               obj.action="EvaluateAnswer";//functionName; //
               //alert(functionName);
           }
        obj.submit();
    }
   }
//-->
</script>  