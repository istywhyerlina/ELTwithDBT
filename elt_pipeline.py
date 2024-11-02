import luigi # type: ignore
from datetime import datetime
import logging
import sentry_sdk
import time
import pandas as pd # type: ignore
import sqlalchemy
from pipeline.utils.db_conn import db_connection
from pipeline.utils.read_sql import read_sql_file
import os
from sqlalchemy.orm import sessionmaker
from typing import TypeVar, Callable
import subprocess as sp
from pipeline.utils.delete_temp_data import delete_temp
T = TypeVar("T")




# Define DIR
SENTRY_DSN = os.getenv("SENTRY_DSN")
DIR_ROOT_PROJECT = os.getenv("DIR_ROOT_PROJECT")
DIR_TEMP_LOG = os.getenv("DIR_TEMP_LOG")
DIR_TEMP_DATA = os.getenv("DIR_TEMP_DATA")
DIR_EXTRACT_QUERY = os.getenv("DIR_EXTRACT_QUERY")
DIR_LOAD_QUERY = os.getenv("DIR_LOAD_QUERY")
SENTRY_DSN = os.getenv("SENTRY_DSN")

# Track the error using sentry
sentry_sdk.init(
    dsn = f"{SENTRY_DSN}"
)


class Extract(luigi.Task):
    
    # Define tables to be extracted from db sources
    tables_to_extract = ['public.aircrafts', 
                         'public.airlines', 
                         'public.airports',
                         'public.customers',
                         'public.flight_bookings2',
                         'public.hotel_bookings2',
                         'public.hotel']
    
    def requires(self):
        pass


    def run(self):        
        try:
            # Configure logging
            logging.basicConfig(filename = f'{DIR_TEMP_LOG}/logs.log', 
                                level = logging.INFO, 
                                format = '%(asctime)s - %(levelname)s - %(message)s')
            
            # Define db connection engine
            src_engine, _ = db_connection()
            conn=src_engine.connect()
            
            # Define the query using the SQL content
            extract_query = read_sql_file(
                file_path = f'{DIR_EXTRACT_QUERY}/all-tables.sql'
            )
            
            start_time = time.time()  # Record start time
            logging.info("==================================STARTING EXTRACT DATA=======================================")
            
            for index, table_name in enumerate(self.tables_to_extract):
                try:
                    # Read data into DataFrame
                    df = pd.read_sql_query(extract_query.format(table_name = table_name), con=conn.connection)

                    if table_name=="public.flight_bookings2":
                    # Write DataFrame to CSV
                        df.to_csv(f"{DIR_TEMP_DATA}/public.flight_bookings.csv", index=False)
                    elif table_name=="public.hotel_bookings2":
                        df.to_csv(f"{DIR_TEMP_DATA}/public.hotel_bookings.csv", index=False)
                    else:
                        df.to_csv(f"{DIR_TEMP_DATA}/{table_name}.csv", index=False)

                    logging.info(f"EXTRACT '{table_name}' - SUCCESS.")
                    
                except Exception:
                    logging.error(f"EXTRACT '{table_name}' - FAILED.")  
                    raise Exception(f"Failed to extract '{table_name}' tables")
            
            logging.info(f"Extract All Tables From Sources - SUCCESS")
            
            end_time = time.time()  # Record end time
            execution_time = end_time - start_time  # Calculate execution time
            
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Extract'],
                'status' : ['Success'],
                'execution_time': [execution_time]
            }
            
            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write DataFrame to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/extract-summary.csv", index = False)
                    
        except Exception:   
            logging.info(f"Extract All Tables From Sources - FAILED")
             
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Extract'],
                'status' : ['Failed'],
                'execution_time': [0]
            }
            
            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write DataFrame to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/extract-summary.csv", index = False)
            
            # Write exception
            raise Exception(f"FAILED to execute EXTRACT TASK !!!")
        
        logging.info("==================================ENDING EXTRACT DATA=======================================")
                
    def output(self):
        outputs = []
        for table_name in self.tables_to_extract:
            if table_name=="public.flight_bookings2":
                outputs.append(luigi.LocalTarget(f'{DIR_TEMP_DATA}/public.flight_bookings.csv'))
            elif table_name=="public.hotel_bookings2":
                outputs.append(luigi.LocalTarget(f'{DIR_TEMP_DATA}/public.hotel_bookings.csv'))
            else:
                outputs.append(luigi.LocalTarget(f'{DIR_TEMP_DATA}/{table_name}.csv'))
            
        outputs.append(luigi.LocalTarget(f'{DIR_TEMP_DATA}/extract-summary.csv'))
            
        outputs.append(luigi.LocalTarget(f'{DIR_TEMP_LOG}/logs.log'))
        return outputs


class Load(luigi.Task):
    
    def requires(self):
        return Extract()
    
    def run(self):
         
        # Configure logging
        logging.basicConfig(filename = f'{DIR_TEMP_LOG}/logs.log', 
                            level = logging.INFO, 
                            format = '%(asctime)s - %(levelname)s - %(message)s')
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Read query to be executed
        try:
            # Read query to truncate pactravel schema in dwh
            truncate_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/pactravel-truncate_tables.sql'
            )

            # Read load query to staging schema
            aircrafts_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-aircrafts.sql'
            )
            
            airlines_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-airlines.sql'
            )
            
            airports_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-airports.sql'
            )
            
            customers_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-customers.sql'
            )
            
            flight_bookings_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-flight_bookings.sql'
            )
            

            
            hotel_bookings_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-hotel_bookings.sql'
            )
            
            hotel_query = read_sql_file(
                file_path = f'{DIR_LOAD_QUERY}/src-hotel.sql'
            )


            logging.info("Read Load Query - SUCCESS")
            
        except Exception:
            logging.error("Read Load Query - FAILED")
            raise Exception("Failed to read Load Query")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Read Data to be load
        try:
            # Read csv
            aircrafts = pd.read_csv(self.input()[0].path)
            airlines = pd.read_csv(self.input()[1].path)
            airports = pd.read_csv(self.input()[2].path)
            customers = pd.read_csv(self.input()[3].path)
            flight_bookings = pd.read_csv(self.input()[4].path)
            hotel_bookings = pd.read_csv(self.input()[5].path)
            hotel = pd.read_csv(self.input()[6].path)
            
          
            logging.info(f"Read Extracted Data - SUCCESS")
            
        except Exception:
            logging.error(f"Read Extracted Data  - FAILED")
            raise Exception("Failed to Read Extracted Data")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Establish connections to DWH
        try:
            _, dwh_engine = db_connection()
            conn=dwh_engine.connect()
            logging.info(f"Connect to DWH - SUCCESS")
            
        except Exception:
            logging.info(f"Connect to DWH - FAILED")
            raise Exception("Failed to connect to Data Warehouse")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Truncate all tables before load
        # This puropose to avoid errors because duplicate key value violates unique constraint
        try:            
            # Split the SQL queries if multiple queries are present
            truncate_query = truncate_query.split(';')

            # Remove newline characters and leading/trailing whitespaces
            truncate_query = [query.strip() for query in truncate_query if query.strip()]
            
            # Create session
            Session = sessionmaker(bind = dwh_engine)
            session = Session()

            # Execute each query
            for query in truncate_query:
                query = sqlalchemy.text(query)
                session.execute(query)
                
            session.commit()
            
            # Close session
            session.close()

            logging.info(f"Truncate pactravel Schema in DWH - SUCCESS")
        
        except Exception:
            logging.error(f"Truncate pactravel Schema in DWH - FAILED")
            
            raise Exception("Failed to Truncate pactravel Schema in DWH")
        
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Record start time for loading tables
        start_time = time.time()  
        logging.info("==================================STARTING LOAD DATA=======================================")
        # Load to tables to pactravel schema
                
        try:
            # Load aircrafts tables    
            aircrafts.to_sql('aircrafts', 
                con = dwh_engine, 
                if_exists = 'append', 
                index = False, 
                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel_aircrafts' - SUCCESS")
            
            
            # Load airlines tables
            airlines.to_sql('airlines', 
                                con = dwh_engine, 
                                if_exists = 'append', 
                                index = False, 
                                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.airlines' - SUCCESS")

                            # Load customers tables
            customers.to_sql('customers', 
                                con = dwh_engine, 
                                if_exists = 'append', 
                                index = False, 
                                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.customers' - SUCCESS")

            # Load airports tables
            airports.to_sql('airports', 
                                con = dwh_engine, 
                                if_exists = 'append', 
                                index = False, 
                                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.airports' - SUCCESS")        


            # Load hotel tables
            hotel.to_sql('hotel', 
                                con = dwh_engine, 
                                if_exists = 'append', 
                                index = False, 
                                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.hotel' - SUCCESS")    


            flight_bookings.to_sql('flight_bookings', 
                                con = dwh_engine, 
                                if_exists = 'append', 
                                index = False, 
                                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.customers' - SUCCESS")

            hotel_bookings.to_sql('hotel_bookings', 
                con = dwh_engine, 
                if_exists = 'append', 
                index = False, 
                schema = 'pactravel')
            logging.info(f"LOAD 'pactravel.hotel_bookings' - SUCCESS")



            logging.info(f"LOAD All Tables To DWH-pactravel - SUCCESS")
            
        except Exception:
            logging.error(f"LOAD All Tables To DWH-pactravel - FAILED")
            raise Exception('Failed Load Tables To DWH-pactravel')
        
    
        # Record end time for loading tables
        end_time = time.time()  
        execution_time = end_time - start_time  # Calculate execution time
        
        # Get summary
        summary_data = {
            'timestamp': [datetime.now()],
            'task': ['Load'],
            'status' : ['Success'],
            'execution_time': [execution_time]
        }

        # Get summary dataframes
        summary = pd.DataFrame(summary_data)
        
        # Write Summary to CSV
        summary.to_csv(f"{DIR_TEMP_DATA}/load-summary.csv", index = False)
        
                
        logging.info("==================================ENDING LOAD DATA=======================================")
        
    #----------------------------------------------------------------------------------------------------------------------------------------
    def output(self):
        return [luigi.LocalTarget(f'{DIR_TEMP_LOG}/logs.log'),
                luigi.LocalTarget(f'{DIR_TEMP_DATA}/load-summary.csv')]



class GlobalParams(luigi.Config):
    CurrentTimeStampParams = luigi.DateSecondParameter(default=datetime.now())


class dbtDebug(luigi.Task):
    get_current_timestamp = GlobalParams().CurrentTimeStampParams

    def requires(self) -> None:  # type: ignore
        return Load()

    def output(self) -> T:  # type: ignore
        return luigi.LocalTarget(
            f"logs/dbt_debug/dbt_debug_logs_{self.get_current_timestamp}.log"
        )  # type: ignore

    def run(self) -> None:
        try:
            with open(self.output().path, "a") as f:
                p1 = sp.run(
                    "cd ./pactravel/ && dbt debug",
                    stdout=f,
                    stderr=sp.PIPE,
                    text=True,
                    shell=True,
                    check=True,
                )

                if p1.returncode == 0:
                    print("Success Run dbt debug process")

                else:
                    print("Failed to run dbt debug process")

        except Exception as e:
            raise e


class dbtDeps(luigi.Task):
    get_current_timestamp = GlobalParams().CurrentTimeStampParams

    def requires(self) -> Callable:  # type: ignore
        return dbtDebug()  # type: ignore

    def output(self) -> T:  # type: ignore
        return luigi.LocalTarget(
            f"logs/dbt_deps/dbt_deps_logs_{self.get_current_timestamp}.log"
        )  # type: ignore

    def run(self) -> None:
        try:
            with open(self.output().path, "a") as f:
                p1 = sp.run(
                    "cd ./pactravel/ && dbt deps",
                    stdout=f,
                    stderr=sp.PIPE,
                    text=True,
                    shell=True,
                    check=True,
                )

                if p1.returncode == 0:
                    print("Success Run dbt deps process")

                else:
                    print("Failed to run dbt deps process")

        except Exception as e:
            raise e


class dbtRun(luigi.Task):
    get_current_timestamp = GlobalParams().CurrentTimeStampParams

    def requires(self) -> Callable:  # type: ignore
        return dbtDeps()  # type: ignore

    def output(self) -> T:  # type: ignore
        return luigi.LocalTarget(
            f"logs/dbt_run/dbt_run_logs_{self.get_current_timestamp}.log"
        )  # type: ignore

    def run(self) -> None:
        try:
            with open(self.output().path, "a") as f:
                p1 = sp.run(
                    "cd ./pactravel/ && dbt build",
                    stdout=f,
                    stderr=sp.PIPE,
                    text=True,
                    shell=True,
                    check=True,
                )

                if p1.returncode == 0:
                    print("Success running dbt data model")

                else:
                    print("Failed to run dbt data model")

        except Exception as e:
            raise e


class dbtTest(luigi.Task):
    get_current_timestamp = GlobalParams().CurrentTimeStampParams

    def requires(self) -> Callable:  # type: ignore
        return dbtRun()  # type: ignore

    def output(self) -> T:  # type: ignore
        return luigi.LocalTarget(
            f"logs/dbt_test/dbt_test_logs_{self.get_current_timestamp}.log"
        )  # type: ignore

    def run(self) -> None:
        try:
            with open(self.output().path, "a") as f:
                p1 = sp.run(
                    "cd ./pactravel/ && dbt test",
                    stdout=f,
                    stderr=sp.PIPE,
                    text=True,
                    shell=True,
                    check=True,
                )

                if p1.returncode == 0:
                    print("Success running testing and create a constraints")

                else:
                    print("Failed running testing and create constraints")
            delete_temp(DIR_TEMP_DATA)
            print("Delete Temp Data")


        except Exception as e:
            raise e


if __name__ == "__main__":
    luigi.build([Extract(),Load(),dbtDebug(), dbtDeps(), dbtRun(), dbtTest()])

