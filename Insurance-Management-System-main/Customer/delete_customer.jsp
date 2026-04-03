<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/dbconnection.jsp" %>
<%
    // Check if logged in
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        if ("1".equals(request.getParameter("ajax"))) {
            response.setContentType("application/json");
            out.print("{\"success\":false,\"error\":\"Session expired. Please login again.\"}");
        } else {
            response.sendRedirect("../Main/login.jsp");
        }
        return;
    }

    boolean isAjax = "1".equals(request.getParameter("ajax"));
    boolean success = false;
    String message = "";
    String errorMsg = "";

    if (request.getParameter("id") != null) {
        int customerId = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getDBConnection();

            String checkSql = "SELECT COUNT(*) FROM customer_policy WHERE customer_id = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setInt(1, customerId);
            rs = pstmt.executeQuery();
            int policyCount = 0;
            if (rs.next()) policyCount = rs.getInt(1);
            rs.close();
            pstmt.close();

            if (policyCount > 0) {
                pstmt = conn.prepareStatement("DELETE FROM customer_policy WHERE customer_id = ?");
                pstmt.setInt(1, customerId);
                pstmt.executeUpdate();
                pstmt.close();
            }

            pstmt = conn.prepareStatement("DELETE FROM claim WHERE customer_id = ?");
            pstmt.setInt(1, customerId);
            pstmt.executeUpdate();
            pstmt.close();

            // Delete the customer record and capture affected rows
            pstmt = conn.prepareStatement("DELETE FROM customer WHERE customer_id = ?");
            pstmt.setInt(1, customerId);
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();

            if (rowsAffected > 0) {
                application.setAttribute("lastUpdate", System.currentTimeMillis());
                success = true;
                message = "Customer deleted successfully";
            } else {
                success = false;
                errorMsg = "Failed to delete customer";
            }
        } catch (Exception e) {
            errorMsg = "Error: " + e.getMessage().replace("\"", "\\\"");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    } else {
        errorMsg = "Invalid customer ID";
    }

    if (isAjax) {
        response.setContentType("application/json");
        if (success) {
            out.print("{\"success\":true,\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
        } else {
            out.print("{\"success\":false,\"error\":\"" + errorMsg.replace("\"", "\\\"") + "\"}");
        }
        return;
    }

    if (success) {
        response.sendRedirect("dashboard_customer.jsp?message=" + java.net.URLEncoder.encode(message, "UTF-8"));
    } else {
        response.sendRedirect("dashboard_customer.jsp?error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
    }
%>
