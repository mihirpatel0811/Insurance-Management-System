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
    
    // Database connection
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String errorMessage = "";
    String successMessage = "";
    
    if (request.getParameter("message") != null) {
        successMessage = request.getParameter("message");
    }
    if (request.getParameter("error") != null) {
        errorMessage = request.getParameter("error");
    }
    
    java.util.List<Object[]> claims = new java.util.ArrayList<>();
    
    try {
        conn = getDBConnection();
        
        String sql = "SELECT cl.claim_id, cl.claim_date, cl.claim_amount, cl.status, " +
                     "c.first_name, c.last_name, p.policy_name " +
                     "FROM claim cl " +
                     "LEFT JOIN customer c ON cl.customer_id = c.customer_id " +
                     "LEFT JOIN insurance_policy p ON cl.policy_id = p.policy_id " +
                     "ORDER BY cl.claim_id DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            claims.add(new Object[]{
                rs.getInt("claim_id"),
                rs.getString("first_name") + " " + rs.getString("last_name"),
                rs.getString("policy_name"),
                rs.getDate("claim_date"),
                rs.getDouble("claim_amount"),
                rs.getString("status")
            });
        }
        
    } catch (Exception e) {
        errorMessage = "Error loading claims: " + e.getMessage();
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
    <title>Claims - Insurance Management System</title>
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
                        <span>Claims</span>
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
                        <h1>Claims Management</h1>
                        <p>Manage all insurance claims</p>
                    </div>
                    <a href="add_update_claim.jsp" class="btn btn-primary">
                        <i class="fas fa-clipboard-list"></i> New Claim
                    </a>
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
                
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-clipboard-check"></i> All Claims</h3>
                        <span class="badge badge-primary"><%= claims.size() %> Total</span>
                    </div>
                    <div class="card-body">
                        <div class="table-container">
                            <table id="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Customer</th>
                                        <th>Policy</th>
                                        <th>Claim Date</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (claims.isEmpty()) { %>
                                        <tr>
                                            <td colspan="7">
                                                <div class="empty-state">
                                                    <i class="fas fa-clipboard-check"></i>
                                                    <h3>No Claims Found</h3>
                                                    <p>Start by adding your first claim</p>
                                                    <a href="add_update_claim.jsp" class="btn btn-primary">
                                                        <i class="fas fa-clipboard-list"></i> New Claim
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } else { 
                                        for (Object[] claim : claims) { 
                                            String status = (String) claim[5];
                                    %>
                                            <tr>
                                                <td><%= claim[0] %></td>
                                                <td><strong><%= claim[1] %></strong></td>
                                                <td><%= claim[2] %></td>
                                                <td><%= claim[3] %></td>
                                                <td>₹<%= String.format("%.2f", claim[4]) %></td>
                                                <td>
                                                    <% if ("Pending".equals(status)) { %>
                                                        <span class="badge badge-warning">Pending</span>
                                                    <% } else if ("Approved".equals(status)) { %>
                                                        <span class="badge badge-success">Approved</span>
                                                    <% } else if ("Rejected".equals(status)) { %>
                                                        <span class="badge badge-danger">Rejected</span>
                                                    <% } else { %>
                                                        <span class="badge badge-info"><%= status %></span>
                                                    <% } %>
                                                </td>
                                                <td>
                                                    <div class="table-actions">
                                                        <a href="add_update_claim.jsp?id=<%= claim[0] %>" 
                                                           class="btn-action btn-edit" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <a href="delete_claim.jsp?id=<%= claim[0] %>" 
                                                           class="btn-action btn-delete" title="Delete"
                                                           onclick="return confirmDelete();">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } 
                                    } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <script src="../desigen/script.js"></script>
    <script>
        function confirmDelete() {
            return confirm('Are you sure you want to delete this claim?');
        }
    </script>
</body>
</html>
