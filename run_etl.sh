# Virtual Environment Path
VENV_PATH="/home/istywhyerlina/datastorage_w7/venv/bin/activate"

# Activate Virtual Environment
source "$VENV_PATH"

# Set Python script
PYTHON_SCRIPT="/home/istywhyerlina/datastorage_w7/elt_pipeline.py"

# Run Python Script and Insert Log Process
python "$PYTHON_SCRIPT" >> /home/istywhyerlina/datastorage_w7/logs/logs.log 2>&1

# Luigi info simple log
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "Luigi started at ${dt}" >> /home/istywhyerlina/datastorage_w7/logs/luigi_info.log

