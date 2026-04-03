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
    
    // Database connection
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    // Initialize counts
    int customerCount = 0;
    int policyCount = 0;
    int companyCount = 0;
    int claimCount = 0;
    int activePolicies = 0;
    int pendingClaims = 0;
    
    try {
        conn = getDBConnection();
        
        // Get customer count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM customer");
        rs = pstmt.executeQuery();
        if (rs.next()) customerCount = rs.getInt(1);
        rs.close();
        
        // Get policy count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM insurance_policy");
        rs = pstmt.executeQuery();
        if (rs.next()) policyCount = rs.getInt(1);
        rs.close();
        
        // Get company count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM insurance_company");
        rs = pstmt.executeQuery();
        if (rs.next()) companyCount = rs.getInt(1);
        rs.close();
        
        // Get claim count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM claim");
        rs = pstmt.executeQuery();
        if (rs.next()) claimCount = rs.getInt(1);
        rs.close();
        
        // Get active policies count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM customer_policy WHERE end_date >= CURDATE()");
        rs = pstmt.executeQuery();
        if (rs.next()) activePolicies = rs.getInt(1);
        rs.close();
        
        // Get pending claims count
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM claim WHERE status = 'Pending'");
        rs = pstmt.executeQuery();
        if (rs.next()) pendingClaims = rs.getInt(1);
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Insurance Management System</title>
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
                <a href="main.jsp" class="menu-item active">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="admin_profile.jsp" class="menu-item">
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
                    <h2>Dashboard</h2>
                    <div class="breadcrumb">
                        <a href="../index.html">Home</a>
                        <i class="fas fa-chevron-right"></i>
                        <span>Dashboard</span>
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
                <!-- Welcome Message -->
                <div class="page-header">
                    <div class="page-title">
                        <h1>Welcome, <%= adminUser %>!</h1>
                        <p>Here's an overview of your insurance management system</p>
                    </div>
                </div>
                
                <!-- Stats Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon primary">
                            <i class="fas fa-users"></i>
                        </div>
                            <div class="stat-info">
                                <h4 id="customerCount" class="stat-number" data-target="<%= customerCount %>"><%= customerCount %></h4>
                                <p>Total Customers</p>
                            </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon success">
                            <i class="fas fa-file-contract"></i>
                        </div>
                        <div class="stat-info">
                            <h4 id="policyCount" class="stat-number" data-target="<%= policyCount %>"><%= policyCount %></h4>
                            <p>Insurance Policies</p>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon warning">
                            <i class="fas fa-building-columns"></i>
                        </div>
                        <div class="stat-info">
                            <h4 id="companyCount" class="stat-number" data-target="<%= companyCount %>"><%= companyCount %></h4>
                            <p>Companies</p>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon danger">
                            <i class="fas fa-clipboard-check"></i>
                        </div>
                        <div class="stat-info">
                            <h4 id="claimCount" class="stat-number" data-target="<%= claimCount %>"><%= claimCount %></h4>
                            <p>Total Claims</p>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon info">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-info">
                            <h4 id="activePolicies" class="stat-number" data-target="<%= activePolicies %>"><%= activePolicies %></h4>
                            <p>Active Policies</p>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon primary">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="stat-info">
                            <h4 id="pendingClaims" class="stat-number" data-target="<%= pendingClaims %>"><%= pendingClaims %></h4>
                            <p>Pending Claims</p>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-bolt"></i> Quick Actions</h3>
                    </div>
                    <div class="card-body">
                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                            <a href="../Customer/add_update_customer.jsp" class="btn btn-primary" style="justify-content: center;">
                                <i class="fas fa-user-plus"></i> Add Customer
                            </a>
                            <a href="../Insurance_Policy/add_update_insur_policy.jsp" class="btn btn-success" style="justify-content: center;">
                                <i class="fas fa-plus-circle"></i> Add Policy
                            </a>
                            <a href="../Claim/add_update_claim.jsp" class="btn btn-secondary" style="justify-content: center;">
                                <i class="fas fa-clipboard-list"></i> New Claim
                            </a>
                            <a href="../Insurance_Company/add_update_company.jsp" class="btn btn-secondary" style="justify-content: center;">
                                <i class="fas fa-building"></i> Add Company
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <script src="../desigen/script.js"></script>
    <script>
        (function(){
            let last = 0;
            function checkUpdate(){
                fetch('../lastUpdate.jsp')
                    .then(r=>r.text())
                    .then(t=>{
                        const ts = parseInt(t||'0');
                        if (ts && ts !== last){
                            last = ts;
                            fetch('../counts.jsp')
                                .then(r=>r.json())
                                .then(data=>{
                                    document.getElementById('customerCount').textContent = data.customerCount;
                                    document.getElementById('policyCount').textContent = data.policyCount;
                                    document.getElementById('companyCount').textContent = data.companyCount;
                                    document.getElementById('claimCount').textContent = data.claimCount;
                                    document.getElementById('activePolicies').textContent = data.activePolicies;
                                    document.getElementById('pendingClaims').textContent = data.pendingClaims;
                                }).catch(()=>{});
                        }
                    }).catch(()=>{});
            }
            // poll every 2 seconds
            setInterval(checkUpdate, 2000);
            // initial check
            checkUpdate();
        })();
    </script>
</body>
</html>
