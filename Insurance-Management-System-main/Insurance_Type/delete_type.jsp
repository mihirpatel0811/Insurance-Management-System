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
    
    // Get type ID
    int typeId = 0;
    if (request.getParameter("id") != null) {
        typeId = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getDBConnection();
            
            // Delete associated policies first
            String deletePolicies = "DELETE FROM insurance_policy WHERE type_id = ?";
            pstmt = conn.prepareStatement(deletePolicies);
            pstmt.setInt(1, typeId);
            pstmt.executeUpdate();
            pstmt.close();
            
            // Now delete the type
            String deleteSql = "DELETE FROM insurance_type WHERE type_id = ?";
            pstmt = conn.prepareStatement(deleteSql);
            pstmt.setInt(1, typeId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                response.sendRedirect("dashboard_type.jsp?message=Insurance type deleted successfully");
            } else {
                response.sendRedirect("dashboard_type.jsp?error=Failed to delete insurance type");
            }
            
        } catch (Exception e) {
            response.sendRedirect("dashboard_type.jsp?error=Error deleting insurance type: " + e.getMessage());
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        response.sendRedirect("dashboard_type.jsp?error=Invalid insurance type ID");
    }
%>
