# Global Logistics & International Business Knowledge Base

A semantic search application that implements the retrieval stage of a
Retrieval-Augmented Generation (RAG) pipeline. Users ask questions in natural
language and the system returns the passages from a curated corpus on global
logistics and international business that are closest in *meaning* to the
question, rather than those that merely share keywords.

## How it works

```
documents ──► chunking ──► sentence embeddings ──► Chroma vector store
                                                          │
user question ──► sentence embedding ──► nearest-neighbour search ──► top-3 passages
```

1. **Corpus.** Ten academic-style texts (≈100–150 words each) cover
   international logistics, supply chain management, geopolitics, Incoterms,
   customs clearance, sustainability, digital transformation, reverse
   logistics, port congestion and inventory management. Each document is
   tagged with its topic as metadata.
2. **Chunking.** `RecursiveCharacterTextSplitter` with `chunk_size=500` and
   `chunk_overlap=50` (21 chunks in total). The chunks are small enough for
   precise retrieval, and the overlap keeps sentences that cross a chunk
   boundary.
3. **Embedding.** Each chunk is encoded with the Sentence Transformers model
   `paraphrase-MiniLM-L3-v2`, which produces 384-dimensional vectors. This
   lightweight model was chosen so the app fits within the memory limits of a
   free cloud hosting tier.
4. **Indexing and retrieval.** The vectors are stored in an in-memory Chroma
   collection. A query is embedded with the same model, and the three nearest
   chunks are returned with their distance scores (lower means more similar)
   and source topic.

The vector store is built once per server process and cached with
`st.cache_resource`.

## Tech stack

| Component | Role |
|---|---|
| Streamlit | Web interface (Home and Search pages) |
| LangChain | Document model, text splitting and vector store integration |
| ChromaDB | Vector database |
| Sentence Transformers | Text embeddings |
| Render.com | Deployment (`render.yaml`) |

## Running locally

Requires Python 3.11.

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
streamlit run app.py
```

The app opens at http://localhost:8501. The embedding model (~70 MB) is
downloaded on first launch.

## Deployment

`render.yaml` defines a Render web service that installs the dependencies and
starts Streamlit on the port Render assigns.

## Limitations and possible extensions

- **No generation step.** The app returns the retrieved passages directly.
  The natural next step is to pass them as context to a large language model
  so it can write a grounded, cited answer.
- **Small, static corpus.** The documents are embedded in the source code.
  Ingesting real literature (PDFs or abstracts) with a persistent index would
  make the system useful for actual research.
- **No evaluation.** Retrieval quality has not been measured. A labelled set
  of question and passage pairs would allow reporting metrics such as
  Recall@k and MRR, and comparing chunking strategies and embedding models.
