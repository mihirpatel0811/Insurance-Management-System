<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/dbconnection.jsp" %>
<%
    // Check if logged in
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int adminId = (Integer) session.getAttribute("adminId");
    
    String errorMessage = "";
    String successMessage = "";
    
    // Database connection
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String currentUsername = "";
    String currentPassword = "";
    
    try {
        conn = getDBConnection();
        
        // Get admin details
        pstmt = conn.prepareStatement("SELECT * FROM admin WHERE admin_id = ?");
        pstmt.setInt(1, adminId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            currentUsername = rs.getString("username");
            currentPassword = rs.getString("password");
        }
        
    } catch (Exception e) {
        errorMessage = "Error loading profile: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    // Handle form submission for password change
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("updatePassword".equals(action)) {
            String currentPass = request.getParameter("currentPassword");
            String newPass = request.getParameter("newPassword");
            String confirmPass = request.getParameter("confirmPassword");
            
            if (currentPass == null || currentPass.trim().isEmpty() ||
                newPass == null || newPass.trim().isEmpty() ||
                confirmPass == null || confirmPass.trim().isEmpty()) {
                errorMessage = "All password fields are required";
            } else if (!currentPass.equals(currentPassword)) {
                errorMessage = "Current password is incorrect";
            } else if (!newPass.equals(confirmPass)) {
                errorMessage = "New password and confirm password do not match";
            } else if (newPass.length() < 6) {
                errorMessage = "Password must be at least 6 characters";
            } else {
                // Update password
                try {
                    conn = getDBConnection();
                    pstmt = conn.prepareStatement("UPDATE admin SET password = ? WHERE admin_id = ?");
                    pstmt.setString(1, newPass);
                    pstmt.setInt(2, adminId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Password updated successfully!";
                    currentPassword = newPass;
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                    
                } catch (Exception e) {
                    errorMessage = "Error updating password: " + e.getMessage();
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
                    if (conn != null) try { conn.close(); } catch (Exception e) {}
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile - Insurance Management System</title>
    <link rel="stylesheet" href="../desigen/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <i class="fas fa-shield-halved"></i>
                </div>
                <h3>IMS</h3>
                <p>Admin Panel</p>
            </div>
            
            <nav class="sidebar-menu">
                <div class="menu-section">Main</div>
                <a href="main.jsp" class="menu-item">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="admin_profile.jsp" class="menu-item active">
                    <i class="fas fa-user-circle"></i>
                    <span>Profile</span>
                </a>
                
                <div class="menu-section">Management</div>
                <a href="../Customer/dashboard_customer.jsp" class="menu-item">
                    <i class="fas fa-users"></i>
                    <span>Customers</span>
                </a>
                <a href="../Insurance_Company/dashboard_company.jsp" class="menu-item">
                    <i class="fas fa-building-columns"></i>
                    <span>Companies</span>
                </a>
                <a href="../Insurance_Type/dashboard_type.jsp" class="menu-item">
                    <i class="fas fa-tags"></i>
                    <span>Insurance Types</span>
                </a>
                <a href="../Insurance_Policy/dashboard_insur_policy.jsp" class="menu-item">
                    <i class="fas fa-file-contract"></i>
                    <span>Policies</span>
                </a>
                <a href="../Customer_Policy/dashboard_cust_policy.jsp" class="menu-item">
                    <i class="fas fa-handshake"></i>
                    <span>Customer Policies</span>
                </a>
                <a href="../Claim/dashboard_claim.jsp" class="menu-item">
                    <i class="fas fa-clipboard-check"></i>
                    <span>Claims</span>
                </a>
                
                <div class="menu-section">Account</div>
                <a href="logout.jsp" class="menu-item">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            <!-- Top Bar -->
            <header class="top-bar">
                <div class="top-bar-left">
                    <h2>Admin Profile</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <span>Profile</span>
                    </div>
                </div>
                <div class="top-bar-right">
                    <div class="user-info">
                        <div class="user-avatar">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="user-details">
                            <span class="name"><%= adminUser %></span>
                            <span class="role">Administrator</span>
                        </div>
                    </div>
                    <a href="logout.jsp" class="btn-logout">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </header>
            
            <!-- Content Area -->
            <div class="content-area">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Profile Settings</h1>
                        <p>Manage your account settings and password</p>
                    </div>
                </div>
                
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
                
                <!-- Profile Info Card -->
                <div class="card" style="max-width: 600px; margin-bottom: 2rem;">
                    <div class="card-header">
                        <h3><i class="fas fa-user"></i> Account Information</h3>
                    </div>
                    <div class="card-body">
                        <div style="display: flex; align-items: center; gap: 1.5rem; margin-bottom: 1.5rem;">
                            <div style="width: 80px; height: 80px; background: linear-gradient(135deg, var(--secondary-color), var(--info-color)); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: white;">
                                <i class="fas fa-user-circle"></i>
                            </div>
                            <div>
                                <h3><%= currentUsername %></h3>
                                <p style="color: var(--gray);">Administrator</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Username</label>
                            <input type="text" class="form-control" value="<%= currentUsername %>" readonly>
                            <small style="color: var(--gray);">Username cannot be changed</small>
                        </div>
                        
                        <div class="form-group">
                            <label>Admin ID</label>
                            <input type="text" class="form-control" value="<%= adminId %>" readonly>
                        </div>
                    </div>
                </div>
                
                <!-- Change Password Card -->
                <div class="card" style="max-width: 600px;">
                    <div class="card-header">
                        <h3><i class="fas fa-lock"></i> Change Password</h3>
                    </div>
                    <div class="card-body">
                        <form action="admin_profile.jsp" method="POST">
                            <input type="hidden" name="action" value="updatePassword">
                            
                            <div class="form-group">
                                <label for="currentPassword">Current Password <span class="required">*</span></label>
                                <input type="password" id="currentPassword" name="currentPassword" class="form-control" 
                                       placeholder="Enter current password" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="newPassword">New Password <span class="required">*</span></label>
                                <input type="password" id="newPassword" name="newPassword" class="form-control" 
                                       placeholder="Enter new password" required minlength="6">
                            </div>
                            
                            <div class="form-group">
                                <label for="confirmPassword">Confirm New Password <span class="required">*</span></label>
                                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                                       placeholder="Confirm new password" required>
                            </div>
                            
                            <div class="form-actions">
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-save"></i> Update Password
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <script src="../desigen/script.js"></script>
</body>
</html>
