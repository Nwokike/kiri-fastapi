# app/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .database import Base
from .deps import get_db
from . import schemas
from typing import List, Dict, Any, Optional

app = FastAPI(title="Kiri.ng API")

# Map reflected classes (these names come from automap)
Service = Base.classes.marketplace_service
Booking = Base.classes.marketplace_booking
Category = Base.classes.marketplace_category
User = Base.classes.auth_user
Profile = Base.classes.users_profile
BlogPost = Base.classes.blog_post
BlogComment = Base.classes.blog_comment
Pathway = Base.classes.academy_learningpathway
Step = Base.classes.academy_modulestep


# -----------------------
# Helper utilities
# -----------------------
def table_columns(model) -> Dict[str, Any]:
    """Return mapping of column name -> Column object for a reflected model."""
    return {c.name: c for c in model.__table__.columns}


def prepare_payload_for_model(model, payload: Dict[str, Any],
                              alias_map: Optional[Dict[str, str]] = None) -> Dict[str, Any]:
    """
    Build a dict of fields suitable for constructing the model instance.
    - Keeps only columns that exist in the table.
    - Supports alias_map: mapping from payload field name -> table column name.
    - Raises HTTPException(400) if required non-nullable columns are missing.
    """
    cols = table_columns(model)
    data = {}

    # apply aliases first
    alias_map = alias_map or {}
    # map payload keys to column names
    for k, v in payload.items():
        target = alias_map.get(k, k)
        if target in cols:
            data[target] = v

    # also accept some common alternate names automatically (e.g. payload 'content' -> DB 'body')
    # this is handled by alias_map if provided when calling

    # Check for required columns missing (simple heuristic)
    missing = []
    for name, col in cols.items():
        # skip primary keys, server defaults and autoincrement
        if col.primary_key:
            continue
        # if a default is present or server_default, treat as not required
        if col.default is not None or getattr(col, "server_default", None) is not None:
            continue
        if getattr(col, "autoincrement", False):
            continue
        if not col.nullable and name not in data:
            missing.append(name)

    if missing:
        # don't expose raw column objects, just names
        raise HTTPException(status_code=400, detail=f"Missing required DB columns for this model: {missing}")

    return data


def serialize_model(obj, mapping: Dict[str, list]) -> Dict[str, Any]:
    """
    Build a dict for response_model by checking multiple possible attribute names.
    mapping: desired_key -> list of candidate attribute names (in priority order)
    """
    out = {}
    for key, candidates in mapping.items():
        val = None
        for c in candidates:
            if hasattr(obj, c):
                val = getattr(obj, c)
                break
        if val is not None:
            out[key] = val
    # copy id if present
    if "id" not in out and hasattr(obj, "id"):
        out["id"] = getattr(obj, "id")
    return out


# -----------------------
# Root + debug
# -----------------------
@app.get("/")
def read_root():
    return {"message": "Welcome to Kiri.ng API 🚀"}


@app.get("/tables")
def get_tables():
    return {"tables": list(Base.classes.keys())}


# -----------------------
# Services (unchanged)
# -----------------------
@app.get("/services", response_model=List[schemas.ServiceRead])
def list_services(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Service).offset(skip).limit(limit).all()

@app.get("/services/{service_id}", response_model=schemas.ServiceRead)
def get_service(service_id: int, db: Session = Depends(get_db)):
    obj = db.get(Service, service_id)
    if not obj:
        raise HTTPException(404, "Service not found")
    return obj

@app.post("/services", response_model=schemas.ServiceRead, status_code=201)
def create_service(payload: schemas.ServiceCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(Service, payload.dict())
    obj = Service(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/services/{service_id}", response_model=schemas.ServiceRead)
def update_service(service_id: int, payload: schemas.ServiceCreate, db: Session = Depends(get_db)):
    obj = db.get(Service, service_id)
    if not obj:
        raise HTTPException(404, "Service not found")
    for k, v in payload.dict().items():
        # only set attributes that actually exist on the ORM object/table
        if k in table_columns(Service):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/services/{service_id}", status_code=204)
def delete_service(service_id: int, db: Session = Depends(get_db)):
    obj = db.get(Service, service_id)
    if not obj:
        raise HTTPException(404, "Service not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Bookings (unchanged)
# -----------------------
@app.get("/bookings", response_model=List[schemas.BookingRead])
def list_bookings(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Booking).offset(skip).limit(limit).all()

@app.get("/bookings/{booking_id}", response_model=schemas.BookingRead)
def get_booking(booking_id: int, db: Session = Depends(get_db)):
    obj = db.get(Booking, booking_id)
    if not obj:
        raise HTTPException(404, "Booking not found")
    return obj

@app.post("/services/{service_id}/bookings", response_model=schemas.BookingRead, status_code=201)
def create_booking(service_id: int, payload: schemas.BookingCreate, db: Session = Depends(get_db)):
    svc = db.get(Service, service_id)
    if not svc:
        raise HTTPException(404, "Service not found")
    data = prepare_payload_for_model(Booking, payload.dict())
    # ensure the FK to service is present on the model
    if "service_id" in table_columns(Booking):
        data["service_id"] = service_id
    obj = Booking(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/bookings/{booking_id}", response_model=schemas.BookingRead)
def update_booking(booking_id: int, payload: schemas.BookingCreate, db: Session = Depends(get_db)):
    obj = db.get(Booking, booking_id)
    if not obj:
        raise HTTPException(404, "Booking not found")
    for k, v in payload.dict().items():
        if k in table_columns(Booking):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/bookings/{booking_id}", status_code=204)
def delete_booking(booking_id: int, db: Session = Depends(get_db)):
    obj = db.get(Booking, booking_id)
    if not obj:
        raise HTTPException(404, "Booking not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Categories (unchanged)
# -----------------------
@app.get("/categories", response_model=List[schemas.CategoryRead])
def list_categories(db: Session = Depends(get_db)):
    return db.query(Category).all()

@app.get("/categories/{category_id}", response_model=schemas.CategoryRead)
def get_category(category_id: int, db: Session = Depends(get_db)):
    obj = db.get(Category, category_id)
    if not obj:
        raise HTTPException(404, "Category not found")
    return obj

@app.post("/categories", response_model=schemas.CategoryRead, status_code=201)
def create_category(payload: schemas.CategoryCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(Category, payload.dict())
    obj = Category(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/categories/{category_id}", response_model=schemas.CategoryRead)
def update_category(category_id: int, payload: schemas.CategoryCreate, db: Session = Depends(get_db)):
    obj = db.get(Category, category_id)
    if not obj:
        raise HTTPException(404, "Category not found")
    for k, v in payload.dict().items():
        if k in table_columns(Category):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/categories/{category_id}", status_code=204)
def delete_category(category_id: int, db: Session = Depends(get_db)):
    obj = db.get(Category, category_id)
    if not obj:
        raise HTTPException(404, "Category not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Users (unchanged)
# -----------------------
@app.get("/users", response_model=List[schemas.UserRead])
def list_users(db: Session = Depends(get_db)):
    return db.query(User).all()

@app.get("/users/{user_id}", response_model=schemas.UserRead)
def get_user(user_id: int, db: Session = Depends(get_db)):
    obj = db.get(User, user_id)
    if not obj:
        raise HTTPException(404, "User not found")
    return obj

@app.post("/users", response_model=schemas.UserRead, status_code=201)
def create_user(payload: schemas.UserCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(User, payload.dict())
    obj = User(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/users/{user_id}", response_model=schemas.UserRead)
def update_user(user_id: int, payload: schemas.UserCreate, db: Session = Depends(get_db)):
    obj = db.get(User, user_id)
    if not obj:
        raise HTTPException(404, "User not found")
    for k, v in payload.dict().items():
        if k in table_columns(User):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/users/{user_id}", status_code=204)
def delete_user(user_id: int, db: Session = Depends(get_db)):
    obj = db.get(User, user_id)
    if not obj:
        raise HTTPException(404, "User not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Profiles (unchanged)
# -----------------------
@app.get("/profiles", response_model=List[schemas.ProfileRead])
def list_profiles(db: Session = Depends(get_db)):
    return db.query(Profile).all()

@app.get("/profiles/{profile_id}", response_model=schemas.ProfileRead)
def get_profile(profile_id: int, db: Session = Depends(get_db)):
    obj = db.get(Profile, profile_id)
    if not obj:
        raise HTTPException(404, "Profile not found")
    return obj

@app.post("/profiles", response_model=schemas.ProfileRead, status_code=201)
def create_profile(payload: schemas.ProfileCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(Profile, payload.dict())
    obj = Profile(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/profiles/{profile_id}", response_model=schemas.ProfileRead)
def update_profile(profile_id: int, payload: schemas.ProfileCreate, db: Session = Depends(get_db)):
    obj = db.get(Profile, profile_id)
    if not obj:
        raise HTTPException(404, "Profile not found")
    for k, v in payload.dict().items():
        if k in table_columns(Profile):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/profiles/{profile_id}", status_code=204)
def delete_profile(profile_id: int, db: Session = Depends(get_db)):
    obj = db.get(Profile, profile_id)
    if not obj:
        raise HTTPException(404, "Profile not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Blog Posts (robust)
# -----------------------
# mapping for serialization: desired_key -> candidate attribute names
POST_SERIALIZE_MAP = {
    "id": ["id", "pk"],
    "title": ["title", "name"],
    "content": ["content", "body", "text", "description"],
    "author_id": ["author_id", "author", "user_id"],
    "created_at": ["created_at", "created", "date_created", "timestamp"],
}

@app.get("/posts", response_model=List[schemas.BlogPostRead])
def list_posts(db: Session = Depends(get_db)):
    rows = db.query(BlogPost).all()
    return [serialize_model(r, POST_SERIALIZE_MAP) for r in rows]

@app.get("/posts/{post_id}", response_model=schemas.BlogPostRead)
def get_post(post_id: int, db: Session = Depends(get_db)):
    obj = db.get(BlogPost, post_id)
    if not obj:
        raise HTTPException(404, "Post not found")
    return serialize_model(obj, POST_SERIALIZE_MAP)

@app.post("/posts", response_model=schemas.BlogPostRead, status_code=201)
def create_post(payload: schemas.BlogPostCreate, db: Session = Depends(get_db)):
    # allow payload 'content' -> DB 'body' mapping
    alias_map = {}
    cols = table_columns(BlogPost)
    # map 'content' to 'body' or 'text' if those exist in DB
    if "content" in payload.dict() and "content" not in cols:
        if "body" in cols:
            alias_map["content"] = "body"
        elif "text" in cols:
            alias_map["content"] = "text"
    if "author_id" in payload.dict() and "author_id" not in cols:
        # try 'user_id' or 'author'
        if "user_id" in cols:
            alias_map["author_id"] = "user_id"
        elif "author" in cols:
            alias_map["author_id"] = "author"

    data = prepare_payload_for_model(BlogPost, payload.dict(), alias_map=alias_map)
    obj = BlogPost(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return serialize_model(obj, POST_SERIALIZE_MAP)

@app.put("/posts/{post_id}", response_model=schemas.BlogPostRead)
def update_post(post_id: int, payload: schemas.BlogPostCreate, db: Session = Depends(get_db)):
    obj = db.get(BlogPost, post_id)
    if not obj:
        raise HTTPException(404, "Post not found")

    # map content->body if necessary
    alias_map = {}
    cols = table_columns(BlogPost)
    if "content" in payload.dict() and "content" not in cols:
        if "body" in cols:
            alias_map["content"] = "body"
        elif "text" in cols:
            alias_map["content"] = "text"
    # apply updates only to existing columns
    for k, v in payload.dict().items():
        target = alias_map.get(k, k)
        if target in cols:
            setattr(obj, target, v)
    db.commit()
    db.refresh(obj)
    return serialize_model(obj, POST_SERIALIZE_MAP)

@app.delete("/posts/{post_id}", status_code=204)
def delete_post(post_id: int, db: Session = Depends(get_db)):
    obj = db.get(BlogPost, post_id)
    if not obj:
        raise HTTPException(404, "Post not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Blog Comments (unchanged)
# -----------------------
@app.get("/comments", response_model=List[schemas.BlogCommentRead])
def list_comments(db: Session = Depends(get_db)):
    return db.query(BlogComment).all()

@app.get("/comments/{comment_id}", response_model=schemas.BlogCommentRead)
def get_comment(comment_id: int, db: Session = Depends(get_db)):
    obj = db.get(BlogComment, comment_id)
    if not obj:
        raise HTTPException(404, "Comment not found")
    return obj

@app.post("/comments", response_model=schemas.BlogCommentRead, status_code=201)
def create_comment(payload: schemas.BlogCommentCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(BlogComment, payload.dict())
    obj = BlogComment(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/comments/{comment_id}", response_model=schemas.BlogCommentRead)
def update_comment(comment_id: int, payload: schemas.BlogCommentCreate, db: Session = Depends(get_db)):
    obj = db.get(BlogComment, comment_id)
    if not obj:
        raise HTTPException(404, "Comment not found")
    for k, v in payload.dict().items():
        if k in table_columns(BlogComment):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/comments/{comment_id}", status_code=204)
def delete_comment(comment_id: int, db: Session = Depends(get_db)):
    obj = db.get(BlogComment, comment_id)
    if not obj:
        raise HTTPException(404, "Comment not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Academy Pathways (robust)
# -----------------------
PATHWAY_SERIALIZE_MAP = {
    "id": ["id"],
    "title": ["title", "name"],
    "description": ["description", "summary", "details"],
    "slug": ["slug"],
    "created_at": ["created_at", "created", "date_created"],
}

@app.get("/pathways", response_model=List[schemas.PathwayRead])
def list_pathways(db: Session = Depends(get_db)):
    rows = db.query(Pathway).all()
    return [serialize_model(r, PATHWAY_SERIALIZE_MAP) for r in rows]

@app.get("/pathways/{pathway_id}", response_model=schemas.PathwayRead)
def get_pathway(pathway_id: int, db: Session = Depends(get_db)):
    obj = db.get(Pathway, pathway_id)
    if not obj:
        raise HTTPException(404, "Pathway not found")
    return serialize_model(obj, PATHWAY_SERIALIZE_MAP)

@app.post("/pathways", response_model=schemas.PathwayRead, status_code=201)
def create_pathway(payload: schemas.PathwayCreate, db: Session = Depends(get_db)):
    # map content names if needed
    alias_map = {}
    cols = table_columns(Pathway)
    data = prepare_payload_for_model(Pathway, payload.dict(), alias_map=alias_map)
    obj = Pathway(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return serialize_model(obj, PATHWAY_SERIALIZE_MAP)

@app.put("/pathways/{pathway_id}", response_model=schemas.PathwayRead)
def update_pathway(pathway_id: int, payload: schemas.PathwayCreate, db: Session = Depends(get_db)):
    obj = db.get(Pathway, pathway_id)
    if not obj:
        raise HTTPException(404, "Pathway not found")
    for k, v in payload.dict().items():
        if k in table_columns(Pathway):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return serialize_model(obj, PATHWAY_SERIALIZE_MAP)

@app.delete("/pathways/{pathway_id}", status_code=204)
def delete_pathway(pathway_id: int, db: Session = Depends(get_db)):
    obj = db.get(Pathway, pathway_id)
    if not obj:
        raise HTTPException(404, "Pathway not found")
    db.delete(obj)
    db.commit()
    return None


# -----------------------
# Academy Steps (unchanged)
# -----------------------
@app.get("/steps", response_model=List[schemas.StepRead])
def list_steps(db: Session = Depends(get_db)):
    return db.query(Step).all()

@app.get("/steps/{step_id}", response_model=schemas.StepRead)
def get_step(step_id: int, db: Session = Depends(get_db)):
    obj = db.get(Step, step_id)
    if not obj:
        raise HTTPException(404, "Step not found")
    return obj

@app.post("/steps", response_model=schemas.StepRead, status_code=201)
def create_step(payload: schemas.StepCreate, db: Session = Depends(get_db)):
    data = prepare_payload_for_model(Step, payload.dict())
    obj = Step(**data)
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@app.put("/steps/{step_id}", response_model=schemas.StepRead)
def update_step(step_id: int, payload: schemas.StepCreate, db: Session = Depends(get_db)):
    obj = db.get(Step, step_id)
    if not obj:
        raise HTTPException(404, "Step not found")
    for k, v in payload.dict().items():
        if k in table_columns(Step):
            setattr(obj, k, v)
    db.commit()
    db.refresh(obj)
    return obj

@app.delete("/steps/{step_id}", status_code=204)
def delete_step(step_id: int, db: Session = Depends(get_db)):
    obj = db.get(Step, step_id)
    if not obj:
        raise HTTPException(404, "Step not found")
    db.delete(obj)
    db.commit()
    return None
