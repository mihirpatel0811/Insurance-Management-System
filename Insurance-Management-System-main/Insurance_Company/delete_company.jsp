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
    
    // Get company ID
    int companyId = 0;
    if (request.getParameter("id") != null) {
        companyId = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getDBConnection();
            
            // Delete associated policies first
            String deletePolicies = "DELETE FROM insurance_policy WHERE company_id = ?";
            pstmt = conn.prepareStatement(deletePolicies);
            pstmt.setInt(1, companyId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Now delete the company
            String deleteSql = "DELETE FROM insurance_company WHERE company_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, companyId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                application.setAttribute("lastUpdate", System.currentTimeMillis());
                response.sendRedirect("dashboard_company.jsp?message=Company deleted successfully");
            } else {
                response.sendRedirect("dashboard_company.jsp?error=Failed to delete company");
            }
            
        } catch (Exception e) {
            response.sendRedirect("dashboard_company.jsp?error=Error deleting company: " + e.getMessage());
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("dashboard_company.jsp?error=Invalid company ID");
    }
%>
