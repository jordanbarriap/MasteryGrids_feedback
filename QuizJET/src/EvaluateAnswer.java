//import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
//import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
//import javax.servlet.http.HttpSession;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import edu.pitt.sis.paws.cbum.report.ReportAPI;

public class EvaluateAnswer extends HttpServlet {
	/**
	 * Creates temp directory and file to compile or interprete to get result, and then compare with user's input answer. 
	 * Call displayQuizAns.jsp afterwards.
	 * Delete temp files at the end.
	 */
	private static final long serialVersionUID = 1L;
	private static boolean verbose = false;
	//TODO: consider passing a parameter?
	private static boolean ignoreFinalNewlines = true;


	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, java.io.IOException {
		doGet(request, response);
	}
	
	public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		
		ServletOutputStream out = response.getOutputStream();
		double evaluateResult = -1; //for reporting to UM
		String appDir = getServletContext().getInitParameter("appDir");
	    String language = getServletContext().getInitParameter("language");
	    String compilerHomeDir = getServletContext().getInitParameter("compilerHomeDir");
		boolean windows = getServletContext().getInitParameter("windows").equals("true") ? true : false;
	    verbose  = getServletContext().getInitParameter("verbose").equals("true") ? true : false;
	    String displayQuizAnsServlet = "displayQuizAns.jsp";//getServletContext().getInitParameter("displayQuizAnsServlet");
    
		String dirDelim = windows ? "\\\\" : "//";
	    String fileSurfix = "." + language;
	    String onlineCompileDir = appDir + "online_compile" + dirDelim;//appDir + 
	    String extraClassDir = appDir + "class" + dirDelim;//appDir + 
		boolean deleteFiles = true;
		String folderSurfix = request.getParameter("folderSurfix");
		String testerSurfix = request.getParameter("testerSurfix");
		String usr = request.getParameter("usr");
		String userAns = request.getParameter("inputans");
		int multiClassFlag = Integer.parseInt(request.getParameter("flag")); // flag=1 means multiclass
		String replace = "___"; // This is for replacing newline symbols, since we are passing it by URL. should always be the same symbol repeated three times, if changes, should change in the display_quiz_ans.jsp, too. 
		
		String curActionDir = onlineCompileDir + folderSurfix + dirDelim;
		File curActionD = new File(curActionDir);
		String testerName = (multiClassFlag == 1 ? "Tester1" : "Tester");
		String code = request.getParameter("code");
		Integer queType = Integer.parseInt(request.getParameter("quesType"));
		
		createTempFile(curActionD, curActionDir, testerName, testerSurfix, fileSurfix, queType, code, out);
		
		String compileCmd1 = "";
		String compileCmd2 = "";
		String executeCmd1 = "";
		String executeCmd2 = "";
		if (language.equalsIgnoreCase("Java")) {
			compileCmd1 = (windows?"cmd /c ":"") + compilerHomeDir + "javac " + curActionDir + "Tester" + testerSurfix + ".java";
			compileCmd2 = (windows?"cmd /c ":"") + compilerHomeDir + "javac -classpath " + curActionDir + " " + curActionDir + "Tester1" + testerSurfix + ".java";
			executeCmd1 = compilerHomeDir + "java -classpath " + curActionDir + " Tester" + testerSurfix;
			executeCmd2 = compilerHomeDir + "java -classpath " + curActionDir + " Tester1" + testerSurfix;
		}
		else {
			compileCmd1 = compilerHomeDir + "python " + curActionDir + "Tester" + testerSurfix + ".py";
			executeCmd1 = compileCmd1;
		}

		if (verbose) {
			log("onlineCompileDir: " + onlineCompileDir);
			log("extraClassDir: " + extraClassDir);
			log("compilerHomeDir: " + compilerHomeDir);
			log("curActionDir: " + curActionDir);
		}

		
		if (verbose) {
			log("\n******** In EvaluateAnswer.java ******");
			Enumeration<String> en = request.getParameterNames();
			for (; en.hasMoreElements();) {
				String name = (String) en.nextElement();
				log(name);
				String[] values = request.getParameterValues(name);
				for (int i = 0; i < values.length; i++) {
					log("    " + values[i]);
				}
			}
		}

		ArrayList<String> fileNames = new ArrayList<String>();
		if (multiClassFlag == 1)
			for (int i = 0; i < Integer.parseInt(request.getParameter("class_size")); i++) 
				fileNames.add(request.getParameter("fileName" + i + ""));

		//HttpSession session = request.getSession(true);
		try {
			File singleClassMainFile = new File(curActionDir + "Tester" + testerSurfix + fileSurfix);
			File multiClassMainFile = new File(curActionDir + "Tester1" + testerSurfix + fileSurfix);

			if (multiClassFlag == 0 && singleClassMainFile.exists()) {
				if (verbose)
					log("INFO: multiClassFlag == 0 && singleClassMainFile.exists()");
				if (deleteFiles && fileSurfix.equals(".java"))
					deleteTempFiles("Tester" + testerSurfix, curActionDir, ".class");

				Process p = Runtime.getRuntime().exec(compileCmd1);
				if (verbose)
					log("INFO: Executing: " + compileCmd1);
				p.waitFor();

				if (p.exitValue() != 0)
					outLog("ERROR: online compile failed: " + compileCmd1 + ", exitValue: " + p.exitValue(), out);
				else if (p.waitFor() != 0) 
					outLog("ERROR: online compile is not finished yet: " + compileCmd1, out);
				else {
					Process p1 = Runtime.getRuntime().exec(executeCmd1);
					if (verbose)
						log("INFO: Executing: " + executeCmd1);
					p1.waitFor();

					//System.out.println("queType:" + queType);
					InputStreamReader reader = new InputStreamReader(p1.getInputStream());

					byte[] correctAnsInByte = IOUtils.toByteArray(reader, "UTF-8");
					String correctAns = new String(correctAnsInByte, "UTF-8");
					
					/* queType=1 for "result" type of question; queType=2 for "print" type of question */
					
					/* on 2016/09/30 no matter what type of question it is, the ending newline is not considered (e.g., even the correct answer has it but student's answer doesn't have it, it is fine. */
					if (ignoreFinalNewlines){
						int i = 0;
						while (i < 10){
							if (correctAns.endsWith("\r\n"))
								correctAns = correctAns.substring(0, correctAns.length() - 2);
							else if (correctAns.endsWith("\r") || correctAns.endsWith("\n"))
								correctAns = correctAns.substring(0, correctAns.length() - 1);
							else
								break;
							i++;
						}
						i = 0;
						while (i < 10){
							if (userAns.endsWith("\r\n"))
								userAns = userAns.substring(0, userAns.length() - 2);
							else if (userAns.endsWith("\r") || userAns.endsWith("\n"))
								userAns = userAns.substring(0, userAns.length() - 1);
							else
								break;
							i++;
						}
					}
					//}
					/* Replace to special characters in order to pass them to url to displayQuizAns.jsp */
					correctAns = correctAns.replace("\r", "\n").replace("\n\n", "\n").replace("\n", replace);
					userAns = userAns.replace("\r", "\n").replace("\n\n", "\n").replace("\n", replace);
					//System.out.println("correctAns:" + correctAns + ", userAns:" + userAns);
					
					response.sendRedirect(getRedirectStr(request, displayQuizAnsServlet, userAns, correctAns, replace));
					//session.setAttribute("res",  userAns.equals(correctAns) ? "1" : "0");
					evaluateResult = userAns.equals(correctAns) ? 1.0 : 0.0;
					
					if (deleteFiles)
						deleteTempFiles("Tester" + testerSurfix, curActionDir, fileSurfix);
					if (p1.exitValue() != 0)
						outLog("ERROR: online execution failed: " + executeCmd1 + ", exitValue: " + p1.exitValue(), out);
				}
			}
			else if (multiClassFlag == 1 && multiClassMainFile.exists()) {
				if (verbose)
					log("INFO: multiClassFlag == 1 && multiClassMainFile.exists()");
//				if (deleteFiles)
//					deleteTempClassFile("Tester1" + testerSurfix, curActionDir, fileSurfix);
				if (deleteFiles && fileSurfix.equals(".java"))
					deleteTempFiles("Tester1" + testerSurfix, curActionDir, ".class");

				File extraClassFile;
				File outputFile;

				String[] tempRealFiles = new String[Integer.parseInt(request.getParameter("class_size"))];
				for (int i = 0; i < Integer.parseInt(request.getParameter("class_size")); i++) {
					String Name = fileNames.get(i).toString();
					extraClassFile = new File(extraClassDir + Name);

					if (fileNames.get(i).toString().substring(0, 1).equals("0")) {
						String RealFileName = fileNames.get(i).toString().substring(2, fileNames.get(i).toString().length());
						outputFile = new File(curActionDir + RealFileName);
						tempRealFiles[i] = RealFileName;
					}
					else if (fileNames.get(i).toString().substring(0, 1).equals("1")) {
						String RealFileName = fileNames.get(i).toString().substring(2, fileNames.get(i).toString().length());
						outputFile = new File(curActionDir + RealFileName);
						tempRealFiles[i] = RealFileName;
					}
					else {
						outputFile = new File(curActionDir + fileNames.get(i));
						tempRealFiles[i] = fileNames.get(i);
					}
					FileInputStream input = new FileInputStream(extraClassFile);
					FileOutputStream output = new FileOutputStream(outputFile);
					int c;

					while ((c = input.read()) != -1)
						output.write(c);

					input.close();
					output.close();
					if (deleteFiles && fileSurfix.equals(".java"))
						deleteTempFiles(tempRealFiles[i], curActionDir, ".class");
						//deleteTempClassFile(tempRealFiles[i], curActionDir, fileSurfix);
				}
				Process p2 = Runtime.getRuntime().exec(compileCmd2);
				if (verbose)
					log("INFO: Executing: " + compileCmd2);
				p2.waitFor();

				if (p2.exitValue() != 0)
					outLog("ERROR: Online compilation/interpretation failed: " + compileCmd2 + "\nexitValue: " + p2.exitValue(), out);
				else if (p2.waitFor() != 0)
					outLog("ERROR: Online compilation/interpretation with importing class(es) is not finished yet!", out);
				else {
					Process p3 = Runtime.getRuntime().exec(executeCmd2);
					if (verbose)
						log("INFO: Executing: " + executeCmd2);
					p3.waitFor();

					InputStreamReader reader = new InputStreamReader(p3.getInputStream());
					byte[] correctAnsInByte = IOUtils.toByteArray(reader, "UTF-8");
					String correctAns = new String(correctAnsInByte, "UTF-8");
					
					if (ignoreFinalNewlines){
						int i = 0;
						while (i < 10){
							if (correctAns.endsWith("\r\n"))
								correctAns = correctAns.substring(0, correctAns.length() - 2);
							else if (correctAns.endsWith("\r") || correctAns.endsWith("\n"))
								correctAns = correctAns.substring(0, correctAns.length() - 1);
							else
								break;
							i++;
						}
						i = 0;
						while (i < 10){
							if (userAns.endsWith("\r\n"))
								userAns = userAns.substring(0, userAns.length() - 2);
							else if (userAns.endsWith("\r") || userAns.endsWith("\n"))
								userAns = userAns.substring(0, userAns.length() - 1);
							else
								break;
							i++;
						}
					}
					
					correctAns = correctAns.replace("\r", "\n").replace("\n\n", "\n").replace("\n", replace);
					userAns = userAns.replace("\r", "\n").replace("\n\n", "\n").replace("\n", replace);
//					if (verbose)
//						log("correct_tmp's length:" + correct_tmp.length() + "\ncorrectans:\n" + correctAns + "//\ncorrectans length: " + correctAns.length() + "\nuserans:\n" + userAns + "//userans length: " + userAns.length());
					
					response.sendRedirect(getRedirectStr(request, displayQuizAnsServlet, userAns, correctAns, replace));
					//session.setAttribute("res", userAns.equals(correctAns) ? "1" : "0");
					evaluateResult = userAns.equals(correctAns) ? 1.0 : 0.0;
					
					if (deleteFiles){
						deleteTempFiles("Tester1" + testerSurfix, curActionDir, fileSurfix);
						for (String tempRealFile : tempRealFiles)
							deleteTempFiles(tempRealFile, curActionDir, fileSurfix);
					}
					if (p3.exitValue() != 0) {
						outLog("ERROR: online execution failed: " + executeCmd2 + "\nexitValue: " + p3.exitValue(), out);
					}
				}// p2.exitValue()==0 || p2.waitFor();
			}// flag == 1 && f2.exists()
			else {// flag != 1 || !f2.exists()
				String str = "ERROR: EvaluateAnswer.java ";
				if (!singleClassMainFile.exists() && !multiClassMainFile.exists())
					outLog(str + "!singleClassMainFile.exists() && !multiClassMainFile.exists()", out);
				else if (multiClassFlag == 0 && !singleClassMainFile.exists())
					outLog(str + "multiClassFlag == 0 && !singleClassMainFile.exists()", out);
				else if (multiClassFlag == 1 && !multiClassMainFile.exists())
					outLog(str + "multiClassFlag == 1 && !multiClassMainFile.exists()", out);
			}
		}
		catch (Exception e) {
			System.out.println(e);
		}

		if (deleteFiles) {
			if (curActionD.exists()) {
				if (!(usr == null || usr.equalsIgnoreCase("null") || usr.length() == 0 || usr.equals("") || usr.equals("\"\"") || usr.equals("''"))) {
					// in this case, folder name will just be the usr
					FileUtils.cleanDirectory(curActionD);
					if (verbose)
						log("INFO: Cleaning directory: " + curActionD);
				}
				else {
					FileUtils.deleteDirectory(curActionD);
					if (verbose)
						log("INFO: Deleting directory: " + curActionD);
				}
			}
		}
		
		boolean reportToUM = getServletContext().getInitParameter("reportToUM").equalsIgnoreCase("true")? true : false;
		String act = request.getParameter("act");
		String sub = request.getParameter("sub");
		if (reportToUM){
			String svc = request.getParameter("svc");
			if (!svc.contains("subproblem") || svc.contains("pretest") || svc.contains("pretrain")){
				reportToPAWsUM(request, evaluateResult, true);
			}
			else log("INFO: Not Reporting activity " + act + ", subactivity " + sub + " to um server!");
		}
		else
			log("INFO: Not reporting activity " + act + ", subactivity " + sub + " to um server!");
	//HttpSession session = request.getSession(true);
	}
	
	private void reportToPAWsUM(HttpServletRequest request, double evaluateResult, boolean verbose){
		
		int appId = Integer.parseInt(request.getParameter("app"));//25;
		String act = request.getParameter("act");
		String sub = request.getParameter("sub");
		String sid = request.getParameter("sid");
		//why use session not request here?
		//double res = session.getAttribute("res").equals("0") ? 0 : 1; //{//previously used "==", which doesn't generate error by chance
		double res = evaluateResult;
		String grp = request.getParameter("grp");
		String user = request.getParameter("usr");
		String svc = request.getParameter("svc");
		// initialize ReportAPI object with URL of the User Model
		// http://adapt2.sis.pitt.edu/wiki/CUMULATE_protocol
		ReportAPI r_api = new ReportAPI(getServletContext().getInitParameter("userModelURL"));//"http://adapt2.sis.pitt.edu/cbum/um");
		try {
			// Send report
			if (verbose) log("INFO: Reporting activity " + act + ", subactivity " + sub + " to um server!");
			r_api.report(appId, act, sub, sid, res, grp, user, svc);
		}
		catch (IOException ioe) {
			System.out.println(ioe);
		}
	}
	
	private String getRedirectStr(HttpServletRequest request, String servletName, String userAns, String correctAns, String replace){
		//String rdfID:  question name
		//String sid : session ID
		String comparisonStr = userAns.equals(correctAns) ? "1" : "0";
		// Caution: don't put correct in the end, because then the final "enter" symbol will be abandoned when display_quiz_ans.jsp received it from response.sendRediret
		//on columnbus, remove request.getContextPath() + "/" 
		String responseStr = servletName + "?rdfID=" + request.getParameter("rdfID") + "&c=" + correctAns 
												+ "&app=" + request.getParameter("app") + "&sub=" + request.getParameter("sub") + "&act=" + request.getParameter("act")
												+	"&res=" + comparisonStr 
												+ "&usr=" + request.getParameter("usr") + "&grp=" + request.getParameter("grp") + "&svc=" + request.getParameter("svc") 
												+ "&ans=" + userAns + "&P=" + request.getParameter("P") + "&sid=" + request.getParameter("sid") + "&replace=" + replace;
		
		log("INFO: EvaluateAnswer.java sending redirect: " + responseStr);
		return responseStr;
	}

	private void deleteTempFiles(String tempFileName, String curActionDir, String surfix) {
		// input: Tester(1)+testerSurfix or BankAccout.java
		if (verbose)
			log("INFO: Inside: deleteTempJavaAndClassFile " + tempFileName);

		String fileName = tempFileName;
		//remove the surfix from the fileName
		if (tempFileName.contains(surfix)) 
			fileName = tempFileName.substring(0, tempFileName.lastIndexOf(surfix));
		
		File f = new File(curActionDir + fileName + surfix);
		if (f.exists()) {
			f.delete();
			if (verbose)
				log("INFO: Deleting: " + curActionDir + fileName + surfix);
		}
		if (surfix.equals(".java")) {
			f = new File(curActionDir + fileName + ".class");
			if (f.exists()) {
				f.delete();
				if (verbose)
					log("INFO: Deleting: " + curActionDir + fileName + ".class");
			}
		}
	}

	
	public void createTempFile(File curActionD, String curActionDir, String testerName, String testerSurfix, String fileSurfix, int queType, String codePart, ServletOutputStream out) throws IOException{
  	//System.out.println("codePart:\n" + codePart);

		if (curActionD.exists() && curActionD.isDirectory()) {
		    FileUtils.cleanDirectory(curActionD); //Cleans a directory without deleting it.
//		    log("INFO: EvaluateAnswer.java cleaning directory: " + curActionD);
		}
		else if (!curActionD.mkdir())
		    outLog("ERROR: EvaluateAnswer.java directory creation failed: " + curActionDir, out);
		    
		if(codePart.contains("Tester"))             
			codePart = codePart.replace("Tester", testerName + testerSurfix); 
		
	    String fileName = testerName + testerSurfix + fileSurfix;
	    String finalCodePart = codePart; 
			FileWriter writer = new FileWriter(curActionDir + fileName); 
	    if(queType == 1){
	        if (fileName.endsWith(".py")){//if (language.equals("py")){
	        	if (!finalCodePart.endsWith("\n"))
	        		finalCodePart += "\n";
	        	finalCodePart += "print result\n";
	        }
	        else{
	//            int codeLen = finalCodePart.length();
	//            finalCodePart = finalCodePart.substring(0, codeLen-9) + "System.out.print(result);}}";//"System.out.println(result);}}";
	
	            finalCodePart = finalCodePart.substring(0, finalCodePart.lastIndexOf("}"));
	            finalCodePart = finalCodePart.substring(0, finalCodePart.lastIndexOf("}"));
	            finalCodePart += "\nSystem.out.print(result);\n}\n}";//"System.out.println(result);}}";
	
	        }
	    }   
	    finalCodePart.replace("\r\n", "\n").replace("\r", "\n").replace("\n\n", "\n");
	    writer.write(finalCodePart);
	    writer.close();
//	    log("INFO: EvaluateAnswer.java writing code to: " + curActionDir + fileName);
	
	    if (verbose)
	    	System.out.println("FinalCodePart:\n" + finalCodePart);
	}
	
	public void outLog(String str, ServletOutputStream out) throws IOException{
		DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		Date date = new Date();
		str = dateFormat.format(date) + " " + str;
		System.out.println(str);
		out.println(str);
	}
	
	public void log(String str){
		DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		Date date = new Date();
		str = dateFormat.format(date) + " " + str;
		System.out.println(str);
	}
	
	
	
}