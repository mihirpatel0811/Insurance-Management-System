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
    
    // Get policy ID
    int policyId = 0;
    if (request.getParameter("id") != null) {
        policyId = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getDBConnection();
            
            // Delete associated customer policies first
            String deleteCustPolicies = "DELETE FROM customer_policy WHERE policy_id = ?";
            pstmt = conn.prepareStatement(deleteCustPolicies);
            pstmt.setInt(1, policyId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Delete associated claims first
            String deleteClaims = "DELETE FROM claim WHERE policy_id = ?";
            pstmt = conn.prepareStatement(deleteClaims);
            pstmt.setInt(1, policyId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Now delete the policy
            String deleteSql = "DELETE FROM insurance_policy WHERE policy_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, policyId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                application.setAttribute("lastUpdate", System.currentTimeMillis());
                response.sendRedirect("dashboard_insur_policy.jsp?message=Policy deleted successfully");
            } else {
                response.sendRedirect("dashboard_insur_policy.jsp?error=Failed to delete policy");
            }
            
        } catch (Exception e) {
            response.sendRedirect("dashboard_insur_policy.jsp?error=Error deleting policy: " + e.getMessage());
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("dashboard_insur_policy.jsp?error=Invalid policy ID");
    }
%>
