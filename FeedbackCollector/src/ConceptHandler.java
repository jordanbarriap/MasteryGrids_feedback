

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ConceptHandler
 */
@WebServlet("/ConceptHandler")
public class ConceptHandler extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ConceptHandler() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
        try {
        	dbInterface dbconnection = new dbInterface(getServletContext().getInitParameter("db.url"),getServletContext().getInitParameter("db.user"),getServletContext().getInitParameter("db.passwd"));
        	dbconnection.openConnection();
        	Class.forName(getServletContext().getInitParameter("db.driver"));
			String actID = request.getParameter("actID");
			System.out.println(actID);
			String provider = request.getParameter("provider");
			ResultSet result = null; 
			if(provider.equals("quizjet")){
				ArrayList<String> arr = new ArrayList<String>();
				String query = "SELECT * FROM rel_content_concept r, ent_jquiz e WHERE r.title=e.title and e.QuizID = '"+actID+"'"; 
				result = dbconnection.executeQuery(query); 
				while (result.next()) {//if only one class, the query will return nothing 
					System.out.println(result.getString("concept"));
					arr.add(result.getString("concept"));
				}
				//Here we serialize the stream to a String.
			    final String output = arr.toString();
			    response.setContentLength(output.length());
			    //And write the string to output.
			    response.getOutputStream().write(output.getBytes());
			    response.getOutputStream().flush();
			    response.getOutputStream().close();
			}
			dbconnection.closeConnection();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
		

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}
	
	/*public String[] getConcepts(String act){
		try {
            String res = "";
            stmt = conn.createStatement();
            String query = "select G.group_name from ent_group G where G.group_id = '"
                    + grp + "';";
            rs = stmt.executeQuery(query);
            System.out.println(query);

            while (rs.next()) {
                res = rs.getString("group_name");
            }
            this.releaseStatement(stmt, rs);
            return res;
        } catch (SQLException ex) {
            this.releaseStatement(stmt, rs);
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
            return null;
        } finally {
            this.releaseStatement(stmt, rs);
        }
	}*/

}
