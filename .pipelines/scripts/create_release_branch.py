import os
import sys
from datetime import datetime, timedelta
from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication
from azure.devops.v7_0.release.models import VariableValue, VariableGroupProjectReference, ProjectReference
from azure.devops.v7_0.task_agent.models import VariableGroupParameters


def parse_date(date_str):
    """Parse YYYY-MM-DD string into datetime.date"""
    return datetime.strptime(date_str, "%Y-%m-%d").date()


def get_variable_group(pat: str, client):
    variable_group = task_agent_client.get_variable_groups(project="athena", group_name="lightrun-helm-chart-variables")[0]
    return variable_group


def main():
    # today = datetime.utcnow().date()  # current UTC date
    
    if len(sys.argv) < 2:
        print("Usage: create_release_branch.py <AZURE_DEVOPS_PAT_RW>")
        sys.exit(1)

    pat = sys.argv[1]
    
    organization_url = "https://dev.azure.com/athenat"
    credentials = BasicAuthentication('', pat)
    connection = Connection(base_url=organization_url, creds=credentials)
    task_agent_client = connection.clients.get_task_agent_client()

    variable_group = get_variable_group(pat=pat)
    next_release_date = variable_group.variables['NEXT_RELEASE_DATE'].value
    override_release_date = variable_group.variables['OVERRIDE_RELEASE_DATE'].value

    if not next_release_date:
        print("NEXT_RELEASE_DATE is not set, exiting...")
        sys.exit(1)

    print(f"NEXT_RELEASE_DATE = {next_release_date}")
    
    if not override_release_date:
        print("OVERRIDE_RELEASE_DATE is not set")
    else:
        print(f"OVERRIDE_RELEASE_DATE = {override_release_date}")
    
    # Convert strings to date objects if they aren't already
    if isinstance(next_release_date, str):
        next_release_date = parse_date(next_release_date)
    if isinstance(override_release_date, str):
        override_release_date = parse_date(override_release_date)
    
    # Check the difference in days
    delta_days = abs((next_release_date - override_release_date).days)
    if delta_days > 13:
        print(f"OVERRIDE_RELEASE_DATE ({override_release_date}) is {delta_days} days away from NEXT_RELEASE_DATE ({next_release_date}). Max delta allowed is 13 days. Deleting value of OVERRIDE_RELEASE_DATE")
        
        if "OVERRIDE_RELEASE_DATE" in variable_group.variables:
            variable_group.variables["OVERRIDE_RELEASE_DATE"].value = "2025-10-23" # None

        variable_group_parameters = VariableGroupParameters(
                name=variable_group.name,
                description=variable_group.description,
                type=variable_group.type,
                variables=variable_group.variables,
                variable_group_project_references=[
                    VariableGroupProjectReference(
                         name=variable_group.name,
                        project_reference=ProjectReference(
                            id="ede58de8-5d83-4b61-9288-35b324e47e30",
                            name="athena"
                        )
                    )
                ]
            )
        
        # it removes the description
        updated_vars = task_agent_client.update_variable_group(variable_group_parameters=variable_group_parameters, group_id=46)

        print(updated_vars)

if __name__ == "__main__":
    main()
