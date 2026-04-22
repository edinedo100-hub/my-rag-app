# RAG Assignment Project Instructions

## Project Title
Global Logistics & International Business Knowledge Base

## Goal
Build a simple but professional Retrieval-Augmented Generation (RAG) web application using:

- Streamlit
- LangChain
- ChromaDB
- Sentence Transformers
- GitHub
- Render.com deployment

The application must allow users to search through academic documents about global logistics and international business using semantic search.

This project must be easy, clean, and reliable for a university master-level assignment.

---

# Required Project Structure

Create exactly these files:

my-rag-app/
- app.py
- requirements.txt
- render.yaml
- .gitignore

---

# App Requirements

## Pages
Create 2 pages:

### 1. Home Page
Include:

- project title
- short explanation of the app
- technologies used
- list of searchable topics

### 2. Search Page
Include:

- text input for user question
- semantic similarity search
- top 3 relevant results displayed clearly

---

# Topic

Use this topic:

Global Logistics & International Business Knowledge Base

Focus on:

- international logistics
- supply chain management
- geopolitics
- Incoterms
- customs clearance
- sustainability in logistics
- digital transformation
- reverse logistics
- port congestion
- inventory management

---

# Documents

Create at least 10 academic-style text documents inside app.py using a Python list called:

DOCUMENTS = []

Each document should be:

- clear
- professional
- 100–300 words
- suitable for academic search

Use short but strong academic explanations.

---

# Technical Requirements

## Chunking Strategy

Use:

- chunk_size = 500
- chunk_overlap = 50

Use:

RecursiveCharacterTextSplitter

Reason:
Good balance between context and precision.

---

## Embedding Model

Use:

all-MiniLM-L6-v2

via:

SentenceTransformerEmbeddings

---

## Vector Database

Use:

Chroma

Persist directory:

chroma_db/

---

# UI Requirements

Keep UI simple and professional:

- wide layout
- globe emoji icon 🌍
- sidebar navigation
- clean academic design

No unnecessary complexity.

Simple = better.

---

# requirements.txt

Must contain:

streamlit
langchain
langchain-community
langchain-text-splitters
chromadb
sentence-transformers

---

# render.yaml

Must contain:

services:
  - type: web
    name: my-rag-app
    runtime: python
    buildCommand: pip install -r requirements.txt
    startCommand: streamlit run app.py --server.port $PORT --server.address 0.0.0.0
    envVars:
      - key: PYTHON_VERSION
        value: "3.11"

---

# .gitignore

Must contain:

__pycache__/
*.pyc
.env
chroma_db/

---

# Important Rules

Very important:

- code must work locally
- code must deploy on Render
- avoid unnecessary advanced features
- avoid bugs
- prioritize reliability over complexity
- clean code
- readable code
- professional academic presentation

This is for grading, not for startup production.

Keep it simple and safe.

---

# Final Goal

The final result must be:

- fully working locally
- pushable to GitHub
- deployable on Render
- professional enough for a master-level university assignment
- easy to explain in the PDF report

Build for maximum grade with minimum risk.