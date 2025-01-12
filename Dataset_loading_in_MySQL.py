import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

password = quote_plus('your password') 

# MySQL connection string
conn_string = 'mysql+pymysql://root:' + password + '@localhost/paintings'
db = create_engine(conn_string)
conn = db.connect()

# List of CSV filenames (without file extensions) that you want to insert into MySQL
files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size', 'subject', 'work']

# Path where the CSV files are stored
file_path_base = r'C:\Users\Hritik Kadam\Desktop\SQL\Famous Painting Case Study\\'

for file in files:
    # Construct the full file path
    file_path = file_path_base + file + '.csv'
    
    # Read the CSV file into a pandas DataFrame
    try:
        df = pd.read_csv(file_path)
        print(f"Loaded data from {file}.csv successfully.")
        
        # Insert data into MySQL (replace table if it exists)
        df.to_sql(file, con=conn, if_exists='replace', index=False)
        print(f"Data from {file}.csv inserted into MySQL table {file}.")
    
    except FileNotFoundError:
        print(f"Error: The file {file}.csv was not found.")
    except Exception as e:
        print(f"Error processing {file}.csv: {e}")

# Close the database connection
conn.close()
print("Database connection closed.")
