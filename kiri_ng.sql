-- Create database
CREATE DATABASE kiri_ng;
USE kiri_ng;

-- Users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('artisan', 'customer', 'admin') DEFAULT 'artisan',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Profiles (1-to-1 with users)
CREATE TABLE profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Services (1-to-many with users)
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Bookings (1-to-many with services)
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL,
    customer_id INT NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
    booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (service_id) REFERENCES services(service_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Badges
CREATE TABLE badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- User-Badges (Many-to-Many)
CREATE TABLE user_badges (
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, badge_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE
);

-- Learning Pathways
CREATE TABLE learning_pathways (
    pathway_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT
);

-- Modules in Pathway
CREATE TABLE modules (
    module_id INT AUTO_INCREMENT PRIMARY KEY,
    pathway_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT,
    FOREIGN KEY (pathway_id) REFERENCES learning_pathways(pathway_id) ON DELETE CASCADE
);

-- Blog Posts
CREATE TABLE blog_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Blog Comments
CREATE TABLE blog_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES blog_posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
