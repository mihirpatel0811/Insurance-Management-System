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
    
    int claimId = 0;
    int customerId = 0;
    int policyId = 0;
    String claimDate = "";
    double claimAmount = 0;
    String status = "Pending";
    String pageTitle = "Add New Claim";
    String btnText = "Add Claim";
    
    // Load customers and policies for dropdown
    java.util.List<Object[]> customers = new java.util.ArrayList<>();
    java.util.List<Object[]> policies = new java.util.ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = getDBConnection();
        
        // Load customers
        pstmt = conn.prepareStatement("SELECT customer_id, first_name, last_name FROM customer ORDER BY first_name, last_name");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            customers.add(new Object[]{rs.getInt("customer_id"), rs.getString("first_name") + " " + rs.getString("last_name")});
        }
        rs.close();
        pstmt.close();
        
        // Load policies
        pstmt = conn.prepareStatement("SELECT policy_id, policy_name FROM insurance_policy ORDER BY policy_name");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            policies.add(new Object[]{rs.getInt("policy_id"), rs.getString("policy_name")});
        }
        rs.close();
        
        // Load claim data if editing
        if (request.getParameter("id") != null) {
            claimId = Integer.parseInt(request.getParameter("id"));
            pageTitle = "Edit Claim";
            btnText = "Update Claim";
            
            pstmt = conn.prepareStatement("SELECT * FROM claim WHERE claim_id = ?");
            pstmt.setInt(1, claimId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                customerId = rs.getInt("customer_id");
                policyId = rs.getInt("policy_id");
                claimDate = rs.getDate("claim_date").toString();
                claimAmount = rs.getDouble("claim_amount");
                status = rs.getString("status");
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
        String customerIdParam = request.getParameter("customerId");
        String policyIdParam = request.getParameter("policyId");
        claimDate = request.getParameter("claimDate");
        String claimAmountParam = request.getParameter("claimAmount");
        status = request.getParameter("status");

        customerId = (customerIdParam == null || customerIdParam.trim().isEmpty()) ? 0 : Integer.parseInt(customerIdParam);
        policyId = (policyIdParam == null || policyIdParam.trim().isEmpty()) ? 0 : Integer.parseInt(policyIdParam);
        claimAmount = (claimAmountParam == null || claimAmountParam.trim().isEmpty()) ? 0 : Double.parseDouble(claimAmountParam);
        
        if (customerId == 0) {
            errorMessage = "Please select a customer";
        } else if (policyId == 0) {
            errorMessage = "Please select a policy";
        } else if (claimDate == null || claimDate.trim().isEmpty()) {
            errorMessage = "Claim date is required";
        } else {
            conn = null;
            pstmt = null;
            
            try {
                conn = getDBConnection();
                
                if (claimId > 0) {
                    String sql = "UPDATE claim SET customer_id = ?, policy_id = ?, claim_date = ?, claim_amount = ?, status = ? WHERE claim_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, customerId);
                    pstmt.setInt(2, policyId);
                    pstmt.setString(3, claimDate);
                    pstmt.setDouble(4, claimAmount);
                    pstmt.setString(5, status);
                    pstmt.setInt(6, claimId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Claim updated successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                } else {
                    String sql = "INSERT INTO claim (customer_id, policy_id, claim_date, claim_amount, status) VALUES (?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, customerId);
                    pstmt.setInt(2, policyId);
                    pstmt.setString(3, claimDate);
                    pstmt.setDouble(4, claimAmount);
                    pstmt.setString(5, status);
                    pstmt.executeUpdate();
                    
                    successMessage = "Claim added successfully!";
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
                <a href="../Insurance_Policy/dashboard_insur_policy.jsp" class="menu-item">
                    <i class="fas fa-file-contract"></i>
                    <span>Policies</span>
                </a>
                <a href="../Customer_Policy/dashboard_cust_policy.jsp" class="menu-item">
                    <i class="fas fa-handshake"></i>
                    <span>Customer Policies</span>
                </a>
                <a href="dashboard_claim.jsp" class="menu-item active">
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
                    <h2>Claims</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="../Main/main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="dashboard_claim.jsp">Claims</a>
                        <i class="fas fa-chevron-right"></i>
                        <span><%= claimId > 0 ? "Edit" : "Add" %></span>
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
                        <p><%= claimId > 0 ? "Update claim information" : "Add a new insurance claim" %></p>
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
                        <h3><i class="fas fa-clipboard-list"></i> Claim Information</h3>
                    </div>
                    <div class="card-body">
                        <form action="add_update_claim.jsp<%= claimId > 0 ? "?id=" + claimId : "" %>" method="POST" class="needs-validation">
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="customerId">Customer <span class="required">*</span></label>
                                    <select id="customerId" name="customerId" class="form-control" required>
                                        <option value="">-- Select Customer --</option>
                                        <% if (customers.isEmpty()) { %>
                                            <option value="" disabled>No customers found. Please add a customer first.</option>
                                        <% } else { 
                                            for (Object[] customer : customers) { %>
                                                <option value="<%= customer[0] %>" <%= customerId == (Integer)customer[0] ? "selected" : "" %>>
                                                    <%= customer[1] %>
                                                </option>
                                            <% } 
                                        } %>
                                    </select>
                                    <% if (customers.isEmpty()) { %>
                                        <div style="margin-top: 0.5rem;">
                                            <a class="btn btn-secondary" style="padding: 0.5rem 0.75rem;" href="../Customer/add_update_customer.jsp">
                                                <i class="fas fa-plus-circle"></i> Add Customer
                                            </a>
                                        </div>
                                    <% } %>
                                </div>
                                
                                <div class="form-group">
                                    <label for="policyId">Policy <span class="required">*</span></label>
                                    <select id="policyId" name="policyId" class="form-control" required>
                                        <option value="">-- Select Policy --</option>
                                        <% if (policies.isEmpty()) { %>
                                            <option value="" disabled>No policies found. Please add a policy first.</option>
                                        <% } else { 
                                            for (Object[] policy : policies) { %>
                                                <option value="<%= policy[0] %>" <%= policyId == (Integer)policy[0] ? "selected" : "" %>>
                                                    <%= policy[1] %>
                                                </option>
                                            <% } 
                                        } %>
                                    </select>
                                    <!-- <% if (policies.isEmpty()) { %>
                                        <div style="margin-top: 0.5rem;">
                                            <a class="btn btn-secondary" style="padding: 0.5rem 0.75rem;" href="../Insurance_Policy/add_update_insur_policy.jsp">
                                                <i class="fas fa-plus-circle"></i> Add Policy
                                            </a>
                                        </div>
                                    <% } %> -->
                                </div>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="claimDate">Claim Date <span class="required">*</span></label>
                                    <input type="date" id="claimDate" name="claimDate" class="form-control" 
                                           value="<%= claimDate %>" required>
                                </div>
                                
                                <div class="form-group">
                                    <label for="claimAmount">Claim Amount (₹) <span class="required">*</span></label>
                                    <input type="number" id="claimAmount" name="claimAmount" class="form-control" 
                                           value="<%= claimAmount %>" placeholder="Enter claim amount" min="0" step="0.01" required>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="status">Status <span class="required">*</span></label>
                                <select id="status" name="status" class="form-control" required>
                                    <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                                    <option value="Approved" <%= "Approved".equals(status) ? "selected" : "" %>>Approved</option>
                                    <option value="Rejected" <%= "Rejected".equals(status) ? "selected" : "" %>>Rejected</option>
                                </select>
                            </div>
                            
                            <div class="form-actions">
                                <a href="dashboard_claim.jsp" class="btn btn-secondary">
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
