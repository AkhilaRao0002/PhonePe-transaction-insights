<<<<<<< HEAD
import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="PhonePe Insights Dashboard", layout="wide")

# ---------------- TITLE ----------------
st.title("📊 PhonePe Data Insights Dashboard")

# ---------------- LOAD DATA ----------------
@st.cache_data
def load_data(path):
    return pd.read_csv(path)

# Example: update paths according to your 9 files
txn = load_data("data/aggregated_transaction.csv")
user = load_data("data/aggregated_user.csv")
map_df = load_data("data/map_transaction.csv")
top = load_data("data/top_transaction.csv")

# ---------------- SIDEBAR ----------------
st.sidebar.title("Filters")

year = st.sidebar.selectbox("Select Year", sorted(txn["year"].unique()))

txn = txn[txn["year"] == year]

# ---------------- KPI METRICS ----------------
st.subheader("📌 Key Metrics")

col1, col2, col3 = st.columns(3)

col1.metric("Total Transactions", txn["count"].sum())
col2.metric("Total Amount", txn["amount"].sum())
col3.metric("Avg Transaction Value", round(txn["amount"].sum()/txn["count"].sum(), 2))

# ---------------- STATE PERFORMANCE ----------------
st.subheader("🗺️ Top States by Transactions")

state_df = txn.groupby("state")["amount"].sum().reset_index()
top_states = state_df.sort_values("amount", ascending=False).head(10)

fig1 = px.bar(top_states, x="state", y="amount", color="state")
st.plotly_chart(fig1, use_container_width=True)

# ---------------- BRAND ANALYSIS ----------------
st.subheader("📱 Brand Performance")

brand_df = user.groupby("brand")["count"].sum().reset_index()
top_brands = brand_df.sort_values("count", ascending=False).head(10)

fig2 = px.bar(top_brands, x="brand", y="count", color="brand")
st.plotly_chart(fig2, use_container_width=True)

# ---------------- TRANSACTION TYPE ----------------
st.subheader("💳 Transaction Type Distribution")

type_df = txn.groupby("type")["count"].sum().reset_index()

fig3 = px.pie(type_df, names="type", values="count")
st.plotly_chart(fig3)

# ---------------- TREND ANALYSIS ----------------
st.subheader("📈 Year-wise Trend")

trend = txn.groupby("year")["amount"].sum().reset_index()

fig4 = px.line(trend, x="year", y="amount", markers=True)
st.plotly_chart(fig4)

# ---------------- DISTRICT ANALYSIS ----------------
st.subheader("📍 Top Districts")

district_df = map_df.groupby("name")["amount"].sum().reset_index()
top_districts = district_df.sort_values("amount", ascending=False).head(10)

fig5 = px.bar(top_districts, x="name", y="amount")
st.plotly_chart(fig5, use_container_width=True)

# ---------------- FOOTER ----------------
=======
import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="PhonePe Insights Dashboard", layout="wide")

# ---------------- TITLE ----------------
st.title("📊 PhonePe Data Insights Dashboard")

# ---------------- LOAD DATA ----------------
@st.cache_data
def load_data(path):
    return pd.read_csv(path)

# Example: update paths according to your 9 files
txn = load_data("data/aggregated_transaction.csv")
user = load_data("data/aggregated_user.csv")
map_df = load_data("data/map_transaction.csv")
top = load_data("data/top_transaction.csv")

# ---------------- SIDEBAR ----------------
st.sidebar.title("Filters")

year = st.sidebar.selectbox("Select Year", sorted(txn["year"].unique()))

txn = txn[txn["year"] == year]

# ---------------- KPI METRICS ----------------
st.subheader("📌 Key Metrics")

col1, col2, col3 = st.columns(3)

col1.metric("Total Transactions", txn["count"].sum())
col2.metric("Total Amount", txn["amount"].sum())
col3.metric("Avg Transaction Value", round(txn["amount"].sum()/txn["count"].sum(), 2))

# ---------------- STATE PERFORMANCE ----------------
st.subheader("🗺️ Top States by Transactions")

state_df = txn.groupby("state")["amount"].sum().reset_index()
top_states = state_df.sort_values("amount", ascending=False).head(10)

fig1 = px.bar(top_states, x="state", y="amount", color="state")
st.plotly_chart(fig1, use_container_width=True)

# ---------------- BRAND ANALYSIS ----------------
st.subheader("📱 Brand Performance")

brand_df = user.groupby("brand")["count"].sum().reset_index()
top_brands = brand_df.sort_values("count", ascending=False).head(10)

fig2 = px.bar(top_brands, x="brand", y="count", color="brand")
st.plotly_chart(fig2, use_container_width=True)

# ---------------- TRANSACTION TYPE ----------------
st.subheader("💳 Transaction Type Distribution")

type_df = txn.groupby("type")["count"].sum().reset_index()

fig3 = px.pie(type_df, names="type", values="count")
st.plotly_chart(fig3)

# ---------------- TREND ANALYSIS ----------------
st.subheader("📈 Year-wise Trend")

trend = txn.groupby("year")["amount"].sum().reset_index()

fig4 = px.line(trend, x="year", y="amount", markers=True)
st.plotly_chart(fig4)

# ---------------- DISTRICT ANALYSIS ----------------
st.subheader("📍 Top Districts")

district_df = map_df.groupby("name")["amount"].sum().reset_index()
top_districts = district_df.sort_values("amount", ascending=False).head(10)

fig5 = px.bar(top_districts, x="name", y="amount")
st.plotly_chart(fig5, use_container_width=True)

# ---------------- FOOTER ----------------
>>>>>>> 5e2e13a57ef28f8836bf2d48bfb4b87913ce7236
st.markdown("### ✅ Insights Dashboard Built from PhonePe Data Analysis")