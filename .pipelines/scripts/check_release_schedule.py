import sys
from datetime import datetime, timedelta
from msrest.authentication import BasicAuthentication
from azure.devops.connection import Connection
from azure.devops.v7_0.release.models import VariableGroupProjectReference, ProjectReference
from azure.devops.v7_0.task_agent.models import VariableGroupParameters

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


def get_variable_group(client):
    variable_group = client.get_variable_groups(project=ATHENA_PROJECT_NAME, group_name=VARIABLE_GROUP_NAME)[0]
    return variable_group


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
    current_date = datetime.utcnow().date()
    
    if len(sys.argv) < 2:
        print("Usage: check_release_schedule.py <AZURE_DEVOPS_PAT_RW>")
        sys.exit(1)
    pat = sys.argv[1]

    organization_url = "https://dev.azure.com/athenat"
    credentials = BasicAuthentication('', pat)
    connection = Connection(base_url=organization_url, creds=credentials)
    task_agent_client = connection.clients.get_task_agent_client()

    variable_group = get_variable_group(client=task_agent_client)
    next_release_date = variable_group.variables['NEXT_RELEASE_DATE'].value
    override_release_date = variable_group.variables['OVERRIDE_RELEASE_DATE'].value

    if not next_release_date:
        print("NEXT_RELEASE_DATE is not set, exiting...")
        sys.exit(1)
    else:
        print(f"NEXT_RELEASE_DATE = {next_release_date}")
    
    if not override_release_date:
        print("OVERRIDE_RELEASE_DATE is not set, ignoring it.")
    else:
        print(f"OVERRIDE_RELEASE_DATE = {override_release_date}")
    
    if isinstance(next_release_date, str):
        next_release_date = parse_date(next_release_date)
    if override_release_date and isinstance(override_release_date, str):
        override_release_date = parse_date(override_release_date)

    # check the difference in days
    delta_days = abs((next_release_date - override_release_date).days) if override_release_date else None

    if delta_days is not None and delta_days > 13:
        print(f"OVERRIDE_RELEASE_DATE ({override_release_date}) is {delta_days} days away from NEXT_RELEASE_DATE ({next_release_date}).\n"
              f"Max delta allowed is 13 days, deleting value of OVERRIDE_RELEASE_DATE and exiting.")
        
        if "OVERRIDE_RELEASE_DATE" in variable_group.variables:
            variable_group.variables["OVERRIDE_RELEASE_DATE"].value = None
        
        update_variable_group(variable_group, task_agent_client)
        sys.exit(1)

    elif override_release_date:
        print(f"OVERRIDE_RELEASE_DATE ({override_release_date}) has priority over NEXT_RELEASE_DATE ({next_release_date}) and will be used.")
        if current_date != override_release_date:
            sys.exit(2) # exit if today is not the override date
        
        next_release_date_plus_2_weeks = next_release_date + timedelta(weeks=2)
        variable_group.variables["NEXT_RELEASE_DATE"].value = next_release_date_plus_2_weeks
        variable_group.variables["OVERRIDE_RELEASE_DATE"].value = None

        update_variable_group(variable_group, task_agent_client)

    elif next_release_date and not override_release_date:
        print(f"Using NEXT_RELEASE_DATE ({next_release_date}) since OVERRIDE_RELEASE_DATE is none.")
        if current_date != next_release_date:
            sys.exit(2) # exit if today is not the next release date
        
        next_release_date_plus_2_weeks = next_release_date + timedelta(weeks=2)
        variable_group.variables["NEXT_RELEASE_DATE"].value = next_release_date_plus_2_weeks

        update_variable_group(variable_group, task_agent_client)


if __name__ == "__main__":
    main()
