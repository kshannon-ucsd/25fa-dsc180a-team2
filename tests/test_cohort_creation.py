import os
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

csv_path = os.getenv('FINAL_COHORT_CSV', 'assets/final_cohort.csv')
if not os.path.exists(csv_path):
    print(f"ERROR: Cohort CSV does not exist at {csv_path}")
    exit(1)

df = pd.read_csv(csv_path)
print(f"Cohort CSV loaded. Shape: {df.shape}")
print(df.head())
