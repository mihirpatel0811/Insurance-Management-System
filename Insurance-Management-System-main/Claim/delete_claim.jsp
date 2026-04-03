<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/dbconnection.jsp" %>
<%
    // Check if logged in
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("../Main/login.jsp");
        return;
    }
    
    // Get claim ID
    int claimId = 0;
    if (request.getParameter("id") != null) {
        claimId = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
            try {
            conn = getDBConnection();
            
            String deleteSql = "DELETE FROM claim WHERE claim_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, claimId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                application.setAttribute("lastUpdate", System.currentTimeMillis());
                response.sendRedirect("dashboard_claim.jsp?message=Claim deleted successfully");
            } else {
                response.sendRedirect("dashboard_claim.jsp?error=Failed to delete claim");
            }
            
        } catch (Exception e) {
            response.sendRedirect("dashboard_claim.jsp?error=Error deleting claim: " + e.getMessage());
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("dashboard_claim.jsp?error=Invalid claim ID");
    }
%>
