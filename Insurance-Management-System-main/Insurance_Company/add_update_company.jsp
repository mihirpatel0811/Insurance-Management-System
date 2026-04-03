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
    
    int companyId = 0;
    String companyName = "";
    String contactInfo = "";
    String pageTitle = "Add New Company";
    String btnText = "Add Company";
    
    if (request.getParameter("id") != null) {
        companyId = Integer.parseInt(request.getParameter("id"));
        pageTitle = "Edit Company";
        btnText = "Update Company";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getDBConnection();
            
            String sql = "SELECT * FROM insurance_company WHERE company_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, companyId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                companyName = rs.getString("company_name");
                contactInfo = rs.getString("contact_info");
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
    
    if ("POST".equals(request.getMethod())) {
        companyName = request.getParameter("companyName");
        contactInfo = request.getParameter("contactInfo");
        
        if (companyName == null || companyName.trim().isEmpty()) {
            errorMessage = "Company name is required";
        } else {
            Connection conn = null;
            PreparedStatement pstmt = null;
            
                try {
                    conn = getDBConnection();
                
                if (companyId > 0) {
                    String sql = "UPDATE insurance_company SET company_name = ?, contact_info = ? WHERE company_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, companyName);
                    pstmt.setString(2, contactInfo);
                    pstmt.setInt(3, companyId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Company updated successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                } else {
                    String sql = "INSERT INTO insurance_company (company_name, contact_info) VALUES (?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, companyName);
                    pstmt.setString(2, contactInfo);
                    pstmt.executeUpdate();
                    
                    successMessage = "Company added successfully!";
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
                <a href="dashboard_company.jsp" class="menu-item active">
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
                <a href="../Main/logout.jsp" class="menu-item">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </nav>
        </aside>
        
        <main class="main-content">
            <header class="top-bar">
                <div class="top-bar-left">
                    <h2>Insurance Companies</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="../Main/main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="dashboard_company.jsp">Companies</a>
                        <i class="fas fa-chevron-right"></i>
                        <span><%= companyId > 0 ? "Edit" : "Add" %></span>
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
            
            <div class="content-area">
                <div class="page-header">
                    <div class="page-title">
                        <h1><%= pageTitle %></h1>
                        <p><%= companyId > 0 ? "Update company information" : "Add a new insurance company to the system" %></p>
                    </div>
                </div>
                
                <% if (!errorMessage.isEmpty()) { %> <div class="alert alert-danger">
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
                
                <div class="card form-card">
                    <div class="card-header">
                        <h3><i class="fas fa-building"></i> Company Information</h3>
                    </div>
                    <div class="card-body">
                        <form action="add_update_company.jsp<%= companyId > 0 ? "?id=" + companyId : "" %>" method="POST" class="needs-validation">
                            <div class="form-group">
                                <label for="companyName">Company Name <span class="required">*</span></label>
                                <input type="text" id="companyName" name="companyName" class="form-control" 
                                       value="<%= companyName %>" placeholder="Enter company name" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="contactInfo">Contact Information</label>
                                <textarea id="contactInfo" name="contactInfo" class="form-control" 
                                          placeholder="Enter contact details (address, phone, email)"><%= contactInfo %></textarea>
                            </div>
                            
                            <div class="form-actions">
                                <a href="dashboard_company.jsp" class="btn btn-secondary">
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
