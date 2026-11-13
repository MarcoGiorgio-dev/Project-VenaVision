#!/usr/bin/env bash
# COMMAND FOR CHAINING COMMANDS IN PIPELINE - 1 PART FAILS = ENTIRE PIPELINE FAILS
set -euo pipefail

# ---------------- CONFIG SECTION ------------------
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="venavision"
DB_USER="postgres"
TABLE_NAME="patients"
COUNT=100

# --------- LISTS OF POSSIBLE DATAINSERTS ----------
DIAGNOSES=(
	"Type 1 diabetes"
	"Type 2 diabetes"
	"Hypertension"
	"Asthma"
	"Anemia"
	"Hepatitis B"
	"Hypothyroidism"
	"COPD"
	"Atrial fibrillation"
	"Migraine"
	"Chronic kidney disease"
	"Sickle cell anemia"
)

BLOODTYPES=("A+" "A-" "B+" "B-" "AB+" "AB-" "O+" "O-")

SEX=("Male" "Female")

COMMENT=(
	"No comments"
	"Afraid of needles"
	"High blood pressure"
	"Cancer patient"
	"Has had an operation performed on the left side of the body"
	"Has had an operation performed on the right side of the body"
	"Has had a blood clot"
	"Has lymphedema"
	"Has a pacemaker"
	"Has burns across their arms"
	"Has severe eczema"
	"Has dialysis from a graft in their right arm"
	"Has dialysis from a graft in their left arm"
	"Has scar tissue covering their arms"
	"Substance abuse"
	"Has fragile veins"
	"Is taking anticoagulants"
	"Is on steroid treatment"
	"Has chlorhexidine allergy"
	"Has dementia"
	"Has adhesive contact dermatitis"
	"Has blown veins"
	"Has skin tears"
	"Has rolling veins"
	"Has nerve damage in their arms"
	"Has small veins"
	"Has deep laying veins"
)

# ----------- FUNCTIONS FOR INSERTIONS -------------
# FUNCTION FOR CHOOSING RANDOM ARGUMENT WITHIN LISTS
random_from() {
	local -n list=$1
	local index=$(( RANDOM % ${#list[@]} ))
	echo "${list[$index]}"
}

# FUNCTIONS FOR GENERATING DATES
random_birthdate() {
	local start=$1
	local end=$2
	local year=$(( start + RANDOM % (end - start + 1) ))
	local month=$(( 1 + RANDOM % 12))
	local day=$(( 1 + RANDOM % 28 ))
	printf "%04d-%02d-%02d\n" "$year" "$month" "$day"
}

random_last_prick() {
	local days_back=$1
	local n=$(( RANDOM % (days_back + 1) ))
	date -d "$n days ago" +%F
}

# FUNCTIONS FOR GENERATING LAST PRICK DATES
add_days() {
	local base=$1
	local n=$2
	date -d "$base + $n days" +%F
}

# FUNCTION FOR RANDOMLY GENERATING CPR NUMBERS
make_cpr() {
	local birthdate=$1
	local sex=$2
	local ddmmyy
	ddmmyy=$(date -d "$birthdate" +%d%m%y)
	local mid=$(( RANDOM % 1000 ))
	local last
	if [[ "$sex" == "Male" ]]; then
		last=$(( 1 + 2 * (RANDOM % 5) ))
	else
		last=$(( 2 * (random % 5) ))
	fi
	printf "%s-%03d%d\n" "$ddmmyy" "$mid" "$last"
}

# ---- DATA ENTRY LOOP USING PREVIOUS FUNCTIONS ----
for i in $(seq 1 "$COUNT"); do
	sex=$(random_from SEX)
	birthdate=$(random_birthdate 1930 2025)
	diagnose=$(random_from DIAGNOSES)
	bloodtype=$(random_from BLOODTYPES)
	last_prick=$(random_last_prick 365)
	follow_up=$(add_days "$last_prick" $(( 14 + RANDOM % 167 )))
	cpr=$(make_cpr "$birthdate" "$sex")
	comment=$(random_from COMMENT)
        sql+=$(printf "INSERT INTO %s (birthdate, diagnose, last_needle_prick, bloodtype, sex, follow_up, cpr_number, comment) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');" \
                "$TABLE_NAME" "$birthdate" "$diagnose" "$last_prick" "$bloodtype" "$sex" "$follow_up" "$cpr" "$comment")
        sql+=$'\n'
done

printf '%s\n' "BEGIN;" "$sql" "COMMIT;" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1

echo "Inserted $COUNT patients"
