#!/usr/bin/env bash
set -euo pipefail

# -------- CONFIG SECTION ---------
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="venavision"
DB_USER="postgres"
TABLE_NAME="patients"
COUNT=100

# ------------- LIST --------------
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

# ----------- FUNCTIONS -----------
random_from() {
	local -n list=$1
	local index=$(( RANDOM % ${#list[@]} ))
	echo "${list[$index]}"
}

random_date() {
	local start=$1
	local end=$2
	local year=$(( start + RANDOM % (end - start + 1) ))
	local month=$(( 1 + RANDOM % 12))
	local day=$(( 1 + RANDOM % 28 ))
	printf "%04d-%02d-%02d\n" "$year" "$month" "$day"
}

random_date 1930 2024
