#!usr/bin/env bash
set -euo pipefail

DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="venavision"
DB_USER="postgres"
TABLE_NAME="patients"

ALLOWED_COLUMNS=(first_name last_name birth_date diagnose last_needle_prick bloodtype sex follow_up cpr_number comment)

# ------------------------------
if [[ $# -ne 2 ]]; then
    echo "How to use: ./search_patients.sh <name of column> <value to search for>" >&2
    echo "Columns: first_name last_name diagnose last_needle_prick bloodtype sex follow_up cpr_number comment"
fi

column="$1"
value="$2"

# --------------- HOW TO SEARCH ----------------
# The case has 2 functionalities - only accept known columns, 
# and decide whether to match the entire input value or just a part of it.
case "$column" in
    sex|bloodtype)
        pattern="$value" ;; 
    first_name|last_name|birth_date|diagnose|last_needle_prick|follow_up|cpr_number|comment)
        pattern="%$value%" ;;
    *)
        echo "Unknown column: $column"
        exit 1 ;;
esac

# ---------- THE SEARCH ITSELF ----------
# Explanation: -v v="$pattern" in line 38 hands the value to the psql command as a variable named v.
# :'v' in line 39 puts it into the query, safely quoted.
# ILIKE ignores upper/lower case, and ::text lets it work on date columns too.
psql -h "$DB_host" -p "$DB_PORT" -u "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -v v="$pattern" \
    <<< "SELECT * FROM $TABLE_NAME WHERE $column::text ILIKE :'v' ORDER BY $column ASC;"
