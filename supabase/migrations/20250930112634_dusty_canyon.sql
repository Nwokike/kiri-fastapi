-- =====================================================
-- KIRI.NG DATABASE MANAGEMENT SYSTEM
-- Complete Database Schema for Service Marketplace
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS kiri_ng;
USE kiri_ng;

-- =====================================================
-- CORE USER MANAGEMENT TABLES
-- =====================================================

-- Users table - Core authentication and role management
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('artisan', 'customer', 'admin') DEFAULT 'artisan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Constraints
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%')
);

-- Profiles table - Extended user information (1-to-1 with users)
CREATE TABLE profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    bio TEXT,
    profile_image_url VARCHAR(500),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Additional Constraints
    CONSTRAINT chk_phone_format CHECK (phone REGEXP '^[+]?[0-9]{7,15}$')
);

-- =====================================================
-- SERVICE MARKETPLACE TABLES
-- =====================================================

-- Categories table - Service categorization
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Self-referencing foreign key for subcategories
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Services table - Core marketplace functionality (1-to-many with users)
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category_id INT,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration_hours INT DEFAULT 1,
    location VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    
    -- Business Logic Constraints
    CONSTRAINT chk_positive_price CHECK (price >= 0),
    CONSTRAINT chk_positive_duration CHECK (duration_hours > 0)
);

-- Bookings table - Service reservations (many-to-many between users and services)
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    customer_id INT NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    scheduled_date DATE,
    scheduled_time TIME,
    total_amount DECIMAL(10,2),
    notes TEXT,
    booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_future_booking CHECK (scheduled_date >= CURDATE()),
    CONSTRAINT chk_positive_amount CHECK (total_amount >= 0)
);

-- =====================================================
-- GAMIFICATION SYSTEM
-- =====================================================

-- Badges table - Achievement system
CREATE TABLE badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    criteria TEXT,
    points_value INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_positive_points CHECK (points_value >= 0)
);

-- User-Badges junction table (Many-to-Many relationship)
CREATE TABLE user_badges (
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    awarded_by INT,
    
    -- Composite Primary Key
    PRIMARY KEY (user_id, badge_id),
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE,
    FOREIGN KEY (awarded_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- =====================================================
-- LEARNING MANAGEMENT SYSTEM
-- =====================================================

-- Learning Pathways table - Educational content structure
CREATE TABLE learning_pathways (
    pathway_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    difficulty_level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    estimated_hours INT,
    is_published BOOLEAN DEFAULT FALSE,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    -- Business Logic Constraints
    CONSTRAINT chk_positive_hours CHECK (estimated_hours > 0)
);

-- Modules table - Pathway components (1-to-many with pathways)
CREATE TABLE modules (
    module_id INT AUTO_INCREMENT PRIMARY KEY,
    pathway_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    content TEXT,
    order_index INT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (pathway_id) REFERENCES learning_pathways(pathway_id) ON DELETE CASCADE,
    
    -- Unique constraint for ordering within pathway
    UNIQUE KEY unique_pathway_order (pathway_id, order_index),
    
    -- Business Logic Constraints
    CONSTRAINT chk_positive_order CHECK (order_index > 0)
);

-- User Progress tracking (Many-to-Many between users and modules)
CREATE TABLE user_progress (
    user_id INT NOT NULL,
    module_id INT NOT NULL,
    status ENUM('not_started', 'in_progress', 'completed') DEFAULT 'not_started',
    progress_percentage INT DEFAULT 0,
    started_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    
    -- Composite Primary Key
    PRIMARY KEY (user_id, module_id),
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(module_id) ON DELETE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_valid_percentage CHECK (progress_percentage BETWEEN 0 AND 100)
);

-- =====================================================
-- COMMUNITY & CONTENT SYSTEM
-- =====================================================

-- Blog Posts table - Community content
CREATE TABLE blog_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    excerpt VARCHAR(500),
    featured_image_url VARCHAR(500),
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Business Logic Constraints
    CONSTRAINT chk_positive_views CHECK (view_count >= 0)
);

-- Blog Comments table - Post engagement
CREATE TABLE blog_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT NULL,
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (post_id) REFERENCES blog_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES blog_comments(comment_id) ON DELETE CASCADE
);

-- =====================================================
-- COMMUNICATION SYSTEM
-- =====================================================

-- Notifications table - User notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type ENUM('booking', 'message', 'system', 'achievement') DEFAULT 'system',
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    -- Foreign Key Constraints
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Messages table - Direct messaging between users
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    subject VARCHAR(200),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    -- Foreign Key Constraints
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    -- Prevent self-messaging
    CONSTRAINT chk_different_users CHECK (sender_id != recipient_id)
);

-- =====================================================
-- REVIEWS & RATINGS SYSTEM
-- =====================================================

-- Reviews table - Service feedback
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    customer_id INT NOT NULL,
    booking_id INT,
    rating INT NOT NULL,
    title VARCHAR(200),
    content TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL,
    
    -- Business Logic Constraints
    CONSTRAINT chk_valid_rating CHECK (rating BETWEEN 1 AND 5),
    
    -- Unique constraint - one review per customer per service
    UNIQUE KEY unique_customer_service_review (service_id, customer_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- User-related indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- Service-related indexes
CREATE INDEX idx_services_user ON services(user_id);
CREATE INDEX idx_services_category ON services(category_id);
CREATE INDEX idx_services_active ON services(is_active);
CREATE INDEX idx_services_price ON services(price);

-- Booking-related indexes
CREATE INDEX idx_bookings_service ON bookings(service_id);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(scheduled_date);

-- Blog-related indexes
CREATE INDEX idx_blog_posts_user ON blog_posts(user_id);
CREATE INDEX idx_blog_posts_status ON blog_posts(status);
CREATE INDEX idx_blog_posts_created ON blog_posts(created_at);
CREATE INDEX idx_blog_comments_post ON blog_comments(post_id);

-- Learning-related indexes
CREATE INDEX idx_modules_pathway ON modules(pathway_id);
CREATE INDEX idx_modules_order ON modules(order_index);
CREATE INDEX idx_user_progress_user ON user_progress(user_id);

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Web Development', 'Website and web application development services'),
('Graphic Design', 'Logo, branding, and visual design services'),
('Digital Marketing', 'SEO, social media, and online marketing services'),
('Photography', 'Event, portrait, and commercial photography'),
('Writing & Translation', 'Content writing, copywriting, and translation services');

-- Insert sample badges
INSERT INTO badges (name, description, points_value) VALUES
('First Service', 'Created your first service listing', 10),
('Customer Favorite', 'Received 10+ five-star reviews', 50),
('Learning Enthusiast', 'Completed 5 learning modules', 25),
('Community Contributor', 'Published 5 blog posts', 30),
('Top Performer', 'Completed 100+ successful bookings', 100);

-- Insert sample learning pathway
INSERT INTO learning_pathways (title, description, difficulty_level, estimated_hours, is_published) VALUES
('Web Development Fundamentals', 'Learn the basics of HTML, CSS, and JavaScript', 'beginner', 40, TRUE),
('Advanced Digital Marketing', 'Master SEO, PPC, and social media marketing', 'advanced', 60, TRUE);

-- Insert sample modules
INSERT INTO modules (pathway_id, title, description, content, order_index, is_published) VALUES
(1, 'Introduction to HTML', 'Learn HTML basics and structure', 'HTML content here...', 1, TRUE),
(1, 'CSS Styling Fundamentals', 'Master CSS for beautiful designs', 'CSS content here...', 2, TRUE),
(1, 'JavaScript Basics', 'Add interactivity with JavaScript', 'JavaScript content here...', 3, TRUE),
(2, 'SEO Fundamentals', 'Search Engine Optimization basics', 'SEO content here...', 1, TRUE),
(2, 'Social Media Strategy', 'Build effective social media campaigns', 'Social media content here...', 2, TRUE);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for service listings with category and artisan info
CREATE VIEW service_listings AS
SELECT 
    s.service_id,
    s.title,
    s.description,
    s.price,
    s.duration_hours,
    s.location,
    s.is_active,
    s.created_at,
    c.name as category_name,
    p.full_name as artisan_name,
    u.email as artisan_email,
    COALESCE(AVG(r.rating), 0) as average_rating,
    COUNT(r.review_id) as review_count
FROM services s
LEFT JOIN categories c ON s.category_id = c.category_id
LEFT JOIN users u ON s.user_id = u.user_id
LEFT JOIN profiles p ON u.user_id = p.user_id
LEFT JOIN reviews r ON s.service_id = r.service_id
GROUP BY s.service_id;

-- View for user dashboard statistics
CREATE VIEW user_stats AS
SELECT 
    u.user_id,
    u.email,
    p.full_name,
    COUNT(DISTINCT s.service_id) as total_services,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    COUNT(DISTINCT ub.badge_id) as badges_earned,
    COUNT(DISTINCT bp.post_id) as blog_posts_written,
    COALESCE(AVG(r.rating), 0) as average_rating
FROM users u
LEFT JOIN profiles p ON u.user_id = p.user_id
LEFT JOIN services s ON u.user_id = s.user_id
LEFT JOIN bookings b ON s.service_id = b.service_id
LEFT JOIN user_badges ub ON u.user_id = ub.user_id
LEFT JOIN blog_posts bp ON u.user_id = bp.user_id
LEFT JOIN reviews r ON s.service_id = r.service_id
GROUP BY u.user_id;

-- =====================================================
-- STORED PROCEDURES FOR COMMON OPERATIONS
-- =====================================================

DELIMITER //

-- Procedure to calculate user's total earnings
CREATE PROCEDURE GetUserEarnings(IN user_id INT, OUT total_earnings DECIMAL(10,2))
BEGIN
    SELECT COALESCE(SUM(b.total_amount), 0)
    INTO total_earnings
    FROM services s
    JOIN bookings b ON s.service_id = b.service_id
    WHERE s.user_id = user_id AND b.status = 'completed';
END //

-- Procedure to award badge to user
CREATE PROCEDURE AwardBadge(IN user_id INT, IN badge_id INT, IN awarded_by_user INT)
BEGIN
    INSERT IGNORE INTO user_badges (user_id, badge_id, awarded_by)
    VALUES (user_id, badge_id, awarded_by_user);
    
    -- Create notification
    INSERT INTO notifications (user_id, type, title, message)
    VALUES (user_id, 'achievement', 'New Badge Earned!', 
            CONCAT('Congratulations! You have earned a new badge.'));
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS FOR BUSINESS LOGIC
-- =====================================================

DELIMITER //

-- Trigger to update blog post published_at when status changes to published
CREATE TRIGGER update_blog_published_date
    BEFORE UPDATE ON blog_posts
    FOR EACH ROW
BEGIN
    IF NEW.status = 'published' AND OLD.status != 'published' THEN
        SET NEW.published_at = CURRENT_TIMESTAMP;
    END IF;
END //

-- Trigger to create notification when booking status changes
CREATE TRIGGER booking_status_notification
    AFTER UPDATE ON bookings
    FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status THEN
        INSERT INTO notifications (user_id, type, title, message)
        VALUES (NEW.customer_id, 'booking', 
                CONCAT('Booking Status Updated'),
                CONCAT('Your booking status has been changed to: ', NEW.status));
    END IF;
END //

DELIMITER ;

-- =====================================================
-- DATABASE SCHEMA COMPLETE
-- Total Tables: 16
-- Relationships: 1-to-1, 1-to-many, many-to-many implemented
-- Constraints: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL
-- Additional Features: Indexes, Views, Stored Procedures, Triggers
-- =====================================================