# API Usage Examples

This document provides comprehensive examples of how to use the Kiri.ng API endpoints.

## Base URL
```
http://localhost:8000
```

## Authentication
Currently, the API doesn't require authentication, but in production, you would add JWT tokens or API keys.

## Content-Type
All POST and PUT requests should include:
```
Content-Type: application/json
```

---

## Services API

### 1. Create a Service
```bash
curl -X POST "http://localhost:8000/services" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Professional Web Development",
    "description": "I create modern, responsive websites using React and Node.js",
    "price": 750.00,
    "artisan_id": 1,
    "category_id": 1
  }'
```

**Response:**
```json
{
  "id": 1,
  "title": "Professional Web Development",
  "description": "I create modern, responsive websites using React and Node.js",
  "price": 750.00,
  "artisan_id": 1,
  "category_id": 1,
  "created_at": "2024-01-15T10:30:00"
}
```

### 2. Get All Services
```bash
curl -X GET "http://localhost:8000/services"
```

### 3. Get Specific Service
```bash
curl -X GET "http://localhost:8000/services/1"
```

### 4. Update Service
```bash
curl -X PUT "http://localhost:8000/services/1" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Premium Web Development",
    "description": "Updated description with premium features",
    "price": 950.00,
    "artisan_id": 1,
    "category_id": 1
  }'
```

### 5. Delete Service
```bash
curl -X DELETE "http://localhost:8000/services/1"
```

---

## Bookings API

### 1. Create a Booking
```bash
curl -X POST "http://localhost:8000/services/1/bookings" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Sarah Johnson",
    "customer_email": "sarah@example.com",
    "customer_phone": "+1-555-0123",
    "notes": "Need a business website with e-commerce functionality",
    "status": "pending"
  }'
```

**Response:**
```json
{
  "id": 1,
  "service_id": 1,
  "customer_name": "Sarah Johnson",
  "customer_email": "sarah@example.com",
  "customer_phone": "+1-555-0123",
  "notes": "Need a business website with e-commerce functionality",
  "status": "pending",
  "created_at": "2024-01-15T11:00:00"
}
```

### 2. Get All Bookings
```bash
curl -X GET "http://localhost:8000/bookings"
```

### 3. Update Booking Status
```bash
curl -X PUT "http://localhost:8000/bookings/1" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Sarah Johnson",
    "customer_email": "sarah@example.com",
    "customer_phone": "+1-555-0123",
    "notes": "Need a business website with e-commerce functionality",
    "status": "confirmed"
  }'
```

---

## Users & Profiles API

### 1. Create a User
```bash
curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "password": "securepassword123"
  }'
```

### 2. Create a Profile
```bash
curl -X POST "http://localhost:8000/profiles" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "bio": "Experienced web developer with 5+ years in the industry",
    "phone_number": "+1-555-0199"
  }'
```

### 3. Get All Users
```bash
curl -X GET "http://localhost:8000/users"
```

---

## Categories API

### 1. Create a Category
```bash
curl -X POST "http://localhost:8000/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mobile App Development",
    "description": "iOS and Android app development services"
  }'
```

### 2. Get All Categories
```bash
curl -X GET "http://localhost:8000/categories"
```

---

## Blog Posts API

### 1. Create a Blog Post
```bash
curl -X POST "http://localhost:8000/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "10 Tips for Better Web Design",
    "content": "Here are my top 10 tips for creating better web designs that convert visitors into customers...",
    "author_id": 1
  }'
```

**Response:**
```json
{
  "id": 1,
  "title": "10 Tips for Better Web Design",
  "content": "Here are my top 10 tips for creating better web designs that convert visitors into customers...",
  "author_id": 1,
  "created_at": "2024-01-15T12:00:00"
}
```

### 2. Get All Blog Posts
```bash
curl -X GET "http://localhost:8000/posts"
```

### 3. Update Blog Post
```bash
curl -X PUT "http://localhost:8000/posts/1" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "15 Tips for Better Web Design (Updated)",
    "content": "Updated content with 5 additional tips...",
    "author_id": 1
  }'
```

---

## Blog Comments API

### 1. Create a Comment
```bash
curl -X POST "http://localhost:8000/comments" \
  -H "Content-Type: application/json" \
  -d '{
    "post_id": 1,
    "author_id": 2,
    "content": "Great tips! I especially liked the advice about color schemes."
  }'
```

### 2. Get All Comments
```bash
curl -X GET "http://localhost:8000/comments"
```

---

## Learning Pathways API

### 1. Create a Learning Pathway
```bash
curl -X POST "http://localhost:8000/pathways" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete Digital Marketing Course",
    "description": "Learn everything from SEO to social media marketing",
    "slug": "digital-marketing-complete"
  }'
```

### 2. Get All Pathways
```bash
curl -X GET "http://localhost:8000/pathways"
```

---

## Module Steps API

### 1. Create a Module Step
```bash
curl -X POST "http://localhost:8000/steps" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Introduction to SEO",
    "content": "Search Engine Optimization (SEO) is the practice of optimizing your website...",
    "module_id": 1
  }'
```

### 2. Get All Steps
```bash
curl -X GET "http://localhost:8000/steps"
```

---

## Utility Endpoints

### 1. Welcome Message
```bash
curl -X GET "http://localhost:8000/"
```

**Response:**
```json
{
  "message": "Welcome to Kiri.ng API 🚀"
}
```

### 2. List Database Tables (Debug)
```bash
curl -X GET "http://localhost:8000/tables"
```

**Response:**
```json
{
  "tables": [
    "marketplace_service",
    "marketplace_booking",
    "marketplace_category",
    "auth_user",
    "users_profile",
    "blog_post",
    "blog_comment",
    "academy_learningpathway",
    "academy_modulestep"
  ]
}
```

---

## Error Handling Examples

### 1. Invalid Data (400 Bad Request)
```bash
curl -X POST "http://localhost:8000/services" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "",
    "price": -100
  }'
```

**Response:**
```json
{
  "detail": [
    {
      "loc": ["title"],
      "msg": "ensure this value has at least 2 characters",
      "type": "value_error.any_str.min_length"
    },
    {
      "loc": ["price"],
      "msg": "ensure this value is greater than or equal to 0",
      "type": "value_error.number.not_ge"
    }
  ]
}
```

### 2. Resource Not Found (404)
```bash
curl -X GET "http://localhost:8000/services/999"
```

**Response:**
```json
{
  "detail": "Service not found"
}
```

---

## Pagination Examples

### Get Services with Pagination
```bash
curl -X GET "http://localhost:8000/services?skip=0&limit=10"
```

### Get Next Page
```bash
curl -X GET "http://localhost:8000/services?skip=10&limit=10"
```

---

## Complex Workflow Example

Here's a complete workflow showing how different endpoints work together:

### 1. Create a User
```bash
curl -X POST "http://localhost:8000/users" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "webdev_pro",
    "email": "webdev@example.com",
    "first_name": "Alex",
    "last_name": "Smith",
    "password": "securepass123"
  }'
```

### 2. Create Profile for User
```bash
curl -X POST "http://localhost:8000/profiles" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "bio": "Professional web developer specializing in React and Node.js",
    "phone_number": "+1-555-0100"
  }'
```

### 3. Create Category
```bash
curl -X POST "http://localhost:8000/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Web Development",
    "description": "Website and web application development"
  }'
```

### 4. Create Service
```bash
curl -X POST "http://localhost:8000/services" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Custom React Website",
    "description": "I will build a custom React website for your business",
    "price": 1200.00,
    "artisan_id": 1,
    "category_id": 1
  }'
```

### 5. Create Booking for Service
```bash
curl -X POST "http://localhost:8000/services/1/bookings" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Business Owner",
    "customer_email": "owner@business.com",
    "customer_phone": "+1-555-0200",
    "notes": "Need a professional website for my consulting business"
  }'
```

### 6. Create Blog Post
```bash
curl -X POST "http://localhost:8000/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Why Your Business Needs a Professional Website",
    "content": "In today digital age, having a professional website is crucial for business success...",
    "author_id": 1
  }'
```

This workflow demonstrates the complete lifecycle of a service marketplace platform, from user registration to service creation and booking.