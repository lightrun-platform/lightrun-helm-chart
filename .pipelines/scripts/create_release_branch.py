import os
import sys
from datetime import datetime, timedelta
from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication


def parse_date(date_str):
    """Parse YYYY-MM-DD string into datetime.date"""
    return datetime.strptime(date_str, "%Y-%m-%d").date()


def get_release_variables(pat: str):
    organization_url = "https://dev.azure.com/athenat"
    credentials = BasicAuthentication('', pat)
    connection = Connection(base_url=organization_url, creds=credentials)
    task_agent_client = connection.clients.get_task_agent_client()

    all_vars = task_agent_client.get_variable_groups(project="athena", group_name="lightrun-helm-chart-variables")[0].variables
    next_release_date = all_vars['NEXT_RELEASE_DATE'].value
    override_release_date = all_vars['OVERRIDE_RELEASE_DATE'].value

    print(f"next release date is {next_release_date} and the override is {override_release_date}")
    return next_release_date, override_release_date


def main():
    # today = datetime.utcnow().date()  # current UTC date
    
    if len(sys.argv) < 2:
        print("Usage: create_release_branch.py <AZURE_DEVOPS_PAT_RO>")
        sys.exit(1)

    pat = sys.argv[1]
    
    next_release_date, override_release_date = get_release_variables(pat=pat)
    
    print(f"NEXT_RELEASE_DATE = {next_release_date}")
    print(f"OVERRIDE_RELEASE_DATE = {override_release_date}")
    
    if not override_release_date:
        print("OVERRIDE_RELEASE_DATE is not set")
    

    # if not last_release_run_date_str:
    #     print("##vso[task.logissue type=error]lastReleaseRunDate is required")
    #     sys.exit(1)

    # last_release_run_date = parse_date(last_release_run_date_str)

    # # Check for override
    # if override_date_str:
    #     override_date = parse_date(override_date_str)

    #     if today == override_date:
    #         print(f"Override date matched today ({today}), pipeline will run ✅")
    #         sys.exit(0)  # continue pipeline
    #     elif today == last_release_run_date + timedelta(days=14):
    #         print(f"Today is the regular 2-week run date ({today}), but override is set -> skipping ❌")
    #         sys.exit(1)  # skip pipeline
    #     else:
    #         print(f"Override date ({override_date}) does not match today ({today}), skipping ❌")
    #         sys.exit(1)  # skip pipeline

    # # No override -> check bi-weekly Wednesday rule
    # next_regular_run = last_release_run_date + timedelta(days=14)

    # if today == next_regular_run and today.weekday() == 2:  # Wednesday = 2
    #     print(f"Today ({today}) is the regular 2nd Wednesday, pipeline will run ✅")
    #     sys.exit(0)
    # else:
    #     print(f"Today ({today}) is not the scheduled run date ({next_regular_run}), skipping ❌")
    #     sys.exit(1)

if __name__ == "__main__":
    main()
