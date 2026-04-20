"""
AI Explorer -- Interactive Workshop App
FAMNIT AI Course - Day 2

An interactive Streamlit application for exploring:
- Embeddings and semantic similarity
- Document chunking strategies
- Vector search with ChromaDB
"""

import streamlit as st
import numpy as np
import re

# =========================================================================
# PAGE CONFIG (must be first Streamlit command)
# =========================================================================
st.set_page_config(page_title="AI Explorer", page_icon="🧠", layout="wide")

# =========================================================================
# CUSTOM CSS
# =========================================================================
st.markdown('''
<style>
    .stApp {
        background-color: #0f0f1a;
    }
    section[data-testid="stSidebar"] {
        background-color: #0a0a14;
        border-right: 1px solid #1a1a2e;
    }
    h1 {
        background: linear-gradient(120deg, #4285f4, #8b5cf6);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800 !important;
    }
    div[data-testid="metric-container"] {
        background-color: #1a1a2e;
        border: 1px solid #2a2a4e;
        border-radius: 10px;
        padding: 15px;
    }
    .stButton > button {
        background: linear-gradient(135deg, #4285f4, #8b5cf6);
        color: white;
        border: none;
        border-radius: 8px;
        font-weight: 600;
    }
    .stCodeBlock { border-radius: 10px; }
    .stAlert { border-radius: 10px; }
    .stTabs [data-baseweb="tab-list"] { gap: 8px; }
    .stTabs [data-baseweb="tab"] { border-radius: 8px; padding: 8px 16px; }
    .workshop-card {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        border: 1px solid #2a2a4e;
        border-radius: 12px;
        padding: 20px;
        margin: 10px 0;
        text-align: center;
    }
</style>
''', unsafe_allow_html=True)

# =========================================================================
# CACHED RESOURCES
# =========================================================================

@st.cache_resource(show_spinner="Loading embedding model...")
def load_model():
    from langchain_huggingface import HuggingFaceEmbeddings
    return HuggingFaceEmbeddings(model_name="all-MiniLM-L6-v2")


# =========================================================================
# SAMPLE TEXT
# =========================================================================
LONG_SAMPLE_TEXT = """Artificial Intelligence (AI) is a broad field of computer science focused on \
creating intelligent machines capable of performing tasks that typically require \
human intelligence. These tasks include learning from experience, understanding \
natural language, recognizing patterns, making decisions, and solving complex \
problems. The history of AI dates back to the 1950s when pioneers like Alan \
Turing proposed the famous Turing Test as a measure of machine intelligence.

Machine learning, a subset of AI, focuses on algorithms that improve through \
experience. Instead of being explicitly programmed, these systems learn patterns \
from data. There are three main types: supervised learning (learning from labeled \
examples), unsupervised learning (finding hidden patterns), and reinforcement \
learning (learning through trial and error). Deep learning, which uses neural \
networks with many layers, has achieved remarkable results in image recognition \
and natural language processing.

Natural Language Processing (NLP) is the branch of AI dealing with the \
interaction between computers and human language. Modern NLP relies heavily on \
transformer models, which use attention mechanisms to understand context and \
relationships between words. Embeddings, which convert text into numerical \
vectors, are fundamental to how these models represent meaning. This is what \
powers search engines, chatbots, and translation systems today."""


# =========================================================================
# SIDEBAR
# =========================================================================
st.sidebar.title("AI Explorer")
page = st.sidebar.radio(
    "Navigate",
    ["Home", "Embeddings", "Chunking", "Vector Search"]
)

# =========================================================================
# HOME PAGE
# =========================================================================
if page == "Home":
    st.title("AI Explorer")
    st.subheader("Interactive Workshop -- Day 2")

    st.markdown("---")

    # Visual workflow diagram
    c1, c2, c3, c4 = st.columns(4)
    for col, (title, icon, desc) in zip(
        [c1, c2, c3, c4],
        [
            ("Raw Text", "📄", "Documents and articles"),
            ("Chunking", "✂️", "Split into pieces"),
            ("Embeddings", "🔢", "Text becomes vectors"),
            ("Vector Search", "🔍", "Search by meaning"),
        ]
    ):
        with col:
            st.markdown(f'''
            <div class="workshop-card">
            <h4>{title}</h4>
            <p style="font-size:2em;">{icon}</p>
            <p>{desc}</p>
            </div>
            ''', unsafe_allow_html=True)

    st.markdown("---")

    st.markdown("""
    ### Learning Objectives

    By the end of this workshop you will be able to:

    - **Explain** what embeddings are and why they capture semantic meaning
    - **Compare** different chunking strategies and know when to use each
    - **Build** a vector database with ChromaDB and perform semantic search
    - **Understand** how RAG (Retrieval-Augmented Generation) works under the hood

    ### Key Idea

    > **Embeddings** convert text into numbers (vectors) that capture *meaning*.
    > Similar texts get similar vectors. This is the foundation of modern AI
    > search, recommendation systems, and RAG.

    Click **"Embeddings"** in the sidebar to begin.
    """)

# =========================================================================
# EMBEDDINGS PAGE
# =========================================================================
elif page == "Embeddings":
    st.title("What Are Embeddings?")
    st.markdown("""
    An **embedding** turns text into a list of numbers (a vector) that captures its **meaning**.
    Similar texts get similar vectors.

    ```
    "The cat sat on the mat"    --> [0.12, -0.45, 0.78, ...] (384 numbers)
    "A kitten rested on a rug"  --> [0.11, -0.43, 0.76, ...] (similar!)
    "Stock prices rose today"   --> [-0.67, 0.22, -0.11, ...] (very different)
    ```
    """)

    st.divider()

    # --- Part 1: Compare two texts ---
    st.subheader("Part 1: Compare two texts")

    col1, col2 = st.columns(2)
    with col1:
        text_a = st.text_input("Text A", "I love machine learning")
    with col2:
        text_b = st.text_input("Text B", "AI is fascinating")

    if st.button("Compare", type="primary"):
        model = load_model()
        vectors = np.array(model.embed_documents([text_a, text_b]))

        from sklearn.metrics.pairwise import cosine_similarity
        sim = cosine_similarity(vectors)[0, 1]

        col_metric, col_interp = st.columns(2)
        with col_metric:
            st.metric("Cosine Similarity", f"{sim:.3f}")
        with col_interp:
            if sim > 0.7:
                st.success("These texts are very similar in meaning!")
            elif sim > 0.4:
                st.info("These texts share some meaning.")
            else:
                st.warning("These texts are quite different.")

        st.write(f"Each text was converted to a vector of **{len(vectors[0])}** numbers.")

        with st.expander("See the raw vectors"):
            st.code(f"Text A: {vectors[0][:10].tolist()}... ({len(vectors[0])} dims)")
            st.code(f"Text B: {vectors[1][:10].tolist()}... ({len(vectors[1])} dims)")

    st.divider()

    # --- Part 2: Similarity matrix ---
    st.subheader("Part 2: Similarity matrix")
    st.markdown("Enter multiple texts (one per line) to see how they all relate.")

    extra_texts = st.text_area(
        "Texts to compare (one per line)",
        "I love machine learning\nAI is fascinating\n"
        "The weather is sunny today\nNeural networks learn from data\n"
        "I need to buy groceries\nIt is a beautiful warm day outside",
        height=150
    )

    if st.button("Build Similarity Matrix", type="primary"):
        model = load_model()
        all_texts = [t.strip() for t in extra_texts.strip().split("\n") if t.strip()]

        if len(all_texts) < 2:
            st.error("Please enter at least 2 texts.")
        else:
            with st.spinner("Embedding texts..."):
                vectors = np.array(model.embed_documents(all_texts))
                from sklearn.metrics.pairwise import cosine_similarity
                sim_matrix = cosine_similarity(vectors)

            import plotly.express as px
            labels = [t[:40] + ("..." if len(t) > 40 else "") for t in all_texts]
            fig = px.imshow(
                sim_matrix, x=labels, y=labels,
                text_auto=".2f", color_continuous_scale="Blues",
                title="Cosine Similarity Matrix", aspect="auto"
            )
            fig.update_layout(height=500)
            st.plotly_chart(fig, use_container_width=True)

            st.info(f"Embedded {len(all_texts)} texts into {vectors.shape[1]}-dimensional vectors.")

# =========================================================================
# CHUNKING PAGE
# =========================================================================
elif page == "Chunking":
    st.title("Chunking Strategies")
    st.markdown("""
    Real documents are too long for embedding models. We need to split them into
    **chunks** -- smaller pieces that can each be converted to a vector.

    The way you chunk affects search quality:
    - **Too small** = chunks lose context
    - **Too big** = meaning gets diluted
    - **Just right** = each chunk captures one coherent idea
    """)

    sample_text = st.text_area("Paste a long text to chunk:",
                               value=LONG_SAMPLE_TEXT, height=200)
    st.write(f"**Total length:** {len(sample_text)} characters")
    st.divider()

    tab1, tab2, tab3 = st.tabs(
        ["Fixed-Size Chunking", "Sentence-Based Chunking", "LangChain Recursive"]
    )

    # --- Fixed-size ---
    with tab1:
        st.markdown("""
        **Fixed-size chunking** splits text every N characters, regardless of content.
        Simple but may cut words or sentences in half.
        """)
        chunk_size = st.slider("Chunk size (characters)", 50, 500, 200, key="fixed_size")
        overlap = st.slider("Overlap (characters)", 0, 100, 30, key="fixed_overlap")

        chunks = []
        start = 0
        while start < len(sample_text):
            chunks.append(sample_text[start:start + chunk_size])
            start += chunk_size - overlap
            if overlap >= chunk_size:
                break

        st.write(f"**{len(chunks)} chunks** created")
        for i, chunk in enumerate(chunks):
            st.text_area(f"Chunk {i+1} ({len(chunk)} chars)", chunk,
                         height=80, key=f"fixed_{i}", disabled=True)

    # --- Sentence-based ---
    with tab2:
        st.markdown("""
        **Sentence-based chunking** splits at sentence boundaries (periods, etc.).
        Each chunk is a complete sentence.
        """)
        sentences = re.split(r'(?<=[.!?])\s+', sample_text.strip())
        sentences = [s.strip() for s in sentences if s.strip()]

        st.write(f"**{len(sentences)} sentences** found")
        for i, sent in enumerate(sentences):
            st.text_area(f"Sentence {i+1} ({len(sent)} chars)", sent,
                         height=60, key=f"sent_{i}", disabled=True)

    # --- LangChain Recursive ---
    with tab3:
        st.markdown("""
        **LangChain RecursiveCharacterTextSplitter** is the smartest approach.
        It tries to split at paragraph boundaries first, then sentences, then words.
        """)
        rc_size = st.slider("Chunk size", 50, 500, 200, key="rc_size")
        rc_overlap = st.slider("Overlap", 0, 100, 30, key="rc_overlap")

        from langchain.text_splitter import RecursiveCharacterTextSplitter
        splitter = RecursiveCharacterTextSplitter(
            chunk_size=rc_size, chunk_overlap=rc_overlap
        )
        rc_chunks = splitter.split_text(sample_text)

        st.write(f"**{len(rc_chunks)} chunks** created")
        for i, chunk in enumerate(rc_chunks):
            st.text_area(f"Chunk {i+1} ({len(chunk)} chars)", chunk,
                         height=80, key=f"rc_{i}", disabled=True)

# =========================================================================
# VECTOR SEARCH PAGE
# =========================================================================
elif page == "Vector Search":
    st.title("Vector Search with ChromaDB")
    st.markdown("""
    A **vector database** stores embeddings and searches by **meaning**, not keywords.

    **Traditional search:** *"Does the document contain the exact words I typed?"*

    **Vector search:** *"Does the document mean something similar to what I typed?"*
    """)

    # Knowledge base
    documents = [
        "Black holes are regions of spacetime where gravity is so strong that nothing can escape.",
        "DNA carries the genetic instructions for the development and functioning of all living organisms.",
        "Machine learning algorithms learn patterns from data without being explicitly programmed.",
        "Quantum computers use qubits that can exist in multiple states simultaneously.",
        "Neural networks are computing systems inspired by the biological neurons in the human brain.",
        "Photosynthesis is the process by which plants convert sunlight into chemical energy.",
        "The theory of relativity describes the relationship between space, time, and gravity.",
        "Antibiotics are medicines that fight bacterial infections in humans and animals.",
        "Climate change refers to long-term shifts in global temperatures and weather patterns.",
        "The Internet connects billions of devices worldwide through a network of networks.",
    ]

    st.markdown("**Documents in our knowledge base:**")
    for i, doc in enumerate(documents, 1):
        st.markdown(f"{i}. {doc}")

    st.divider()

    query = st.text_input("Search query",
                          placeholder="e.g., 'How do computers learn?'")
    num_results = st.slider("Number of results", 1, 5, 3, key="num_results")

    if st.button("Search", type="primary") and query:
        model = load_model()

        with st.spinner("Building vector database and searching..."):
            from langchain_community.vectorstores import Chroma
            vectorstore = Chroma.from_texts(texts=documents, embedding=model)
            results = vectorstore.similarity_search_with_relevance_scores(
                query, k=num_results
            )

        st.subheader("Results (ranked by meaning similarity)")
        for i, (doc, score) in enumerate(results, 1):
            pct = max(0, score) * 100
            col_text, col_score = st.columns([4, 1])
            with col_text:
                st.markdown(f"**{i}.** {doc.page_content}")
            with col_score:
                st.metric("Relevance", f"{pct:.0f}%")
            st.progress(min(1.0, max(0, score)))

        st.divider()
        st.info("""
        **Try these queries to see semantic search in action:**
        - "How do computers learn?" -- finds ML and neural network docs
        - "What makes plants grow?" -- finds photosynthesis
        - "Space and the universe" -- finds black holes and relativity
        - "Fighting disease" -- finds antibiotics
        - "Global warming" -- finds climate change
        """)
