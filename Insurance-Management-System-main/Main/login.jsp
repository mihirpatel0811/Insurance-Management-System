<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/dbconnection.jsp" %>
<%
    // Check if already logged in
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser != null) {
        response.sendRedirect("main.jsp");
        return;
    }
    
    String errorMessage = "";
    String successMessage = "";
    
    // Handle login form submission
    if ("POST".equals(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        // Validate inputs
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            errorMessage = "Please enter both username and password";
        } else {
            // Database connection
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = getDBConnection();
                
                String sql = "SELECT * FROM admin WHERE username = ? AND password = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.setString(2, password);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    // Login successful
                    session.setAttribute("adminUser", username);
                    session.setAttribute("adminId", rs.getInt("admin_id"));
                    response.sendRedirect("main.jsp");
                    return;
                } else {
                    errorMessage = "Invalid username or password";
                }
                
            } catch (Exception e) {
                errorMessage = "Database error: " + e.getMessage();
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception e) {}
                if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Insurance Management System</title>
    <link rel="stylesheet" href="../desigen/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="login-header">
                <i class="fas fa-shield-halved"></i>
                <h2>Insurance Management</h2>
                <p>Admin Login Panel</p>
            </div>
            
            <div class="login-body">
                <% if (!errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><%= errorMessage %></span>
                        <button class="alert-close" onclick="this.parentElement.remove()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                <% } %>
                
                <% if (!successMessage.isEmpty()) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i>
                        <span><%= successMessage %></span>
                        <button class="alert-close" onclick="this.parentElement.remove()">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                <% } %>
                
                <form action="login.jsp" method="POST" class="needs-validation">
                    <div class="form-group">
                        <label for="username">Username <span class="required">*</span></label>
                        <div class="input-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" id="username" name="username" class="form-control" 
                                   placeholder="Enter your username" required autocomplete="username">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password <span class="required">*</span></label>
                        <div class="input-icon">
                            <i class="fas fa-lock"></i>
                            <input type="password" id="password" name="password" class="form-control" 
                                   placeholder="Enter your password" required autocomplete="current-password">
                        </div>
                    </div>
                    
                    <button type="submit" class="btn-login">
                        <i class="fas fa-sign-in-alt"></i> Login
                    </button>
                </form>
            </div>
            
            <div class="login-footer">
                <p><a href="../index.html"><i class="fas fa-arrow-left"></i> Back to Home</a></p>
            </div>
        </div>
    </div>
    
    <script src="../desigen/script.js"></script>
</body>
</html>
