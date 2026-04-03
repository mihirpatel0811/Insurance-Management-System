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
    
    // Get customer ID and policy ID
    int customerId = 0;
    int policyId = 0;
    
    if (request.getParameter("customerId") != null && request.getParameter("policyId") != null) {
        customerId = Integer.parseInt(request.getParameter("customerId"));
        policyId = Integer.parseInt(request.getParameter("policyId"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getDBConnection();
            
            String deleteSql = "DELETE FROM customer_policy WHERE customer_id = ? AND policy_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, customerId);
            pstmt.setInt(2, policyId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                application.setAttribute("lastUpdate", System.currentTimeMillis());
                response.sendRedirect("dashboard_cust_policy.jsp?message=Policy assignment removed successfully");
            } else {
                response.sendRedirect("dashboard_cust_policy.jsp?error=Failed to remove policy assignment");
            }
            
        } catch (Exception e) {
            response.sendRedirect("dashboard_cust_policy.jsp?error=Error removing policy assignment: " + e.getMessage());
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("dashboard_cust_policy.jsp?error=Invalid customer or policy ID");
    }
%>
