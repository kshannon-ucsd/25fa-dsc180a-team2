import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')

# List SQL files in order (adjust as needed for your pipeline)
sql_dir = 'scripts/sql/matviews/final_cohort_matviews'
sql_files = [
    '1first_icu_stay_matview.sql',
    '2adults_first_cohort_matview.sql',
    '3elixhauser_quan.sql',
    '4final_cohort_matview.sql'
]

engine = create_engine(DATABASE_URL)
with engine.connect() as conn:
    for sql_file in sql_files:
        with open(os.path.join(sql_dir, sql_file), 'r') as f:
            sql_code = f.read()
            conn.execute(sql_code)
    # Optional: Export the final result to CSV, e.g. from a materialized view
    df = pd.read_sql('SELECT * FROM final_cohort_view', conn)
    df.to_csv('assets/final_cohort.csv', index=False)
print("Cohort creation and export completed.")
