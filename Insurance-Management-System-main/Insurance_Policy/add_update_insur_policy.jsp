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
    
    int policyId = 0;
    String policyName = "";
    int companyId = 0;
    int typeId = 0;
    double coverageAmount = 0;
    double premium = 0;
    String pageTitle = "Add New Policy";
    String btnText = "Add Policy";
    
    // Load companies and types for dropdown
    java.util.List<Object[]> companies = new java.util.ArrayList<>();
    java.util.List<Object[]> types = new java.util.ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = getDBConnection();
        
        // Load companies
        pstmt = conn.prepareStatement("SELECT company_id, company_name FROM insurance_company ORDER BY company_name");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            companies.add(new Object[]{rs.getInt("company_id"), rs.getString("company_name")});
        }
        rs.close();
        pstmt.close();
        
        // Load types
        pstmt = conn.prepareStatement("SELECT type_id, type_name FROM insurance_type ORDER BY type_name");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            types.add(new Object[]{rs.getInt("type_id"), rs.getString("type_name")});
        }
        rs.close();
        
        // Load policy data if editing
        if (request.getParameter("id") != null) {
            policyId = Integer.parseInt(request.getParameter("id"));
            pageTitle = "Edit Policy";
            btnText = "Update Policy";
            
            pstmt = conn.prepareStatement("SELECT * FROM insurance_policy WHERE policy_id = ?");
            pstmt.setInt(1, policyId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                policyName = rs.getString("policy_name");
                companyId = rs.getInt("company_id");
                typeId = rs.getInt("type_id");
                coverageAmount = rs.getDouble("coverage_amount");
                premium = rs.getDouble("premium");
            }
        }
        
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
    
    String errorMessage = "";
    String successMessage = "";
    
    if ("POST".equals(request.getMethod())) {
        policyName = request.getParameter("policyName");
        String companyIdParam = request.getParameter("companyId");
        String typeIdParam = request.getParameter("typeId");
        String coverageAmountParam = request.getParameter("coverageAmount");
        String premiumParam = request.getParameter("premium");

        companyId = (companyIdParam == null || companyIdParam.trim().isEmpty()) ? 0 : Integer.parseInt(companyIdParam);
        typeId = (typeIdParam == null || typeIdParam.trim().isEmpty()) ? 0 : Integer.parseInt(typeIdParam);
        coverageAmount = (coverageAmountParam == null || coverageAmountParam.trim().isEmpty()) ? 0 : Double.parseDouble(coverageAmountParam);
        premium = (premiumParam == null || premiumParam.trim().isEmpty()) ? 0 : Double.parseDouble(premiumParam);
        
        if (policyName == null || policyName.trim().isEmpty()) {
            errorMessage = "Policy name is required";
        } else if (companyId == 0) {
            errorMessage = "Please select a company";
        } else if (typeId == 0) {
            errorMessage = "Please select an insurance type";
        } else {
            conn = null;
            pstmt = null;
            
                try {
                conn = getDBConnection();
                
                if (policyId > 0) {
                    String sql = "UPDATE insurance_policy SET policy_name = ?, company_id = ?, type_id = ?, coverage_amount = ?, premium = ? WHERE policy_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, policyName);
                    pstmt.setInt(2, companyId);
                    pstmt.setInt(3, typeId);
                    pstmt.setDouble(4, coverageAmount);
                    pstmt.setDouble(5, premium);
                    pstmt.setInt(6, policyId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Policy updated successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                } else {
                    String sql = "INSERT INTO insurance_policy (policy_name, company_id, type_id, coverage_amount, premium) VALUES (?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, policyName);
                    pstmt.setInt(2, companyId);
                    pstmt.setInt(3, typeId);
                    pstmt.setDouble(4, coverageAmount);
                    pstmt.setDouble(5, premium);
                    pstmt.executeUpdate();
                    
                    successMessage = "Policy added successfully!";
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
                <a href="../Insurance_Company/dashboard_company.jsp" class="menu-item">
                    <i class="fas fa-building-columns"></i>
                    <span>Companies</span>
                </a>
                <a href="../Insurance_Type/dashboard_type.jsp" class="menu-item">
                    <i class="fas fa-tags"></i>
                    <span>Insurance Types</span>
                </a>
                <a href="dashboard_insur_policy.jsp" class="menu-item active">
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
                    <h2>Insurance Policies</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="../Main/main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="dashboard_insur_policy.jsp">Policies</a>
                        <i class="fas fa-chevron-right"></i>
                        <span><%= policyId > 0 ? "Edit" : "Add" %></span>
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
                        <p><%= policyId > 0 ? "Update policy information" : "Add a new insurance policy to the system" %></p>
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
                
                <div class="card form-card">
                    <div class="card-header">
                        <h3><i class="fas fa-file-contract"></i> Policy Information</h3>
                    </div>
                    <div class="card-body">
                        <form action="add_update_insur_policy.jsp<%= policyId > 0 ? "?id=" + policyId : "" %>" method="POST" class="needs-validation">
                            <div class="form-group">
                                <label for="policyName">Policy Name <span class="required">*</span></label>
                                <input type="text" id="policyName" name="policyName" class="form-control" 
                                       value="<%= policyName %>" placeholder="Enter policy name" required>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="companyId">Insurance Company <span class="required">*</span></label>
                                    <select id="companyId" name="companyId" class="form-control" required>
                                        <option value="">-- Select Company --</option>
                                        <% if (companies.isEmpty()) { %>
                                            <option value="" disabled>No companies found. Please add a company first.</option>
                                        <% } else { 
                                            for (Object[] company : companies) { %>
                                                <option value="<%= company[0] %>" <%= companyId == (Integer)company[0] ? "selected" : "" %>>
                                                    <%= company[1] %>
                                                </option>
                                            <% } 
                                        } %>
                                    </select>
                                    <% if (companies.isEmpty()) { %>
                                        <div style="margin-top: 0.5rem;">
                                            <a class="btn btn-secondary" style="padding: 0.5rem 0.75rem;" href="../Insurance_Company/add_update_company.jsp">
                                                <i class="fas fa-plus-circle"></i> Add Company
                                            </a>
                                        </div>
                                    <% } %>
                                </div>
                                
                                <div class="form-group">
                                    <label for="typeId">Insurance Type <span class="required">*</span></label>
                                    <select id="typeId" name="typeId" class="form-control" required>
                                        <option value="">-- Select Type --</option>
                                        <% if (types.isEmpty()) { %>
                                            <option value="" disabled>No insurance types found. Please add an insurance type first.</option>
                                        <% } else { 
                                            for (Object[] type : types) { %>
                                                <option value="<%= type[0] %>" <%= typeId == (Integer)type[0] ? "selected" : "" %>>
                                                    <%= type[1] %>
                                                </option>
                                            <% } 
                                        } %>
                                    </select>
                                    <!-- <% if (types.isEmpty()) { %>
                                        <div style="margin-top: 0.5rem;">
                                            <a class="btn btn-secondary" style="padding: 0.5rem 0.75rem;" href="../Insurance_Type/add_update_type.jsp">
                                                <i class="fas fa-plus-circle"></i> Add Insurance Type
                                            </a>
                                        </div>
                                    <% } %> -->
                                </div>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="coverageAmount">Coverage Amount (₹) <span class="required">*</span></label>
                                    <input type="number" id="coverageAmount" name="coverageAmount" class="form-control" 
                                           value="<%= coverageAmount %>" placeholder="Enter coverage amount" min="0" step="0.01" required>
                                </div>
                                
                                <div class="form-group">
                                    <label for="premium">Premium (₹) <span class="required">*</span></label>
                                    <input type="number" id="premium" name="premium" class="form-control" 
                                           value="<%= premium %>" placeholder="Enter premium amount" min="0" step="0.01" required>
                                </div>
                            </div>
                            
                            <div class="form-actions">
                                <a href="dashboard_insur_policy.jsp" class="btn btn-secondary">
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
