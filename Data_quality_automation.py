import pandas as pd
import psycopg2

# Sensitive database credentials are replaced with placeholders
# to prevent exposing private connection details on GitHub.
# connect to postgresql
conn = psycopg2.connect(
    host="#####",
    database="#####",
    user="#####",
    password="#####"
)

print("postgresql connected succesfully " )

# read tables
candidates = pd.read_sql("select * from candidates", conn)
employers = pd.read_sql("select * from employers", conn)
postings = pd.read_sql("select * from postings", conn)
applications = pd.read_sql("select * from applications", conn)

# quality checks
checks = []

# candidates - missing city
missing_city = candidates["city"].isnull().sum()

checks.append({
    "check_name": "missing candidate city",
    "status": "pass" if missing_city == 0 else "fail",
    "failed_records": missing_city
})

# employers - duplicate company names
duplicate_companies = (
    employers.groupby("company_name")
    .size()
    .gt(1)
    .sum()
)

checks.append({
    "check_name": "duplicate company names",
    "status": "pass" if duplicate_companies == 0 else "fail",
    "failed_records": duplicate_companies
})

# applications - orphan postings
orphan_applications = applications[
    ~applications["posting_id"].isin(postings["posting_id"])
].shape[0]

checks.append({
    "check_name": "orphan applications",
    "status": "pass" if orphan_applications == 0 else "fail",
    "failed_records": orphan_applications
})

# create report
report = pd.DataFrame(checks)

# save report
report.to_csv("data_quality_report.csv", index=False)

print(report)
print("\nreport saved successfully!")


# create scorecard

scorecard = []

scorecard.append({
    "table_name": "candidates",
    "total_checks": 1,
    "passed_checks": 1 if missing_city == 0 else 0,
    "failed_checks": 0 if missing_city == 0 else 1
})

scorecard.append({
    "table_name": "employers",
    "total_checks": 1,
    "passed_checks": 1 if duplicate_companies == 0 else 0,
    "failed_checks": 0 if duplicate_companies == 0 else 1
})

scorecard.append({
    "table_name": "applications",
    "total_checks": 1,
    "passed_checks": 1 if orphan_applications == 0 else 0,
    "failed_checks": 0 if orphan_applications == 0 else 1
})

scorecard_df = pd.DataFrame(scorecard)

scorecard_df["health_score"] = (
    scorecard_df["passed_checks"] * 100 /
    scorecard_df["total_checks"]
).round(2)

scorecard_df.to_csv("data_quality_scorecard.csv", index=False)

print("\nscorecard:")
print(scorecard_df)
print("\nscorecard saved successfully!")
