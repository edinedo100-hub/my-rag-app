import streamlit as st
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import SentenceTransformerEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_core.documents import Document

# ---------------------------------------------------------------------------
# Page configuration
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Global Logistics & International Business Knowledge Base",
    page_icon="🌍",
    layout="wide",
)

# ---------------------------------------------------------------------------
# Academic documents
# ---------------------------------------------------------------------------
DOCUMENTS = [
    """International logistics is the branch of management that coordinates the
    movement of goods, information, and financial resources across national
    borders. It involves transportation planning, customs documentation,
    multimodal routing, and compliance with international trade regulations.
    Modern international logistics relies on integrated information systems
    that connect shippers, carriers, freight forwarders, and customs
    authorities. Efficient international logistics reduces lead times, lowers
    landed costs, and strengthens competitiveness in global markets. Academic
    research highlights three pillars of success: network design, visibility,
    and risk management. Network design determines warehouse and port
    locations, visibility ensures real-time tracking of shipments, and risk
    management mitigates disruptions caused by political instability, natural
    disasters, or pandemics. Together these elements form the foundation of
    resilient cross-border supply chains.""",

    """Supply chain management (SCM) is the strategic coordination of
    procurement, production, inventory, and distribution activities across a
    network of suppliers and customers. The goal of SCM is to deliver the
    right product, in the right quantity, at the right place and time, while
    minimizing total cost. Contemporary SCM integrates demand forecasting,
    supplier relationship management, and lean operations. Scholars emphasize
    that value creation in supply chains depends on collaboration,
    information sharing, and trust among partners. Digital platforms and
    advanced analytics have transformed SCM into a data-driven discipline.
    Sustainability and ethical sourcing are increasingly embedded into supply
    chain strategies, reflecting stakeholder pressure and regulatory demands.
    A well-designed supply chain becomes a source of lasting competitive
    advantage.""",

    """Geopolitics exerts a profound influence on international business and
    logistics. Trade tensions, sanctions, and regional conflicts disrupt
    established supply routes and reshape sourcing strategies. Firms
    operating globally must monitor geopolitical risk indicators and develop
    contingency plans for scenarios such as tariff escalation, export
    controls, or border closures. Academic literature describes the recent
    shift from pure efficiency toward resilience, often achieved through
    nearshoring, friendshoring, and regional diversification. Geopolitical
    awareness is now considered a core competence for logistics managers.
    Companies increasingly work with political risk consultants and use
    scenario planning to stress-test their networks. Understanding the
    interaction between geography, policy, and commerce is essential for
    long-term strategic planning in international business.""",

    """Incoterms, published by the International Chamber of Commerce, are
    standardized trade terms that define the responsibilities of buyers and
    sellers in international transactions. They specify who arranges
    transportation, who pays freight and insurance, and where the risk of
    loss transfers between the parties. Common Incoterms include EXW, FOB,
    CIF, and DDP. Correct use of Incoterms prevents costly disputes and
    ensures clarity in contracts. Educational sources stress that Incoterms
    only govern the physical delivery of goods; they do not determine
    ownership or payment terms. The 2020 revision introduced updates
    reflecting modern transport practices, including electronic
    documentation. Mastery of Incoterms is a fundamental skill for
    international trade professionals, freight forwarders, and export
    managers.""",

    """Customs clearance is the administrative process of moving goods
    through a country's border controls. It involves the submission of
    import or export declarations, the payment of duties and taxes, and
    compliance with product-specific regulations such as health,
    safety, and origin requirements. Modern customs authorities rely on
    electronic single-window systems that consolidate documentation and
    accelerate processing. Delays in customs clearance can disrupt just-in-
    time supply chains and inflate logistics costs. Research highlights the
    role of Authorized Economic Operator programs in reducing inspection
    rates for trusted traders. Accurate tariff classification, valuation,
    and country-of-origin declaration are critical to avoid penalties.
    Effective customs management integrates legal compliance with strategic
    planning and close cooperation with licensed brokers.""",

    """Sustainability in logistics addresses the environmental and social
    impact of moving goods. Transportation accounts for a significant share
    of global greenhouse gas emissions, which has driven the industry to
    adopt alternative fuels, electric vehicles, and optimized routing
    algorithms. Sustainable logistics also considers packaging reduction,
    warehouse energy efficiency, and fair labor practices. Academic studies
    show that green logistics strategies can lower operating costs while
    improving brand reputation. Regulatory frameworks such as the European
    Green Deal and corporate ESG reporting standards encourage measurable
    emission reductions along the supply chain. Firms increasingly set
    science-based targets and pursue certifications like ISO 14001.
    Sustainability is no longer optional; it is a core criterion of modern
    logistics performance.""",

    """Digital transformation in logistics refers to the integration of
    technologies such as Internet of Things sensors, artificial
    intelligence, blockchain, and cloud computing into supply chain
    operations. These tools provide real-time visibility, predictive
    analytics, and secure data sharing across trading partners. Digital
    twins simulate warehouse and transportation networks, helping managers
    test scenarios before implementation. Academic research identifies
    digital maturity as a predictor of supply chain resilience. However,
    transformation projects frequently fail due to poor change management,
    data quality issues, or lack of interoperability between legacy
    systems. Successful adoption requires a clear digital strategy,
    skilled talent, and strong governance. Logistics firms that embrace
    digital innovation achieve faster decisions and higher customer
    satisfaction.""",

    """Reverse logistics manages the flow of products from the customer back
    to the manufacturer or an intermediate recovery facility. It covers
    returns, repairs, refurbishment, recycling, and responsible disposal.
    Efficient reverse logistics reduces waste, recovers residual value, and
    supports the circular economy. E-commerce growth has dramatically
    increased return volumes, challenging traditional networks designed
    primarily for outbound flows. Scholars emphasize that reverse logistics
    requires specialized processes for inspection, sorting, and
    re-marketing. Integration with forward logistics and robust
    information systems is essential. Environmental regulations, such as
    Extended Producer Responsibility, further motivate firms to invest in
    reverse capabilities. A well-managed return process enhances customer
    loyalty and contributes to sustainability goals.""",

    """Port congestion occurs when vessels, containers, or cargo accumulate
    at maritime terminals faster than they can be processed. Causes
    include demand surges, labor shortages, equipment breakdowns, and
    weather events. Congestion produces cascading effects: longer vessel
    waiting times, higher freight rates, equipment imbalances, and
    delayed deliveries inland. Research during recent global disruptions
    showed that even a few congested hubs can ripple through the entire
    world trade network. Mitigation strategies include port automation,
    appointment systems for trucks, improved hinterland connections, and
    diversification of gateway ports. Shippers adopt dynamic routing and
    safety stock policies to buffer against delays. Understanding port
    congestion is essential for planning reliable international supply
    chains.""",

    """Inventory management balances the cost of holding stock against the
    risk of stockouts. Core techniques include Economic Order Quantity,
    safety stock calculations, ABC classification, and just-in-time
    replenishment. In global operations, inventory decisions must account
    for long ocean lead times, currency fluctuations, and multi-echelon
    network structures. Advanced analytics and machine learning improve
    demand forecasting and dynamic reorder policies. Scholars describe
    inventory as both a buffer and a mirror of supply chain performance:
    excessive stock signals inefficiency, while frequent shortages reveal
    forecasting or supplier issues. Effective inventory management
    contributes to service levels, working capital optimization, and
    sustainability by reducing obsolescence. It is a central topic in
    operations and international business education.""",
]

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
    "Inventory management",
]

# ---------------------------------------------------------------------------
# Vector store (cached once per session)
# ---------------------------------------------------------------------------
@st.cache_resource(show_spinner="Building the knowledge base...")
def build_vectorstore():
    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    docs = [Document(page_content=text) for text in DOCUMENTS]
    chunks = splitter.split_documents(docs)

    embeddings = SentenceTransformerEmbeddings(model_name="all-MiniLM-L6-v2")
    vectordb = Chroma.from_documents(
        chunks,
        embedding=embeddings,
        persist_directory="chroma_db",
    )
    return vectordb


# ---------------------------------------------------------------------------
# Pages
# ---------------------------------------------------------------------------
def home_page():
    st.title("🌍 Global Logistics & International Business Knowledge Base")
    st.subheader("A simple RAG application for academic semantic search")

    st.markdown(
        """
        This application allows you to explore a curated collection of
        academic-style documents about **global logistics** and
        **international business**. Instead of keyword matching, it uses
        **semantic search** to retrieve the passages most related in meaning
        to your question.
        """
    )

    st.markdown("### Technologies used")
    st.markdown(
        """
        - **Streamlit** — web interface
        - **LangChain** — orchestration and text splitting
        - **ChromaDB** — vector database
        - **Sentence Transformers** (`all-MiniLM-L6-v2`) — embeddings
        - **GitHub** — version control
        - **Render.com** — deployment
        """
    )

    st.markdown("### Searchable topics")
    cols = st.columns(2)
    for i, topic in enumerate(TOPICS):
        cols[i % 2].markdown(f"- {topic}")


def search_page():
    st.title("🔎 Semantic Search")
    st.markdown(
        "Ask a question in natural language. The system returns the **top 3** "
        "most relevant passages from the knowledge base."
    )

    vectordb = build_vectorstore()

    query = st.text_input(
        "Your question",
        placeholder="e.g. How does port congestion affect global supply chains?",
    )

    if query:
        with st.spinner("Searching the knowledge base..."):
            results = vectordb.similarity_search_with_score(query, k=3)

        if not results:
            st.warning("No results found.")
            return

        st.markdown("### Top 3 relevant results")
        for i, (doc, score) in enumerate(results, start=1):
            with st.container(border=True):
                st.markdown(f"**Result {i}** — similarity distance: `{score:.4f}`")
                st.write(doc.page_content.strip())


# ---------------------------------------------------------------------------
# Sidebar navigation
# ---------------------------------------------------------------------------
st.sidebar.title("🌍 Navigation")
page = st.sidebar.radio("Go to", ["Home", "Search"])

st.sidebar.markdown("---")
st.sidebar.caption(
    "Master-level academic RAG project — Global Logistics & International "
    "Business."
)

if page == "Home":
    home_page()
else:
    search_page()
