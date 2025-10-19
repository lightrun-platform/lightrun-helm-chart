import sys
from datetime import datetime, timedelta
from msrest.authentication import BasicAuthentication
from azure.devops.connection import Connection
from azure.devops.v7_0.release.models import VariableGroupProjectReference, ProjectReference
from azure.devops.v7_0.task_agent.models import VariableGroupParameters

ORGANIZATION_NAME = "athenat"
ATHENA_PROJECT_ID = "ede58de8-5d83-4b61-9288-35b324e47e30"
ATHENA_PROJECT_NAME = "athena"
VARIABLE_GROUP_NAME = "lightrun-helm-chart-variables"
VARIABLE_GROUP_ID = 45


def parse_date(date_str):
    """Parse YYYY-MM-DD or YYYY-M-D into datetime.date"""
    try:
        year, month, day = map(int, date_str.split('-'))
        return datetime(year, month, day).date()
    except ValueError as e:
        raise ValueError(f"Invalid date format: {date_str}, correct format: YYYY-MM-DD") from e


def get_variable_group(client, group: str):
    variable_groups = client.get_variable_groups(project=ATHENA_PROJECT_NAME, group_name=group)
    if not variable_groups:
        raise ValueError(f"No variable group found with name '{group}' in project '{ATHENA_PROJECT_NAME}'.")
    
    return variable_groups[0]


def update_variable_group(variable_group, client):
        variable_group_parameters = VariableGroupParameters(
                name=variable_group.name,
                description=variable_group.description,
                type=variable_group.type,
                variables=variable_group.variables,
                variable_group_project_references=[
                    VariableGroupProjectReference(
                         name=variable_group.name,
                        project_reference=ProjectReference(
                            id=ATHENA_PROJECT_ID,
                            name=ATHENA_PROJECT_NAME
                        )
                    )
                ]
            )
        
        # removes the description of the variable group
        client.update_variable_group(variable_group_parameters=variable_group_parameters, group_id=VARIABLE_GROUP_ID)
        print("variable group updated.")


def main():
    if len(sys.argv) < 2:
        print("Usage: check_release_schedule.py <AZURE_DEVOPS_PAT_RW>")
        sys.exit(1)
    pat = sys.argv[1]

    organization_url = f"https://dev.azure.com/{ORGANIZATION_NAME}"
    credentials = BasicAuthentication('', pat)
    connection = Connection(base_url=organization_url, creds=credentials)
    task_agent_client = connection.clients.get_task_agent_client()

    variable_group = get_variable_group(client=task_agent_client, group=VARIABLE_GROUP_NAME)
    
    if 'NEXT_RELEASE_DATE' not in variable_group.variables:
        raise KeyError(f"Variable 'NEXT_RELEASE_DATE' not found in the variable group '{VARIABLE_GROUP_NAME}'.")
    NEXT_RELEASE_DATE = variable_group.variables['NEXT_RELEASE_DATE'].value

    if 'OVERRIDE_RELEASE_DATE' not in variable_group.variables:
        raise KeyError(f"Variable 'OVERRIDE_RELEASE_DATE' not found in the variable group '{VARIABLE_GROUP_NAME}'.")
    OVERRIDE_RELEASE_DATE = variable_group.variables['OVERRIDE_RELEASE_DATE'].value
    
    current_date = datetime.utcnow().date()

    if not NEXT_RELEASE_DATE:
        print("NEXT_RELEASE_DATE is not set, exiting...")
        sys.exit(1)
    else:
        print(f"NEXT_RELEASE_DATE = {NEXT_RELEASE_DATE}")
    
    if not OVERRIDE_RELEASE_DATE:
        print("OVERRIDE_RELEASE_DATE is not set, ignoring it.")
    else:
        print(f"OVERRIDE_RELEASE_DATE = {OVERRIDE_RELEASE_DATE}")
    
    if isinstance(NEXT_RELEASE_DATE, str):
        NEXT_RELEASE_DATE = parse_date(NEXT_RELEASE_DATE)
    if OVERRIDE_RELEASE_DATE and isinstance(OVERRIDE_RELEASE_DATE, str):
        OVERRIDE_RELEASE_DATE = parse_date(OVERRIDE_RELEASE_DATE)

    # check the difference in days
    delta_days = abs((NEXT_RELEASE_DATE - OVERRIDE_RELEASE_DATE).days) if OVERRIDE_RELEASE_DATE else None

    if delta_days is not None and delta_days > 13:
        print(f"OVERRIDE_RELEASE_DATE ({OVERRIDE_RELEASE_DATE}) is {delta_days} days away from NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}).\n"
              f"Max delta allowed is 13 days, deleting value of OVERRIDE_RELEASE_DATE and exiting.")
        
        if "OVERRIDE_RELEASE_DATE" in variable_group.variables:
            variable_group.variables["OVERRIDE_RELEASE_DATE"].value = None
        
        update_variable_group(variable_group, task_agent_client)
        sys.exit(1)

    elif OVERRIDE_RELEASE_DATE:
        print(f"OVERRIDE_RELEASE_DATE ({OVERRIDE_RELEASE_DATE}) has priority over NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}) and will be used.")
        if current_date != OVERRIDE_RELEASE_DATE:
            sys.exit(2) # exit if today is not the override date
        
        next_release_date_plus_2_weeks = NEXT_RELEASE_DATE + timedelta(weeks=2)
        variable_group.variables["NEXT_RELEASE_DATE"].value = next_release_date_plus_2_weeks
        variable_group.variables["OVERRIDE_RELEASE_DATE"].value = None

        update_variable_group(variable_group, task_agent_client)

    elif NEXT_RELEASE_DATE and not OVERRIDE_RELEASE_DATE:
        print(f"Using NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}) since OVERRIDE_RELEASE_DATE is None.")
        if current_date != NEXT_RELEASE_DATE:
            sys.exit(2) # exit if today is not the next release date
        
        next_release_date_plus_2_weeks = NEXT_RELEASE_DATE + timedelta(weeks=2)
        variable_group.variables["NEXT_RELEASE_DATE"].value = next_release_date_plus_2_weeks

        update_variable_group(variable_group, task_agent_client)


if __name__ == "__main__":
    main()
