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
    
    // Get messages from URL
    if (request.getParameter("message") != null) {
        successMessage = request.getParameter("message");
    }
    if (request.getParameter("error") != null) {
        errorMessage = request.getParameter("error");
    }
    
    // Initialize customers list
    java.util.List<Object[]> customers = new java.util.ArrayList<>();
    
    try {
        conn = getDBConnection();
        
        String sql = "SELECT customer_id, first_name, last_name, email, phone_number FROM customer ORDER BY customer_id DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        while (rs.next()) {
            customers.add(new Object[]{
                rs.getInt("customer_id"),
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("email"),
                rs.getString("phone_number")
            });
        }
        
    } catch (Exception e) {
        errorMessage = "Error loading customers: " + e.getMessage();
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
    <title>Customer Management - Insurance Management System</title>
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
                        <span>Customers</span>
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
                        <h1>Customer Management</h1>
                        <p>View and manage all registered customers</p>
                    </div>
                    <a href="add_update_customer.jsp" class="btn btn-primary">
                        <i class="fas fa-user-plus"></i> Add Customer
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
                
                <!-- Search -->
                <div class="card" style="margin-bottom: 1.5rem;">
                    <div class="card-body">
                        <div class="input-icon" style="max-width: 400px;">
                            <i class="fas fa-search"></i>
                            <input type="text" id="search-input" class="form-control" 
                                   placeholder="Search customers..." onkeyup="searchTable()">
                        </div>
                    </div>
                </div>
                
                <!-- Customers Table -->
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-users"></i> All Customers</h3>
                        <span class="badge badge-primary"><%= customers.size() %> Total</span>
                    </div>
                    <div class="card-body">
                        <div class="table-container">
                            <table id="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>First Name</th>
                                        <th>Last Name</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (customers.isEmpty()) { %>
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <i class="fas fa-users"></i>
                                                    <h3>No Customers Found</h3>
                                                    <p>Start by adding your first customer</p>
                                                    <a href="add_update_customer.jsp" class="btn btn-primary">
                                                        <i class="fas fa-user-plus"></i> Add Customer
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } else { 
                                        for (Object[] customer : customers) {
                                            String fn = customer[1] != null ? customer[1].toString() : "";
                                            String ln = customer[2] != null ? customer[2].toString() : "";
                                            String safeName = fn.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;") + " " + ln.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                                    %>
                                            <tr data-customer-id="<%= customer[0] %>">
                                                <td><%= customer[0] %></td>
                                                <td><%= customer[1] %></td>
                                                <td><%= customer[2] %></td>
                                                <td><%= customer[3] != null ? customer[3] : "N/A" %></td>
                                                <td><%= customer[4] != null ? customer[4] : "N/A" %></td>
                                                <td>
                                                    <div class="table-actions">
                                                        <a href="add_update_customer.jsp?id=<%= customer[0] %>" 
                                                           class="btn-action btn-edit" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <a href="delete_customer.jsp?id=<%= customer[0] %>" 
                                                           class="btn-action btn-delete btn-delete-ajax" title="Delete"
                                                           data-customer-name="<%= safeName %>" data-customer-id="<%= customer[0] %>">
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
        function searchTable() {
            const input = document.getElementById('search-input');
            const filter = input ? input.value.toLowerCase() : '';
            const table = document.getElementById('data-table');
            if (!table) return;
            const tbody = table.getElementsByTagName('tbody')[0];
            if (!tbody) return;
            const rows = tbody.getElementsByTagName('tr');
            for (let i = 0; i < rows.length; i++) {
                const cells = rows[i].getElementsByTagName('td');
                if (cells.length < 2) continue;
                let found = false;
                for (let j = 0; j < cells.length - 1; j++) {
                    const cellText = (cells[j].textContent || cells[j].innerText || '').toLowerCase();
                    if (cellText.indexOf(filter) > -1) { found = true; break; }
                }
                rows[i].style.display = found ? '' : 'none';
            }
        }
        function confirmDeleteCustomer(name) {
            return confirm('Are you sure you want to delete customer: ' + name + '? This action cannot be undone.');
        }
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('data-table') && document.getElementById('data-table').addEventListener('click', function(e) {
                var a = e.target.closest('a.btn-delete-ajax');
                if (!a) return;
                e.preventDefault();
                var name = a.getAttribute('data-customer-name') || 'this customer';
                var id = a.getAttribute('data-customer-id');
                if (!confirmDeleteCustomer(name)) return;
                var row = a.closest('tr');
                var badge = document.querySelector('.card-header .badge');
                fetch('delete_customer.jsp?id=' + encodeURIComponent(id) + '&ajax=1')
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (data.success) {
                            row.style.transition = 'opacity 0.3s';
                            row.style.opacity = '0';
                                setTimeout(function() {
                                row.remove();
                                var tbody = document.querySelector('#data-table tbody');
                                if (badge) {
                                    var n = parseInt(badge.textContent, 10);
                                    if (!isNaN(n)) badge.textContent = (n - 1) + ' Total';
                                }
                                if (tbody && tbody.querySelectorAll('tr').length === 0) {
                                    var emptyRow = '<tr><td colspan="6"><div class="empty-state"><i class="fas fa-users"></i><h3>No Customers Found</h3><p>Start by adding your first customer</p><a href="add_update_customer.jsp" class="btn btn-primary"><i class="fas fa-user-plus"></i> Add Customer</a></div></td></tr>';
                                    tbody.innerHTML = emptyRow;
                                }
                                showAlert('success', data.message);
                            }, 300);
                        } else {
                            showAlert('danger', data.error || 'Delete failed');
                        }
                    })
                    .catch(function() { showAlert('danger', 'Network error. Please try again.'); });
            });
        });
    </script>
</body>
</html>
