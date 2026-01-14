import glob
from dotenv import load_dotenv
import os
import kagglehub
import snowflake.connector



def get_snowflake_connection() -> snowflake.connector.SnowflakeConnection:
    
    load_dotenv()  # reads .env

    conn_params = {
        "account": os.getenv("SNOWFLAKE_ACCOUNT"),
        "user": os.getenv("SNOWFLAKE_USER"),
        "password": os.getenv("SNOWFLAKE_PASSWORD"),
        "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
        "database": os.getenv("SNOWFLAKE_DATABASE"),
        "schema": os.getenv("SNOWFLAKE_SCHEMA"),
        "role": os.getenv("SNOWFLAKE_ROLE"),
    }
        
    return snowflake.connector.connect(**conn_params) 


def extract_csv_from_kaggle() -> str:
    path = kagglehub.dataset_download("zynicide/wine-reviews")
    print("Path to dataset files:", path)
    return  list(glob.glob(os.path.join(path, "**", "*.csv"), recursive=True))[0]

def load_csv_to_raw(conn, csv_file_path) -> None:
    
    stage = "DEMO_PIPELINE.RAW.KAGGLE_STAGE"
    file_format = "DEMO_PIPELINE.RAW.CSV_FMT"
    target_table = "DEMO_PIPELINE.RAW.WINE_REVIEWS_RAW"


    # file:///home/user/path/file.csv
    abs_path = os.path.abspath(csv_file_path)
    put_uri = "file://" + abs_path
    
    try:
        cur = conn.cursor()

        # 1) PUT: upload local file -> internal stage
        cur.execute(f"""
            PUT '{put_uri}'
            @{stage}
            AUTO_COMPRESS=TRUE
            OVERWRITE=TRUE
        """)
        put_results = cur.fetchall()
        print("PUT results:", put_results)

        # 2) COPY INTO: stage -> table        
        staged_filename = put_results[0][1]          # 'winemag-data_first150k.csv.gz'
        staged_path = f"@{stage}/{staged_filename}"

        cur.execute(f"TRUNCATE TABLE {target_table}")

        cur.execute(f"""
            COPY INTO {target_table}
            FROM {staged_path}
            FILE_FORMAT = (FORMAT_NAME = {file_format})
            ON_ERROR = 'ABORT_STATEMENT'
        """)
        copy_results = cur.fetchall()
        print("COPY results:", copy_results)

        conn.commit()

    finally:
        cur.close()




if __name__ == "__main__":
    conn = get_snowflake_connection()
    print("Successfully connected to Snowflake.")
    local_csv_path = extract_csv_from_kaggle()
    print("Local CSV path:", local_csv_path)
    load_csv_to_raw(conn, local_csv_path)
    print("Data loaded into Snowflake raw table successfully.")
    conn.close()