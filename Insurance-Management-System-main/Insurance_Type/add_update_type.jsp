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
    
    // Check if editing
    int typeId = 0;
    String typeName = "";
    String pageTitle = "Add New Insurance Type";
    String btnText = "Add Type";
    
    // Get type ID if editing
    if (request.getParameter("id") != null) {
        typeId = Integer.parseInt(request.getParameter("id"));
        pageTitle = "Edit Insurance Type";
        btnText = "Update Type";
        
        // Database connection to get type data
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getDBConnection();
            
            String sql = "SELECT * FROM insurance_type WHERE type_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, typeId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                typeName = rs.getString("type_name");
            }
            
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
    
    String errorMessage = "";
    String successMessage = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        typeName = request.getParameter("typeName");
        
        // Validation
        if (typeName == null || typeName.trim().isEmpty()) {
            errorMessage = "Type name is required";
        } else {
            // Database operation
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = getDBConnection();
                
                if (typeId > 0) {
                    // Update existing type
                    String sql = "UPDATE insurance_type SET type_name = ? WHERE type_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, typeName);
                    pstmt.setInt(2, typeId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Insurance type updated successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                } else {
                    // Insert new type
                    String sql = "INSERT INTO insurance_type (type_name) VALUES (?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, typeName);
                    pstmt.executeUpdate();
                    
                    successMessage = "Insurance type added successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                }
                
            } catch (Exception e) {
                errorMessage = "Error: " + e.getMessage();
            } finally {
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
    <title><%= pageTitle %> - Insurance Management System</title>
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
                <a href="../Main/main.jsp" class="menu-item">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="../Main/admin_profile.jsp" class="menu-item">
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
                <a href="dashboard_type.jsp" class="menu-item active">
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
                <a href="../Main/logout.jsp" class="menu-item">
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
                    <h2>Insurance Types</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="../Main/main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="dashboard_type.jsp">Types</a>
                        <i class="fas fa-chevron-right"></i>
                        <span><%= typeId > 0 ? "Edit" : "Add" %></span>
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
                    <a href="../Main/logout.jsp" class="btn-logout">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </header>
            
            <!-- Content Area -->
            <div class="content-area">
                <div class="page-header">
                    <div class="page-title">
                        <h1><%= pageTitle %></h1>
                        <p><%= typeId > 0 ? "Update insurance type information" : "Add a new insurance type to the system" %></p>
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
                
                <!-- Type Form -->
                <div class="card form-card">
                    <div class="card-header">
                        <h3><i class="fas fa-tag"></i> Insurance Type Information</h3>
                    </div>
                    <div class="card-body">
                        <form action="add_update_type.jsp<%= typeId > 0 ? "?id=" + typeId : "" %>" method="POST" class="needs-validation">
                            <div class="form-group">
                                <label for="typeName">Type Name <span class="required">*</span></label>
                                <input type="text" id="typeName" name="typeName" class="form-control" 
                                       value="<%= typeName %>" placeholder="e.g., Life Insurance, Health Insurance, Vehicle Insurance" required>
                                <small style="color: var(--gray);">Enter a descriptive name for the insurance type</small>
                            </div>
                            
                            <div class="form-actions">
                                <a href="dashboard_type.jsp" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-save"></i> <%= btnText %>
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
