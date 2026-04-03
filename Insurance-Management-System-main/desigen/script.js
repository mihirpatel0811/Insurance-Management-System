/* ========================================
   Insurance Management System - JavaScript
   MCA First Year Project
   ======================================== */

// DOM Ready Function
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all functionalities
    initAlerts();
    initFormValidation();
    initConfirmDialogs();
    initAnimations();
    initSidebar();
});

// ========================================
// Alert/Message Functions
// ========================================
function initAlerts() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        const closeBtn = alert.querySelector('.alert-close');
        if (closeBtn) {
            closeBtn.addEventListener('click', function() {
                alert.style.opacity = '0';
                alert.style.transform = 'translateX(20px)';
                setTimeout(() => {
                    alert.remove();
                }, 300);
            });
            
            // Auto dismiss after 5 seconds
            setTimeout(() => {
                if (alert.parentElement) {
                    alert.style.opacity = '0';
                    alert.style.transform = 'translateX(20px)';
                    setTimeout(() => {
                        alert.remove();
                    }, 300);
                }
            }, 5000);
        }
    });
}

function showAlert(type, message, duration = 5000) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type}`;
    
    const icons = {
        'success': 'fa-check-circle',
        'danger': 'fa-exclamation-circle',
        'warning': 'fa-exclamation-triangle',
        'info': 'fa-info-circle'
    };
    
    alertDiv.innerHTML = `
        <i class="fas ${icons[type] || 'fa-info-circle'}"></i>
        <span>${message}</span>
        <button class="alert-close" onclick="this.parentElement.remove()">
            <i class="fas fa-times"></i>
        </button>
    `;
    
    // Insert after page header or at top of content
    const contentArea = document.querySelector('.content-area') || document.body;
    const firstChild = contentArea.firstElementChild;
    if (firstChild) {
        contentArea.insertBefore(alertDiv, firstChild);
    } else {
        contentArea.appendChild(alertDiv);
    }
    
    // Auto dismiss
    if (duration > 0) {
        setTimeout(() => {
            if (alertDiv.parentElement) {
                alertDiv.style.opacity = '0';
                alertDiv.style.transform = 'translateX(20px)';
                setTimeout(() => {
                    alertDiv.remove();
                }, 300);
            }
        }, duration);
    }
}

// ========================================
// Form Validation
// ========================================
function initFormValidation() {
    const forms = document.querySelectorAll('.needs-validation');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        });
        
        // Real-time validation
        const inputs = form.querySelectorAll('.form-control');
        inputs.forEach(input => {
            input.addEventListener('blur', function() {
                validateField(this);
            });
            
            input.addEventListener('input', function() {
                if (this.classList.contains('is-invalid')) {
                    validateField(this);
                }
            });
        });
    });
}

function validateField(field) {
    const value = field.value.trim();
    let isValid = true;
    let message = '';
    
    // Required validation
    if (field.hasAttribute('required') && !value) {
        isValid = false;
        message = 'This field is required';
    }
    
    // Email validation
    if (field.type === 'email' && value) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
            isValid = false;
            message = 'Please enter a valid email address';
        }
    }
    
    // Phone validation
    if (field.type === 'tel' && value) {
        const phoneRegex = /^[\d\s\-\+\(\)]{10,}$/;
        if (!phoneRegex.test(value)) {
            isValid = false;
            message = 'Please enter a valid phone number';
        }
    }
    
    // Number validation
    if (field.type === 'number' && value) {
        const min = field.getAttribute('min');
        const max = field.getAttribute('max');
        
        if (min && parseFloat(value) < parseFloat(min)) {
            isValid = false;
            message = `Value must be at least ${min}`;
        }
        
        if (max && parseFloat(value) > parseFloat(max)) {
            isValid = false;
            message = `Value must not exceed ${max}`;
        }
    }
    
    // Date validation
    if (field.type === 'date' && value) {
        const startDate = field.getAttribute('data-start-date');
        const endDate = field.getAttribute('data-end-date');
        
        const fieldDate = new Date(value);
        
        if (startDate && fieldDate < new Date(startDate)) {
            isValid = false;
            message = `Date must be after ${startDate}`;
        }
        
        if (endDate && fieldDate > new Date(endDate)) {
            isValid = false;
            message = `Date must be before ${endDate}`;
        }
    }
    
    // Update field class
    if (!isValid) {
        field.classList.add('is-invalid');
        field.classList.remove('is-valid');
        
        // Show error message
        let errorDiv = field.parentElement.querySelector('.error-message');
        if (!errorDiv) {
            errorDiv = document.createElement('div');
            errorDiv.className = 'error-message';
            errorDiv.style.color = '#e74c3c';
            errorDiv.style.fontSize = '0.8rem';
            errorDiv.style.marginTop = '0.25rem';
            field.parentElement.appendChild(errorDiv);
        }
        errorDiv.textContent = message;
    } else {
        field.classList.remove('is-invalid');
        field.classList.add('is-valid');
        
        // Remove error message
        const errorDiv = field.parentElement.querySelector('.error-message');
        if (errorDiv) {
            errorDiv.remove();
        }
    }
    
    return isValid;
}

function validateForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return true;
    
    const inputs = form.querySelectorAll('.form-control');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    return isValid;
}

// ========================================
// Confirmation Dialogs
// ========================================
function initConfirmDialogs() {
    // Add confirm-click class to elements that need confirmation
    const confirmButtons = document.querySelectorAll('.confirm-click');
    
    confirmButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            const message = this.getAttribute('data-confirm-message') || 'Are you sure you want to proceed?';
            const originalText = this.innerHTML;
            
            if (!confirm(message)) {
                e.preventDefault();
                return false;
            }
            
            // Show loading state
            this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
            this.disabled = true;
            
            // If it's a form, let it submit
            // Otherwise, restore after a timeout
            setTimeout(() => {
                if (!this.type || this.type !== 'submit') {
                    this.innerHTML = originalText;
                    this.disabled = false;
                }
            }, 3000);
        });
    });
}

function confirmAction(message = 'Are you sure?') {
    return confirm(message);
}

function confirmDelete(itemName = 'this item') {
    return confirm(`Are you sure you want to delete ${itemName}? This action cannot be undone.`);
}

// ========================================
// Animations
// ========================================
function initAnimations() {
    // Add fade-in animation to cards
    const cards = document.querySelectorAll('.card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            card.style.transition = 'all 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 100);
    });
    
    // Add hover effects to table rows
    const tableRows = document.querySelectorAll('tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('mouseenter', function() {
            this.style.background = 'rgba(52, 152, 219, 0.05)';
        });
        
        row.addEventListener('mouseleave', function() {
            this.style.background = '';
        });
    });
}

// Animate stats numbers
function animateNumbers() {
    const statNumbers = document.querySelectorAll('.stat-number');
    
    statNumbers.forEach(stat => {
        const target = parseInt(stat.getAttribute('data-target'));
        const duration = 1500;
        const increment = target / (duration / 16);
        let current = 0;
        
        const updateNumber = () => {
            current += increment;
            if (current < target) {
                stat.textContent = Math.floor(current);
                requestAnimationFrame(updateNumber);
            } else {
                stat.textContent = target;
            }
        };
        
        // Start animation when in view
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    updateNumber();
                    observer.unobserve(entry.target);
                }
            });
        });
        
        observer.observe(stat);
    });
}

// ========================================
// Sidebar Functions
// ========================================
function initSidebar() {
    const menuItems = document.querySelectorAll('.menu-item');
    const currentPage = window.location.pathname.split('/').pop();
    
    menuItems.forEach(item => {
        const href = item.getAttribute('href');
        if (href === currentPage || (currentPage === '' && href === 'main.jsp')) {
            item.classList.add('active');
        }
        
        item.addEventListener('click', function(e) {
            // Remove active class from all items
            menuItems.forEach(mi => mi.classList.remove('active'));
            // Add active class to clicked item
            this.classList.add('active');
        });
    });
    
    // Mobile menu toggle
    const menuToggle = document.querySelector('.menu-toggle');
    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            const sidebar = document.querySelector('.sidebar');
            sidebar.classList.toggle('open');
        });
    }
}

function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    
    if (window.innerWidth > 768) {
        if (sidebar.style.width === '80px') {
            sidebar.style.width = '260px';
            mainContent.style.marginLeft = '260px';
        } else {
            sidebar.style.width = '80px';
            mainContent.style.marginLeft = '80px';
        }
    }
}

// ========================================
// Utility Functions
// ========================================

// Format currency (Indian Rupee)
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR'
    }).format(amount);
}

// Format date
function formatDate(dateString) {
    const options = { year: 'numeric', month: 'long', day: 'numeric' };
    return new Date(dateString).toLocaleDateString('en-US', options);
}

// Format date for input
function formatDateForInput(dateString) {
    const date = new Date(dateString);
    return date.toISOString().split('T')[0];
}

// Get URL parameter
function getUrlParameter(name) {
    const params = new URLSearchParams(window.location.search);
    return params.get(name);
}

// Set URL parameter
function setUrlParameter(name, value) {
    const url = new URL(window.location);
    url.searchParams.set(name, value);
    window.history.pushState({}, '', url);
}

// Redirect with message
function redirectWithMessage(url, type, message) {
    const separator = url.includes('?') ? '&' : '?';
    window.location.href = `${url}${separator}message=${encodeURIComponent(message)}&type=${type}`;
}

// Loading overlay
function showLoading() {
    const overlay = document.createElement('div');
    overlay.id = 'loading-overlay';
    overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    `;
    
    const spinner = document.createElement('div');
    spinner.innerHTML = '<i class="fas fa-spinner fa-spin fa-3x text-white"></i>';
    spinner.style.cssText = 'color: white; font-size: 3rem;';
    
    overlay.appendChild(spinner);
    document.body.appendChild(overlay);
}

function hideLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
        overlay.remove();
    }
}

// Export to CSV
function exportToCSV(filename = 'data.csv') {
    const table = document.querySelector('table');
    if (!table) return;
    
    let csv = [];
    const rows = table.querySelectorAll('tr');
    
    rows.forEach(row => {
        const cols = row.querySelectorAll('td, th');
        const rowData = [];
        
        cols.forEach(col => {
            // Skip action buttons
            if (!col.querySelector('.btn')) {
                rowData.push('"' + col.textContent.trim() + '"');
            }
        });
        
        csv.push(rowData.join(','));
    });
    
    const csvFile = new Blob([csv.join('\n')], { type: 'text/csv' });
    const downloadLink = document.createElement('a');
    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = 'none';
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

// ========================================
// Search Functionality
// ========================================
function initSearch(tableId = 'data-table', searchInputId = 'search-input') {
    const searchInput = document.getElementById(searchInputId);
    const table = document.getElementById(tableId);
    
    if (!searchInput || !table) return;
    
    searchInput.addEventListener('keyup', function() {
        const searchTerm = this.value.toLowerCase();
        const rows = table.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            row.style.display = text.includes(searchTerm) ? '' : 'none';
        });
    });
}

// ========================================
// Prompt Enhancement Feature
// ========================================

// Enhancement patterns and templates
const enhancementPatterns = {
    'claim': {
        keywords: ['claim', 'claims', 'file', 'submit', 'process'],
        templates: [
            'Please provide detailed information about: ',
            'For a comprehensive response regarding {topic}, consider: ',
            'To get accurate assistance with {topic}, please specify: '
        ],
        clarifications: [
            '- The type of insurance policy (health, vehicle, life, property)\n',
            '- Date of incident or when the claim needs to be filed\n',
            '- Any relevant policy numbers or documentation\n',
            '- Specific details about the incident or coverage needed'
        ]
    },
    'policy': {
        keywords: ['policy', 'policies', 'coverage', 'insurance'],
        templates: [
            'To provide you with the best policy information: ',
            'For detailed policy guidance: ',
            'When discussing insurance policies, please include: '
        ],
        clarifications: [
            '- The specific type of insurance coverage you need\n',
            '- Your budget or preferred premium range\n',
            '- Duration of coverage required\n',
            '- Any specific features or benefits you require'
        ]
    },
    'customer': {
        keywords: ['customer', 'client', 'user', 'member'],
        templates: [
            'For customer-related inquiries: ',
            'To better assist with customer matters: ',
            'When managing customer information: '
        ],
        clarifications: [
            '- The specific customer service request or issue\n',
            '- Customer ID or account details if available\n',
            '- Preferred method of communication\n',
            '- Any previous interactions or history'
        ]
    },
    'default': {
        keywords: [],
        templates: [
            'To provide you with a more comprehensive answer: ',
            'For better assistance with your query: ',
            'Please consider adding more details: '
        ],
        clarifications: [
            '- Specific context or background information\n',
            '- Any particular aspects you want to focus on\n',
            '- Your intended goal or outcome\n',
            '- Any constraints or requirements'
        ]
    }
};

// Main enhance prompt function
function enhancePrompt() {
    const promptInput = document.getElementById('prompt-input');
    const enhancedResult = document.getElementById('enhanced-result');
    const enhancedText = document.getElementById('enhanced-text');
    const loadingIndicator = document.getElementById('loading-indicator');
    const enhanceBtn = document.getElementById('enhance-btn');
    
    if (!promptInput) {
        console.error('Prompt input element not found');
        return;
    }
    
    const originalPrompt = promptInput.value.trim();
    
    // Validate input
    if (!originalPrompt) {
        showAlert('warning', 'Please enter a prompt to enhance');
        promptInput.focus();
        return;
    }
    
    // Show loading state
    enhanceBtn.disabled = true;
    enhanceBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Enhancing...';
    loadingIndicator.style.display = 'block';
    enhancedResult.style.display = 'none';
    
    // Simulate AI processing delay
    setTimeout(function() {
        // Generate enhanced prompt
        const enhanced = generateEnhancedPrompt(originalPrompt);
        
        // Display result
        enhancedText.textContent = enhanced;
        enhancedResult.style.display = 'block';
        
        // Hide loading
        loadingIndicator.style.display = 'none';
        enhanceBtn.disabled = false;
        enhanceBtn.innerHTML = '<i class="fas fa-magic"></i> Enhance Prompt';
        
        // Show success message
        showAlert('success', 'Prompt enhanced successfully!', 3000);
    }, 1500);
}

// Generate enhanced prompt based on input
function generateEnhancedPrompt(originalPrompt) {
    const lowerPrompt = originalPrompt.toLowerCase();
    
    // Find matching pattern
    let pattern = enhancementPatterns['default'];
    
    for (const [key, value] of Object.entries(enhancementPatterns)) {
        if (key !== 'default') {
            const hasKeyword = value.keywords.some(keyword => lowerPrompt.includes(keyword));
            if (hasKeyword) {
                pattern = value;
                break;
            }
        }
    }
    
    // Select random template
    const template = pattern.templates[Math.floor(Math.random() * pattern.templates.length)];
    
    // Build enhanced prompt
    let enhanced = '';
    
    // Add context header
    enhanced += template + '\n\n';
    
    // Add original prompt with emphasis
    enhanced += '📝 **Your Enhanced Query:**\n';
    enhanced += '"' + capitalizeFirstLetter(originalPrompt) + '"' + '\n\n';
    
    // Add clarifications
    enhanced += '✨ **Recommended Details to Include:**\n';
    enhanced += pattern.clarifications.join('');
    
    // Add example if applicable
    enhanced += '\n💡 **Example of Enhanced Prompt:**\n';
    enhanced += '"' + generateExamplePrompt(originalPrompt, pattern) + '"';
    
    return enhanced;
}

// Generate example prompt
function generateExamplePrompt(originalPrompt, pattern) {
    const examples = {
        'claim': 'I need to file an insurance claim for my health policy. The incident occurred on [date]. Policy number: [number]. Please provide the complete step-by-step process including required documents and timeline.',
        'policy': 'I am looking for a comprehensive health insurance policy with coverage of at least ₹5 lakhs, affordable premiums, and cashless hospitalization benefits. My age group is [age range]. What options are available?',
        'customer': 'I need to update the contact information for customer ID [ID]. The new email is [email] and phone number is [phone]. Please confirm the update was successful.',
        'default': originalPrompt + '. Please provide detailed information including specific requirements, relevant examples, and best practices.'
    };
    
    const key = Object.keys(enhancementPatterns).find(k => 
        k !== 'default' && 
        enhancementPatterns[k].keywords.some(keyword => originalPrompt.toLowerCase().includes(keyword))
    ) || 'default';
    
    return examples[key] || examples['default'];
}

// Clear prompt function
function clearPrompt() {
    const promptInput = document.getElementById('prompt-input');
    const enhancedResult = document.getElementById('enhanced-result');
    
    if (promptInput) {
        promptInput.value = '';
        promptInput.focus();
    }
    
    if (enhancedResult) {
        enhancedResult.style.display = 'none';
    }
}

// Copy enhanced prompt to clipboard
function copyEnhancedPrompt() {
    const enhancedText = document.getElementById('enhanced-text');
    
    if (!enhancedText) return;
    
    const textToCopy = enhancedText.textContent;
    
    navigator.clipboard.writeText(textToCopy).then(function() {
        showAlert('success', 'Enhanced prompt copied to clipboard!', 3000);
    }).catch(function(err) {
        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = textToCopy;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
        showAlert('success', 'Enhanced prompt copied to clipboard!', 3000);
    });
}

// Capitalize first letter helper
function capitalizeFirstLetter(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

// Initialize prompt enhancement if on landing page
document.addEventListener('DOMContentLoaded', function() {
    const promptInput = document.getElementById('prompt-input');
    if (promptInput) {
        // Add enter key support
        promptInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && e.ctrlKey) {
                enhancePrompt();
            }
        });
    }
});

// ========================================
// Pagination
// ========================================
function initPagination(tableId = 'data-table', rowsPerPage = 10) {
    const table = document.getElementById(tableId);
    if (!table) return;
    
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    const totalPages = Math.ceil(rows.length / rowsPerPage);
    let currentPage = 1;
    
    function displayPage(page) {
        const start = (page - 1) * rowsPerPage;
        const end = start + rowsPerPage;
        
        rows.forEach((row, index) => {
            row.style.display = (index >= start && index < end) ? '' : 'none';
        });
        
        updatePaginationControls(page);
    }
    
    function updatePaginationControls(page) {
        // Remove existing pagination
        const existingPagination = table.parentElement.querySelector('.pagination-controls');
        if (existingPagination) {
            existingPagination.remove();
        }
        
        if (totalPages <= 1) return;
        
        const pagination = document.createElement('div');
        pagination.className = 'pagination-controls';
        pagination.style.cssText = `
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.5rem;
            margin-top: 1.5rem;
            padding: 1rem;
        `;
        
        let paginationHTML = `
            <button class="btn btn-secondary" onclick="changePage(${page - 1})" ${page === 1 ? 'disabled' : ''}>
                <i class="fas fa-chevron-left"></i> Previous
            </button>
            <span>Page ${page} of ${totalPages}</span>
            <button class="btn btn-secondary" onclick="changePage(${page + 1})" ${page === totalPages ? 'disabled' : ''}>
                Next <i class="fas fa-chevron-right"></i>
            </button>
        `;
        
        pagination.innerHTML = paginationHTML;
        table.parentElement.appendChild(pagination);
    }
    
    // Make changePage available globally
    window.changePage = function(page) {
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        displayPage(currentPage);
    };
    
    // Initial display
    displayPage(1);
}

// ========================================
// Initialize on load
// ========================================
window.addEventListener('load', function() {
    animateNumbers();
    
    // Check for URL messages
    const message = getUrlParameter('message');
    const type = getUrlParameter('type') || 'info';
    
    if (message) {
        showAlert(type, decodeURIComponent(message));
        
        // Clean URL
        const url = new URL(window.location);
        url.searchParams.delete('message');
        url.searchParams.delete('type');
        window.history.pushState({}, '', url);
    }
});

// Add smooth scrolling
document.documentElement.style.scrollBehavior = 'smooth';
