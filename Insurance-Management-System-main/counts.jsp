<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/dbconnection.jsp" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int customerCount = 0, policyCount = 0, companyCount = 0, claimCount = 0, activePolicies = 0, pendingClaims = 0;
    try {
        conn = getDBConnection();
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM customer");
        rs = pstmt.executeQuery(); if (rs.next()) customerCount = rs.getInt(1); rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM insurance_policy");
        rs = pstmt.executeQuery(); if (rs.next()) policyCount = rs.getInt(1); rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM insurance_company");
        rs = pstmt.executeQuery(); if (rs.next()) companyCount = rs.getInt(1); rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM claim");
        rs = pstmt.executeQuery(); if (rs.next()) claimCount = rs.getInt(1); rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM customer_policy WHERE end_date >= CURDATE()");
        rs = pstmt.executeQuery(); if (rs.next()) activePolicies = rs.getInt(1); rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM claim WHERE status = 'Pending'");
        rs = pstmt.executeQuery(); if (rs.next()) pendingClaims = rs.getInt(1); rs.close(); pstmt.close();
    } catch (Exception e) {
        // ignore and return zeros
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }

    out.print("{");
    out.print("\"customerCount\":"+customerCount+",");
    out.print("\"policyCount\":"+policyCount+",");
    out.print("\"companyCount\":"+companyCount+",");
    out.print("\"claimCount\":"+claimCount+",");
    out.print("\"activePolicies\":"+activePolicies+",");
    out.print("\"pendingClaims\":"+pendingClaims);
    out.print("}");
%>
