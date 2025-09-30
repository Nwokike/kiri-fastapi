# app/schemas.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Literal
from datetime import datetime

# --- Service ---
class ServiceBase(BaseModel):
    title: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    price: Optional[float] = Field(default=0, ge=0)
    artisan_id: Optional[int] = None
    category_id: Optional[int] = None

class ServiceCreate(ServiceBase):
    pass

class ServiceRead(ServiceBase):
    id: int
    created_at: Optional[datetime] = None
    model_config = {"from_attributes": True}


# --- Booking ---
class BookingBase(BaseModel):
    customer_name: str = Field(..., min_length=2, max_length=100)
    customer_email: Optional[EmailStr] = None
    customer_phone: Optional[str] = Field(
        default=None,
        pattern=r"^\+?\d{7,15}$"
    )
    scheduled_time: Optional[datetime] = None
    notes: Optional[str] = None
    status: Literal["pending", "confirmed", "cancelled"] = "pending"

class BookingCreate(BookingBase):
    pass

class BookingRead(BookingBase):
    id: int
    service_id: int
    created_at: Optional[datetime] = None
    model_config = {"from_attributes": True}


# --- Category ---
class CategoryBase(BaseModel):
    name: str
    description: Optional[str] = None

class CategoryCreate(CategoryBase):
    pass

class CategoryRead(CategoryBase):
    id: int
    model_config = {"from_attributes": True}


# --- User ---
class UserBase(BaseModel):
    username: str
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class UserCreate(UserBase):
    password: str  # only on create

class UserRead(UserBase):
    id: int
    date_joined: Optional[datetime] = None
    is_active: Optional[bool] = True
    model_config = {"from_attributes": True}


# --- Profile ---
class ProfileBase(BaseModel):
    bio: Optional[str] = None
    phone_number: Optional[str] = None

class ProfileCreate(ProfileBase):
    user_id: int

class ProfileRead(ProfileBase):
    id: int
    user_id: int
    model_config = {"from_attributes": True}


# --- Blog Post ---
# Note: Some schemas/databases use 'content' or 'body' or 'text' — we accept both.
class BlogPostBase(BaseModel):
    title: str
    content: Optional[str] = None
    body: Optional[str] = None

class BlogPostCreate(BlogPostBase):
    author_id: Optional[int] = None

class BlogPostRead(BlogPostBase):
    id: int
    author_id: Optional[int] = None
    created_at: Optional[datetime] = None
    model_config = {"from_attributes": True}


# --- Blog Comment ---
class BlogCommentBase(BaseModel):
    content: str

class BlogCommentCreate(BlogCommentBase):
    post_id: int
    author_id: Optional[int] = None

class BlogCommentRead(BlogCommentBase):
    id: int
    post_id: int
    author_id: Optional[int] = None
    created_at: Optional[datetime] = None
    model_config = {"from_attributes": True}


# --- Academy Pathway ---
# DB might use different column names; accept title/description/slug
class PathwayBase(BaseModel):
    title: str
    description: Optional[str] = None
    slug: Optional[str] = None

class PathwayCreate(PathwayBase):
    pass

class PathwayRead(PathwayBase):
    id: int
    created_at: Optional[datetime] = None
    model_config = {"from_attributes": True}


# --- Academy Step ---
class StepBase(BaseModel):
    title: str
    content: str

class StepCreate(StepBase):
    module_id: Optional[int] = None

class StepRead(StepBase):
    id: int
    module_id: Optional[int] = None
    model_config = {"from_attributes": True}
