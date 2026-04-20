import streamlit as st

st.set_page_config(page_title="Global Logistics & International Business Knowledge Base", layout="wide")
st.title("Global Logistics & International Business Knowledge Base")
st.write("""
Welcome to the RAG-powered knowledge base for global logistics and international business. Use the sidebar to navigate and search academic documents semantically.
""")

# --- Imports ---
import streamlit as st
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import SentenceTransformerEmbeddings
from langchain_text_splitters import RecursiveCharacterTextSplitter
import os

# --- Constants ---
PROJECT_TITLE = "🌍 Global Logistics & International Business Knowledge Base"
TOPICS = [
    "International logistics",
    "Supply chain management",
    "Geopolitics",
    "Incoterms",
    "Customs clearance",
    "Sustainability in logistics",
    "Digital transformation",
    "Reverse logistics",
    "Port congestion",
    "Inventory management"
]
CHROMA_DIR = "chroma_db/"
EMBEDDING_MODEL = "all-MiniLM-L6-v2"
CHUNK_SIZE = 500
CHUNK_OVERLAP = 50

# --- Academic Documents ---
DOCUMENTS = [
    "International logistics involves the management of goods and services across international borders. It requires coordination among various stakeholders, including suppliers, carriers, customs authorities, and end customers. Effective international logistics ensures timely delivery, cost efficiency, and compliance with regulations, making it a critical component of global trade.",
    "Supply chain management encompasses the planning and oversight of all activities involved in sourcing, procurement, conversion, and logistics management. It integrates supply and demand management within and across companies, aiming to optimize efficiency, reduce costs, and enhance customer satisfaction.",
    "Geopolitics plays a significant role in global logistics. Political stability, trade agreements, tariffs, and international relations can impact supply chains, causing disruptions or creating opportunities. Understanding geopolitical risks is essential for resilient logistics strategies.",
    "Incoterms are standardized international commercial terms published by the International Chamber of Commerce. They define the responsibilities of buyers and sellers in the delivery of goods, clarifying who is responsible for shipping, insurance, and tariffs at each stage of the transaction.",
    "Customs clearance is the process of passing goods through customs so they can enter or leave a country. It involves preparing and submitting documentation, paying duties and taxes, and ensuring compliance with import/export regulations. Efficient customs clearance minimizes delays and costs.",
    "Sustainability in logistics focuses on reducing the environmental impact of transportation and warehousing. Strategies include optimizing routes, using eco-friendly packaging, and adopting alternative fuels. Sustainable logistics practices are increasingly important for regulatory compliance and corporate responsibility.",
    "Digital transformation in logistics leverages technologies such as IoT, AI, and blockchain to enhance visibility, efficiency, and decision-making. Automation and real-time data analytics enable proactive management of logistics operations, reducing errors and improving service quality.",
    "Reverse logistics refers to the process of moving goods from their final destination back to the manufacturer or distributor for returns, repairs, recycling, or disposal. Effective reverse logistics can recover value, reduce waste, and improve customer satisfaction.",
    "Port congestion occurs when the volume of cargo exceeds a port’s handling capacity, leading to delays and increased costs. Causes include labor shortages, equipment failures, and surges in demand. Managing port congestion requires collaboration among stakeholders and investment in infrastructure.",
    "Inventory management is the supervision of non-capitalized assets and stock items. It involves balancing the costs of holding inventory with the need to meet customer demand. Advanced inventory management techniques use forecasting and automation to optimize stock levels."
]

# --- Embedding & Vector Store Setup ---
@st.cache_resource(show_spinner=False)
def get_vectorstore():
    # Split documents
    splitter = RecursiveCharacterTextSplitter(chunk_size=CHUNK_SIZE, chunk_overlap=CHUNK_OVERLAP)
    docs = []
    for i, doc in enumerate(DOCUMENTS):
        for chunk in splitter.split_text(doc):
            docs.append({"page_content": chunk, "metadata": {"source": f"Doc {i+1}"}})
    # Embeddings
    embeddings = SentenceTransformerEmbeddings(model_name=EMBEDDING_MODEL)
    # Vector DB
    if not os.path.exists(CHROMA_DIR):
        os.makedirs(CHROMA_DIR)
    vectordb = Chroma.from_documents([d["page_content"] for d in docs], embeddings, persist_directory=CHROMA_DIR, metadatas=[d["metadata"] for d in docs])
    return vectordb

vectordb = get_vectorstore()

# --- Streamlit UI ---
st.set_page_config(page_title=PROJECT_TITLE, layout="wide")

with st.sidebar:
    st.title("🌍 RAG Knowledge Base")
    page = st.radio("Navigation", ["Home", "Search"], index=0)
    st.markdown("---")
    st.caption("Built with Streamlit, LangChain, ChromaDB, Sentence Transformers.")

if page == "Home":
    st.title(PROJECT_TITLE)
    st.markdown("""
**Welcome!** This Retrieval-Augmented Generation (RAG) web app lets you semantically search academic documents about global logistics and international business. Designed for clarity, reliability, and academic excellence.
    """)
    st.subheader("Technologies Used")
    st.markdown("- Streamlit\n- LangChain\n- ChromaDB\n- Sentence Transformers\n- Python 3.11\n- Render.com deployment")
    st.subheader("Searchable Topics")
    st.markdown("\n".join([f"- {t}" for t in TOPICS]))

elif page == "Search":
    st.title("Semantic Search")
    st.write("Enter a question or topic to search the academic knowledge base.")
    query = st.text_input("Your question:")
    if query:
        with st.spinner("Searching..."):
            results = vectordb.similarity_search(query, k=3)
        st.success(f"Top 3 results for: '{query}'")
        for i, res in enumerate(results, 1):
            st.markdown(f"**Result {i}:**")
            st.write(res.page_content)
            st.caption(res.metadata.get("source", ""))
