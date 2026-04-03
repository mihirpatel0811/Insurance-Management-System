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
    int customerId = 0;
    String firstName = "";
    String lastName = "";
    String email = "";
    String phoneNumber = "";
    String pageTitle = "Add New Customer";
    String btnText = "Add Customer";
    
    // Get customer ID if editing
    if (request.getParameter("id") != null) {
        customerId = Integer.parseInt(request.getParameter("id"));
        pageTitle = "Edit Customer";
        btnText = "Update Customer";
        
        // Database connection to get customer data
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getDBConnection();
            
            String sql = "SELECT * FROM customer WHERE customer_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                firstName = rs.getString("first_name");
                lastName = rs.getString("last_name");
                email = rs.getString("email");
                phoneNumber = rs.getString("phone_number");
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
        firstName = request.getParameter("firstName");
        lastName = request.getParameter("lastName");
        email = request.getParameter("email");
        phoneNumber = request.getParameter("phoneNumber");
        
        // Validation
        if (firstName == null || firstName.trim().isEmpty()) {
            errorMessage = "First name is required";
        } else if (lastName == null || lastName.trim().isEmpty()) {
            errorMessage = "Last name is required";
        } else {
            // Database operation
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = getDBConnection();
                
                if (customerId > 0) {
                    // Update existing customer
                    String sql = "UPDATE customer SET first_name = ?, last_name = ?, email = ?, phone_number = ? WHERE customer_id = ?";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, firstName);
                    pstmt.setString(2, lastName);
                    pstmt.setString(3, email);
                    pstmt.setString(4, phoneNumber);
                    pstmt.setInt(5, customerId);
                    pstmt.executeUpdate();
                    
                    successMessage = "Customer updated successfully!";
                    application.setAttribute("lastUpdate", System.currentTimeMillis());
                } else {
                    // Insert new customer
                    String sql = "INSERT INTO customer (first_name, last_name, email, phone_number) VALUES (?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, firstName);
                    pstmt.setString(2, lastName);
                    pstmt.setString(3, email);
                    pstmt.setString(4, phoneNumber);
                    pstmt.executeUpdate();
                    
                    successMessage = "Customer added successfully!";
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

    if ("POST".equals(request.getMethod()) && "1".equals(request.getParameter("ajax"))) {
        response.setContentType("application/json");
        if (!errorMessage.isEmpty()) {
            out.print("{\"success\":false,\"error\":\"" + errorMessage.replace("\\", "\\\\").replace("\"", "\\\"") + "\"}");
        } else {
            out.print("{\"success\":true,\"message\":\"" + successMessage.replace("\\", "\\\\").replace("\"", "\\\"") + "\"}");
        }
        return;
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
                <a href="dashboard_customer.jsp" class="menu-item active">
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
                    <h2>Customers</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="../Main/main.jsp">Dashboard</a>
                        <i class="fas fa-chevron-right"></i>
                        <a href="dashboard_customer.jsp">Customers</a>
                        <i class="fas fa-chevron-right"></i>
                        <span><%= customerId > 0 ? "Edit" : "Add" %></span>
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
                        <p><%= customerId > 0 ? "Update customer information" : "Add a new customer to the system" %></p>
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
                
                <!-- Customer Form -->
                <div class="card form-card">
                    <div class="card-header">
                        <h3><i class="fas fa-user"></i> Customer Information</h3>
                    </div>
                    <div class="card-body">
                        <form id="customer-form" action="add_update_customer.jsp<%= customerId > 0 ? "?id=" + customerId : "" %>" method="POST" class="needs-validation">
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="firstName">First Name <span class="required">*</span></label>
                                    <input type="text" id="firstName" name="firstName" class="form-control" 
                                           value="<%= firstName %>" placeholder="Enter first name" required>
                                </div>
                                
                                <div class="form-group">
                                    <label for="lastName">Last Name <span class="required">*</span></label>
                                    <input type="text" id="lastName" name="lastName" class="form-control" 
                                           value="<%= lastName %>" placeholder="Enter last name" required>
                                </div>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="email">Email Address</label>
                                    <input type="email" id="email" name="email" class="form-control" 
                                           value="<%= email %>" placeholder="Enter email address">
                                </div>
                                
                                <div class="form-group">
                                    <label for="phoneNumber">Phone Number</label>
                                    <input type="tel" id="phoneNumber" name="phoneNumber" class="form-control" 
                                           value="<%= phoneNumber %>" placeholder="Enter phone number">
                                </div>
                            </div>
                            
                            <div class="form-actions">
                                <a href="dashboard_customer.jsp" class="btn btn-secondary">
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
    <script>
        document.getElementById('customer-form').addEventListener('submit', function(e) {
            if (!this.checkValidity()) return;
            e.preventDefault();
            var form = this;
            var submitBtn = form.querySelector('button[type="submit"]');
            var originalText = submitBtn ? submitBtn.innerHTML : '';
            if (submitBtn) { submitBtn.disabled = true; submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...'; }
            var fd = new FormData(form);
            fd.append('ajax', '1');
            fetch(form.action, { method: 'POST', body: fd })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (data.success) {
                        showAlert('success', data.message, 2000);
                        setTimeout(function() { window.location.href = 'dashboard_customer.jsp?message=' + encodeURIComponent(data.message); }, 800);
                    } else {
                        showAlert('danger', data.error || 'Error saving');
                        if (submitBtn) { submitBtn.disabled = false; submitBtn.innerHTML = originalText; }
                    }
                })
                .catch(function() {
                    showAlert('danger', 'Network error. Please try again.');
                    if (submitBtn) { submitBtn.disabled = false; submitBtn.innerHTML = originalText; }
                });
        });
    </script>
</body>
</html>
